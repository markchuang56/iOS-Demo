//
//  MicroLife.m
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/8/17.
//  Copyright © 2018年 h2Sync. All rights reserved.
//


#import "H2Config.h"
#import "h2BrandModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "H2BleService.h"

#import "H2Records.h"
#import "H2BleTimer.h"

#import "H2BleEquipId.h"
#import "H2LastDateTime.h"
#import "H2Config.h"
#import "MicroLife.h"

@interface MicroLife()
{
    Byte *cmdBuffer;
    UInt8 mlCmdSel;
    UInt16 mlCmdLen;
    UInt16 mlCmdTotalLen;
    UInt8 mlCmdSum;
    
    NSMutableData *mlDataBuffer;
    UInt16 mlDataTotalLen;
    UInt16 mlDataReceivedLen;
    UInt16 mlRecordIndex;
    
    UInt8 mlBufferParam;
    UInt8 emailLen;
    NSString *emailSerialNr;
}

@end

@implementation MicroLife

- (id)init
{
    if (self = [super init]) {
        cmdBuffer = (Byte *)malloc(32);
        mlCmdSel = 0;
        mlCmdLen = 0;
        mlCmdSum = 0;
        mlCmdTotalLen = 0;
        
        emailLen = 0;
        emailSerialNr = nil;
        
        mlDataBuffer = [[NSMutableData alloc] init];
        mlDataTotalLen = 0;
        mlDataReceivedLen = 0;
        mlRecordIndex = 0;
        
        _mlF3ServiceID = [CBUUID UUIDWithString:ML_3_SERVICE_UUID];
        _mlF0ServiceID = [CBUUID UUIDWithString:ML_0_SERVICE_UUID];
        
        _mlF4CharacteristicID = [CBUUID UUIDWithString:ML_3_CHAR4_UUID];
        _mlF5CharacteristicID = [CBUUID UUIDWithString:ML_3_CHAR5_UUID];
        _mlF1CharacteristicID = [CBUUID UUIDWithString:ML_0_CHAR1_UUID];
        _mlF2CharacteristicID = [CBUUID UUIDWithString:ML_0_CHAR2_UUID];
        
        // Micro Life A6 BT Service
        _mlF3Service = nil;
        _mlF0Service = nil;
        
        // Micro Life A6 BT Characteristic
        _mlF4Characteristic = nil;
        _mlF5Characteristic = nil;
        _mlF1Characteristic = nil;
        _mlF2Characteristic = nil;
    }
    return self;
}

- (void)mlBufferInit
{
    [mlDataBuffer setLength:0];
    mlDataTotalLen = 0;
    mlDataReceivedLen = 0;
    mlRecordIndex = 0;
}

#pragma mark - ==== A6 BT VALUE UPDATE ====
- (void)microLifeValueUpdate:(CBCharacteristic *)characteristic
{
    //NSLog(@"DATA UPDATE");
    if (![characteristic.UUID isEqual:_mlF1CharacteristicID]){
        return;
    }
    UInt8 receivedLen = characteristic.value.length;
    Byte *tmpBuffer = (Byte *)malloc(20);
    memcpy(tmpBuffer, [characteristic.value bytes], receivedLen);
    mlDataReceivedLen += receivedLen;
    [mlDataBuffer appendBytes:tmpBuffer length:receivedLen];
    if (tmpBuffer[0] == 'M') {
        mlDataTotalLen = tmpBuffer[ML_LOC_IDX];
        mlDataTotalLen <<= 8;
        mlDataTotalLen += tmpBuffer[ML_LOC_IDX+1];
        //NSLog(@"BL DATA LEN = %04X", mlDataTotalLen);
        mlDataTotalLen += 4;
        //NSLog(@"BL DATA TOTAL LEN = %04X", mlDataTotalLen);
    }
    
    if (mlDataTotalLen <= mlDataReceivedLen) {
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        //NSLog(@"BL PARSER");
        switch (mlCmdSel) {
            case ML_CMD_READ_ALL:
                [self mlRecordsTotalParser];
                break;
                
            case ML_CMD_READ_UID:
                [self mlUserIdParser];
                break;
                
            case ML_CMD_WRITE_UID:
                [self mlWriteUserIdParser];
                break;
                
            case ML_CMD_CANCEL_BLE:
                NSLog(@"===== CANCEL BLE (ML) ======");
                break;
                
            case ML_CMD_CLR_ALL:
                //NSLog(@"SYNC END and CLR ALL");
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                break;
                
            default:
                NSLog(@"PARSER FAIL");
                break;
        }
    }
}

