//
//  H2CableFlow.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/8.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2BleService.h"
#import "h2CmdInfo.h"
#import "H2AudioFacade.h"
#import "H2Config.h"
#import "H2CableFlow.h"
#import "H2DataFlow.h"
#import "H2AudioHelper.h"

#import "GlucoCardVital.h"
#import "H2ApexBioEventProcess.h"
#import "ROConfirm.h"
#import "H2OneTouchEventProcess.h"

#import "H2Timer.h"
#import "H2Records.h"

@implementation H2CableFlow


- (id)init
{
    if (self = [super init]) {
        _cableTimer = [[NSTimer alloc] init];
        _cableTimer = nil;
        _audioSystemCmd = 0xFF;
    }
    return self;
}



#pragma mark -
#pragma mark Command structure

unsigned char cableBleReset[] = {
    0x00, CMD_BLE_RESET, BLE_MCU_RST, 0x00, 0x00
};

unsigned char cableBleMcuPM3[] = {
    0x00, CMD_BLE_RESET, BLE_MCU_PM3, 0x00, 0x00
};

unsigned char cableSwitchOn[] = {
    0x00, CMD_SW_ON, 0x00, 0x00, 0x00
};
unsigned char cableSwitchOff[] = {
    0x00, CMD_SW_OFF, 0x00, 0x00, 0x00
};

/*
unsigned char cableUartInit[] = {
    0x00, CMD_UART_INIT, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
*/

unsigned char cableVersion[] = {
    0x00, CMD_CABLE_VERSION, 0x00, 0x00, 0x00
};
unsigned char cableExistingTalk[] = {
    0x00, CMD_CABLE_EXISTING, 0x00, 0x00, 0x00
};
unsigned char externalMeterTalk[] = {
    0x00, CMD_EX_METER_TALK,
    0xBA, 0x01, 0x02, 0x03, 0x04, 0x05,
    0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
    0x00, 0x00, 0x0E, 0x0F,
    //    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17
    0x0, 0x0, 0x0, 0x0, 0x0, 0x03
};
/*
unsigned char cableCycleTalk[] = {
    0x00, CMD_INTERFACE_TEST, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00
};
*/
unsigned char cableCycleTalkFreeStyle[] = {
    0x00, 0x98, //0x00, 0x00, 0x00, 0x00
    '$', 'l', 'o', 'g', ',', '0', '0', '0', 0x0A
};
unsigned char getAudioCableBufferTalk[] = {
    0x00, CMD_GET_BUFFER, 0x00, 0x00, 0x00
};

/*
unsigned char cableSNtalk[] = {
    0x00, CMD_SN_TALK, 0x00, 0x00
};
*/
/*
unsigned char bleRocheTalk[] = {
    0x00, CMD_ROCHE_TALK, 0x00, 0x00
};
*/

- (void)h2SystemResendCmdInit
{
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = SYSTEM_NORMAL_RESEND_CYCLE;
    [self h2SyncSystemCommandResendTimerSetting];
}




