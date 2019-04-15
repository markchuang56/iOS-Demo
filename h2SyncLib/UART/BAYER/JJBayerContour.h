//
//  JJBayerContour.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//





#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"

@class H2MeterSystemInfo;

@class H2BgRecord;

@interface JJBayerContour : NSObject{
    
}
@property (readwrite) BOOL didSkipMeterInfo;
@property (readwrite) BOOL goToNextYearStage;
@property (readwrite) BOOL isSyncSecondStageRunning;

@property (readwrite) BOOL isSyncSecondStageDidRemoved;

@property (readwrite) BOOL isBayerOldFWVersion;

@property (readwrite) BOOL didBayerSyncRunning;

@property (readwrite) BOOL didBayerMmolUnit;


- (void)jjBayerCommandGeneral:(UInt16)cmdMethod;


- (H2MeterSystemInfo *)jjContourCurrentTimeParserEx;
- (NSString *)jjContourUnitParserEx;

- (H2BgRecord *)jjContourDateTimeValueParser:(UInt16)index;

#pragma mark - BLE PARSER
- (H2BgRecord *)jjContourBLEDateTimeValueParser;

+ (JJBayerContour *)sharedInstance;
@end





