//
//  h2CmdInfo.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/10/3.
//
//

#import "h2CmdInfo.h"


#pragma mark -
#pragma mark H2SYNC SYSTEM COMMAND IMPLEMENTATION

@implementation H2SyncSystemCommand{
    
    
}


- (id)init
{
    if (self = [super init]) {
        _cmdLength = 0;
        
        _cmdSystemTypeId = 0;
        _cmdSystemDataLength = 0;
        _cmdMcuBufferOffsetAt = 0;
//        _cmdResendInterval = 2.0f;

        _cmdData = (Byte *)malloc(48);
//        _cmdSystemTimer = [[NSTimer alloc] init];
    }
    return self;
}


+ (H2SyncSystemCommand *)sharedInstance
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


#pragma mark -
#pragma mark H2SYNC METER COMMAND IMPLEMENTATION

@implementation H2SyncMeterCommand{
    
    
}


- (id)init
{
    if (self = [super init]) {
        _cmdLength = 0;
        
        _cmdMeterTypeId = 0;
        _cmdMeterDataLength = 0;
        _cmdMcuBufferOffsetAt = 0;

        _cmdData = (Byte *)malloc(48);
//        _cmdMeterTimer = [[NSTimer alloc] init];
    }
    return self;
}


+ (H2SyncMeterCommand *)sharedInstance
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





#pragma mark -
#pragma mark H2 COMMAND INFORMATION IMPLEMENTATION
@implementation H2CmdInfo
{
    
}


- (id)init
{
    if (self = [super init]) {
        
        _receivedDataLength = 0;
        _cmdPreMethod = 0;
        _cmdSavePreMethod = YES;
        
//        _cmdUartSel = 0;
//        _cmdSwitchSel = 0;
        _cmdIrDAMiniBNorInvZeroSwitch = 0;
        _cmdUartLenStopParityBaudRate = 0;
        
    
        _meterRecordCurrentIndex = 0;
        
        _meterRecordReportIndex = 0;
        _meterIndexEqualToOne = NO;
        
//        _meterGluValue = 0;
        

    }
    
    return self;
}


+ (H2CmdInfo *)sharedInstance
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



#pragma mark -
#pragma mark CABLE STATUS PARAMETER IMPLEMENTATION

@implementation H2CableParameter
{
    
}



- (id)init
{
    if (self = [super init]) {

        _h2AudioRoute = @"";
        _cmdCableStatus = 0;
        
        
        _didSkipExistCmd = NO;
        //_didFinishedExistCmd = NO;
        _didFinishedVersionCmd = NO;
        
        _CableVersionNumber = 0;
        
        _cmdGroupInitFlag = NO;

        
        _sdkAndCableVersion = @"";
    }
    return self;
}

+ (H2CableParameter *)sharedInstance
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

#pragma mark -
#pragma mark SYNC STATUS IMPLEMENT

@implementation H2SyncStatus
{
}


- (id)init
{
    if (self = [super init]) {
        
        _didReportFinished = NO;
        _didReportSyncFail = NO;
        _sdkFlowActive = NO;
        //_cablePreSyncStep = NO;
        _cableSyncStop = NO;
        _didMeterUartReady = NO;
    }
    return self;
}
+ (H2SyncStatus *)sharedInstance
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


