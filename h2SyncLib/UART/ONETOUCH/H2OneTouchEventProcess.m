//
//  H2OneTouchEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "LSOneTouchUltra2.h"
#import "LSOneTouchUltraMini.h"
#import "LSOneTouchUltraVUE.h"
#import "H2Config.h"
#import "H2Report.h"
#import "h2AudioFacade.h"
#import "H2OneTouchEventProcess.h"

#import "H2DataFlow.h"
#import "H2Records.h"


@interface H2OneTouchEventProcess()
{
}
@end

@implementation H2OneTouchEventProcess

- (id)init
{
    if (self = [super init]) {
        
        _ultra2DivCycle = 0;
        
        _resendUltra2cmdSystemInterval = 0;
        _didOneTouchSendGeneralCommand = NO;
        _didOneTouchSendRecordCommand = NO;
        
        _ultra2SwitchOnDelayTime = 0.0f;
        _ultra2RecordTimeOutInterval = 0.0f;
        
    }
    return self;
}



+ (H2OneTouchEventProcess *)sharedInstance
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




- (void)h2OneTouchInfoRecordProcess
{

    if ([H2DataFlow sharedDataFlowInstance].equipProtocolId == SM_ONETOUCH_ULTRA_) {
        [self receivedDataProcessOneTouchUltraXXX];
        return;
    }
    switch (([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0xF0)>>4) {
        case MODEL_ONETOUCH_ULTRA2:
        
        case MODEL_ONETOUCH_EX_B:
        case MODEL_ONETOUCH_EX_C:
        case MODEL_ONETOUCH_EX_D:
        case MODEL_ONETOUCH_EX_E:
        case MODEL_ONETOUCH_EX_F:
            [self receivedDataProcessOneTouchUltra2];
            break;
        case MODEL_ONETOUCH_ULTRAEASY:
        case MODEL_ONETOUCH_ULTRAMINI:
        case MODEL_ONETOUCH_ULTRALIN:
        case MODEL_ONETOUCH_EX_4:
        case MODEL_ONETOUCH_EX_5:
        case MODEL_ONETOUCH_EX_6:
        case MODEL_ONETOUCH_EX_7:
            
        case MODEL_ONETOUCH_EX_8:
        case MODEL_ONETOUCH_EX_9:
            [H2AudioAndBleCommand sharedInstance].cmdInterval = ULTRA_MINI_CMD_INTERVAL;
            [self receivedDataProcessOneTouchUltraMini];
            break;
            
        case MODEL_ONETOUCH_EX_VUE:
            [H2AudioAndBleCommand sharedInstance].cmdInterval = ULTRA_MINI_CMD_INTERVAL;
            [self receivedDataProcessOneTouchUltraVue];
            break;
            
            
        default:
            break;
    }
}


#pragma mark - ULTR 2 DATA PROCESS
- (void)receivedDataProcessOneTouchUltra2
{
    NSMutableArray *meterDateTimeValueArray = [[NSMutableArray alloc]init];
    
    NSUInteger numObjects = 0;

    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
            
        case METHOD_RECORD:
#ifdef DEBUG_LIB
            DLog(@"ULTRA 2 DEBUG ....");
#endif
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;

            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;

            [H2SyncReport sharedInstance].reportMeterInfo = [[LSOneTouchUltra2 sharedInstance] ultra2AudioHeaderParser];
#ifdef DEBUG_LIB
            DLog(@"DEBUG ULTRA 2 model name is %d", [H2SyncReport sharedInstance].reportMeterInfo.smNumberOfRecord);
#endif
            // Zero Record
            if ([H2SyncReport sharedInstance].reportMeterInfo.smNumberOfRecord == 0) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                return;
            }

 //           _ultra2TotalTime = [H2SyncReport sharedInstance].reportMeterInfo.smNumberOfRecord * TIME_PER_RECORD_FOR_ULTRA2;

#ifdef DEBUG_LIB
//            DLog(@"DEBUG ULTRA 2 time and number are %f, %d", _ultra2TotalTime, [H2SyncReport sharedInstance].reportMeterInfo.smNumberOfRecord);
#endif
            
            meterDateTimeValueArray = [[LSOneTouchUltra2 sharedInstance] ultra2DateTimeValueArrayParser:0];
            
            numObjects = [meterDateTimeValueArray count];
            
            _ultra2DivCycle++;
            
            if ([meterDateTimeValueArray count] > 0) { // Get New Record
                for (H2BgRecord *infoRecord in meterDateTimeValueArray) {
                    [H2Records sharedInstance].bgTmpRecord = infoRecord;
                    
                    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                        [[H2SyncReport sharedInstance].recordsArray addObject:infoRecord];
                        [H2SyncReport sharedInstance].hasMultiRecords = YES;
                    }else{ // Normal Ending Here ...
#ifdef DEBUG_LIB
                        DLog(@"ULTRA 2 DID COME TO HERE ...");
#endif
                        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                        DLog(@"did ultra2 check this");
#endif
                        return;
                    }
                }

            }
