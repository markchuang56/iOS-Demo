//
//  H2BleHmd.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/10/28.
//  Copyright © 2015年 h2Sync. All rights reserved.
//


#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"


#import "h2DebugHeader.h"
#import "h2CmdInfo.h"
#import "H2BleHmd.h"

@implementation H2BleHmd



- (id)init
{
    if (self = [super init]) {
        
        _hmdBleCharSel = 2;
        _hmdRecordIndex = 1;
        _hmdTmpIndex = 0;
        
        _h2_HMD_Service = nil;
        _h2_HMD_CHAR_Measurement = nil;
        _h2_HMD_CHAR_Feature = nil;
        _h2_HMD_CHAR_RecordAccessControlPoint = nil;
        
#ifdef DEBUG_LIB
        DLog(@"H2 HMD BLE init ....");
#endif
    }
    return self;
}



+ (H2BleHmd *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_LIB
    DLog(@"BLE HMD INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

@end





