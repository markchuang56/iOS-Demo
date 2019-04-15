//
//  H2SMApexBio.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/14.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "H2Config.h"
#import "Omnis.h"
#import "H2Report.h"

#import "H2AudioFacade.h"
#import "h2Sync.h"
#import "H2CableFlow.h"
#import "H2DataFlow.h"
#import "H2BleService.h"

#import "H2ApexBioEventProcess.h"

#import "H2Records.h"


unsigned char OmnisMeterExTalk[] = {
    0x00, CMD_EX_METER_TALK,
    0xBA, 0x01, 0x02, 0x03, 0x04, 0x05,
    0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B,
    0x00, 0x00, 0x0E, 0x0F,
    0x0, 0x0, 0x0, 0x0, 0x0, 0x03
};

@interface H2ApexBioEventProcess(){
    
    NSString *stringTimeIndex1;
    
    NSString *serverLastDateTimeTmp;
}


@end




#pragma mark - DISPATCH APEXBIO METER DATA
@implementation H2ApexBioEventProcess
{
    
}

- (id)init
{
    if (self = [super init]) {
        
        _EmbraceOverLoading = NO;
        _EmbraceOverBleMode = NO;
        _skipEmbraceRecordOffset = 0;
        _OmnisParserFlag = NO;

        stringTimeIndex1 = [[NSString alloc] init];
        serverLastDateTimeTmp = [[NSString alloc] init];

        
        _embraceEndingTimer = [[NSTimer alloc] init];
        
        _embraceEndingTimer = nil;
        
    }
    return self;
}

+ (H2ApexBioEventProcess *)sharedInstance
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

- (void)ApexBioEventProcess
{
    [H2AudioAndBleSync sharedInstance].syncMethodSel = [H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F;
    [H2AudioAndBleSync sharedInstance].syncModelSel = ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0xF0) >> 4;
//    switch (([H2stAudioAndBleSync sharedInstance].dataBuffer[MODEL_METHOD_AT_0] & 0xF0)>>4) {
    switch ([H2AudioAndBleSync sharedInstance].syncModelSel) {
        case 0:
            [self receivedDataProcessOmnisEmbrace];
            break;
        case 1:
        case 5:
            [self receivedDataProcessOmnisEmbraceEVO];
            break;
            
        case 2:
        case 3:
        case 4:
        case 6:
        case 8: // APEX BG001_C
            [self receivedDataProcessGlucoSureVIVO];
            break;
            
        case 7:
            [self receivedDataProcessOmnisExt];
            break;
            
            
        
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
            break;
    }
}