#ifdef DEBUG_LIB
            DLog(@"Total : %d, Index : %d", [H2SyncReport sharedInstance].reportMeterInfo.smNumberOfRecord, [LSOneTouchUltra2 sharedInstance].ultra2RecordIndex);
#endif
            
            // Get 500 Set Record, Ending here ...
            if (([H2SyncReport sharedInstance].reportMeterInfo.smNumberOfRecord - [LSOneTouchUltra2 sharedInstance].ultra2RecordIndex) > 0) {
                
                _ultra2SwitchOnDelayTime = (float)([H2SyncReport sharedInstance].reportMeterInfo.smNumberOfRecord - [LSOneTouchUltra2 sharedInstance].ultra2RecordIndex) * TIME_PER_RECORD_FOR_ULTRA2;
                
                _ultra2RecordTimeOutInterval = (float)[LSOneTouchUltra2 sharedInstance].ultra2RecordIndex * TIME_PER_RECORD_FOR_ULTRA2;
#ifdef DEBUG_LIB
                DLog(@"DEBUG_ULTRA 2 DELAY TIME %f ", _ultra2SwitchOnDelayTime);
                DLog(@"DEBUG_ULTRA 2 TIME OUT   %f ", _ultra2RecordTimeOutInterval);
#endif
                // Meter Time Out Interval
                [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = 3 + ULTRA2_RESEND_INTERVAL + _ultra2RecordTimeOutInterval;
                
                // System command Delay Interval, Turn ON Switch
                [H2AudioAndBleCommand sharedInstance].cmdInterval = ULTRA2_SWITCH_ON_INTERVAL + _ultra2SwitchOnDelayTime;
                
                // System command resend interval,
                [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = [H2AudioAndBleCommand sharedInstance].cmdInterval + 3;
                
                [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = YES;
                [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
                [self h2SyncUltra2CmdTurnOnSwitch];
                
            }else{ // Ending here ...
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            break;
            
        case METHOD_UNIT: // Current time
            
            _ultra2DivCycle = 0;
            [LSOneTouchUltra2 sharedInstance].ultra2RecordIndex = 0;
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit =  [[LSOneTouchUltra2 sharedInstance] ultra2ElseParser];
#ifdef DEBUG_LIB
                DLog(@"the ultra 2 unit is %@", [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit);
#endif
            if ([[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit isEqualToString:@"MG/DL"]) {
                //DLog(@"get mg/dl unit ....");
//                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"meter_unit"];
                [LSOneTouchUltra2 sharedInstance].didUseMmolUnit = NO;
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = NO;
            }else{
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"meter_unit"];
                [LSOneTouchUltra2 sharedInstance].didUseMmolUnit = YES;
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = YES;
            }
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            
        
#ifdef DEBUG_LIB
                DLog(@"the model name is %@", [H2SyncReport sharedInstance].reportMeterInfo.smModelName);
                DLog(@"the Serial number is %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
#endif
            break;
            
        case METHOD_SN:
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber =  [[LSOneTouchUltra2 sharedInstance] ultra2ElseParser];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            
#ifdef DEBUG_LIB
                DLog(@"the ultra 1 serial number is %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
                DLog(@"the ultra 2 serial number is %@", [h2MeterModelSerialNumber sharedInstance].smSerialNumber);
#endif
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            _didOneTouchSendGeneralCommand = YES;
            break;
            
        case METHOD_TIME:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime =  [[LSOneTouchUltra2 sharedInstance] ultra2ElseParser];
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
            _didOneTouchSendGeneralCommand = YES;
            break;
            
        case METHOD_VERSION:
            
            [H2SyncReport sharedInstance].reportMeterInfo.smVersion =  [[LSOneTouchUltra2 sharedInstance] ultra2ElseParser];
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_UNIT;
            _didOneTouchSendGeneralCommand = YES;
            break;
            
        case METHOD_ACK_RECORD:
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            
            // Record Process
            if ([H2AudioAndBleSync sharedInstance].dataLength == ULTRA2_BLE_RECORD_LENGTH) {
                [H2Records sharedInstance].bgTmpRecord = (H2BgRecord *)[[LSOneTouchUltra2 sharedInstance] ultra2BLEDateTimeValueParser];
                
                if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]) {
                    [H2AudioAndBleCommand sharedInstance].cmdInterval = BLE_DELAY_INTERVAL;
                    [H2SyncReport sharedInstance].didSyncFail = YES;
#ifdef DEBUG_LIB
                    DLog(@"ULTRA 2 _DEBUG -- ENDING 1");
#endif
                    return;
                }
                
                if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"R"]) {
                    if ([LSOneTouchUltra2 sharedInstance].ultra2RecordNumber > 1) {
                        [LSOneTouchUltra2 sharedInstance].ultra2RecordNumber--;
                        return;
                    }else{
                        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                        DLog(@"ULTRA 2 _DEBUG -- ENDING 2");
#endif
                    }
                    
                    
                }
                
                //[H2SyncReport sharedInstance].tmpBgRecord.smRecordDateTime = [H2SyncReport sharedInstance].tmpBgRecord.smRecordDateTime;
                
                if ([LSOneTouchUltra2 sharedInstance].ultra2RecordNumber > 0) {
                    [LSOneTouchUltra2 sharedInstance].ultra2RecordNumber--;
                
                    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                        
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                        
                    }else{ // Get the Old Record, Skip BLE Buffer
#ifdef DEBUG_LIB
                        DLog(@"ULTRA 2 _DEBUG -- check this");
#endif
                            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                        DLog(@"ULTRA 2 _DEBUG -- ENDING 3");
#endif
                    }
                }
                if ([LSOneTouchUltra2 sharedInstance].ultra2RecordNumber == 0) {
                    [H2AudioAndBleCommand sharedInstance].cmdInterval = 2.0f;
                    
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    if ([[H2SyncReport sharedInstance].h2BgRecordReportArray count]) {
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    }
#ifdef DEBUG_LIB
                    DLog(@"ULTRA 2 _DEBUG -- ENDING 4");
#endif
                }else{
#ifdef DEBUG_LIB
                    DLog(@"DEBUG_LIB Ultra 2 Come Back here %d ... METHOD_ACK_RECORD", [LSOneTouchUltra2 sharedInstance].ultra2RecordNumber);
#endif
                }
                
                // Header Process
            }else if ([H2AudioAndBleSync sharedInstance].dataLength == ULTRA2_BLE_HEADER_LENGTH){
                [H2SyncReport sharedInstance].reportMeterInfo = (H2MeterSystemInfo *)[[LSOneTouchUltra2 sharedInstance] ultra2BLEHeaderParser];
                
                // ZERO record
                if ([LSOneTouchUltra2 sharedInstance].ultra2RecordNumber == 0) {
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                    DLog(@"ULTRA 2 _DEBUG -- ENDING 0");
#endif
                }
                
            }else{
#ifdef DEBUG_LIB
                DLog(@"ULTRA 2 _DEBUG -- ENDING 5");
#endif
            }
            
            break;
            
        default:
            break;
    }
    if (_didOneTouchSendGeneralCommand) {
        _didOneTouchSendGeneralCommand = NO;
        [self h2SyncUltra2General];
    }
}


#pragma mark - ULTRA MINI DATA PROCESS

- (void)receivedDataProcessOneTouchUltraMini
{
    UInt16 tmpNumber = 0;
    
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_NROFRECORD: // number of recording, dWord
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            memcpy(&tmpNumber, &[H2AudioAndBleSync sharedInstance].dataBuffer[11], 2);
            [H2AudioAndBleSync sharedInstance].recordTotal = tmpNumber;
//            [H2AudioAndBleSync sharedInstance].recordIndex = tmpNumber;
            
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
            [H2AudioAndBleSync sharedInstance].recordIndex = 0;
            break;
            
            
        case METHOD_RECORD:
            _didOneTouchSendRecordCommand = YES;
             [H2AudioAndBleSync sharedInstance].recordIndex++;
            
            [H2Records sharedInstance].bgTmpRecord = [[LSOneTouchUltraMini sharedInstance] ultraMiniDateTimeValueParser];
            
            
            [H2Records sharedInstance].bgTmpRecord.bgUnit = [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit;
            
            if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                
                if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }
            }else{
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            
            if ([H2AudioAndBleSync sharedInstance].recordIndex >= [H2AudioAndBleSync sharedInstance].recordTotal) {
//            if ([H2AudioAndBleSync sharedInstance].recordIndex == 0) {
        
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            
            
            if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
                _didOneTouchSendRecordCommand = NO;
            }
            break;
            
        case METHOD_UNIT: // Current Unit
            if ([H2AudioAndBleSync sharedInstance].dataBuffer[ONETOUCH_ULTRAMINI_UNIT_AT_11] & 1) {
#ifdef DEBUG_LIB
                DLog(@"the meter unit is mmol/L");
#endif
                [LSOneTouchUltraMini sharedInstance].didUseMmolUnit = YES;
                [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT_EX;
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = YES;
            }else{
#ifdef DEBUG_LIB
                DLog(@"the meter unit is mg/dL");
#endif
                [LSOneTouchUltraMini sharedInstance].didUseMmolUnit = NO;
                [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT;
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = NO;
            }
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            _didOneTouchSendGeneralCommand = YES;
            break;
            
            
            
            
        case METHOD_SN: // Serial Number
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[LSOneTouchUltraMini sharedInstance] ultraMiniSerialNumberParserEx];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            _didOneTouchSendGeneralCommand = YES;
            break;
            
        case METHOD_TIME:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[LSOneTouchUltraMini sharedInstance] ultraMiniCurrentDateTimeParserEx];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_UNIT;
            _didOneTouchSendGeneralCommand = YES;
            break;
            
            
        default:
            break;
    }
    if (_didOneTouchSendGeneralCommand) {
        _didOneTouchSendGeneralCommand = NO;
        [self h2SyncUltraMiniGeneral];
    }
    if (_didOneTouchSendRecordCommand) {
        _didOneTouchSendRecordCommand = NO;
        [self h2SyncUltraMiniReadRecord];
    }
}




