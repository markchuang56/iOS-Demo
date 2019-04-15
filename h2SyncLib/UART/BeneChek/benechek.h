//
//  benechek.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//


#define BC_START_INDEX          10
#define BC_END_INDEX            12

#define BENECHEK_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"

@class H2BgRecord;

@interface benechek : NSObject
{
    
}

- (void)BeneChekCommandGeneral:(UInt16)cmdMethod;

- (void)BeneChekQueryGluValue:(UInt16)indexOfRecord;



- (NSString *)beneChekModelParser;


- (H2BgRecord *)beneChekDateTimeParser:(BOOL)unitFlag;

+ (benechek *)sharedInstance;
@end

