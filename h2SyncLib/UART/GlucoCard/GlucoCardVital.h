//
//  GlucoCardVital.h
//  h2SyncLib
//
//  Created by h2Sync on 2014/6/19.
//  Copyright (c) 2014年 h2Sync. All rights reserved.
//

#define RELION_DELAY                    0x65
#define GLUCOCARD_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"


@interface GlucoCardVital : NSObject
{
    
}
@property(readwrite) BOOL h2SyncIsVitalHighSpeedMode;

- (void)GlucoCardVitalCommandGeneral:(UInt16)cmdMethod;
- (void)GlucoCardVitalRecord:(UInt16)nIndex;

- (unsigned char)glucoNumericToChar:(unsigned char)num;

+ (GlucoCardVital *)sharedInstance;

@end

