//
//  Gm700sb.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/10/20.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2Config.h"
#import "h2BrandModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "H2BleService.h"
#import "Gm700sb.h"

#import "H2Records.h"
#import "H2BleTimer.h"

#import "H2BleEquipId.h"
#import "H2LastDateTime.h"
#import "H2Config.h"

@implementation Gm700sb


- (id)init
{
    if (self = [super init]) {
        
#pragma mark - BIONIME GM700SB Object
        // UUID
        
        _bioNimeServiceID = [CBUUID UUIDWithString:BLE_BIONIME_SERVICE_ID];
        
        _bioNimeCharacteristicReadWriteID = [CBUUID UUIDWithString:BLE_BIONIME_READ_WRITE_ID];
        _bioNimeCharacteristicNotifyID = [CBUUID UUIDWithString:BLE_BIONIME_NOTIFY_ID];
        _bioNimeCharacteristicWriteID = [CBUUID UUIDWithString:BLE_BIONIME_WRITE_ID];
        
        _sbSn = @"";
        // BioNeme GM700SB Service
        _bioNimeService = nil;
        
        // BioNeme GM700SB Characteristic
        _bioNimeCharacteristicReadWrite = nil;
        _bioNimeCharacteristicNotify = nil;
        _bioNimeCharacteristicWrite = nil;
        
        //_userKey = 0x0101;
        _userKey = SB_PAIR_KEY_BEGIN;//0x9ABE;
        
        _rawForKey0 = 0;
        _rawForKey1 = 0;
        _reportLength = 0;
        _timerWriting = NO;
        _mmolFlag = NO;
        
        _readingSel = 0;
        //_currentCmdSel = METHOD_INIT;
        
        _sbYear = 0;
        _sbMonth = 0;
        _sbDay = 0;
        _sbHour = 0;
        _sbMinute = 0;
        
        _userKey -= SB_PAIR_OFFSET;
    }
    return self;
}

#pragma mark - PAIRING COMMAND (BUFFER)
unsigned char bioSbPairingCommand[9] = {0};

#pragma mark - GM700SB DATA PROCESS
- (void)bioNimeGb700sbDataProcess:(CBCharacteristic *)characteristic
{
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    
    NSLog(@"SB VALUE %@", characteristic);
    
    if ([characteristic.UUID isEqual:_bioNimeCharacteristicReadWriteID]){
        NSLog(@"CH 0 COMING ...");
        [self bioNimeGb700sbCh1:characteristic];
    }
    
    if([characteristic.UUID isEqual:_bioNimeCharacteristicNotifyID]){
        [self bioNimeGb700sbCh2:characteristic];
    }
    return;
    
}

