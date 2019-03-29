//
//  h2MeterRecord.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/11/1.
//
//

#import <Foundation/Foundation.h>

/*
 flag definitions
 N : no define
 C : Control Solution
 E : Error
 B : Before meal
 A : after meal
 R : remark // maybe
 
 app will receive N, B, A, R
 
 smRecordComment definitions
 0000		No Comment
 0001		Not Enough Food
 0002		Too Much Food
 0004		Mild Exercise
 0008		Hard Exercise
 0010		Medication
 0020		Stress
 0040		Illness
 0080		Feel Hypo
 0100		Menses
 0200		Vacation
 0400		Other
 0800
 1000
 2000
 4000
 8000
 */

// flag definitions
/*
#define FLAG_NO_DEFINE                      'N'
#define FLAG_CONTROL_SOLUTION               'C'
#define FLAG_ERROR                          'E'
#define FLAG_BEFOR_MEAL                     'B'
#define FLAG_AFTER_MEAL                     'A'
#define FLAG_REMARK                         'R'
#define FLAG_LOG                            'D'
#define FLAG_FAIL_OR_ERROR                  'F'
*/
#define FLAG_NO_DEFINE                      @"N"
#define FLAG_CONTROL_SOLUTION               @"C"
#define FLAG_ERROR                          @"E"
#define FLAG_BEFOR_MEAL                     @"B"
#define FLAG_AFTER_MEAL                     @"A"
#define FLAG_REMARK                         @"R"
#define FLAG_LOG                            @"D"
#define FLAG_FAIL_OR_ERROR                  @"F"

#define FLAG_MEAL_FASTING                   @"Fasting"
#define FLAG_MEAL_SNACKS                    @"Snacks"
#define FLAG_MEAL_BEDTIME                   @"Bedtime"

#define METER_UNIT_MG                       0
#define METER_UNIT_MMOL                     1

#define ULTRA2_MAX_DELAY_TIME                   50

#define SYNC_INFO_CABLE_STATUS_SIZE             256
#define SYNC_INFO_TEMP_BUFFER_SIZE              1024

#define SYNC_INFO_TEMP_GLOBAL_BUFFER_LIMIT      128



// smRecordComment definitions
#define CM_No_Comment                   0x0000		// No Comment
#define CM_Not_Enough_Food              0x0001		// Not Enough Food
#define CM_Too_Much_Food                0x0002		// Too Much Food
#define CM_Mild_Exercise                0x0004		// Mild Exercise
#define CM_Hard_Exercise                0x0008		// Hard Exercise
#define CM_Medication                   0x0010		// Medication
#define CM_Stress                       0x0020		// Stress
#define CM_Illness                      0x0040		// Illness
#define CM_Feel_Hypo                    0x0080		// Feel Hypo
#define CM_Menses                       0x0100		// Menses
#define CM_Vacation                     0x0200		// Vacation
#define CM_Other                        0x0400		// Other



@interface H2MeterSystemInfo : NSObject
{
}
@property (nonatomic, strong) NSString *smCurrentDateTime;
@property (nonatomic, strong) NSString *smCurrentUnit;
@property (nonatomic, strong) NSString *smBrandName;
@property (nonatomic, strong) NSString *smModelName;
@property (nonatomic, strong) NSString *smSerialNumber;
@property (nonatomic, strong) NSString *smVersion;
@property (readwrite) BOOL smWantToReadRecord;
@property (readwrite) UInt16 smNumberOfRecord;

@property (nonatomic, strong) NSString *bgLastDateTime;
@property (nonatomic, strong) NSString *bpLastDateTime;
@property (nonatomic, strong) NSString *bwLastDateTime;


@property (readwrite) BOOL smMmolUnitFlag;
@property (readwrite) BOOL IsOldMeter;
@property (readwrite) BOOL formatError;


+ (H2MeterSystemInfo *)sharedInstance;

@end


// [H2MeterSystemInfo sharedInstance]
@interface h2MeterModelSerialNumber : NSObject
{
}
@property (nonatomic, strong) NSString *smModel;
@property (nonatomic, strong) NSString *smSerialNumber;
@property (nonatomic, strong) NSString *smLastDateTime;

+ (h2MeterModelSerialNumber *)sharedInstance;
@end




@interface H2BrandAndModel : NSObject

@property (nonatomic, strong) NSArray *h2BrandList;
@property (nonatomic, strong) NSArray *h2DemoModel;
@property (nonatomic, strong) NSArray *h2AccuChekModel;
@property (nonatomic, strong) NSArray *h2BayerModel;
@property (nonatomic, strong) NSArray *h2CareSensModel;
@property (nonatomic, strong) NSArray *h2FreeStyleModel;
@property (nonatomic, strong) NSArray *h2GlucoCardModel;
@property (nonatomic, strong) NSArray *h2OneTouchModel;
@property (nonatomic, strong) NSArray *h2ReliOnModel;
@property (nonatomic, strong) NSArray *h2BeneChekModel;
@property (nonatomic, strong) NSArray *h2EXT_9_Model;
@property (nonatomic, strong) NSArray *h2EXT_A_Model;
@property (nonatomic, strong) NSArray *h2EXT_B_Model;
@property (nonatomic, strong) NSArray *h2EXT_C_Model;
@property (nonatomic, strong) NSArray *h2EXT_D_Model;
@property (nonatomic, strong) NSArray *h2EXT_E_Model;
@property (nonatomic, strong) NSArray *h2EXT_F_Model;
@property (nonatomic, strong) NSArray *h2EXT_10_Model;


// EXTEND MODEL
@property (nonatomic, strong) NSArray *ultra2ExtendModel;
@property (nonatomic, strong) NSArray *bionimeExtendModel;
@property (nonatomic, strong) NSArray *apexBioExtendModel;


+ (id)brandSharedInstance;

@end

#pragma mark - H2SYNC SYSTEM COMMAND STRUCTURE

@interface H2SyncSystemMessageInfo : NSObject

@property (readwrite) UInt8 cmdSystemLength;
@property (readwrite) Byte *cmdSystemBuffer;
@property (readwrite) Byte *cmdSystemHeader;
@property (readwrite) Byte *cmdBgmHeader;


@property (readwrite) Byte *syncInfoCableStatus;
@property (readwrite) UInt16 syncInfoCableStatusIndex;
@property (readwrite) Byte *syncInfoTempBuffer;
@property (readwrite) UInt16 syncInfoRocheNakTimes;
@property (readwrite) UInt8 systemMeterReportLength;
@property (atomic, readwrite) Byte *systemGlobalBuffer;

@property (readwrite) UInt16 systemGlobalBufferIndex;
@property (readwrite) UInt8 systemGlobalBufferState;
@property (readwrite) UInt8 cmdMeterLength;
@property (readwrite) Byte *cmdMeterBuffer;
//@property (readwrite) UInt16 syncRowBatteryValue;
@property (nonatomic, strong) NSString *syncInfoAudioStatus;
@property (readwrite) BOOL systemSyncCmdAck;

+ (H2SyncSystemMessageInfo *)sharedInstance;

@end
