//
//  H2Timer.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/6/3.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2Timer.h"

@implementation H2Timer

- (id)init
{
    if (self = [super init]) {
        
        //_bleCableSyncFinished = [[NSTimer alloc] init];
        //_bleCableSyncFinished = nil;
        
        _resendMeterCmd = [[NSTimer alloc] init];
        _resendMeterCmd = nil;
        
        _resendCableCmd = [[NSTimer alloc] init];
        _resendCableCmd = nil;
    }
    return self;
}


#pragma mark - CLEAR TIMER
- (void)clearCableTimer
{
#ifdef DEBUG_LIB
    DLog(@"DEBUG METER TIMER @%@", _resendMeterCmd);
    DLog(@"DEBUG SYSTEM TIMER @%@", _resendCableCmd);
#endif

    if (_resendMeterCmd != nil) {
        [_resendMeterCmd invalidate];
        _resendMeterCmd = nil;
    }
    
    if (_resendCableCmd != nil) {
        [_resendCableCmd invalidate];
        _resendCableCmd = nil;
    }
 
}


+ (H2Timer *)sharedInstance
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