#pragma mark - GM700SB A1 ROUTING
- (void)bioNimeGb700sbCh1:(CBCharacteristic *)characteristic
{
    UInt8 bmp[32] = {0xFF};
    UInt8 len = [H2BleEquipId sharedEquipInstance].bleEquipBuffer.length;
    memcpy(bmp, [[H2BleEquipId sharedEquipInstance].bleEquipBuffer bytes], len);
    for (int i=0; i<len; i++) {
        NSLog(@"CH0 %d, %02X", i, bmp[i]);
    }
    if (bmp[0] == 0) {
        [NSTimer scheduledTimerWithTimeInterval:SB_FLOW_INIT_INTERVAL target:self selector:@selector(bioNimeGb700sbA3CmdFlowInit) userInfo:nil repeats:NO];
    }else{
        // TO DO ...
        // ERROR PROCESS ...
    }
    NSLog(@"SB What Happen!! Len = %d, VAL = %02X", len, bmp[0]);
}
#pragma mark - GM700SB A2 ROUTING
- (void)bioNimeGb700sbCh2:(CBCharacteristic *)characteristic
{
    UInt8 sbOffset = 4;
    UInt8 sbCmdID = 0;
    UInt8 sbSum = 0;
    UInt8 bmp[32] = {0};
    UInt8 pairKey0 = 0;
    UInt8 pairKey1 = 0;
    UInt8 len = [H2BleEquipId sharedEquipInstance].bleEquipBuffer.length;
    memcpy(bmp, [[H2BleEquipId sharedEquipInstance].bleEquipBuffer bytes], len);
    for (int i=0; i<len; i++) {
        NSLog(@"CH1 %d, %02X", i, bmp[i]);
    }
    
    if (bmp[0] == 0x0B) {
        return;
    }
    sbCmdID = bmp[3];
    
    switch (sbCmdID) {
        case (SB_FLOW0_INIT ^ 0xFF):
            //_userKey -= SB_PAIR_OFFSET;
            //_userKey = 0;
            pairKey0 = (UInt8)(_userKey & 0xFF);
            pairKey1 = (UInt8)((_userKey & 0xFF00)>>8);
            
            
            bioSbPairingCommand[0] = 0xB0;
            bioSbPairingCommand[1] = SB_FLOW1_PAIR;
            //bioSbPairingCommand[2] = bmp[sbOffset+1] ^ SB_PAIR_KEY0;
            //bioSbPairingCommand[3] = bmp[sbOffset+4] ^ SB_PAIR_KEY1;
            bioSbPairingCommand[2] = bmp[sbOffset+1] ^ pairKey0;
            bioSbPairingCommand[3] = bmp[sbOffset+4] ^ pairKey1;
            _rawForKey0 = bmp[sbOffset+1];
            _rawForKey1 = bmp[sbOffset+4];
            
            bioSbPairingCommand[4] = bmp[sbOffset+5];
            bioSbPairingCommand[5] = bmp[sbOffset+9];
            bioSbPairingCommand[6] = bmp[sbOffset+11];
            bioSbPairingCommand[7] = bmp[sbOffset+14];
            bioSbPairingCommand[8] = 0;
            for (int i=0; i<8; i++) {
                sbSum += bioSbPairingCommand[i];
            }
            bioSbPairingCommand[8] = sbSum;
            
            [NSTimer scheduledTimerWithTimeInterval:SB_FLOW_PAIR_INTERVAL target:self selector:@selector(bioNimeGb700sbA3CmdPair) userInfo:nil repeats:NO];
            
            NSLog(@"0x30 FLOW, %04X", _userKey);
            //_userKey++;
            break;
            
        case (SB_FLOW1_PAIR ^ 0xFF):
            NSLog(@"0x31 FLOW");
            if (bmp[4] == 1) {
                _timerWriting = NO;
                _currentCmdSel = METHOD_MODEL;
                
//                [H2BleService sharedInstance].bleNormalDisconnected = YES;
                [self bioNimeGb700sbCmmand];
                NSLog(@"SB HAS PAIRED");
            }
            break;
            
        case (BIONIME_CID_MODEL ^ 0xFF):
            [self bioNimeModel];
            _currentCmdSel = METHOD_VERSION;
            [self bioNimeGb700sbCmmand];
            NSLog(@"SB HAS MODEL");
            break;
            
        case (BIONIME_CID_FWVER ^ 0xFF):
            [self bioNimeFirmwareVersion];
            _currentCmdSel = METHOD_INIT;
            [self bioNimeGb700sbCmmand];
            NSLog(@"SB HAS FW VERSION");
            break;
            
        case (BIONIME_CID_ENMEM ^ 0xFF):
            //_currentCmdSel = METHOD_SN;
            _currentCmdSel = METHOD_UNIT; // Read Current Time
            NSLog(@"SB HAS MEM ENABLE");
            
            //_currentCmdSel = METHOD_NROFRECORD;
            //_currentCmdSel = METHOD_RECORD;
            [self bioNimeGb700sbCmmand];
            break;
            
        case (BIONIME_CID_GS_DATE_TIME_UNIT ^ 0xFF):
            
            //NSLog(@"SB HAS SN, SN, SN");
            if (_timerWriting) {
                _timerWriting = NO;
                //[self bioNimeGb700sbA3CmdFlow:SB_FLOW2_BF2]; // Before Records
                _currentCmdSel = METHOD_SN;
                [self bioNimeGb700sbCmmand];
            }else{
                [self bioNimeDateTimeAndUnit];
                //_currentCmdSel = METHOD_TIME; // Write Current Time
                _currentCmdSel = METHOD_SN;
                [self bioNimeGb700sbCmmand];
            }
            break;
            
        case (SB_FLOW2_BF2 ^ 0xFF):
            [self bioNimeGb700sbA3CmdFlow:SB_FLOW3_BF3];
            break;
            
        case (SB_FLOW3_BF3 ^ 0xFF):
            [self bioNimeGb700sbA3CmdFlow:SB_FLOW4_BF4];
            
            NSLog(@"SB HAS WHAT ...");
            break;
            
        case (SB_FLOW4_BF4 ^ 0xFF):
            NSLog(@"SB HAS WHAT ... 0x34");
            break;
            
        case (BIONIME_CID_SN ^ 0xFF):
            _sbSn = [self bioNimeSerialNumber];
            
            if (_sbSn == nil) {
                // FAIL
                return;
            }
            
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = _sbSn;
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = _sbSn;
#ifdef DEBUG_FORA
            DLog(@"FORA SN APPENDING ... %@", _sbSn);
#endif
            if ([H2BleService sharedInstance].blePairingStage) {
                [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
                return;
            }else{
                if ([H2BleService sharedInstance].isBleEquipment) {
#ifdef DEBUG_FORA
                    DLog(@"FORA SERIAL NUMBER DEVICE ... %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
                    DLog(@"FORA SERIAL NUMBER SERVER ... %@", [H2BleService sharedInstance].bleScanningKey);
#endif
                    
                    if ([[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber isEqualToString:[H2BleService sharedInstance].bleScanningKey]) { // GO TO NORMAL SYNC
                        [H2BleService sharedInstance].bleSerialNumberStage = NO;
                        [H2SyncReport sharedInstance].didSendEquipInformation = YES;
                    }else{
                        [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_NOT_FOUND];
                        return;
                    }
                }
            }
            
            //_currentCmdSel = METHOD_NROFRECORD;
            //[self bioNimeGb700sbCmmand];
            NSLog(@"SB HAS SN, SN, SN");
            break;
            
        case (BIONIME_CID_RECORD ^ 0xFF):
            if (_currentCmdSel == METHOD_NROFRECORD) {
                [H2AudioAndBleSync sharedInstance].recordTotal = [self bioNimeTotalAmount];
                
                [H2AudioAndBleSync sharedInstance].recordIndex = [H2AudioAndBleSync sharedInstance].recordTotal;
                if ([H2AudioAndBleSync sharedInstance].recordTotal > 0) {
                    _currentCmdSel = METHOD_RECORD;
                    [self bioNimeGb700sbCmmand];
                }else{
                    // Finished
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    //[H2BleService sharedInstance].bleNormalDisconnected = YES;
                }
                
                
                
            }else{
                [H2Records sharedInstance].bgTmpRecord  = [self bioNimeDateTimeValueParser];
                
                if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                    [H2Records sharedInstance].bgTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
                    NSLog(@"NORMALE RECORD ... %@", [H2Records sharedInstance].bgTmpRecord);
                    [H2SyncReport sharedInstance].serverBgLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime: RECORD_TYPE_BG withUserId:(1 << [H2Records sharedInstance].currentUser)];
                    
                    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                        [H2Records sharedInstance].recordBgIndex++;
                        [H2Records sharedInstance].bgTmpRecord.bgIndex = [H2Records sharedInstance].recordBgIndex;
                        
                        [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
                        [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bgTmpRecord];
                    }else{
                        NSLog(@"ENDING ...1 with ");
                       // _btmRecordRunning = NO;
                       // cmdLen = BTM_CMD_LENGTH;
                       // cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_METER_OFF; // Command ID
                        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                        return;
                    }
                }
                
                
                
                if ([H2AudioAndBleSync sharedInstance].recordIndex > 0) {
            
                    _currentCmdSel = METHOD_RECORD;
                    [self bioNimeGb700sbCmmand];
                    NSLog(@"CONTINUED ...2");
                }else{
                    // Finished
                    NSLog(@"ENDING ...2");
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    return;
                }
                
            }
            NSLog(@"SB HAS RECORD of RECORD INFO");
            
            // value = <01014ff8 00000000 f4010000 3c>,
            break;
            
        default:
            break;
    }
}




#pragma mark - PARSER == MODEL ==
- (NSString *)bioNimeModel
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    unsigned char srcTmp[32] = {0};
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 tmpSum = 0;
    for (int i=DA_ST; i<length-1; i++) {
        tmpSum += srcData[i];
        NSLog(@"INDEX = %d, %02X, %02X", i, srcData[i], tmpSum);
    }
    
    NSLog(@"SB_ SUM_X = %02X, SUM = %02X", tmpSum & 0xFF, srcData[length-1]);
    if (tmpSum != (~srcData[_reportLength])) {
        //return nil;
    }
    
    memcpy(srcTmp, &srcData[DA_0], DATA_LEN_MODEL);
    
    NSString *string = [NSString stringWithUTF8String:(const char *)srcTmp];
    NSLog(@"SB_PR (MODEL) = %@, SUM = %02X",string, tmpSum);
    return string;
}