#pragma mark - EMBRACE PROCESS
- (void)receivedDataProcessOmnisEmbrace
{
    
    NSMutableArray *meterDateTimeValueArray = [[NSMutableArray alloc]init];
    
    unsigned long numObjects = 0;
    BOOL embraceDidFinished = NO;
    
    switch ([H2AudioAndBleSync sharedInstance].syncMethodSel) {
        case METHOD_INIT:
            if (_EmbraceOverLoading || _EmbraceOverBleMode) {
                _skipEmbraceRecordOffset = 0;
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
            }else{
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_5;
            }
            [Omnis sharedInstance].tmpIndex = 0;
            [self H2SMApexBioOmnisGeneral];
            
            break;
            
        case METHOD_NROFRECORD:
            [H2ApexBioEventProcess sharedInstance].OmnisParserFlag = [[Omnis sharedInstance] OmnisParserCheck];
#ifdef DEBUG_LIB
                DLog(@"the index Seed is %d",[Omnis sharedInstance].indexSeed);
#endif

            if ([H2AudioAndBleSync sharedInstance].recordIndex == (EMBRACE_SEED * 2) && ([H2AudioAndBleSync sharedInstance].dataBuffer[2] & 0x7F) != 0x7F) { // EQUAL TO INDEX 300
                [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            }else{
                
                if ([Omnis sharedInstance].indexSeed) {
                    if ([Omnis sharedInstance].indexSeed) {
                        [Omnis sharedInstance].indexSeed /= 2;
                    }
                    if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF){
                        [H2AudioAndBleSync sharedInstance].recordIndex -= [Omnis sharedInstance].indexSeed; // down
                        //                        DLog(@"Index down");
                    }else{
                        [H2AudioAndBleSync sharedInstance].recordIndex += [Omnis sharedInstance].indexSeed; // up
                        //                        DLog(@"Index up");
                    }
                }else{
                    //                    DLog(@"COME TO HERE 0 00000");
                    if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF){
                        if ([Omnis sharedInstance].OmnisPreYear != 0x7F && [Omnis sharedInstance].OmnisPreYearOther != 0xFF) { // DOWN
                            [H2AudioAndBleSync sharedInstance].recordIndex--;
#ifdef DEBUG_LIB
                                DLog(@"the pre current index is %d", [H2AudioAndBleSync sharedInstance].recordIndex);
                                DLog(@"ending 3 -------");
#endif
                            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
                            return;
                        }else{
                            [H2AudioAndBleSync sharedInstance].recordIndex--;
                            
                        }
                    }else{  // CURRENT
                        
                        if ([Omnis sharedInstance].OmnisPreYear == 0x7F && [Omnis sharedInstance].OmnisPreYearOther == 0xFF) {
#ifdef DEBUG_LIB_XXX
                                DLog(@"the current index is %d", [H2AudioAndBleSync sharedInstance].recordIndex);
                                DLog(@"the current meter TYPE is %d", [H2DataFlow sharedDataFlowInstance].equipUartProtocol);
                                if (_OmnisParserFlag) {
                                    DLog(@"the current index is YES");
                                    [H2SyncReport sharedInstance].reportMeterInfo.smWantToReadRecord = YES;
                                }else{
                                    DLog(@"the flag is NO");
                                }
                                DLog(@"ending 4 -------");
#endif
                            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
                            return;
                        }else{
                            [H2AudioAndBleSync sharedInstance].recordIndex++;
                        }
                    }
                }
                [Omnis sharedInstance].OmnisPreYear = ([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F);
                [Omnis sharedInstance].OmnisPreYearOther = ([H2AudioAndBleSync sharedInstance].dataBuffer[3]);

                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
                [self H2SMApexBioOmnisCmdNumberOfRecord];
                
//                if ([Omnis sharedInstance].indexSeed) {
//                    [Omnis sharedInstance].indexSeed /= 2;
//                }
            }
            break;
            
      
        case METHOD_RECORD:
#if 1
            [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisDateTimeValueParserEmbrace];
            
            if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                
#ifdef DEBUG_LIB
                    DLog(@"show the end because no data");
#endif
                break;
            }
            if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) { // continued
                
                if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"] || [[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]) {
                }else{
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }
                if ([H2AudioAndBleSync sharedInstance].recordIndex) {
                    [H2AudioAndBleSync sharedInstance].recordIndex--;
                    [self H2SMApexBioOmnisCmdRecord];
                    
                }else{
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }else{
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                    DLog(@"show the end");
#endif
            }
