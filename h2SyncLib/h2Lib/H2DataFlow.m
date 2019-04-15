//
//  H2DataFlow.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/9.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


#import "version.h"

#import "Fora.h"
#import "AllianceDSA.h"

#import "H2DebugHeader.h"
#import "H2Sync.h"
#import "H2CableFlow.h"
#import "H2DataFlow.h"
#import "H2AudioHelper.h"

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
#import "H2Records.h"

#import "H2Timer.h"
#import "H2LastDateTime.h"


#define BLE_BATTERY_30V         0x01A9//0
#define BLE_BATTERY_29V         0x0199//0
#define BLE_BATTERY_28V         0x0188//0
#define BLE_BATTERY_27V         0x0180//70
#define BLE_BATTERY_26V         0x0160
#define BLE_BATTERY_25V         0x0150

#define AUDIO_BATTERY_30V         0x7640//0x7300
#define AUDIO_BATTERY_29V         0x6D70//0x6F00
#define AUDIO_BATTERY_28V         0x6500//0x6A00
#define AUDIO_BATTERY_27V         0x5E00//0x6100
#define AUDIO_BATTERY_26V         0x5600
#define AUDIO_BATTERY_25V         0x4D00

unsigned char   gh2LRC;
static UInt16 showTmpLength = 0;

@interface H2DataFlow()
{
    BOOL bionimeUartFlag;
}

@end

@implementation H2DataFlow


- (id)init
{
    if (self = [super init]) {
        
        bionimeUartFlag = NO;
        _equipId = 0;
        _equipFunction = 0;
        _equipProtocolId = 0;
//        _equipBleProtocol = 0;
        _equipUartProtocol = 0;
        
//        _isBleEquipment = NO;
        _dataForEngineer = [[NSData alloc]init];
        
        _sdkActivity = NO;
        _cableUartStage = NO;
        _cableSN = [[NSString alloc] init];
        _cableFW = [[NSString alloc] init];
    }
    return self;
}


