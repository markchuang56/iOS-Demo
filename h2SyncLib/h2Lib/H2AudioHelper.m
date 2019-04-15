//
//  H2AudioHelper.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/9.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "version.h"

#import "Fora.h"

#import "H2DebugHeader.h"
#import "H2Sync.h"
#import "H2CableFlow.h"
#import "H2DataFlow.h"

#import "H2AudioFacade.h"
#import "H2AudioSession.h"

#import "H2BleCentralManager.h"
#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "ScannedPeripheral.h"

#import "H2BleOad.h"

#import "H2Config.h"

#import "H2GlucoCardEventProcess.h"
#import "H2iCareSensEventProcess.h"
#import "H2BeneChekEventProcess.h"
#import "H2ApexBioEventProcess.h"

#import "H2RocheEventProcess.h"
#import "H2BayerEventProcess.h"
#import "H2OneTouchEventProcess.h"
#import "H2FreeStyleEventProcess.h"



#import "LSOneTouchUltra2.h"
#import "LSOneTouchUltraVUE.h"
#import "Omnis.h"

#import "JJBayerContour.h"
#import "GlucoCardVital.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>

#import "ROConfirm.h"


#import "H2DebugHeader.h"
#import "H2AudioHelper.h"

#import "H2Timer.h"


@interface H2AudioHelper() <H2AudioFacadeDelegate, H2AudioSessionDelegate, H2BleCentralControllerDelegate>
{
@private
    myVersion *_version;
}

@end

@implementation H2AudioHelper


- (id)init
{
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO HELPER INIT ...");
#endif
    if (self = [super init]) {
        _audioMode = NO;
        ((H2AudioFacade *)[H2AudioFacade sharedInstance]).delegate = (id<H2AudioFacadeDelegate >)self;
        //((H2AudioSession *)[H2AudioSession sharedInstance]).audioSessionDelegate = (id<H2AudioSessionDelegate >)self;
        ((H2BleCentralController *)[H2BleCentralController sharedInstance]).bleDelegate = (id<H2BleCentralControllerDelegate >)self;
    }
    return  self;
}

- (void)audioForSession
{
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO HELPER FOR SESSION %@ ...", [H2AudioSession sharedInstance].audioSessionDelegate);
#endif
    ((H2AudioSession *)[H2AudioSession sharedInstance]).audioSessionDelegate = (id<H2AudioSessionDelegate >)self;
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO HELPER FOR SESSION %@ ...", [H2AudioSession sharedInstance].audioSessionDelegate);
#endif
}


#pragma mark - AUDIO RECEIVE DATA, AND FUNCTION
/*************************************************************************
 * AUDIO AUDIO
 ************************************************************************/
- (void)receiveAudioData:(uint8_t)ch
{
    [[H2DataFlow sharedDataFlowInstance] audioCableDataParser:ch];
}

#pragma mark AudioFacadeDelegate implementation
- (void)h2ExistCable:(BOOL)cable
{
    if (!cable) {
        [[H2AudioFacade sharedInstance] audioStop];
        [[H2AudioSession sharedInstance] setVolumeLevelMin];
        [[H2AudioFacade sharedInstance] commandStop];
        [[H2Timer sharedInstance] clearCableTimer];
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:FAIL_CABLE_EXIST delegateCode:DELEGATE_SYNC];
#ifdef DEBUG_LIB
        DLog(@"DEBUG REMOVED CALBE ----");
#endif
    }
    [H2Sync sharedInstance].isAudioCable = cable;
}

#pragma mark - BLE RECEIVE DATA, AND FUNCTION
/*************************************************************************
 * BLE BLE
 ************************************************************************/

#pragma mark - BLE 4.0 delegate
- (void)h2BleCableSyncEvent
{
    [H2CableFlow sharedCableFlowInstance].audioSystemCmd = CMD_CABLE_EXISTING;
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioHelperCommand:) userInfo:nil repeats:NO];
}

- (void)receiveBleCableData:(NSData *)bleCableData
{
    [[H2DataFlow sharedDataFlowInstance] bleCableDataParser:bleCableData];
}

- (void)h2BleConnectStatus:(UInt8)code withGoodCode:(UInt8)selection
{
#ifdef DEBUG_LIB
    DLog(@"Did come to H2SYNC .... %02X", code);
#endif
    [[H2Sync sharedInstance] demoSdkSyncCableStatus:code delegateCode:selection];
}


unsigned char cableCycleTalk[] = {
    0x00, CMD_INTERFACE_TEST, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00
};