#endif
            break;
            
        case METHOD_5:// 1
            if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF) {
                 [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }else{
                if ([[Omnis sharedInstance] OmnisParserCheck]) {
                    [H2ApexBioEventProcess sharedInstance].OmnisParserFlag = YES;
                    [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisModelFormatParser];
                    
                    if([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]){
                        [H2SyncReport sharedInstance].didSyncFail = YES;
                    }else{
                        stringTimeIndex1 = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_6;
                        [self H2SMApexBioOmnisGeneral];
                    }
                    
                    //[NSTimer scheduledTimerWithTimeInterval:_omnisCmdInterval target:self selector:@selector(H2SMApexBioOmnisGeneral) userInfo:nil repeats:NO];
                }else{
                    [H2SyncReport sharedInstance].didSyncFail = YES;
                }
            }
            break;
        

        case METHOD_6: // 2
            if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF) {
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
//j                 = METHOD_6;
                [self H2SMApexBioOmnisGeneral];
                //[NSTimer scheduledTimerWithTimeInterval:_omnisCmdInterval target:self selector:@selector(H2SMApexBioOmnisGeneral) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
                    DLog(@"Embrace 1 data only");
#endif
            }else{
                [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisModelFormatParser];
                if([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]){
                    [H2SyncReport sharedInstance].didSyncFail = YES;
#ifdef DEBUG_LIB
                    DLog(@"Embrace 0 FAIL OR OK");
#endif
                }else{
#ifdef DEBUG_LIB
                    DLog(@"Embrace 0 OK or FAIL");
#endif
                    serverLastDateTimeTmp = [H2SyncReport sharedInstance].serverBgLastDateTime;
                    [H2SyncReport sharedInstance].serverBgLastDateTime = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
                    [H2Records sharedInstance].bgTmpRecord.bgDateTime = stringTimeIndex1;
                    
                    if ([[H2SyncReport sharedInstance] h2SyncOmnisDidGreateThanPrevious] == GREAT_THAN ){
                        // show error message
                        
                        [H2SyncReport sharedInstance].didSyncFail = YES;
                        
                    }else{
                        // Embrace format, new data in index 1
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                        
                        [self H2SMApexBioOmnisGeneral];
                    }
                    
                    
                    [H2SyncReport sharedInstance].serverBgLastDateTime = serverLastDateTimeTmp;
                    
                }
            }
            
            break;
            
        case METHOD_ACK_RECORD:
            if ([H2BleService sharedInstance].isBleCable) {
                [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
                [_embraceEndingTimer invalidate];
                _embraceEndingTimer = nil;
            }

            [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
#if 1
            meterDateTimeValueArray = [[Omnis sharedInstance] OmnisDateTimeValueParserEmbraceAll];
            
            numObjects = [meterDateTimeValueArray count];
#ifdef DEBUG_LIB
            DLog(@"THE EMBRACE NUMBER IS %lu", numObjects);
#endif
            for (H2BgRecord *infoRecord in meterDateTimeValueArray) {
                if ([infoRecord.bgMealFlag isEqualToString:@"F"]){
#ifdef DEBUG_LIB
                    DLog(@"THE EMBRACE ERROR FLAG");
#endif
                    [H2SyncReport sharedInstance].didSyncFail = YES;
                    return;
                }
                
                [H2Records sharedInstance].bgTmpRecord = infoRecord;
                if ([infoRecord.bgMealFlag isEqualToString:@"E"]){
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_OMNIS
                    DLog(@"DEBUG_EMBRACE END  --- E E E");
#endif
                    [H2AudioAndBleSync sharedInstance].recordIndex = 0;
#ifdef DEBUG_LIB
                    DLog(@"EMBRACE EEEE --- EEE");
#endif
                    embraceDidFinished = YES;
                    break;

                }else{
                    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                        [[H2SyncReport sharedInstance].recordsArray addObject:infoRecord];
                        [H2SyncReport sharedInstance].hasMultiRecords = YES;
                    }else{
#ifdef DEBUG_LIB
                        DLog(@"EMBRACE_DEBUG -- check this");
#endif
                        embraceDidFinished = YES;
                        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                            DLog(@"did EMBRACE  check this");
#endif
                        break;
                    }
                }
            }
#ifdef DEBUG_LIB
            DLog(@"EMBRACE - BLE --01");
#endif
            if ([H2BleService sharedInstance].isBleCable) {
#ifdef DEBUG_LIB
                DLog(@"EMBRACE - BLE --02");
#endif
//#ifdef HIGH_SPEED
#if 0
                _embraceEndingTimer = [NSTimer scheduledTimerWithTimeInterval:BLE_EMBRACE_ENDING_INTERVAL target:self selector:@selector(embraceBLEEndingTask) userInfo:nil repeats:NO];
#else
                if ([Omnis sharedInstance].OmnisEmbraceCount > 0) {
#ifdef DEBUG_LIB
                    DLog(@"EMBRACE - BLE --03");
#endif
                    DLog(@"EMBRACE NOT ENDING %d EM-COUNT", [Omnis sharedInstance].OmnisEmbraceCount);
                    if ([H2SyncReport sharedInstance].didSyncRecordFinished || [H2SyncReport sharedInstance].didSyncFail) {
#ifdef DEBUG_LIB
                        DLog(@"EMBRACE - BLE --04");
#endif
                        _embraceEndingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(embraceBLEEndingTask) userInfo:nil repeats:NO];
                    }else{
#ifdef DEBUG_LIB
                        DLog(@"EMBRACE - BLE --05");
#endif
                        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(H2SMApexBioOmnisCmdRecordAllCoef) userInfo:nil repeats:NO];
                    }
                }else{
#ifdef DEBUG_LIB
                    DLog(@"EMBRACE - BLE --06");
#endif
                    DLog(@"EMBRACE ENDING -- HERE ");
                    _embraceEndingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(embraceBLEEndingTask) userInfo:nil repeats:NO];
                }
