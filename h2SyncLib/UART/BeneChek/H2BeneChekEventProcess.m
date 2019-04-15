//
//  H2BeneChekEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//
#import "benechek.h"
#import "H2Config.h"
#import "H2BeneChekEventProcess.h"

#import "h2MeterRecordInfo.h"
#import "H2DataFlow.h"
#import "H2LastDateTime.h"

#import "H2Records.h"

@interface H2BeneChekEventProcess()
{
}



@end

@implementation H2BeneChekEventProcess

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}


+ (H2BeneChekEventProcess *)sharedInstance
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

#pragma mark - DISPATCH BENECHEK METER DATA
- (void)h2BeneChekInfoRecordProcess
{
    
    [self receivedDataProcessBeneChekPlusJet];
    
}

#pragma mark - Data Processing
- (void)receivedDataProcessBeneChekPlusJet
{
    UInt16 tmpNumber = 0;
    
    
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_NROFRECORD:
            memcpy(&tmpNumber, &([H2AudioAndBleSync sharedInstance].dataBuffer[10]), 2);
            [H2AudioAndBleSync sharedInstance].recordTotal = tmpNumber;
            [H2AudioAndBleSync sharedInstance].recordIndex = tmpNumber;
           
            if (tmpNumber==0) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:DEF_LAST_DATE_TIME];

            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            
            break;
            
        case METHOD_RECORD:
            [H2Records sharedInstance].bgTmpRecord = [[benechek sharedInstance] beneChekDateTimeParser:[H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag];
            
            [[H2SyncReport sharedInstance].h2BgRecordReportArray addObject:[H2Records sharedInstance].bgTmpRecord];
            
            
            [H2AudioAndBleSync sharedInstance].recordIndex--;
            if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime] && [H2AudioAndBleSync sharedInstance].recordIndex > 0) {
                [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
                [self h2SyncBeneChekReadRecord];
            }else{
                if (![[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                    [[H2SyncReport sharedInstance].h2BgRecordReportArray removeLastObject];
                }else{
                    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                }
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES; // [self h2SyncDidFinished];
#ifdef DEBUG_LIB
                    DLog(@"show the end");
#endif
            }
            break;
            
        case METHOD_MODEL:
            [H2SyncReport sharedInstance].reportMeterInfo.smModelName = [[benechek sharedInstance] beneChekModelParser];
#ifdef DEBUG_LIB
            if ([[H2SyncReport sharedInstance].reportMeterInfo.smModelName isEqualToString:@"Premium"]) {
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = YES;
            }else{
                [H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag = NO;
            }
            if ([[H2SyncReport sharedInstance].reportMeterInfo.smModelName isEqualToString:@"PlusJet"]){
                    DLog(@"get PlusJet --- ");
            }
            if ([[H2SyncReport sharedInstance].reportMeterInfo.smModelName isEqualToString:@"PT"]){
                    DLog(@"get PT ---- ");
            }
#endif
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_VERSION;
            [self h2SyncBeneChekGeneral];
//            [NSTimer scheduledTimerWithTimeInterval:_beneChekCmdInterval
//                                             target:self selector:@selector(h2SyncBeneChekGeneral)
//                                           userInfo:nil repeats:NO];
            break;
            
        case METHOD_VERSION:
            [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_NROFRECORD;
            [self h2SyncBeneChekGeneral];
//            [NSTimer scheduledTimerWithTimeInterval:_beneChekCmdInterval
//                                             target:self selector:@selector(h2SyncBeneChekGeneral)
//                                           userInfo:nil repeats:NO];
            break;
            
        default:
            break;
    }
}



#pragma mark - BENECHEK READ RECORD COMMAND
- (void)h2SyncBeneChekGeneral
{
    [[benechek sharedInstance] BeneChekCommandGeneral:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}
- (void)h2SyncBeneChekReadRecord
{
    [[benechek sharedInstance] BeneChekQueryGluValue:([H2AudioAndBleSync sharedInstance].recordTotal-[H2AudioAndBleSync sharedInstance].recordIndex)];
}

@end