#pragma mark - VUE VUE PROCESS #####



- (void)receivedDataProcessOneTouchUltraVue
{
    BOOL sendCommand = NO;
    
    //[H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
    [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
    //[H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
    
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
            
        case METHOD_RECORD:
#ifdef DEBUG_LIB
            DLog(@"VUE VUE  DEBUG ....");
#endif
             [H2Records sharedInstance].bgTmpRecord = [[LSOneTouchUltraVUE sharedInstance] ultraVueDateTimeValueParser];
            
            if ((![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) && [[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                
                if ([[H2SyncReport sharedInstance]  h2SyncBgDidGreateThanVueLastDateTime]) {
                    [H2SyncReport sharedInstance].tmpDateTimeForVue = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
                    //[H2SyncReport sharedInstance].tmpDateTimeForVue = [NSString stringWithFormat:@"%@",[H2Records sharedInstance].bgTmpRecord.bgDateTime];
                    [H2SyncReport sharedInstance].bgLdtIndex = [H2AudioAndBleSync sharedInstance].recordIndex;
#ifdef DEBUG_LIB
                    DLog(@"CURRENT TMP LDT %@", [H2SyncReport sharedInstance].tmpDateTimeForVue);
#endif
                }
            }
            
            
            [H2AudioAndBleSync sharedInstance].recordIndex++;
            if ([H2AudioAndBleSync sharedInstance].recordIndex >= 600) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            }else{
                [[LSOneTouchUltraVUE sharedInstance] UltraVueReadRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
                [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
            }
            return;
            
        case METHOD_NROFRECORD:
            [H2AudioAndBleSync sharedInstance].recordTotal = [[LSOneTouchUltraVUE sharedInstance] ultraVueRecordNumberParser];
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
            [H2AudioAndBleSync sharedInstance].recordIndex = 0;
           
#ifdef DEBUG_LIB
            DLog(@"VUE - UNIT");
#endif
            break;
            
        case METHOD_SN:
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[LSOneTouchUltraVUE sharedInstance] ultraVueSerialNumberParser];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
#ifdef DEBUG_LIB
            DLog(@"VUE - SEARIAL NUMBER");
#endif
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            sendCommand = YES;
            break;
            
        case METHOD_TIME:
#ifdef DEBUG_LIB
            DLog(@"VUE - TIME");
#endif
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[LSOneTouchUltraVUE sharedInstance] ultraVueCurrentTimeParser];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
            sendCommand = YES;
            break;
            
            
        case METHOD_VERSION:
            
            [[LSOneTouchUltraVUE sharedInstance] ultraVueVersionParser];
#ifdef DEBUG_LIB
            DLog(@"VUE - VERSION");
#endif
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            sendCommand = YES;
            break;
            
        default:
            break;
    }
    if (sendCommand) {
        sendCommand = NO;
        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
        //[H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
        [self h2SyncUltraVueGeneral];
    }else{
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
    }
}




#pragma mark - ULTRA XXX
- (void)receivedDataProcessOneTouchUltraXXX
{
    //    NSMutableArray *meterDateTimeValueArray = [[NSMutableArray alloc]init];
    
    //    NSUInteger numObjects = 0;
    unsigned char cmdSel = 0;
    
    cmdSel = [H2AudioAndBleSync sharedInstance].dataBuffer[0];
    //memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
            
        case METHOD_INIT:
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [H2AudioAndBleResendCfg sharedInstance].didResendSystemCmd = NO;
            
            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            
            _didOneTouchSendGeneralCommand = YES;
            /*
             == '@' // Serial Number
             == 'F' // Current
             == '?' // Version
             == 'S' // Unit
             */
            switch (cmdSel) {
                case '@': // Serial Number
                    _ultraOldFinished = NO;
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
                    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[LSOneTouchUltra2 sharedInstance] ultraXXXParser];
                    break;
                    
                case 'F': // Current Time
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
                    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[LSOneTouchUltra2 sharedInstance] ultraXXXParser];
                    break;
                    
                case '?': // Version
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_UNIT;
                    [[LSOneTouchUltra2 sharedInstance] ultraXXXParser];
                    break;
                    
                case 'S': // Unit
                    // TO DO ..
                    [[LSOneTouchUltra2 sharedInstance] ultraXXXParser];
#if 1
                    _didOneTouchSendGeneralCommand = NO;
                    [H2SyncReport sharedInstance].didSendEquipInformation = YES;
                    //                    [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
#else
                    //                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
                    
                    _didOneTouchSendGeneralCommand = NO;
                    [[LSOneTouchUltra2 sharedInstance] UltraOldCommandLoop:0];
#endif
                    break;
                    
                case 'P': // Records
                    // TO DO ..
                    if ([LSOneTouchUltra2 sharedInstance].ultraOldRecordsSart) {
#ifdef DEBUG_ULTRA_XXX
                        DLog(@"ULTRA XXX - RECORD YES");
#endif
                        [[LSOneTouchUltra2 sharedInstance] ultraXXXRecordsParser];
                    }else{
#ifdef DEBUG_ULTRA_XXX
                        DLog(@"ULTRA XXX - RECORD NO");
#endif
                    }
                    
                    _didOneTouchSendGeneralCommand = NO;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case METHOD_RECORD:
            if (_ultraOldFinished) {
#ifdef DEBUG_ULTRA_XXX
                DLog(@"ULTRA XXX - HAS FINISHED ****");
#endif
                return;
            }
            
#ifdef DEBUG_ULTRA_XXX
            DLog(@"ULTRA XXX -- INDEX == %d ADND TOTAL == %d", [LSOneTouchUltra2 sharedInstance].ultraOldIndexRecords, [LSOneTouchUltra2 sharedInstance].ultraOldTotalRecords);
#endif
            if ([H2AudioAndBleSync sharedInstance].dataLength > 40) {
                [H2Records sharedInstance].bgTmpRecord = [[LSOneTouchUltra2 sharedInstance] ultraXXXRecordsParser];
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }else{
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    _ultraOldFinished = YES;
                    return;
                }
                
                [LSOneTouchUltra2 sharedInstance].ultraOldIndexRecords++;
                if ([LSOneTouchUltra2 sharedInstance].ultraOldIndexRecords >= [LSOneTouchUltra2 sharedInstance].ultraOldTotalRecords) {
#ifdef DEBUG_ULTRA_XXX
                    DLog(@"ULTRA XXX -- FINISHED");
#endif
                    _ultraOldFinished = YES;
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }else{
#ifdef DEBUG_ULTRA_XXX
                    DLog(@"ULTRA XXX -- FINISHED NOT ");
#endif
                }
            }else{
                [LSOneTouchUltra2 sharedInstance].ultraOldTotalRecords = [[LSOneTouchUltra2 sharedInstance] ultraXXXNumberOfRecordsParser];
#ifdef DEBUG_ULTRA_XXX
                DLog(@"TOTAL RECORDS == %d == IN XXX", [LSOneTouchUltra2 sharedInstance].ultraOldIndexRecords);
#endif
                [LSOneTouchUltra2 sharedInstance].ultraOldIndexRecords = 0;
            }
            
            _didOneTouchSendGeneralCommand = NO;
            break;
            
        default:
#ifdef DEBUG_ULTRA_XXX
            DLog(@"ULTRA XXX - COME TO DEFAULT");
#endif
            _didOneTouchSendGeneralCommand = NO;
            break;
    }
    if (_didOneTouchSendGeneralCommand) {
        _didOneTouchSendGeneralCommand = NO;
        [self h2SyncUltraXXXGeneral];
    }
}