#endif
            }else{
                if (!embraceDidFinished) {
                    if (_skipEmbraceRecordOffset < (EMBRACE_INDEX_MAX / EMBRACE_REPORT_COEF - 1)) {

                        _skipEmbraceRecordOffset++;
                        
#ifdef DEBUG_LIB
                        DLog(@"EMBRACE GET TOTAL COME TO -- GOING %02X", _skipEmbraceRecordOffset);
#endif
                        // Read Next 20 record
                        [H2AudioAndBleResendCfg sharedInstance].resendSystemCmdInterval = OMNIS_AUDIO_SW_ON_CMD_INTERVAL + 1.4f;
                        [H2AudioAndBleCommand sharedInstance].cmdInterval = OMNIS_AUDIO_SW_ON_CMD_INTERVAL;
                        [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                         target:self selector:@selector(H2SMApexBioOmnisCmdRecordAllTurnOn)
                                                       userInfo:nil repeats:NO];
#ifdef DEBUG_OMNIS
                        DLog(@"EMBRACE CRASH HERE 1");
#endif
                        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = NO;
//                        [self H2SMApexBioOmnisCmdRecordAllTurnOn];
                    }else{
#ifdef DEBUG_LIB
                        DLog(@"EMBRACE GET TOTAL COME TO --- END");
#endif
                        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;

                        _skipEmbraceRecordOffset = 0;
                    }
                }
            }
#endif
#ifdef DEBUG_LIB
            DLog(@"EMBRACE - BLE --07");
#endif
            
            break;
            
            
        case METHOD_SN:
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[Omnis sharedInstance] OmnisSNParser];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            
            [self H2SMApexBioOmnisGeneral];
            break;
            
        case METHOD_TIME:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[Omnis sharedInstance] OmnisCurrentTimeParser];
            
            if (_EmbraceOverLoading || _EmbraceOverBleMode) {
                [H2SyncReport sharedInstance].didSendEquipInformation = YES; // why ???
            }else{
                
                [Omnis sharedInstance].indexSeed = EMBRACE_SEED;
                [H2AudioAndBleSync sharedInstance].recordIndex = EMBRACE_SEED;
#ifdef DEBUG_OMNIS
                DLog(@"EMBRACE SET INDEX SEED ....");
#endif
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
                
                [self H2SMApexBioOmnisCmdNumberOfRecord];
            }
            
            break;
            
            
        default:
            break;
    }
}

