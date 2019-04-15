//
//  H2BleOad.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/11/30.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

/*
#define OAD_FINISHED                    0x0A
#define OAD_UPDATED                     0x1A
#define OAD_FILE_ERR                    0x87
#define OAD_INTERRUPT                   0x8A
#define OAD_VENDOR_MODE                 0x81
#define OAD_CABLE_NOT_SUPPORT           0x85
*/

#define OAD_HEADER_LEN                  16
#define OAD_BLOCK_LEN                   16
#define OAD_LEN                         18

#define OAD_BUFFER_SIZE             0x4FFFF

// OAD
#define H2_OAD_IMG_SERVICE_UUID                         @"AE61FFC0-3266-4BBA-9626-06CBE7657213"

#define H2_OAD_IMG_ID_CHARACTERISTIC_UUID               @"AE61FFC1-3266-4BBA-9626-06CBE7657213"
#define H2_OAD_IMG_BLOCK_CHARACTERISTIC_UUID            @"AE61FFC2-3266-4BBA-9626-06CBE7657213"

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@interface H2BleOad : NSObject

// OAD

@property (nonatomic, strong)CBUUID *h2ServiceOADImgUUID;

@property (nonatomic, strong)CBUUID *h2CharacteristicOADImgIdentifyUUID;
@property (nonatomic, strong)CBUUID *h2CharacteristicOADImgBlockUUID;

@property(readwrite) UInt16 blkNum;
@property(readwrite) UInt16 crc;
@property(readwrite) UInt16 crcShadow;
@property(readwrite) UInt16 ver;
@property(readwrite) UInt16 lenBlock;

@property(readwrite) Byte *header;
//@property(readwrite) Byte *buffer;
@property(readwrite) Byte *imgBuffer;

@property(readwrite) BOOL oadMode;
@property(readwrite) BOOL didOadWriteFinished;

// OAD Service
@property (nonatomic, strong) CBService *h2_ServiceOAD;


// OAD Identify and Flash Block Caracteristic
@property (nonatomic, strong) CBCharacteristic *h2_CharacteristicIdentify;
@property (nonatomic, strong) CBCharacteristic *h2_CharacteristicBlock;


// [H2BleOad sharedInstance] H2OADWriteBlock

- (void)H2OADWriteIdentify;
- (void)H2OADWriteBlock;

+ (H2BleOad *)sharedInstance;




// [H2BleOad sharedInstance].didOadFinished

@end

