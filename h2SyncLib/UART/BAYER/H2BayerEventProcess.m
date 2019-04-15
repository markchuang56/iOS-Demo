//
//  H2BayerEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "JJBayerContour.h"
#import "H2Config.h"
#import "H2Report.h"
#import "H2BayerEventProcess.h"

#import "H2Sync.h"
#import "H2DataFlow.h"
#import "H2LastDateTime.h"

#import "H2Records.h"

@interface H2BayerEventProcess()
{
    NSTimer *h2SendUartInitTimer;
}

- (void)bayerUartInitEx;
@end

@implementation H2BayerEventProcess

- (id)init
{
    if (self = [super init]) {
        _serverSrcLastDateTimes = [[NSMutableArray alloc] init];
        _serverSrcLastDateTimes = nil;
        _bayerParam = 0;
        _bayerTag = 0;
        h2SendUartInitTimer = [[NSTimer alloc] init];
    }
    return self;
}


+ (H2BayerEventProcess *)sharedInstance
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


- (void)h2BayerInfoRecordProcess
{
    [self receivedDataProcessBayerContour];
}




- (void)receivedDataProcessBayerContour
{
    
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            switch ([H2AudioAndBleSync sharedInstance].dataBuffer[2]) {
                case 'H': // head process
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[1] == '1') { // current time // brand
                        [H2SyncReport sharedInstance].reportMeterInfo = [[JJBayerContour sharedInstance] jjContourCurrentTimeParserEx];
                        [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
                    }
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_INIT;
                    [self h2SyncBayerGeneral];
                    break;
                    
                case 'O':
                case 'P':
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_INIT;
                    [self h2SyncBayerGeneral];
                    break;
                    
                case 'R': // unit process and serial number
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[2+2] == '1') { // unit Parser
                        [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = [[JJBayerContour sharedInstance] jjContourUnitParserEx];
                        NSRange unitRange = [[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit rangeOfString:@"mg/dL"];
                        if (unitRange.location != NSNotFound) {
                            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT;
                            [JJBayerContour sharedInstance].didBayerMmolUnit = NO;
                        }else{
                            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT_EX;
                            [JJBayerContour sharedInstance].didBayerMmolUnit = YES;
                        }
                        
                        [JJBayerContour sharedInstance].didSkipMeterInfo = YES;
#ifdef DEBUG_LIB
                        DLog(@"BAYER 1 THE SN IS %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
                        DLog(@"current time is %@", [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime);
                        DLog(@"last date time is %@", [H2SyncReport sharedInstance].serverBgLastDateTime );
#endif
                        [self bayerSerialNumberProcess];
                        
#ifdef DEBUG_LIB
                        DLog(@"BAYER_DEBUG BUFFER ANY TIME BF UART %lu ---- ********", (unsigned long)[[H2SyncReport sharedInstance].h2BgRecordReportArray count]);
#endif
                        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                        [self bayerUartInitEx];
                    }
                    break;
            }
            break;

            
        case METHOD_RECORD:
            switch ([H2AudioAndBleSync sharedInstance].dataBuffer[2]) {
                case 'O':
#ifdef DEBUG_LIB
                        DLog(@"control solution here do not thing");
#endif
                    break;
                    
                case 'R': // record process
                    if ([H2AudioAndBleSync sharedInstance].dataLength > 48) {
                        [H2AudioAndBleSync sharedInstance].recordIndex++;
                        [H2Records sharedInstance].bgTmpRecord = [[JJBayerContour sharedInstance] jjContourDateTimeValueParser:[H2AudioAndBleSync sharedInstance].recordIndex];
                        
                        
                        if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]) {
                            
                            [H2AudioAndBleSync sharedInstance].recordIndex--;
                        }else{
                            if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                                [H2SyncReport sharedInstance].hasSMSingleRecord = YES; //
                            }
                        }
                    }

                    break;
                    
                case 'L': // command endprocess
                    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
#ifdef DEBUG_LIB
                    DLog(@"COMMAND END FOR BAYER");
#endif
                    if ([JJBayerContour sharedInstance].isBayerOldFWVersion) {
                        if ([JJBayerContour sharedInstance].goToNextYearStage) {
                            // for re-sync
                            //j [H2SyncStatus sharedInstance].cableSyncRunning = NO;
                            h2SendUartInitTimer = [NSTimer scheduledTimerWithTimeInterval:16.0f target:self selector:@selector(bayerUartInitEx) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
                            DLog(@"COMMAND END FOR BAYER - GO TO NEX YEAR");
#endif
                            return;
                        }
                    }
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    [H2AudioAndBleSync sharedInstance].recordIndex = 0;
#ifdef DEBUG_LIB
                        DLog(@"the Contour command end processing");
#endif
                    break;
                    
                default:
                    break;
            }
            
            if ([H2SyncStatus sharedInstance].didReportFinished == NO) {
#ifdef DEBUG_LIB
                DLog(@"BAYER_DEBUG ..... OOOOOO");
#endif
                if ([H2AudioAndBleSync sharedInstance].dataBuffer[2] != 'L' ) { // total command end
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
                    
                    if ([JJBayerContour sharedInstance].isBayerOldFWVersion == YES) {
                        if ([H2AudioAndBleSync sharedInstance].dataBuffer[1] - _bayerParam == 1 && [H2AudioAndBleSync sharedInstance].recordIndex != 1) {
                            if ([JJBayerContour sharedInstance].isSyncSecondStageRunning == YES) {
                                if ([H2BayerEventProcess sharedInstance].bayerTag == [H2AudioAndBleSync sharedInstance].dataBuffer[2] && [H2AudioAndBleSync sharedInstance].dataBuffer[2] == 'R') {
#ifdef DEBUG_LIB
                                    DLog(@"BAYER_DEBUG_ONE");
#endif
                                    [self h2SyncBayerGeneral];
                                }
                            }else{
                                [self h2SyncBayerGeneral];
#ifdef DEBUG_LIB
                                DLog(@"BAYER_DEBUG_ OR HERE");
#endif
                            }
                            
                        }
                        _bayerParam = [H2AudioAndBleSync sharedInstance].dataBuffer[1];
                        if (_bayerParam == '7') {
                            _bayerParam = 0x2F;
                        }
                    }else{
                        [self h2SyncBayerGeneral];
                    }
                }
            }
            
            [H2BayerEventProcess sharedInstance].bayerTag = [H2AudioAndBleSync sharedInstance].dataBuffer[2];
            break;
            
            
        case METHOD_6:
#ifdef DEBUG_LIB
            DLog(@"BAYER_DEBUG BUFFER ANY TIME ACK %lu ---- ********", (unsigned long)[[H2SyncReport sharedInstance].h2BgRecordReportArray count]);
#endif
            if ([JJBayerContour sharedInstance].isBayerOldFWVersion == NO) {

                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
                [self h2SyncBayerGeneral];
                //[NSTimer scheduledTimerWithTimeInterval:_bayerCmdInterval target:self selector:@selector(h2SyncBayerGeneral) userInfo:nil repeats:NO];
            }
            
            break;
            
        case METHOD_ACK_RECORD:
            switch ([H2AudioAndBleSync sharedInstance].dataBuffer[2]) {
                case 'H': // head process
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[1] == '1') { // current time // brand
                        [H2SyncReport sharedInstance].reportMeterInfo = [[JJBayerContour sharedInstance] jjContourCurrentTimeParserEx];
                        [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
                    }
                    if ([H2SyncReport sharedInstance].didSyncFail) {
                        return;
                    }
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_ACK_RECORD;
                    [self h2SyncBayerGeneral];
                    break;
                    
                case 'O':
                case 'P':
#ifdef DEBUG_LIB
                    DLog(@"control solution here do not thing");
#endif
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_ACK_RECORD;
                    [self h2SyncBayerGeneral];
                    break;
                    
                case 'R': // unit process
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[2 + 2] == '1') { // unit Parser
                        
                        [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = [[JJBayerContour sharedInstance] jjContourUnitParserEx];
                        NSRange unitRange = [[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit rangeOfString:@"mg/dL"];
                        if (unitRange.location != NSNotFound) {
                            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT;
                            [JJBayerContour sharedInstance].didBayerMmolUnit = NO;
                        }else{
                            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT_EX;
                            [JJBayerContour sharedInstance].didBayerMmolUnit = YES;
                        }
                        [JJBayerContour sharedInstance].didSkipMeterInfo = YES;
                        
#ifdef DEBUG_LIB
                        DLog(@"BAYER 2 THE SN IS %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
                        DLog(@"current time is %@", [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime);
                        DLog(@"last date time is %@", [H2SyncReport sharedInstance].serverBgLastDateTime );
#endif
                        
                    }else{// Record Data Process
                        if ([H2AudioAndBleSync sharedInstance].dataLength > 48) {
                            
                            [H2Records sharedInstance].bgTmpRecord = [[JJBayerContour sharedInstance] jjContourDateTimeValueParser:[H2AudioAndBleSync sharedInstance].recordIndex];
                            
                            
                            if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]) {
                                
                                [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                            }
                        }
                        
                    }
                    break;
                    
                case 'L': // command endprocess
//                    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    
                    
                    [H2AudioAndBleSync sharedInstance].recordIndex = 0;
#ifdef DEBUG_LIB
                    DLog(@"the Contour command end processing");
#endif
                    break;
                    
                default:
                    break;
            }
            
            if ([H2SyncStatus sharedInstance].didReportFinished == NO) {
#ifdef DEBUG_LIB
                DLog(@"BAYER_DEBUG ..... OOOOOO");
#endif
                if ([H2AudioAndBleSync sharedInstance].dataBuffer[2] != 'L' ) { // total command end
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
                    
                    if ([JJBayerContour sharedInstance].isBayerOldFWVersion) {
                        if ([H2AudioAndBleSync sharedInstance].dataBuffer[1] - _bayerParam == 1 && [H2AudioAndBleSync sharedInstance].recordIndex != 1) {
                            if ([JJBayerContour sharedInstance].isSyncSecondStageRunning) {
                                if ([H2BayerEventProcess sharedInstance].bayerTag == [H2AudioAndBleSync sharedInstance].dataBuffer[2] && [H2AudioAndBleSync sharedInstance].dataBuffer[2] == 'R') {
#ifdef DEBUG_LIB
                                    DLog(@"BAYER_DEBUG_ONE");
#endif
                                    [self h2SyncBayerGeneral];
                                }
                            }else{
                                [self h2SyncBayerGeneral];
#ifdef DEBUG_LIB
                                DLog(@"BAYER_DEBUG_ OR HERE");
#endif
                            }
                            
                        }
                        _bayerParam = [H2AudioAndBleSync sharedInstance].dataBuffer[1];
                        if (_bayerParam == '7') {
                            _bayerParam = 0x2F;
                        }
                    }else{
                        //                        DLog(@"BAYER_DEBUG_SECOND");
                        [self h2SyncBayerGeneral];
                    }
                }
            }
            
            [H2BayerEventProcess sharedInstance].bayerTag = [H2AudioAndBleSync sharedInstance].dataBuffer[2];
            
            
            break;
        ////////////////////////////////////////////////////////////////////////////////////////////////////
            //
            //
#if 1
        case METHOD_4:
            switch ([H2AudioAndBleSync sharedInstance].dataBuffer[2]) {
                case 'H': // head process
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[1] == '1') { // current time // brand
                        [H2SyncReport sharedInstance].reportMeterInfo = [[JJBayerContour sharedInstance] jjContourCurrentTimeParserEx];
                        
                        [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_4;
                        [self h2SyncBayerGeneral];
                        
                    }
                    break;

                case 'R': // unit process
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[2 + 2] == '1') { // unit Parser
                        
                        [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = [[JJBayerContour sharedInstance] jjContourUnitParserEx];
                        NSRange unitRange = [[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit rangeOfString:@"mg/dL"];
                        if (unitRange.location != NSNotFound) {
                            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT;
                            [JJBayerContour sharedInstance].didBayerMmolUnit = NO;
                        }else{
                            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = BG_UNIT_EX;
                            [JJBayerContour sharedInstance].didBayerMmolUnit = YES;
                        }
                        
                        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                        [H2SyncReport sharedInstance].didSendEquipInformation = YES;
                        
                        
#ifdef DEBUG_LIB
                        DLog(@"BAYER 3 THE SN IS %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
                        DLog(@"current time is %@", [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime);
                        DLog(@"last date time is %@", [H2SyncReport sharedInstance].serverBgLastDateTime );
#endif
                        
                    }
                    break;
                    
                case 'O':
                case 'P':
#ifdef DEBUG_LIB
                    DLog(@"control solution here do not thing");
#endif
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_4;
                    [self h2SyncBayerGeneral];
                    break;
                    
                default:
                    break;
            }
            
            break;
#endif
        case METHOD_VERSION:
            switch ([H2AudioAndBleSync sharedInstance].dataBuffer[2]) {
                case 'H': // head process
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[1] == '1') { // current time // brand
                        [H2SyncReport sharedInstance].reportMeterInfo = [[JJBayerContour sharedInstance] jjContourCurrentTimeParserEx];
                        
                        [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
                        
                    }
                    break;
                    
                case 'R': // unit process
                    // Record Data Process
                    [H2Records sharedInstance].bgTmpRecord = [[JJBayerContour sharedInstance] jjContourBLEDateTimeValueParser];
                    if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]) {
                        
                        if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                            [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                        }
                    }
                    break;
                    
                case 'L': // command endprocess
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                    DLog(@"the Contour command END processing");
#endif
                    break;
                    
                case 'O':
                case 'P':
                default:
#ifdef DEBUG_LIB
                    DLog(@"control solution here do not thing");
#endif
                    break;
            }
            
            
            
            if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
                [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
#ifdef DEBUG_LIB
                DLog(@"BLE BAYER FINISHED HERE");
#endif
                
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
                [self h2SyncBayerGeneral];
#ifdef DEBUG_LIB
                DLog(@"BLE BAYER SEND VERSION METHOD");
#endif
            }
            break;
            
        default:
            break;
    }
}




#pragma mark - BAYER CONTOUR COMMAND
- (void)h2SyncBayerGeneral{
    [[JJBayerContour sharedInstance] jjBayerCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}

- (void)bayerUartInitEx{
    [[H2DataFlow sharedDataFlowInstance] h2CableUartInit:nil];
#ifdef DEBUG_LIB
    DLog(@"BAYER DEBUG -- Did come to Send Uart Init in Bayer Process");
#endif
}

- (void)bayerSerialNumberProcess
{
    //DLog(@"BAYER %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
    // Get Serial Number From Meter
    if ([[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber isEqualToString:@""]) {
        return;
    }else{
        [[H2Sync sharedInstance] sdkEquipInfoProcess:[H2Records sharedInstance].dataTypeFilter withSvrUserId:[H2Records sharedInstance].equipUserIdFilter];
    }
    //didSkipMeterInfo
    // LDT Update

    // Get LDT for Compare
    NSString *subLdtYear = [[H2SyncReport sharedInstance].serverBgLastDateTime substringWithRange:NSMakeRange(0, 4)];
#ifdef DEBUG_LIB
    NSString *subCurrentYear = [[H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime substringWithRange:NSMakeRange(0, 4)];
    DLog(@"BAYER DEBUG -- THE YEAR SVR = %@ and CUR = %@", subLdtYear, subCurrentYear);
#endif
    if ([JJBayerContour sharedInstance].isBayerOldFWVersion) {
        [H2SyncReport sharedInstance].cableBayerLastDateTime = [NSString stringWithFormat:@"%04d-01-01 00:00:00 +0000",[subLdtYear intValue]];
    }else{
        [H2SyncReport sharedInstance].cableBayerLastDateTime = [H2SyncReport sharedInstance].serverBgLastDateTime;
    }
}

@end