#pragma mark - EVO PROCESS
- (void)receivedDataProcessOmnisEmbraceEVO
{
    switch ([H2AudioAndBleSync sharedInstance].syncMethodSel) {
        case METHOD_INIT:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_5;
            [self H2SMApexBioOmnisGeneral];
            break;
            
            
        case METHOD_RECORD:
            [H2AudioAndBleSync sharedInstance].recordIndex++;
            
            [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisDateTimeValueParserEVO];
            
            if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]){
                // Fail
                [H2SyncReport sharedInstance].didSyncFail = YES;
                return;
            }
            
            if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]){
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            
            if (![H2SyncReport sharedInstance].didSyncRecordFinished) {
                if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                    [self H2SMApexBioOmnisCmdRecord];
                    return;
                }
                
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                    // Get New Record Data
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    if ([H2AudioAndBleSync sharedInstance].recordIndex < 301) {
                        [self H2SMApexBioOmnisCmdRecord];
                    }
                    
                    
                }else{
                    // Ending
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }
            if ([H2AudioAndBleSync sharedInstance].recordIndex >= 301) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            
            break;
            
            
        case METHOD_5:// 1
            if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                    DLog(@"show the end because no data");
#endif
            }else{
                if ([[Omnis sharedInstance] OmnisEVOParserCheck]) {
                    [H2ApexBioEventProcess sharedInstance].OmnisParserFlag = NO;
                    [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisEVOModelFormatParser];
                    
                    if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]) {
                        [H2SyncReport sharedInstance].didSyncFail = YES;
                    }else{
                        stringTimeIndex1 = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_6;
                        [self H2SMApexBioOmnisGeneral];
                    }
                    
                }else{
#ifdef DEBUG_LIB
                        DLog(@"evo error here");
#endif
                    [H2SyncReport sharedInstance].didSyncFail = YES;
                }
            }
            break;
            
        case METHOD_6: // 2
            if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF) {
                //[Omnis sharedInstance].syncDidFinished = YES;
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                [self H2SMApexBioOmnisGeneral];
#ifdef DEBUG_LIB
                    DLog(@"EVO 1 data only");
#endif
            }else{
#ifdef DEBUG_LIB
                DLog(@"EMBRACE_DEBUG 6_1 -----");
#endif
                [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisEVOModelFormatParser];
                
                if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]) {
                    [H2SyncReport sharedInstance].didSyncFail = YES;
                }else{
                    serverLastDateTimeTmp = [H2SyncReport sharedInstance].serverBgLastDateTime;
                    [H2SyncReport sharedInstance].serverBgLastDateTime = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
                    [H2Records sharedInstance].bgTmpRecord.bgDateTime = stringTimeIndex1;
                    
                    if ([[H2SyncReport sharedInstance] h2SyncOmnisDidGreateThanPrevious] == LESS_THAN){
#ifdef DEBUG_LIB
                        DLog(@"EMBRACE_DEBUG 6_3 -----");
#endif
                        [H2SyncReport sharedInstance].didSyncFail = YES;
                    }else{
                        
                        // EVO format, new data in index 1
#ifdef DEBUG_LIB
                        DLog(@"EMBRACE_DEBUG 6_2 -----");
#endif
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                        [self H2SMApexBioOmnisGeneral];
                    }
                    [H2SyncReport sharedInstance].serverBgLastDateTime = serverLastDateTimeTmp;
                }
            }
            break;
            
            
        case METHOD_SN:
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[Omnis sharedInstance] OmnisSNParser];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            [self H2SMApexBioOmnisGeneral];
            break;
            
        case METHOD_TIME:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[Omnis sharedInstance] OmnisCurrentTimeParser];
            
            [H2AudioAndBleSync sharedInstance].recordIndex = 1;
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            
            break;
            
        default:
            break;
    }
    
}

#pragma mark - VIVO PROCESS
- (void)receivedDataProcessGlucoSureVIVO
{
    switch ([H2AudioAndBleSync sharedInstance].syncMethodSel) {
        case METHOD_INIT:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_5;
            //            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN; // for mini-B usb test
            [self H2SMApexBioOmnisGeneral];
            break;
            
        case METHOD_NROFRECORD:
            [H2SyncReport sharedInstance].serverBgLastDateTime = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
            [H2Records sharedInstance].bgTmpRecord.bgDateTime = stringTimeIndex1;
            
            
        case METHOD_RECORD:
            [H2AudioAndBleSync sharedInstance].recordIndex++;
            [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisDateTimeValueParserEmbrace];
            
            if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]){
                // Fail
                [H2SyncReport sharedInstance].didSyncFail = YES;
                return;
            }