- (void)h2CableCycleTalk:(UInt32)number
{
#ifdef DEBUG_LIB
    UInt8 idx = 0;
    DLog(@"cable cycle test talk");
#endif
    if ([H2Sync sharedInstance].isAudioCable)
    {
#if 1
        unsigned char cmdTmp[sizeof(cableCycleTalk)];
        UInt32 numberTmp = number;
        
        memcpy(cmdTmp, cableCycleTalk, sizeof(cableCycleTalk));
        memcpy(&cmdTmp[6], &numberTmp, sizeof(numberTmp));
#ifdef DEBUG_LIB
        for (idx = 0; idx < sizeof(cableCycleTalk); idx++) {
            DLog(@"the cycle id %02X, %02X", idx, cmdTmp[idx]);
        }
#endif
#else
        unsigned char cmdTmp[sizeof(cableCycleTalkFreeStyle)];
        UInt32 numberTmp = number;
        
        memcpy(cmdTmp, cableCycleTalkFreeStyle, sizeof(cableCycleTalkFreeStyle));
        UInt8 num100, num10, num;
        
        num100 = numberTmp/100;
        num10 = (numberTmp%100)/10;
        num = (numberTmp%100)%10;
        cmdTmp[2+5] = 0x30 + num100;
        cmdTmp[2+6] = 0x30 + num10;
        cmdTmp[2+7] = 0x30 + num;
        
#endif
        [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdTmp withCmdLength:sizeof(cmdTmp) cmdType:BRAND_SYSTEM
                                         returnDataLength:0 mcuBufferOffSetAt:0];
    }else{
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:FAIL_CABLE_EXIST delegateCode:DELEGATE_SYNC];
    }
    
#ifdef DEBUG_LIB
    DLog(@"cycle test command here....");
#endif
}

#pragma mark - TOOL METHOD
unsigned char cableSNtalk[] = {
    0x00, CMD_SN_TALK, 0x00, 0x00
};


#pragma mark - AUDIO SART AND SN FUNCTION
- (BOOL)start:(NSError **)error
{
    return [[H2AudioFacade sharedInstance] audioStart:error];
}

- (void)tmReadWriteH2SerialNumber:(unsigned char *)sn withLength:(UInt8)length reading:(BOOL)reading
{
    if ([H2Sync sharedInstance].isAudioCable  || [H2BleService sharedInstance].isBleCable)
    {
        UInt8 wantToRead = 0;
        unsigned char tmp[16] = {0};
        UInt16 cmdLength = 0;
        
        cmdLength = sizeof(cableSNtalk);
        memcpy(tmp, cableSNtalk, sizeof(cableSNtalk));
        
        
        if (reading) {
            wantToRead = 0x80;  // read serial number
            [H2SyncSystemCommand sharedInstance].cmdSystemDataLength = 0x80;// reading
        }else{ // write serial number
            cmdLength += length;
            memcpy(&tmp[sizeof(cableSNtalk)], sn, length);
        }
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:tmp withCmdLength:cmdLength cmdType:BRAND_SYSTEM
                                         returnDataLength:wantToRead mcuBufferOffSetAt:0];
        
        [[H2CableFlow sharedCableFlowInstance] h2SystemResendCmdInit];
    }else{
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:FAIL_CABLE_EXIST delegateCode:DELEGATE_SYNC];
    }
}


- (void)h2BleDebugScan:(BOOL)enableScan
{
    [H2BleService sharedInstance].blePairingStage = NO;
    [H2Sync sharedInstance].isAudioCable = NO;
    if ([H2BleCentralController sharedInstance].h2CentralManager == nil) {
        [[H2BleCentralController sharedInstance] h2CentralManagerAlloc];
    }
    [[H2BleCentralController sharedInstance] h2BleStart:nil];
}


#pragma mark - DEBUG MODE, REPORT ERROR COUNT

- (void)h2AudioLongRunReport:(NSMutableArray *)dataGroup
{
    @autoreleasepool {
        if ([self.libAudioDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libAudioDelegate respondsToSelector:@selector(h2EngineerChecking:)])
        {
            [self.libAudioDelegate h2EngineerChecking:dataGroup];
        }
    }
}

