//
//  MicroLife.h
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/8/17.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#define ML_CLR_ALL              0
#define ML_SN_INTERVAL          3.0f
#define ML_CMD_HEADER           'M'
#define ML_CMD_DEV              0xFF

#define ML_CMD_READ_ALL         0
#define ML_CMD_CLR_ALL          3
#define ML_CMD_CANCEL_BLE       4
#define ML_CMD_READ_UID         5
#define ML_CMD_WRITE_UID        6
#define ML_CMD_READ_LAST        7

#define ML_LOC_HEADER           0
#define ML_LOC_DEV              1
#define ML_LOC_IDX              2
#define ML_LOC_OP               4
#define ML_LOC_DATA_STRING      5

#define ML_UID_LEN              11
#define ML_RECORD_LEN           7

#define ML_RECORDS_MAX          100
/*
UUID = Device Information>",
"<CBService: 0x14ef1b60, isPrimary = YES, UUID = 1803>",
"<CBService: 0x14ef1bf0, isPrimary = YES, UUID = 1802>",
"<CBService: 0x14ef1c30, isPrimary = YES, UUID = 1804>",
"<CBService: 0x14ef1c70, isPrimary = YES, UUID = Battery>",
"<CBService: 0x14ee72e0, isPrimary = YES, UUID = Heart Rate>",
"<CBService: 0x14ee7350, isPrimary = YES, UUID = FFF3>",
"<CBService: 0x14ee7070, isPrimary = YES, UUID = FFF0>"
*/

// SN <81000020 150629>

#define ML_LINKLOSS_SERVICE_UUID                    @"1803" // Link Loss
#define ML_IMMEDALERT_SERVICE_UUID                  @"1802" // Immediate Alert
#define ML_TXPWR_SERVICE_UUID                       @"1804" // Tx Power
#define ML_3_SERVICE_UUID                           @"FFF3"
#define ML_0_SERVICE_UUID                           @"FFF0"

#define ML_ALERTLEVEL_CHAR_UUID                     @"2A06"     // 0A Alert Level
//#define ML_2_CHAR_UUID                  @"2A06"     // 04
#define ML_TXPWR_CHAR_UUID                          @"2A07"     // 12 Tx Power Level

#define ML_HR_CHAR0_UUID                    @"2A37"   // 10 HR Measurement
#define ML_HR_CHAR1_UUID                    @"2A38"   // 02 Body Sensor Location

#define ML_3_CHAR4_UUID                     @"FFF4"    // 10
#define ML_3_CHAR5_UUID                     @"FFF5"    // 0C
#define ML_0_CHAR1_UUID                     @"FFF1"    // 10
#define ML_0_CHAR2_UUID                     @"FFF2"    // 0C



#import <Foundation/Foundation.h>

@interface MicroLife : NSObject

// UUID
@property (nonatomic, strong) CBUUID *mlF3ServiceID;
@property (nonatomic, strong) CBUUID *mlF0ServiceID;

@property (nonatomic, strong) CBUUID *mlF4CharacteristicID;
@property (nonatomic, strong) CBUUID *mlF5CharacteristicID;
@property (nonatomic, strong) CBUUID *mlF1CharacteristicID;
@property (nonatomic, strong) CBUUID *mlF2CharacteristicID;


// Micro Life A6 BT Service
@property (nonatomic, strong) CBService *mlF3Service;
@property (nonatomic, strong) CBService *mlF0Service;

// Micro Life A6 BT Characteristic
@property (nonatomic, strong) CBCharacteristic *mlF4Characteristic; // 10
@property (nonatomic, strong) CBCharacteristic *mlF5Characteristic; // 0C
@property (nonatomic, strong) CBCharacteristic *mlF1Characteristic; // 10
@property (nonatomic, strong) CBCharacteristic *mlF2Characteristic; // 0C


- (void)microLifeValueUpdate:(CBCharacteristic *)characteristic;

- (void)mlCmdInit;
- (void)mlCmdSync;
- (void)mlCmdFlow;


+ (MicroLife *)sharedInstance;

@end
