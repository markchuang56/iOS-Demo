//
//  BleConnect.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/10/23.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "BleDidConnectPeripheral.h"

@implementation BleDidConnectPeripheral


+ (BleDidConnectPeripheral *)sharedInstance
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
