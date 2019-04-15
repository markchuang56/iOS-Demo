//
//  TransferService.h
//  h2Ble
//
//  Created by h2Sync on 2015/1/20.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//
/*
#ifndef h2Ble_TransferService_h
#define h2Ble_TransferService_h


#endif
*/ 



/*
#define BLE_NAME_LEN_H2                             19
#define BLE_NAME_LEN_FORA                           9
#define BLE_NAME_LEN_HMD                            13

#define BLE_NAME_H2                                 @"H2 CABLE"
#define BLE_NAME_FORA                               @"FORA "
#define BLE_NAME_HMD                                @"HMD "


#define NORMAL_RECORD_TIME                                  3.0f
#define BLE_RECORD_TIME                                     30.0f

*/


#ifndef LE_Profile_TransferService_h
#define LE_Profile_TransferService_h


// #define TRANSFER_SERVICE_UUID                       @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
// #define TRANSFER_CHARACTERISTIC_UUID                @"08590F7E-DB05-467E-8757-72F6FAEB13D4"

/*
#pragma mark - H2 BT 4.0 UUID STRING
// demo board test, maybe...
#define H2_CABLE_SERVICE_UUID                       @"AE618100-3266-4BBA-9626-06CBE7657213"
#define H2_METER_SERVICE_UUID                       @"AE618200-3266-4BBA-9626-06CBE7657213"

#define H2_CABLE_INFO_CHARACTERISTIC_UUID           @"AE618101-3266-4BBA-9626-06CBE7657213"

#define H2_METER_INFO_CHARACTERISTIC_UUID           @"AE618201-3266-4BBA-9626-06CBE7657213"
#define H2_METER_RECORD_CHARACTERISTIC_UUID         @"AE618202-3266-4BBA-9626-06CBE7657213"

// OAD
#define H2_OAD_IMG_SERVICE_UUID                         @"AE61FFC0-3266-4BBA-9626-06CBE7657213"

#define H2_OAD_IMG_ID_CHARACTERISTIC_UUID               @"AE61FFC1-3266-4BBA-9626-06CBE7657213"
#define H2_OAD_IMG_BLOCK_CHARACTERISTIC_UUID            @"AE61FFC2-3266-4BBA-9626-06CBE7657213"
*/

// OAD FOR TI
//#define H2_OAD_IMG_SERVICE_UUID                         @"F000FFC0-0451-4000-B000-000000000000"

//#define H2_OAD_IMG_ID_CHARACTERISTIC_UUID               @"F000FFC1-0451-4000-B000-000000000000"
//#define H2_OAD_IMG_BLOCK_CHARACTERISTIC_UUID            @"F000FFC2-0451-4000-B000-000000000000"




// for RN4020 Test

#define RN4020_SERVICE_UUID_STRING                      @"00035B03-58E6-07DD-021A-08123A000300"

#define RN4020_CHARACTERISTIC_TMP_NW_UUID_STRING        @"00035B03-58E6-07DD-021A-08123A000301" // 28
#define RN4020_CHARACTERISTIC_TMP_WRITE_UUID_STRING     @"00035B03-58E6-07DD-021A-08123A0003FF"





// Device Infor
#pragma mark - DEVICE INFO

#define     BLE_DEVINFO_SERVICE_ID                      @"180A"

#define     BLE_DEVICE_NAME_ID                          @"2A00"

#define     BLE_MANUFACTURER_ID                         @"2A29"
#define     BLE_MODEL_ID                                @"2A24"
#define     BLE_HARDWARE_ID                             @"2A27"
#define     BLE_FIRMWARE_ID                             @"2A26"
#define     BLE_SOFTWARE_ID                             @"2A28"
#define     BLE_SERIALNUMBER_ID                         @"2A25"

#define     BLE_SYSTEM_ID                               @"2A23"

#define     BLE_PNP_ID                                  @"2A50"
#define     BLE_EEE_ID                                  @"2A2A"

#define     BLE_Date_Time_ID                            @"2A08"

#pragma mark - BLOOD PRESSURE
#define     BLE_BLOOD_PRESSURE_SERVICE_ID                       @"1810"

#define     BLE_BLOOD_PRESSURE_MEASUREMENT_ID                       @"2A35"
#define     BLE_BLOOD_PRESSURE_CUFF_ID                              @"2A36"
#define     BLE_BLOOD_PRESSURE_FEATURE_ID                           @"2A49"

// Battery Service
#pragma mark - BATTERY

#define     BLE_BATTERY_SERVICE_ID                      @"180F"
#define     BLE_BATTERY_LEVEL_ID                        @"2A19"

// Current Time
#pragma mark - CURRENT TIME

#define     BLE_CURRENT_TIME_SERVICE_ID                 @"1805"
#define     BLE_CURRENT_TIME_ID                         @"2A2B"

#define     BLE_EXACT_TIME_256_ID                         @"2A0C"

// Glucose Service
#pragma mark - GLUCOSE SERVICE
#define  BLE_GLUCOSE_SERVICE_ID                             @"1808"

#define  BLE_RECORD_ACCESS_CONTROL_POINT_ID                 @"2A52"
#define  H2_FEATURE_ID                                      @"2A51"
#define  H2_MEASUREMENT_ID                                  @"2A18"
#define  H2_MEASUREMENT_CONTEXT_ID                          @"2A34"
#define  H2_GENERAL_SERVICE_ID                              @"2A00"

