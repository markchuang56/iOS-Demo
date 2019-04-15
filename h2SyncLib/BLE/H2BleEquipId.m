//
//  H2SyncService.m
//  h2Central
//
//  Created by h2Sync on 2015/2/2.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>
// BLE 
#import "H2BleEquipId.h"

// SYSTEM
#import "h2DebugHeader.h"
#import "h2CmdInfo.h"
#import "h2Config.h"

#import "H2Sync.h"

// DEVICE
#import "Fora.h"
#import "H2BleHmd.h"
#import "H2BleOad.h"
#import "BleBtm.h"


@implementation H2BleEquipId{
}


- (id)init
{
    if (self = [super init]) {
        _bleEquipBuffer = [[NSMutableData alloc] init];
        [_bleEquipBuffer setLength:0];
    }
    return self;
}


+ (H2BleEquipId *)sharedEquipInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred = 0;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


@end


