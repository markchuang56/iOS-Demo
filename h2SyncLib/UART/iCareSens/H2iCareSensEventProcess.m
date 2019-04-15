//
//  H2iCareSensEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//
#import "CareSensN.h"
#import "OmnisEmbracePro.h"
#import "Bionime.h"
#import "Hmd.h"
#import "Fora.h"
#import "AllianceDSA.h"
#import "H2BleCentralManager.h"

#import "H2Config.h"
#import "H2iCareSensEventProcess.h"

#import "H2DataFlow.h"
#import "H2LastDateTime.h"
#import "H2BleService.h"
#import "H2Records.h"


@interface H2iCareSensEventProcess()
{
    
}



@end

@implementation H2iCareSensEventProcess

- (id)init
{
    if (self = [super init]) {
        
        _bionimeModel = @"";
        _bionimeGM550Version = @"";

        _didiCareSensSendGeneralCommand = NO;
        _didiCareSensSendRecordCommand = NO;
    }
    return self;
}


+ (H2iCareSensEventProcess *)sharedInstance
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




#pragma mark - DISPATCH I-CARESENS METER DATA

- (void)h2CareSensInfoRecordProcess
{
    if ([H2AudioAndBleSync sharedInstance].dataBuffer[0] == 7 && [H2AudioAndBleSync sharedInstance].dataLength == 1) {
        return;
    }
    

    
    switch (([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0xF0)>>4) {
        case MODEL_CARESENS_N:
        case MODEL_CARESENS_POP:
            [self receivedDataProcessCareSensN];
            break;
            
        case MODEL_OMNIS_EMBRACE_PRO:
            [self receivedDataProcessOmnisEmbracePro];
            break;
            
        case MODEL_TYSON_TB200:
            //j            [self receivedDataProcessTyson];
            break;
            
        case MODEL_BIONIME:
            [self receivedDataProcessBionime];
            break;
            
        case MODEL_HMD:
            [self receivedDataProcessHmd];
            break;
            
        case MODEL_FORA:
            [[Fora sharedInstance] h2ForaDataProcess];
            break;
            
        case MODEL_ALLIANCE:
            [[AllianceDSA sharedInstance] allianceValueUpdate];
            break;
            
        default:
            break;
    }
    
}
#pragma mark - DATA PROCESS
#pragma mark -
#pragma mark EXT_PRO - EMBRACE PRO
- (void)receivedDataProcessCareSensN
{
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_BRAND;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_BRAND:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_MODEL:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_SN:
            [[CareSensN sharedInstance ] careSenseNSystemInfoParser];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_DATE;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_DATE: // get total of record
            [[CareSensN sharedInstance ] careSenseNSystemInfoParser];
            [H2AudioAndBleSync sharedInstance].recordTotal = ([H2AudioAndBleSync sharedInstance].dataBuffer[1] & 0x0F) * 16 + ([H2AudioAndBleSync sharedInstance].dataBuffer[2] & 0x0F);
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [H2AudioAndBleSync sharedInstance].recordIndex = [H2AudioAndBleSync sharedInstance].recordTotal;
            
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];

            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:DEF_LAST_DATE_TIME];

            break;
            
        case METHOD_RECORD:
            
            [H2Records sharedInstance].bgTmpRecord = [[CareSensN sharedInstance ] careSenseNDateTimeValueParser];
            
            [H2AudioAndBleSync sharedInstance].recordIndex--;
            
            
            _didiCareSensSendRecordCommand = YES;
            if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
 
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    
                }else{ // Reach Old Record Data
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }
            
            if ([H2AudioAndBleSync sharedInstance].recordIndex == 0) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            
            
            if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
                _didiCareSensSendRecordCommand = NO;
            }
            

            
            break;
            
        default:
            break;
    }
    
    if (_didiCareSensSendGeneralCommand) {
        _didiCareSensSendGeneralCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncCareSensNGeneral) userInfo:nil repeats:NO];
        }else{
            [self h2SyncCareSensNGeneral];
        }
        
    }
    if (_didiCareSensSendRecordCommand) {
        _didiCareSensSendRecordCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncCareSensNReadRecord) userInfo:nil repeats:NO];
        }else{
            [self h2SyncCareSensNReadRecord];
        }
        
    }
}

