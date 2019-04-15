//

//
//  Created by JasonChuang on 12/10/29.

//
//#import "PDKeychainBindingsController.h"
//#import "ACSimpleKeychain.h"



#import "version.h"

#import "Fora.h"
#import "ForaD40.h"
#import "OneTouchPlusFlex.h"

#import "H2DebugHeader.h"
#import "H2Sync.h"
#import "H2CableFlow.h"
#import "H2DataFlow.h"
#import "H2AudioHelper.h"
#import "H2Records.h"

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

#import "OMRON_HEM-9200T.h"
#import "OMRON_HEM-7280T.h"
#import "OMRON_HBF-254C.h"
#import "ARKRAY_GT-1830.h"

#import "LSOneTouchUltra2.h"
#import "LSOneTouchUltraVUE.h"
#import "Omnis.h"

#import "JJBayerContour.h"
#import "GlucoCardVital.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>

#import "ROConfirm.h"

#import "H2DataFlow.h"

#import "H2DebugHeader.h"
#import "H2LastDateTime.h"

#import "H2BleTimer.h"
#import "H2Timer.h"

#import "H2Records.h"

#import "H2BleBgm.h"
#import "AllianceDSA.h"


#define DELAY_RECORDS               0.2f

/************************************
 * Internal usage only
 ************************************/

@interface H2Sync()<H2AudioHelperDelegate>
{
@private
    myVersion *_version;
    BOOL bleNormalConnect;
}


#pragma mark - SYSTEM COMMAND DEFINE

- (BOOL)dataTypeChecking:(UInt8)type;
- (void)transferRecordsTask;


#pragma mark - BLE METHOD DEFINE
- (void)h2CableBLEDelayTurnOffSW;
- (void)h2SyncInfoReportProcess;

@end

@implementation H2Sync

- (id)init
{
    if (self = [super init]) {
#ifdef DEBUG_LIB
        DLog(@"H2SYNC INIT ...");
#endif
        _isAudioCable = NO;
    
        //H2AudioHelperDelegate
        [H2AudioHelper sharedInstance].libAudioDelegate = (id<H2AudioHelperDelegate >)self;
        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex = 0;
        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
        
        _version = [[myVersion alloc] init];
        //_isAudioCable = [H2AudioSession isHeadsetPluggedIn];
    }
    return self;
}

+ (H2Sync *)sharedInstance
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


        
#pragma mark - BATTERY & DYNAMIC INFO
- (void)sdkSendSerialNumberBatteryLevel:(UInt8)devSel
{
    BatDynamicInfo *dynamic = [[BatDynamicInfo alloc] init];
    
    dynamic.batteryLevel = [H2BleService sharedInstance].batteryLevel;
    dynamic.batteryRawData = [H2BleService sharedInstance].batteryRawValue;
    switch (devSel) {
        case DYNAMIC_AUDIO: // AUDIO CABLE
            dynamic.devType = DYNAMIC_AUDIO;
            dynamic.serialNumber = [H2DataFlow sharedDataFlowInstance].cableSN;
            dynamic.cableVersion = [H2DataFlow sharedDataFlowInstance].cableFW;
            break;
            
        case DYNAMIC_DONGLE: // BLE CABLE
            dynamic.devType = DYNAMIC_DONGLE;
            dynamic.serialNumber = [H2DataFlow sharedDataFlowInstance].cableSN;
            dynamic.cableVersion = [H2DataFlow sharedDataFlowInstance].cableFW;
            dynamic.bleLocalName = [H2BleService sharedInstance].bleTempLocalName;
            dynamic.bleIdentifier = [H2BleService sharedInstance].bleTempIdentifier;
            break;
            
        case DYNAMIC_BLE_METER: // BLE METER
            dynamic.devType = DYNAMIC_BLE_METER;
            dynamic.serialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            dynamic.bleLocalName = [H2BleService sharedInstance].bleTempLocalName;
            dynamic.bleIdentifier = [H2BleService sharedInstance].bleTempIdentifier;
            break;
            
        default:
            dynamic.devType = 4;
            dynamic.serialNumber = @"XXX";
            break;
    }
    
    /*
     // To Get : BLE Name And Ble Identifier
    if ([H2BleService sharedInstance].h2ConnectedPeripheral != nil) {
        bleName = [H2BleService sharedInstance].h2ConnectedPeripheral.name;
        blePeripheral = @{@"BT_NAME" : bleName, @"BT_IDENTIFIER" :[H2BleService sharedInstance].bleTempIdentifier};
    }
    */
    
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateBatteryAndDynamicInfo:)])
        {
            [self.libDelegate appDelegateBatteryAndDynamicInfo:dynamic];
        }
    }
}


#pragma mark - AUDIO FACADE
#pragma mark AudioFacadeDelegate implementation
#pragma mark - AUDIO METHOD AREA
- (void)openAudioFirstTime
{
    NSError *error;
    if (_isAudioCable) {
        [[H2AudioFacade sharedInstance] audioStart:&error];
        // Set YES, don't send cable existing test,
        [[H2AudioSession sharedInstance] setVolumeLevelMax];
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(h2CableAudioExistingCheck) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
        DLog(@"Internal Set Audio Volume.+++++++++++++++  1");
#endif
    }else{
#ifdef DEBUG_LIB
        DLog(@"AUDIO_DEBUG cable not existing.");
#endif
    }
}


- (void)h2CableAudioExistingCheck
{
    [H2CableFlow sharedCableFlowInstance].audioSystemCmd = CMD_CABLE_EXISTING;
    [[H2CableFlow sharedCableFlowInstance] h2CableSystemCommand:nil];
    [[H2AudioFacade sharedInstance] h2AudioTriggerCommand];
#ifdef DEBUG_LIB
    DLog(@"AUDIO CABLE EXISTING CHECKING");
#endif
}



#pragma mark - REPORT CABLE STATUS, SYNC FINISHED, TOURN OFF SW

- (void)demoSdkSyncCableStatus:(UInt8)status delegateCode:(UInt8)deleSel
{
#ifdef DEBUG_LIB
    NSLog(@"STATUS RAW = %02X and SEL = %d", status, deleSel);
#endif
    [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatus[[H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex] = status;
    BOOL isFlowEnding = NO;
    if (status & 0x80) {
        isFlowEnding = YES;
        [H2BleService sharedInstance].blePairingModeFinished = YES;
        [H2BleService sharedInstance].bleErrorHappen = YES;
        if ([H2BleService sharedInstance].isBleCable) {
            [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
        }
    }
#ifdef DEBUG_LIB
    NSLog(@"SDK STATUS = %02X", status);
#endif
    if (deleSel != DELEGATE_DEVELOP) {
        switch (status) {
            case SUCCEEDED_NEW:
                [H2BleService sharedInstance].bleErrorHappen = YES;
                status = H2SSDKSyncStatusWithNewRecord;
                break;
            case SUCCEEDED_OLD:
                [H2BleService sharedInstance].bleErrorHappen = YES;
                status = H2SSDKSyncStatusNoNewRecord;
                break;
                
            case SUCCEEDED_PAIR:
                [H2BleService sharedInstance].bleErrorHappen = YES;
                status = H2SSDKPairStatusBleCableSucceeded;
                break;
                
            case FAIL_CABLE_EXIST:
                status = H2SSDKSyncStatusCableNotFound;
                break;
                
            case FAIL_METER_EXISTING:
                status = H2SSDKSyncStatusMeterNotFound;
                break;
                
                
            case FAIL_BLE_PHONE_OFF:
                status = H2SSDKSyncStatusBLEDisabled;
                break;
                
            case FAIL_BLE_NOT_FOUND:
                status = H2SSDKSyncStatusBLENotFound;
                break;
                
            case FAIL_BLE_INSUFFICIENT_AUTHENTICATION:
                status = H2SSDKSyncStatusAuthFailed;
                break;
                
            case FAIL_BLE_PAIR_TIMEOUT:
            //case FAIL_BLE_NO_DIALOG:
                status = H2SSDKPairStatusTimeout;
                break;
                
            case FAIL_BLE_MODE:
                status = H2SSDKPairStatusModeError;
                break;
                
            case H2SSDKSyncStatusSdkFlowBusy:
                status = H2SSDKSyncStatusSdkFlowBusy;
                break;
               
            case FAIL_BLE_ARKRAY_CMD_NOT_FOUND:
                status = H2SSDKSyncStatusAppRemoved;
                break;
                
            case FAIL_BLE_NEO_DISCONNECT:
                status = H2SSDKSyncStatusMeterAbnormal;
                break;
                
            case FAIL_SYNC:
            case FAIL_BLE_ARKRAY_PASSWORD:
            default:
                // FAIL_BLE_CMD_ERR                            0xA1 // SYNC ERR
                // FAIL_BLE_ARKRAY_CMD_NOT_FOUND              0xA2 // Pair ERR, Retry
                // FAIL_BLE_ARKRAY_PASSWORD                   0xA3 // Pair Err, Remove & Retry
                // FAIL_BLE_ARKRAY_PWSLOWLY                   0xA5 // Pair Err, Remove & Retry
                
                // FAIL_BLE_OMRON_PAIRCANCEL                  0xA6 // Maybe Change ...
                
                // W310
                // FAIL_BLE_FORA_NO_USER_SEL                  0xA7
                // FAIL_LDT_FMT                                 0xA8
                status = H2SSDKSyncStatusFail;
                break;
        }
    }
    
    switch (deleSel) {
        case DELEGATE_SYNC: // Sync
            [self reportStatusAtSyncStage:status];
            break;
            
        case DELEGATE_PAIRING: // Pairing
            [self reportStatusAtPairingStage:status];
            break;
            
        case DELEGATE_DEVELOP: // Develop
            [self reportStatusAtDevelopStage:status];
            break;
            
        default:
            break;
    }
    
    if (isFlowEnding) {
        [self globalEndingProcess];
        [self h2SyncInfoReportProcess];
    }
}

#pragma mark - REPORT STATUS, SYNC, PAIRING, DEVELOP
- (void)reportStatusAtSyncStage:(UInt8)code
{
    H2SSDKSyncStatus status = code;
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateCableSyncStatus:)])
        {
            [self.libDelegate appDelegateCableSyncStatus:status];
        }
    }
}
- (void)reportStatusAtPairingStage:(UInt8)code
{
    H2SSDKPairStatus status = code;
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateCablePairingStatus:)])
        {
            [self.libDelegate appDelegateCablePairingStatus:status];
        }
    }
}

- (void)reportStatusAtDevelopStage:(UInt8)code
{
    H2SSDKDevelopStatus status = code;
    if ((status & 0xF0) == 0x20) {
        [H2SyncStatus sharedInstance].sdkFlowActive = NO;
    }
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateCableDevelop:)])
        {
            [self.libDelegate appDelegateCableDevelop:status];
        }
    }
}


#pragma mark - Cable Synchronous methods

- (void)h2InternalPreSync:(id)sender
{
    [H2SyncStatus sharedInstance].sdkFlowActive = YES;
    [H2AudioAndBleCommand sharedInstance].newRecordAtFinal = NO;
    [H2BleTimer sharedInstance].bleRecordModeForTimer = NO;
    
    [H2DataFlow sharedDataFlowInstance].cableFW = nil;
    [H2DataFlow sharedDataFlowInstance].cableSN = nil;
    
    [H2DataFlow sharedDataFlowInstance].cableUartStage = NO;
    
    for (int i=0; i<3; i++) {
        [H2SyncSystemMessageInfo sharedInstance].cmdSystemHeader[i] = 0x00;
        [H2SyncSystemMessageInfo sharedInstance].cmdBgmHeader[i] = 0x00;
    }
    
    [H2BleService sharedInstance].bleTempIdentifier = @"";
    [H2BleCentralController sharedInstance].didSkipBLE = NO;
   
    
    [JJBayerContour sharedInstance].goToNextYearStage = NO;
    [JJBayerContour sharedInstance].isSyncSecondStageRunning = NO;
    [JJBayerContour sharedInstance].isSyncSecondStageDidRemoved = NO;
    [H2SyncStatus sharedInstance].didMeterUartReady = NO;
    [H2SyncStatus sharedInstance].didReportFinished = NO;
    [H2SyncStatus sharedInstance].didReportSyncFail = NO;
    
    [H2AudioAndBleResendCfg sharedInstance];
    
    [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex = 0;
    [H2SyncSystemMessageInfo sharedInstance].syncInfoRocheNakTimes = 0;
    
    [H2CableParameter sharedInstance].sdkAndCableVersion = [_version libVersion];
    [H2CableParameter sharedInstance].sdkAndCableVersion = [[H2CableParameter sharedInstance].sdkAndCableVersion stringByAppendingString:@"  "];
    
    if ([H2BleService sharedInstance].isBleCable || [H2BleService sharedInstance].isBleEquipment) {
        [[H2BleCentralController sharedInstance] h2BleStart:nil];
#ifdef DEBUG_LIB
            DLog(@"BLE NORMAL START");
        if ([H2BleService sharedInstance].isBleEquipment) {
            DLog(@"DEBUG_LIB using VENDOR BLE DEV ...");
        }
#endif
    }else{
        [H2CableFlow sharedCableFlowInstance].cableTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                      target:self selector:@selector(openAudioFirstTime)
                                                    userInfo:nil repeats:NO];
    }
}


