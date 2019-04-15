//
//  H2BleTimer.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/8/22.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2BleTimer.h"

#import "h2CmdInfo.h"
#import "H2Sync.h"
#import "H2BleCentralManager.h"
#import "H2BleService.h"

#import "H2BleOad.h"
#import "H2DataFlow.h"
#import "H2BleEquipId.h"

#import "H2Omron.h"
#import "ARKRAY_GT-1830.h"
#import "OMRON_HEM-7280T.h"
#import "OMRON_HBF-254C.h"
#import "H2BleBgm.h"
#import "ForaD40.h"
#import "OneTouchPlusFlex.h"

@implementation H2BleTimer

- (id)init
{
    if (self = [super init]) {
        
        _h2BleNormalTimer = [[NSTimer alloc] init];
        _h2BleNormalTimer = nil;
        
        _bleTimerTaskSel = 0;
        _bleRecordModeForTimer = NO;
#ifdef DEBUG_LIB
        DLog(@"H2 BLE TIMER INIT");
#endif
    }
    return self;
}


+ (H2BleTimer *)sharedInstance
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


- (void)h2SetBleTimerTask:(float)interval taskSel:(UInt8)taskSel
{
    _bleTimerTaskSel = taskSel;
    _h2BleNormalTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(h2BleTimeOutTask) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
    DLog(@"SET NORMAL TIMER %f and SEL = %02X, OBJ = %@", interval, taskSel, _h2BleNormalTimer);
#endif
}

- (void)h2ClearBleTimerTask
{
#ifdef DEBUG_LIB
    DLog(@"CLEAR NORMAL TIMER %@ , SEL = %02X", _h2BleNormalTimer, _bleTimerTaskSel);
#endif
    if (_h2BleNormalTimer != nil) {
        [_h2BleNormalTimer invalidate];
        _h2BleNormalTimer = nil;
    }
}




- (void)h2BleTimeOutTask
{
#ifdef DEBUG_LIB
    DLog(@"BLE NORMAL TIME OUT TASK %@, SEL = %02X", _h2BleNormalTimer, _bleTimerTaskSel);
#endif
    [self h2ClearBleTimerTask];
    switch (_bleTimerTaskSel) {
        case BLE_TIMER_SCAN_MODE:
            [[H2BleCentralController sharedInstance] h2BleScanDevEnd];
            break;
            
        case BLE_TIMER_BLE_CONNECT_MODE:
            [self h2BleConnectTimeOut];
            break;
            
        case BLE_TIMER_READ_SN:
            [self h2ReadSerialNumberTimeOut];
            break;
            
        case BLE_TIMER_PREPIN_MODE:
            // enter to PIN MODE
            [H2BleService sharedInstance].normalFlowHasNofity = YES;
            switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
                case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
                case SM_BLE_ACCUCHEK_INSTANT:
                    if (![H2BleService sharedInstance].blePairingStage) {
                        [H2BleBgm sharedInstance].willFinished = YES;
                    }
                    break;
                    
                default:
                    // DO NOTHING!!
                    break;
            }
            [self h2SetBleTimerTask:BLE_DIALOG_INTERVAL taskSel:BLE_TIMER_PIN_MODE];
            break;
            
        case BLE_TIMER_PIN_MODE:
            [self bleDialogNotAppearTimeOut];
            break;
            
            
        case BLE_TIMER_RECORD_MODE:
            [self h2BleRecordTask];
            break;
            
        case BLE_TIMER_OMRON_MODE:
            [self omronModeTimeOut];
#ifdef DEBUG_LIB
            DLog(@"OMRON MODE TIME OUT");
#endif
            break;
            
        case BLE_TIMER_OMRON_CMD_FLOW:
            [[H2BleCentralController sharedInstance] h2BleConnectReport:[[H2Omron sharedInstance] omronCmdFlowTimerTask]];
#ifdef DEBUG_LIB
            DLog(@"OMRON MODE TIME OUT");
#endif
            break;
            
        case BLE_TIMER_ARKRAY_NOTIFY:
            [self h2ArkrayNotifyFail];
            break;
            
        case BLE_TIMER_USER_INPUT:
            [self h2ArkrayPasswordTimeOut];
            break;
            
        case BLE_TIMER_ARKRAY_CMD_CHECK:
            [self h2ArkrayCmdTimeOut];
            break;
            
        case BLE_TIMER_OMRON_HEM_CMD_FLOW:
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:[H2Omron sharedInstance].cmdTimeOutInterval taskSel:BLE_TIMER_OMRON_CMD_FLOW];
            [[OMRON_HEM_7280T sharedInstance] h2OmronHem7280TA1CmdFlow];
            break;
            
        case BLE_TIMER_OMRON_HBF_CMD_FLOW:
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:[H2Omron sharedInstance].cmdTimeOutInterval taskSel:BLE_TIMER_OMRON_CMD_FLOW];
            [[OMRON_HBF_254C sharedInstance] h2OmronHbf254CA1CmdFlow];
            break;
            
        case BLE_TIMER_BGM_DATA_MODE:
            
            break;
            
        case BLE_TIMER_OH_PLUS_FLEX:
            if ([OneTouchPlusFlex sharedInstance].flexCmdSel == 0 && [OneTouchPlusFlex sharedInstance].flexFirstCmd) {
                [OneTouchPlusFlex sharedInstance].flexFirstCmd = NO;
                
                [NSTimer scheduledTimerWithTimeInterval:BLE_FLUS_FLEX_RS_INTERVAL target:self selector:@selector(plusFlexRestart) userInfo:nil repeats:NO];
                return;
            }
            [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_SYNC];
            break;
            
        default:
            break;
    }
}