// Weight Scale
#define     BLE_WEIGHT_SCALE_SERVICE_ID                     @"181D"

#define     BLE_WEIGHT_MEASUREMENT_ID                       @"2A9D" // 20
#define     BLE_WEIGHT_SCALE_FEATURE_ID                     @"2A9E" // 02

#endif

#pragma mark - BP SERVICE or HEALTH THERMO METER
#define BLE_HEALTH_THERMOMETER                          @"1809"


// ARKRAY
#define ARK_GBLACK_SERVICE_UUID                         @"040F9E5C-A38E-4F10-B44C-71C3E8B5477B" //

// Report characteristic
#define BLE_REPORT_ID                                   @"2A4D" // 0x28, 0010 1000
#define ARK_GENERAL_CHARACTERISTIC_UUID                 @"DE5AC50D-7031-4BA4-BDB8-9A4F204B1507" // 0x28, 0010 1000
//#define BLE_REPORT_ID                               @"FF01" // 0x28, 0010 1000


#import <CoreBluetooth/CoreBluetooth.h>

@interface H2BleProfile : NSObject{
    
    
}

// Device INFO
@property (nonatomic, strong)CBUUID *bleDevInfoServiceUUID;

@property (nonatomic, strong)CBUUID *bleDeviceNameUUID;
@property (nonatomic, strong)CBUUID *bleManufacturerUUID;
@property (nonatomic, strong)CBUUID *bleModelUUID;
@property (nonatomic, strong)CBUUID *bleHarewareUUID;
@property (nonatomic, strong)CBUUID *bleFirmwareUUID;
@property (nonatomic, strong)CBUUID *bleSoftwareUUID;
@property (nonatomic, strong)CBUUID *bleSerialNumberUUID;
@property (nonatomic, strong)CBUUID *bleSystemUUID;
@property (nonatomic, strong)CBUUID *blePnpUUID;
@property (nonatomic, strong)CBUUID *bleEeeUUID;

@property (nonatomic, strong)CBUUID *bleDateTimeUUID;
// HEALTH THERMO METER

@property (nonatomic, strong)CBUUID *bleHealthHermoServiceUUID;
//health thermometer

// BLOOD PRESSURE

@property (nonatomic, strong)CBUUID *bleBPServiceUUID;
@property (nonatomic, strong)CBUUID *bleBPMeasurementUUID;
@property (nonatomic, strong)CBUUID *bleBPCuffUUID;
@property (nonatomic, strong)CBUUID *bleBPFreatureUUID;

@property (nonatomic, strong) CBService *bleBPService;
@property (nonatomic, strong) CBCharacteristic *bleCharBPMeasurement;


@property (nonatomic, strong) CBCharacteristic *bleCharBPCuff;
@property (nonatomic, strong) CBCharacteristic *bleCharBPFeature;


// Battery LEVEL
@property (nonatomic, strong)CBUUID *bleBatteryServiceUUID;
@property (nonatomic, strong)CBUUID *bleBatteryLevelCharacteristicUUID;


// Current Time
@property (nonatomic, strong)CBUUID *bleCurrentTimeServiceUUID;
@property (nonatomic, strong)CBUUID *bleCurrentTimeCharacteristicUUID;
@property (nonatomic, strong)CBUUID *bleExactTime256CharacteristicUUID;

@property (nonatomic, strong) CBService *bleCTService;
@property (nonatomic, strong) CBCharacteristic *bleCharCurrentTime;

@property (nonatomic, strong) CBCharacteristic *bleCharDateTime;

// BLE Glucose
@property (nonatomic, strong) CBUUID *bleBgmServiceID;

@property (nonatomic, strong) CBUUID *bleBgmCharacteristic_RecordAccessControlPointID;
@property (nonatomic, strong) CBUUID *bleBgmCharacteristic_FeatureID;
@property (nonatomic, strong) CBUUID *bleBgmCharacteristic_MeasurementID;
@property (nonatomic, strong) CBUUID *h2BgmCharacteristic_ContextID;

// BLE Weight Scale
@property (nonatomic, strong) CBUUID *bleBwsServiceID;

@property (nonatomic, strong) CBUUID *bleBwsCharacteristic_MeasurementID;
@property (nonatomic, strong) CBUUID *bleBwsCharacteristic_FeatureID;

// BLE BGM Service
@property (nonatomic, strong) CBService *h2_BleBgm_Service;

// BLE BGM Characteristic
@property (nonatomic, strong) CBCharacteristic *h2_BleBgm_CHAR_Measurement;
@property (nonatomic, strong) CBCharacteristic *h2_BleBgm_CHAR_Feature;
@property (nonatomic, strong) CBCharacteristic *h2_BleBgm_CHAR_RecordAccessControlPoint;
@property (nonatomic, strong) CBCharacteristic *h2_BleBgm_CHAR_MeasurementContext;

@property (nonatomic, strong) CBCharacteristic *bleCharSerialNumber;

// BLE BGM Service
@property (nonatomic, strong) CBService *bleBws_Service;

// BLE BGM Characteristic
@property (nonatomic, strong) CBCharacteristic *bleBws_CHAR_Measurement;
@property (nonatomic, strong) CBCharacteristic *bleBws_CHAR_Feature;

@property (readwrite) BOOL currentTimeReady;
@property (readwrite) BOOL serialNumberReady;


+ (H2BleProfile *)sharedBleProfileInstance;

@end











