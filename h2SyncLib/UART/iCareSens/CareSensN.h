//
//  CareSensN.h
//  h2SyncLib
//
//  Created by h2Sync on 2014/1/6.
//
//

#define CARESENS_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"

@class H2BgRecord;
@class H2MeterSystemInfo;

@interface CareSensN : NSObject

- (void)CareSensCommandGeneral:(UInt16)cmdMethod;

- (void)CareSensReadRecord:(UInt16)nIndex;


- (H2BgRecord *)careSenseNDateTimeValueParser;
- (H2MeterSystemInfo *)careSenseNSystemInfoParser;

+ (CareSensN *)sharedInstance;
@end