//////////////////////////////////////////////////////////////////////////////////
// record data Synchonous
#pragma mark -
#pragma mark Meter command methods START SYNCHRONOUS
- (void)appStartRecordSync:(id)sender
{
#ifdef DEBUG_LIB
    DLog(@"START SYNC ================ ******* ");
#endif
    if([H2SyncReport sharedInstance].didSyncRecordFinished) {
        // REPORT STATUS
        [self demoSdkSyncCableStatus:SUCCEEDED_OLD delegateCode:DELEGATE_SYNC];
        return;
    }
    [H2BleService sharedInstance].recordMode = YES;
    if ([H2DataFlow sharedDataFlowInstance].equipId & BLE_FLAG_MASK) {
        // Get Vendor Ble Record Here ...
        if ([H2BleService sharedInstance].bleDeleteRecords) {
            [[H2BleService sharedInstance] h2DeleteVendorRecords];
        }else{
            [[H2BleService sharedInstance] h2GetVendorRecord];
        }
        return;
    }
    
    if ([H2BleService sharedInstance].isBleCable) {
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
    }else{
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
    }
    
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES; // FOR TEST
    
    //
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = METER_NORMAL_RESEND_CYCLE;
    
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = SYSTEM_NORMAL_RESEND_INTERVAL;
    
    
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
    
    switch ([H2DataFlow sharedDataFlowInstance].equipUartProtocol) {
        case SM_ACCUCHEK_AVIVA:
        case SM_ACCUCHEK_PERFOMA:
        case SM_ACCUCHEK_AVIVANANO:
        case SM_ACCUCHEK_NANO:
            
        case SM_ACCUCHEK_PERFOMA_II:
        case SM_ACCUCHEK_EXT_5:
        case SM_ACCUCHEK_EXT_6:
        case SM_ACCUCHEK_EXT_7:
            
        case SM_ACCUCHEK_EXT_8:
        case SM_ACCUCHEK_EXT_9:
            [[H2RocheEventProcess sharedInstance] h2SyncAvivaReadRecord];
            break;
            
        case SM_ACCUCHEK_COMPACTPLUS:
        case SM_ACCUCHEK_ACTIVE:
            
        case SM_ACCUCHEK_EXT_C:
        case SM_ACCUCHEK_EXT_D:
        case SM_ACCUCHEK_EXT_E:
        case SM_ACCUCHEK_EXT_F:
            [[H2RocheEventProcess sharedInstance] h2SyncCompactPlusReadRecord];
            
            break;
            
            
        case SM_BAYER_BREEZE2:
        case SM_BAYER_CONTOUR:
        case SM_BAYER_CONTOURNEXTEZ:
        case SM_BAYER_CONTOURXT:
            
        case SM_BAYER_TS:
        case SM_BAYER_PLUS:
        case SM_BAYER_EXT_6:
        case SM_BAYER_EXT_7:
            
        case SM_BAYER_EXT_8:
        case SM_BAYER_EXT_9:
        case SM_BAYER_EXT_A:
        case SM_BAYER_EXT_B:
        case SM_BAYER_EXT_C:
        case SM_BAYER_EXT_D:
        case SM_BAYER_EXT_E:
        case SM_BAYER_EXT_F:
            [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = METER_BAYER_RESEND_INTERVAL;
            [JJBayerContour sharedInstance].didBayerSyncRunning = YES;
            [[H2BayerEventProcess sharedInstance] h2SyncBayerGeneral];
            break;
            
        case SM_CARESENS_ISENSN:
        case SM_CARESENS_ISENSNPOP:
            
        case SM_CARESENS_EXT_2:
        case SM_CARESENS_EXT_3:
        case SM_CARESENS_EXT_4:
        case SM_CARESENS_EXT_5:
        case SM_CARESENS_EXT_6:
            
            //        case SM_CARESENS_EXT_9:
            //        case SM_CARESENS_EXT_A:
            //        case SM_CARESENS_EXT_B:
        case SM_CARESENS_EXT_D:
        case SM_CARESENS_EXT_E:
        case SM_CARESENS_EXT_F:
            [[H2iCareSensEventProcess sharedInstance] h2SyncCareSensNReadRecord];
            break;
            
        case SM_CARESENS_EXT_9_BIONIME:
            [[H2iCareSensEventProcess sharedInstance] h2SyncBionimeReadRecord];
            break;
            
        case SM_CARESENS_EXT_A_HMD_GL:
            [[H2iCareSensEventProcess sharedInstance] h2SyncHmdReadRecord];
            break;
            
            
        case SM_CARESENS_EXT_7_TB200:
            //j            [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(h2SyncExtTysonRecord) userInfo:nil repeats:NO];
            break;
            
        case SM_CARESENS_EXT_8_EMBRACE_PRO:
            //            [h2CmdInfo sharedInstance].cmdCurrentMethod = METHOD_RECORD;
            [[H2iCareSensEventProcess sharedInstance] h2SyncEmbraceProReadRecord];
            break;
            
        case SM_CARESENS_EXT_B_FORA_GD40A:
            [[Fora sharedInstance] FORABleGetRecord];
            break;
            
        case SM_CARESENS_EXT_C_DSA:
            [[AllianceDSA sharedInstance] allianceCmdFlow:METHOD_RECORD];
            break;
            
        case SM_FREESTYLE_FREEDOMLITE:
        case SM_FREESTYLE_LITE:
            
        case SM_FREESTYLE_EXT_2:
        case SM_FREESTYLE_EXT_3:
        case SM_FREESTYLE_EXT_4:
        case SM_FREESTYLE_EXT_5:
        case SM_FREESTYLE_EXT_6:
        case SM_FREESTYLE_EXT_7:
            
        case SM_FREESTYLE_EXT_8:
        case SM_FREESTYLE_EXT_9:
        case SM_FREESTYLE_EXT_A:
        case SM_FREESTYLE_EXT_B:
        case SM_FREESTYLE_EXT_C:
        case SM_FREESTYLE_EXT_D:
        case SM_FREESTYLE_EXT_E:
        case SM_FREESTYLE_EXT_F:
            [H2AudioAndBleSync sharedInstance].recordIndex  = 1;
            [[H2FreeStyleEventProcess sharedInstance] h2SyncFreeStyleLiteGeneral];
#ifdef DEBUG_LIB
            DLog(@"DEBUG - FREE STYLE METHOD %02X",[H2AudioAndBleCommand sharedInstance].cmdMethod);
#endif
            
            break;
            
        case SM_GLUCOCARD_01:
        case SM_GLUCOCARD_VITAL:
            
        case SM_GLUCOCARD_EXT_2:
        case SM_GLUCOCARD_EXT_3:
        case SM_GLUCOCARD_EXT_4:
        case SM_GLUCOCARD_EXT_5:
        case SM_GLUCOCARD_EXT_6:
        case SM_GLUCOCARD_EXT_7:
            
        case SM_GLUCOCARD_EXT_8:
        case SM_GLUCOCARD_EXT_9:
        case SM_GLUCOCARD_EXT_A:
        case SM_GLUCOCARD_EXT_B:
        case SM_GLUCOCARD_EXT_C:
        case SM_GLUCOCARD_EXT_D:
        case SM_GLUCOCARD_EXT_E:
        case SM_GLUCOCARD_EXT_F:
        case SM_RELION_CONFIRM:
        case SM_RELION_PRIME:
            
        case SM_RELION_EXT_2:
        case SM_RELION_EXT_3:
        case SM_RELION_EXT_4:
        case SM_RELION_EXT_5:
        case SM_RELION_EXT_6:
        case SM_RELION_EXT_7:
            
        case SM_RELION_EXT_8:
        case SM_RELION_EXT_9:
        case SM_RELION_EXT_A:
        case SM_RELION_EXT_B:
        case SM_RELION_EXT_C:
        case SM_RELION_EXT_D:
        case SM_RELION_EXT_E:
        case SM_RELION_EXT_F:
            
            if ([GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode) {
                [[H2GlucoCardEventProcess sharedInstance] h2SyncGlucoCardVitalReadRecord];
            }else{
                [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = 2;
                [[H2GlucoCardEventProcess sharedInstance] h2SyncReliOnReadRecord];
            }
            
            break;
            
        case SM_ONETOUCH_ULTRA2:
        case SM_ONETOUCH_EXT_B:
        case SM_ONETOUCH_EXT_C:
        case SM_ONETOUCH_EXT_D:
        case SM_ONETOUCH_EXT_E:
        case SM_ONETOUCH_EXT_F:
            if ([H2DataFlow sharedDataFlowInstance].equipProtocolId == SM_ONETOUCH_ULTRA_) {
                // TO DO ...
                [[LSOneTouchUltra2 sharedInstance] UltraOldCommandLoop:0];
                [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            }else{
                if ([H2BleService sharedInstance].isBleCable) {
                    [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(h2SyncOneTouchUltra2ReadRecordAll) userInfo:nil repeats:NO];
                }else{
                    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = ULTRA2_RESEND_INTERVAL + 1.0f;
                    [[H2OneTouchEventProcess sharedInstance] h2SyncUltra2CmdTurnOnSwitch];
                }
            }
            break;
            
        case SM_ONETOUCH_ULTRA_VUE:
            [[LSOneTouchUltraVUE sharedInstance] UltraVueReadRecord:0];
            break;
            
        case SM_ONETOUCH_ULTRALIN:
        case SM_ONETOUCH_ULTRAMINI:
        case SM_ONETOUCH_ULTRAEASY:
            
        case SM_ONETOUCH_EXT_4:
        case SM_ONETOUCH_EXT_5:
        case SM_ONETOUCH_EXT_6:
        case SM_ONETOUCH_EXT_7:
            
        case SM_ONETOUCH_EXT_8:
        case SM_ONETOUCH_EXT_9:
            [[H2OneTouchEventProcess sharedInstance] h2SyncUltraMiniReadRecord];
            
            break;
            
            
            
            
        case SM_BENECHEK_PLUS_JET:
        case SM_BENECHEK_PT_GAMA:
        case SM_BENECHEK_EXT_2:
        case SM_BENECHEK_EXT_3:
        case SM_BENECHEK_EXT_4:
        case SM_BENECHEK_EXT_5:
        case SM_BENECHEK_EXT_6:
        case SM_BENECHEK_EXT_7:
            
        case SM_BENECHEK_EXT_8:
        case SM_BENECHEK_EXT_9:
        case SM_BENECHEK_EXT_A:
        case SM_BENECHEK_EXT_B:
        case SM_BENECHEK_EXT_C:
        case SM_BENECHEK_EXT_D:
        case SM_BENECHEK_EXT_E:
        case SM_BENECHEK_EXT_F:
            [[H2BeneChekEventProcess sharedInstance] h2SyncBeneChekReadRecord];
            break;
            
            
        case SM_OMNIS_EMBRACE:
            if ([H2ApexBioEventProcess sharedInstance].EmbraceOverLoading || [H2ApexBioEventProcess sharedInstance].EmbraceOverBleMode) {
                [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisCmdRecordAllCoef];
            }else{
                [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisCmdRecord];
            }
            break;
            
        case SM_OMNIS_EMBRACE_EVO:
            
        case SM_GLUCOSURE_VIVO:
        case SM_EVENCARE_G2:
        case SM_EVENCARE_G3:
        case SM_OMNIS_AUTOCODE:
        case SM_EXT_OMNIS6:
        case SM_APEX_BG001_C:
        //case SM_APEX_BGM014:
            [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisCmdRecord];
            break;
            
        case SM_Embrace_TOTAL:
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [H2CmdInfo sharedInstance].meterRecordCurrentIndex = 0;
            [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisCmdNumberOfRecordAll];
            return;
            break;
            
            
        default:
            break;
    }
    [[H2CableFlow sharedCableFlowInstance] h2CableMeterCommandPreProcess];
}



#pragma mark - SYNC MESSAGE PROCESS
- (void)h2SyncInfoReportProcess
{
    [H2SyncStatus sharedInstance].sdkFlowActive = NO;

    Byte *tmpHeader = (Byte *)malloc(SYNC_INFO_TEMP_BUFFER_SIZE);
    Byte *tmpSystemCommand = (Byte *)malloc(SYNC_INFO_TEMP_BUFFER_SIZE);
    Byte *tmpMeterCommand = (Byte *)malloc(SYNC_INFO_TEMP_BUFFER_SIZE);
    Byte *tmpGlobalBuffer = (Byte *)malloc(SYNC_INFO_TEMP_GLOBAL_BUFFER_LIMIT);
    unsigned char highByte;
    unsigned char lowByte;
    

    int mm=0, nn=0;
    
    for (int i = 0; i < SYNC_INFO_TEMP_BUFFER_SIZE; i++) {
        tmpHeader[i] = 0;
    }
    
    for (int i = 0; i < SYNC_INFO_TEMP_BUFFER_SIZE; i++) {
        tmpSystemCommand[i] = 0;
    }
    
    for (int i = 0; i < SYNC_INFO_TEMP_BUFFER_SIZE; i++) {
        tmpMeterCommand[i] = 0;
    }
    
    for (int i = 0; i < SYNC_INFO_TEMP_GLOBAL_BUFFER_LIMIT; i++) {
        tmpGlobalBuffer[i] = 0;
    }
    
    for (int i = 0; i < SYNC_INFO_TEMP_BUFFER_SIZE; i++) {
        [H2SyncSystemMessageInfo sharedInstance].syncInfoTempBuffer[i] = 0;
    }
    
    // TO DO ...
#ifdef DEBUG_LIB
    DLog(@"STATUS INDEX %02X", [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex);
    DLog(@"STATUS VALUE %02X", [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatus[0]);
#endif
    for (int i = 0; i <= [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex; i++) {
        highByte = ([H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatus[i] & 0xF0)>>4;
        lowByte  = [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatus[i] & 0x0F;
        [H2SyncSystemMessageInfo sharedInstance].syncInfoTempBuffer[3*i] = [[H2SyncReport sharedInstance] h2NumericToChar:highByte];
        [H2SyncSystemMessageInfo sharedInstance].syncInfoTempBuffer[3*i+1] = [[H2SyncReport sharedInstance] h2NumericToChar:lowByte];
        [H2SyncSystemMessageInfo sharedInstance].syncInfoTempBuffer[3*i+2] = 0x20;
    }
    
    unsigned char cmdHeader[12] = {0};
    memcpy(cmdHeader, [H2SyncSystemMessageInfo sharedInstance].cmdSystemHeader, 6);
    memcpy(&cmdHeader[6], [H2SyncSystemMessageInfo sharedInstance].cmdBgmHeader, 6);

    for (int i = 0; i < 12; i++) {
        highByte = (cmdHeader[i] & 0xF0)>>4;
        lowByte  = cmdHeader[i] & 0x0F;
        
        tmpHeader[3*i] = [[H2SyncReport sharedInstance] h2NumericToChar:highByte];
        tmpHeader[3*i+1] = [[H2SyncReport sharedInstance] h2NumericToChar:lowByte];
        tmpHeader[3*i+2] = 0x20;
    }
    

    for (int i = 0; i < [H2SyncSystemCommand sharedInstance].cmdLength; i++) {
        if ([H2SyncSystemCommand sharedInstance].cmdData[i] > 0x20 && [H2SyncSystemCommand sharedInstance].cmdData[i] < 0x7F) {
            memcpy(&tmpSystemCommand[mm + 3 * nn], &[H2SyncSystemCommand sharedInstance].cmdData[i], 1);
            mm++;
        }else{
            highByte = ([H2SyncSystemCommand sharedInstance].cmdData[i] & 0xF0)>>4;
            lowByte  = [H2SyncSystemCommand sharedInstance].cmdData[i] & 0x0F;
#ifdef DEBUG_LIB
            DLog(@"tmp system command %02X", highByte);
            DLog(@"tmp system command %02X", lowByte);
#endif
            tmpSystemCommand[mm + 3 * nn] = [[H2SyncReport sharedInstance] h2NumericToChar:highByte];
            tmpSystemCommand[mm + 3 * nn + 1] = [[H2SyncReport sharedInstance] h2NumericToChar:lowByte];
            tmpSystemCommand[mm + 3 * nn + 2] = 0x20;
            nn++;
        }
    }

    mm = 0;
    nn = 0;
    for (int i = 0; i < [H2SyncMeterCommand sharedInstance].cmdLength; i++) {
        if ([H2SyncMeterCommand sharedInstance].cmdData[i] >= 0x20 && [H2SyncMeterCommand sharedInstance].cmdData[i] < 0x7F) {
            memcpy(&tmpMeterCommand[mm + 3 * nn], &[H2SyncMeterCommand sharedInstance].cmdData[i], 1);
            mm++;
        }else{
            highByte = ([H2SyncMeterCommand sharedInstance].cmdData[i] & 0xF0)>>4;
            lowByte  = [H2SyncMeterCommand sharedInstance].cmdData[i] & 0x0F;
            
            tmpMeterCommand[mm + 3 * nn] = [[H2SyncReport sharedInstance] h2NumericToChar:highByte];
            tmpMeterCommand[mm + 3 * nn + 1] = [[H2SyncReport sharedInstance] h2NumericToChar:lowByte];
            tmpMeterCommand[mm + 3 * nn + 2] = 0x20;
            nn++;
        }
    }
    
    mm = 0;
    nn = 0;
    
    for (int i = 0; i < [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex; i++) {
        if (i >= (SYNC_INFO_TEMP_GLOBAL_BUFFER_LIMIT/4 - 2)) {
            break;
        }
        if ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[i] > 0x20 && [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[i] < 0x7F) {
            memcpy(&tmpGlobalBuffer[mm + 3 * nn], &[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[i], 1);
            mm++;
        }else{
            highByte = ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[i] & 0xF0)>>4;
            lowByte  = [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[i] & 0x0F;
#ifdef DEBUG_LIB
            DLog(@"tmp system command %02X", highByte);
            DLog(@"tmp system command %02X", lowByte);
#endif
            tmpGlobalBuffer[mm + 3 * nn] = [[H2SyncReport sharedInstance] h2NumericToChar:highByte];
            tmpGlobalBuffer[mm + 3 * nn + 1] = [[H2SyncReport sharedInstance] h2NumericToChar:lowByte];
            tmpGlobalBuffer[mm + 3 * nn + 2] = 0x20;
            nn++;
        }
    }
    
    // Device current Time
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *devCurrentTimeString = [timeFormatter stringFromDate: currentTime];
    
    NSDictionary *syncInfoMessage =
    @{
        @"syncInfoCableStatus":[NSString stringWithUTF8String:(const char *)[H2SyncSystemMessageInfo sharedInstance].syncInfoTempBuffer],
        @"syncInfoBatteryValue":[NSString stringWithFormat:@"0x%04X",[H2BleService sharedInstance].batteryRawValue],
        @"syncInfoAudioDetect":[NSString stringWithFormat:@"%@", [H2SyncSystemMessageInfo sharedInstance].syncInfoAudioStatus],
        @"syncInfoRocheNakTimes":[NSString stringWithFormat:@"%03d",[H2SyncSystemMessageInfo sharedInstance].syncInfoRocheNakTimes],
        @"syncInfoSystemCommandBuffer":[NSString stringWithUTF8String:(const char *)tmpSystemCommand],
        @"syncInfoMeterCommandBuffer":[NSString stringWithUTF8String:(const char *)tmpMeterCommand],
        @"syncInfoCurrentCommandHeader":[NSString stringWithUTF8String:(const char *)tmpHeader],
        @"syncInfoCurrentGlobalBuffer":[NSString stringWithUTF8String:(const char *)tmpGlobalBuffer],
      
        @"syncInfoMeterBrand":[H2SyncReport sharedInstance].reportMeterInfo.smBrandName,
        @"syncInfoMeterModel":[H2SyncReport sharedInstance].reportMeterInfo.smModelName,
        @"syncInfoMeterSerialNumber":[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber,
        @"syncInfoMeterVersion":[H2SyncReport sharedInstance].reportMeterInfo.smVersion,
        
        @"syncInfoOmronCmd":[H2Omron sharedInstance].omronCmdLogArray,
        @"syncInfoOmronValue":[H2Omron sharedInstance].omronValueLogArray,
        
        @"syncInfoTime1":[NSString stringWithFormat:@"CellPhoneTime:%@, EquipmentTime:%@",devCurrentTimeString ,[H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime],
        
        @"syncInfoTime2":[NSString stringWithFormat:@"BgLastDateTime:%@, BpLastDateTime:%@, BwLastDateTime:%@",[H2SyncReport sharedInstance].serverBgLastDateTime ,[H2SyncReport sharedInstance].serverBpLastDateTime ,[H2SyncReport sharedInstance].serverBwLastDateTime],

        @"syncInfoSdkAndFWVer":[NSString stringWithFormat:@"%@ %@",[H2CableParameter sharedInstance].sdkAndCableVersion, [H2DataFlow sharedDataFlowInstance].cableSN],
#ifdef DEBUG_LIB
        @"syncInfoRSSIAvage":[NSString stringWithFormat:@"RSSI:%02d", [H2BleCentralController sharedInstance].rssiValueAvage],
#endif
        @"syncMeterId":[NSString stringWithFormat:@"%08X", (unsigned int)[H2DataFlow sharedDataFlowInstance].equipId],
        @"syncBleLocalName":[NSString stringWithFormat:@"REAL:%@, TMP:%@", [H2BleService sharedInstance].bleLocalName, [H2BleService sharedInstance].bleTempLocalName],
        @"syncUserIDAndEmail": [NSString stringWithFormat:@"ID:%@, EMAIL:%@",[H2SyncReport sharedInstance].userIdentifier,[H2SyncReport sharedInstance].userEMail]
    };
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(debugMessageForUsers:)])
        {
            [self.libDelegate debugMessageForUsers:syncInfoMessage];
        }
    }
}







- (void)h2CableBLEDelayTurnOffSW
{
    [H2BleCentralController sharedInstance].didSkipBLE = NO;
    [[H2CableFlow sharedCableFlowInstance] h2SyncTurnOffSwitch];
#ifdef DEBUG_LIB
    DLog(@"CABLE DELAY TURN OFF SW");
#endif
}

- (void)receivedDataFromOthers
{
    if ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN] == 0x07) {
        return;
    }
}


#pragma mark - FW UPDATE AREA

- (UInt8)demoAppOadUpDateFlash:(unsigned char *)buffer withSerialNumber:(NSString *)sn withUserID:(NSString *)userID andUserEmail:(NSString *)userEmail
{
    UInt16 crc = 0;
    UInt16 crcShadow = 0;
    UInt16 ver = 0;
    UInt16 len = 0;
#ifdef DEBUG_LIB
    DLog(@"FW UPDATE AREA ...");
#endif
    
    memcpy([H2BleOad sharedInstance].header, buffer, OAD_HEADER_LEN);
    memcpy([H2BleOad sharedInstance].imgBuffer, buffer, OAD_BUFFER_SIZE);
    
    memcpy(&crc, [H2BleOad sharedInstance].imgBuffer, 2);
    memcpy(&crcShadow, [H2BleOad sharedInstance].imgBuffer+2, 2);
    memcpy(&ver, [H2BleOad sharedInstance].imgBuffer+4, 2);
    memcpy(&len, [H2BleOad sharedInstance].imgBuffer+6, 2);
    
    [H2BleService sharedInstance].bleSeverIdentifier = @"";
    [H2BleService sharedInstance].bleScanningKey = @"";
    
    if (sn == nil) {
        [H2BleService sharedInstance].bleScanningKey = @"";
    }else{
        [H2BleService sharedInstance].bleScanningKey = sn;
    }
    
    if ([H2BleCentralController sharedInstance].h2CentralManager == nil) {
        [[H2BleCentralController sharedInstance] h2CentralManagerAlloc];
    }
    
#ifdef DEBUG_LIB
    DLog(@"x DEBUG_OAD CRC is            %04X\n", crc);
    DLog(@"x DEBUG_OAD CRC SHARDOW is    %04X\n", crcShadow);
    DLog(@"x DEBUG_OAD VER is            %04X\n", ver);
    DLog(@"x DEBUG_OAD data length is    %04X\n", len);
    DLog(@"x DEBUG_OAD HEADER 1 is %02X %02X %02X %02X\n", [H2BleOad sharedInstance].imgBuffer[0], [H2BleOad sharedInstance].imgBuffer[1], [H2BleOad sharedInstance].imgBuffer[2], [H2BleOad sharedInstance].imgBuffer[3]);
    DLog(@"DEBUG_OAD HEADER 2 is %02X %02X %02X %02X\n", [H2BleOad sharedInstance].imgBuffer[4], [H2BleOad sharedInstance].imgBuffer[5], [H2BleOad sharedInstance].imgBuffer[6], [H2BleOad sharedInstance].imgBuffer[7]);
    
    DLog(@"DEBUG_OAD ID is %02X %02X %02X %02X\n", [H2BleOad sharedInstance].imgBuffer[8], [H2BleOad sharedInstance].imgBuffer[9], [H2BleOad sharedInstance].imgBuffer[10], [H2BleOad sharedInstance].imgBuffer[11]);
    DLog(@"DEBUG_OAD ID SHADOW is %02X %02X %02X %02X\n", [H2BleOad sharedInstance].imgBuffer[12], [H2BleOad sharedInstance].imgBuffer[13], [H2BleOad sharedInstance].imgBuffer[14], [H2BleOad sharedInstance].imgBuffer[15]);
#endif
    [[H2BleCentralController sharedInstance] h2BleStart:nil];
#ifdef DEBUG_LIB
    DLog(@"DEBUG_OAD START ...");
#endif
    return 0;
}


- (void)sdkBleDeviceList:(NSMutableArray *)blePeripherals;
{
#ifdef DEBUG_LIB
    DLog(@"H2 DEBUG Call listing BLE dev %d ", (int)[blePeripherals count]);
#endif
    [H2SyncStatus sharedInstance].sdkFlowActive = NO;
    if ([H2BleService sharedInstance].blePairingModeFinished) {
        return;
    }
    [H2BleService sharedInstance].blePairingModeFinished = YES;
    BOOL bleNotFound = NO;
    NSMutableArray *bleDevicesTmp = [[NSMutableArray alloc] init];
    if ([blePeripherals count] > 0) {
        for (ScannedPeripheral *sensor in blePeripherals) {
            if (![sensor.name isEqualToString:@""]) {
                [bleDevicesTmp addObject:sensor];
            }
        }
        if ([bleDevicesTmp count] == 0) {
            bleNotFound = YES;
        }
    }else{
        bleNotFound = YES;
    }
    if (bleNotFound) {
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:FAIL_BLE_NOT_FOUND delegateCode:DELEGATE_PAIRING];
    }else{
        @autoreleasepool {
            if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
                [self.libDelegate respondsToSelector:@selector(appDelegateBleDevicesHaveFound:)])
            {
                [self.libDelegate appDelegateBleDevicesHaveFound:bleDevicesTmp];
#ifdef DEBUG_LIB
                DLog(@"H2 DEBUG BLE DEV LIST ");
#endif
            }
        }
    }
}

- (void)sdkOadWriteProgress:(UInt16)deno withFraction:(UInt16)fraction;
{
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateOadWriteStatus:withFraction:)])
        {
            [self.libDelegate appDelegateOadWriteStatus:deno withFraction:fraction];
#ifdef DEBUG_LIB
            DLog(@"OAD INTERNAL PROGRESS .... 00 ");
#endif
        }
    }
}



- (BOOL)demoDidAudioHeadsetPluggedIn
{
    return [H2AudioSession isHeadsetPluggedIn];
}

#pragma mark - SDK Send Notify
- (NSDictionary *)h2BlePeripheralToDictionary
{
    if ([[H2BleService sharedInstance].bleTempIdentifier isEqualToString:@""]) {
        return nil;
    }
    NSDictionary *blePeripheral = nil;
    NSString *bleName = @"";
    if ([H2BleService sharedInstance].h2ConnectedPeripheral != nil) {
        bleName = [H2BleService sharedInstance].h2ConnectedPeripheral.name;
        blePeripheral = @{@"BT_NAME" : bleName, @"BT_IDENTIFIER" :[H2BleService sharedInstance].bleTempIdentifier};
    }
    
#ifdef DEBUG_LIB
    DLog(@"BLE PERIPHERAL TO DICT .... %@ ", [H2BleService sharedInstance].h2ConnectedPeripheral.name);
#endif
    return blePeripheral;
}

- (void)appAudioHideVolumeIcon:(UIView *)firstView
{
    [firstView addSubview:[H2AudioSession sharedInstance].gh2VolumeView];
}



- (void)h2ZeroRecordTest:(BOOL)zeroRecord{
    [H2SyncDebug sharedInstance].zeroRecord = zeroRecord;
}




#pragma mark - ============== NEW FOR MULTI USER AND DATA TYPE ==============
#pragma mark - NEW APP FUNCTION
- (UInt8)appGlobalPreSync:(H2PackageForSync *)packageForSync
{
    H2PackageForSync *tmpPackage = [[H2PackageForSync alloc] init];
    tmpPackage = packageForSync;
    
    BOOL funcSelErr = NO;
    BOOL dataTagErr = NO;
    BOOL dataTypeErr = NO;
    
    BOOL bleSync = NO;
    
#ifdef DEBUG_LIB
    DLog(@"NEW SYNC METHOD ... %@ == %@", tmpPackage, packageForSync);
    DLog(@"NEW SYNC METHOD ...  UID %02X == %02X", tmpPackage.userTagInMeter,packageForSync.userTagInMeter);
    DLog(@"NEW SYNC METHOD ... TYPE %02X == %02X", tmpPackage.recordTypeInMeter, packageForSync.recordTypeInMeter);
#endif
    
    [H2Omron sharedInstance].tmpUserProfile = packageForSync.userProfile;
    if ([H2SyncStatus sharedInstance].sdkFlowActive) {
        switch (tmpPackage.interfaceTask) {
            case BLE_CABLE_PAIRING:
            case BLE_EQUIP_PAIRING:
                [self demoSdkSyncCableStatus:H2SSDKPairStatusSdkFlowBusy delegateCode:DELEGATE_PAIRING];
                break;
                
            default:
                [self demoSdkSyncCableStatus:H2SSDKSyncStatusSdkFlowBusy delegateCode:DELEGATE_SYNC];
                break;
        }
        return H2SSDKPairStatusSdkFlowBusy;
    }
    
    [self sdkSyncInit];
    
#ifdef DEBUG_LIB
    DLog(@"G-UPF ... UID = %02X", [H2Omron sharedInstance].tmpUserProfile.uTag);
    DLog(@"G-UPF ... 生日 年 =%d", [H2Omron sharedInstance].tmpUserProfile.uBirthYear);
    DLog(@"G-UPF ... 生日 月 = %d", [H2Omron sharedInstance].tmpUserProfile.uBirthMonth);
    DLog(@"G-UPF ... 生日 日 = %d", [H2Omron sharedInstance].tmpUserProfile.uBirthDay);
    DLog(@"G-UPF ... 性別 %d", [H2Omron sharedInstance].tmpUserProfile.uGender);
    DLog(@"G-UPF ... 身高 : %d", [H2Omron sharedInstance].tmpUserProfile.uBodyHeight);
#endif
    
    [H2BleService sharedInstance].bleSeverIdentifier = tmpPackage.bleIdentifier;
    [H2BleService sharedInstance].bleScanningKey = tmpPackage.bleScanningKey;

#ifdef DEBUG_LIB
    DLog(@"GLOBAL SN ... %@, and %@", [H2BleService sharedInstance].bleScanningKey, tmpPackage.bleScanningKey);
#endif
    // LDT ARRAY
    [H2BayerEventProcess sharedInstance].serverSrcLastDateTimes = [[NSMutableArray alloc] initWithArray:tmpPackage.serverLastDateTimeArray];

    [H2SyncReport sharedInstance].userEMail = tmpPackage.uEMailStringFromRegister;
    [H2SyncReport sharedInstance].userIdentifier = tmpPackage.uIDStringFromRegister;
    
    // EQUIPMENT USER ID AND DATA TYPE
    [H2Records sharedInstance].dataTypeFilter = tmpPackage.recordTypeInMeter;
    [H2Records sharedInstance].equipUserIdFilter = tmpPackage.userTagInMeter;
    
    [H2Omron sharedInstance].recordTypeFilter = [H2Records sharedInstance].dataTypeFilter;
    [H2Omron sharedInstance].userIdFilter = [H2Records sharedInstance].equipUserIdFilter;
    
    [H2DataFlow sharedDataFlowInstance].equipId = packageForSync.equipCode;
    
    [H2DataFlow sharedDataFlowInstance].equipProtocolId = [H2DataFlow sharedDataFlowInstance].equipId & GPROTOCOL_MASK;
    
    [H2DataFlow sharedDataFlowInstance].equipUartProtocol = [H2DataFlow sharedDataFlowInstance].equipId  & UART_PROTOCOL_MASK;
    
    if ([H2DataFlow sharedDataFlowInstance].equipProtocolId == 0) {
        if (tmpPackage.interfaceTask != BLE_CABLE_PAIRING) {
            [self demoSdkSyncCableStatus:H2SSDKDevlopStatusMeterID delegateCode:DELEGATE_DEVELOP];
            //return FAIL_EQUIPID_IF;
            return H2SSDKDevlopStatusMeterID;
        }
    }
    
    if ([H2DataFlow sharedDataFlowInstance].equipProtocolId & BLE_FLAG_MASK) {
         [H2BleService sharedInstance].isBleEquipment = YES;
    }
    
    if ([H2DataFlow sharedDataFlowInstance].equipId & BLE_MULTI_USERS) {
        [H2Records sharedInstance].multiUsers = YES;
    }
    
#ifdef DEBUG_LIB
    DLog(@"IF Function %02x", tmpPackage.interfaceTask);
#endif
    
    // Error Handling 0. INTERFACE ERROR
    // INTERFACE VS EQUIP_ID
    switch (tmpPackage.interfaceTask) {
        case AUDIO_CABLE_SYNC:
        case BLE_CABLE_SYNC:
        case BLE_CABLE_PAIRING:
        case OAD_UPDATE:
            if ([H2BleService sharedInstance].isBleEquipment) {
                funcSelErr = YES;
            }
            break;
            
        case BLE_EQUIP_SYNC:
        case BLE_EQUIP_PAIRING:
            if (![H2BleService sharedInstance].isBleEquipment) {
                funcSelErr = YES;
            }
            break;
            
            default:
            break;
    }
    if(funcSelErr){
        [self demoSdkSyncCableStatus:FAIL_EQUIPID_IF delegateCode:DELEGATE_DEVELOP];
        return FAIL_EQUIPID_IF;
    }
    
    // USER ID FILTER CHECKING
    switch (tmpPackage.interfaceTask) {// DATA TYPE ERROR
        case AUDIO_CABLE_SYNC:
        case BLE_CABLE_SYNC:
        case BLE_EQUIP_SYNC:
            if ([H2Records sharedInstance].equipUserIdFilter == 0){
                dataTagErr = YES;
            }
            if ([H2Records sharedInstance].equipUserIdFilter >= USER_MAX_6) {
                // max uset tage 0x10
                dataTagErr = YES;
            }
            if ([self dataTypeChecking:[H2Records sharedInstance].dataTypeFilter]) {
                dataTypeErr = YES;
            }
            break;
            
        default:
            break;
    }
    
    if(![H2Records sharedInstance].multiUsers){
        if ([H2Records sharedInstance].equipUserIdFilter >= USER_MAX_2) {
            dataTagErr = YES;
        }
    }
    
    // Four Users
    if([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HBF_254C || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HBF_256T || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_CARESENS_EXT_B_FORA_D40){
        if ([H2Records sharedInstance].equipUserIdFilter >= USER_MAX_5) {
            dataTagErr = YES;
        }
    }
    
    // Two Users
    if([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_7280T || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6324T){
        if ([H2Records sharedInstance].equipUserIdFilter >= USER_MAX_3) {
            dataTagErr = YES;
        }
    }
    
    if(dataTagErr){
        [self demoSdkSyncCableStatus:H2SSDKDevlopStatusUserTag delegateCode:DELEGATE_DEVELOP];
        return H2SSDKDevlopStatusUserTag;
    }
    
    if(dataTypeErr){
        [self demoSdkSyncCableStatus:H2SSDKDevlopStatusDataType delegateCode:DELEGATE_DEVELOP];
        return H2SSDKDevlopStatusDataType;
    }
    bleNormalConnect = YES;
    switch (tmpPackage.interfaceTask) {
        case AUDIO_CABLE_SYNC:
            [H2AudioHelper sharedInstance].audioMode = YES;
            _isAudioCable = [H2AudioSession isHeadsetPluggedIn];
            if (!_isAudioCable) {
                [[H2AudioSession sharedInstance] resetAudioSession];
#ifdef DEBUG_LIB
                DLog(@"AUDIO-FAIL --> NOT AUDIO CABLE");
#endif
                [self demoSdkSyncCableStatus:H2SSDKSyncStatusCableNotFound delegateCode:NO];
                return H2SSDKSyncStatusCableNotFound;
            }
            [H2BleService sharedInstance].isAudioSyncFlow = YES;
            [H2BleCentralController sharedInstance].h2CentralManager = nil;
            [H2BleCentralController sharedInstance].bleCentralPowerOn = NO;
            [self h2InternalPreSync:nil];
            return 0;
            
        case BLE_CABLE_SYNC:
            bleSync = YES;
            [H2BleService sharedInstance].isBleCable = YES;
#ifdef DEBUG_LIB
            DLog(@"NEW SYNC METHOD ... BLE CABLE SYNC");
#endif
            break;
            
            
        case BLE_DEL_RECORDS:
            [H2BleService sharedInstance].bleDeleteRecords = YES;
        case BLE_EQUIP_SYNC:
            bleSync = YES;
#ifdef DEBUG_LIB
            DLog(@"NEW SYNC METHOD ... EQUIPMENT SYNC");
#endif
            break;
            
        case BLE_CABLE_PAIRING:
            [H2BleService sharedInstance].isBleCable = YES;
            [H2BleService sharedInstance].bleCablePairing = YES;
#ifdef DEBUG_LIB
            DLog(@"NEW SYNC METHOD ... BLE CABLE PAIRING");
#endif
            break;
            
        case BLE_EQUIP_PAIRING:
            [H2BleService sharedInstance].blePairingStage = YES;
            [H2Omron sharedInstance].setUserIdMode = YES;
#ifdef DEBUG_LIB
            DLog(@"NEW SYNC METHOD ... BLE EQUIPMENT PAIRING");
#endif
            break;
            
        case OAD_UPDATE:
            bleSync = YES;
            [H2BleService sharedInstance].isBleCable = YES;
            [H2BleOad sharedInstance].oadMode = YES;
            break;
            
        default:
            break;
    }
    
    if ([H2BleService sharedInstance].isBleCable) {
        if ([[H2BleService sharedInstance].bleScanningKey length] < BLE_CABLE_SN_LEN) { // H Q 1 6 0 2 T B 123456
            [self demoSdkSyncCableStatus:H2SSDKDevlopStatusBLECableSN delegateCode:DELEGATE_DEVELOP];
            return H2SSDKDevlopStatusBLECableSN;
        }
    }
    
    if ([H2BleService sharedInstance].isBleCable || [H2BleService sharedInstance].isBleEquipment) {
        if ([H2BleCentralController sharedInstance].h2CentralManager == nil) {
            [[H2BleCentralController sharedInstance] h2CentralManagerAlloc];
        }
    }
    
    if ([H2DataFlow sharedDataFlowInstance].equipId & BLE_NEED_PAIR_DIALOG) {
        [H2BleService sharedInstance].didNeedMoreTimeForBlePairing = YES;
    }else{
        switch ([H2DataFlow sharedDataFlowInstance].equipId) {
            case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
            case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
            case SM_BLE_ACCUCHEK_INSTANT:
            case SM_BLE_BGM_TRUE_METRIX:
            case SM_BLE_BGM_TYSON_HT100:
            case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
            case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
                [H2BleService sharedInstance].didNeedMoreTimeForBlePairing = YES;
                break;
                
            default:
                break;
        }
    }
    
    if (bleSync) {
        if ([[H2BleService sharedInstance].bleScanningKey isEqualToString:@""] || [H2BleService sharedInstance].bleScanningKey == nil) {
            [self demoSdkSyncCableStatus:H2SSDKDevlopStatusBLECableSN delegateCode:DELEGATE_DEVELOP];
            return H2SSDKDevlopStatusBLECableSN;
        }
        
        [[H2CableFlow sharedCableFlowInstance] bleSyncInitTask:[H2BleService sharedInstance].bleSeverIdentifier];
        [self h2InternalPreSync:nil];
        return 0;
    }
    
    if ([H2BleService sharedInstance].blePairingStage || [H2BleService sharedInstance].bleCablePairing) {
        switch ([H2DataFlow sharedDataFlowInstance].equipId) {
            case SM_BLE_CARESENS_EXT_B_FORA:
            case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
            case SM_BLE_CARESENS_EXT_B_FORA_TNG:
            case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
            case SM_BLE_CARESENS_EXT_B_FORA_D40:
            case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
                //case SM_BLE_CARESENS_EXT_C_BTM:
                [H2BleService sharedInstance].bleScanMultiDevice = YES;
                [H2BleService sharedInstance].bleScanDeviceMax = BLE_MAX_COUNT;
                break;
                
            default:
                break;
        }
        [H2SyncStatus sharedInstance].sdkFlowActive = YES;
        [[H2BleCentralController sharedInstance] h2BleStart:nil];
        return 0;
    }
    return 0;
}

- (void)appTerminateBleFlow
{
    [[H2BleCentralController sharedInstance] h2BleCentralCanncelConnectForVendor];
}


- (void)sdkSyncInit
{
    for (int i=0; i<48; i++) {
        [H2SyncSystemCommand sharedInstance].cmdData[i] = 0;
        [H2SyncMeterCommand sharedInstance].cmdData[i] = 0;
    }
    
    _isAudioCable = NO;
    [H2AudioHelper sharedInstance].audioMode = NO;
    [Fora sharedInstance].foraFinished = NO;
    [H2Records sharedInstance].currentUser = 0;
    [H2Records sharedInstance].multiUsers = NO;
    
    [H2BleService sharedInstance].isBleCable = NO;
    [H2BleService sharedInstance].bleCablePairing = NO;
    [H2BleService sharedInstance].isBleEquipment = NO;
    [H2BleService sharedInstance].recordMode = NO;
    [H2BleService sharedInstance].isAudioSyncFlow = NO;
    
    [H2BleService sharedInstance].bleSerialNumberMode = NO;
    [H2BleService sharedInstance].normalFlowHasNofity = NO;
    
    [H2BleService sharedInstance].blePeripheralIdle = NO;
    
    //[OneTouchPlusFlex sharedInstance].rocheSetting = NO;
    [H2BleOad sharedInstance].oadMode = NO;
    [H2Omron sharedInstance].dialogWillAppear = NO;
    [H2Omron sharedInstance].setUserIdMode = NO;
    [H2Omron sharedInstance].a0NotifyYES = NO;
    [H2Omron sharedInstance].isHem7600TOrHbf = NO;
    
    if ([H2Omron sharedInstance].omronCmdLogArray.count > 0) {
        [[H2Omron sharedInstance].omronCmdLogArray removeAllObjects];
    }
    if ([H2Omron sharedInstance].omronValueLogArray.count > 0) {
        [[H2Omron sharedInstance].omronValueLogArray removeAllObjects];
    }
    
    [H2SyncStatus sharedInstance].cableSyncStop = NO;
    
    [ArkrayGBlack sharedInstance].arkrayShowDialog = NO;
    [ArkrayGBlack sharedInstance].arkraySyncPhs = NO;
    [ArkrayGBlack sharedInstance].arkrayActive = NO;
    
    [ArkrayGBlack sharedInstance].arkrayTmpIdString = @"";
    [ArkrayGBlack sharedInstance].arkrayDynamicCmd = 0;
    
    [H2BleService sharedInstance].didNeedMoreTimeForBlePairing = NO;
    
    [H2BleService sharedInstance].blePairingStage = NO;
    [H2BleService sharedInstance].bleSerialNumberStage = NO;
    
    [H2BleService sharedInstance].bleDevInList = NO;
    [H2BleService sharedInstance].bleConnected = NO;
    [H2BleService sharedInstance].bleNormalDisconnected = NO;
    [H2BleService sharedInstance].bleErrorHappen = NO;
    
    
    [H2BleService sharedInstance].reconnectPeripheral = nil;
    [H2BleService sharedInstance].bleDeleteRecords = NO;
    
    [H2Records sharedInstance].bgCableSyncFinished = NO;
    [H2CableParameter sharedInstance].didFinishedVersionCmd = NO;
    
    [H2BleService sharedInstance].batteryLevel = -1;
    [H2BleService sharedInstance].batteryRawValue = 0;
    
    [H2BleService sharedInstance].blePairingModeFinished = NO;
    [H2BleService sharedInstance].bleMultiDeviceCanncel = NO;
    [H2BleService sharedInstance].bleScanMultiDevice = NO;
    [H2BleService sharedInstance].bleScanDeviceMax = 1;
    [H2BleService sharedInstance].bleScanDeviceCount = 0;
    
    [H2BleService sharedInstance].bleLocalName = @"";
    [H2BleService sharedInstance].bleTempLocalName = @"";
    
    [OMRON_HEM_9200T sharedInstance].hem9200tSerialNumberDone = NO;
    [OMRON_HEM_9200T sharedInstance].hem9200tCurrentTimeDone = NO;
    
    [Fora sharedInstance].syncStart = NO;
    [ForaD40 sharedInstance].foraD40Finished = NO;
    [ForaD40 sharedInstance].foraD40BgFinished = NO;
    [ForaD40 sharedInstance].foraD40BpFinished = NO;
    [H2DataFlow sharedDataFlowInstance].sdkActivity = NO;
    
    [H2SyncReport sharedInstance].cableBayerLastDateTime = DEF_LAST_DATE_TIME;
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = DEF_LAST_DATE_TIME;
    [H2SyncReport sharedInstance].didSyncRecordFinished = NO;
    [H2SyncReport sharedInstance].tmpDateTimeForVue = @"";
    [H2SyncReport sharedInstance].didEquipInfoDone = NO;
    
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = @"";
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = @"";
    
    // GENERAL REPORT INDEX INIT
    [H2SyncReport sharedInstance].h2BgRecordReportIndex = 0;
    [H2SyncReport sharedInstance].h2BpRecordReportIndex = 0;
    [H2SyncReport sharedInstance].h2BwRecordReportIndex = 0;
    
    [H2SyncReport sharedInstance].bgHasBeenSkip = 0;
    [H2SyncReport sharedInstance].bpHasBeenSkip = 0;
    [H2SyncReport sharedInstance].bwHasBeenSkip = 0;
    
    [H2BleService sharedInstance].didBleCableFinished = NO;
    [H2SyncStatus sharedInstance].didReportFinished = NO;
    
    // RECORD BUFFER INIT
    if ([[H2SyncReport sharedInstance].h2BgRecordReportArray count] > 0) {
        [[H2SyncReport sharedInstance].h2BgRecordReportArray removeAllObjects];
    }
    if ([[H2SyncReport sharedInstance].h2BpRecordReportArray count] > 0) {
        [[H2SyncReport sharedInstance].h2BpRecordReportArray removeAllObjects];
    }
    if ([[H2SyncReport sharedInstance].h2BwRecordReportArray count] > 0) {
        [[H2SyncReport sharedInstance].h2BwRecordReportArray removeAllObjects];
    }
    
    // LDT ARRAY INIT
    if ([[H2SyncReport sharedInstance].h2MultableLastDateTime count] > 0) {
        [[H2SyncReport sharedInstance].h2MultableLastDateTime removeAllObjects];
    }
    
    
    // H2 BLE BGM INIT
    [H2BleBgm sharedInstance].willFinished = NO;
    //[H2BleBgm sharedInstance].cmdSegmentForTyson = 1;
}


#pragma mark - REPORT EQUIPMENT INFO and BUILD SVR LDT
- (void)sdkEquipInfoProcess:(UInt8)dataTypeFilter withSvrUserId:(UInt8)userIdFilter
{

#ifdef DEBUG_LIB
    DLog(@"BEFORE NEW RECORDS \n%@", [H2Records sharedInstance].H2RecordsArray);
#endif
    [[H2Records sharedInstance] resetRecordsArray];
#ifdef DEBUG_LIB
    DLog(@"AFTER NEW RECORDS \n%@", [H2Records sharedInstance].H2RecordsArray);
#endif
    [[H2SvrLastDateTime sharedInstance] h2InitTimeAndIndexFromServer];
    [H2SyncReport sharedInstance].reportMeterInfo.smWantToReadRecord = YES;
#ifdef DEBUG_LIB
    DLog(@"REPORT EQUIPMENT INFO");
#endif
    
    if ([[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber isEqualToString:@""]) {
        // Meter that has no Serial Number
#ifdef DEBUG_LIB
        DLog(@"BG BP BW SN - EMPTY ###");
#endif
        [H2SyncReport sharedInstance].serverBgLastDateTime = DEF_LAST_DATE_TIME;//@"1970-01-01 00:00:00 +0000";
    }else{
#ifdef DEBUG_LIB
        DLog(@"LIB UPDATE SVR - BG BP BW - WITH SN ### %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
        DLog(@"LDT FILTER d-TYPE %02X and u-TYPE %02X", dataTypeFilter, userIdFilter);
#endif
        for (int i=0; i<3; i++) { // TYPE LOOP
            if (dataTypeFilter & (1 << i)) {
                for (int k=0; k<5; k++) { // USER ID LOOP
                    if (userIdFilter & (1 << k)) {
                        // TO DO ...
#ifdef DEBUG_LIB
                        DLog(@"LDT for LIB %d and %d", i, k);
#endif
                        if(![self svrNewLastDateTimeProcess:i withUid:k])
                        {
                            return;
                        }
                    }
                }
            }
        }
    }
 
#ifdef DEBUG_LIB
    DLog(@"LIB  SHOW SVR LDT ---");
    NSArray *typeArray = 0;
    for (int i=0; i<3; i++) {
        typeArray = [[H2SvrLastDateTime sharedInstance].totalSvrLastDateTime objectAtIndex:i];
        for (NSString *ldt in typeArray) {
            DLog(@"LIB-SVR LDT =  %@", ldt);
        }
    }
#endif
    
    BOOL needGetCurrentLdtFromServer = NO;
    
    // Cable Meter, accu-connect, fora GD40B, URight
    if ([H2DataFlow sharedDataFlowInstance].equipId < 0x00010000) {
        [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
        needGetCurrentLdtFromServer = YES;
    }
    
    // Ble Meter, Single User Tag
    if (!([H2DataFlow sharedDataFlowInstance].equipId & BLE_MULTI_USERS)) {
        if ([H2DataFlow sharedDataFlowInstance].equipId & BLE_BG_EQUIP) {
            [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
            needGetCurrentLdtFromServer = YES;
        }
        
    }
    
    if ( needGetCurrentLdtFromServer) {
        [H2Records sharedInstance].currentUser = 0;
        [H2SyncReport sharedInstance].serverBgLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime: RECORD_TYPE_BG withUserId:(1 << [H2Records sharedInstance].currentUser)];
    }

    if ([H2SyncReport sharedInstance].didSendEquipInformation) {
        //[NSTimer scheduledTimerWithTimeInterval:0.04f target:self selector:@selector(sdkSendMeterInfo) userInfo:nil repeats:NO];
        [self sdkSendMeterInfo];
    }
}

- (void)sdkSendMeterInfo
{
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateMeterInfo:)])
        {
#ifdef DEBUG_LIB
            DLog(@"LIB REPORT EQUIPMENT INFO -- NEW");
#endif
            [self.libDelegate appDelegateMeterInfo:[H2SyncReport sharedInstance].reportMeterInfo];
        }
    }
    [H2SyncReport sharedInstance].didSendEquipInformation = NO;
    [H2SyncReport sharedInstance].didEquipInfoDone = YES;
}

- (BOOL)svrNewLastDateTimeProcess:(UInt8)type withUid:(UInt8)uId
{
    UInt8 dataTypeValue = (1 << type);
    UInt8 userIdValue = (1 << uId);
#ifdef DEBUG_LIB
    DLog(@"LIB-LDT = %@", [H2BayerEventProcess sharedInstance].serverSrcLastDateTimes);
#endif
    // ALL NEW
    if ([[H2BayerEventProcess sharedInstance].serverSrcLastDateTimes count] == 0) {
        return YES;
    }
#ifdef DEBUG_LIB
    DLog(@"LIB-LDT != 0");
#endif
    for (NSDictionary *svrLDT in [H2BayerEventProcess sharedInstance].serverSrcLastDateTimes){
        
        // Compare Serial Number and User ID
        [ArkrayGBlack sharedInstance].ArkraySvrSerialNumber = [svrLDT objectForKey: @"LDT_SerialNumber"];
        
        if ([ArkrayGBlack sharedInstance].ArkraySvrSerialNumber == nil) {
            [self demoSdkSyncCableStatus:FAIL_KEY_ERROR delegateCode:DELEGATE_DEVELOP];
            return NO;
        }
        
        [ArkrayGBlack sharedInstance].ArkrayNewSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
#ifdef DEBUG_LIB
        DLog(@"LIB SVR SN IS %@", [ArkrayGBlack sharedInstance].ArkraySvrSerialNumber);
        DLog(@"LIB DEV SN IS %@", [ArkrayGBlack sharedInstance].ArkrayNewSerialNumber);
#endif
        if ([H2DataFlow sharedDataFlowInstance].equipId  == SM_BLE_ARKRAY_G_BLACK || [H2DataFlow sharedDataFlowInstance].equipId  == SM_BLE_ARKRAY_NEO_ALPHA) {
            if ([ArkrayGBlack sharedInstance].ArkraySvrSerialNumber.length == 6){
                continue;
            }
        }
        
#ifdef DEBUG_LIB
        DLog(@"SEC LIB SVR SN IS %@", [ArkrayGBlack sharedInstance].ArkraySvrSerialNumber);
        DLog(@"SEC LIB DEV SN IS %@", [ArkrayGBlack sharedInstance].ArkrayNewSerialNumber);
#endif
        
        // GET SERIAL NUMBER
        //UInt8 tmpType = 1;
        //UInt8 tmpUser = 1;
        NSNumber *tmpNrType = [svrLDT objectForKey: @"LDT_NrRecordType"];
        NSNumber *tmpNrUserTag = [svrLDT objectForKey: @"LDT_NrUserTag"];
        if (tmpNrType == nil || tmpNrUserTag == nil) {
            [self demoSdkSyncCableStatus:FAIL_KEY_ERROR delegateCode:DELEGATE_DEVELOP];
            return NO;
        }
        
        UInt8 tmpType = [tmpNrType intValue];
        UInt8 tmpUser = [tmpNrUserTag intValue];
        
#ifdef DEBUG_LIB
        DLog(@"LIB TYPE : %d AND DEV : %d", dataTypeValue, tmpType);
        DLog(@"LIB TAG : %d AND DEV : %d", userIdValue, tmpUser);

        if ([[ArkrayGBlack sharedInstance].ArkrayNewSerialNumber isEqualToString:[ArkrayGBlack sharedInstance].ArkraySvrSerialNumber]){
            DLog(@"LDT-DEBUG -> SN");
        }
        if (dataTypeValue == tmpType) {
            DLog(@"LDT-DEBUG -> TYPE");
        }
        if (userIdValue == tmpUser) {
            DLog(@"LDT-DEBUG -> TAG");
        }
#endif
        if ([[ArkrayGBlack sharedInstance].ArkrayNewSerialNumber isEqualToString:[ArkrayGBlack sharedInstance].ArkraySvrSerialNumber] &&
            dataTypeValue == tmpType && userIdValue == tmpUser
            ){
#ifdef DEBUG_LIB
            DLog(@"LIB SN IS EQUAL TO %@", [ArkrayGBlack sharedInstance].ArkraySvrSerialNumber);
#endif
            NSString *tmpLdt = [svrLDT objectForKey: @"LDT_DateTime"];
            if ([tmpLdt isEqualToString:@""] || tmpLdt == nil) {
                tmpLdt = DEF_LAST_DATE_TIME;
            }
            UInt8 newTimeFmt = [tmpLdt characterAtIndex:10];
            if (newTimeFmt == 'T') {
                [self demoSdkSyncCableStatus:SUCCEEDED_NEW_TIME_FMT delegateCode:DELEGATE_DEVELOP];
            }
            
            if (![[H2SyncReport sharedInstance] kmTimeFormatting:(&tmpLdt)]) {
                
                [self demoSdkSyncCableStatus:FAIL_LDT_FMT delegateCode:DELEGATE_SYNC];
                return NO;
            }
            
            [[H2SvrLastDateTime sharedInstance] h2UpdateLastTimeFromServer:type withUserId:uId withSvrLDT:tmpLdt];
            
            
            NSNumber *tmpIndex = [svrLDT objectForKey: @"LDT_NrIndexOfRecord"];
            if (tmpIndex == nil) {
                [self demoSdkSyncCableStatus:FAIL_KEY_ERROR delegateCode:DELEGATE_DEVELOP];
                return NO;
            }
#ifdef DEBUG_LIB
            DLog(@"THE INDEX %@", tmpIndex);
#endif
            [[H2SvrLastDateTime sharedInstance] h2UpdateLdtIndexFromServer:type withUserId:uId withSvrIndex:tmpIndex];
            
#ifdef DEBUG_LIB
                DLog(@"GET OLD LDT --  TYPE %02X,  UID %02X", type, uId);
#endif
            [H2SyncReport sharedInstance].reportMeterInfo.IsOldMeter = YES;
            break;
        }else{
            [H2SyncReport sharedInstance].reportMeterInfo.IsOldMeter = NO;
#ifdef DEBUG_LIB
            DLog(@"SN NOT EQUAL");
#endif
        }
    }
    return YES;
}



#pragma mark - SINGLE RESULT ....
- (void)sdkReportMeterDateTimeValueSingle:(id)record
{
    if ([[H2SyncReport sharedInstance].recordsArray count] == 0) {
#ifdef DEBUG_LIB
        DLog(@"NO Any Record");
#endif
        return;
    }
    switch ([H2Records sharedInstance].currentDataType) {
        case RECORD_TYPE_BP:
            [self bpSingleReport];
            break;
            
        case RECORD_TYPE_BW:
            [self bwSingleReport];
            break;
            
        case RECORD_TYPE_BG:
        default:
            [self bgSingleReport];
            break;
    }
    [[H2SyncReport sharedInstance].recordsArray removeAllObjects];
    [H2SyncReport sharedInstance].hasSMSingleRecord = NO;
#ifdef DEBUG_LIB_XXX
    DLog(@"LIB GLOBAL BG TOTAL NOW = %@", [H2Records sharedInstance].H2RecordsArray);
#endif
}


- (void)bgSingleReport
{
    
#ifdef DEBUG_LIB
    DLog(@"BG-SINGLE");
#endif
    

    for (H2BgRecord *bgRecord in [H2SyncReport sharedInstance].recordsArray) {
        
        if (![H2Records sharedInstance].multiUsers) {
            [H2SyncReport sharedInstance].h2BgRecordReportIndex++;
            bgRecord.bgIndex = [H2SyncReport sharedInstance].h2BgRecordReportIndex;
            bgRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
        }
        
        bgRecord.recordType = RECORD_TYPE_BG;
#ifdef DEBUG_LIB
        DLog(@"BG NEW UINT - %@", bgRecord.bgUnit);
#endif
        if ([bgRecord.bgUnit isEqualToString:BG_UNIT_EX]) {
            if(bgRecord.bgValue_mmol >= SMG_MMOL_MAX){
                bgRecord.bgValue_mmol = SMG_MMOL_MAX;
            }
            bgRecord.bgValue = [NSString stringWithFormat:@"%.2f", bgRecord.bgValue_mmol];
        }else{
            if(bgRecord.bgValue_mg >= SMG_MG_MAX){
                bgRecord.bgValue_mg = SMG_MG_MAX;
            }
            bgRecord.bgValue = [NSString stringWithFormat:@"%d", bgRecord.bgValue_mg];
        }
#ifdef DEBUG_LIB
        DLog(@"BG NEW RECORD - %@", bgRecord);
#endif
        [[H2SyncReport sharedInstance].h2BgRecordReportArray addObject:bgRecord];
        if ([H2Sync sharedInstance].isAudioCable || [H2BleService sharedInstance].isBleCable) {
            [[H2Records sharedInstance] buildRecordsArray:(id)bgRecord];
        }
    }
    
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appChkBgRecordIndex:)])
        {
            [self.libDelegate appChkBgRecordIndex:[[H2SyncReport sharedInstance].h2BgRecordReportArray count]];
        }
    }
    
    for (int i = 0; i<[[H2SyncReport sharedInstance].recordsArray count]; i++) {

        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appChkBgSingleRecord:)])
        {
            [self.libDelegate appChkBgSingleRecord:(H2BgRecord *)[[H2SyncReport sharedInstance].recordsArray objectAtIndex:i]];
        }
    }
}

