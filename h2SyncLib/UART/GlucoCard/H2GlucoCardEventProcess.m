//
//  H2GlucoCardEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//
#import "GlucoCardVital.h"
#import "ROConfirm.h"
#import "H2Config.h"

#import "H2RocheEventProcess.h"
#import "H2GlucoCardEventProcess.h"

#import "H2DataFlow.h"
#import "H2Records.h"



@interface H2GlucoCardEventProcess()
{
}
@end

@implementation H2GlucoCardEventProcess


#pragma mark - GLUCOCARD VITAL PROCESS
- (id)init
{
    if (self = [super init]) {
    }
    return self;
}


+ (H2GlucoCardEventProcess *)sharedInstance
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

#pragma mark - DISPATCH GLUCOCARD METER DATA
- (void)h2GlucoCardInfoRecordProcess
{
    
//    if ([H2RocheEventProcess sharedInstance].didSendMeterPreCmd) {
//        return;
//    }
    if ([GlucoCardVital sharedInstance].h2SyncIsVitalHighSpeedMode) { // fast
        [self receivedDataProcessGlucoCardVital];
    }else{
        [self receivedDataProcessReliOnConfirm];
    }
}



- (void)receivedDataProcessGlucoCardVital
{
    UInt8 idx=0;
    unsigned char tmp[4] = {0};
    NSString *string;
    

    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            [H2SyncReport sharedInstance].reportMeterInfo = [[ReliOnConfirm sharedInstance] reliOnConfirmCurrentTimeParser];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_BRAND;
            [self h2SyncGlucoCardVitalGeneral];
            break;
            
        case METHOD_BRAND:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
            [self h2SyncGlucoCardVitalGeneral];
            break;
            
        case METHOD_MODEL:
            [[ReliOnConfirm sharedInstance ] reliOnConfirmModelParser];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            [self h2SyncGlucoCardVitalGeneral];
            break;
            
        case METHOD_SN:
            do {
                if ([H2AudioAndBleSync sharedInstance].dataBuffer[idx] == '|') {
                    memcpy(tmp, &[H2AudioAndBleSync sharedInstance].dataBuffer[idx+1], 3);
                    string = [NSString stringWithUTF8String:(const char *)tmp];
                    break;
                }
                idx++;
            } while ([H2AudioAndBleSync sharedInstance].dataBuffer[idx] != 0x0D);
            
            [H2AudioAndBleSync sharedInstance].recordTotal = [string intValue];
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [H2AudioAndBleSync sharedInstance].recordIndex = 0;
            
#ifdef DEBUG_LIB
                DLog(@"ReliOn Confirm recordNumberis %d", [H2AudioAndBleSync sharedInstance].recordTotal);
#endif
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            break;
            
        
            
        case METHOD_RECORD:
            DLog(@"GLUCOCARD_DEBUG 0");
            [H2Records sharedInstance].bgTmpRecord = [[ReliOnConfirm sharedInstance ] reliOnConfirmDateTimeValueParser];
            
            if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                DLog(@"GLUCOCARD_DEBUG 1");
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                    DLog(@"GLUCOCARD_DEBUG 2");
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }else{
                    DLog(@"GLUCOCARD_DEBUG 3");
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }
            
            // record start at index 0
            if (![H2SyncReport sharedInstance].didSyncRecordFinished) {
                DLog(@"GLUCOCARD_DEBUG 4, index %d", [H2AudioAndBleSync sharedInstance].recordIndex);
                if ([H2AudioAndBleSync sharedInstance].recordTotal - [H2AudioAndBleSync sharedInstance].recordIndex > 1)
                {
                    [H2AudioAndBleSync sharedInstance].recordIndex++;
                    DLog(@"GLUCOCARD_DEBUG 5");
                    [self h2SyncGlucoCardVitalReadRecord];
                }else{
                    DLog(@"GLUCOCARD_DEBUG 6");
                   [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }
            break;
            
        default:
            break;
    }
}


