//
//  H2Report.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/14.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#define SN_LEN_CABLE_OLD                10
#define SN_LEN_CABLE_NEW                15
#define FW_LEN_CABLE                    12

#define DATE_TIME_LEN                                   25

#define EQUTO_TO                    0
#define GREAT_THAN                  1
#define LESS_THAN                   2

#import <Foundation/Foundation.h>

@class H2BgRecord;
@class H2MeterSystemInfo;

@interface H2SyncReport : NSObject
{
    
}

@property(readwrite) UInt16 h2BgRecordReportIndex;
@property(readwrite) UInt16 h2BpRecordReportIndex;
@property(readwrite) UInt16 h2BwRecordReportIndex;

@property(readwrite) UInt16 bgLdtIndex;


@property(nonatomic, strong) NSMutableArray *h2BgRecordReportArray;
@property(nonatomic, strong) NSMutableArray *h2BpRecordReportArray;
@property(nonatomic, strong) NSMutableArray *h2BwRecordReportArray;

@property(nonatomic, strong) NSMutableArray *h2MultableLastDateTime;

@property(nonatomic, strong) NSMutableArray *recordsArray;

@property(readwrite) UInt8 h2StatusCode;

@property(readwrite) UInt16 bgHasBeenSkip;
@property(readwrite) UInt16 bpHasBeenSkip;
@property(readwrite) UInt16 bwHasBeenSkip;

//@property(nonatomic, retain) H2BgRecord *tmpBgRecord;
@property(nonatomic, strong) H2MeterSystemInfo *reportMeterInfo;



@property(readwrite) BOOL isMeterWithNewRecords;
@property(readwrite) BOOL didSyncRecordFinished;
@property(readwrite) BOOL hasSMSingleRecord;
@property(readwrite) BOOL hasMultiRecords;
@property(readwrite) BOOL didSendEquipInformation;
@property(readwrite) BOOL didEquipInfoDone;
@property(readwrite) BOOL didSyncFail;


@property(nonatomic, strong) NSString *serverBgLastDateTime;
@property(nonatomic, strong) NSString *serverBpLastDateTime;
@property(nonatomic, strong) NSString *serverBwLastDateTime;

@property(nonatomic, strong) NSString *cableBayerLastDateTime;

@property(nonatomic, strong) NSString *userIdentifier;
@property(nonatomic, strong) NSString *userEMail;

@property(nonatomic, strong) NSString *tmpDateTimeForVue;

+ (H2SyncReport *)sharedInstance;

- (id)init;
- (void)h2SyncNewMeterChecking;
//- (BOOL)h2SyncForaD40DidGreateThanTempTime:(NSString *)newRecordTime;
- (UInt8)h2SyncOmnisDidGreateThanPrevious;
- (BOOL)h2SyncBgDidGreateThanLastDateTime;
- (BOOL)h2SyncBgDidGreateThanLastDateTimeNEW;
- (BOOL)h2SyncBpDidGreateThanLastDateTime;
- (BOOL)h2SyncBwDidGreateThanLastDateTime;
- (BOOL)didGreateMoreThanSystemTime:(NSString *)meterRecordTimeString;
- (BOOL)h2SyncBgDidGreateThanVueLastDateTime;

- (BOOL)kmTimeFormatting:(NSString **)dateTime;
- (unsigned char)h2NumericToChar:(unsigned char)num;

@end

#pragma mark - PHONE SYSTEM TIME
@interface H2SystemDateTime : NSObject
{
    
}

@property(readwrite) UInt16 sysYear;
@property(readwrite) UInt8 sysMonth;
@property(readwrite) UInt8 sysDay;

@property(readwrite) UInt8 sysHour;
@property(readwrite) UInt8 sysMinute;

@property(readwrite) BOOL writeMeterDateTime;

@property(readwrite) UInt8 sysYearByte;


+ (H2SystemDateTime *)sharedInstance;


@end





@interface H2SyncDebug : NSObject
{
    
}

@property(readwrite) UInt16 debugErrorCountMeter;
@property(readwrite) UInt16 debugErrorCountSystem;

@property(readwrite) BOOL zeroRecord;

@property(readwrite) BOOL willReportStatus;

+ (H2SyncDebug *)sharedInstance;



@end