- (void)bpSingleReport
{
#ifdef DEBUG_LIB
    DLog(@"BP-SINGLE");
#endif
    for (H2BpRecord *bpSingle in [H2SyncReport sharedInstance].recordsArray) {
        
        if (![H2Records sharedInstance].multiUsers) {
            [H2SyncReport sharedInstance].h2BpRecordReportIndex++;
            bpSingle.bpIndex = [H2SyncReport sharedInstance].h2BpRecordReportIndex;
        }
        
        bpSingle.recordType = RECORD_TYPE_BP;
        [[H2SyncReport sharedInstance].h2BpRecordReportArray addObject:bpSingle];
        //[[H2Records sharedInstance] buildRecordsArray:(id)bpSingle
    }
    
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appChkBpRecordIndex:)])
        {
            [self.libDelegate appChkBpRecordIndex:[[H2SyncReport sharedInstance].h2BpRecordReportArray count]];
        }
    }
    
    for (int i = 0; i<[[H2SyncReport sharedInstance].recordsArray count]; i++) {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appChkBpSingleRecord:)])
        {
            [self.libDelegate appChkBpSingleRecord:(H2BpRecord *)[[H2SyncReport sharedInstance].recordsArray objectAtIndex:i]];
        }
    }
}



- (void)bwSingleReport
{
#ifdef DEBUG_LIB
    DLog(@"BW-SINGLE");
#endif
    for (H2BwRecord *bwSingle in [H2SyncReport sharedInstance].recordsArray) {
        [H2SyncReport sharedInstance].h2BwRecordReportIndex++;
        bwSingle.bwIndex = [H2SyncReport sharedInstance].h2BwRecordReportIndex;
        bwSingle.recordType = RECORD_TYPE_BW;
        [[H2SyncReport sharedInstance].h2BwRecordReportArray addObject:bwSingle];
        //[[H2Records sharedInstance] buildRecordsArray:(id)bwSingle];
    }
    
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appChkBwRecordIndex:)])
        {
            [self.libDelegate appChkBwRecordIndex:[[H2SyncReport sharedInstance].h2BwRecordReportArray count]];
        }
    }
    
    for (int i = 0; i<[[H2SyncReport sharedInstance].recordsArray count]; i++) {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appChkBwSingleRecord:)])
        {
            [self.libDelegate appChkBwSingleRecord:(H2BwRecord *)[[H2SyncReport sharedInstance].recordsArray objectAtIndex:i]];
        }
    }
}