- (void)receivedDataProcessReliOnConfirm
{
//    UInt8 idx = 0;
 //   unsigned char tmp[4] = {0};
//    NSString *string;
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
    
#ifdef DEBUG_LIB
        DLog(@"RELION_DEBUG OLD PROCESS ---- ");

    DLog(@"RELION_DEBUG DA DA DA ---- ");
#endif

    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
//            if ([H2AudioAndBleSync sharedInstance].dataBuffer[0] == 7) {
//                return;
 //           }
            if ([H2AudioAndBleSync sharedInstance].dataLength > 1) {
                [H2SyncReport sharedInstance].reportMeterInfo = [[ReliOnConfirm sharedInstance ] reliOnConfirmCurrentTimeParser];
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_BRAND;
                [self h2SyncReliOnGeneral];
            }else{
                [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            }
            break;
            
            
        case METHOD_BRAND:
            if ([H2AudioAndBleSync sharedInstance].dataBuffer[0] == 4) {
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_BRAND;
                [self h2SyncReliOnLoop];
            }else if([H2AudioAndBleSync sharedInstance].dataBuffer[0] == 6){
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
                [self h2SyncReliOnGeneral];
            }
            break;
            
        case METHOD_MODEL:
            if ([H2AudioAndBleSync sharedInstance].dataLength > 1) {
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                [self h2SyncReliOnGeneral];
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
                [self h2SyncReliOnLoop];
            }
/*
            if ([H2SyncMeterCommand sharedInstance].cmdData[0] == 'R' || [H2SyncMeterCommand sharedInstance].cmdData[0] == 'C') {
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
                [self h2SyncReliOnLoop];
            }else if ([H2AudioAndBleSync sharedInstance].dataBuffer[0] == 6){
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
                [self h2SyncReliOnLoop];
            }else if ([H2AudioAndBleSync sharedInstance].dataLength > 1){
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                [self h2SyncReliOnGeneral];
            }else{
                [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
                return;
            }
*/
            break;
            
        case METHOD_SN:
            if ([H2AudioAndBleSync sharedInstance].dataLength > 1) {
                DLog(@"SN - 2");
                [H2AudioAndBleSync sharedInstance].recordTotal = [[ReliOnConfirm sharedInstance] reliOnNumberOfParser];
                
#ifdef  ZERO_T
                [H2AudioAndBleSync sharedInstance].recordTotal = 0;
                DLog(@"EMPTY TEST &&&&&");
#endif
                [H2AudioAndBleSync sharedInstance].recordIndex = 0;
#ifdef DEBUG_LIB
                DLog(@"ReliOn Confirm recordNumberis %d", [H2AudioAndBleSync sharedInstance].recordIndex);
#endif
                [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
                
                [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                [self h2SyncReliOnLoop];
            }
            
#if 0
            if ([H2SyncMeterCommand sharedInstance].cmdData[0] == 'R' || [H2SyncMeterCommand sharedInstance].cmdData[0] == 'M') {
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                [self h2SyncReliOnLoop];
                DLog(@"SN - 0");
            }else if ([H2AudioAndBleSync sharedInstance].dataBuffer[0] == 6){
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                [self h2SyncReliOnLoop];
                DLog(@"SN - 1");
            }else if ([H2AudioAndBleSync sharedInstance].dataLength > 1){
                DLog(@"SN - 2");
/*
                [[ReliOnConfirm sharedInstance ] reliOnConfirmResetCounter];
                do {
                    if ([H2AudioAndBleSync sharedInstance].dataBuffer[idx] == '|') {
                        memcpy(tmp, &[H2AudioAndBleSync sharedInstance].dataBuffer[idx+1], 3);
                        string = [NSString stringWithUTF8String:(const char *)tmp];
                        break;
                    }
                    idx++;
                } while ([H2AudioAndBleSync sharedInstance].dataBuffer[idx] != 0x0D);
                
                [H2AudioAndBleSync sharedInstance].recordTotal = [string intValue];
*/
                [H2AudioAndBleSync sharedInstance].recordTotal = [[ReliOnConfirm sharedInstance] reliOnNumberOfParser];
                
#ifdef  ZERO_T
                [H2AudioAndBleSync sharedInstance].recordTotal = 0;
                DLog(@"EMPTY TEST &&&&&");
#endif
                [H2AudioAndBleSync sharedInstance].recordIndex = 0;
#ifdef DEBUG_LIB
                DLog(@"ReliOn Confirm recordNumberis %d", [H2AudioAndBleSync sharedInstance].recordIndex);
#endif
                [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
                
                [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
                [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                return;
            }else{
                [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
                return;
            }
#endif
            break;
            
            
        case METHOD_RECORD:
            if ([H2AudioAndBleSync sharedInstance].dataLength > 1){
                DLog(@"RELION RECORD 0");
                [H2Records sharedInstance].bgTmpRecord = [[ReliOnConfirm sharedInstance ] reliOnConfirmDateTimeValueParser];
                
                if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                    DLog(@"RELION RECORD 1");
                    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                        DLog(@"RELION RECORD 2");
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    }else{
                        DLog(@"RELION RECORD 3");
                        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    }
                }
                [H2AudioAndBleSync sharedInstance].recordIndex++;
                
                if ([H2AudioAndBleSync sharedInstance].recordIndex >= [H2AudioAndBleSync sharedInstance].recordTotal){
                    DLog(@"RELION RECORD 6");
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }else{
                    DLog(@"RELION RECORD 5");
                    if (![H2SyncReport sharedInstance].didSyncRecordFinished) {
                        [self h2SyncReliOnReadRecord];
                    }
                }
            }else{
                
                [self h2SyncReliOnLoop];
            }
            
            break;
            
            
        default:
            break;
    }
}

// Reset Meter - Send GlucoCard Reset Command

- (void)h2SynGlucoCardResetMeter{
    [H2RocheEventProcess sharedInstance].didSendMeterPreCmd = YES;
    DLog(@"GLUCOCARD_DEBUG RESEND INIT 1");
    if ((([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xF0) >> 4) ==  BRAND_GLUCOCARD)
    {
        DLog(@"GLUCOCARD_DEBUG RESEND INIT 2");
        [self h2SyncGlucoCardVitalGeneral];
    }else{
        [self h2SyncReliOnGeneral];
    }
}
 

#pragma mark - GLUCOCARD VITAL COMMAND

- (void)h2SyncGlucoCardVitalGeneral
{
    [[GlucoCardVital sharedInstance] GlucoCardVitalCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}
- (void)h2SyncGlucoCardVitalReadRecord
{
    [[GlucoCardVital sharedInstance] GlucoCardVitalRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
}


#pragma mark - RELION CONFIRM COMMAND
- (void)h2SyncReliOnGeneral
{
    [[ReliOnConfirm sharedInstance ] ReliOnCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}

- (void)h2SyncReliOnReadRecord
{
    [[ReliOnConfirm sharedInstance ] ReliOnReadRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
}

- (void)h2SyncReliOnLoop
{
    [[ReliOnConfirm sharedInstance] ReliOnCommandLoop];
}





@end





