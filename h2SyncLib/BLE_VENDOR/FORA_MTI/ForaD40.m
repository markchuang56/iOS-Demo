//
//  Fora.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/12/9.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2Omron.h"
#import "Fora.h"
#import "ForaD40.h"


#import "H2AudioFacade.h"
#import "H2Sync.h"
#import "H2DataFlow.h"
#import "H2Records.h"

#import "H2Report.h"
#import "H2Records.h"
#import "H2LastDateTime.h"


#import "H2Config.h"
#import "H2BleTimer.h"



@interface ForaD40()
{
    
}

@end


@implementation ForaD40





- (id)init
{
    if (self = [super init]) {
        
        _isBPRecord = NO;
        _isBPAvg = NO;
        
        _bpArrhyValue = 0;
        
        _foraD40Index = 0;
        
        _foraD40Info = NO;
        _foraD40Finished = NO;
        _foraD40BgFinished = NO;
        _foraD40BpFinished = NO;
        
    }
    return self;
}



+ (ForaD40 *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


#pragma mark - FORA D40 COMMAND TASK ===
- (void)h2ForaD40CmdTask
{
    UInt8 cmdCheckSum = 0;
    
    switch ([Fora sharedInstance].foraCmdNext) {
        case FORA_CMD_FORA_CMD_NUMBER_OF_RECORD: // GET Number of Record
            _foraD40Index = 0;
            [H2Records sharedInstance].recordBgIndex = 0;
            [H2Records sharedInstance].recordBpIndex = 0;
            [Fora sharedInstance].foraCmdBuffer[CMD_AT] = FORA_CMD_FORA_CMD_NUMBER_OF_RECORD;
            [Fora sharedInstance].foraCmdBuffer[DATA_0] = [H2Records sharedInstance].currentUser+1; // NEXT USER ID
            break;
          
        case FORA_CMD_RECORD_TIME: // GET Time of Record
            [Fora sharedInstance].foraCmdBuffer[CMD_AT] = FORA_CMD_RECORD_TIME;
            [Fora sharedInstance].foraCmdBuffer[DATA_D40_ID_AT] = [H2Records sharedInstance].currentUser+1;
            memcpy(&[Fora sharedInstance].foraCmdBuffer[DATA_0], &_foraD40Index, 2);
            break;
          
        case FORA_CMD_RECORD_VALUE: // GET Value of Record
            [Fora sharedInstance].foraCmdBuffer[CMD_AT] = FORA_CMD_RECORD_VALUE;
            [Fora sharedInstance].foraCmdBuffer[DATA_D40_ID_AT] = [H2Records sharedInstance].currentUser+1;
            memcpy(&[Fora sharedInstance].foraCmdBuffer[DATA_0], &_foraD40Index, 2);
            break;
         
        case FORA_CMD_TURN_OFF:
            [Fora sharedInstance].foraCmdBuffer[CMD_AT] = FORA_CMD_TURN_OFF;
            break;
            
            
        default:
            break;
    }
    
    
    [Fora sharedInstance].foraCmdBuffer[0] = FORA_CMD_HEADER;
    [Fora sharedInstance].foraCmdBuffer[STOP] = FORA_CMD_STOP;
    
    [Fora sharedInstance].curCommand = [Fora sharedInstance].foraCmdBuffer[CMD_AT] ;
    
    for (int i = 0; i<FORA_CMD_LENGTH-1; i++) {
        cmdCheckSum += [Fora sharedInstance].foraCmdBuffer[i];
    }
    [Fora sharedInstance].foraCmdBuffer[FORA_CMD_LENGTH-1] = cmdCheckSum;
    
#ifdef DEBUG_FORA
    for(int i = 0; i<FORA_CMD_LENGTH; i++)
    {
        DLog(@"FORA D40 RECORD COMMAND %d and %02X", i, [Fora sharedInstance].foraCmdBuffer[i]);
    }
#endif
    
    if ([Fora sharedInstance].foraFinished) {
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_FORA
        DLog(@"FORA P30+ WILL STOP !! STOP !!");
#endif
    }else{
#ifdef DEBUG_FORA
        DLog(@"FORA D40 - END WR and WILL STOP");
#endif
        if ([Fora sharedInstance].foraCmdNext == FORA_CMD_TURN_OFF) {
            if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_CARESENS_EXT_B_FORA_D40){
                //[H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                _foraD40Finished = YES;
                [H2BleTimer sharedInstance].bleRecordModeForTimer = NO;
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL*2 taskSel:BLE_TIMER_RECORD_MODE];
            }
        }
        if ([H2BleTimer sharedInstance].bleRecordModeForTimer) {
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
        }
        [[Fora sharedInstance] h2ForaBLEWriteTask:[Fora sharedInstance].foraCmdBuffer withLength:FORA_CMD_LENGTH];
    }
}




