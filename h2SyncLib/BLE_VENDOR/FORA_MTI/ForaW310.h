//
//  Fora.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/12/9.
//  Copyright © 2015年 h2Sync. All rights reserved.
//




// FORA UUID Base: 1212-efde-1523-785feabcd123
// FORA Service UUID: 0x1523
// FORA Characteristic: 0x1524 (write/notify)

//#define FORA_METER_SERVICE_UUID                     @"00001523-1212-EFDE-1523-785FEABCD123"
//#define FORA_METER_CHARACTERISTIC_UUID              @"00001524-1212-EFDE-1523-785FEABCD123"
// Service //00001523-1212-EFDE-1523-785FEABCD123>

@class H2BwRecord;

#import <Foundation/Foundation.h>

@interface ForaW310 : NSObject


- (H2BwRecord *)recordBwParser;
- (void)foraW310BSetUserProfile:(UInt8)userId;
- (BOOL)foraW310BRecordProcess;

+ (ForaW310 *)sharedInstance;

@end







