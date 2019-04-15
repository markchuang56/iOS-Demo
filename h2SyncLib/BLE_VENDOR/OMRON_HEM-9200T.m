//
//  OMRON_HEM-9200T.m
//  h2LibAPX
//
//  Created by h2Sync on 2017/4/26.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2AudioFacade.h"

#import "H2Config.h"

#import "H2BleOad.h"
#import "H2BgmCable.h"

#import "OMRON_HEM-7280T.h"
#import "OMRON_HBF-254C.h"
#import "H2AudioHelper.h"

#import "OMRON_HEM-9200T.h"
#import "H2Sync.h"
#import "H2Records.h"
#import "BPMViewController.h"

@implementation OMRON_HEM_9200T

- (id)init
{
    if (self = [super init]) {
        
        _hem9200tCurrentTimer = [[NSTimer alloc] init];
        _hem9200tCurrentTimer = nil;
        
        _hem9200tSyncTimer = [[NSTimer alloc] init];
        _hem9200tSyncTimer = nil;
        
        _hem9200TRecordTimeOut = NO;
        _hem9200tSyncModeHasRecord = NO;
        
        _hem9200tSerialNumberDone = NO;
        _hem9200tCurrentTimeDone = NO;
    }
    return self;
}



- (void)hem9200TRecordParser:(CBCharacteristic *)characteristic;
{
    if([H2BleService sharedInstance].blePairingStage){
#ifdef DEBUG_BP
        DLog(@"PAIRING MODE WITH RECORDS ...");
#endif
        return;
    }
#ifdef DEBUG_BP
    DLog(@"PARSER 9200T ...");
#endif
    [self hem9200tClearRecordTimer];
    [H2Records sharedInstance].bpTmpRecord = [[BPMViewController sharedBpInstance] BPMDidUpdateValueForCharacteristic:characteristic];
    if ([[H2Records sharedInstance].bpTmpRecord.bpDateTime isEqualToString:@""] || [[H2Records sharedInstance].bpTmpRecord.bpDateTime isEqualToString:@"n/a"]){// == nil ) {
#ifdef DEBUG_BP
        DLog(@"DATE TIME -- NIL");
#endif
        [self hem9200tSetRecordTimer];
        return;
    }
    [[H2SyncReport sharedInstance] h2SyncBpDidGreateThanLastDateTime];
    
    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
    [H2Omron sharedInstance].reportIndex++;
    
    [H2Records sharedInstance].bpTmpRecord.bpIndex = [H2Omron sharedInstance].reportIndex;
#ifdef DEBUG_BP
    DLog(@"BP INDEX = %d, CURRENT USER %d", [H2Omron sharedInstance].reportIndex, [H2Records sharedInstance].currentUser);
#endif
    [H2Records sharedInstance].bpTmpRecord.bpIndex = [H2Omron sharedInstance].reportIndex;
    [H2Records sharedInstance].bpTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
    [H2Records sharedInstance].currentDataType = RECORD_TYPE_BP;
#ifdef DEBUG_BP
    DLog(@"TEMP RECORD FOR 9200T %@", [H2Records sharedInstance].bpTmpRecord);
#endif
    [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bpTmpRecord];
#ifdef DEBUG_BP
    DLog(@"RE-START SYNC TIMER FOR 9200T");
#endif
    [self hem9200tSetRecordTimer];
}

#pragma mark - CURRENT TIME TIMER
- (void)hem9200tSetCurrentTimer
{
    _hem9200tCurrentTimer = [NSTimer scheduledTimerWithTimeInterval:HEM_9200T_CURRENT_TIME_INTERVAL target:self selector:@selector(hem9200tCurrentTimerTask) userInfo:nil repeats:NO];
#ifdef DEBUG_BP
    DLog(@"SET UP CT TIMER %f", HEM_9200T_CURRENT_TIME_INTERVAL);
#endif
}

- (void)hem9200tClearCurrentTimer
{
    if (_hem9200tCurrentTimer != nil) {
        [_hem9200tCurrentTimer invalidate];
        _hem9200tCurrentTimer = nil;
    }
#ifdef DEBUG_BP
    DLog(@"CLR CT TIMER");
#endif
}

