//
//  Gm700sb.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/10/20.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#define SB_FLOW0_INIT                   0x30
#define SB_FLOW1_PAIR                   0x31
#define SB_FLOW2_BF2                    0x32
#define SB_FLOW3_BF3                    0x33
#define SB_FLOW4_BF4                    0x34

//#define SB_PAIR_KEY0                    0xBE
//#define SB_PAIR_KEY1                    0x9A


#define SB_PAIR_OFFSET                  0//10

//#define SB_PAIR_KEY_BEGIN              0x7000
#define SB_PAIR_KEY_BEGIN              0x9FB3
//#define SB_PAIR_KEY_BEGIN              0x9ABE

#define SB_READ_MODE_INTERVAL                    0.05f
#define SB_FLOW_INIT_INTERVAL                    0.5f//0.3f//0.5f
#define SB_FLOW_PAIR_INTERVAL                    1.2f//0.3f//1.2f

#define SB_FLOW_PAIR_LOOP                   0.5f


#define BIONIME_HOC                 0xB0

#define BIONIME_CID_MODEL           0x00
#define BIONIME_CID_FWVER           0x01
#define BIONIME_CID_ENMEM           0x02
//#define BIONIME_CIE_TIMER           0x06
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
#define DATA_LEN_ENMEM                      0
#define DATA_LEN_DT_UNIT                    6
#define DATA_LEN_SN                         11
#define DATA_LEN_RECORD                     6

#define DA_ST           2

#define DA_0             4
#define DA_1             5
#define DA_2             6
#define DA_3             7
#define DA_4             8
#define DA_5             9
#define DA_6             10
#define DA_7             11

#define READ_A1             1
#define READ_A2             2

#pragma mark - BIONIME GM700SB UUID

#define BLE_BIONIME_SERVICE_ID                              @"FEE0"
//#define BLE_BIONIME_SERVICE_ID                              @"FEE9"

#define BLE_BIONIME_READ_WRITE_ID                           @"FEE1" // 0x0E, 0000 1110
#define BLE_BIONIME_NOTIFY_ID                               @"FEE2" // 0x12, 0001 0010
#define BLE_BIONIME_WRITE_ID                                @"FEE3" // 0x08, 0000 1000




#import <Foundation/Foundation.h>

@interface Gm700sb : NSObject

#pragma mark - BIONIME GM700SB Object
// UUID
@property (nonatomic, strong) CBUUID *bioNimeServiceID;

@property (nonatomic, strong) CBUUID *bioNimeCharacteristicReadWriteID;
@property (nonatomic, strong) CBUUID *bioNimeCharacteristicNotifyID;
@property (nonatomic, strong) CBUUID *bioNimeCharacteristicWriteID;


// BioNeme GM700SB Service
@property (nonatomic, strong) CBService *bioNimeService;

// BioNeme GM700SB Characteristic
// Set PCL Mode
@property (nonatomic, strong) CBCharacteristic *bioNimeCharacteristicReadWrite;
@property (nonatomic, strong) CBCharacteristic *bioNimeCharacteristicNotify;
@property (nonatomic, strong) CBCharacteristic *bioNimeCharacteristicWrite;

@property (nonatomic, strong) NSString *sbSn;

@property (readwrite) BOOL mmolFlag;
@property (readwrite) BOOL timerWriting;
@property (readwrite) BOOL bionimeCommand;

@property (readwrite) UInt16 userKey;
@property (readwrite) UInt8 rawForKey0;
@property (readwrite) UInt8 rawForKey1;

@property (readwrite) UInt16 recordIndex;
@property (readwrite) UInt8 cmdRId;
@property (readwrite) UInt8 reportLength;

@property (readwrite) UInt8 currentCmdSel;

@property (readwrite) UInt8 readingSel;

@property (readwrite) UInt8 sbYear;
@property (readwrite) UInt8 sbMonth;
@property (readwrite) UInt8 sbDay;
@property (readwrite) UInt8 sbHour;
@property (readwrite) UInt8 sbMinute;


#pragma mark - GM700SB Parser
- (void)bioNimeGb700sbDataProcess:(CBCharacteristic *)characteristic;

#pragma mark - GM700SB Command
- (void)bioNimeGb700sbA1ModeChange;
- (void)bioNimeGb700sbCmmand;

/*
- (void)queryModelName;
- (void)queryFirmwareVersion;
//- (void)enableAccessingMemory;
//Get/Set
- (void)getDateTimeAndUnit;
- (void)setDateTimeAndUnit;
- (void)querySerialNumber;
- (void)readOneRecord;
- (void)readEightRecord;
*/


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



