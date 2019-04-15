//
//  H2FreeStyleEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//
#import "FreeStyleLite.h"
#import "H2Config.h"
#import "H2Report.h"
#import "H2FreeStyleEventProcess.h"

#import "H2DataFlow.h"

#import "H2Records.h"

@interface H2FreeStyleEventProcess()
{
}
@end

@implementation H2FreeStyleEventProcess
- (id)init
{
    if (self = [super init]) {
    }
    return self;
}


+ (H2FreeStyleEventProcess *)sharedInstance
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


- (void)h2FreeStyleInfoRecordProcess
{
    switch ([H2AudioAndBleSync sharedInstance].dataHeader[MODEL_METHOD_AT_0] & 0x0F) {
        case METHOD_INIT:
            [H2SyncReport sharedInstance].reportMeterInfo =  [[FreeStyleLite sharedInstance ] fsLiteSystemInfoParser];
            if ([H2SyncReport sharedInstance].reportMeterInfo.formatError) {
                [H2SyncReport sharedInstance].reportMeterInfo.formatError = NO;
                [H2SyncReport sharedInstance].didSyncFail = YES;
                return;
            }
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
#ifdef DEBUG_LIB
                DLog(@"the freestyle sn is --- %@", [h2MeterModelSerialNumber sharedInstance].smSerialNumber);
#endif
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            break;
            
        case METHOD_RECORD:
            if ([[FreeStyleLite sharedInstance ] fsLiteLogNotFoundParser]) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
                    DLog(@"the free style command end");
#endif
                break;
            }
            if ([H2AudioAndBleSync sharedInstance].dataLength>54) {
                [H2Records sharedInstance].bgTmpRecord = [[FreeStyleLite sharedInstance ] fsLiteDateTimeValueParser:[H2SyncReport sharedInstance].reportMeterInfo.smMmolUnitFlag];
                
                if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime] && [H2AudioAndBleSync sharedInstance].recordIndex < 651) { // freeStyle total record
                    if ([[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"E"]) {
#ifdef DEBUG_LIB
                            DLog(@"control solution test for freeStyle here....");
#endif
                    }else{
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                    }
                    [H2AudioAndBleSync sharedInstance].recordIndex++;
                    [H2AudioAndBleCommand sharedInstance].cmdMethod = METHOD_RECORD;
                    [self h2SyncFreeStyleLiteGeneral];

#ifdef DEBUG_LIB
                        DLog(@" some data yes");
#endif
                    break;
                }else{
#ifdef DEBUG_LIB
                        DLog(@"no data");
#endif
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES; 
                    [H2AudioAndBleSync sharedInstance].recordIndex = 0;
                    break;
                }
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - FREESTYLE LITE COMMAND
- (void)h2SyncFreeStyleLiteGeneral
{
    [[FreeStyleLite sharedInstance ] FreeStyleCommandGeneral:[H2AudioAndBleSync sharedInstance].recordIndex withCommandMethod:[H2AudioAndBleCommand sharedInstance].cmdMethod];
}


@end
