//
//  H2RocheEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "ACAviva.h"
#include "ACCompactPlus.h"

#import "H2Config.h"
#import "H2Report.h"
#import "H2RocheEventProcess.h"

#import "H2DataFlow.h"
#import "H2BleService.h"

#import "H2Records.h"

@interface H2RocheEventProcess()
{
    UInt8 indexIncRocheBuffer;
}

@end

@implementation H2RocheEventProcess

- (id)init
{
    if (self = [super init]) {
        _didSkipMeterEndCmd = NO;
        
        _didSendMeterPreCmd = NO;
        _resendCount = ROCHE_RESEND_TIME_MAX;
    }
    return self;
}


+ (H2RocheEventProcess *)sharedInstance
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


- (void)h2RocheInfoRecordProcess
{
    
#ifdef DEBUG_ACCU_CHEK
    DLog(@"ACCU-CHEK  PRE CMD %02X, CURRENT CMD %02X", [H2AudioAndBleCommand sharedInstance].cmdPreMethod, [H2AudioAndBleCommand sharedInstance].cmdMethod);
#endif
    BOOL rocheNak = NO;
    _didRocheSendGeneralCommand = NO;
    _didRocheSendRecordCommand = NO;
    if ([H2AudioAndBleSync sharedInstance].dataBuffer[1] == ACCU_CHEK_CMD_NAK) {
        
        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_4;
        
        [H2SyncSystemMessageInfo sharedInstance].syncInfoRocheNakTimes++;
        rocheNak = YES;
    }
    if ([H2RocheEventProcess sharedInstance].didSendMeterPreCmd) {
#ifdef DEBUG_ACCU_CHEK
        DLog(@"ACCU-CHEK  PRE CMD - RETURN ");
#endif
        // ROCHE RESEND COMMAND
        [H2RocheEventProcess sharedInstance].didSendMeterPreCmd = NO;
        [H2AudioAndBleCommand sharedInstance].cmdMethod = [H2AudioAndBleCommand sharedInstance].cmdPreMethod;
        
        if (_resendCount == 0) {
            [H2SyncReport sharedInstance].didSyncFail = YES;
            return;
        }
        _resendCount--;
        if ([H2AudioAndBleCommand sharedInstance].cmdPreMethod == METHOD_RECORD) {
            if((([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0xF0)>>4) >= MODEL_COMPACTPLUS) {
                [self h2SyncCompactPlusReadRecord];
            }else{
                [self h2SyncAvivaReadRecord];
            }
            
            
        }else{
            if((([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0xF0)>>4) >= MODEL_COMPACTPLUS) {
                [self h2SyncCompactPlusGeneral];
            }else{
                [self h2SyncAvivaGeneral];
            }
            
        }
        return;
    }
    _resendCount = ROCHE_RESEND_TIME_MAX;
    switch (([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0xF0)>>4) {
        case MODEL_AVIVA:
        case MODEL_PREFORMA:
        case MODEL_NANO:
        case MODEL_AVIVA_NANO:
            
        case MODEL_ACCU_CHEK_EX_4:
        case MODEL_ACCU_CHEK_EX_5:
        case MODEL_ACCU_CHEK_EX_6:
        case MODEL_ACCU_CHEK_EX_7:
        case MODEL_ACCU_CHEK_EX_8:
        case MODEL_ACCU_CHEK_EX_9:
            if (rocheNak) {
#ifdef DEBUG_LIB
                    DLog(@"ROCHE_DEBU  AVIVA_NAK --- ");
#endif
                [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(h2SyncAvivaGeneral) userInfo:nil repeats:NO];
            }else{
                [self receivedDataProcessAccuChekAviva];
            }
            break;
            
        case MODEL_COMPACTPLUS:
        case MODEL_ACTIVE:
        case MODEL_ACCU_CHEK_EX_C:
        case MODEL_ACCU_CHEK_EX_D:
        case MODEL_ACCU_CHEK_EX_E:
        case MODEL_ACCU_CHEK_EX_F:
            if (rocheNak) {
#ifdef DEBUG_LIB
                    DLog(@"ROCHE_DEBU  COMPACTPLUS_NAK --- ");
                
#endif
                [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(h2SyncCompactPlusGeneral) userInfo:nil repeats:NO];
            }else{
                [self receivedDataProcessAccuChekCompactPlus];
            }
            break;
            
        default:
            break;
    }
}

- (void)receivedDataProcessAccuChekAviva
{
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_BRAND;
            _didRocheSendGeneralCommand = YES;
            _didSkipMeterEndCmd = NO;
            break;

        case METHOD_NROFRECORD:
            
            [H2AudioAndBleSync sharedInstance].recordTotal = [[H2RocheAviva sharedInstance] acAvivaParserNumberOfRecord];
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
#ifdef DEBUG_LIB
                DLog(@"AVIVA DEBUG Record Numberis %d", [H2AudioAndBleSync sharedInstance].recordTotal);
#endif
           
            [H2AudioAndBleSync sharedInstance].recordIndex = 1;
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            [H2SyncReport sharedInstance].reportMeterInfo.smWantToReadRecord = YES;
            if ([H2AudioAndBleSync sharedInstance].recordTotal == 0) {
                [H2SyncReport sharedInstance].didSendEquipInformation = NO;
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                _didRocheSendGeneralCommand = YES;
            }
            break;
            
        case METHOD_RECORD:
            [H2AudioAndBleSync sharedInstance].recordIndex++;
            [H2Records sharedInstance].bgTmpRecord = [[H2RocheAviva sharedInstance] acAvivaDateTimeValueParser:[H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag];
            
            if ([H2Records sharedInstance].bgTmpRecord == nil) {
                
                if ([H2AudioAndBleSync sharedInstance].recordIndex > [H2AudioAndBleSync sharedInstance].recordTotal) {
#ifdef DEBUG_LIB
                    DLog(@"AVIVA ENDING XX");
#endif
                    _didRocheSendGeneralCommand = YES;
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                }else{
                    _didRocheSendRecordCommand = YES;
                }
            }else{
                
                if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"] || [[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]) {
                    if ([H2AudioAndBleSync sharedInstance].recordIndex > [H2AudioAndBleSync sharedInstance].recordTotal) {
#ifdef DEBUG_LIB
                        DLog(@"AVIVA ENDING 0");
#endif
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                        _didRocheSendGeneralCommand = YES;
                    }else{
                        _didRocheSendRecordCommand = YES;
                    }
                }else{
                    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                        
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                        if ( [H2AudioAndBleSync sharedInstance].recordIndex > [H2AudioAndBleSync sharedInstance].recordTotal) {
#ifdef DEBUG_LIB
                            DLog(@"AVIVA ENDING 1");
#endif
                            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                            _didRocheSendGeneralCommand = YES;
                        }else{
#ifdef DEBUG_LIB
                            DLog(@"AVIVA NORMAL RECORD");
#endif
                            _didRocheSendRecordCommand = YES;
                        }
                    }else{
#ifdef DEBUG_LIB
                        DLog(@"AVIVA ENDING 2");
#endif
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                        _didRocheSendGeneralCommand = YES;
                    }
                }
            }

            break;
            
        case METHOD_UNIT:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = [[H2RocheAviva sharedInstance] acAvivaParserEx];
            if ([H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
            }else{
                if ([[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit isEqualToString:@"mg/dl"]) {
                    [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = NO;
                }else{
                    if ([[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit isEqualToString:@"mmol/l"]) {
                        [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = YES;
                    }
                }
                
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
                _didRocheSendGeneralCommand = YES;
            }
#ifdef DEBUG_LIB
                DLog(@"do nothing ---- unit");
#endif
            break;
            
        case METHOD_4:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = [H2AudioAndBleCommand sharedInstance].cmdPreMethod;
            switch ([H2AudioAndBleCommand sharedInstance].cmdMethod) {
                case METHOD_RECORD:
                    [self h2SyncAvivaReadRecord];
                    break;
                    
                case METHOD_NROFRECORD:
                case METHOD_UNIT:
                case METHOD_BRAND:
                case METHOD_MODEL:
                case METHOD_SN:
                case METHOD_DATE:
                case METHOD_TIME:
                    [self h2SyncAvivaGeneral];
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case METHOD_END:
            if ([H2AudioAndBleSync sharedInstance].recordTotal == 0) {
                [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            }
#ifdef DEBUG_LIB
            DLog(@"NANO-DEBUG");
#endif
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            break;
            
        case METHOD_BRAND:
            [H2SyncReport sharedInstance].reportMeterInfo.smBrandName = [[H2RocheAviva sharedInstance] acAvivaParserEx];
            if ([H2SyncReport sharedInstance].reportMeterInfo.smBrandName == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
            }else{
                NSRange accuBrand = [[H2SyncReport sharedInstance].reportMeterInfo.smBrandName rangeOfString:@"Aviva ASIC"];
                
                if (accuBrand.location != NSNotFound) {
#ifdef DEBUG_LIB
                    DLog(@"get accu brand name  -+-+ %@", [H2SyncReport sharedInstance].reportMeterInfo.smBrandName);
#endif
                }
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
                _didRocheSendGeneralCommand = YES;
            }
            break;
            
        case METHOD_MODEL:
            [H2SyncReport sharedInstance].reportMeterInfo.smModelName = [[H2RocheAviva sharedInstance] acAvivaParserEx];
            if ([H2SyncReport sharedInstance].reportMeterInfo.smModelName == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                _didRocheSendGeneralCommand = YES;
            }
            break;
            
        case METHOD_SN:
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[H2RocheAviva sharedInstance] acAvivaParserEx];
            if ([H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
            }else{
                // ?????
                [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[H2SyncReport sharedInstance].reportMeterInfo.smModelName stringByAppendingString:[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber];
                [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
                
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_DATE;
                _didRocheSendGeneralCommand = YES;
            }
            break;
            
        case METHOD_DATE:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[H2RocheAviva sharedInstance] acAvivaDateParserEx];
            if ([H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
                _didRocheSendGeneralCommand = YES;
            }
            
            break;
            
        case METHOD_TIME:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[H2RocheAviva sharedInstance] acAvivaTimeParserEx:[H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime];
            if ([H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_UNIT;
                _didRocheSendGeneralCommand = YES;
            }
            break;
            
            
        default:
            break;
    }
    
    if (_didRocheSendGeneralCommand) {
        [self h2SyncAvivaGeneral];
    }
    
    if (_didRocheSendRecordCommand) {
        [self h2SyncAvivaReadRecord];
    }
    
}

- (void)receivedDataProcessAccuChekCompactPlus
{
    
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_BRAND;
            [self h2SyncCompactPlusGeneral];
            _didSkipMeterEndCmd = NO;

            break;
            
        case METHOD_NROFRECORD:
            indexIncRocheBuffer=0;
            do {
                if ([H2AudioAndBleSync sharedInstance].dataBuffer[indexIncRocheBuffer] == 0x02) {
                    break;
                }
                indexIncRocheBuffer++;
            } while (indexIncRocheBuffer < [H2AudioAndBleSync sharedInstance].dataLength);
            
            [H2AudioAndBleSync sharedInstance].recordTotal =
            ([H2AudioAndBleSync sharedInstance].dataBuffer[indexIncRocheBuffer +4] - 0x30) * 100 +
            ([H2AudioAndBleSync sharedInstance].dataBuffer[indexIncRocheBuffer +5] - 0x30) * 10 +
            ([H2AudioAndBleSync sharedInstance].dataBuffer[indexIncRocheBuffer +6] - 0x30);
            
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            
            if ([H2AudioAndBleSync sharedInstance].recordTotal > ACCU_ACTIVE_DINDEX_MAX && [H2DataFlow sharedDataFlowInstance].equipUartProtocol == SM_ACCUCHEK_ACTIVE) {
                [H2AudioAndBleSync sharedInstance].recordTotal = ACCU_ACTIVE_DINDEX_MAX+1;
            }
            

#ifdef DEBUG_LIB
                DLog(@"COM PLUS recordNumberis %d", [H2AudioAndBleSync sharedInstance].recordTotal);
#endif
            [H2AudioAndBleSync sharedInstance].recordIndex = 1;
            if ([H2AudioAndBleSync sharedInstance].recordTotal > 0) {
                [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                [self h2SyncCompactPlusGeneral];

            }
            break;
            
        case METHOD_RECORD:
            [H2AudioAndBleSync sharedInstance].recordIndex++;
            [H2Records sharedInstance].bgTmpRecord = [[H2RocheCompactPlus sharedInstance] acCompactPlusDateTimeValueParser:[H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag];
            
            if ([H2Records sharedInstance].bgTmpRecord == nil) {
                if ( [H2AudioAndBleSync sharedInstance].recordTotal > [H2AudioAndBleSync sharedInstance].recordIndex) {
                    [self h2SyncCompactPlusReadRecord];
                }else{
#ifdef DEBUG_LIB
                    DLog(@"COMPACT PLUS ENDING 0");
#endif
                    //                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                    [self h2SyncCompactPlusGeneral];
                }
            }
            
            
            if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"] || [[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]) {
                if ( [H2AudioAndBleSync sharedInstance].recordTotal > [H2AudioAndBleSync sharedInstance].recordIndex) {
                    [self h2SyncCompactPlusReadRecord];
                    return;
                }else{
#ifdef DEBUG_LIB
                    DLog(@"COMPACT PLUS ENDING 0");
#endif
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                    [self h2SyncCompactPlusGeneral];
                }
                
            }else{
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    if ([H2AudioAndBleSync sharedInstance].recordTotal < [H2AudioAndBleSync sharedInstance].recordIndex) {
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
#ifdef DEBUG_LIB
                        DLog(@"COMPACT PLUS ENDING 1");
#endif
                        [self h2SyncCompactPlusGeneral];
                    }else{
#ifdef DEBUG_LIB
                        DLog(@"COMPACT PLUS NORMAL RECORD");
#endif
                        [self h2SyncCompactPlusReadRecord];
                    }
                }else{
#ifdef DEBUG_LIB
                    DLog(@"COMPACT PLUS ENDING 2");
#endif
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                    [self h2SyncCompactPlusGeneral];
                }
                
            }
            
 
            break;
            
            
            
        case METHOD_UNIT:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = [[H2RocheCompactPlus sharedInstance] acCompactPlusParserEx];
            
            if ([[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit isEqualToString:@"mmol/l"]) {
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = YES;
            }else{
                if ([[H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit isEqualToString:@"mg/dl"]) {
                    [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = NO;
                }
            }
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            [self h2SyncCompactPlusGeneral];
            break;
            
        case METHOD_4:
#ifdef DEBUG_ACCU_CHEK
            DLog(@"ACCU-CHEK METHOD 4 PRE %02X, CURRENT %02X", [H2AudioAndBleCommand sharedInstance].cmdPreMethod, [H2AudioAndBleCommand sharedInstance].cmdMethod);
#endif
            [H2AudioAndBleCommand sharedInstance].cmdMethod = [H2AudioAndBleCommand sharedInstance].cmdPreMethod;
            switch ([H2AudioAndBleCommand sharedInstance].cmdMethod) {
                case METHOD_RECORD:
                    [self h2SyncCompactPlusReadRecord];
                    break;
                case METHOD_NROFRECORD:
                case METHOD_UNIT:
                case METHOD_BRAND:
                case METHOD_MODEL:
                case METHOD_SN:
                case METHOD_DATE:
                case METHOD_TIME:
                    [self h2SyncCompactPlusGeneral];

                    break;
                    
                    
                default:
                    break;
            }
            
            break;
            
        
            
        case METHOD_END:
            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
            [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            break;
            
        case METHOD_BRAND:
            [H2SyncReport sharedInstance].reportMeterInfo.smBrandName = [[H2RocheCompactPlus sharedInstance] acCompactPlusParserEx];
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
            [self h2SyncCompactPlusGeneral];
            break;
            
        case METHOD_MODEL:
            [H2SyncReport sharedInstance].reportMeterInfo.smModelName = [[H2RocheCompactPlus sharedInstance] acCompactPlusParserEx];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            [self h2SyncCompactPlusGeneral];
            break;
            
        case METHOD_SN:
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[H2RocheCompactPlus sharedInstance] acCompactPlusParserEx];
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[H2SyncReport sharedInstance].reportMeterInfo.smModelName stringByAppendingString:[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber];
            
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_DATE;
            [self h2SyncCompactPlusGeneral];
            break;
            
        case METHOD_DATE:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[H2RocheCompactPlus sharedInstance] acCompactPlusDateParserEx];
            if ([H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
                return;
            }
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            [self h2SyncCompactPlusGeneral];
            break;
            
        case METHOD_TIME:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[H2RocheCompactPlus sharedInstance] acCompactPlusTimeParserEx:[H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime];
            
            if ([H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime == nil) {
                [H2SyncReport sharedInstance].didSyncFail = YES;
                return;
            }
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_UNIT;
            [self h2SyncCompactPlusGeneral];
            break;
            
        default:
            break;
    }
    
    
}

- (void)h2SynRocheResetMeter{
    [H2RocheEventProcess sharedInstance].didSendMeterPreCmd = YES;
    if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0x0F) >= MODEL_COMPACTPLUS) {
        [self h2SyncCompactPlusGeneral];
    }else{
        [self h2SyncAvivaGeneral];
    }
}

#pragma mark -
#pragma mark ACCU CHEK COMPACT PLUS COMMAND
    
- (void)h2SyncCompactPlusGeneral{
    if ((([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_INIT) || ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_END))) {
#ifdef DEBUG_LIB
        DLog(@"ROCHE_DEBUG PRE COMMAND COMPACT PLUS .... INIT or END");
#endif
        [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = NO;
    }else{
        [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = YES;
    }

    if ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_END) {
//        _didAudioSkipOffSW = YES;
    }
    
    if ([H2BleService sharedInstance].isBleCable && [H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_END)
    {
        _didSkipMeterEndCmd = YES;
    }

    [[H2RocheCompactPlus sharedInstance] CompactPlusCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}
    
- (void)h2SyncCompactPlusReadRecord
{
    [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = YES;
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
    [[H2RocheCompactPlus sharedInstance] CompactPlusReadRecord: [H2AudioAndBleSync sharedInstance].recordIndex];
    
}
    
    
#pragma mark -
#pragma mark ACCU CHEK AVIVA
- (void)h2SyncAvivaGeneral{
    if ((([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_INIT) || ([H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_END))) {
#ifdef DEBUG_LIB
        DLog(@"ROCHE_DEBUG PRE COMMAND .... INIT or END");
#endif
        [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = NO;
    }else{
        [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = YES;
    }


    if ([H2BleService sharedInstance].isBleCable && [H2AudioAndBleCommand sharedInstance].cmdMethod == METHOD_END)
    {
        _didSkipMeterEndCmd = YES;
    }

    [[H2RocheAviva sharedInstance] AvivaCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}
    
- (void)h2SyncAvivaReadRecord
{
    [H2AudioAndBleResendCfg sharedInstance].didNeedSaveRocheTypePreCmd = YES;
    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
    [[H2RocheAviva sharedInstance] AvivaReadRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
}





@end
