//
//  Omnis.h
//  h2SyncLib
//
//  Created by h2Sync on 2014/2/7.
//
//


#define HIGH_SPEED

#define EMBRACE_COEF_AT                     (14+8)
//#define EMBRACE_COEF_MAX                14

#define EMBRACE_INDEX_MAX                   300

#define OMNIS_COMMAND_LEN                   11

#define EMBRACE_REPORT_COEF                 20 // for BLE TEST ....(20)
#define OMNIS_REPORT_LEN                    11

#define EM_DIV_MODE                         0x80
#define EM_CYCLE                            (300/EMBRACE_REPORT_COEF)

#define EMBRACE_SKIP_MAX                        0x01
#define EMBRACE_SW_TURN_OFF                     0x02

#define GLUCOSURE_HT_LIKE                       0x98

#define APEXBIO_END                             0xFF

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"

@class H2BgRecord;

#define OMNIS_FAIL_AT_SYNC                           0x8A

@interface Omnis : NSObject
{
    
}

@property(readwrite) UInt16 indexSeed;

@property(readwrite) UniChar OmnisPreYear;
@property(readwrite) UniChar OmnisPreYearOther;


//@property(readwrite) UInt16 omnisMeter_id;

@property(readwrite) UInt16 tmpIndex;


@property(readwrite) UInt16 omnisYear;
@property(readwrite) UInt8 omnisMonth;

@property(readwrite) UInt16 omnisTotalTime;

@property(readwrite) UInt8 omnisDay;

@property(readwrite) UInt8 omnisHour;
@property(readwrite) UInt8 omnisMinute;

@property(readwrite) UInt8 omnisUnit;
@property(readwrite) UInt8 omnisCtrlSolution;

@property(readwrite) UInt16 omnisValue;


@property(readwrite) UInt8 omnisTmpD1_Ctrl;
@property(readwrite) UInt8 omnisTmpD1_Food;
@property(readwrite) UInt8 omnisTmpD1_Events;

@property(readwrite) UInt8 OmnisEmbraceCount;


- (void)OmnisCommandGeneral:(UInt16)cmdMethod;
- (void)OmnisRecord:(UInt16)nIndex;
- (void)OmnisRecordAll:(UInt16)nIndex;
- (void)OmnisNumberOfRecord:(UInt16)nIndex;



#pragma mark - OMNIS PARSER
- (BOOL)OmnisParserCheck;
- (BOOL)OmnisEVOParserCheck;

- (NSString *)OmnisSNParser;
- (NSString *)OmnisCurrentTimeParser;
- (H2BgRecord *)OmnisDateTimeValueParserEmbrace;//:(UInt16)index;
- (NSMutableArray *)OmnisDateTimeValueParserEmbraceAll;

- (H2BgRecord *)OmnisDateTimeValueParser:(UInt16)index;

- (H2BgRecord *)OmnisDateTimeValueParserEVO;
- (H2BgRecord *)OmnisModelFormatParser;
- (H2BgRecord *)OmnisEVOModelFormatParser;



// for test
- (void)OmnisInitExt:(UInt16)currentMeter;

+ (Omnis *)sharedInstance;
@end

// Over Loading Process
// 94 : Set Skip index
// 91 : Turn On Switch
// 90_8 : Send Meter Record Ack Command, flag to Turn OFF Switch

