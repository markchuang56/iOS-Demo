//
//  H2BleHmd.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/10/28.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

/*
// Customer
#define H2_HMD_SERVICE_ID                           0xCF70




#define H2_HMD_CHAR_1_RW                        0xCF71  //, properties = 0xA,       READ AND WRITE
#define H2_HMD_CHAR_2_READ                      0xCF72  //, properties = 0x2        READ ONLY
#define H2_HMD_CHAR_3_WRITE                     0xCF73  //, properties = 0x8        WRITE ONLY
#define H2_HMD_CHAR_4_NOTIFY                    0xCF74  //, properties = 0x10       NOTIFICATION
#define H2_HMD_CHAR_5_READ                      0xCF75  //, properties = 0x2        READ ONLY
*/



#import <Foundation/Foundation.h>

@interface H2BleHmd : NSObject


@property (readwrite) UInt8 hmdBleCharSel;

@property (readwrite) UInt8 hmdRecordIndex;
@property (readwrite) UInt16 hmdTmpIndex;


// HMD Service
@property (nonatomic, strong) CBService *h2_HMD_Service;

// HMD Characteristic
@property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR_Measurement;
@property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR_Feature;
@property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR_RecordAccessControlPoint;


+ (H2BleHmd *)sharedInstance;



//- (void)H2HmdBLEWriteTask:(unsigned char *)hmdCmdData withLength:(UInt8)length;

@end

//[H2BleHmd sharedInstance] h2HmdDeSubscribeTask





/*
 // Customer
 @property (nonatomic, strong) CBUUID *h2ServiceHmdUUID;
 @property (strong, readwrite) CBUUID *h2HMDCharacteristic_1_ReadWriteUUID;
 @property (strong, readwrite) CBUUID *h2HMDCharacteristic_2_ReadUUID;
 @property (strong, readwrite) CBUUID *h2HMDCharacteristic_3_WriteUUID;
 @property (strong, readwrite) CBUUID *h2HMDCharacteristic_4_NotifyUUID;
 @property (strong, readwrite) CBUUID *h2HMDCharacteristic_5_ReadUUID;
 
 // HMD Service
 @property (nonatomic, strong) CBService *h2_HMD_Service;
 
 // HMD Characteristic
 @property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR1_ReadWrite;
 @property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR2_Read;
 @property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR3_Write;
 @property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR4_Notify;
 @property (nonatomic, strong) CBCharacteristic *h2_HMD_CHAR5_Read;
 */