#pragma mark - ### D40 D40 PROCESS

- (BOOL)foraD40NextUser
{
    BOOL toNextUser = NO;
    if ([H2Records sharedInstance].currentUser < FORA_D40_MAX_ID) {
        // Not reach MAX User id
        // Go to next user
        for (int i=0; i<FORA_D40_MAX_ID; i++) {
            if ([Fora sharedInstance].foraAppUserId & (1 << i)) {
                [H2Records sharedInstance].currentUser = i;
                [Fora sharedInstance].foraAppUserId ^= (1 << i);
                toNextUser = YES;
                break;
            }
        }
    }else{
#ifdef DEBUG_FORA
        DLog(@"REACH LAST USER %2X", [H2Records sharedInstance].currentUser);
#endif
    }
    return toNextUser;
}





- (void)h2ForaD40NumberOfRecordTask
{
    //J            _recordTotal = 0; // FOR TEST
    // 0. REPORT METER INFO, AND WAIT START SYNC
    // 1. USER ID LOOP
    // 2. NEXT USER ID
    // 3. ENDING
    //    BOOL newUserID = NO;
    
    [H2Records sharedInstance].recordBgIndex = 0;
    [H2Records sharedInstance].recordBpIndex = 0;
    [H2SyncReport sharedInstance].didSendEquipInformation = NO;
    if (_foraD40Info) {
        [H2SyncReport sharedInstance].didSendEquipInformation = YES;
        _foraD40Info = NO;
        return;
    }
    
    if ([Fora sharedInstance].recordTotal > 0) { // GET RECORD
        [Fora sharedInstance].foraCmdNext = FORA_CMD_RECORD_TIME;//FORAD40_RECORD_TIME;
    }else{
        if ([self foraD40NextUser]) {// next user (multi)
            [Fora sharedInstance].foraCmdNext = FORA_CMD_FORA_CMD_NUMBER_OF_RECORD;//FORAD40_NROFRECORD;
        }else{
            [Fora sharedInstance].foraCmdNext = FORA_CMD_TURN_OFF;//FORAD40_TURN_OFF;
        }
    }
    [self h2ForaD40CmdTask];
}



