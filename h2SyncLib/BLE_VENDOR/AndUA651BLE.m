//
//  AndUA651BLE.m
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/9/16.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "H2BleTimer.h"
#import "H2BleService.h"
#import "H2BleProfile.h"

#import "H2Records.h"
#import "BWSViewController.h"
#import "AndUA651BLE.h"


#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2Config.h"

#import "OMRON_HEM-7280T.h"
#import "OMRON_HEM-9200T.h"

@implementation AndUA651BLE

- (id)init
{
    if (self = [super init]) {
        
        _UA651_Service_UUID = [CBUUID UUIDWithString:UA651BLE_SERVICE_UUID];
        _UA651_Characteristic_UUID = [CBUUID UUIDWithString:UA651BLE_CHARACTERISTIC_UUID];
        
        _AndUa651_Service = nil;
        _AndUa651_Characteristic = nil;
    }
    return self;
}

- (void)writeBleDateTime
{
    Byte  *timeBuffer;
    timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
    
    UInt16 year = timeBuffer[0];
    UInt8 cmdBuffer[7] = {0};
    NSData *dataToWrite = [[NSData alloc]init];
    
    year += 2000;
    memcpy(cmdBuffer, &year, 2);
    memcpy(&cmdBuffer[2], &timeBuffer[1], 5);
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdBuffer length:7];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:[H2BleProfile sharedBleProfileInstance].bleCharDateTime type:CBCharacteristicWriteWithResponse];
    NSLog(@"A&D WR CT == %@", dataToWrite);
}

- (void)bwsNormalRecordParser:(CBCharacteristic *)characteristic
{
    if([H2BleService sharedInstance].blePairingStage){
#ifdef DEBUG_BP
        DLog(@"PAIRING MODE WITH RECORDS ...");
#endif
        return;
    }
    
    [[OMRON_HEM_9200T sharedInstance] hem9200tClearRecordTimer];
    [H2Records sharedInstance].bwTmpRecord = [[BWSViewController sharedInstance] BWSDidUpdateValueForCharacteristic:characteristic];
    if ([[H2Records sharedInstance].bwTmpRecord.bwDateTime isEqualToString:@""] || [[H2Records sharedInstance].bwTmpRecord.bwDateTime isEqualToString:@"n/a"]){
#ifdef DEBUG_BP
        DLog(@"DATE TIME -- NIL");
#endif
        [[OMRON_HEM_9200T sharedInstance] hem9200tSetRecordTimer];
        return;
    }
    [[H2SyncReport sharedInstance] h2SyncBwDidGreateThanLastDateTime];
    
    [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
    [H2Omron sharedInstance].reportIndex++;
    
    [H2Records sharedInstance].bwTmpRecord.bwIndex = [H2Omron sharedInstance].reportIndex;
#ifdef DEBUG_BP
    DLog(@"NORMAL BWS INDEX = %d, CURRENT USER %d", [H2Omron sharedInstance].reportIndex, [H2Records sharedInstance].currentUser);
#endif
    [H2Records sharedInstance].bwTmpRecord.bwIndex = [H2Omron sharedInstance].reportIndex;
    [H2Records sharedInstance].bwTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
    [H2Records sharedInstance].currentDataType = RECORD_TYPE_BW;
#ifdef DEBUG_BP
    DLog(@"NORMAL BWS %@", [H2Records sharedInstance].bwTmpRecord);
#endif
    [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bwTmpRecord];
#ifdef DEBUG_BP
    DLog(@"RE-START SYNC TIMER FOR 352");
#endif
    [[OMRON_HEM_9200T sharedInstance] hem9200tSetRecordTimer];
}


+ (AndUA651BLE *)sharedInstance
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