#pragma mark - PARSER == FIRMWAR VERSION ==
- (NSString *)bioNimeFirmwareVersion
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    unsigned char srcTmp[32] = {0};
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 tmpSum = 0;
    for (int i=DA_ST; i<length-1; i++) {
        tmpSum += srcData[i];
        NSLog(@"INDEX = %d, %02X, %02X", i, srcData[i], tmpSum);
    }
    NSLog(@"SB_ SUM_X = %02X, SUM = %02X", tmpSum & 0xFF, srcData[length-1]);
    if (tmpSum != (~srcData[_reportLength])) {
        //return nil;
    }
    
    memcpy(srcTmp, &srcData[DA_0], DATA_LEN_FWVER);
    
    NSString *string = [NSString stringWithUTF8String:(const char *)srcTmp];
    NSLog(@"SB_PR (FW) = %@, SUM = %02X", string, tmpSum);
    return string;
}

#pragma mark - PARSER == SERIAL NUMBER ==
- (NSString *)bioNimeSerialNumber
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    unsigned char srcTmp[32] = {0};
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 snLen = srcData[DA_0];
    

    // SN CheckSum
    UInt16 tmpSum = 0;
    for (int i=0; i<snLen; i++) {
        tmpSum += srcData[DA_0+1+i];
    }
    NSLog(@"SB_ SUM_X = %02X, SUM = %02X", tmpSum & 0xFF, srcData[length-2]);
    NSLog(@"SN SUM = %02X", tmpSum);
    if (tmpSum != (~srcData[2+1+snLen])) {
        //return nil;
    }
    // Total CheckSum
    tmpSum = 0;
    for (int i=DA_ST; i<length-1; i++) {
        tmpSum += srcData[i];
    }
    NSLog(@"SB_ SUM_X = %02X, SUM = %02X", tmpSum & 0xFF, srcData[length-1]);
    NSLog(@"SN SUM (TOTAL) = %02X", tmpSum);
    if (tmpSum != (~srcData[2+1+snLen+1])) {
        //return nil;
    }

    //memcpy(srcTmp, &srcData[DA_0], snLen);DATA_LEN_SN
    memcpy(srcTmp, &srcData[DA_0+1], DATA_LEN_SN);
    NSString *string = [NSString stringWithUTF8String:(const char *)srcTmp];
    NSLog(@"SB_PR (SN) = %@", string);
    return string;
}

