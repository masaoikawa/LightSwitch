/*
    Arduino BLE Nano
      Bluetooth Low Energy Boards
      Based on Nordic nRF51822

    LED Light, Arudino BLE Nano Module, Switch On/OFF
    秋月のソリッドステートリレー & イケヤ LED Light & RedBearBLE Nano

*/

#include <Servo.h>
#include <BLE_API.h>
#include <LiquidCrystal.h>

#define TXRX_BUF_LEN                     20

//Pin For Nano
#ifdef BLE_NANO

#define DIGITAL_OUT_PIN   		 D1
#define DIGITAL_IN_PIN     		 D2
#define PWM_PIN           	         D0
#define SERVO_PIN        		 D3
#define ANALOG_IN_PIN      		 A3

#endif

#define STATUS_CHECK_TIME                APP_TIMER_TICKS(200, 0)

Servo myservo;

BLEDevice  ble;

static app_timer_id_t                    m_status_check_id; 
static boolean analog_enabled = false;
static byte old_state = LOW;
static boolean light_switch = true;
static boolean light_old = false;

// The Nordic UART Service
static const uint8_t uart_base_uuid[]     = {0x71, 0x3D, 0, 0, 0x50, 0x3E, 0x4C, 0x75, 0xBA, 0x94, 0x31, 0x48, 0xF1, 0x8D, 0x94, 0x1E};
static const uint8_t uart_tx_uuid[]       = {0x71, 0x3D, 0, 3, 0x50, 0x3E, 0x4C, 0x75, 0xBA, 0x94, 0x31, 0x48, 0xF1, 0x8D, 0x94, 0x1E};
static const uint8_t uart_rx_uuid[]       = {0x71, 0x3D, 0, 2, 0x50, 0x3E, 0x4C, 0x75, 0xBA, 0x94, 0x31, 0x48, 0xF1, 0x8D, 0x94, 0x1E};
static const uint8_t uart_base_uuid_rev[] = {0x1E, 0x94, 0x8D, 0xF1, 0x48, 0x31, 0x94, 0xBA, 0x75, 0x4C, 0x3E, 0x50, 0, 0, 0x3D, 0x71};
uint8_t txPayload[TXRX_BUF_LEN] = {0,};
uint8_t rxPayload[TXRX_BUF_LEN] = {0,};

GattCharacteristic  txCharacteristic (uart_tx_uuid, txPayload, 1, TXRX_BUF_LEN,
                                      GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_WRITE | GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_WRITE_WITHOUT_RESPONSE);
                                      
GattCharacteristic  rxCharacteristic (uart_rx_uuid, rxPayload, 1, TXRX_BUF_LEN,
                                      GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_NOTIFY);
                                      
GattCharacteristic *uartChars[] = {&txCharacteristic, &rxCharacteristic};
GattService         uartService(uart_base_uuid, uartChars, sizeof(uartChars) / sizeof(GattCharacteristic *));

void disconnectionCallback(void)
{
    ble.startAdvertising();
}

void onDataWritten(uint16_t charHandle)
{	
    uint8_t buf[TXRX_BUF_LEN];
    uint16_t bytesRead;
	
    if (charHandle == txCharacteristic.getHandle()) 
    {
        ble.readCharacteristicValue(txCharacteristic.getHandle(), buf, &bytesRead);

        memset(txPayload, 0, TXRX_BUF_LEN);
        memcpy(txPayload, buf, TXRX_BUF_LEN);		

        // ライトON/OFF 0x0101=ON 0x0100=OFF
        if (buf[0] == 0x01)  // Command is to control digital out pin
        {
            if (buf[1] == 0x01) {
                digitalWrite(DIGITAL_OUT_PIN, HIGH);
                light_switch = true;
            } else {
                digitalWrite(DIGITAL_OUT_PIN, LOW);
                light_switch = false;
            }
        }
        else if (buf[0] == 0xA0) // Command is to enable analog in reading
        {
            if (buf[1] == 0x01)
              analog_enabled = true;
            else
              analog_enabled = false;
        }
        else if (buf[0] == 0x02) // Command is to control PWM pin
        {
            analogWrite(PWM_PIN, buf[1]);
        }
        else if (buf[0] == 0x03)  // Command is to control Servo pin
        {
            myservo.write(buf[1]);
        }
        else if (buf[0] == 0x04)  // Command is to ?
        {
            analog_enabled = false;
            myservo.write(0);
            analogWrite(PWM_PIN, 0);
            digitalWrite(DIGITAL_OUT_PIN, LOW);
            old_state = LOW;
        }
    }
}


// 流用する場合は以下を全てコピーする
#include "nrf_soc.h"
#define VBAT_MAX_IN_MV                  3300

