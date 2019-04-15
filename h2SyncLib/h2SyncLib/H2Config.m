//
//  H2Config.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/13.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "H2Config.h"

@implementation H2Config

@end


#pragma mark - AUDIO AND BLE COMMAND
@implementation H2AudioAndBleCommand : NSObject{
}



- (id)init
{
    if (self = [super init]) {
        
        _value = (Byte *)malloc(64);
        
        _cmdMethod = 0;
        _cmdPreMethod = 0;
        _cmdModel = 0;
        _cmdBrand = 0;
        
        _cmdLength = 0;
        _reportLength = 0;
        _uartRxBufferOffset = 0;
        
        _cmdInterval = 0.5f;
        _didTriggerMeterCmd = NO;
        
    }
    return self;
}

// [H2AudioAndBleCommand sharedInstance].cmdInterval

+ (H2AudioAndBleCommand *)sharedInstance
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

#pragma mark - Resend COMMAND OBJECT
@implementation H2AudioAndBleResendCfg : NSObject{
    
}

- (id)init
{
    if (self = [super init]) {
        
        _resendSystemCmdCycle = 0;
        _resendSystemCmdInterval = 2.02f;
        _didResendSystemCmd = NO;
        
        
        _resendMeterCmdCycle = 0;
        _resendMeterCmdInterval = 2.02f;
 //       _cmdMeterNormalInterval = 0.02f;
        _didResendMeterCmd = NO;

        
        _didNeedSaveRocheTypePreCmd = NO;
        
        _resendPreCmdHeaderData  = (Byte *)malloc(48);
        _resendPreCmdLength = 0;
        
        _resendCmdLength = 0;
        _resendCmdType = 0;
    }
    return self;
}

+ (H2AudioAndBleResendCfg *)sharedInstance
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
// [H2AudioAndBleResendCfg sharedInstance].



#pragma mark - AUDIO AND BLE SYNC

@implementation H2AudioAndBleSync : NSObject{
}



- (id)init
{
    if (self = [super init]) {
        
        _dataHeader = (Byte *)malloc(6);
        _dataBuffer = (Byte *)malloc(256*2);
        
        _dataLength = 0;
        
        _recordIndex = 0;
        _recordTotal = 0;
        
        _syncPreState = NO;
        _syncRunning = NO;
        _syncIsNormalMode = YES;
    }
    return self;
}

+ (H2AudioAndBleSync *)sharedInstance
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