#pragma mark - ==== A6 BT PARSER ====
- (void)mlUserIdParser
{
    UInt16 tmpLen = mlDataBuffer.length;
    Byte *userInfo = (Byte *)malloc(128);
    //NSLog(@"USER INFO LEN = %04X", tmpLen);
    //NSLog(@"USER INFO LEN = %@", mlDataBuffer);
    memcpy(userInfo, [mlDataBuffer bytes], tmpLen);
    //NSLog(@"USER NUMBER = %d", userInfo[5]);
    
    UInt8 devUidSrc[ML_UID_LEN+1] = {0};
    memcpy(devUidSrc, &userInfo[6], ML_UID_LEN);
    
    NSString *devUidString;
    devUidString = [NSString stringWithUTF8String:(const char *)devUidSrc];
    
    UInt8 batterySrc = userInfo[27];
    mlBufferParam = userInfo[25];
    //NSLog(@"BL BUFFER SIZE = %d", mlBufferParam);
    
    // Battery Level
    [H2BleService sharedInstance].batteryRawValue = batterySrc;
    if (batterySrc >= 48) {
        [H2BleService sharedInstance].batteryLevel = 10;
    }else{
        [H2BleService sharedInstance].batteryLevel = 3;
    }
    
    //NSLog(@"ML BATTERY LEVEL = %d, %02X", [H2BleService sharedInstance].batteryLevel, [H2BleService sharedInstance].batteryRawValue);
    
    if([H2BleService sharedInstance].blePairingStage){
        if (userInfo[6] != 'H' || userInfo[7] != '2') {
            int num = arc4random();
            int numMode = (num & 0x7FFFFFFF)%1000000000;
            NSString *nrString = [NSString stringWithFormat:@"%09d", numMode];
            userIdSrc[0] = 'H';
            userIdSrc[1] = '2';
            for (int i=0; i<ML_UID_LEN-2; i++) {
                userIdSrc[i+2] = [nrString characterAtIndex:i];;
            }
            emailSerialNr = [NSString stringWithUTF8String:(const char *)userIdSrc];
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [NSString stringWithFormat:@"%@", emailSerialNr];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            
            [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(mlWriteUserId) userInfo:nil repeats:NO];
        }else{
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [NSString stringWithFormat:@"%@", devUidString];
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            //[[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
            [self mlCancleBleFunc];
        }
        return;
    }
    
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [NSString stringWithFormat:@"%@", devUidString];
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;

    
    if ([devUidString isEqualToString:[H2BleService sharedInstance].bleScanningKey]) {
        // GO TO NORMAL SYNC
        [H2Records sharedInstance].bgSkipRecords = NO;
        [H2BleService sharedInstance].bleSerialNumberStage = NO;
        [[H2BleService sharedInstance] bleVendorReportMeterInfo];
    }else{
        // Not Found ...
        [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_NOT_FOUND];
    }
}

- (void)mlWriteUserIdParser
{
    //[[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
    [self mlCancleBleFunc];
}

- (void)mlRecordsTotalParser
{
    [H2SyncReport sharedInstance].serverBpLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime: RECORD_TYPE_BP withUserId:(1 << [H2Records sharedInstance].currentUser)];
    
    UInt8 col = 0;
    UInt16 tmpLen = mlDataBuffer.length;
    
    Byte *records = (Byte *)malloc(ML_RECORDS_MAX * 7 + 64);
    mlBufferParam = 0;
    UInt8 record[8] = {0};
    UInt8 maxIndx = tmpLen/ML_RECORD_LEN;
    
    //NSLog(@"RECORD LEN = %04X", tmpLen);
    //NSLog(@"RECORD DATA = %@", mlDataBuffer);
    memcpy(records, [mlDataBuffer bytes], mlDataBuffer.length);
    for (int i=(4+1); i<tmpLen; i++) {
        if ((i-5) % ML_RECORD_LEN == 0) {
            //NSLog(@"");
            //NSLog(@"======== %d =========", col);
            if (col >= 4 && col < maxIndx) {
                memcpy(record, &records[i], ML_RECORD_LEN);
                [H2Records sharedInstance].bpTmpRecord = [self mlRecordParser:record];
                if ([H2Records sharedInstance].bpTmpRecord != nil) {
                    [self mlAddedNewRecord];
                }
                //NSLog(@"");
            }
            col++;
        }
        //NSLog(@"IDX = %d, VAL = %02X", i-5, records[i]);
    }
#if ML_CLR_ALL
    [self mlClearRecords];
#else
    [self mlCancleBleFunc];
    //[H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#endif
}