#pragma mark - PARSER == CURRENT TIME, UNIT ==
- (NSString *)bioNimeDateTimeAndUnit
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    UInt16 tmpSum = 0;
    for (int i=DA_ST; i<length-1; i++) {
        tmpSum += srcData[i];
    }
    
    NSLog(@"SB_ SUM_X = %02X, SUM = %02X", tmpSum & 0xFF, srcData[length-1]);
    if (tmpSum != (~srcData[_reportLength])) {
        //return nil;
    }
    
    UInt16 year = srcData[DA_1];
    year += 2000;
    UInt8 month = srcData[DA_2];
    month++;
    UInt8 day = srcData[DA_3];
    day++;
    
    UInt8 hour = srcData[DA_4];
    UInt8 minute = srcData[DA_5];
    
    NSString *stringUnit=@"";
    _mmolFlag = NO; // mg/dL
    if (srcData[DA_0] & 0x02) {
        _mmolFlag = YES; // mmol/L
        stringUnit = @"mmol";
    }else{
        stringUnit = @"mgdL";
    }
    
    
    NSString *currentTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", year, month, day, hour, minute];
    NSLog(@"SB_PR (UNIT) = %@, SUM = %02X", stringUnit, tmpSum);
    NSLog(@"SB_PR (CT) = %@", currentTime);
    return currentTime;
}


#pragma mark - PARSER == AMOUNT ==
- (UInt16) bioNimeTotalAmount
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 tmpSum = 0;
    for (int i=DA_ST; i<length-1; i++) {
        tmpSum += srcData[i];
    }
    NSLog(@"SB_ SUM_X = %02X, SUM = %02X", tmpSum & 0xFF, srcData[length-1]);
    
    UInt16 rdIndex = (srcData[DA_1] << 8 ) + srcData[DA_0];
    UInt16 rdTotal = (srcData[DA_3] << 8 ) + srcData[DA_2];
    UInt16 rdMaximun = (srcData[DA_5] << 8 ) + srcData[DA_4];
    UInt16 rdLastTransfer = (srcData[DA_7] << 8 ) + srcData[DA_6];
    
    NSLog(@"SB_PR (INDEX) = %d, SUM = %02X", rdIndex, tmpSum);
    NSLog(@"SB_PR (TOTAL) = %d", rdTotal);
    NSLog(@"SB_PR (MAX) = %d", rdMaximun);
    NSLog(@"SB_PR (LAST) = %d", rdLastTransfer);
    
    _recordIndex = rdTotal;
    return rdTotal;
}

