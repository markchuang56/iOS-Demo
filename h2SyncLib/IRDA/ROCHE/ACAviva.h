//
//  ACAviva.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/29.
//
//

#define AVIVA_RESEND_INTERVAL       3.0f

//#define ACCU_CHEK_CMD_INTERVAL      0.02f

// why ???
//#define ACCU_CHEK_CMD_INTERVAL      0.6f
//#define ACCU_CHEK_CMD_INTERVAL      0.2f

#define ACCU_CHEK_CMD_NAK           0x15

#define ACCU_ACTIVE_DINDEX_MAX      50
//#define ACCU_CHEK_SCALE                 80
//#define ACCU_CHEK_INDEX_MIN           100
//#define ACCU_CHEK_NUMBER_MIN           200

//#define ACCU_CHEK_LONG_RUN

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"



@class H2BgRecord;

@interface H2RocheAviva : NSObject{
}

- (void)AvivaCommandGeneral:(UInt16)comdMethod;


- (void)AvivaReadRecord:(UInt16)nIndex;


- (H2BgRecord *)acAvivaDateTimeValueParser:(BOOL)mmolUnit;

- (NSString *)acAvivaParserEx;
- (UInt16) acAvivaParserNumberOfRecord;

- (NSString *)acAvivaDateParserEx;
- (NSString *)acAvivaTimeParserEx:(NSString *)dateString;

+ (H2RocheAviva *)sharedInstance;

@end