- (void)mlAddedNewRecord
{
    if (![[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:[H2Records sharedInstance].bpTmpRecord.bpDateTime]) {
        if ([[H2SyncReport sharedInstance] h2SyncBpDidGreateThanLastDateTime]) {
            //[H2SyncReport sharedInstance].hasSMSingleRecord = YES;
            [H2SyncReport sharedInstance].hasMultiRecords = YES;
            mlRecordIndex++;
#ifdef DEBUG_BP
            DLog(@"ML INDEX = %d, CURRENT USER %d", mlRecordIndex, [H2Records sharedInstance].currentUser);
#endif
            [H2Records sharedInstance].bpTmpRecord.bpIndex = mlRecordIndex;
            [H2Records sharedInstance].bpTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
            [H2Records sharedInstance].currentDataType = RECORD_TYPE_BP;
            [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bpTmpRecord];
            
            //
            [[H2SyncReport sharedInstance].recordsArray addObject:[H2Records sharedInstance].bpTmpRecord];
        }
    }
}

- (H2BpRecord *)mlRecordParser:(Byte *)record
{
    H2BpRecord *tmpRecordInfo = [[H2BpRecord alloc] init];
    
    NSString *dateTime = [[NSString alloc] init];
    UInt8 bpDiastolic = 0;
    UInt16 bpSystolic = 0;
    
    UInt16 bpYear = 0;
    UInt8 bpHeardRate = 0;
    
    UInt8 bpMonth = 0;
    UInt8 bpDay = 0;
    UInt8 bpHour = 0;
    
    UInt8 bpMinute = 0;
    UInt8 bpSecond = 0;
   
    bpSystolic = record[0];
    bpDiastolic = record[1];
    bpHeardRate = record[2];
    
    bpDay = record[3] & 0x3F;
    bpHour = record[4] & 0x3F;
    bpMinute = record[5];
    
    if (bpDay == 0) {
        return nil;
    }
    
    bpYear = record[6] & 0x3F;
    bpYear += 2000;
    
    if (record[6] & 0x80) {
        //NSLog(@"=== MEM ===");
        if (record[6] & 0x40) {
            tmpRecordInfo.mamArrhythmia = YES;
            //NSLog(@"=== MEM ARR ===");
        }
    }else{
        if (record[6] & 0x40) {
            tmpRecordInfo.bpIsArrhythmia = YES;
            //NSLog(@"=== ARR ===");
        }
    }
    
    bpMonth = (record[3] & 0xC0) >> 2;
    bpMonth |= (record[4] & 0xC0);
    bpMonth >>= 4;
    
    dateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", bpYear, bpMonth, bpDay, bpHour, bpMinute, bpSecond];
#ifdef DEBUG_BP
    DLog(@"BP_DATE_TIME %04d-%02d-%02d %02d:%02d:%02d +0000", bpYear, bpMonth, bpDay, bpHour, bpMinute, bpSecond);
    DLog(@"BP  %d / %d mmHg , %d HR", bpSystolic, bpDiastolic, bpHeardRate);
    DLog(@"\n\n");
#endif
    
    tmpRecordInfo.recordType = RECORD_TYPE_BP;
    tmpRecordInfo.bpDateTime = dateTime;
    
    tmpRecordInfo.bpSystolic = [NSString stringWithFormat:@"%d", bpSystolic];
    tmpRecordInfo.bpDiastolic = [NSString stringWithFormat:@"%d", bpDiastolic];
    tmpRecordInfo.bpHeartRate_pulmin = [NSString stringWithFormat:@"%d", bpHeardRate];
    
    return tmpRecordInfo;
}

unsigned char userIdSrc[ML_UID_LEN+1] = {0};
unsigned char userId[] = {
    0x4D, 0xFF, 0x00, 0x0E , 0x06, 0x62, 0x32, 0x30 ,
    0x30, 0x32, 0x20, 0x20 , 0x20, 0x20, 0x20, 0x20 ,
    0x0A, 0x50
    
    // 4d 31 00 02 81 01
    
    //4d 31 00 19  05 01
    //62 32
    //30 30 32 20  20 20 20 20
    //20 00 52 47  31 11 06 09
    //01 63 06 3d  14
    
    //0x4d, 0x31, 0x00, 0x19 , 0x05, 0x01, 0x31, 0x32 ,
    //0x33, 0x34, 0x35, 0x36 , 0x37, 0x38, 0x39, 0x41 ,
    //0x42, 0x14, 0x52, 0x47 , 0x31, 0x11, 0x06, 0x09 ,
    //0x01, 0x63, 0x06, 0x3d , 0xa2
};

#pragma mark - ==== A6 BT COMMAND ====
- (void)mlCmdInit
{
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(mlCmdReadUserId) userInfo:nil repeats:NO];
}