#pragma mark - PARSER == RECORD ==
- (H2BgRecord *)bioNimeDateTimeValueParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 tmpSum = 0;
    for (int i=DA_ST; i<length-1; i++) {
        tmpSum += srcData[i];
    }
    //01 01 4f f8 01 00 52 4b ad 12 08 71 1d
    //01014ff8 0100524b ad120871 1d
    NSLog(@"SUM FOR RD = %02X", tmpSum & 0xFF);
    NSLog(@"SB_ SUM_X = %02X, SUM = %02X", tmpSum & 0xFF, srcData[length-1]);
    
    UInt8 month = ((srcData[DA_ST+DA_1] & 0xC0) >> 4) + ((srcData[DA_ST+DA_0] & 0xC0) >> 6);
    month++;
    UInt8 day = srcData[DA_ST+DA_0] & 0x1F;
    day++;
    
    UInt8 hour = srcData[DA_ST+DA_1] & 0x1F;
    UInt8 minute = srcData[DA_ST+DA_2] & 0x3F;
    
    UInt16 year = srcData[DA_ST+DA_3] & 0x7F;
    year += 2000;
    
    NSLog(@"MON = %d", month);
    NSLog(@"DAY = %d", day);
    NSLog(@"YEAR = %d", year);
    
    NSLog(@"HOUR = %d", hour);
    NSLog(@"MIN = %d", minute);
    
    UInt16 glucoseValue = 0;
    //Hi Flag
    //1: Record was marked as “Hi”( Over 600 mg/dL)
    if (srcData[DA_3] & 0x80) {
        glucoseValue = 600;
    }else{
        glucoseValue = ((srcData[DA_ST+DA_4] & 0x03) << 8) + srcData[DA_ST+DA_5];
    }
    
    NSLog(@"VALUE = %d", glucoseValue);
    H2BgRecord *bioNimeRecord;
    bioNimeRecord = [[H2BgRecord alloc] init];
    
    //bioNimeRecord.smRecordValue_mg = 0;
    
    
    bioNimeRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", year, month, day, hour, minute];
    
    // Control Solution
    if (srcData[DA_ST+DA_4] & 0x04) {
        bioNimeRecord.bgMealFlag = @"C";
    }else{ // Normal
        // Meal Flag
        if (srcData[DA_ST+DA_4] & 0x08) {// Meal Flag
            if (srcData[DA_ST+DA_4] & 0x20) {// Meal Flag
                // After
                bioNimeRecord.bgMealFlag = @"A";
            }else{
                // Before
                bioNimeRecord.bgMealFlag = @"B";
            }
            
        }else{ // AVG or Non
            
        }
    }
    
    NSLog(@"BG STATUS = %@", bioNimeRecord.bgMealFlag);
#ifdef DEBUG_AVIVA
    DLog(bioNimeRecord.bgDateTime, nil);
#endif
   
    if (_mmolFlag) {
        //bioNimeRecord.smRecordValue_mmol = (float)glucoseValue/MMOL_COIF;
        bioNimeRecord.bgValue = [NSString stringWithFormat:@"%.02f", (float)glucoseValue/MMOL_COIF];
        bioNimeRecord.bgUnit = BG_UNIT_EX;
    }else{
        //bioNimeRecord.smRecordValue_mg = glucoseValue;
        bioNimeRecord.bgValue = [NSString stringWithFormat:@"%d", glucoseValue];
        bioNimeRecord.bgUnit = BG_UNIT;
    }
    if (![bioNimeRecord.bgMealFlag isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bioNimeRecord.bgDateTime]) {
            bioNimeRecord.bgMealFlag = @"C";
        }
    }
    NSLog(@"SB-BG VAL = %@", bioNimeRecord.bgValue);
    return bioNimeRecord;
}



#pragma mark - GM700SB Command

- (void)bioNimeGb700sbA1ModeChange
{
    unsigned char cmdTemp[1] = {0};
    // FEE1
    cmdTemp[0] = 0;
    NSData *dataToWrite = [[NSData alloc]init];
    
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdTemp length:1];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_bioNimeCharacteristicReadWrite type:CBCharacteristicWriteWithResponse];
    
    [NSTimer scheduledTimerWithTimeInterval:SB_READ_MODE_INTERVAL target:self selector:@selector(bioNimeGb700sbA1ModeInfo) userInfo:nil repeats:NO];
    //_readingSel = READ_A1;
    //[self bioNimeGb700sbA2Flow];
}

- (void)bioNimeGb700sbA1ModeInfo
{
    [[H2BleService sharedInstance].h2ConnectedPeripheral readValueForCharacteristic:_bioNimeCharacteristicReadWrite];
}


#pragma mark - GM700SB CMD FLOW
- (void)bioNimeGb700sbA3CmdFlowInit
{
    [self bioNimeGb700sbA3CmdFlow:SB_FLOW0_INIT];
}
- (void)bioNimeGb700sbA3CmdFlow:(UInt8)flowSel
{
    UInt8 sumTmp = 0;
    unsigned char cmdTemp[] = {BIONIME_HOC, 0x30, 0xE0};
    cmdTemp[1] = flowSel;
    sumTmp = cmdTemp[0] + cmdTemp[1];
    cmdTemp[2] = sumTmp;
    
    NSData *dataToWrite = [[NSData alloc]init];
    
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdTemp length:sizeof(cmdTemp)];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_bioNimeCharacteristicWrite type:CBCharacteristicWriteWithResponse];
    NSLog(@"SB INIT CMD = %@", dataToWrite);
}

- (void)bioNimeGb700sbA3CmdPair
{
    NSData *dataToWrite = [[NSData alloc]init];
    // Write ...
    dataToWrite = [NSData dataWithBytes:bioSbPairingCommand length:sizeof(bioSbPairingCommand)];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_bioNimeCharacteristicWrite type:CBCharacteristicWriteWithResponse];
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(sbNofityAgain) userInfo:nil repeats:NO];
    NSLog(@"SB PAIR CMD = %@", dataToWrite);
    //unsigned char cmdTemp[] = {0xB0, 0x31,
    //0x19, 0xEE, 0x83, 0x5F, 0x2D, 0xDA, 0xD1};
    //    0xAA, 0x3A, 0x44, 0x51, 0xC0, 0x5C, 0x76};
 //   [NSTimer scheduledTimerWithTimeInterval:SB_FLOW_PAIR_LOOP target:self selector:@selector(bioNimePairingCmdLoop) userInfo:nil repeats:NO];
}


