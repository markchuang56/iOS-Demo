//
//  LSOneTouchUltraMini.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//

#define ULTRAMINI_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"


@class H2BgRecord;

#define ONETOUCH_ULTRAMINI_SN_AT_11                 (6+5)
#define ONETOUCH_ULTRAMINI_UNIT_AT_11               (6+5)
#define ONETOUCH_ULTRAMINI_TIME_AT_11               (6+5)
#define ONETOUCH_ULTRAMINI_VALUE_AT_15              (6+5+4)

#define STR_YEAR_EASY                   1970
#define STR_YEAR_FLEX                   2000

@interface LSOneTouchUltraMini : NSObject
{
    
}
@property(readwrite) BOOL didUseMmolUnit;

- (void)UltraMiniCommandGeneral:(UInt16)cmdMethod;
- (void)UltraMiniReadRecord:(UInt16)nIndex;


- (unsigned short)crc_calculate_crc :(unsigned short)initial_crc inSrc : (const unsigned char *)buffer inLength :(unsigned short) length;





- (H2BgRecord *)ultraMiniDateTimeValueParser;

- (NSString *)ultraMiniSerialNumberParserEx;
- (NSString *)ultraMiniCurrentDateTimeParserEx;

- (NSString *)dateTimeParser:(UInt32)inSecond;

+ (LSOneTouchUltraMini *)sharedInstance;

@end

