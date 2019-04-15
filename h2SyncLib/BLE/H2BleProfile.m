//
//  H2SyncService.m
//  h2Central
//
//  Created by h2Sync on 2015/2/2.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>
// BLE 
//#import "H2BleService.h"
#import "H2BleProfile.h"

// SYSTEM
#import "h2DebugHeader.h"
#import "h2CmdInfo.h"
#import "h2Config.h"

#import "H2Sync.h"

// DEVICE
#import "Fora.h"
#import "H2BleHmd.h"
#import "H2BleOad.h"
#import "BleBtm.h"


@implementation H2BleProfile{
    
    
}


- (id)init
{
    if (self = [super init]) {
        
        // Device INFO
        
        _bleDevInfoServiceUUID = [CBUUID UUIDWithString:BLE_DEVINFO_SERVICE_ID];
        
        _bleDeviceNameUUID = [CBUUID UUIDWithString:BLE_DEVICE_NAME_ID];
        _bleManufacturerUUID = [CBUUID UUIDWithString:BLE_MANUFACTURER_ID];
        _bleModelUUID = [CBUUID UUIDWithString:BLE_MODEL_ID];
        _bleHarewareUUID = [CBUUID UUIDWithString:BLE_HARDWARE_ID];
        _bleFirmwareUUID = [CBUUID UUIDWithString:BLE_FIRMWARE_ID];
        _bleSoftwareUUID = [CBUUID UUIDWithString:BLE_SOFTWARE_ID];
        _bleSerialNumberUUID = [CBUUID UUIDWithString:BLE_SERIALNUMBER_ID];
        
        _bleSystemUUID = [CBUUID UUIDWithString:BLE_SYSTEM_ID];
        _blePnpUUID = [CBUUID UUIDWithString:BLE_PNP_ID];
        _bleEeeUUID = [CBUUID UUIDWithString:BLE_EEE_ID];
        
        _bleDateTimeUUID = [CBUUID UUIDWithString:BLE_Date_Time_ID];
        // HEALTH THERMO METER
        
        
        _bleHealthHermoServiceUUID =  [CBUUID UUIDWithString:BLE_HEALTH_THERMOMETER];
        // BLOOD PRESSURE
        
        _bleBPServiceUUID = [CBUUID UUIDWithString:BLE_BLOOD_PRESSURE_SERVICE_ID];
        
        _bleBPMeasurementUUID = [CBUUID UUIDWithString:BLE_BLOOD_PRESSURE_MEASUREMENT_ID];
        _bleBPCuffUUID = [CBUUID UUIDWithString:BLE_BLOOD_PRESSURE_CUFF_ID];
        _bleBPFreatureUUID = [CBUUID UUIDWithString:BLE_BLOOD_PRESSURE_FEATURE_ID];
        
        
        
        _bleBPService = nil;
        
        _bleCharBPMeasurement = nil;
        _bleCharBPCuff = nil;
        _bleCharBPFeature = nil;
        
        
        // Battery LEVEL
        _bleBatteryServiceUUID = [CBUUID UUIDWithString:BLE_BATTERY_SERVICE_ID];
        _bleBatteryLevelCharacteristicUUID = [CBUUID UUIDWithString:BLE_BATTERY_LEVEL_ID];
        
        // Current TIME
        _bleCurrentTimeServiceUUID = [CBUUID UUIDWithString:BLE_CURRENT_TIME_SERVICE_ID];
        _bleCurrentTimeCharacteristicUUID = [CBUUID UUIDWithString:BLE_CURRENT_TIME_ID];
        _bleExactTime256CharacteristicUUID = [CBUUID UUIDWithString:BLE_EXACT_TIME_256_ID];
        
        _bleCTService = nil;
        _bleCharCurrentTime = nil;
        
        _bleCharDateTime = nil;

        // Glucose Meter
        _bleBgmServiceID = [CBUUID UUIDWithString:BLE_GLUCOSE_SERVICE_ID];
        _bleBgmCharacteristic_RecordAccessControlPointID = [CBUUID UUIDWithString:BLE_RECORD_ACCESS_CONTROL_POINT_ID];
        _bleBgmCharacteristic_FeatureID = [CBUUID UUIDWithString:H2_FEATURE_ID];
        _bleBgmCharacteristic_MeasurementID = [CBUUID UUIDWithString:H2_MEASUREMENT_ID];
        _h2BgmCharacteristic_ContextID = [CBUUID UUIDWithString:H2_MEASUREMENT_CONTEXT_ID];
        
        // BLE Weight Scale
        _bleBwsServiceID = [CBUUID UUIDWithString:BLE_WEIGHT_SCALE_SERVICE_ID];
        
        _bleBwsCharacteristic_MeasurementID = [CBUUID UUIDWithString:BLE_WEIGHT_MEASUREMENT_ID];
        _bleBwsCharacteristic_FeatureID = [CBUUID UUIDWithString:BLE_WEIGHT_SCALE_FEATURE_ID];
        
        _bleBws_Service = nil;
        
        _bleBws_CHAR_Measurement = nil;
        _bleBws_CHAR_Feature = nil;
        
        _h2_BleBgm_Service = nil;
        
        // BLE BGM Characteristic
        _h2_BleBgm_CHAR_Measurement = nil;
        _h2_BleBgm_CHAR_Feature = nil;
        _h2_BleBgm_CHAR_RecordAccessControlPoint = nil;
        _h2_BleBgm_CHAR_MeasurementContext = nil;
        
        _bleCharSerialNumber = nil;
        
        _currentTimeReady = NO;
        _serialNumberReady = NO;
        
#ifdef DEBUG_LIB
        DLog(@"BLE SERVICE INIT");
#endif

    }
    return self;
}


+ (H2BleProfile *)sharedBleProfileInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred = 0;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


@end