- (void)mlCmdReadUserId
{
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    mlBufferParam = 0;
    
    mlCmdSel = ML_CMD_READ_UID;
    [self mlCmdFlow];
    [[H2BleTimer sharedInstance] h2SetBleTimerTask:ML_SN_INTERVAL taskSel:BLE_TIMER_READ_SN];
}

- (void)mlCmdSync
{
    mlCmdSel = ML_CMD_READ_ALL;
    [self mlCmdFlow];
    [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_CONNECT_INTERVAL+ML_SN_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
}

- (void)mlWriteUserId
{
    mlCmdSel = ML_CMD_WRITE_UID;
    memcpy(&userId[5], userIdSrc, ML_UID_LEN);
    [self mlCmdFlow];
}

- (void)mlCancleBleFunc
{
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(mlCancleBleFuncNext) userInfo:nil repeats:NO];
}

- (void)mlCancleBleFuncNext
{
    mlCmdSel = ML_CMD_CANCEL_BLE;
    [self mlCmdFlow];
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(mlCancleBleFuncNextSecond) userInfo:nil repeats:NO];
}

// NEW ...
- (void)mlCancleBleFuncNextSecond
{
    if ([H2BleService sharedInstance].blePairingStage) {
        [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
    }else{
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
        
        [H2BleService sharedInstance].bleNormalDisconnected = YES;
#ifdef DEBUG_LIB
        DLog(@"FORA - GO TO SYNC ENDING TASK");
#endif
        [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
    }
}

- (void)mlClearRecords
{
    mlCmdSel = ML_CMD_CLR_ALL;
    [self mlCmdFlow];
}

- (void)mlCmdFlow
{
    [self mlBufferInit];
    cmdBuffer[ML_LOC_HEADER] = ML_CMD_HEADER;
    cmdBuffer[ML_LOC_DEV] = ML_CMD_DEV;
    mlCmdLen = 2;
    cmdBuffer[ML_LOC_IDX] = 0;
    mlCmdSum = 0;
    
    Byte  *timeBuffer;
    switch (mlCmdSel) {
        case ML_CMD_READ_ALL:
            mlCmdLen += 6;
            cmdBuffer[ML_LOC_OP] = ML_CMD_READ_ALL;
            timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
            memcpy(&cmdBuffer[ML_LOC_DATA_STRING], timeBuffer, 6);
            
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(mlCmdNext) userInfo:nil repeats:NO];
            break;
            
        case ML_CMD_CLR_ALL:
            cmdBuffer[ML_LOC_OP] = ML_CMD_CLR_ALL;
            break;
            
        case ML_CMD_CANCEL_BLE:
            cmdBuffer[ML_LOC_OP] = ML_CMD_CANCEL_BLE;
            break;
            
        case ML_CMD_READ_UID:
            cmdBuffer[ML_LOC_OP] = ML_CMD_READ_UID;
            break;
            
        case ML_CMD_WRITE_UID:
            mlCmdLen += 12;
            memcpy(cmdBuffer, userId, 16);
            cmdBuffer[ML_LOC_OP] = ML_CMD_WRITE_UID;
            break;
            
        case ML_CMD_READ_LAST:
            cmdBuffer[ML_LOC_OP] = ML_CMD_READ_LAST;
            break;
            
        default:
            break;
    }
    mlCmdTotalLen = mlCmdLen + 4;
    cmdBuffer[ML_LOC_IDX+1] = mlCmdLen;
    for (int i=0; i < (3+mlCmdLen); i++) {
        mlCmdSum += cmdBuffer[i];
    }
    cmdBuffer[3+mlCmdLen] = mlCmdSum;
    
    NSData *dataToWrite = [[NSData alloc]init];
    
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdBuffer length:(3+mlCmdLen+1)];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_mlF2Characteristic type:CBCharacteristicWriteWithResponse];
    //NSLog(@"ML-CMD == %@", dataToWrite);
}

- (void)mlCmdNext
{
    if (mlCmdTotalLen > 20) {
        NSData *dataToWrite = [[NSData alloc]init];
        
        // Write ...
        dataToWrite = [NSData dataWithBytes:&cmdBuffer[20] length:(mlCmdTotalLen-20)];
        
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_mlF2Characteristic type:CBCharacteristicWriteWithResponse];
        //NSLog(@"ML-CMD == %@", dataToWrite);
    }
    
}


+ (MicroLife *)sharedInstance
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