- (void)bioNimePairingCmdLoop{
    
    UInt8 pairKey0 = 0;
    UInt8 pairKey1 = 0;
    UInt8 sbSum = 0;
    
    _userKey++;
    pairKey0 = (UInt8)(_userKey & 0xFF);
    pairKey1 = (UInt8)((_userKey & 0xFF00)>>8);
    
    bioSbPairingCommand[2] = _rawForKey0 ^ pairKey0;
    bioSbPairingCommand[3] = _rawForKey1 ^ pairKey1;
    
    //bioSbPairingCommand[4] = bmp[sbOffset+5];
    //bioSbPairingCommand[5] = bmp[sbOffset+9];
    //bioSbPairingCommand[6] = bmp[sbOffset+11];
    //bioSbPairingCommand[7] = bmp[sbOffset+14];
    bioSbPairingCommand[8] = 0;
    for (int i=0; i<8; i++) {
        sbSum += bioSbPairingCommand[i];
    }
    bioSbPairingCommand[8] = sbSum;
    
    [self bioNimeGb700sbA3CmdPair];
    //[NSTimer scheduledTimerWithTimeInterval:SB_FLOW_PAIR_INTERVAL target:self selector:@selector(bioNimeGb700sbA3CmdPair) userInfo:nil repeats:NO];
}

#pragma mark - GM700SB COMMAND NORMAL
- (void)bioNimeGb700sbCmmand
{
    UInt8 cmdLength = 0;
    UInt16 checkSum = 0;
    Byte cmdBuffer[48] = {0};
    NSLog(@"SB WRITE START ...");
    cmdBuffer[0] = BIONIME_HOC;
    
    switch (_currentCmdSel) {
        case METHOD_INIT: // ENABLE ACCESS MEMORY
            _recordIndex = 0;
            _mmolFlag = NO;
            cmdLength = CMD_LEN_ENMEM;
            cmdBuffer[1] = BIONIME_CID_ENMEM;
            
            cmdBuffer[2] = 'B';
            cmdBuffer[3] = 'n';
            cmdBuffer[4] = '0';
            
            _reportLength = 2;
            break;
            
        case METHOD_MODEL:
            cmdLength = CMD_LEN_MODEL;
            cmdBuffer[1] = BIONIME_CID_MODEL;
            _reportLength = 2+5;
            break;
            
        case METHOD_VERSION:
            cmdLength = CMD_LEN_FWVER;
            cmdBuffer[1] = BIONIME_CID_FWVER;
            _reportLength = 2+4;
            break;
            
        case METHOD_SN:
            cmdLength = CMD_LEN_SN;
            cmdBuffer[1] = BIONIME_CID_SN;
            //_reportLength = 2+5;
            break;
            
        case METHOD_UNIT:// Unit and Current Time
            cmdLength = CMD_LEN_DT_UNIT;
            
            cmdBuffer[1] = BIONIME_CID_GS_DATE_TIME_UNIT;
            
            cmdBuffer[2] = 0; // UNIT, Read, 24Hr
            
            cmdBuffer[3] = 0; // YEAR
            cmdBuffer[4] = 0; // MONTH
            cmdBuffer[5] = 0; // DAY
            
            cmdBuffer[6] = 0; // HOUR
            cmdBuffer[7] = 0; // MINUTE
            
            _reportLength = 2+6;
            break;
            
        case METHOD_TIME:
            _timerWriting = YES;
            cmdLength = CMD_LEN_DT_UNIT;
            cmdBuffer[1] = BIONIME_CID_GS_DATE_TIME_UNIT;
            
            //cmdBuffer[2] = 0x11; // UNIT, Read, 24Hr
            cmdBuffer[2] = 0x01; // UNIT, Read, 24Hr
            cmdBuffer[2] |= 0x08; // Write Enable
            
            [self sysCurrentTime];
            
            cmdBuffer[3] = _sbYear; // YEAR
            cmdBuffer[4] = _sbMonth; // MONTH
            cmdBuffer[5] = _sbDay; // DAY
            
            cmdBuffer[6] = _sbHour; // HOUR
            cmdBuffer[7] = _sbMinute; // MINUTE
            
            
            _reportLength = 2+6;
            break;
            
        case METHOD_NROFRECORD:
            cmdLength = CMD_LEN_RECORD;
            cmdBuffer[1] = BIONIME_CID_RECORD;
            cmdBuffer[2] = 0;
            cmdBuffer[3] = 0;
            //memcpy(&cmdBuffer[2], &_recordIndex, 2);
            _reportLength = 2+2+6;// Head, Index, Data
            break;
            
        case METHOD_RECORD:
            cmdLength = CMD_LEN_RECORD;
            cmdBuffer[1] = BIONIME_CID_RECORD;
            //memcpy(&cmdBuffer[2], &_recordIndex, 2);
            //memcpy(&cmdBuffer[2], &[H2AudioAndBleSync sharedInstance].recordIndex, 2);
            //cmdBuffer[2] = 1;
            //cmdBuffer[3] = 0;
            
            cmdBuffer[2] = (UInt8)([H2AudioAndBleSync sharedInstance].recordIndex & 0xFF);
            cmdBuffer[3] = (UInt8)(([H2AudioAndBleSync sharedInstance].recordIndex & 0xFF00)>>8);
            _reportLength = 2+2+6;// Head, Index, Data
            [H2AudioAndBleSync sharedInstance].recordIndex--;
            break;
            
        default:
            break;
    }
    _cmdRId = (~cmdBuffer[1]);
    for (int i=0; i<cmdLength; i++) {
        checkSum += cmdBuffer[i];
    }
    cmdBuffer[cmdLength] = (checkSum & 0xFF);
    
    NSData *dataToWrite = [[NSData alloc]init];
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdBuffer length:cmdLength+1];
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:[Gm700sb sharedInstance].bioNimeCharacteristicWrite type:CBCharacteristicWriteWithResponse];
    NSLog(@"SB WRITE CMD (NORMAL)");
    NSLog(@"CMD = %@", dataToWrite);
}

