//
//  H2Records.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/11.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#define RECORD_TYPE_BG              0x0001
#define RECORD_TYPE_BP              0x0002
#define RECORD_TYPE_BW              0x0004
#define RECORD_TYPE_SAO2            0x0008

#define RECORD_TYPE_CHOLES          0x0010
#define RECORD_TYPE_UA              0x0020

/*
#define USER_ID1_YES            0x01
#define USER_ID2_YES            0x02
#define USER_ID3_YES            0x04
#define USER_ID4_YES            0x08
#define USER_ID5_YES            0x10



#define CURRENT_0               0
#define CURRENT_1               1
#define CURRENT_2               2
#define CURRENT_3               3
#define CURRENT_4               4
*/

#define USER_TAG1_MASK            0x01
#define USER_TAG2_MASK            0x02
#define USER_TAG3_MASK            0x04
#define USER_TAG4_MASK            0x08
#define USER_TAG5_MASK            0x10



#define NX_TAG_1               0
#define NX_TAG_2               1
#define NX_TAG_3               2
#define NX_TAG_4               3
#define NX_TAG_5               4


#define BG_UNIT                 @"mg/dL"
#define BG_UNIT_EX              @"mmol/L"

#define BP_UNIT                 @"mmHg"
#define BP_UNIT_KPA              @"kPa"

#define BW_UNIT                 @"Kg"
#define BW_UNIT_LB              @"lb"


#define DYNAMIC_AUDIO                                       0
#define DYNAMIC_DONGLE                                  1
#define DYNAMIC_BLE_METER                               2


@class H2BgRecord;
@class H2BpRecord;
@class H2BwRecord;


#import <Foundation/Foundation.h>

@interface H2Records : NSObject

@property (readwrite) UInt8 dataTypeFilter;
@property (readwrite) UInt8 equipUserIdFilter;

@property (readwrite) UInt16 recordBgIndex;
@property (readwrite) UInt16 recordBpIndex;

@property (readwrite) BOOL multiUsers;

@property (readwrite) UInt8 currentDataType;
@property (readwrite) UInt8 currentUser;

@property (readwrite) BOOL bgSkipRecords;
@property (readwrite) BOOL bgCableSyncFinished;

// 1 : BG data
// 2 : BP data
// 4 : BW data
// ...
@property (nonatomic, strong) NSMutableArray *bgUser1RecordsArray;// = [[NSMutableArray alloc] init];
@property (nonatomic, strong) NSMutableArray *bgUser2RecordsArray;
@property (nonatomic, strong) NSMutableArray *bgUser3RecordsArray;
@property (nonatomic, strong) NSMutableArray *bgUser4RecordsArray;
@property (nonatomic, strong) NSMutableArray *bgUser5RecordsArray;

@property (nonatomic, strong) NSMutableArray *bpUser1RecordsArray;
@property (nonatomic, strong) NSMutableArray *bpUser2RecordsArray;
@property (nonatomic, strong) NSMutableArray *bpUser3RecordsArray;
@property (nonatomic, strong) NSMutableArray *bpUser4RecordsArray;
@property (nonatomic, strong) NSMutableArray *bpUser5RecordsArray;

@property (nonatomic, strong) NSMutableArray *bwUser1RecordsArray;
@property (nonatomic, strong) NSMutableArray *bwUser2RecordsArray;
@property (nonatomic, strong) NSMutableArray *bwUser3RecordsArray;
@property (nonatomic, strong) NSMutableArray *bwUser4RecordsArray;
@property (nonatomic, strong) NSMutableArray *bwUser5RecordsArray;

@property (nonatomic, strong) NSMutableArray *bgRecordsArray;
@property (nonatomic, strong) NSMutableArray *bpRecordsArray;
@property (nonatomic, strong) NSMutableArray *bwRecordsArray;

@property (nonatomic, strong) NSMutableArray *H2RecordsArray;


@property (nonatomic, strong) H2BgRecord *bgTmpRecord;
@property (nonatomic, strong) H2BpRecord *bpTmpRecord;
@property (nonatomic, strong) H2BwRecord *bwTmpRecord;


@property (nonatomic, strong) NSMutableArray *multiRecords;

// LAST DATE TIME ARRAY
@property (nonatomic, strong) NSMutableArray *bgLastDateTimeArray;
@property (nonatomic, strong) NSMutableArray *bpLastDateTimeArray;
@property (nonatomic, strong) NSMutableArray *bwLastDateTimeArray;

@property (nonatomic, strong) NSMutableArray *totalLastDateTimeArray;