- (void)hem9200tCurrentTimerTask
{
    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_PAIR_TIMEOUT];
#ifdef DEBUG_BP
    DLog(@"9200T CT TIME OUT");
#endif
}


#pragma mark - RECORD TIMER

- (void)hem9200tSetRecordTimer
{
    _hem9200tSyncTimer = [NSTimer scheduledTimerWithTimeInterval:HEM_9200T_RECORD_INTERVAL target:self selector:@selector(hem9200tRecordTimerTask) userInfo:nil repeats:NO];
#ifdef DEBUG_BP
    DLog(@"SET UP RECORD TIMER");
#endif
}

- (void)hem9200tClearRecordTimer
{
    _hem9200TRecordTimeOut = YES;
    if (_hem9200tSyncTimer != nil) {
        [_hem9200tSyncTimer invalidate];
        _hem9200tSyncTimer = nil;
    }
#ifdef DEBUG_BP
    DLog(@"CLR RECORD TIMER");
#endif
}

- (void)hem9200tRecordTimerTask
{
    _hem9200TRecordTimeOut = YES;
    [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
#ifdef DEBUG_BP
    DLog(@"9200T RECORD RECORD TIME OUT");
#endif
}





+ (OMRON_HEM_9200T *)sharedInstance
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

@end


#if 0
- (void)BPMDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        // Decode the characteristic data
        NSData *data = characteristic.value;
        uint8_t *array = (uint8_t*) data.bytes;
        
        UInt8 flags = [CharacteristicReader readUInt8Value:&array];
        BOOL kPa = (flags & 0x01) > 0;
        BOOL timestampPresent = (flags & 0x02) > 0;
        BOOL pulseRatePresent = (flags & 0x04) > 0;
#ifdef DEBUG_BP
        DLog(@"DID COME TO (OMRON_HEM_9200T)BPM - PARSER ...");
#endif
        
        // Update units
        if (kPa)
        {
            _systolicUnit = BP_UNIT_KPA;
            _diastolicUnit = BP_UNIT_KPA;
            _meanApUnit = BP_UNIT_KPA;
        }else{
            _systolicUnit = BP_UNIT;
            _diastolicUnit = BP_UNIT;
            _meanApUnit = BP_UNIT;
        }
        
        // Read main values
        //if(1){
        //if ([characteristic.UUID isEqual:bpmBloodPressureMeasurementCharacteristicUUID])
        {
            float systolicValue = [CharacteristicReader readSFloatValue:&array];
            float diastolicValue = [CharacteristicReader readSFloatValue:&array];
            float meanApValue = [CharacteristicReader readSFloatValue:&array];
            
            _systolic = [NSString stringWithFormat:@"%.1f", systolicValue];
            _diastolic = [NSString stringWithFormat:@"%.1f", diastolicValue];
            _meanAp = [NSString stringWithFormat:@"%.1f", meanApValue];
            
            //self.systolicUnit.hidden = NO;
            //self.diastolicUnit.hidden = NO;
            //self.meanApUnit.hidden = NO;
        }
        
        // Read timestamp
        if (timestampPresent)
        {
            NSDate* date = [CharacteristicReader readDateTime:&array];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd.MM.yyyy, hh:mm"];
            NSString* dateFormattedString = [dateFormat stringFromDate:date];
            
            _timestamp = dateFormattedString;
        }else{
            _timestamp = @"n/a";
        }
        
        // Read pulse
        if (pulseRatePresent)
        {
            float pulseValue = [CharacteristicReader readSFloatValue:&array];
            _pulse = [NSString stringWithFormat:@"%.1f", pulseValue];
        }else{
            _pulse = @"-";
        }
        
#ifdef DEBUG_BP
        DLog(@"BPM SYS - %@ %@", _systolic, _systolicUnit);
        DLog(@"BPM DIA - %@ %@", _diastolic, _diastolicUnit);
        DLog(@"BPM MEAN - %@ %@", _meanAp, _meanApUnit);
        DLog(@"BPM TIME - %@ ", _timestamp);
        DLog(@"BPM PULSE - %@", _pulse);
#endif
    });
}

#endif