#pragma mark - HELPER ...
- (void)sysCurrentTime
{
    Byte  *timeBuffer;
    timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
    
    UInt8 year = timeBuffer[0]; //[components year];
    UInt8 month = timeBuffer[1]; //[components month];
    UInt8 day = timeBuffer[2]; //[components day];
    
    UInt8 hour = timeBuffer[3]; //[components hour];
    UInt8 minute = timeBuffer[4]; //[components minute];
    UInt8 second = timeBuffer[5]; //[components second];
    
    _sbYear = year;
    _sbMonth = month-1;
    _sbDay = day - 1;
    _sbHour = hour;
    _sbMinute = minute;
    
#ifdef DEBUG_BP
    DLog(@" SB_PR DEMO-DEBUG Y:%04X, M:%02X, D:%02X", year, month, day);
    DLog(@" SB_PR DEMO-DEBUG H:%02X, MIN:%02X, SEC:%02X", hour, minute, second);
    DLog(@" SB_PR OMRON Y:%04X, M:%02X, D:%02X", year, month, day);
#endif
}

- (void)sbNofityAgain
{
    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:NO forCharacteristic:_bioNimeCharacteristicNotify];
}


+ (Gm700sb *)sharedInstance
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
- (void)queryModelName
{
    /*
     Host Send:
     0xB0 0x00 0xB0
     
     Mete Response:
     0x4F 0xFF 0x47 0x4D 0x37 0x38 0x32 0x83 (HEX)
     
     HDR CID ‘G’ ‘M’’ ‘7’ ‘8’ ‘2’ CS (ASCII)
     It means the Meter’s Model name is GM700.
     */
    
}

- (void)queryFirmwareVersion
{
    /*
     Host Send:
     0xBO 0x01 0xB1
     
     Meter Response:
     0x4F 0xFE ‘A’ ‘0’ ‘0’ ‘8’  CS (ASCII)
     0x4F 0xFE 0x41 0x30 0x30 0x38 0x26 (Hex)
     It means Meter’s firmware version is A008
     */
}

- (void)enableAccessingMemory
{
    /*
     Host Send:
     0xB0 0x02 0x42 0x6E 0x30 CS (HEX)
     HDR CID ‘B’ ‘n’ ‘0’ CS (ASCII)
     Meter Response:
     0x4F 0xFD CS (HEX)
     HDR CID CS (ASCII)
     */
}

//Get/Set
- (void)getDateTimeAndUnit
{
    /*
     Host Send:
     0xB0 0x06 0x00 0x00 0x00 0x00 0x00 0x00 0xB6
     Meter Response:
     0x4F 0xF9 0x01 0x09 0x00 0x00 0x0C 0x00 0x5E
     
     Unit(0x01) Read Time, 24-hours, mg/dL, Unit is
     Year(0x09) Means year 2009
     Month(0x00) Means January
     Day(0x00) Means 1st day of the month
     Hour(0x0C) Means 12 o’clock
     Minute(0x00) Means 0 minutes
     
     7:5
     Reserved, Default = 0.
     
     4
     On/Off Volume(Buzzer) 0 : Volume On
     1 : Volume Off
     
     
     3
     Read or Write
     0 : read from meter 1 : write to meter
     
     2
     24-hours display setting
     0 : 24 hours display. 1 : 12 hours display.
     
     1
     Display measurement unit, 0 : mg/dL
     1 : mmol/L
     NOTE:
     If Bit 0 of this byte is 1, it means Unit Setting is fixed, then bit 1 is unworkable.
     0
     Unit changeable setting 0 : Unit is changeable. 1 : Unit is fixed.
     NOTE:
     This bit is only workable during read data; write is unworkable,
     */
    
    
    
    
}

