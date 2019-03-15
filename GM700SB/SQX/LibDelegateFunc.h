//
//  LibDelegateFunc.h
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#import <Foundation/Foundation.h>

//#import "h2MeterRecordInfo.h"
#import "H2Sync.h"
#import "H2AudioHelper.h"
#import "H2Records.h"
#import "AppDebug.h"
//#import "ScannedPeripheral.h"

#define STATUS_INTERVAL                 0.05f

#define  BLE_TEST_LOOP_TARGET           10000
#define  BLE_TEST_LOOP_INTERVAL         8.0f

#define LONG_RUN_CYCLE                  0//1000

#define BLE_CYCLE_INTERVAL              10.0f

//#define AUTO_SYNC

#define ROCHE_AVIVA_CONNECT_SEL                         0
#define FORA_GD40B_SEL                                  1
#define FORA_TAIDOC_SEL                                 2
#define FORA_D40_SEL_70D                                3
//#define FORA_D40_SEL_673                                4
#define FORA_P30_PLUS                                4
#define FORA_W30B_SEL                                   5

#define BTM_SEL                                         6
#define TRUE_METRIX                                     7
#define ONETOUCH                                        8


#define OMRON_HEM_7280T         9
#define OMRON_HBF_254C          10

#define ARKRAY_GT_1830          11

#define OMRON_HEM_9200T         12
#define OMRON_HEM_6320T         13


#define TYSON_HT100                                     14

#define CONTOUR_NEXT_ONE                                15

//#define BLE_CABLE_SEL                                     16
#define AVIVA_GUIDE_SEL                                     16

#define OMRON_HEM_6324T                                     17
#define OMRON_HEM_7600T                                     18
#define OMRON_HBF_256T                                     19

#define MI_SCALE_SEL                                         20
#define MI_BAND2_SEL                                         21

#define SM_BLE_CONTOUR_PLUS_ONE_SEL                          22

#define ARKRAY_NEO_ALPHA                                    23

#define ACCU_CHEK_INSTANT_SEL                               24
#define BIONIME_GM700SB_SEL                                 25

#define FORA_TNG_SEL                                         26
#define FORA_TNG_VOICE_SEL                                         27


#define GARMIN_SEL                                         28

#define MICRO_LIFE_SEL                                      29
#define AND_UA651_SEL                                       30
#define AND_UC352_SEL                                       31

#define HMD_SEL                                         32
#define H2_SPACE                                         33



@class H2MeterSystemInfo;
@class UserGlobalProfile;
@class RecordsSkipped;

@interface LibDelegateFunc : NSObject <H2SyncDelegate>

@property(nonatomic, strong) NSString *cableSerialnumber;

@property(nonatomic, strong) NSString *stbTitle;

@property(nonatomic, strong) NSMutableArray *bgRecordsResult;
@property(nonatomic, strong) NSMutableArray *bpRecordsResult;
@property(nonatomic, strong) NSMutableArray *bwRecordsResult;

@property(nonatomic, strong) NSMutableArray *ldtNewResult;



@property(nonatomic, strong) NSMutableArray *haveFoundBlePeripherals;

@property(nonatomic, strong) NSMutableArray *omronRecordsUserA;
@property(nonatomic, strong) NSMutableArray *omronRecordsUserB;
@property(nonatomic, strong) NSMutableArray *omronRecordsUserC;
@property(nonatomic, strong) NSMutableArray *omronRecordsUserD;
@property(nonatomic, strong) NSMutableArray *omronRecordsUserE;


@property(nonatomic, strong) NSMutableArray *sdkDefaultBleDevices;

@property(nonatomic, strong) UserGlobalProfile *userProfile;

@property(readwrite) UInt8 indexStatus;

//@property(nonatomic, strong) NSString *syncStatusString;
@property(nonatomic, strong) NSString *syncStatusStringEx;

@property(nonatomic, strong) NSString *singleRecordValue;
@property(nonatomic, strong) NSString *singleRecordDateTime;

@property(nonatomic, strong) NSString *batteryLevelString;
@property(nonatomic, strong) NSString *bleIdentifierString;

@property(nonatomic, strong) NSString *equipIdString;


@property(nonatomic, strong) H2MeterSystemInfo *bgmInfo;

@property(readwrite) Byte *byteStatus;


@property(readwrite) BOOL demoSyncRunning;
@property(readwrite) BOOL demoAutoSync;
@property(readwrite) BOOL meterTaskAutoSync;
@property(readwrite) BOOL stbSync;

@property(nonatomic, strong) NSString *qrStringCode;

//@property(nonatomic, strong) NSString *recordIndex;
@property(nonatomic, strong) NSString *bgIndexString;
@property(nonatomic, strong) NSString *bpIndexString;
@property(nonatomic, strong) NSString *bwIndexString;

@property(nonatomic, strong) NSString *recordSingle;
@property(nonatomic, strong) NSString *loopIndex;

@property(nonatomic, strong) NSMutableArray *syncMsg;

@property (nonatomic, strong) NSMutableArray *serverLastDateTimes;

@property (nonatomic, strong) NSMutableArray *tmswToolCableListing;

@property (nonatomic, strong) NSString *middleDateTime;


@property (nonatomic, strong) NSString *longRunBatterLevel;
@property (nonatomic, strong) NSString *longRunRSSIValue;
@property (nonatomic, strong) NSString *longRunCurrentTime;
@property (nonatomic, strong) NSString *longRunRecordIndex;

@property(nonatomic, strong) NSString *userID;
@property(nonatomic, strong) NSString *userEMail;

@property(readwrite) UInt16 h2BleTestLoop;
@property(readwrite) UInt16 h2RecordsDataType;

@property(readwrite) UInt16 h2LongRunCycle;
@property(readwrite) UInt16 bionimeCount;

@property(readwrite) UInt8 omronUserIdFromEquipment;
@property(readwrite) UInt16 h2OmronDataType;

@property(nonatomic, strong) RecordsSkipped *skipNumbers;

@property(nonatomic, strong) H2PackageForSync *packageForSyncTmp;

- (void)demoDefaultLDT;
- (void)demoGlobalSync;

+ (LibDelegateFunc *)sharedInstance; // packageForSyncTmp


@end