- (void)resetRecordsArray;
- (void)buildRecordsArray:(id)record;

+ (H2Records *)sharedInstance;

@end

@interface H2BgRecord : NSObject

@property (readwrite) UInt8 recordType;
@property (readwrite) UInt16 bgIndex;
@property (nonatomic, strong) NSString *bgDateTime;
@property (readwrite) UInt8 meterUserId;

// BGM
@property (readwrite) UInt16 bgValue_mg;
@property (readwrite) float bgValue_mmol;

@property (nonatomic, strong) NSString *bgValue;

@property (nonatomic, strong) NSString *bgUnit;
@property (readwrite) UInt16 bgComment;
//@property (nonatomic, unsafe_unretained) UniChar bgFlag;
@property (nonatomic, strong) NSString *bgMealFlag;
@property (readwrite) BOOL bgHasUnit;
@property (readwrite) BOOL bgParserSuccessful;

+ (H2BgRecord *)sharedInstance;

@end

@interface H2BpRecord : NSObject

@property (readwrite) UInt8 recordType;
@property (readwrite) UInt16 bpIndex;
@property (nonatomic, strong) NSString *bpDateTime;
@property (readwrite) UInt8 meterUserId;

// Blood Pressure, kPa or mmHg
@property (nonatomic, strong) NSString *bpUnit;
//@property (nonatomic, unsafe_unretained) UniChar bpFlag;

// BP
@property (readwrite) BOOL recordIsBp;
// Record's data type, BG or BP in Fora D40

// 1毫米汞柱=0.133千帕，也就是7.5毫米汞柱=1千帕。
// 换算口诀：
// 千帕换算成毫米汞柱，原数乘30除以4；
// 毫米汞柱换算成千帕，原数乘4除以30。

// Blood Pressure
@property (nonatomic, strong) NSString *bpSystolic;
@property (nonatomic, strong) NSString *bpDiastolic;

// Heart Rate
@property (nonatomic, strong) NSString *bpHeartRate_pulmin;

// Heart Beats
@property (readwrite) BOOL bpIsArrhythmia;
@property (readwrite) BOOL mamArrhythmia;

//@property (nonatomic, unsafe_unretained) NSString *bpIhbValue;
@property (readwrite) UInt8 bpIhbValue;
/*
 IHB=0 : Normal Heart Beats
 IHB=1 : Tachycardia(>110) or Bradycardia(<50)
 IHB=2 : Varied Heart Rate ( ±20%)
 IHB=3 : Atrail Fibrillation (AF)
 */

+ (H2BpRecord *)sharedInstance;

@end

@interface H2BwRecord : NSObject

@property (readwrite) UInt8 recordType;
@property (readwrite) UInt16 bwIndex;
@property (nonatomic, strong) NSString *bwDateTime;

@property (readwrite) UInt8 meterUserId;

// Kg or Lb
@property (nonatomic, strong) NSString *bwUnit;
//@property (nonatomic, unsafe_unretained) UInt8 bwDataWithUserId;
// In Fora W310, Records with the User ID field,.


@property (nonatomic, strong) NSString *bwGender;
//Gender. Female = 0, Male =1

@property (nonatomic, strong) NSString *bwHeightCm;
@property (nonatomic, strong) NSString *bwHeightInch;

@property (readwrite) UInt8 bwAge;


//@property (nonatomic, unsafe_unretained) UInt8 bwUnit;
// Kg=0, lb=1, st=2


@property (nonatomic, strong) NSString *bwWeight;
@property (nonatomic, strong) NSString *bwBmi;

@property (nonatomic, strong) NSString *bwFat;
@property (nonatomic, strong) NSString *bwSkeletalMuscle;
@property (nonatomic, strong) NSString *bwRestingMetabolism;

@property (nonatomic, strong) NSString *bwLevel;

+ (H2BwRecord *)sharedInstance;

@end


@interface BatDynamicInfo : NSObject

@property (readwrite) UInt8 devType;// audio cable, ble cable, ble dev

@property (readwrite) UInt16 batteryLevel;
@property (readwrite) UInt16 batteryRawData;

@property (nonatomic, strong) NSString *cableVersion;

@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *model;

@property (nonatomic, strong) NSString *bleIdentifier;
@property (nonatomic, strong) NSString *bleLocalName;

@end

@interface RecordsSkipped : NSObject

@property(readwrite) UInt16 bgSkip;
@property(readwrite) UInt16 bpSkip;
@property(readwrite) UInt16 bwSkip;

@end