#ifdef DEBUG_OMNIS
            DLog(@"APEX_DEBUG 0 - INDEX IS %03d", [H2AudioAndBleSync sharedInstance].recordIndex);
#endif
            if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]){
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_OMNIS
                DLog(@"APEX_DEBUG 1");
#endif
//                return;
            }
            
            if (![H2SyncReport sharedInstance].didSyncRecordFinished) {
                if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                    [self H2SMApexBioOmnisCmdRecord];
#ifdef DEBUG_OMNIS
                    DLog(@"APEX_DEBUG 2");
#endif
                    return;
                }
                
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
#ifdef DEBUG_OMNIS
                    DLog(@"APEX_DEBUG 5");
#endif
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    if ([H2AudioAndBleSync sharedInstance].recordIndex < 301){
                        [self H2SMApexBioOmnisCmdRecord];
                    }
                    
                }else{
#ifdef DEBUG_OMNIS
                    DLog(@"APEX_DEBUG 6");
#endif
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                }
            }
            if ([H2AudioAndBleSync sharedInstance].recordIndex >= 301){
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            break;
            
        case METHOD_5:// 1
            if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                    DLog(@"show the end because no data");
#endif
            }else{
                if ([[Omnis sharedInstance] OmnisParserCheck]) {
                    [H2ApexBioEventProcess sharedInstance].OmnisParserFlag = YES;
                    [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisModelFormatParser];
                    
                    if([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]){
                        [H2SyncReport sharedInstance].didSyncFail = YES;
                    }else{
                        stringTimeIndex1 = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_6;
                        [self H2SMApexBioOmnisGeneral];
                    }
                    
                    
                }else{
                    [H2SyncReport sharedInstance].didSyncFail = YES;
                }
            }
            break;
            
        case METHOD_6: // 2
            if (([H2AudioAndBleSync sharedInstance].dataBuffer[2]&0x7F) == 0x7F && [H2AudioAndBleSync sharedInstance].dataBuffer[3] == 0xFF) {
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                [self H2SMApexBioOmnisGeneral];
#ifdef DEBUG_LIB
                    DLog(@" one data only");
#endif
            }else{
                [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisModelFormatParser];
                if([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"F"]){
                    [H2SyncReport sharedInstance].didSyncFail = YES;
#ifdef DEBUG_LIB
                    DLog(@"Embrace VIVO 0 FAIL OR OK");
#endif
                }else{
#ifdef DEBUG_LIB
                    DLog(@"Embrace VIVO 0 OK or FAIL");
#endif                    
                    serverLastDateTimeTmp = [H2SyncReport sharedInstance].serverBgLastDateTime;
                    [H2SyncReport sharedInstance].serverBgLastDateTime = [H2Records sharedInstance].bgTmpRecord.bgDateTime;
                    [H2Records sharedInstance].bgTmpRecord.bgDateTime = stringTimeIndex1;
                    
                    if ([[H2SyncReport sharedInstance] h2SyncOmnisDidGreateThanPrevious] == LESS_THAN){
                        [H2SyncReport sharedInstance].didSyncFail = YES;
                    }else{
                        // VIVO format, new data in index 1
                        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_SN;
                        [self H2SMApexBioOmnisGeneral];
                    }
                    [H2SyncReport sharedInstance].serverBgLastDateTime = serverLastDateTimeTmp;
                    
                }
                
                
            }
            break;
            
            
            
        case METHOD_SN:
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[Omnis sharedInstance] OmnisSNParser];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_TIME;
            [self H2SMApexBioOmnisGeneral];
            break;
            
        case METHOD_TIME:
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [[Omnis sharedInstance] OmnisCurrentTimeParser];
            [H2AudioAndBleSync sharedInstance].recordIndex = 1;
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            break;
            
        default:
            break;
    }
}