//- (void)bleDataProcess:(NSData *)h2ReportData
- (void)bleCableDataParser:(NSData *)bleCableData
{
#ifdef DEBUG_LIB
    DLog(@"DEBUG_LIB what we have received %@", bleCableData);
    DLog(@"BLE CABLE CALL REPORT ... %d", (int)bleCableData.length);
#endif
    
    // clear Timer
    [[H2Timer sharedInstance] clearCableTimer];
    
    if (bleCableData.length > 255) {
#ifdef DEBUG_LIB
        DLog(@"DATA LENGTH TOO LONG");
#endif
        return;
    }
    
    
    if (bleCableData.length - CMD_HEADER_LEN <= 0) {
        return;
    }
    [H2CmdInfo sharedInstance].receivedDataLength = bleCableData.length - CMD_HEADER_LEN - 1;
    [H2AudioAndBleSync sharedInstance].dataLength = [H2CmdInfo sharedInstance].receivedDataLength;
    
    memcpy([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer, [bleCableData bytes], bleCableData.length);
    
    
    if (([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F)) {
        
        memcpy([H2AudioAndBleSync sharedInstance].dataHeader, [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer, CMD_HEADER_LEN);
        memcpy([H2AudioAndBleSync sharedInstance].dataBuffer, &[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN], [H2AudioAndBleSync sharedInstance].dataLength);
#ifdef DEBUG_LIB
        for (int i = 0; i<[H2AudioAndBleSync sharedInstance].dataLength; i++) {
            DLog(@"BLE DATA addr = %d data = %02X\n", i, [H2AudioAndBleSync sharedInstance].dataBuffer[i]);
        }
        for (int i = 0; i<CMD_HEADER_LEN; i++) {
            DLog(@"BLE HEADER addr = %d data = %02X\n", i, [H2AudioAndBleSync sharedInstance].dataHeader[i]);
        }
#endif
        
        [self XXXreceivedDataFromMeterVendorBrand];
    }else{
        [self XXXcableDataParser];
    }
}



- (void)audioCableDataParser:(uint8_t)ch
{
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
        return;
    }
    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[[H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex] = ch;
    
    switch ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState) {
        case BUFFERBUSY:
            if ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex == (2+VENDOROFFSET)) {
                memcpy(&showTmpLength, &[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[1+VENDOROFFSET], 2);
            }
#ifdef DEBUG_LIB
            DLog(@"yes addr = %d data = %02X\n", [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex, [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[[H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex]);
#endif
            if ( [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex >= (2+VENDOROFFSET) && [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex == showTmpLength-1) {
                
                
                gh2LRC = [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[0];
                for(int i = 1; i<[H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex; i++){
                    gh2LRC ^= [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[i];
                    
                }// Command checking
                if (gh2LRC == [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[[H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex]) {
                    
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFEROK;
                    
                    [H2CmdInfo sharedInstance].receivedDataLength = [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex - CMD_HEADER_LEN;
                    
                    if (([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN] == 0x07 && [H2CmdInfo sharedInstance].receivedDataLength == 1)){
                        
                        [H2SyncSystemMessageInfo sharedInstance].systemSyncCmdAck = YES;
#if 0
#ifdef DEBUG_LIB
                        DLog(@"METER_DEBUG, ACK RTimer instance 0 @%@", [H2Timer sharedInstance].resendMeterCmd);
#endif
                        if (![GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode) {
                            if (([h2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F) ==  BRAND_GLUCOCARD || ([h2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F) == BRAND_RELION ||
                                ([h2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F) == BRAND_EXT_B) {
                                
                                if ([H2SyncMeterCommand sharedInstance].cmdData[0] == '|' || [H2SyncMeterCommand sharedInstance].cmdData[0] == 0x6 || [H2SyncMeterCommand sharedInstance].cmdData[0] == 0x92 || [H2SyncMeterCommand sharedInstance].cmdData[0] == 0x05){
#ifdef DEBUG_LIB
                                    DLog(@"clear do nothing ----- %02X", [H2SyncMeterCommand sharedInstance].cmdData[0]);
#endif
                                }else{
                                    [[H2Timer sharedInstance] clearCableTimer];
#ifdef DEBUG_LIB
                                    DLog(@"clear the resend timer +++++ %02X", [H2SyncMeterCommand sharedInstance].cmdData[0]);
#endif
                                }
                            }
                        }
#endif
                    }else{
                        
                        if ([GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode) {
                            [[H2Timer sharedInstance] clearCableTimer];
                        }else{
                            if (([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F) ==  BRAND_GLUCOCARD || ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F) == BRAND_RELION ||
                                ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F) == BRAND_EXT_B) {
                                if ([ReliOnConfirm sharedInstance].reliOnDataStart) {
                                    [[H2Timer sharedInstance] clearCableTimer];
                                }
                            }else{
                                [[H2Timer sharedInstance] clearCableTimer];
                            }
                        }
                        
#ifdef DEBUG_LIB
                        DLog(@"LENGTH NOT EQUAL TO 1\n");
#endif
                    }
                    
#ifdef DEBUG_LIB
                    DLog(@"good data here --------%02X\n", ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex+1));
#endif
                    /*
                     if ([H2SyncStatus sharedInstance].cableSyncStop) {
                     [[H2Timer sharedInstance] clearCableTimer];
                     [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(h2SyncStopEx:) userInfo:nil repeats:NO];
                     }else{
                     */
                    if (([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F)) {
                        
                        [H2AudioAndBleSync sharedInstance].dataLength = [H2CmdInfo sharedInstance].receivedDataLength;
                        memcpy([H2AudioAndBleSync sharedInstance].dataHeader, [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer, CMD_HEADER_LEN);
#ifdef DEBUG_LIB
                        DLog(@"the data buffer size is %02X", [H2AudioAndBleSync sharedInstance].dataBuffer[6]);
                        DLog(@"the GLOBAL buffer size is %02X", [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[0]);
#endif
                        memcpy(&[H2AudioAndBleSync sharedInstance].dataBuffer[0], &[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN], [H2AudioAndBleSync sharedInstance].dataLength);
#ifdef DEBUG_LIB
                        for (int i = 0; i<[H2AudioAndBleSync sharedInstance].dataLength; i++) {
                            DLog(@"FS - IDX = %03d, %02X, %02X HAHA ", i, [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN + i], [H2AudioAndBleSync sharedInstance].dataBuffer[i]);
                        }
#endif
                        [self XXXreceivedDataFromMeterVendorBrand];
                        
                    }else{
                        [self XXXcableDataParser];
                    }
                    //j                    }
                    
                    
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
                    
                } else {
                    /*
                     if ([H2SyncStatus sharedInstance].cableSyncStop) {
                     [[H2Timer sharedInstance] clearCableTimer];
                     [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(h2SyncStopEx:) userInfo:nil repeats:NO];
                     }
                     */
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
#ifdef DEBUG_LIB
                    DLog(@"error message ....");
#endif
                }
                [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex = 0;
#ifdef DEBUG_LIB
                DLog(@"FORA - GD40A return Length %02x, %d\n", ch, [H2CmdInfo sharedInstance].receivedDataLength);
#endif
            }else{
                [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex++;
            }
            break;
            
        default:
#ifdef DEBUG_LIB
            DLog(@"noise is here %d.", [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState);
#endif
            break;
            
        case BUFFERIDLE:
#ifdef DEBUG_LIB
            DLog(@"idle here %d, 0x%02X", [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex, [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[[H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex]);
#endif
            switch ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex) {
                case 0:
                    if ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[0] == '$' ){
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex++;
                    }else{
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex=0;
                    }
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
                    break;
                case 1:
                    if ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[1] == 'H' ){
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex++;
                    }else{
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex=0;
                    }
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
                    break;
                case 2:
                    if ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[2] == '2' ){
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex++;
                    }else{
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex=0;
                    }
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
                    break;
                case 3:
                    if ([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[3] == 'S' ){
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERBUSY;
                    }else{
                        [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
                    }
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex=0;
                    break;
                    
                default:
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex=0;
                    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
                    break;
            }
            break;
    }
}


- (void)XXXcableDataParser
{
    BOOL uartNormal = YES;
    NSMutableArray *engineerCheckArray = [[NSMutableArray alloc]init];
    
    UInt8 cableCode = [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN + 1];
   
    
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = SYSTEM_NORMAL_RESEND_INTERVAL;
    
    [H2AudioAndBleCommand sharedInstance].cmdInterval = CABLE_NORMAL_CMD_INTERVAL;
    
    if ([H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex == SYNC_INFO_CABLE_STATUS_SIZE) {
        [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex = 0;
    }
    [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatus[[H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex] = cableCode;
    [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex++;
    if (!_sdkActivity) {
        [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatus[[H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatusIndex-1] += 0x10;
        //DLog(@"BEFORE %02X", );
        return;
    }
    
    [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
    if (!([H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[BRAND_AT_1] & 0x3F)) {
        [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = 4;
        // REPORT STATUS
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:cableCode delegateCode:DELEGATE_DEVELOP];
#ifdef DEBUG_LIB
        DLog(@"CABLE Did COME HERE ....");
#endif
        switch (cableCode) {
        
            case ACK_TEST: // Enginering data

                [H2SyncStatus sharedInstance].sdkFlowActive = NO;
                _dataForEngineer = [NSData dataWithBytes:&[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN] length: [H2CmdInfo sharedInstance].receivedDataLength];
                [engineerCheckArray addObject:[H2MeterSystemInfo sharedInstance]];
                // ENGINEER REPORT
                [[H2AudioHelper sharedInstance] h2AudioLongRunReport:engineerCheckArray];
                break;
                
            case SUCCEEDED_SWITCH_ON:
                switch ([H2DataFlow sharedDataFlowInstance].equipUartProtocol) {
                    case SM_ONETOUCH_ULTRA2:
                        [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(h2SyncUltra2ReadRecordTask) userInfo:nil repeats:NO];
                        break;
                        
                    case SM_OMNIS_EMBRACE:
                        [self h2EmbraceExternalSetting];
                        
                        [H2CableFlow sharedCableFlowInstance].cableTimer = [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2CableSendAudioCommand) userInfo:nil repeats:NO];
                        break;
                        
                    case SM_BAYER_BREEZE2:
                    case SM_BAYER_CONTOUR:
                    case SM_BAYER_CONTOURNEXTEZ:
                    case SM_BAYER_CONTOURXT:
                    case SM_BAYER_TS:
                    case SM_BAYER_PLUS:
                    case SM_BAYER_EXT_6:
                    case SM_BAYER_EXT_7:
                        if ([JJBayerContour sharedInstance].didBayerSyncRunning && [JJBayerContour sharedInstance].isBayerOldFWVersion) {
                            
                            [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(h2BayerExternalSetting) userInfo:nil repeats:NO];
                        }
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case SUCCEEDED_SWITCH_OFF:
                if ([H2BleService sharedInstance].isBleCable) {
                    if ([H2DataFlow sharedDataFlowInstance].equipId == SM_ONETOUCH_ULTRA2) {
                        [H2CableFlow sharedCableFlowInstance].audioSystemCmd = CMD_BLE_RESET;
                        [[H2CableFlow sharedCableFlowInstance] h2CableSystemCommand:nil];
                    }
                }else{
                    if ([H2SyncStatus sharedInstance].didReportFinished) {
                        [H2SyncStatus sharedInstance].didReportFinished = NO;
                        [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(dataFlowReportRecords) userInfo:nil repeats:NO];
                    }
                }
                break;
                
            case SUCCEEDED_CABLE_UART_INIT:// synchronous start
                [H2SyncStatus sharedInstance].didMeterUartReady = YES;
                
                switch ([H2DataFlow sharedDataFlowInstance].equipUartProtocol) {
                    case SM_CARESENS_EXT_9_BIONIME:
                        if (!bionimeUartFlag) {
                            //bionimeUartFlag = NO;
                        //}else{
                            bionimeUartFlag = YES;
                            uartNormal = NO;
                        }
                    break;
                        
                    default:
                    break;
                        
                }
                
                if (uartNormal) {
                    if ([JJBayerContour sharedInstance].didSkipMeterInfo) {
                        [[H2Sync sharedInstance] sdkSendMeterInfo];
#ifdef DEBUG_LIB
                        DLog(@"BAYER_DEBUG UART INIT 2");
                        DLog(@"BAYER_DEBUG BUFFER ANY TIME AF UART %lu ---- ********", (unsigned long)[[H2SyncReport sharedInstance].h2BgRecordReportArray count]);
#endif
                    }else{
                        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(h2SyncInit:) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
                        DLog(@"BAYER_DEBUG UART INIT 1");
#endif
                    }
                }else{
                    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(h2MeterSelect:) userInfo:nil repeats:NO];
                }

                

                break;
                
            case SUCCEEDED_PRE_COMMAND: // meter external talk ...
                
                [self h2EmbraceGetAllRecord];
                [H2CableFlow sharedCableFlowInstance].cableTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(h2CableSendAudioCommand) userInfo:nil repeats:NO];
                
#ifdef DEBUG_LIB
                DLog(@"pre command come back here");
#endif
                break;
                
            case SUCCEEDED_CABLE_EXIST:
                bionimeUartFlag = NO;
                [self cableExistingProcess];
                break;
                
            case SUCCEEDED_CABLE_VERSION:
                [self cableVersionProcess];
                
                break;
                
            case ACK_SN:// Serial Number
#ifdef DEBUG_LIB                
                DLog(@"get serial Number --- ++++ -----");
#endif

                break;
                
            case SUCCEEDED_ROCHE_TALK:
#ifdef DEBUG_LIB
                DLog(@"BLE ROCHE, DEBUG_ACCU_CHEK -----");
#endif
                // Set Reset BLE cable Timer for Roche
                [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(h2RocheResetMeterTask) userInfo:nil repeats:NO];
                
                break;
                
            default:
                break;
        }
    }
}







- (void)XXXreceivedDataFromMeterVendorBrand
{
#ifdef DEBUG_LIB
    if ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_RECORD) {
        DLog(@"METER_VENDOR ....%@", [H2AudioAndBleSync sharedInstance]);
        DLog(@"METER_RECORD ....");
    }
    DLog(@"METER_VENDOR ....");
    DLog(@"METER_VENDOR ....%02X @%@", [H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1], [H2AudioAndBleSync sharedInstance]);
#endif
    
    // Cable ACK while receive Meter Command
    if ([H2AudioAndBleSync sharedInstance].dataBuffer[0] == 0x07 && [H2CmdInfo sharedInstance].receivedDataLength == 1){
        // FOR AUDIO CABLE
        if ([GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode) {
            [self h2SyncReportBufferInit];
            return;
        }else{
            // FOR OLD OLD CABLE
            
            if ([ReliOnConfirm sharedInstance].reliOnCmdIndex > 0) { // current command
                if ([ReliOnConfirm sharedInstance].reliOnCmdBuffer[[ReliOnConfirm sharedInstance].reliOnCmdIndex-1]  == '|') {
#ifdef DEBUG_LIB
                    DLog(@"RELICON COMMAND DATA == %02X PPPP", [ReliOnConfirm sharedInstance].reliOnCmdBuffer[[ReliOnConfirm sharedInstance].reliOnCmdIndex-1] );
#endif
                    [self h2SyncReportBufferInit];
                    return;
                }
            }else{
                // TO DO
                if (!(([H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1] & 0x3F) ==  BRAND_GLUCOCARD || ([H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1] & 0x3F) ==  BRAND_RELION)) {
                    [self h2SyncReportBufferInit];
                    return;
                }
            }
        }
    }
    
    
    if ([H2BleService sharedInstance].isBleCable) {
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
    }else{
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
    }
    
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = SYSTEM_NORMAL_RESEND_INTERVAL;
    
    // TO DO //
    if ([GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode) {
        [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = METER_NORMAL_RESEND_CYCLE;
#ifdef DEBUG_LIB
        DLog(@"HIGH SPEED NEED SET RESEND_CYCLE");
#endif
    }else{
        if (!(([H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1] & 0x3F) ==  BRAND_GLUCOCARD || ([H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1] & 0x3F) ==  BRAND_RELION)) {
#ifdef DEBUG_LIB
            DLog(@"LOW SPEED NEED SET RESEND_CYCLE");
#endif
            [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = METER_NORMAL_RESEND_CYCLE;
        }
    }
    
    
    [H2AudioAndBleCommand sharedInstance].cmdInterval = 0.2f;
    
#ifdef DEBUG_LIB
    DLog(@"METER_VENDOR ....%02X", [H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1]);
#endif
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1] & 0x0F) {
        case BRAND_ACCUCHEK:
            [[H2RocheEventProcess sharedInstance] h2RocheInfoRecordProcess];
            if ( [H2BleService sharedInstance].isBleCable) {
                [H2AudioAndBleCommand sharedInstance].cmdInterval = ROCHE_BLE_CMD_INTERVAL;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdInterval = ROCHE_AUDIO_CMD_INTERVAL;
            }
            break;
            
        case BRAND_BAYER:
            [[H2BayerEventProcess sharedInstance] h2BayerInfoRecordProcess];
            break;
            
        case BRAND_CARESENS:
            if ([H2DataFlow sharedDataFlowInstance].equipUartProtocol == SM_ONETOUCH_ULTRA_VUE) {
                [[H2OneTouchEventProcess sharedInstance] h2OneTouchInfoRecordProcess];
            }else{
                [[H2iCareSensEventProcess sharedInstance] h2CareSensInfoRecordProcess];
            }
            
            break;
            
        case BRAND_FREESTYLE:
#ifdef DEBUG_LIB
            DLog(@"FS CRASH - BEFORE" );
#endif
            [[H2FreeStyleEventProcess sharedInstance] h2FreeStyleInfoRecordProcess];
#ifdef DEBUG_LIB
            DLog(@"FS CRASH - AFTER" );
#endif
            break;
            
        case BRAND_GLUCOCARD:
        case BRAND_RELION:
#ifdef DEBUG_LIB
            DLog(@"ULTRA XXX --B--DEBUG %04X", _equipProtocolId );
#endif
            if (_equipProtocolId == SM_ONETOUCH_ULTRA_) {
                [[H2OneTouchEventProcess sharedInstance] h2OneTouchInfoRecordProcess];
            }else{
                [[H2GlucoCardEventProcess sharedInstance] h2GlucoCardInfoRecordProcess];
            }
            break;
            
        case BRAND_ONETOUCH:
#ifdef DEBUG_LIB
            DLog(@"METER_VENDOR ....555");
            if ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_RECORD) {
                DLog(@"METER_VENDOR ....%02X", [H2AudioAndBleSync sharedInstance].dataHeader[BRAND_AT_1]);
                DLog(@"METER_RECORD ....");
            }
#endif
            [[H2OneTouchEventProcess sharedInstance] h2OneTouchInfoRecordProcess];
            break;
            
        case BRAND_BENECHEK:
            [[H2BeneChekEventProcess sharedInstance] h2BeneChekInfoRecordProcess];
            break;
            
        case BRAND_EXT_OMNIS:
            [[H2ApexBioEventProcess sharedInstance] ApexBioEventProcess];
            break;
            
            
        default:
            break;
    }
    
    
    // Data Process finally ....
    // 1. Sync Fail Process
    // 2. Send Equipment Info
    // 3. Single or Multi Records Process
    // 4. Finished Process
    
    
    if ([H2SyncReport sharedInstance].didSyncFail || [H2SyncReport sharedInstance].didSendEquipInformation || [H2SyncReport sharedInstance].didSyncRecordFinished){
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
        [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
    }
    
    // Report Single Record
    if ([H2SyncReport sharedInstance].hasSMSingleRecord) {
        [[H2SyncReport sharedInstance].recordsArray addObject:[H2Records sharedInstance].bgTmpRecord];
        [[H2Sync sharedInstance] sdkReportMeterDateTimeValueSingle:nil];
#ifdef DEBUG_LIB
        DLog(@"BLE DEBUG -- NEED REPORT SINGLE RECORD");
#endif
    }
    
    if ([H2SyncReport sharedInstance].hasMultiRecords) {
        // TO DO ...
        [[H2Sync sharedInstance] sdkReportMeterDateTimeValueSingle:nil];
        [H2SyncReport sharedInstance].hasMultiRecords = NO;
#ifdef DEBUG_LIB
        DLog(@"BLE DEBUG -- NEED REPORT MULTI RECORDS");
#endif
    }
    
    
    if ([H2SyncReport sharedInstance].didSyncFail){
        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
        
        [H2SyncReport sharedInstance].didSyncFail = NO;
        
        if ([H2SyncReport sharedInstance].didEquipInfoDone) {
            [H2SyncReport sharedInstance].h2StatusCode = H2SSDKSyncStatusFail;
        }else{
            [H2SyncReport sharedInstance].h2StatusCode =  FAIL_METER_EXISTING;
        }
#ifdef DEBUG_LIB
        DLog(@"EMBARCE ERROR HAPPEN ... oh ~");
#endif
        [H2SyncStatus sharedInstance].didReportSyncFail = YES;
        [[H2CableFlow sharedCableFlowInstance] h2SyncTurnOffSwitch];
        
    }else if([H2SyncReport sharedInstance].didSendEquipInformation){
        // TO DO ...
        [[H2Sync sharedInstance] sdkEquipInfoProcess:[H2Records sharedInstance].dataTypeFilter withSvrUserId:[H2Records sharedInstance].equipUserIdFilter];
#ifdef DEBUG_LIB
        DLog(@"BLE DEBUG -- NEED REPORT METER INFORMATION");
#endif
        // Report Meter Information
        if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
//            [self h2CableFinishTask];
        }
        
    }else if([H2SyncReport sharedInstance].didSyncRecordFinished){
        DLog(@"CABLE FINISHED");
        [self h2CableFinishTask];
    }else{
        // Send Pre-Command
        // when meter be reset after error happen, app send Pre-meter command
        // Like Roche, GlucoCard
        if ([H2RocheEventProcess sharedInstance].didSendMeterPreCmd) {
            [H2RocheEventProcess sharedInstance].didSendMeterPreCmd = NO;
            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = 0;
            [[H2AudioFacade sharedInstance] h2SendMeterPreCommand];
#ifdef DEBUG_LIB
            DLog(@"BLE_DEBUG ROCHE SEND PRE COMMAND  ... ...");
#endif
        }
        // RE-OPEN
        // For Roche in BLE, because BLE not return meter Ending Data,
        // So app delay a few time than send TURN OFF SWITCH command

        if ([H2RocheEventProcess sharedInstance].didSkipMeterEndCmd) {
#ifdef DEBUG_LIB
            DLog(@"BLE_DEBUG ROCHE END AND SWITCH OFF  ... ...");
#endif
            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
            
            // Skip BLE some data ....Roche doesn't Return Ending
            [H2BleCentralController sharedInstance].didSkipBLE = YES;
            
            [H2AudioAndBleCommand sharedInstance].cmdInterval = 1.3f;
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2CableTurnOffSwitch) userInfo:nil repeats:NO];
        }

        //
        // Config New Meter Command for Resend it, included Cycle and Interval
        if ([H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd) {
            [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = METER_NORMAL_RESEND_CYCLE;
            
            [[H2CableFlow sharedCableFlowInstance] h2SyncMeterCommandResendTimerSetting];
#ifdef DEBUG_LIB
            DLog(@"BLE_DEBUG RESEND METER COMMAND FLAG YES YES ... ...");
#endif
        }
        // Config New System Command for Resend it, EMBRACE need to this, included Cycle and Interval
        // ULTRA 2 need or not ???
        if ([H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd) {
            [[H2CableFlow sharedCableFlowInstance] h2SyncSystemCommandResendTimerSetting];
        }
        
        
        // Only Audio interface need to do this, audio send data immediately
        if ([H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd) {
#ifdef DEBUG_LIB
            DLog(@"BLE_DEBUG DID SEND AUDIO COMMAND ... ...");
#endif
            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            [H2CableFlow sharedCableFlowInstance].cableTimer = [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2CableSendAudioCommand) userInfo:nil repeats:NO];
        }
    }
    
#ifdef DEBUG_LIB
    DLog(@"WHAT ULTRA 2 HAPPEN ???");
#endif
}






- (void)h2SyncReportBufferInit
{
    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferIndex = 0;
    [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState = BUFFERIDLE;
#ifdef DEBUG_LIB
    DLog(@"Buffer Previous Status is %02X.\n", [H2SyncSystemMessageInfo sharedInstance].systemGlobalBufferState);
#endif
}

#pragma mark - SN PROCESS
- (NSString *)cableNumberProcess:(NSData *)serialNumber
{
    NSString *returnSN;
#ifdef DEBUG_LIB
    DLog(@"serial number check");
#endif
    NSUInteger len = [serialNumber length];
    Byte *byteData = (Byte *)malloc(len);
    unsigned char tmp;
    unsigned char ch[16]= {0};
    UInt32 sn = 0;
    UInt8  year;
    UInt8  month;
    NSString *customer;
    NSString *model;
    
    memcpy(byteData, [serialNumber bytes], len);
#ifdef DEBUG_LIB
    for (int i = 0; i< len; i++) {
        DLog(@"%02X", byteData[i]);
    }
#endif
    tmp = byteData[0];
    for (int i = 1; i<len-1; i++) {
        tmp ^= byteData[i];
    }
    
    if (len == SN_LEN_CABLE_NEW) {
        _cableSN = [NSString stringWithUTF8String:(const char *)ch];
        return _cableSN;
    }
    
    
#ifdef DEBUG_LIB
    DLog(@"the tmp is %02X", tmp);
#endif
    memcpy(ch, (byteData+4), 2);
    customer = [NSString stringWithUTF8String:(const char *)ch];
    
    memcpy(ch, byteData, 2);
    model = [NSString stringWithUTF8String:(const char *)ch];
    
    if (ch[0] == 0xFF) {
        returnSN = [NSString stringWithFormat:@"  SN : %@", @"No Serial Number"];
    }else{
        memcpy(&sn, (byteData+6), 3);
        memcpy(&year, (byteData+2), 1);
        memcpy(&month, (byteData+3), 1);
        [serialNumber getBytes:&sn range:NSMakeRange(6, 3)];
#ifdef DEBUG_LIB
        DLog(@"the serial number is %06d", (unsigned int)sn);
#endif
        _cableSN = nil;
        if (tmp == byteData[len-1]) {
            returnSN = [NSString stringWithFormat:@"  SN : %@%02d%02d%@%06d", model, year, month, customer, (unsigned int)sn];
            _cableSN = [NSString stringWithFormat:@"%@%02d%02d%@%06d", model, year, month, customer, (unsigned int)sn];
        }else{
            returnSN = [NSString stringWithFormat:@"  SN :FAIL"];
        }
    }
    return returnSN;
}

#pragma mark - METER EX SETTING
- (void)h2RocheResetMeterTask
{
    //    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_4;
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_INIT;
    [[H2RocheEventProcess sharedInstance] h2SynRocheResetMeter];
    
    // Only Send 1 time
    // Disable for Normal Resend Command
    //    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = 0;
    [[H2CableFlow sharedCableFlowInstance] h2SyncMeterCommandResendTimerSetting];
}



- (void)h2SyncUltra2ReadRecordTask
{
    [[H2OneTouchEventProcess sharedInstance] h2SyncUltra2ReadRecord];
    
    [[H2CableFlow sharedCableFlowInstance] h2SyncMeterCommandResendTimerSetting];
    
    [self h2CableSendAudioCommand];
}

- (void)h2BayerExternalSetting
{
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
    [[H2BayerEventProcess sharedInstance] h2SyncBayerGeneral];
    
    
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = METER_BAYER_RESEND_INTERVAL;
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = METER_NORMAL_RESEND_CYCLE;
    [[H2CableFlow sharedCableFlowInstance] h2SyncMeterCommandResendTimerSetting];
}

- (void)h2GlucoCardResetMeterTask{
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_INIT;
    [[H2GlucoCardEventProcess sharedInstance] h2SynGlucoCardResetMeter];
}

- (void)h2EmbraceGetAllRecord
{
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_ACK_RECORD;
    [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisGeneral];
    
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = METER_EMBRACE_RESEND_INTERVAL;
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = METER_NORMAL_RESEND_CYCLE;
    [[H2CableFlow sharedCableFlowInstance] h2SyncMeterCommandResendTimerSetting];
}
- (void)h2EmbraceExternalSetting
{
    [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisCmdRecordAllCoef];
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdCycle = SYSTEM_NORMAL_RESEND_CYCLE;
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = 1.2f;
    [[H2CableFlow sharedCableFlowInstance] h2SyncSystemCommandResendTimerSetting];
}


- (void)h2CableSendAudioCommand
{
#ifdef DEBUG_LIB
    DLog(@"AUDIO_DEBUG ----  CABLE CABLE WILL SEND COMMAND");
#endif
    if ([H2Sync sharedInstance].isAudioCable) {
        [[H2AudioFacade sharedInstance] h2AudioTriggerCommand];
    }
}


#pragma mark -
#pragma mark Meter select & uart init methods

////////////
- (void)h2MeterSelect:(id)sender
{
    [H2CmdInfo sharedInstance].meterRecordCurrentIndex = 0;
    
    [H2CableParameter sharedInstance].cmdCableStatus = 0;
    [JJBayerContour sharedInstance].didSkipMeterInfo = NO;
    [H2BayerEventProcess sharedInstance].bayerTag = '0';

    [H2RocheEventProcess sharedInstance].didSendMeterPreCmd = NO;
    

    [H2SyncReport sharedInstance].reportMeterInfo.bgLastDateTime = @"";
    [H2SyncReport sharedInstance].reportMeterInfo.bpLastDateTime = @"";
    [H2SyncReport sharedInstance].reportMeterInfo.bwLastDateTime = @"";
    
    [H2SyncReport sharedInstance].reportMeterInfo.smModelName = @"";
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = @"";
    [H2SyncReport sharedInstance].reportMeterInfo.smBrandName = @"";
    [H2SyncReport sharedInstance].reportMeterInfo.smVersion = @"";

#ifdef DEBUG_LIB
    NSLog(@"EQ-ID -> %08X", (int)[H2DataFlow sharedDataFlowInstance].equipId);
    NSLog(@"EQ-P -> %08X", [H2DataFlow sharedDataFlowInstance].equipProtocolId);
    NSLog(@"EQ-U -> %08X", [H2DataFlow sharedDataFlowInstance].equipUartProtocol);
#endif
    
    //[H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = 0;
    
    switch ([H2DataFlow sharedDataFlowInstance].equipUartProtocol) {
            
        case SM_ACCUCHEK_AVIVANANO:
        case SM_ACCUCHEK_NANO:
        case SM_ACCUCHEK_PERFOMA:
            
        case SM_ACCUCHEK_PERFOMA_II:
        case SM_ACCUCHEK_EXT_5:
        case SM_ACCUCHEK_EXT_6:
        case SM_ACCUCHEK_EXT_7:
            
        case SM_ACCUCHEK_AVIVA:
        case SM_ACCUCHEK_EXT_8:
        case SM_ACCUCHEK_EXT_9:
            
        case SM_ACCUCHEK_COMPACTPLUS:
        case SM_ACCUCHEK_ACTIVE:
        case SM_ACCUCHEK_EXT_C:
        case SM_ACCUCHEK_EXT_D:
        case SM_ACCUCHEK_EXT_E:
        case SM_ACCUCHEK_EXT_F:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= (UART_IR_MASK | SW_NorNorTR_MASK);
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
            [H2AudioAndBleCommand sharedInstance].newRecordAtFinal = YES;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_InvNorTR_MASK;
            break;
            
            
        case SM_CARESENS_ISENSN:
        case SM_CARESENS_ISENSNPOP:
            
        case SM_CARESENS_EXT_2:
        case SM_CARESENS_EXT_3:
        case SM_CARESENS_EXT_4:
        case SM_CARESENS_EXT_5:
        case SM_CARESENS_EXT_6:
            
        case SM_CARESENS_EXT_C_DSA:
        case SM_CARESENS_EXT_D:
        case SM_CARESENS_EXT_E:
        case SM_CARESENS_EXT_F:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            break;
            
        case SM_CARESENS_EXT_9_BIONIME:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            if (!bionimeUartFlag) { // Normal
                
            //}else{
                // INIT
                [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= UART_MINIB_MASK;
            }
            break;
            
        case SM_CARESENS_EXT_A_HMD_GL:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_TRG;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_InvInvTR_MASK;
            
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate |= UART_2STOP_MASK;
            break;
            
            
        case SM_CARESENS_EXT_7_TB200:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_4800;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate |= UART_EVEN_MASK;
            break;
            
        case SM_CARESENS_EXT_8_EMBRACE_PRO:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_RTG;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            break;
            
        case SM_CARESENS_EXT_B_FORA_GD40A:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GTR;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_19200;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_InvInvTR_MASK;
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
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GTR;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_19200;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_InvInvTR_MASK;
            
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
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_19200;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_InvNorTR_MASK;
            break;
            
        case SM_ONETOUCH_ULTRA2:
        case SM_ONETOUCH_ULTRALIN:
        case SM_ONETOUCH_ULTRAMINI:
        case SM_ONETOUCH_ULTRAEASY:
            
        case SM_ONETOUCH_EXT_4:
        case SM_ONETOUCH_EXT_5:
        case SM_ONETOUCH_EXT_6:
        case SM_ONETOUCH_EXT_7:
            
        case SM_ONETOUCH_EXT_8:
        case SM_ONETOUCH_EXT_9:
            //        case SM_ONETOUCH_EXT_A:
        case SM_ONETOUCH_EXT_B:
        case SM_ONETOUCH_EXT_C:
        case SM_ONETOUCH_EXT_D:
        case SM_ONETOUCH_EXT_E:
        case SM_ONETOUCH_EXT_F:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            break;
            
        case SM_ONETOUCH_ULTRA_VUE:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_38400;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            break;
            
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
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_19200;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_InvNorTR_MASK;
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
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_TRG;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_38400;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            break;
            
            
        case SM_OMNIS_EMBRACE:
        case SM_OMNIS_EMBRACE_EVO:
        case SM_GLUCOSURE_VIVO:
        case SM_EVENCARE_G2:
        case SM_EVENCARE_G3:
        case SM_OMNIS_AUTOCODE:
        case SM_EXT_OMNIS6:
        case SM_Embrace_TOTAL:
            
#if 1
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GTR;
#else
            // for G3 test
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
#endif
            
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_19200;
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            break;
            
        case SM_APEX_BG001_C:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GTR;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_19200;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= (UART_MINIB_MASK | SW_NorNorTR_MASK);
            break;
            
        case SM_EXT_OMNIS_C:
        case SM_EXT_OMNIS_D:
        case SM_EXT_OMNIS_E:
        case SM_EXT_OMNIS_F:
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch = SW_GRT;
            [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate = UART_9600;
            
            [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch |= SW_NorNorTR_MASK;
            break;
            
            
            
        default:
            return;
            break;
    }
#ifdef DEBUG_LIB
    DLog(@"METER SELECT ----------------------");
#endif
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = @"";
    [H2SyncReport sharedInstance].reportMeterInfo.smBrandName = @"";
    [H2SyncReport sharedInstance].reportMeterInfo.smModelName = @"";
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = @"";
    
    [H2SyncReport sharedInstance].serverBgLastDateTime = DEF_LAST_DATE_TIME;
    
    [self h2CableUartInit:nil];
}

unsigned char cableUartInit[] = {
    0x00, CMD_UART_INIT, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

- (void)h2CableUartInit:(id)sender
{
    
    [H2BayerEventProcess sharedInstance].bayerParam = 0x2E;
    [H2BayerEventProcess sharedInstance].bayerTag = '0';
    UInt8 idx;
    //[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentMeterTime"];
    
    [JJBayerContour sharedInstance].didBayerSyncRunning = NO;

    
    unsigned char tmp2[sizeof(cableUartInit)];
    memcpy(tmp2, cableUartInit, sizeof(cableUartInit));
    
    tmp2[NORINV_SWITCH_ADDR] = [H2CmdInfo sharedInstance].cmdIrDAMiniBNorInvZeroSwitch;
    tmp2[UART_BAUDRATE_ADDR] = [H2CmdInfo sharedInstance].cmdUartLenStopParityBaudRate;
    
    //        DATE_FOR_COMPARE_ADDR
    NSUInteger characterCount = [[H2SyncReport sharedInstance].serverBgLastDateTime length];
    char ch[32];
    
    // METER FW COMMAND DELAY TIME FOR AUDIO
    switch (([H2DataFlow sharedDataFlowInstance].equipUartProtocol >> 4) & 0x3F) {
        case BRAND_ACCUCHEK:
            tmp2[DATE_FOR_COMPARE_ADDR] = ACCU_CHEK_DELAY;
            break;
            
        case BRAND_BAYER:
            tmp2[DATE_FOR_COMPARE_ADDR-1] = 0x12; // SKIP RECORDS ( + 8 << 1) TIME AND DELAY CYCLE * 16
            for (idx = 0; idx<characterCount; idx++) {
                ch[idx] = [[H2SyncReport sharedInstance].cableBayerLastDateTime characterAtIndex:idx];
            }
            tmp2[DATE_FOR_COMPARE_ADDR] = ((ch[0] & 0x0F)<<4) | (ch[1] & 0x0F);
            tmp2[DATE_FOR_COMPARE_ADDR+1] = ((ch[2] & 0x0F)<<4) | (ch[3] & 0x0F);
            tmp2[DATE_FOR_COMPARE_ADDR+2] = ((ch[5] & 0x0F)<<4) | (ch[6] & 0x0F);
            tmp2[DATE_FOR_COMPARE_ADDR+3] = ((ch[8] & 0x0F)<<4) | (ch[9] & 0x0F);
            tmp2[DATE_FOR_COMPARE_ADDR+4] = ((ch[11] & 0x0F)<<4) | (ch[12] & 0x0F);
            tmp2[DATE_FOR_COMPARE_ADDR+5] = ((ch[14] & 0x0F)<<4) | (ch[15] & 0x0F);
            break;
            
        case BRAND_GLUCOCARD:
        case BRAND_RELION:
            tmp2[DATE_FOR_COMPARE_ADDR] = RELION_DELAY;
            break;
            
        default:
            break;
    }
    
    if (_equipProtocolId == SM_ONETOUCH_ULTRA_) {
        tmp2[DATE_FOR_COMPARE_ADDR] = RELION_DELAY;
    }
    
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:tmp2 withCmdLength:sizeof(cableUartInit) cmdType:BRAND_SYSTEM returnDataLength:0 mcuBufferOffSetAt:0];
    
    if (![JJBayerContour sharedInstance].goToNextYearStage) {
        [[H2SyncReport sharedInstance].h2BgRecordReportArray removeAllObjects];
    }
    
#ifdef DEBUG_LIB
    DLog(@"BAYER_DEBUG -- REMOVE OBJECTS FROM GLOBAL ARRAY SECOND --- %lu", (unsigned long)[H2SyncReport sharedInstance].h2BgRecordReportArray);
#endif
    
    if ([JJBayerContour sharedInstance].isSyncSecondStageDidRemoved == YES) {
        [JJBayerContour sharedInstance].isSyncSecondStageDidRemoved = NO;
        [JJBayerContour sharedInstance].goToNextYearStage = NO;
        [JJBayerContour sharedInstance].isSyncSecondStageRunning = YES;
    }
    if ([H2Sync sharedInstance].isAudioCable  || [H2BleService sharedInstance].isBleCable) {
        [[H2CableFlow sharedCableFlowInstance] h2SystemResendCmdInit];
    }
    
    if ([H2Sync sharedInstance].isAudioCable) {
        [[H2AudioFacade sharedInstance] h2AudioTriggerCommand];
    }
    
    [H2DataFlow sharedDataFlowInstance].cableUartStage = YES;
#ifdef DEBUG_LIB
    DLog(@"the cmd is %02X,%02X,%02X,%02X,%02X", tmp2[0], tmp2[1], tmp2[2], tmp2[3], tmp2[4]);
    DLog(@"the cmd date for compare is %02X, %02X, %02X, %02X, %02X, %02X", tmp2[DATE_FOR_COMPARE_ADDR], tmp2[DATE_FOR_COMPARE_ADDR+1],
          tmp2[DATE_FOR_COMPARE_ADDR+2],tmp2[DATE_FOR_COMPARE_ADDR+3], tmp2[DATE_FOR_COMPARE_ADDR+4], tmp2[DATE_FOR_COMPARE_ADDR+5]);
#endif
}


- (void)h2SyncInit:(id)sender
{
    
    [H2RocheEventProcess sharedInstance].didSkipMeterEndCmd = NO;
    if ([H2BleService sharedInstance].isBleCable) {
        DLog(@"CABLE IS BLE TYPE");
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
    }else{
        DLog(@"CABLE IS AUDIO TYPE");
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
    }
    
    [H2DataFlow sharedDataFlowInstance].cableUartStage = NO;
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
    [H2MeterSystemInfo sharedInstance].smMmolUnitFlag = NO;
    
    
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_INIT;
    
    [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = SYSTEM_NORMAL_RESEND_INTERVAL;
    
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = METER_NORMAL_RESEND_CYCLE;
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = METER_NORMAL_RESEND_INTERVAL;
    
    
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
#ifdef DEBUG_LIB
            DLog(@"METER_DEBUG call Meter AVIVA Init command");
#endif
            [[H2RocheEventProcess sharedInstance] h2SyncAvivaGeneral];
            break;
            
        case SM_ACCUCHEK_COMPACTPLUS:
        case SM_ACCUCHEK_ACTIVE:
        case SM_ACCUCHEK_EXT_C:
        case SM_ACCUCHEK_EXT_D:
        case SM_ACCUCHEK_EXT_E:
        case SM_ACCUCHEK_EXT_F:
            [[H2RocheEventProcess sharedInstance] h2SyncCompactPlusGeneral];
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
#ifdef DEBUG_LIB
            DLog(@"METER_DEBUG call Meter BAYER Init command");
#endif
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
#ifdef DEBUG_LIB
            DLog(@"METER_DEBUG call Meter CARESENSN Init command");
#endif
            [[H2iCareSensEventProcess sharedInstance] h2SyncCareSensNGeneral];
            break;
            
        case SM_CARESENS_EXT_9_BIONIME:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_DATE;
            [[H2iCareSensEventProcess sharedInstance] h2SyncBionimeGeneral];
            break;
            
        case SM_CARESENS_EXT_A_HMD_GL:
            // FOR HMD BLE BG TEST
            
            //j            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_DATE;
            
            [[H2iCareSensEventProcess sharedInstance] h2SyncHmdGeneral];
            break;
            
        case SM_CARESENS_EXT_7_TB200:
            //j            [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(h2SyncExtTysonInit) userInfo:nil repeats:NO];
            break;
            
        case SM_CARESENS_EXT_8_EMBRACE_PRO:
            [[H2iCareSensEventProcess sharedInstance] h2SyncEmbraceProGeneral];
            
            break;
            
        case SM_CARESENS_EXT_B_FORA_GD40A:
            [[Fora sharedInstance] h2FORAInitTask];
            break;
            
        case SM_CARESENS_EXT_C_DSA:
            [[AllianceDSA sharedInstance] allianceCmdFlow:METHOD_INIT];
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
                [[H2GlucoCardEventProcess sharedInstance] h2SyncGlucoCardVitalGeneral];
            }else{
                [[H2GlucoCardEventProcess sharedInstance] h2SyncReliOnGeneral];
                //                [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            }
            
            
            break;
            
        case SM_ONETOUCH_ULTRA2:
            
            //        case SM_ONETOUCH_EXT_A:
        case SM_ONETOUCH_EXT_B:
        case SM_ONETOUCH_EXT_C:
        case SM_ONETOUCH_EXT_D:
        case SM_ONETOUCH_EXT_E:
        case SM_ONETOUCH_EXT_F:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            if (_equipProtocolId == SM_ONETOUCH_ULTRA_) {
                [[H2OneTouchEventProcess sharedInstance] h2SyncUltraXXXGeneral];
            }else{
                [[H2OneTouchEventProcess sharedInstance] h2SyncUltra2General];
            }
            
            break;
            
        case SM_ONETOUCH_ULTRA_VUE:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            [[H2OneTouchEventProcess sharedInstance] h2SyncUltraVueGeneral];
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
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            [[H2OneTouchEventProcess sharedInstance] h2SyncUltraMiniGeneral];
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
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
            [[H2BeneChekEventProcess sharedInstance] h2SyncBeneChekGeneral];
            break;
            
        case SM_OMNIS_EMBRACE:
            
        case SM_OMNIS_EMBRACE_EVO:
            
        case SM_GLUCOSURE_VIVO:
        case SM_EVENCARE_G2:
        case SM_EVENCARE_G3:
        case SM_OMNIS_AUTOCODE:
        case SM_EXT_OMNIS6:
        case SM_APEX_BG001_C:
        //case SM_APEX_BGM014:
            [Omnis sharedInstance].indexSeed = EMBRACE_SEED;
            [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisGeneral];
            break;
            
        case SM_Embrace_TOTAL:
            break;
            
        case SM_EXT_OMNIS_C:
        case SM_EXT_OMNIS_D:
        case SM_EXT_OMNIS_E:
        case SM_EXT_OMNIS_F:
            break;
            
            
        default:
            break;
    }
#ifdef DEBUG_LIB
    DLog(@"METER_DEBUG call Meter Init command");
#endif
    [[H2CableFlow sharedCableFlowInstance] h2CableMeterCommandPreProcess];
    
}

#pragma mark - INTERNAL TASK
- (void)dataFlowCommand:(id)sender
{
    DLog(@"DATA FLOW COMMAND");
    [[H2CableFlow sharedCableFlowInstance] h2CableSystemCommand:nil];
}

- (void)dataFlowReportRecords
{
    [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
}



- (void)h2CableFinishTask
{
    [H2BleCentralController sharedInstance].didSkipBLE = YES;
    BOOL turnOffSwitch = NO;
    
    // Clear Embrace Ending Checking Timer in BLE mode
    if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == SM_OMNIS_EMBRACE) {
        if ([H2ApexBioEventProcess sharedInstance].embraceEndingTimer != nil) {
            [[H2ApexBioEventProcess sharedInstance].embraceEndingTimer invalidate];
            [H2ApexBioEventProcess sharedInstance].embraceEndingTimer = nil;
        }
    }
    
    
    // BLE Ending .... for ULTRA 2 ...
    if ([H2BleService sharedInstance].isBleCable) {
        [H2RocheEventProcess sharedInstance].didSkipMeterEndCmd = NO;
        
        // Others
        [H2AudioAndBleCommand sharedInstance].cmdInterval = 2.3f;
        
        if ((([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xF0) >> 4) == BRAND_ONETOUCH) {
            if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == SM_ONETOUCH_ULTRA2 || ([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) > SM_ONETOUCH_ULTRAMINI) {
                
                if ([LSOneTouchUltra2 sharedInstance].ultra2RecordNumber > 0) {
                    [H2AudioAndBleCommand sharedInstance].cmdInterval = (float)[LSOneTouchUltra2 sharedInstance].ultra2RecordNumber * ULTRA2_RECORD_INTERVAL + 1;
                }
            }
        }
#ifdef DEBUG_LIB
        DLog(@"TURN OFF DELAY TIME ULTRA 2 -- %f BLE ", [H2AudioAndBleCommand sharedInstance].cmdInterval);
#endif
        turnOffSwitch = YES;
        // BLE DELAY
    }else{
        if ((([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xF0) >> 4) == BRAND_ONETOUCH) {
            if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == SM_ONETOUCH_ULTRA2 || ([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) > SM_ONETOUCH_ULTRAMINI) {
                if ([LSOneTouchUltra2 sharedInstance].ultra2RecordNumber > 0) {
                    [H2AudioAndBleCommand sharedInstance].cmdInterval = (float)[LSOneTouchUltra2 sharedInstance].ultra2RecordNumber * ULTRA2_RECORD_INTERVAL + 1;
                }
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdInterval = 1.0f;
            }
        }else{
            [H2AudioAndBleCommand sharedInstance].cmdInterval = 1.0f;
        }
        
#ifdef DEBUG_LIB
        DLog(@"TURN OFF DELAY TIME NO SKIP %f AUDIO ", [H2AudioAndBleCommand sharedInstance].cmdInterval);
#endif
        turnOffSwitch = YES;
    }
    if (turnOffSwitch) {
        [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2CableTurnOffSwitch) userInfo:nil repeats:NO];
    }
}


#pragma mark - CABLE EXISTING PROCESS
- (BOOL)cableExistingProcess
{
     UInt16 batTempValue = 0;
    NSData *tmpSN = [[NSData alloc] init];
    
    if ([H2CmdInfo sharedInstance].receivedDataLength - 4) {
        memcpy(&batTempValue, &[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN+2], 2);
        //[H2SyncSystemMessageInfo sharedInstance].syncRowBatteryValue = batTempValue;
        
        [H2BleService sharedInstance].batteryRawValue = batTempValue;
        
        [H2ApexBioEventProcess sharedInstance].EmbraceOverBleMode = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            
            [H2ApexBioEventProcess sharedInstance].EmbraceOverBleMode = YES;
            
            if (batTempValue > BLE_BATTERY_30V) {
                batTempValue = 10;
            }else if (batTempValue > BLE_BATTERY_29V){
                batTempValue = 7;
            }else if (batTempValue > BLE_BATTERY_28V){
                batTempValue = 5;
            }else if (batTempValue > BLE_BATTERY_27V){
                batTempValue = 3;
            }else{
                batTempValue = 1;
            }
        }else{
            if (batTempValue > AUDIO_BATTERY_30V) {
                batTempValue = 10;
            }else if (batTempValue > AUDIO_BATTERY_29V){
                batTempValue = 7;
            }else if (batTempValue > AUDIO_BATTERY_28V){
                batTempValue = 5;
            }else if (batTempValue > AUDIO_BATTERY_27V){
                batTempValue = 3;
            }else{
                batTempValue = 1;
            }
        }
    }
    [H2BleService sharedInstance].batteryLevel = batTempValue;
    
#ifdef DEBUG_LIB
    DLog(@"SN Did LEN =  %d, %d", [H2CmdInfo sharedInstance].receivedDataLength - 4, SN_LEN_CABLE_OLD);
#endif
    if ([H2BleService sharedInstance].isBleCable) {
        if ([H2CmdInfo sharedInstance].receivedDataLength - 4 == SN_LEN_CABLE_NEW) {
            unsigned char snTmp[16] = {0};
            memcpy(snTmp, &[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN + 4] , SN_LEN_CABLE_NEW-1);
            _cableSN = [NSString stringWithUTF8String:(const char *)snTmp];
        }
    }else{
        if ([H2CmdInfo sharedInstance].receivedDataLength - 4 == SN_LEN_CABLE_OLD ) {
            tmpSN = [NSData dataWithBytes:&[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN + 4] length: [H2CmdInfo sharedInstance].receivedDataLength - 4];
            [self cableNumberProcess:tmpSN];
        }
        //tmpSN = @"FF0301FF123456";
    }
    // BLE CABLE
    if ([H2BleService sharedInstance].isBleCable) {
        UInt8 irCode = [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN + 4 + 1];
        BOOL meterErr = NO;
        if (irCode == 'I') { // IR CABLE, HB8301
            if (((_equipUartProtocol & 0xF0) >> 4) != BRAND_ACCUCHEK) {
                meterErr = YES;
            }
        }else{ // HB8201
            if (((_equipUartProtocol & 0xF0) >> 4) == BRAND_ACCUCHEK) {
                meterErr = YES;
            }
        }
        
        if (meterErr) {// cable meter not match
            [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(cableXmeter) userInfo:nil repeats:NO];
            return NO;
        }
    }
    
    
#ifdef DEBUG_LIB
    DLog(@"debug for low battery %02X, %02X", [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN+2], [H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN+2]);
#endif
    
#ifdef DEBUG_LIB
    DLog(@"REPORT SN -- 2 ");
#endif
    //[[H2Sync sharedInstance] sdkCableBleSerialNumberBatteryLevel:_cableSN withBatteryLevel:_batteryValue withCableFw:_cableFW];

#ifdef DEBUG_LIB
    DLog(@"LIB DEBUG ...REPORT SN FW BATTERY LEVEL ---");
#endif
    [H2CableFlow sharedCableFlowInstance].audioSystemCmd = CMD_CABLE_VERSION;
    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(dataFlowCommand:) userInfo:nil repeats:NO];

    return YES;
}

- (void)cableXmeter
{
    [[H2Sync sharedInstance] demoSdkSyncCableStatus:FAIL_CABLE_EXIST delegateCode:DELEGATE_SYNC];
}

#pragma mark - CABLE FIRMWARE VERSION PROCESS
- (BOOL)cableVersionProcess
{
    if (_cableUartStage) { // SHOW ERROR, UART Leakage ...
        
        [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = 0;
        
        [[H2CableFlow sharedCableFlowInstance] h2SyncMeterCommandResendTask:nil];
        
        return NO;
    }
    
    if ([H2CableParameter sharedInstance].didFinishedVersionCmd) {
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:FAIL_CABLE_VERSION delegateCode:DELEGATE_SYNC];
        return NO;
    }
    [H2CableParameter sharedInstance].didFinishedVersionCmd = YES;
    unsigned char tmp[16] = {0};
    
    UInt16 tmpHi = 0;
    UInt16 tmpLo = 0;
    
    memcpy(tmp, &[H2SyncSystemMessageInfo sharedInstance].systemGlobalBuffer[CMD_HEADER_LEN+BRAND_AT_1 + 2],[H2CmdInfo sharedInstance].receivedDataLength - 4);
#ifdef DEBUG_LIB
    for (int i=0; i<12; i++) {
        DLog(@"FW index %d value %02X", i, tmp[i]);
    }
#endif
    
    
    _cableFW = [NSString stringWithUTF8String:(const char *)tmp];
    
    tmpHi = tmp[3] & 0x0F;
    tmpLo = tmp[4] & 0x0F;
    
    [H2CableParameter sharedInstance].CableVersionNumber = ((tmpHi * 10) + tmpLo) * 10000;
#ifdef DEBUG_LIB
    DLog(@"The YEAR HI is %02X", tmpHi);
    DLog(@"The YEAR LO is %02X", tmpLo);
#endif
    tmpHi = 0;
    tmpLo = 0;
    tmpHi = tmp[6] & 0x0F;
    tmpLo = tmp[7] & 0x0F;
    [H2CableParameter sharedInstance].CableVersionNumber += ((tmpHi * 10) + tmpLo) * 100;
    
#ifdef DEBUG_LIB
    DLog(@"The MONTH HI is %02X", tmpHi);
    DLog(@"The MONTH LO is %02X", tmpLo);
#endif
    tmpHi = 0;
    tmpLo = 0;
    tmpHi = tmp[9] & 0x0F;
    tmpLo = tmp[10] & 0x0F;
    [H2CableParameter sharedInstance].CableVersionNumber += (tmpHi * 10) + tmpLo;
    
#ifdef DEBUG_LIB
    DLog(@"The DAY HI is %02X", tmpHi);
    DLog(@"The DAY LO is %02X", tmpLo);
    
    
    DLog(@"the Number %d 0x%08X, version is %@ --------",(int)[H2CableParameter sharedInstance].CableVersionNumber, (int)[H2CableParameter sharedInstance].CableVersionNumber, _cableFW);
#endif
    NSRange fwVersionRange = [_cableFW rangeOfString:@"h2 14"];
    
    [JJBayerContour sharedInstance].isBayerOldFWVersion = NO;
    [GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode = YES;
    
    if (fwVersionRange.location != NSNotFound) { // OLD CABLE, iOS use
        if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xF0) == 0x10) {
            // OLD cable not support Roche's meter
            //[[H2Timer sharedInstance] clearCableTimer];
            // METER SEL ERROR
            [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(cableXmeter) userInfo:nil repeats:NO];
            return NO;
        }
        [JJBayerContour sharedInstance].isBayerOldFWVersion = YES;
        [GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode = NO;
    }else{
        //[JJBayerContour sharedInstance].isBayerOldFWVersion = YES;
        //[GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode = NO;
    }
    
    if ([H2CableParameter sharedInstance].CableVersionNumber >= 141223) {
        [H2ApexBioEventProcess sharedInstance].EmbraceOverLoading = YES;
    }else{
        [H2ApexBioEventProcess sharedInstance].EmbraceOverLoading = NO;
    }
    
    [H2CableParameter sharedInstance].sdkAndCableVersion = [[H2CableParameter sharedInstance].sdkAndCableVersion stringByAppendingString:_cableFW];
    
#ifdef DEBUG_LIB
    DLog(@"REPORT SN -- 3 ");
#endif
    if ([H2Sync sharedInstance].isAudioCable) {
        [[H2Sync sharedInstance] sdkSendSerialNumberBatteryLevel:DYNAMIC_AUDIO];
    }else{
        [[H2Sync sharedInstance] sdkSendSerialNumberBatteryLevel:DYNAMIC_DONGLE];
    }
    
    
#ifdef DEBUG_LIB
    
    DLog(@"LIB DEBUG DID FW VERSION HERE --- ++++ -----");
#endif
    [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(h2MeterSelect:) userInfo:nil repeats:NO];
    return YES;
}

- (void)h2CableTurnOffSwitch
{
#ifdef DEBUG_LIB
    DLog(@"CABLE DELAY TURN OFF SW");
#endif
    [H2BleCentralController sharedInstance].didSkipBLE = NO;
    [[H2CableFlow sharedCableFlowInstance] h2SyncTurnOffSwitch];
}

+ (H2DataFlow *)sharedDataFlowInstance
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
