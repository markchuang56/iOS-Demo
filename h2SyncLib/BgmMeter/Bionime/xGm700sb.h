//
//  Gm700sb.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/10/20.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


#define BIONIME_HOC                 0xB0
#define BIONIME_CID_MODEL           0x00
#define BIONIME_CID_FWVER           0x01
#define BIONIME_CID_ENMEM           0x02
//#define BIONIME_CID         0x03
//#define BIONIME_CID         0x04
//#define BIONIME_CID         0x05
#define BIONIME_CID_GS_DATE_TIME_UNIT           0x06

#define BIONIME_CID_SN                          0x18
#define BIONIME_CID_RECORD          0x07

#define CMD_LEN_MODEL                   2
#define CMD_LEN_FWVER                   2
#define CMD_LEN_ENMEM                   5
#define CMD_LEN_DT_UNIT                 8
#define CMD_LEN_SN                      2
#define CMD_LEN_RECORD                  4


#define SET_DT                          0x01

#define DATA_LEN_MODEL                      5
#define DATA_LEN_FWVER                      4
#define ENMEM_LEN_ENMEM                     0
#define DATA_LEN_DT_UNIT                    6
//#define CMD_LEN_SN                      2
#define DATA_LEN_RECORD                     6

#define DA_0             4
#define DA_1             5
#define DA_2             6
#define DA_3             7
#define DA_4             8
#define DA_5             9

#pragma mark - BIONIME GM700SB UUID

#define BLE_BIONIME_SERVICE_ID                              @"FFF0"

#define BLE_BIONIME_READ_WRITE_ID                           @"FFF1" // 0x28, 0010 1000
#define BLE_BIONIME_NOTIFY_ID                               @"FFF2" // 0x28, 0010 1000
#define BLE_BIONIME_WRITE_ID                                @"FFF3" // 0x28, 0010 1000




#import <Foundation/Foundation.h>

@interface Gm700sb : NSObject

#pragma mark - BIONIME GM700SB Object
// UUID
@property (strong, nonatomic) CBUUID *bioNimeServiceID;

@property (strong, nonatomic) CBUUID *bioNimeCharacteristicReadWriteID;
@property (strong, nonatomic) CBUUID *bioNimeCharacteristicNotifyID;
@property (strong, nonatomic) CBUUID *bioNimeCharacteristicWriteID;


// BioNeme GM700SB Service
@property (strong, nonatomic) CBService *bioNimeService;

// BioNeme GM700SB Characteristic
// Set PCL Mode
@property (strong, nonatomic) CBCharacteristic *bioNimeCharacteristicReadWrite;
@property (strong, nonatomic) CBCharacteristic *bioNimeCharacteristicNotify;
@property (strong, nonatomic) CBCharacteristic *bioNimeCharacteristicWrite;

@property (readwrite) BOOL mmolFlag;

@property (readwrite) UInt16 recordIndex;
@property (readwrite) UInt8 cmdRId;
@property (readwrite) UInt8 reportLength;

@property (readwrite) UInt8 currentCmdSel;


#pragma mark - GM700SB Parser
- (void)bioNimeGb700sbDataProcess;

#pragma mark - GM700SB Command
- (void)bioNimeGb700sbCmmand;


- (void)queryModelName;
- (void)queryFirmwareVersion;
- (void)enableAccessingMemory;
//Get/Set
- (void)getDateTimeAndUnit;
- (void)setDateTimeAndUnit;
- (void)querySerialNumber;
- (void)readOneRecord;
- (void)readEightRecord;



+ (Gm700sb *)sharedInstance;



@end

/*
 
 bioNimeService;
 bioNimeCharacteristicReadWrite
 bioNimeCharacteristicNotify
 bioNimeCharacteristicWrite
 
 [Gm700sb sharedInstance].bioNimeServiceID
 
 [Gm700sb sharedInstance].bioNimeCharacteristicReadWriteID
 [Gm700sb sharedInstance].bioNimeCharacteristicNotifyID
 [Gm700sb sharedInstance].bioNimeCharacteristicWriteID

 */