- (void)receivedDataProcessOmnisExt
{
    switch ([H2AudioAndBleSync sharedInstance].syncMethodSel) {
        case METHOD_INIT:
            [H2ApexBioEventProcess sharedInstance].OmnisParserFlag = YES;
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            break;
            
        case METHOD_NROFRECORD:
            
            break;
            
            
            
        case METHOD_RECORD:
            
            [H2Records sharedInstance].bgTmpRecord = [[Omnis sharedInstance] OmnisDateTimeValueParserEmbrace];
            [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
            if ([H2AudioAndBleSync sharedInstance].recordIndex<300) {
                [H2AudioAndBleSync sharedInstance].recordIndex++;
                [self H2SMApexBioOmnisCmdRecord];
            }else{
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                    DLog(@"show the end");
#endif
            }
            
            break;
            
        case METHOD_ACK:
            break;
            
        case METHOD_SN:
            break;
            
        case METHOD_TIME:
            break;

        default:

            break;
        }
}




- (void)H2SMApexBioOmnisGeneral
{
    [[Omnis sharedInstance] OmnisCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}

- (void)H2SMApexBioOmnisCmdRecord
{
    [[Omnis sharedInstance] OmnisRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
}

- (void)H2SMApexBioOmnisCmdNumberOfRecord
{
    [[Omnis sharedInstance] OmnisNumberOfRecord:[H2AudioAndBleSync sharedInstance].recordIndex];
}

- (void)H2SMApexBioOmnisCmdNumberOfRecordAll
{
    [[Omnis sharedInstance] OmnisRecordAll:[H2AudioAndBleSync sharedInstance].recordIndex];
}

- (void)H2SMApexBioOmnisCmdRecordAllTurnOn
{
//    [[H2Sync sharedInstance] h2CableSwitchOn:nil];
    [H2CableFlow sharedCableFlowInstance].audioSystemCmd = CMD_SW_ON;
    [[H2CableFlow sharedCableFlowInstance] h2CableSystemCommand:nil];
    [[H2AudioFacade sharedInstance] h2AudioTriggerCommand];
#ifdef DEBUG_OMNIS
    DLog(@"EMBRACE CRASH HERE 2");
#endif
}


- (void)H2SMApexBioOmnisCmdRecordAllCoef
{
    DLog(@"EMBRACE GET ALL RECORD AT BLE MODE");
    if ([H2BleService sharedInstance].isBleCable) {
        [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_ACK_RECORD;
        [[H2ApexBioEventProcess sharedInstance] H2SMApexBioOmnisGeneral];
#ifdef HIGH_SPEED
        [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = BLE_EMBRACE_ENDING_INTERVAL;
#else
        [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = BLE_EMBRACE_ENDING_INTERVAL - 1;
#endif
        
        DLog(@"ENDING INTERVAL IS %f", BLE_EMBRACE_ENDING_INTERVAL);
        _embraceEndingTimer = [NSTimer scheduledTimerWithTimeInterval:BLE_EMBRACE_ENDING_INTERVAL target:self selector:@selector(embraceBLEEndingTask) userInfo:nil repeats:NO];
    }else{
        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
        
        unsigned char embraceTmp[sizeof(OmnisMeterExTalk)] = {0};
        memcpy(embraceTmp, OmnisMeterExTalk, sizeof(OmnisMeterExTalk));
        embraceTmp[EMBRACE_COEF_AT] = _skipEmbraceRecordOffset;
        
        embraceTmp[EMBRACE_COEF_AT + 1] = EMBRACE_SKIP_MAX | EMBRACE_SW_TURN_OFF;
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:embraceTmp withCmdLength:sizeof(OmnisMeterExTalk) cmdType:BRAND_SYSTEM returnDataLength:0 mcuBufferOffSetAt:0];
    }
    
}

- (void)embraceBLEEndingTask
{
    DLog(@"EMBRACE BLE ENDING TASK ....");
    [[H2CableFlow sharedCableFlowInstance] h2CableBLEEmbraceRecordEndingTask];
}





@end
