//
//  LSOneTouchUltra2.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//

/*
#define ULTRA2_SWITCH_ON_INTERVAL                    1.0f

#define ULTRA2_COEF                                 0.82f // 0.8 ms/10 record delay

#define ULTRA2_RECORD_INTERVAL                      0.082f // 0.8 ms/10 record delay



#define ULTRA2_AUDIO_RECORD_SKIP              20
#define ULTRA2_AUDIO_RECORD_LENGTH            16


#define ULTRA2_BLE_HEADER_LENGTH                        33
#define ULTRA2_BLE_RECORD_LENGTH                        61
*/

#define STR_YEAR_VUE                2000
#define YYY_YEAR_VUE                2000

//#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"

@class H2BgRecord;

@interface LSOneTouchUltraVUE : NSObject
{
    
}


- (void)UltraVueCommandGeneral:(UInt16)cmdMethod;
- (void)UltraVueReadRecord:(UInt16)nIndex;

#pragma mark - PARSER
- (NSString *)ultraVueSerialNumberParser;
- (NSString *)ultraVueCurrentTimeParser;
- (NSString *)ultraVueVersionParser;


- (UInt16)ultraVueRecordNumberParser;

- (H2BgRecord *)ultraVueDateTimeValueParser;

+ (LSOneTouchUltraVUE *)sharedInstance;

@end


