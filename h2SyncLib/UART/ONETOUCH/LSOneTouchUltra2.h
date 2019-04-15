//
//  LSOneTouchUltra2.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//


#define ULTRA2_SWITCH_ON_INTERVAL                    1.0f

#define ULTRA2_COEF                                 0.82f // 0.8 ms/10 record delay

#define ULTRA2_RECORD_INTERVAL                      0.082f // 0.8 ms/10 record delay



#define ULTRA2_AUDIO_RECORD_SKIP              20
#define ULTRA2_AUDIO_RECORD_LENGTH            16


#define ULTRA2_BLE_HEADER_LENGTH                        33
#define ULTRA2_BLE_RECORD_LENGTH                        61


#import "h2BrandModel.h"
#import "h2CmdInfo.h"


@class H2BgRecord;
@class H2MeterSystemInfo;

@interface LSOneTouchUltra2 : NSObject
{
    
}

@property(readwrite) UInt16 ultraOldCmdLength;
@property(readwrite) UInt16 ultraOldCmdIndex;
@property(readwrite) BOOL ultraOldRecordsSart;

@property(readwrite) UInt16 ultraOldTotalRecords;
@property(readwrite) UInt16 ultraOldIndexRecords;

@property (readwrite) BOOL didUseMmolUnit;
@property(readwrite) UInt16 ultra2RecordNumber;

@property(readwrite) UInt16 ultra2RecordIndex;

@property(nonatomic, strong) NSString *ultra2RecordUnit;


- (void)Ultra2CommandGeneral:(UInt16)cmdMethod;
- (void)Ultra2ReadRecord:(UInt8)currentIndexDiv;
- (void)Ultra2BLEReadRecordAll;//:(UInt16)currentMeter;



- (NSMutableArray *)ultra2ValueArrayParser:(UInt16)indexOffset;
- (NSMutableArray *)ultra2DateTimeValueArrayParser:(UInt16)indexOffset;

- (H2MeterSystemInfo *)ultra2AudioHeaderParser;



- (NSString *)ultra2ElseParser;

#pragma mark - ULTRA XXX
- (void)UltraXXXCommandGeneral:(UInt16)cmdMethod;
- (void)UltraOldCommandLoop:(UInt16)cmdMethod;

- (NSString *)ultraXXXParser;
- (UInt16)ultraXXXNumberOfRecordsParser;
- (H2BgRecord *)ultraXXXRecordsParser;

- (H2MeterSystemInfo *)ultra2BLEHeaderParser;
- (H2BgRecord *)ultra2BLEDateTimeValueParser;
- (BOOL)ultra2BLECheckSumTest;


+ (LSOneTouchUltra2 *)sharedInstance;
// [LSOneTouchUltra2 sharedInstance].didUseMmolUnit
@end