#pragma mark - SYNC FINISHED PROCESS - RECORDS and UPDATE LDT
- (void)sdkProcessRecordsBeforeTransfer
{
    [H2BleService sharedInstance].bleNormalDisconnected = YES;
    if ([H2BleService sharedInstance].isBleEquipment) {
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
    }else{
        if ([H2SyncStatus sharedInstance].didReportSyncFail) {
           [self demoSdkSyncCableStatus:[H2SyncReport sharedInstance].h2StatusCode delegateCode:DELEGATE_SYNC];
            return;
        }
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(sdkProcessRecordsBeforeTransferDelay) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
    DLog(@"Call == Process Record == TASK");
#endif
}

- (void)globalEndingProcess
{
    if ([H2BleService sharedInstance].isBleCable || [H2BleService sharedInstance].isBleEquipment) {
        [H2BleService sharedInstance].isBleCable = NO;
        [H2BleService sharedInstance].isBleEquipment = NO;
        [H2BleService sharedInstance].blePairingStage = NO;
    }else{
        if(_isAudioCable){
            [[H2AudioFacade sharedInstance] audioStop];
            [[H2AudioSession sharedInstance] setVolumeLevelMin];
        }
    }
    
    [H2SyncStatus sharedInstance].sdkFlowActive = NO;
    
    [JJBayerContour sharedInstance].goToNextYearStage = NO;
    [JJBayerContour sharedInstance].isSyncSecondStageRunning = NO;
}

- (void)sdkProcessRecordsBeforeTransferDelay
{
    NSMutableArray *typeArray = [[NSMutableArray alloc] init];
    NSMutableArray *userArray= [[NSMutableArray alloc] init];
#ifdef DEBUG_LIB
    DLog(@"ENDDING -- RECORDS ... PROCESS");
#endif
    [self globalEndingProcess];
    
    if ([H2SyncStatus sharedInstance].didReportSyncFail) {
        [H2SyncStatus sharedInstance].didReportSyncFail = NO;
        [H2SyncReport sharedInstance].didSyncRecordFinished = NO;
        [self h2SyncInfoReportProcess];
#ifdef DEBUG_LIB
        DLog(@"ENDDING -- FAIL FAIL ...");
#endif
        return;
    }else{
        if ([[H2SyncReport sharedInstance].h2BgRecordReportArray count] || [[H2SyncReport sharedInstance].h2BpRecordReportArray count] || [[H2SyncReport sharedInstance].h2BwRecordReportArray count] ) {
            [H2SyncReport sharedInstance].h2StatusCode = SUCCEEDED_NEW;
#ifdef DEBUG_LIB
            DLog(@"ENDDING -- (BG, BP, BW)NEW NEW ...");
#endif
        }else{
            [H2SyncReport sharedInstance].h2StatusCode = SUCCEEDED_OLD;
            [NSTimer scheduledTimerWithTimeInterval:DELAY_RECORDS target:self selector:@selector(recordsHaveSkip) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
            DLog(@"ENDDING -- ZERO or OLD ...");
#endif
        }
    }
    
    if ([H2BleService sharedInstance].isBleEquipment) { // BLE Equipment, Model = @""
        [H2SyncReport sharedInstance].reportMeterInfo.smModelName = @"";
    }
#ifdef DEBUG_LIB
    DLog(@"WHAT WE WANT - TYPE %02X", [H2Records sharedInstance].dataTypeFilter);
    DLog(@"WHAT WE WANT - UID %02X", [H2Records sharedInstance].equipUserIdFilter);
#endif
    if ([[H2SyncReport sharedInstance].h2MultableLastDateTime count] > 0) {
        [[H2SyncReport sharedInstance].h2MultableLastDateTime removeAllObjects];
    }

    //BOOL hasRecord = NO;
    if ([H2SyncReport sharedInstance].h2StatusCode == SUCCEEDED_NEW) {
        // LOOP For Get LDT for BG, BP, BW and ALL User
        for (int i =0; i<3; i++) {
            if ([H2Records sharedInstance].dataTypeFilter & (1 << i)) {
                typeArray = [[H2Records sharedInstance].H2RecordsArray objectAtIndex:i];
                for (int k=0; k<5; k++) {
#ifdef DEBUG_LIB
                    DLog(@"LDT CUR USER =  %2X", k);
#endif
                    if ([H2Records sharedInstance].equipUserIdFilter & (1 << k)) {
                        if ([userArray count] > 0) {
                            [userArray removeAllObjects];
                        }
                        userArray = [typeArray objectAtIndex:k];
                        
                        if ([userArray count] > 0) {
                            //hasRecord = YES;
#ifdef DEBUG_LIB
                            DLog(@"LDT-T - %02X, LDT-U - %02X, LDT-R - %@", i, k, userArray);
#endif
                            // TO DO ...
                            [self h2SyncUpdateLastDateTime:i withUserId:k withRecords:userArray];
                            
                        }else{
#ifdef DEBUG_LIB
                            DLog(@"LDT USER %02X, TYPE %02X --> NO DATA", k, i);
#endif
                        }
                    }
                }
            }
        }
    }

    // Report FINAL Status
    [self demoSdkSyncCableStatus:[H2SyncReport sharedInstance].h2StatusCode delegateCode:DELEGATE_SYNC];
    
    [H2SyncReport sharedInstance].isMeterWithNewRecords = NO;
    [H2SyncReport sharedInstance].didSyncRecordFinished = NO;
    
    if ([H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex == SYNC_INFO_CABLE_STATUS_SIZE) {
        [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex = 0;
    }
#ifdef DEBUG_LIB
    if ([H2SyncReport sharedInstance].h2StatusCode == SUCCEEDED_NEW || [H2SyncReport sharedInstance].h2StatusCode == SUCCEEDED_OLD) {
        [self h2SyncInfoReportProcess];
    }
#endif
    // NEW REPORT ....
    if ([H2SyncReport sharedInstance].h2StatusCode == SUCCEEDED_NEW) {
        // Transfer records to Outside, Delay 200 ms
        [NSTimer scheduledTimerWithTimeInterval:DELAY_RECORDS target:self selector:@selector(transferRecordsTask) userInfo:nil repeats:NO];
    }
}

- (void)recordsHaveSkip
{
    RecordsSkipped *numbersSkip = [[RecordsSkipped alloc] init];
    
    numbersSkip.bgSkip = [H2SyncReport sharedInstance].bgHasBeenSkip;
    numbersSkip.bpSkip = [H2SyncReport sharedInstance].bpHasBeenSkip;
    numbersSkip.bwSkip = [H2SyncReport sharedInstance].bwHasBeenSkip;
    
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateRecordsSkip:)])
        {
            [self.libDelegate appDelegateRecordsSkip:numbersSkip];
        }
    }
}