#pragma mark - CABLE COMMAND TALK
- (void)h2CableSystemCommand:(id)sender{
#ifdef DEBUG_LIB
    DLog(@"CABLE COMMAND (SYSTEM)... %02X", _audioSystemCmd);
#endif
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = SYSTEM_NORMAL_RESEND_CYCLE;
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = SYSTEM_NORMAL_RESEND_INTERVAL;
    UInt8 cmdLength = 0;
    UInt8 cmdBuffer[32] = {0};
    switch (_audioSystemCmd) {
            
        case CMD_BLE_RESET:
#ifdef DEBUG_LIB
            DLog(@"H2 DEBUG RESET MCU INIT");
#endif
            [H2BleCentralController sharedInstance].bleCanncelConnect = YES;
            [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = 0;
            
            if ([H2BleService sharedInstance].isBleCable)
            {
                // For Long Run Test
#if 1
                cmdLength = sizeof(cableBleMcuPM3);
                memcpy(cmdBuffer, cableBleMcuPM3, cmdLength);
                [H2BleService sharedInstance].didBleCableFinished = YES;
                
#else
                // For Long Run Test
                cmdLength = sizeof(cableBleReset);
                memcpy(cmdBuffer, cableBleReset, cmdLength);
#endif
                [H2Records sharedInstance].bgCableSyncFinished = YES;
            }
            break;
            
        case CMD_SW_ON:
            cmdLength = sizeof(cableSwitchOn);
            memcpy(cmdBuffer, cableSwitchOn, cmdLength);
            break;
            
        case CMD_SW_OFF:
            cmdLength = sizeof(cableSwitchOff);
            memcpy(cmdBuffer, cableSwitchOff, cmdLength);
            break;
            
        case CMD_UART_INIT:
            break;
        case CMD_EX_METER_TALK:
            break;
            
        case CMD_CABLE_EXISTING:
            [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = SYSTEM_EXIST_RESEND_CYCLE;
            [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = SYSTEM_NORMAL_RESEND_INTERVAL;
            [H2DataFlow sharedDataFlowInstance].sdkActivity = YES;
            cmdLength = sizeof(cableExistingTalk);
            memcpy(cmdBuffer, cableExistingTalk, cmdLength);
            break;
            
        case CMD_CABLE_VERSION:
            cmdLength = sizeof(cableVersion);
            memcpy(cmdBuffer, cableVersion, cmdLength);
            break;
            
        default:
            break;
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:BRAND_SYSTEM returnDataLength:0 mcuBufferOffSetAt:0];
    [self h2SyncSystemCommandResendTimerSetting];
}



#pragma mark - ELSE ...
- (void)h2SyncSystemCommandResendTask:(id)sender
{
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
#ifdef DEBUG_LIB
    if (![H2AudioAndBleSync sharedInstance].syncIsNormalMode) {
        [H2SyncDebug sharedInstance].debugErrorCountSystem++;
        // TO DO ....
    }
    // TO DO ...
    [[H2AudioHelper sharedInstance] h2SyncDebugTask:nil];
#endif
    [[H2Timer sharedInstance] clearCableTimer];
    if ([H2BleService sharedInstance].didBleCableFinished) {
        [H2BleService sharedInstance].didBleCableFinished = NO;
        if ([H2SyncStatus sharedInstance].didReportFinished) {
            [H2SyncStatus sharedInstance].didReportFinished = NO;
            //j [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(cableDoneAndReportResult) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
            DLog(@"H2 DEBUG -- RESET MCU TIME OUT");
#endif
        }
        return;
    }
    if ([H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle > 0){
#ifdef DEBUG_LIB
        DLog(@"H2 DEBUG -- RESET MCU ERROR");
#endif
        [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle--;
        [[H2AudioFacade sharedInstance] h2ResendSystemCommand];
        [self h2SyncSystemCommandResendTimerSetting];
    }else{
        [H2SyncReport sharedInstance].h2StatusCode = 0x80 | (0x0F & [H2SyncSystemCommand sharedInstance].cmdData[1]);
        if ([H2SyncReport sharedInstance].h2StatusCode == 0x80) {
            [H2SyncReport sharedInstance].h2StatusCode = FAIL_SYNC;
        }
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:[H2SyncReport sharedInstance].h2StatusCode delegateCode:DELEGATE_SYNC];
    }
}


- (void)h2SyncMeterCommandResendTask:(id)sender
{
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
#ifdef DEBUG_LIB
    DLog(@"METER COMMAND RESEND ...");
    if (![H2AudioAndBleSync sharedInstance].syncIsNormalMode) {
        if ([H2SyncSystemMessageInfo sharedInstance].systemSyncCmdAck){
            [H2SyncDebug sharedInstance].debugErrorCountMeter++;
            
        }else{
            [H2SyncDebug sharedInstance].debugErrorCountSystem++;
        }
    }
    [[H2AudioHelper sharedInstance] h2SyncDebugTask:nil];
#endif
    [[H2Timer sharedInstance] clearCableTimer];
    
    if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == SM_OMNIS_EMBRACE) {
        if ([H2ApexBioEventProcess sharedInstance].embraceEndingTimer != nil) {
            [[H2ApexBioEventProcess sharedInstance].embraceEndingTimer invalidate];
            [H2ApexBioEventProcess sharedInstance].embraceEndingTimer = nil;
        }
    }
    
    if ([H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle == 0){
        
        if ([H2BleService sharedInstance].recordMode) { // RECORD MODE
            [H2SyncReport sharedInstance].h2StatusCode = FAIL_SYNC;
            NSLog(@"METER-TIME-OUT (SYNC FAIL - RECORD)");
            //[self demoSdkSyncCableStatus:FAIL_SYNC delegateCode:DELEGATE_SYNC];
        }else{
            [H2SyncReport sharedInstance].h2StatusCode = FAIL_METER_EXISTING;
            NSLog(@"METER-TIME-OUT (METER NOT FOUND - INFO)");
            //[self demoSdkSyncCableStatus:FAIL_METER_EXISTING delegateCode:DELEGATE_SYNC];
        }
        /*
         if (([H2SyncMeterCommand sharedInstance].cmdMeterTypeId & 0x0F) == METHOD_RECORD) {
         NSLog(@"METER-TIME-OUT (SYNC FAIL)");
         [H2SyncReport sharedInstance].h2StatusCode = FAIL_SYNC;
         }else{
         NSLog(@"METER-TIME-OUT (METER NOT FOUND)");
         [H2SyncReport sharedInstance].h2StatusCode = FAIL_METER_EXISTING;
         }
         */
        
        [self h2SyncTurnOffSwitch];
        [H2SyncStatus sharedInstance].didReportFinished = YES;
        [H2SyncStatus sharedInstance].didReportSyncFail = YES;
        return;
    }else{
        [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle--;
        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
        [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
        
        UInt8 resendCommandSel = 0xFF;
        //        UInt8 varGlucoCardCmdIndex = 0;
        //       UInt8 varGlucoCardCommandTypeId = 0;
        
        if ([H2BleService sharedInstance].isBleCable) {
#ifdef DEBUG_LIB
            DLog(@"ROCHE DEBUG 0 ");
#endif
            if ((([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0x3F0) >> 4) == BRAND_ACCUCHEK) {
                // ROCHE PROCESS
#ifdef DEBUG_LIB
                DLog(@"ROCHE DEBUG 1 ");
#endif
                if ([H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd) {
                    // TO DO ...
                    [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = NO;
#ifdef DEBUG_LIB
                    DLog(@"ROCHE DEBUG 2 ");
#endif
                    [self h2CableBLERocheTalk];
                    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = 0;
                }else{ // INIT COMMAND ONLY
#ifdef DEBUG_LIB
                    DLog(@"ROCHE DEBUG 3 ");
#endif
                    [[H2AudioFacade sharedInstance] h2ResendMeterCommand];
                }
                
            }else{
#ifdef DEBUG_LIB
                DLog(@"ROCHE DEBUG 4 ");
#endif
                // OTHER METER PROCESS
                if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == SM_OMNIS_EMBRACE) {
                    if ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_ACK_RECORD) {
                        [H2ApexBioEventProcess sharedInstance].embraceEndingTimer = [NSTimer scheduledTimerWithTimeInterval:BLE_EMBRACE_ENDING_INTERVAL target:self selector:@selector(h2CableBLEEmbraceRecordEndingTask) userInfo:nil repeats:NO];
                    }else{
                        [[H2AudioFacade sharedInstance] h2ResendMeterCommand];
                    }
                }else{
                    [[H2AudioFacade sharedInstance] h2ResendMeterCommand];
                }
            }
            
            
            
        }else{ // AUDIO PROCESS
            
            switch (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0x3F0) >> 4) {
                case BRAND_ACCUCHEK:
                    
                    if ([H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd) {
                        // TO DO ...
                        
                        [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = NO;
                        [[H2DataFlow sharedDataFlowInstance] h2RocheResetMeterTask];
                        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
                        
                    }else{
                        resendCommandSel = CMD_RESEND_NORMAL;
                    }
                    break;
                    
                case BRAND_BAYER:
                    resendCommandSel = CMD_RESEND_NORMAL;
                    break;
                    
                case BRAND_CARESENS:
                case BRAND_FREESTYLE:
                case BRAND_BENECHEK:
                case BRAND_EXT_OMNIS:
                default:
                    resendCommandSel = CMD_RESEND_NORMAL;
                    break;
                    
                case BRAND_GLUCOCARD:
                case BRAND_RELION:
                    if ([GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode) {
                        resendCommandSel = CMD_RESEND_NORMAL;
#ifdef DEBUG_LIB
                        DLog(@"METER_DEBUG Resend Glucode Normal ++++ ");
#endif
                    }else{
                        resendCommandSel = CMD_RESEND_GLUCODE;
#ifdef DEBUG_LIB
                        DLog(@"METER_DEBUG Resend Glucode ----");
#endif
                    }
                    break;
                    
                case BRAND_ONETOUCH:
#ifdef DEBUG_LIB
                    DLog(@"CMD RESEND VALUE IS %04x, %04x", [H2DataFlow sharedDataFlowInstance].equipUartProtocol, (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0x00F0) >> 4));
#endif
                    if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0x000F) == 0 ) { // Ultra 2
#ifdef DEBUG_LIB
                        DLog(@"CMD RESEND ONETOUCH");
#endif
                        resendCommandSel = CMD_RESEND_ULTRA2;
                    }else{
#ifdef DEBUG_LIB
                        DLog(@"CMD RESEND NORMAL");
#endif
                        resendCommandSel = CMD_RESEND_NORMAL;
                    }
                    break;
            }
            
            switch (resendCommandSel) {
                case CMD_RESEND_NORMAL:
                    [[H2AudioFacade sharedInstance] h2ResendMeterCommand];
                    break;
                    
                default:
                    break;
                    
                    
                case CMD_RESEND_BAYER:
                    break;
                    
                case CMD_RESEND_GLUCODE:
                    [ReliOnConfirm sharedInstance].reliOnCmdIndex = 0;
                    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = 5.0f;
                    [[ReliOnConfirm sharedInstance] ReliOnCommandLoop];
                    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
                    [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
                    break;
                    
                case CMD_RESEND_ULTRA2:
                    if ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_RECORD) { // Send TURN ON SW Command
                        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                        [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = YES;
                        [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = 0;
                        // 可以直接打開SW
                        [[H2OneTouchEventProcess sharedInstance] h2SyncUltra2CmdTurnOnSwitch];
                        [self h2SyncSystemCommandResendTimerSetting];
                    }else{ // Normal, Resend Meter Command
                        
                    }
                    break;
            }
        }
        [self h2CableMeterCommandPreProcess];
    }
    
}

- (void)h2SyncSystemCommandResendTimerSetting
{
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
    [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
    if ([H2Timer sharedInstance].resendCableCmd == nil) {
        
        [H2Timer sharedInstance].resendCableCmd = [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval target:self selector:@selector(h2SyncSystemCommandResendTask:) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
        DLog(@"SYSTEM @%@ \n Cycle %d and TIME OUT is %f", [H2Timer sharedInstance].resendCableCmd, [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle,  [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval);
#endif
    }
}

- (void)h2SyncMeterCommandResendTimerSetting
{
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
    if ([H2Timer sharedInstance].resendMeterCmd == nil) {
        [H2Timer sharedInstance].resendMeterCmd = [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval
                                                                                                       target:self
                                                                                                     selector:@selector(h2SyncMeterCommandResendTask:)
                                                                                                     userInfo:nil
                                                                                                      repeats:NO];
#ifdef DEBUG_LIB
        DLog(@"NORMAL METER @%@ \n Cycle %d and TIME OUT is %f", [H2Timer sharedInstance].resendMeterCmd,[H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle,  [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval);
#endif
    }
}




unsigned char bleRocheTalk[] = {
    0x00, CMD_ROCHE_TALK, 0x00, 0x00
};

- (void)h2CableBLERocheTalk
{
    // Set Flag
    unsigned char tmp[16] = {0};
    UInt16 cmdLength = 0;
    
    cmdLength = sizeof(bleRocheTalk);
    memcpy(tmp, bleRocheTalk, sizeof(bleRocheTalk));
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:tmp withCmdLength:cmdLength cmdType:BRAND_SYSTEM returnDataLength:0 mcuBufferOffSetAt:0];
    
    [self h2SystemResendCmdInit];
}


- (void)h2SyncTurnOffSwitch
{
#ifdef DEBUG_LIB
    DLog(@"CABLE TURN OFF SWITCH");
#endif
    if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
#ifdef DEBUG_LIB
        DLog(@"ENDDING WITH DATA");
#endif
        if ([[H2SyncReport sharedInstance].h2BgRecordReportArray count] == 0) {
            [H2SyncReport sharedInstance].didSyncRecordFinished = NO;
        }
    }
    
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
    [H2SyncStatus sharedInstance].didReportFinished = YES;
    
    if ([H2Sync sharedInstance].isAudioCable) {
        _audioSystemCmd = CMD_SW_OFF;
#ifdef DEBUG_LIB
        DLog(@"ENDDING -- SW OFF  AUDIO");
#endif
    }else{
        if ([H2DataFlow sharedDataFlowInstance].equipId == SM_ONETOUCH_ULTRA2) {
            _audioSystemCmd = CMD_SW_OFF;
        }else{
            _audioSystemCmd = CMD_BLE_RESET;
        }
#ifdef DEBUG_LIB
        DLog(@"ENDDING -- RESET MCU BLE");
#endif
    }
    
    [[H2CableFlow sharedCableFlowInstance] h2CableSystemCommand:nil];
    [H2CableFlow sharedCableFlowInstance].cableTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(cableFlowSendAudioCommand) userInfo:nil repeats:NO];
    
}

         
- (void)h2CableMeterCommandPreProcess
{
    if ([H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd) {
#ifdef DEBUG_LIB
        DLog(@"DID RESEND METER COMMAND");
#endif
        [[H2CableFlow sharedCableFlowInstance] h2SyncMeterCommandResendTimerSetting];
    }else{
        if ([H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd) {
#ifdef DEBUG_LIB
            DLog(@"DID RESEND SYSTEM COMMAND");
#endif
            [[H2CableFlow sharedCableFlowInstance] h2SyncSystemCommandResendTimerSetting];
        }
    }
    // Audio Command Trigger
    if ([H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd) {
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
        [[H2DataFlow sharedDataFlowInstance] h2CableSendAudioCommand];
    }
}

#pragma mark - METER EX SETTING FOR BLE
- (void)h2CableBLEEmbraceRecordEndingTask
{
#ifdef DEBUG_LIB
    DLog(@"DEBUG_GET ALL RECORD 3 - ENDING EMBRACE");
#endif
    if ([H2SyncReport sharedInstance].didSyncFail) { // ERROR process
        
        [H2SyncReport sharedInstance].didSyncFail = NO;
        
        if ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_RECORD) {
            [H2SyncReport sharedInstance].h2StatusCode = FAIL_SYNC;
        }else{
            [H2SyncReport sharedInstance].h2StatusCode =  FAIL_METER_EXISTING;
        }
        
        [H2SyncStatus sharedInstance].didReportSyncFail = YES;
    }else{
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
    }
    
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
    [[H2CableFlow sharedCableFlowInstance] h2SyncTurnOffSwitch];
    
}

#pragma mark - INTERNAL TASK
- (void)cableFlowSendAudioCommand
{
    [[H2DataFlow sharedDataFlowInstance] h2CableSendAudioCommand];
}

- (void)cableDoneAndReportResult
{
    [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
    //[[H2Sync sharedInstance] sdkSyncReportRecords];
}



- (BOOL)bleSyncInitTask:(NSString *)bleIdentifierString
{
#ifdef DEBUG_LIB
    DLog(@"SVR SN %@", [H2BleService sharedInstance].bleScanningKey);
    DLog(@"SVR ID %@", [H2BleService sharedInstance].bleSeverIdentifier);
#endif
    
    NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:bleIdentifierString];
    if(nsUUID)
    {
        NSArray *peripheralArray = [[H2BleCentralController sharedInstance].h2CentralManager retrievePeripheralsWithIdentifiers:@[nsUUID]];
#ifdef DEBUG_LIB
        DLog(@"PERIPHERAL ARRAY FOR RE-CONNECT IS  %@", peripheralArray);
#endif
        // Check for known Peripherals
        if([peripheralArray count] > 0)
        {
            [H2BleService sharedInstance].bleDevInList = YES;
            [H2BleService sharedInstance].reconnectPeripheral = [peripheralArray objectAtIndex:0];
#ifdef DEBUG_LIB
            for(CBPeripheral *peripheral in peripheralArray)
            {
                DLog(@"Connecting to Peripheral NOT - %@", peripheral);
            }
#endif
            return YES;
        }
    }
    return NO;
}

+ (H2CableFlow *)sharedCableFlowInstance
{
    //initialize sharedObject as nil (first call only)
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
