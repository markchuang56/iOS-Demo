//
//  AndUA651BLE.h
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/9/16.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#define UA651BLE_SERVICE_UUID                       @"233BF000-5A34-1B6D-975C-000D5690ABE4"
#define UA651BLE_CHARACTERISTIC_UUID                @"233BF001-5A34-1B6D-975C-000D5690ABE4"

#import <Foundation/Foundation.h>

@interface AndUA651BLE : NSObject

@property (nonatomic, strong) CBUUID *UA651_Service_UUID;
@property (nonatomic, strong) CBUUID *UA651_Characteristic_UUID;

@property (nonatomic, strong) CBService *AndUa651_Service;
@property (nonatomic, strong) CBCharacteristic *AndUa651_Characteristic;

- (void)writeBleDateTime;

- (void)bwsNormalRecordParser:(CBCharacteristic *)characteristic;
+ (AndUA651BLE *)sharedInstance;

@end

// [AndUA651BLE sharedInstance].UA651_Service_UUID

// value = <1467003f 004d0040 000000>, notifying = YES>
// 103, 63, 64

// 11 <1465003d 004b003f 000000>, 101, 61, 63

// 11 <14650041 0051003e 000400>, 101, 65, 62

/* */
// UUID = 2A35, properties = 0x20, value = (null), notifying = NO>
// UUID = 2A49, properties = 0x2, value = (null), notifying = NO>
// UUID = 2A08, properties = 0xA, value = (null), notifying = NO>

/* */
// UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO> UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>

// UUID = Serial Number String, properties = 0x2, value = (null), notifying = NO>

// UUID = Hardware Revision String, properties = 0x2, value = (null), notifying = NO>
// UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO>
// UUID = Software Revision String, properties = 0x2, value = (null), notifying = NO>
// UUID = System ID, properties = 0x2, value = (null), notifying = NO>

// UUID = IEEE Regulatory Certification, properties = 0x2, value = (null), notifying

/* */
// UUID = Battery Level, properties = 0x2

/* */
// UUID = 233BF001-5A34-1B6D-975C-000D5690ABE4, properties = 0xA