// LDT Process
- (void)h2SyncUpdateLastDateTime:(UInt8 )dataType withUserId:(UInt8)uId withRecords:(NSArray *)recordArray
{
    NSString *sLDT;
    switch (1 << dataType) {
        case RECORD_TYPE_BG:
            
            if ([H2DataFlow sharedDataFlowInstance].equipUartProtocol == SM_ONETOUCH_ULTRA_VUE) {
                sLDT = [H2SyncReport sharedInstance].tmpDateTimeForVue;
            }else{
                if ([H2AudioAndBleCommand sharedInstance].newRecordAtFinal) {
                    sLDT = ((H2BgRecord *)[recordArray lastObject]).bgDateTime;
                }else{
                    sLDT = ((H2BgRecord *)[recordArray objectAtIndex:0]).bgDateTime;
                }
            }
            
            break;
            
        case RECORD_TYPE_BP:
                if ([H2AudioAndBleCommand sharedInstance].newRecordAtFinal) {
                    sLDT = ((H2BpRecord *)[recordArray lastObject]).bpDateTime;
                }else{
                    sLDT = ((H2BpRecord *)[recordArray objectAtIndex:0]).bpDateTime;
                }
            break;
            
        case RECORD_TYPE_BW:
            if ([H2AudioAndBleCommand sharedInstance].newRecordAtFinal) {
                sLDT = ((H2BwRecord *)[recordArray lastObject]).bwDateTime;
            }else{
                sLDT = ((H2BwRecord *)[recordArray objectAtIndex:0]).bwDateTime;
            }
            break;
            
        default:
            break;
    }
    
/*
    NSNumber *nrSkipBgRecords = [NSNumber numberWithInt:[H2SyncReport sharedInstance].bgHasBeenSkip];
    NSNumber *nrSkipBpRecords = [NSNumber numberWithInt:[H2SyncReport sharedInstance].bpHasBeenSkip];
    NSNumber *nrSkipBwRecords = [NSNumber numberWithInt:[H2SyncReport sharedInstance].bwHasBeenSkip];
  */
    NSDictionary *dicLastDateTime = [[NSDictionary alloc] init];
    NSNumber *nrIndex = [NSNumber numberWithInt:[H2SyncReport sharedInstance].bgLdtIndex];
    NSNumber *nrRecordType = [NSNumber numberWithInt:(1 << dataType)];
    NSNumber *nrUserTag = [NSNumber numberWithInt:(1 << uId)];
    dicLastDateTime = @{
                        @"LDT_DateTime" : sLDT, // Date and Time String
                        @"LDT_Model" :@"",//@"NewModel",
                        @"LDT_SerialNumber" : [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber,
/*
                        @"LDT_NrSkipBgRecords" : nrSkipBgRecords, // Totol Skip BG Records(Time Error)
                        @"LDT_NrSkipBpRecords" : nrSkipBpRecords, // Totol Skip BP Records(Time Error)
                        @"LDT_NrSkipBwRecords" : nrSkipBwRecords, // Totol Skip BW Records(Time Error)
*/
                        @"LDT_NrIndexOfRecord" : nrIndex,
                        @"LDT_NrRecordType" : nrRecordType, // Record Type
                        @"LDT_NrUserTag": nrUserTag // Meter User ID
                        };
    [[H2SyncReport sharedInstance].h2MultableLastDateTime addObject:dicLastDateTime];
#ifdef DEBUG_LIB
    DLog(@"GO SVR LDT TOTAL NOW %@", [H2SyncReport sharedInstance].h2MultableLastDateTime);
#endif
}

- (void)appGetLastDateTime
{
    [self recordsHaveSkip];
    // RECORDS Skip INFO, Delay 200 ms
    [NSTimer scheduledTimerWithTimeInterval:DELAY_RECORDS target:self selector:@selector(reportLastDateTime) userInfo:nil repeats:NO];
    
}

- (void)reportLastDateTime
{
    DLog(@"GET LDT FROM APP");
    if ([[H2SyncReport sharedInstance].h2MultableLastDateTime count] > 0) {
        @autoreleasepool {
            if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
                [self.libDelegate respondsToSelector:@selector(appDelegateLastDateTimeArray:)])
            {
                [self.libDelegate appDelegateLastDateTimeArray:[H2SyncReport sharedInstance].h2MultableLastDateTime];
            }
        }
    }else{
        DLog(@"NO NEW LDT");
    }
}