unsigned char ultra2CableSwitchOn[] = {
    0x00, CMD_SW_ON, 0x00, 0x00, 0x00
};
#pragma mark - ONE TOUCH ULTRA 2 COMMAND
- (void)h2SyncUltra2CmdTurnOnSwitch
{
//    [[LSOneTouchUltra2 sharedInstance] switchOn];
    [[H2AudioFacade sharedInstance] sendCommandDataEx:ultra2CableSwitchOn withCmdLength:sizeof(ultra2CableSwitchOn) cmdType:BRAND_SYSTEM returnDataLength:0 mcuBufferOffSetAt:0];
}

- (void)h2SyncUltraXXXGeneral
{
    [[LSOneTouchUltra2 sharedInstance] UltraXXXCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}

- (void)h2SyncUltra2General
{
    [[LSOneTouchUltra2 sharedInstance] Ultra2CommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}

- (void)h2SyncUltra2ReadRecord
{
    [[LSOneTouchUltra2 sharedInstance] Ultra2ReadRecord:_ultra2DivCycle];
}

- (void)h2SyncUltra2BLEReadRecordAll
{
    [[LSOneTouchUltra2 sharedInstance] Ultra2BLEReadRecordAll];
}




#pragma mark - ONE TOUCH ULTRA MINI COMMAND

- (void)h2SyncUltraMiniGeneral
{
    [[LSOneTouchUltraMini sharedInstance] UltraMiniCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}
- (void)h2SyncUltraMiniReadRecord
{
#ifdef DEBUG_LIB
    DLog(@"ULTRAMINI_DEBUG The Total Record -- %02d", [H2AudioAndBleSync sharedInstance].recordTotal);
    DLog(@"ULTRAMINI_DEBUG The Current Index -- %02d",[H2AudioAndBleSync sharedInstance].recordIndex);
#endif
    [[LSOneTouchUltraMini sharedInstance] UltraMiniReadRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
}


#pragma mark - VUE VUE GENERAL ###
- (void)h2SyncUltraVueGeneral
{
#ifdef DEBUG_ULTRA_XXX
    DLog(@"DID COME TO -- VUE VUE -- GENERAL");
#endif
    [[LSOneTouchUltraVUE sharedInstance] UltraVueCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}



@end