- (void)receivedDataProcessOmnisEmbracePro
{
    
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            _didiCareSensSendGeneralCommand = YES;
            _embraceProWriteSerialNumberCount = 3;
            break;
            
        case METHOD_BRAND:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            _didiCareSensSendGeneralCommand = YES;
            _embraceProWriteSerialNumberCount--;
            break;
            
        case  METHOD_SN:
            if ([[OmnisEmbracePro sharedInstance] omnisEmbraceProSerialNumberParser]) {
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
            }else{
                if (_embraceProWriteSerialNumberCount > 0) {
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_BRAND;
                }else{
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
                }
            }
            
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_VERSION:
#if 0
            // for setup unit test
            [NSTimer scheduledTimerWithTimeInterval:_iCareSensCmdInterval target:self selector:@selector(h2SyncEmbraceProGeneral) userInfo:nil repeats:NO];
#else
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            _didiCareSensSendGeneralCommand = YES;
//            [NSTimer scheduledTimerWithTimeInterval:_iCareSensCmdInterval target:self selector:@selector(h2SyncEmbraceProGeneral) userInfo:nil repeats:NO];
#endif
            break;
            
        case METHOD_UNIT:
            // 需設定
//            _didiCareSensSendGeneralCommand = YES;
//            [NSTimer scheduledTimerWithTimeInterval:_iCareSensCmdInterval target:self selector:@selector(h2SyncEmbraceProGeneral) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
                DLog(@"Embrace PRO come here");
#endif
            break;
            
        case METHOD_NROFRECORD:
            [H2AudioAndBleSync sharedInstance].recordTotal = [[OmnisEmbracePro sharedInstance] omnisEmbraceProNumberOfRecordParser];
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [H2AudioAndBleSync sharedInstance].recordIndex = [H2AudioAndBleSync sharedInstance].recordTotal;
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
            

            if ([H2SyncReport sharedInstance].reportMeterInfo.smWantToReadRecord) {
#ifdef DEBUG_LIB
                    DLog(@"the numer of record is %02d", [H2AudioAndBleSync sharedInstance].recordIndex);
#endif
                [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:DEF_LAST_DATE_TIME];
            }
            
            break;
        case METHOD_END:
            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
//            _didiCareSensSendRecordCommand = NO;
//            _didiCareSensSendGeneralCommand = YES;
            
#ifdef DEBUG_LIB
                DLog(@"the Embrace PRO End");
#endif
            break;
            
        case METHOD_RECORD:
            
            [H2Records sharedInstance].bgTmpRecord = [[OmnisEmbracePro sharedInstance] omnisEmbraceProDateTimeValueParser];
            [H2AudioAndBleSync sharedInstance].recordIndex--;
            _didiCareSensSendRecordCommand = YES;
            
            
            if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }else{
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
                
            }
            if ([H2AudioAndBleSync sharedInstance].recordIndex == 0) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }

            if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = NO;
                _didiCareSensSendRecordCommand = NO;
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_END;
                _didiCareSensSendGeneralCommand = YES;
            }
            break;
            
        default:
            break;
    }
    if (_didiCareSensSendGeneralCommand) {
        _didiCareSensSendGeneralCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncEmbraceProGeneral) userInfo:nil repeats:NO];
        }else{
            [self h2SyncEmbraceProGeneral];
        }
        
    }
    
    if (_didiCareSensSendRecordCommand) {
        _didiCareSensSendRecordCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncEmbraceProReadRecord) userInfo:nil repeats:NO];
        }else{
            [self h2SyncEmbraceProReadRecord];
        }
        
    }
}


#pragma mark -
#pragma mark EXT_PRO - BIONIME