/*!
 * @method
 *
 *
 */
- (void)transferRecordsTask
{
    NSDictionary *tmpRecords;
    tmpRecords = @{
                     @"bg_records" : [H2SyncReport sharedInstance].h2BgRecordReportArray,
                     @"bp_records" : [H2SyncReport sharedInstance].h2BpRecordReportArray,
                     @"bw_records" : [H2SyncReport sharedInstance].h2BwRecordReportArray
                     };

    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateGetMeterRecordData:)])
        {
            [self.libDelegate appDelegateGetMeterRecordData:tmpRecords];
        }
    }
    
}



#pragma mark - ULTRA2
- (void)h2SyncOneTouchUltra2ReadRecordAll
{
    [[H2OneTouchEventProcess sharedInstance] h2SyncUltra2BLEReadRecordAll];
}




/////////////////////// ARKRAY AND OMRON ////////////////////////
#pragma mark - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#pragma mark - ARKRAY METHOD AREA
- (void)sdkArkrayRegisterNotify
{
#ifdef DEBUG_LIB
    DLog(@"ARKRAY INIT NOTIFY FOR REGISTER ....");
#endif
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)] &&
            [self.libDelegate respondsToSelector:@selector(appDelegateArkrayPasswordRequest)])
        {
            [self.libDelegate appDelegateArkrayPasswordRequest];
#ifdef DEBUG_LIB
            DLog(@"Did come to H2SYNC .... 00 ");
#endif
        }
    }
}