- (void)setDateTimeAndUnit
{
    
}

- (void)querySerialNumber
{
    
}

- (void)readOneRecord
{
    
}

- (void)readEightRecord
{
    
}
#endif

/*
 - (void)bioNimeGb700sbA2Flow
 {
 [NSTimer scheduledTimerWithTimeInterval:SB_READ_MODE_INTERVAL target:self selector:@selector(bioNimeGb700sbA2ReadTask) userInfo:nil repeats:NO];
 }
 
 - (void)bioNimeGb700sbA2ReadTask
 {
 switch (_readingSel) {
 case READ_A1:
 [[H2BleService sharedInstance].h2ConnectedPeripheral readValueForCharacteristic:_bioNimeCharacteristicReadWrite];
 break;
 
 case READ_A2:
 [[H2BleService sharedInstance].h2ConnectedPeripheral readValueForCharacteristic:_bioNimeCharacteristicNotify];
 break;
 
 default:
 break;
 }
 
 //#ifdef DEBUG_LIB
 NSLog(@"SB READING TASK .... %02X", _readingSel);
 //#endif
 }
 */

/*
 - (void)bioNimeGb700sbA3CmdFlowInit
 {
 unsigned char cmdTemp[] = {0xB0, 0x30, 0xE0};
 NSData *dataToWrite = [[NSData alloc]init];
 
 // Write ...
 dataToWrite = [NSData dataWithBytes:cmdTemp length:sizeof(cmdTemp)];
 
 [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_bioNimeCharacteristicWrite type:CBCharacteristicWriteWithResponse];
 NSLog(@"SB INIT CMD = %@", dataToWrite);
 }
 
 
 - (void)bioNimeGb700sbA3CmdBF2
 {
 unsigned char cmdTemp[] = {0xB0, 0x32, 0x01, 0x04, 0xE7};
 NSData *dataToWrite = [[NSData alloc]init];
 
 // Write ...
 dataToWrite = [NSData dataWithBytes:cmdTemp length:sizeof(cmdTemp)];
 
 [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_bioNimeCharacteristicWrite type:CBCharacteristicWriteWithResponse];
 NSLog(@"SB BEFORE CMD = %@", dataToWrite);
 }
 
 - (void)bioNimeGb700sbA3CmdBF3
 {
 unsigned char cmdTemp[] = {0xB0, 0x33, 0xE3};
 NSData *dataToWrite = [[NSData alloc]init];
 
 // Write ...
 dataToWrite = [NSData dataWithBytes:cmdTemp length:sizeof(cmdTemp)];
 
 [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_bioNimeCharacteristicWrite type:CBCharacteristicWriteWithResponse];
 }
 
 - (void)bioNimeGb700sbA3CmdBF4
 {
 unsigned char cmdTemp[] = {0xB0, 0x34, 0xE4};
 NSData *dataToWrite = [[NSData alloc]init];
 
 // Write ...
 dataToWrite = [NSData dataWithBytes:cmdTemp length:sizeof(cmdTemp)];
 
 [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_bioNimeCharacteristicWrite type:CBCharacteristicWriteWithResponse];
 }
 */

/*
 - (void)bioNimeGb700sbCh1
 {
 switch (_currentCmdSel) {
 case METHOD_INIT:
 
 _currentCmdSel = METHOD_MODEL;
 break;
 
 case METHOD_MODEL:
 [self bioNimeModel];
 _currentCmdSel = METHOD_VERSION;
 break;
 
 case METHOD_VERSION:
 [self bioNimeFirmwareVersion];
 _currentCmdSel = METHOD_SN;
 break;
 
 case METHOD_SN:
 [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [self bioNimeSerialNumber];
 _currentCmdSel = METHOD_UNIT;
 break;
 
 case METHOD_UNIT:
 [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [self bioNimeDateTimeAndUnit];
 _currentCmdSel = METHOD_NROFRECORD;
 break;
 
 case METHOD_NROFRECORD:
 [self bioNimeTotalAmount];
 _currentCmdSel = METHOD_RECORD;
 [H2SyncReport sharedInstance].didSendEquipInformation = YES;
 break;
 
 case METHOD_RECORD:
 [self bioNimeDateTimeValueParser];
 _currentCmdSel = METHOD_RECORD;
 
 [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
 break;
 
 default:
 break;
 }
 if ([H2SyncReport sharedInstance].didSyncRecordFinished) {// finshed
 //
 }else{ // Report Meter Info.
 if ([H2SyncReport sharedInstance].didSendEquipInformation) {
 //
 }else{ // Next Command Continued
 [self bioNimeGb700sbCmmand];
 }
 }
 }
 */