- (void)receivedDataProcessBionime
{

    NSString *bionimeString;
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
            
        case METHOD_DATE:
            bionimeString = [[Bionime sharedInstance] BionimeCurrentDateTimeUnitParser];
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = bionimeString;
            [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = NO;
            if ([Bionime sharedInstance].bmIsUnitMmol) {
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag  = YES;
            }
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_MODEL:
            _bionimeModel = [[Bionime sharedInstance] BionimeModelVerSerialNrParser];
            [H2SyncReport sharedInstance].reportMeterInfo.smModelName = _bionimeModel;
            [h2MeterModelSerialNumber sharedInstance].smModel = _bionimeModel;
            
//            if ([_bionimeModel isEqualToString:BIONIME_GM550]) {
//                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
//            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
//            }
            
            
            
            _didiCareSensSendGeneralCommand = YES;
            break;
            
           
        
            
        case METHOD_VERSION:
            _bionimeGM550Version = [[Bionime sharedInstance] BionimeModelVerSerialNrParser];
            
            [H2SyncReport sharedInstance].reportMeterInfo.smVersion = _bionimeGM550Version;
#ifdef DEBUG_LIB
            DLog(@"DEBUG_GM550 come to here ....%@", _bionimeGM550Version);
#endif
            
            if ([_bionimeModel isEqualToString:BIONIME_GM550]) {
                if ([_bionimeGM550Version isEqualToString:BIONIME_GM550_B010] || [_bionimeGM550Version isEqualToString:BIONIME_GM550_B021] || [_bionimeGM550Version isEqualToString:BIONIME_GM550_B025]) {
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
#ifdef DEBUG_LIB
                    DLog(@"DEBUG_GM550 come to here ....");
#endif
                }
               [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_4;
            }
            _didiCareSensSendGeneralCommand = YES;

#if 0
#if 0
            // for setup unit test
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_4;//METHOD_SN;
            [NSTimer scheduledTimerWithTimeInterval:_iCareSensCmdInterval target:self selector:@selector(h2SyncBionimeGeneral) userInfo:nil repeats:NO];
#else
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            if ([[H2SyncReport sharedInstance].reportMeterInfo.smModelName isEqualToString:BIONIME_GM550]) {
                if ([_bionimeGM550Version isEqualToString:BIONIME_GM550_B010] || [_bionimeGM550Version isEqualToString:BIONIME_GM550_B021] || [_bionimeGM550Version isEqualToString:BIONIME_GM550_B025]) {
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
#ifdef DEBUG_LIB
                    DLog(@"DEBUG_GM550 come to here ....");
#endif
                }
            }
            
#endif
#endif
            break;
            
        case METHOD_4:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_5;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_5:
            [[Bionime sharedInstance] BionimeSerialNrLenParser];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_6;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_6:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
            
        case METHOD_SN:
            bionimeString = [[Bionime sharedInstance] BionimeModelVerSerialNrParser];
            
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = bionimeString;
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = bionimeString;
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            _didiCareSensSendGeneralCommand = YES;

#ifdef DEBUG_LIB
                DLog(@"BIONIME_DEBU come here");
#endif
            break;
            
        case METHOD_NROFRECORD:
            [H2AudioAndBleSync sharedInstance].recordTotal = [[Bionime sharedInstance] BionimeTotalRecordParser];
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [H2AudioAndBleSync sharedInstance].recordIndex = [H2AudioAndBleSync sharedInstance].recordTotal;
#ifdef DEBUG_LIB
                DLog(@"DEBUB_BIONIME Total Amount %d ", [H2AudioAndBleSync sharedInstance].recordTotal);
#endif
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];

            break;
            
        case METHOD_RECORD:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
            
            [H2AudioAndBleSync sharedInstance].recordIndex--;
            _didiCareSensSendRecordCommand = YES;
            [H2Records sharedInstance].bgTmpRecord = [[Bionime sharedInstance] BionimeDateTimeValueParser];
            
            if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                
                if([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }else{
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }
            
            if ([H2AudioAndBleSync sharedInstance].recordIndex == 0) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            
            
            if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
                _didiCareSensSendRecordCommand = NO;
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            break;
            
        default:
            break;
    }
    if (_didiCareSensSendGeneralCommand) {
        _didiCareSensSendGeneralCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncBionimeGeneral) userInfo:nil repeats:NO];
        }else{
            [self h2SyncBionimeGeneral];
        }
        
    }
    if (_didiCareSensSendRecordCommand) {
        _didiCareSensSendRecordCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncBionimeReadRecord) userInfo:nil repeats:NO];
        }else{
            [self h2SyncBionimeReadRecord];
        }
        
    }
}


#pragma mark - HMD 
- (void)receivedDataProcessHmd
{
    UInt16 numberOfRecord = 0;
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_4;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_4:
            // Init EX
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_ACK;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_ACK:
            // Meter ON
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_DATE;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_END:
            // Meter OFF
            _didiCareSensSendGeneralCommand = NO;
            break;
            
        case METHOD_DATE: // Get RTC
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[Hmd sharedInstance] HmdCurrentDateTimeParser];
            
//j            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
            
        case METHOD_NROFRECORD: // Get Number Of Record
            numberOfRecord = [H2AudioAndBleSync sharedInstance].dataBuffer[0];
            [H2AudioAndBleSync sharedInstance].recordTotal = (numberOfRecord << 8) + [H2AudioAndBleSync sharedInstance].dataBuffer[1];
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [H2AudioAndBleSync sharedInstance].recordIndex = 1;
#ifdef DEBUG_LIB
            DLog(@"HMD DEBUG Record Numberis %d", [H2AudioAndBleSync sharedInstance].recordTotal);
#endif
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];
            _didiCareSensSendGeneralCommand = NO;
            break;
            