- (void)appArkrayRegister:(Byte *)arkrayPassword
{
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    memcpy([ArkrayGBlack sharedInstance].akPassword, arkrayPassword, 6);
    [[ArkrayGBlack sharedInstance] passwordInit];
    [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_ARKRAY_CMD_INTERVAL taskSel:BLE_TIMER_ARKRAY_CMD_CHECK];
#ifdef DEBUG_LIB
    for (int i = 0; i < 6; i++) {
        DLog(@"ARKRAY PW %d and %02X", i, arkrayPassword[i]);
    }
#endif
}


#pragma mark - OMRON OMRON RESPONSE
- (void)sdkOmronUserTagStatus:(UInt8)uTagStatus
{
#ifdef DEBUG_LIB
    DLog(@"LIB - D USER ID STATUS -- BE SHOW");
#endif
#ifdef OMRON_UID_DEMO
    @autoreleasepool {
        if ([self.libDelegate conformsToProtocol:@protocol(H2SyncDelegate)]){
            DLog(@"LIB - D GOOD 1");
            if ([self.libDelegate respondsToSelector:@selector(demoAppDelegateReportUserTag:)]) {
                DLog(@"LIB - D GOOD 2");
                [self.libDelegate demoAppDelegateReportUserTag:uTagStatus];
                DLog(@"LIB - D OMRON RESPONSE .... HA HA HA ");
                
                DLog(@"NFY-UPF ... UID = %02X", [H2Omron sharedInstance].tmpUserProfile.uTag);
                DLog(@"NFY-UPF ... 生日 年 =%d", [H2Omron sharedInstance].tmpUserProfile.uBirthYear);
                DLog(@"NFY-UPF ... 生日 月 = %d", [H2Omron sharedInstance].tmpUserProfile.uBirthMonth);
                DLog(@"NFY-UPF ... 生日 日 =%d", [H2Omron sharedInstance].tmpUserProfile.uBirthDay);
                DLog(@"NFY-UPF ... 性別 %d", [H2Omron sharedInstance].tmpUserProfile.uGender);
                DLog(@"NFY-UPF ... 身高 : %d", [H2Omron sharedInstance].tmpUserProfile.uBodyHeight);
            }else{
                DLog(@"LIB - D BAD 2");
            }
        }else{
            DLog(@"LIB - D BAD 1");
        }
    }

#else
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(sdkOmronSetUserTag) userInfo:nil repeats:NO];
    