- (void)plusFlexRestart
{
    [[OneTouchPlusFlex sharedInstance] plusFlexCmdFlow];
}

#pragma mark - BLE CONNECT TIME OUT TASK
- (void)h2BleConnectTimeOut
{
    BOOL devNotFound = YES;
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
        case SM_BLE_CARESENS_EXT_C_BTM:
            if ([H2BleService sharedInstance].blePairingStage) {
                if ([H2BleService sharedInstance].bleScanDeviceCount > 0) {
                    devNotFound = NO;
                }
            }
            break;
            
        case SM_BLE_AND_UA_651BLE:
        case SM_BLE_AND_UC_352BLE:
            [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_ARKRAY_CMD_NOT_FOUND];
            //[[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_PAIR_TIMEOUT];
            return;
            
        default:
            break;
    }
    if (devNotFound) {
        [[H2BleCentralController sharedInstance] h2BleCentralCanncelConnectForVendor];
        [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_NOT_FOUND];
    }else{
        [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
    }
#ifdef DEBUG_LIB
    DLog(@"BLE CONNECT TIME OUT!!");
#endif
}

#pragma mark - BLE SN TIME OUT TASK
- (void)h2ReadSerialNumberTimeOut
{
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
#ifdef DEBUG_LIB
    if ([H2BleService sharedInstance].bleConnected) {
        DLog(@"BLE READ SN TO - CONNECTED");
    }else{
        DLog(@"BLE READ SN TO - NO CONNECTED");
    }
    DLog(@"BLE TIME OUT FOR READ SN - %02X", [H2Omron sharedInstance].omronCmdSel);
#endif
    BOOL bleCanncel = NO;
    UInt8 errCode = 0;
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
            if ([H2BleService sharedInstance].bleSerialNumberMode) {
                errCode = FAIL_BLE_PAIR_TIMEOUT;
            }else{
                errCode = FAIL_BLE_NOT_FOUND;
            }
            bleCanncel = YES;
#ifdef DEBUG_LIB
            DLog(@"AVIVA CONNECT(GUIDE) - DIALOG NOT APPEAR");
#endif
            break;
            
        case SM_BLE_BGM_TRUE_METRIX:
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            errCode = FAIL_BLE_NOT_FOUND;
            bleCanncel = YES;
#ifdef DEBUG_LIB
            DLog(@"TRUE METRIX or AVIVA CONNECT - BLE SN TIME OUT");
#endif
            break;
            
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
            bleCanncel = YES;
            errCode = [[H2Omron sharedInstance] omronCmdFlowTimerTask];
#ifdef DEBUG_LIB
            DLog(@"OMRON NOT FOUND  or INPUT TIME OUT, ARKRAY TIME OUT");
#endif
            break;
            
        case SM_BLE_OMRON_HEM_9200T:
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            errCode = FAIL_BLE_NOT_FOUND;
            bleCanncel = YES;
            break;
            
        default:
            break;
    }
    
    if (bleCanncel) {
        [[H2BleCentralController sharedInstance] h2BleConnectReport:errCode];
        [[H2BleCentralController sharedInstance] h2BleCentralCanncelConnectForVendor];
        return;
    }
    if ([H2BleService sharedInstance].bleSerialNumberStage) {
        [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_NOT_FOUND];
        return;
    }
    [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
}