// Second State
        case METHOD_TIME: // Product Year
            [Hmd sharedInstance].hmdProductYear = [H2AudioAndBleSync sharedInstance].dataBuffer[0];
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
//        case METHOD_BRAND:
//            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_MODEL;
//            _didiCareSensSendGeneralCommand = YES;
//            break;
            
        case METHOD_MODEL: // Query Model
            [Hmd sharedInstance].hmdModel = [H2AudioAndBleSync sharedInstance].dataBuffer[0];
            [H2SyncReport sharedInstance].reportMeterInfo.smModelName = [[Hmd sharedInstance] HmdModelParser];
            // Skip Function Command
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
//j            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_SN:  // FUN 1, Record Descriptor
            // TO DO ...
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[Hmd sharedInstance] HmdSerialNrParser];
            _didiCareSensSendGeneralCommand = YES;
            break;
            
        case METHOD_VERSION: // FUN 2, Descriptor Header
            // TO DO ... Maybe
            
            [H2AudioAndBleSync sharedInstance].recordTotal = [[Hmd sharedInstance] HmdTotalRecordNumberParser];
#ifdef  ZERO_T
            [H2AudioAndBleSync sharedInstance].recordTotal = 0;
            DLog(@"EMPTY TEST &&&&&");
#endif
            [H2AudioAndBleSync sharedInstance].recordIndex = 1;
#ifdef DEBUG_LIB
            DLog(@"HMD DEBUG Record Numberis %d", [H2AudioAndBleSync sharedInstance].recordTotal);
#endif
            [[H2SyncReport sharedInstance] h2SyncNewMeterChecking];

            _didiCareSensSendGeneralCommand = NO;
            
            break;
            
            
        case METHOD_RECORD:
            
            [H2Records sharedInstance].bgTmpRecord = [[Hmd sharedInstance ] HmdDateTimeValueParser];
            
            [H2AudioAndBleSync sharedInstance].recordIndex++;
            
            
            _didiCareSensSendRecordCommand = YES;
            if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }else{ // Reach Old Record Data
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }
            
            if ([H2AudioAndBleSync sharedInstance].recordIndex > [H2AudioAndBleSync sharedInstance].recordTotal) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            
            if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
                _didiCareSensSendRecordCommand = NO;              
            }
            
            break;
            
        default:
            break;
    }
    if (_didiCareSensSendGeneralCommand) {
        _didiCareSensSendGeneralCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncHmdGeneral) userInfo:nil repeats:NO];
        }else{
            [self h2SyncHmdGeneral];
        }
        
    }
    if (_didiCareSensSendRecordCommand) {
        _didiCareSensSendRecordCommand = NO;
        if ([H2BleService sharedInstance].isBleCable) {
            [NSTimer scheduledTimerWithTimeInterval:[H2AudioAndBleCommand sharedInstance].cmdInterval target:self selector:@selector(h2SyncHmdReadRecord) userInfo:nil repeats:NO];
        }else{
            [self h2SyncHmdReadRecord];
        }
    }
}






#pragma mark - CARESENSE N COMMAND
- (void)h2SyncCareSensNGeneral
{
    [[CareSensN sharedInstance] CareSensCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}

- (void)h2SyncCareSensNReadRecord
{
    [[CareSensN sharedInstance] CareSensReadRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
}



#pragma mark - EXT OMNIS EMBRACE PRO READ RECORD COMMAND
- (void)h2SyncEmbraceProGeneral
{
    [[OmnisEmbracePro sharedInstance] EmbraceProCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}


- (void)h2SyncEmbraceProReadRecord
{
    [[OmnisEmbracePro sharedInstance] EmbraceProReadRecord:([H2AudioAndBleSync sharedInstance].recordTotal - [H2AudioAndBleSync sharedInstance].recordIndex)];
}



#pragma mark - EXT_DEF -- BIONIME
- (void)h2SyncBionimeGeneral
{
    [[Bionime sharedInstance] BionimeCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}

- (void)h2SyncBionimeReadRecord
{
    [[Bionime sharedInstance] BionimeReadRecord:([H2AudioAndBleSync sharedInstance].recordTotal - [H2AudioAndBleSync sharedInstance].recordIndex + 1)];
}




#pragma mark - HMD COMMAND
- (void)h2SyncHmdGeneral
{
    [[Hmd sharedInstance] HmdCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
    
    //
//    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(h2SyncHmdBLERead) userInfo:nil repeats:NO];
}

- (void)h2SyncHmdReadRecord
{
    [[Hmd sharedInstance] HmdReadRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
    
}

- (void)h2SyncHmdRecordAck
{
    [[Hmd sharedInstance] HmdRecordAck:[H2AudioAndBleSync sharedInstance].recordIndex];
}


- (void)h2SyncHmdBLERead
{
//    [[H2BleCentralController sharedInstance] h2HmdReadTask];
#ifdef DEBUG_LIB
    DLog(@"HMD Read FROM ... iCareSens");
#endif
}








@end



