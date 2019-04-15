//
//  H2Omron.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/8/23.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


//#define MEM_MODE
#define HEM_INDEX_MASK      0x7F
#define HBF_INDEX_MASK      0x1F

#define OM_LOG_LEN          40
#define OM_COMMAND_LOG      0
#define OM_VALUE_LOG        1

@class H2BpRecord;
@class UserGlobalProfile;

#import "H2DebugHeader.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
@interface H2Omron : NSObject
{
    
}

@property (nonatomic, strong) CBUUID *OMRON_Service_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A0_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A1_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A2_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A3_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A4_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A5_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A6_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A7_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A8_UUID;
@property (nonatomic, strong) CBUUID *OMRON_Characteristic_A9_UUID;




// OMRON_HEM_7280T Service

@property (nonatomic, strong) CBService *Omron_Service;


// OMRON_HEM_7280T Caracteristic
@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A0;

@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A1;
@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A2;
@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A3;
@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A4;

@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A5;
@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A6;
@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A7;
@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A8;

@property (nonatomic, strong) CBCharacteristic *Omron_Characteristic_A9;

@property (readwrite) UInt8 cmdLength;
@property (readwrite) Byte *omronHemCmd;

@property (readwrite) float cmdTimeOutInterval;
@property (readwrite) Byte *omronIndexArray;


@property (readwrite) UInt8 recordTypeFilter;
@property (readwrite) UInt8 userIdFilter;

@property (nonatomic, strong)NSData *omronDataToWrite;

@property (readwrite) UInt8 omronCmdSel;

@property (readwrite) BOOL dialogWillAppear;
@property (readwrite) BOOL setUserIdMode;
@property (readwrite) BOOL omronFinished;
@property (readwrite) BOOL omronModeFlag;

@property (readwrite) BOOL omronInputStage;
@property (readwrite) BOOL omronMultiUserTag;

@property (readwrite) BOOL omronFail;
@property (readwrite) BOOL a0NotifyYES;
@property (readwrite) BOOL isHem7600TOrHbf;

@property (readwrite) UInt8 omronDataLength;
@property (readwrite) Byte *omronA0Buffer;

@property (nonatomic, strong) NSMutableData *omronDataBuffer;

@property (readwrite) UniChar bpFlag;
@property (readwrite) UniChar bwFlag;
// PARSER FLAG
@property (readwrite) BOOL parserFinished;
@property (readwrite) BOOL parserHardwareInfo;
@property (readwrite) BOOL parserCurrentTime;
@property (readwrite) BOOL parserUserProfile;

@property (readwrite) BOOL parserOrCollectRecord;
@property (readwrite) BOOL normalCmdFlow;

@property (readwrite) BOOL parserSetCurrentTime;
@property (readwrite) BOOL parserSetTagProfile;


@property (readwrite) BOOL parserClearIndex;

@property (readwrite) UInt8 userIdStatus;
@property (readwrite) UInt8 userSetId;

@property (readwrite) UInt16 reportIndex;

@property (nonatomic, strong) NSString *omronSerialNumber;

@property (nonatomic, strong) UserGlobalProfile* tmpUserProfile;

@property (readwrite)UInt16 indexTimeAddr;
@property (readwrite)UInt16 currentTimeDataLength;

@property (readwrite)UInt16 hemTagAddr;
@property (readwrite)UInt16 hemTimeAddr;

@property (readwrite)UInt16 hbfProfileAddr;

@property (readwrite)UInt16 tag1RecordsAddr;
@property (readwrite)UInt16 tag2RecordsAddr;
@property (readwrite)UInt16 tag3RecordsAddr;
@property (readwrite)UInt16 tag4RecordsAddr;

@property (readwrite) Byte *tmpIndexBuffer;


@property (readwrite) UInt16 qtsForTag_1;
@property (readwrite) UInt16 qtsForTag_2;
@property (readwrite) UInt16 qtsForTag_3;
@property (readwrite) UInt16 qtsForTag_4;

@property (readwrite) UInt16 addrForTag_1;
@property (readwrite) UInt16 addrForTag_2;
@property (readwrite) UInt16 addrForTag_3;
@property (readwrite) UInt16 addrForTag_4;

@property (nonatomic, strong) NSMutableArray *omronCmdLogArray;
@property (nonatomic, strong) NSMutableArray *omronValueLogArray;

/*
@property (readwrite) UInt16 qtsForTagOne;
@property (readwrite) UInt16 qtsForTagTwo;
@property (readwrite) UInt16 qtsForTagThree;
@property (readwrite) UInt16 qtsForTagFour;
*/

- (void)hem7600TNotify:(CBCharacteristic *)characteristic;
- (void)OmronStartFromA0;
- (void)h2OmronDataHandling:(CBCharacteristic *)characteristic;

- (UInt8)omronCmdFlowTimerTask;
- (BOOL)omronHemRecordCmdProcess;

- (void)omronHemBpGetRecord:(UInt16)index;
- (void)omronHbfBwGetRecord:(UInt16)index;

- (void)omronGetIndexCurrentTime;


- (void)omronWriteA1Task;
- (void)omronSencondCommand;

- (void)omronHemRecordsParser;
- (void)clearHemTagIndex:(UInt8)user;
- (void)clearHbfTagIndex:(UInt8)user;

- (void)omronIndexCmdProcess;
- (void)omronBufferInit;
- (void)omronHardwareInfoParser;
- (BOOL)omronCheckSerialNumber:(UInt8)uTag;

- (void)cmdDone;
- (void)addrQtyProcess:(UInt8)qty withIdx:(UInt8)addrIdx omronTypeHem:(BOOL)typeHem;
+ (H2Omron *)sharedInstance;

@end