#pragma mark - BLE PIN DIALOG NOT APPEAR
- (void)bleDialogNotAppearTimeOut
{
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
#ifdef DEBUG_LIB
    DLog(@"SHOULD SHOW DIALOG");
    if ([H2BleService sharedInstance].bleConnected) {
        DLog(@"BLE - CONNECTED");
    }else{
        DLog(@"BLE - NO CONNECTED");
    }
    DLog(@"BLE TIME OUT FOR SHOW DIALOG - %02X", [H2Omron sharedInstance].omronCmdSel);
#endif
    UInt8 errCode = 0;
    
    
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
            if ([H2BleService sharedInstance].bleSerialNumberMode) {
                errCode = FAIL_BLE_PAIR_TIMEOUT;
            }else{
                errCode = FAIL_BLE_NOT_FOUND;
            }
            break;
            
        case SM_BLE_BGM_TRUE_METRIX:
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            errCode = FAIL_BLE_PAIR_TIMEOUT;

            break;
            
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
            errCode = FAIL_BLE_PAIR_TIMEOUT;
            break;
            
            
        case SM_BLE_OMRON_HEM_9200T:
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            errCode = FAIL_BLE_NOT_FOUND;
            break;
            
        case SM_BLE_AND_UA_651BLE:
        case SM_BLE_AND_UC_352BLE:
            //errCode = FAIL_BLE_ARKRAY_CMD_NOT_FOUND;
            errCode = FAIL_BLE_PAIR_TIMEOUT;
            break;
            
        default:
            errCode = FAIL_BLE_NOT_FOUND;
            break;
    }
    [[H2BleCentralController sharedInstance] h2BleConnectReport:errCode];
    [[H2BleCentralController sharedInstance] h2BleCentralCanncelConnectForVendor];
}

- (void)omronModeTimeOut
{
    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_MODE];
    [[H2BleCentralController sharedInstance] h2BleCentralCanncelConnectForVendor];
}





- (void)h2BleRecordTask
{
    // CANCEL SYNC AND REPORT SYNC FAIL.
    [H2BleService sharedInstance].bleRecordStage = NO;
    [H2BleService sharedInstance].bleOADStage = NO;
    [H2BleOad sharedInstance].oadMode = NO;
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
    
    if ([ForaD40 sharedInstance].foraD40Finished) {
        [ForaD40 sharedInstance].foraD40Finished = NO;
        [H2BleService sharedInstance].bleNormalDisconnected = YES;
        [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
        return;
    }
    
    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_SYNC];
#ifdef DEBUG_LIB
    DLog(@"BLE SYNC TIME OUT HAPPEN");
#endif
}


- (void)h2BleBgmModeTask
{
    // CANCEL SYNC AND REPORT SYNC FAIL.
    [H2BleService sharedInstance].bleRecordStage = NO;
    [H2BleService sharedInstance].bleOADStage = NO;
    [H2BleOad sharedInstance].oadMode = NO;
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
    [[H2BleCentralController sharedInstance] h2BleConnectReport: OAD_OLD_IMAGE];
#ifdef DEBUG_LIB
    DLog(@"BLE BGM SYNC TIME OUT HAPPEN");
#endif
}

- (void)h2ArkrayPasswordTimeOut
{
    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_ARKRAY_PWSLOWLY];
    DLog(@"ARKRAY PW - USER SLOWLY");
}

- (void)h2ArkrayNotifyFail
{
    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_PAIR_TIMEOUT];
    DLog(@"PIN DIALOG NOT APPEAR OR NOTIFY FAIL");
}

- (void)h2ArkrayCmdTimeOut
{
    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_MODE];
    DLog(@"ARKRAY CMD TIME OUT - FAIL");
    // OR COMMAND NOT FOUND
}

#pragma mark - ==== A6 BT HEAPER ====
- (Byte *)systemCurrentTime
{
    NSDate *now = [[NSDate alloc] init];
#ifdef DEBUG_BW
    DLog(@"SYTEM CT IS --> %@", now);
#endif
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
    
    Byte *timeTmp = (Byte *)malloc(6);
    UInt16 year = [components year];
    //memcpy(timeTmp, &year, 2);
    
    timeTmp[0] = (UInt8)((year-2000)&0xFF);
    timeTmp[1] = [components month];
    timeTmp[2] = [components day];
    
    timeTmp[3] = [components hour];
    timeTmp[4] = [components minute];
    timeTmp[5] = [components second];
    
    return timeTmp;
}

@end
