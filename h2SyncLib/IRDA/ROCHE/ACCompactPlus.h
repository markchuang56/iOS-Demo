//
//  ACCompactPlus.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/28.
//
//
#define COMPACTPLUS_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"

@class H2BgRecord;

@interface H2RocheCompactPlus : NSObject

- (void)CompactPlusCommandGeneral:(UInt16)cmdMethod;
- (void)CompactPlusReadRecord:(UInt16)nIndex;


- (H2BgRecord *)acCompactPlusDateTimeValueParser:(BOOL)mmolUnit;
- (NSString *)acCompactPlusParserEx;

- (NSString *)acCompactPlusDateParserEx;
- (NSString *)acCompactPlusTimeParserEx:(NSString *)dateString;

+ (H2RocheCompactPlus *)sharedInstance;
@end