uint8_t battery_level_get(void)
{
    // Configure ADC
    NRF_ADC->CONFIG     = (ADC_CONFIG_RES_8bit                        << ADC_CONFIG_RES_Pos)     |
                          (ADC_CONFIG_INPSEL_SupplyOneThirdPrescaling << ADC_CONFIG_INPSEL_Pos)  |
                          (ADC_CONFIG_REFSEL_VBG                      << ADC_CONFIG_REFSEL_Pos)  |
                          (ADC_CONFIG_PSEL_Disabled                   << ADC_CONFIG_PSEL_Pos)    |
                          (ADC_CONFIG_EXTREFSEL_None                  << ADC_CONFIG_EXTREFSEL_Pos);
    NRF_ADC->EVENTS_END = 0;
    NRF_ADC->ENABLE     = ADC_ENABLE_ENABLE_Enabled;

    NRF_ADC->EVENTS_END  = 0;    // Stop any running conversions.
    NRF_ADC->TASKS_START = 1;
    
    while (!NRF_ADC->EVENTS_END)
    {
    }
    
    uint16_t vbg_in_mv = 1200;
    uint8_t adc_max = 255;
    uint16_t vbat_current_in_mv = (NRF_ADC->RESULT * 3 * vbg_in_mv) / adc_max;
    
    NRF_ADC->EVENTS_END     = 0;
    NRF_ADC->TASKS_STOP     = 1;
    
    return (uint8_t) ((vbat_current_in_mv * 100) / VBAT_MAX_IN_MV);
}

uint32_t temperature_data_get(void)
{
    int32_t temp;
    uint32_t err_code;
    
    err_code = sd_temp_get(&temp);
    APP_ERROR_CHECK(err_code);
    
    temp = (temp / 4) * 100;
    
    int8_t exponent = -2;
    return ((exponent & 0xFF) << 24) | (temp & 0x00FFFFFF);
}


void m_status_check_handle(void * p_context)
{   
    uint8_t buf[3];
    if (analog_enabled)  // if analog reading enabled
    {
        // Read and send out
        uint16_t value = analogRead(ANALOG_IN_PIN); 
        buf[0] = (0x0B);
        buf[1] = (value >> 8);
        buf[2] = (value);
        ble.updateCharacteristicValue(rxCharacteristic.getHandle(), buf, 3);
    }
    // If digital in changes, report the state
    if (digitalRead(DIGITAL_IN_PIN) != old_state)
    {
        old_state = digitalRead(DIGITAL_IN_PIN);
        
        if (digitalRead(DIGITAL_IN_PIN) == HIGH)
        {
            buf[0] = (0x0A);
            buf[1] = (0x01);
            buf[2] = (0x00);    
            ble.updateCharacteristicValue(rxCharacteristic.getHandle(), buf, 3);
        }
        else
        {
            buf[0] = (0x0A);
            buf[1] = (0x00);
            buf[2] = (0x00);
            ble.updateCharacteristicValue(rxCharacteristic.getHandle(), buf, 3);
        }
    }
    if (light_switch != light_old){
        light_old = light_switch;
        if (light_switch == true) {
            buf[0] = (0x01);
            buf[1] = (0x01);
            buf[2] = (0x00);    
            ble.updateCharacteristicValue(rxCharacteristic.getHandle(), buf, 3);
        }else{
            buf[0] = (0x01);
            buf[1] = (0x00);
            buf[2] = (0x00);    
            ble.updateCharacteristicValue(rxCharacteristic.getHandle(), buf, 3);            
        }
    }
}

void setup(void)
{  
    uint32_t err_code = NRF_SUCCESS;
    
    delay(1000);
    //Serial.begin(9600);
    //Serial.println("Initialising the nRF51822\n\r");
    ble.init();
    ble.onDisconnection(disconnectionCallback);
    ble.onDataWritten(onDataWritten);

    // setup advertising 
    ble.accumulateAdvertisingPayload(GapAdvertisingData::BREDR_NOT_SUPPORTED);
    ble.setAdvertisingType(GapAdvertisingParams::ADV_CONNECTABLE_UNDIRECTED);
    ble.accumulateAdvertisingPayload(GapAdvertisingData::SHORTENED_LOCAL_NAME,
                                    (const uint8_t *)"Biscuit", sizeof("Biscuit") - 1);
    ble.accumulateAdvertisingPayload(GapAdvertisingData::COMPLETE_LIST_128BIT_SERVICE_IDS,
                                    (const uint8_t *)uart_base_uuid_rev, sizeof(uart_base_uuid));
    // 100ms; in multiples of 0.625ms. 
    ble.setAdvertisingInterval(160);

    ble.addService(uartService);
    
    ble.startAdvertising();
    
    pinMode(DIGITAL_OUT_PIN, OUTPUT);
    pinMode(DIGITAL_IN_PIN, INPUT_PULLUP);
    pinMode(PWM_PIN, OUTPUT);
    //pinMode(13, OUTPUT);
    // Default to internally pull high, change it if you need
    digitalWrite(DIGITAL_IN_PIN, HIGH);
    digitalWrite(DIGITAL_OUT_PIN, HIGH);
    
    myservo.attach(SERVO_PIN);
    myservo.write(0);

    err_code = app_timer_create(&m_status_check_id,APP_TIMER_MODE_REPEATED, m_status_check_handle);
    APP_ERROR_CHECK(err_code);
    
    err_code = app_timer_start(m_status_check_id, STATUS_CHECK_TIME, NULL);
    APP_ERROR_CHECK(err_code);    
    
    //Serial.println("Advertising Start!");
}

void loop(void)
{
    ble.waitForEvent();
}