#endif
    
}

#pragma mark - App Terminal BLE Sync Flow
- (void)appTerminateSdkFlow
{
    [H2SyncStatus sharedInstance].cableSyncStop = YES;
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
#ifdef DEBUG_LIB
        NSLog(@"NORMAL DISCONNECT(STOP)");
#endif
        return;
    }
    [H2BleService sharedInstance].bleNormalDisconnected = YES;
    if ([H2BleService sharedInstance].isBleEquipment) {
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
    }else{
        
        [[H2Timer sharedInstance] clearCableTimer];
        if ([H2ApexBioEventProcess sharedInstance].embraceEndingTimer != nil) {
            [[H2ApexBioEventProcess sharedInstance].embraceEndingTimer invalidate];
            [H2ApexBioEventProcess sharedInstance].embraceEndingTimer = nil;
        }
        
        [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
    
        if ([H2BleService sharedInstance].isBleCable) {
         // TO DO
            [H2CableFlow sharedCableFlowInstance].audioSystemCmd = CMD_BLE_RESET;
            [[H2CableFlow sharedCableFlowInstance] h2CableSystemCommand:nil];
        }else{
            if (_isAudioCable) {
                [[H2AudioFacade sharedInstance] audioStop];
                [[H2AudioSession sharedInstance] setVolumeLevelMin];
            }
        }
    }
    // report STATUS
    if ([H2SyncStatus sharedInstance].sdkFlowActive) {
        [H2SyncStatus sharedInstance].sdkFlowActive = NO;
        if ([H2BleService sharedInstance].isBleEquipment) { // BLE DEVICE
            if ([H2BleService sharedInstance].blePairingStage || [H2BleService sharedInstance].bleCablePairing) {
                [self demoSdkSyncCableStatus:FAIL_SYNC delegateCode:DELEGATE_PAIRING];
            }else{
                [self demoSdkSyncCableStatus:FAIL_SYNC delegateCode:DELEGATE_SYNC];
            }
        }else{
            if ([H2BleService sharedInstance].recordMode) { // RECORD MODE
                [self demoSdkSyncCableStatus:FAIL_SYNC delegateCode:DELEGATE_SYNC];
            }else{
                [self demoSdkSyncCableStatus:FAIL_METER_EXISTING delegateCode:DELEGATE_SYNC];
            }
        }
    }
}


#pragma mark - OMRON OMRON OMRON TASK

- (void)demoAppOmronSetUserTag:(UInt8)userTag
{
#ifdef DEBUG_LIB
    DLog(@"LIB SET USER ID ...DEBUG ... $$$$$$$$$$");
#endif
#ifdef OMRON_UID_DEMO
    [[H2BleService sharedInstance] H2ServiceSetUserID:userTag];
#endif
}


- (void)sdkOmronSetUserTag
{
#ifdef DEBUG_LIB
    DLog(@"LIB SET USER ID ... AUTO -- $$$$$$$$$");
#endif
    UInt8 userTag = [H2Omron sharedInstance].tmpUserProfile.uTag;
    [[H2BleService sharedInstance] H2ServiceSetUserID:userTag];
    /*
    if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_7280T || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6324T) {
        switch ([H2Omron sharedInstance].tmpUserProfile.uTag) {
            case 1:
            default:
                userTag = USER_ID1_YES;
                break;
                
            case 2:
                userTag = USER_ID2_YES;
                break;
        }
    }else{
        switch ([H2Omron sharedInstance].tmpUserProfile.uTag) {
            case 1:
            default:
                userTag = USER_ID1_YES;
                break;
                
            case 2:
                userTag = USER_ID2_YES;
                break;
                
            case 3:
                userTag = USER_ID3_YES;
                break;
                
            case 4:
                userTag = USER_ID4_YES;
                break;
        }
    }
    
    [[H2BleService sharedInstance] H2ServiceSetUserID:userTag];
     */
}

- (UInt8)arkrayCmdParser:(UInt8)cmd
{
    UInt8 tmp = 0x80;
    switch (cmd) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            tmp = cmd & 0x0F;
            break;
            
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F':
            tmp = cmd - 'A' + 0x0A;
            break;
            
        default:
            break;
    }
    return tmp;
}


- (BOOL)dataTypeChecking:(UInt8)type
{
    if (type > 7 || type == 0) {
        return YES;
    }
    
    if ([H2DataFlow sharedDataFlowInstance].equipId > 0x00008000) { // BLE
        if ([H2DataFlow sharedDataFlowInstance].equipId > 0x00020000) { // BP or BG
            
            switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                case SM_BLE_CARESENS_EXT_B_FORA_D40: // BP + BG
                    if (type & RECORD_TYPE_BW) {
                        return YES;
                    }
                    break;
                    
                case SM_BLE_OMRON_HEM_7280T: // BP
                case SM_BLE_OMRON_HEM_7600T:
                case SM_BLE_OMRON_HEM_9200T:
                case SM_BLE_OMRON_HEM_6320T:
                case SM_BLE_OMRON_HEM_6324T:
                case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
                case SM_BLE_MICRO_LIFE:
                case SM_BLE_AND_UA_651BLE:
                    if (type != RECORD_TYPE_BP) {
                        return YES;
                    }
                    break;

                case SM_BLE_OMRON_HBF_254C: // BW
                case SM_BLE_OMRON_HBF_256T:
                case SM_BLE_CARESENS_EXT_B_FORA_W310B:
                case SM_BLE_AND_UC_352BLE:
                    if (type != RECORD_TYPE_BW) {
                        return YES;
                    }
                    break;
                    
                default: // BG
                    if (type != RECORD_TYPE_BG) {
                        return YES;
                    }
                    break;
            }
            
        }else{ // BLE BG
            if (type != RECORD_TYPE_BG) {
                return YES;
            }
        }
        
        
    }else{// Cable BG
        if (type != RECORD_TYPE_BG) {
            return YES;
        }
    }
    return NO;
}

    
    
@end




#if 0
////////////////////////////////////////////////////
//
////////////////////////////////////////////////////
- (BOOL)AlcIsAudioBusy
{
    return [[H2AudioFacade sharedInstance] isAudioBusy];
}

#pragma mark - AUDIO START

- (BOOL)start:(NSError **)error
{
    return [[H2AudioFacade sharedInstance] audioStart:error];
}

- (BOOL)isRunning
{
    return [[H2AudioFacade sharedInstance] isRunning];
}


- (void)stop
{
    if (_isAudioCable) { // cannel BLE Function
        [[H2AudioFacade sharedInstance] audioStop];
    }
    
    [JJBayerContour sharedInstance].didBayerSyncRunning = NO;
    [H2SyncStatus sharedInstance].didMeterUartReady = NO;
#ifdef DEBUG_LIB
    DLog(@"SYNC STOP METHOD");
#endif
}
#endif