- (void)h2ForaD40RecordTask{
    
    BOOL reachOldRecord = NO;
    
    if ( [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_CARESENS_EXT_B_FORA_P30PLUS) {
        [ForaD40 sharedInstance].isBPRecord = YES;
    }
    if ([ForaD40 sharedInstance].isBPRecord) { // BP DATA
#ifdef DEBUG_FORA
        DLog(@"D40 - BP DATA = %02X", [H2Records sharedInstance].dataTypeFilter);
#endif
        if ([H2Records sharedInstance].dataTypeFilter & RECORD_TYPE_BP) { // GET BP
#ifdef DEBUG_FORA
            DLog(@"D40 - BP TYPE");
#endif
            [H2Records sharedInstance].bpTmpRecord = (H2BpRecord *)[[Fora sharedInstance] recordValueParserNEW];
            [H2Records sharedInstance].bpTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
            if ([H2Omron sharedInstance].bpFlag != 'C') {
                [H2SyncReport sharedInstance].serverBpLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime: RECORD_TYPE_BP withUserId:(1 << [H2Records sharedInstance].currentUser)];
                
                if([[H2SyncReport sharedInstance] h2SyncBpDidGreateThanLastDateTime]){
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    [H2Records sharedInstance].recordBpIndex++;
                    [H2Records sharedInstance].bpTmpRecord.bpIndex = [H2Records sharedInstance].recordBpIndex;
#ifdef DEBUG_FORA
                    DLog(@"BP GREAT THAN ... INDEX = %d", [H2Records sharedInstance].recordBpIndex);
#endif
                    [H2Records sharedInstance].currentDataType = RECORD_TYPE_BP;
                    [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bpTmpRecord];
                }else{
                    //NSLog(@"BP GREATE");
                    if (_foraD40BgFinished) {
                        reachOldRecord = YES;
                    //    NSLog(@"BG HAS FINISHED");
                    }
                    _foraD40BpFinished = YES;
                }
            }else{
                //NSLog(@"BP time error");
            }
        }
    }else{ // BG DATA
#ifdef DEBUG_FORA
        DLog(@"D40 - BG DATA (OLD)");
#endif
        if ([H2Records sharedInstance].dataTypeFilter & RECORD_TYPE_BG) { // GET BG
            [H2Records sharedInstance].bgTmpRecord  = (H2BgRecord *)[[Fora sharedInstance] recordValueParserNEW];
#ifdef DEBUG_FORA
            DLog(@"D40 - BG TYPE (OLD)");
            DLog(@"D40 - DATE-TIME %@ ==", [H2Records sharedInstance].bgTmpRecord.bgDateTime);
            DLog(@"D40 - CURRENT USER = %02X", [H2Records sharedInstance].currentUser);
#endif
            [H2Records sharedInstance].bgTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
            if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
            
                [H2SyncReport sharedInstance].serverBgLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime: RECORD_TYPE_BG withUserId:(1 << [H2Records sharedInstance].currentUser)];
                
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    [H2Records sharedInstance].recordBgIndex++;
                    [H2Records sharedInstance].bgTmpRecord.bgIndex = [H2Records sharedInstance].recordBgIndex;
                    
#ifdef DEBUG_FORA
                    DLog(@"BG GREAT THAN ... INDEX = %d", [H2Records sharedInstance].recordBgIndex);
                    DLog(@"BG GREAT THAN ... (OLD) %02X ID", [H2Records sharedInstance].bgTmpRecord.meterUserId);
                    DLog(@"WHAT'S THE OBJ = %@, %02X = ID XXX", [H2Records sharedInstance].bgTmpRecord, [H2Records sharedInstance].bgTmpRecord.meterUserId);
#endif
                    [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
                    [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bgTmpRecord];
                }else{
                    //NSLog(@"BG GREAT");
                    if (_foraD40BpFinished) {
                    //    NSLog(@"BP HAS FINISHED");
                        reachOldRecord = YES;
                    }
                    _foraD40BgFinished = YES;
                }
            }else{
                //NSLog(@"BG time error");
            }
        }
    }
    
#ifdef DEBUG_FORA
    DLog(@"BG OR BP TOTAL NOW = %@", [H2Records sharedInstance].H2RecordsArray);
#endif
    _isBPRecord = NO;
    _isBPAvg = NO;
    _bpArrhyValue = 0;
    
    _foraD40Index++;
    
    if (reachOldRecord  || (_foraD40Index >= [Fora sharedInstance].recordTotal)) {
        if ([self foraD40NextUser]) { // NEXT USER ...
            [Fora sharedInstance].foraCmdNext = FORA_CMD_FORA_CMD_NUMBER_OF_RECORD;
            //FORAD40_NROFRECORD;
#ifdef DEBUG_FORA
            DLog(@"FORA D40 -- ending 1 - GO TO NEXT USER");
#endif
        }else{ // END
            [Fora sharedInstance].foraCmdNext = FORA_CMD_TURN_OFF;
            // FORAD40_TURN_OFF;
#ifdef DEBUG_FORA
            DLog(@"FORA DEBUG -- TURN OFF COMMAND, ALL HAS DONE");
#endif
        }
    }else{
        [Fora sharedInstance].foraCmdNext = FORA_CMD_RECORD_TIME;
        // FORAD40_RECORD_TIME;
#ifdef DEBUG_FORA
        DLog(@"FORA DEBUG -- NOT ending");
#endif
    }

    [self h2ForaD40CmdTask];
}

@end
