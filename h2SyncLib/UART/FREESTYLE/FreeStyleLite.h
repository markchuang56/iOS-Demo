//
//  FreeStyleLite.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/28.
//
//
#define FREESTYLE_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"

@class H2BgRecord;
@class H2MeterSystemInfo;

@interface FreeStyleLite : NSObject{
    
}

- (void)FreeStyleCommandGeneral:(UInt16)index withCommandMethod:(UInt16)cmdMethod;



- (H2BgRecord *)fsLiteDateTimeValueParser:(BOOL)unitFlag;
- (H2MeterSystemInfo *)fsLiteSystemInfoParser;
- (BOOL)fsLiteLogNotFoundParser;

+ (FreeStyleLite *)sharedInstance;
@end