- (void)h2SyncDebugTask:(id)sender
{
#ifdef DEBUG_LIB
    if (![H2AudioAndBleSync sharedInstance].syncIsNormalMode) {
        @autoreleasepool {
            if ([self.libAudioDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
                [self.libAudioDelegate respondsToSelector:@selector(h2EngineerBufferErr:)])
            {
                [self.libAudioDelegate h2EngineerBufferErr:[H2SyncDebug sharedInstance].debugErrorCountMeter];
            }
        }
        @autoreleasepool {
            if ([self.libAudioDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
                [self.libAudioDelegate respondsToSelector:@selector(h2EngineerSystemErr:)])
            {
                [self.libAudioDelegate h2EngineerSystemErr:[H2SyncDebug sharedInstance].debugErrorCountSystem];
            }
        }
        
    }
    DLog(@"SYSTEM_DEBUG -- SYSTEM RESEND TIMER INSTANCE 1 @%@, %02d", [H2Timer sharedInstance].resendCableCmd, [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle);
    
    DLog(@"METER_DEBUG--  METER RESEND TIMER INSTANCE 1 @%@, %02d", [H2Timer sharedInstance].resendMeterCmd, [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle);
    
    DLog(@"Buffer Status is %02X.\n", [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState);
#endif
}




- (void)h2CableTotalRecord:(BOOL)getTotal
{
    [H2AudioAndBleSync sharedInstance].syncIsNormalMode = getTotal ? NO : YES;
    [H2SyncDebug sharedInstance].debugErrorCountMeter = 0;
    [H2SyncDebug sharedInstance].debugErrorCountSystem = 0;
}

#pragma mark - INTERNAL TASK
- (void)audioHelperCommand:(id)sender
{
    [[H2CableFlow sharedCableFlowInstance] h2CableSystemCommand:nil];
}

+ (H2AudioHelper *)sharedInstance
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
    DLog(@"H2SYNC instance IS @%@", _sharedObject);
#endif
    return _sharedObject;
}



@end


/////////////////////////////////////////////////////////


@implementation H2PackageForSync


- (id)init
{
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO HELPER INIT ...");
#endif
    if (self = [super init]) {
        _interfaceTask = 0;
        _uIDStringFromRegister = @"";
        _uEMailStringFromRegister = @"";
        
        _equipCode = 0;
        
        _recordTypeInMeter = 0; // 1 : bg, 2 : bp, 4 : bw
        _bleScanningKey = @"";
        _serverLastDateTimeArray = [[NSMutableArray alloc] init];
        //_userProfile = [[UserGlobalProfile alloc] init];
        
        _bleIdentifier = @"";
        _userTagInMeter = 0;
#ifdef DEBUG_AUDIO
        DLog(@"SDK PROFILE -- %@", _userProfile);
#endif
    }
    return  self;
}
// 0 : audio
// 1 : ble cable sync
// 2 : ble Sync
// 3 : ble cable pairing
// 4 : ble pairing
// 5 : oad update

@end


//Y  M  D  S  BH()
//ff ff 00 00 0000 81 82 83 85
//           Crc Crc_Ex
//86 84 0000 13  eb

@implementation UserGlobalProfile


- (id)init
{
    if (self = [super init]) {
        //////////////////////
        // OMRON - HBF-254C,
        // OMRON - HEM-7280T
        _uBuffer = (Byte *) malloc(16);
        
        _uTag = 1;
        _uBirthYear = BIRTH_YEAR;
        _uBirthMonth = BIRTH_MONTH;
        _uBirthDay = BIRTH_DAY;
        
        _uGender = MALE;
        _uBodyHeight = BODY_HEIGHT;
        
        _uBuffer[0] = (_uBirthYear-1900) & 0x00FF;
        _uBuffer[1] = _uBirthMonth;
        _uBuffer[2] = _uBirthDay;
        
        _uBuffer[3] = _uGender;
        
        _uBuffer[5] = (_uBodyHeight & 0x00FF);
        
        _uBuffer[4] = ((_uBodyHeight>>8) & 0x00FF);
        
        _uBuffer[6] = 0x81;
        _uBuffer[7] = 0x82;
        _uBuffer[8] = 0x83;
        _uBuffer[9] = 0x85;
        
        _uBuffer[10] = 0x86;
        _uBuffer[11] = 0x84;
        _uBuffer[12] = 0x00;
        _uBuffer[13] = 0x00;
    }
    
    return self;
}

/*
+ (UserGlobalProfile *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_AUDIO
    DLog(@"Meter USER PROFILE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}
*/

@end




@implementation TS_Sever


- (id)init
{
    if (self = [super init]) {
        
        _tsServerLastDateTimes = [[NSMutableArray alloc] init];
        _tsServerMeterUserId = 1;
        _tsServerMeterDataType = 1;
        _tsServerMeterIdSel = 0x00000000;
    }
    return self;
}


+ (TS_Sever *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_AUDIO
    DLog(@"TS SERVER VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

@end



#if 0
@implementation SMSyncStatus

- (id)init
{
    if (self = [super init]) {
        _globalStatus = FAILED_CABLE_NOTFOUND;
    }
    return self;
}


+ (SMSyncStatus *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_AUDIO
    DLog(@"TS SERVER VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

@end

#endif
