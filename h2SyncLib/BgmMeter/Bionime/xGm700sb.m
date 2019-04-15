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
        
        // BioNeme GM700SB Service
        _bioNimeService = nil;
        
        // BioNeme GM700SB Characteristic
        _bioNimeCharacteristicReadWrite = nil;
        _bioNimeCharacteristicNotify = nil;
        _bioNimeCharacteristicWrite = nil;
        
        _reportLength = 0;
        _mmolFlag = NO;
        //_currentCmdSel = METHOD_INIT;
    }
    return self;
}

#pragma mark - GM700SB PARSER
- (void)bioNimeGb700sbDataProcess
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


#pragma mark - MODEL PARSER
- (NSString *)bioNimeModel
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    unsigned char srcTmp[32] = {0};
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    if (srcData[0] != 0x4F) {
        return nil;
    }
    //if (srcData[0] != (~BIONIME_HOC) || srcData[1] !=_cmdRId) {
     //   return nil;
    //}
    
    UInt16 tmpSum = 0;
    for (int i=0; i<_reportLength; i++) {
        tmpSum += srcData[i];
    }
    
    if (tmpSum != (~srcData[_reportLength])) {
        return nil;
    }
    
    memcpy(srcTmp, &srcData[2], DATA_LEN_MODEL);
    
    NSString *string = [NSString stringWithUTF8String:(const char *)srcTmp];
    return string;
}

#pragma mark - FIRMWAR VERSION PARSER
- (NSString *)bioNimeFirmwareVersion
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    unsigned char srcTmp[32] = {0};
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    //if (srcData[0] != (~BIONIME_HOC) || srcData[1] !=_cmdRId) {
    //    return nil;
    //}
    
    UInt16 tmpSum = 0;
    for (int i=0; i<_reportLength; i++) {
        tmpSum += srcData[i];
    }
    
    if (tmpSum != (~srcData[_reportLength])) {
        return nil;
    }
    
    memcpy(srcTmp, &srcData[2], DATA_LEN_FWVER);
    
    NSString *string = [NSString stringWithUTF8String:(const char *)srcTmp];
    return string;
}

#pragma mark - SERIAL NUMBER PARSER
- (NSString *)bioNimeSerialNumber
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    unsigned char srcTmp[32] = {0};
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 snLen = srcData[3];
    
    //if (srcData[0] != (~BIONIME_HOC) || srcData[1] !=_cmdRId) {
    //    return nil;
    //}

    // SN CheckSum
    UInt16 tmpSum = 0;
    for (int i=0; i<snLen; i++) {
        tmpSum += srcData[3+i];
    }
    
    if (tmpSum != (~srcData[2+1+snLen])) {
        return nil;
    }
    // Total CheckSum
    tmpSum = 0;
    for (int i=0; i<2+1+snLen+1; i++) {
        tmpSum += srcData[i];
    }
    
    if (tmpSum != (~srcData[2+1+snLen+1])) {
        return nil;
    }

    memcpy(srcTmp, &srcData[3], snLen);
    
    NSString *string = [NSString stringWithUTF8String:(const char *)srcTmp];
    return string;
}

#pragma mark - CURRENT TIME AND UNIT PARSER
- (NSString *)bioNimeDateTimeAndUnit
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    //unsigned char srcTmp[32] = {0};
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    //if (srcData[0] != (~BIONIME_HOC) || srcData[1] !=_cmdRId) {
        //return nil;
    //}
    
    UInt16 tmpSum = 0;
    for (int i=0; i<_reportLength; i++) {
        tmpSum += srcData[i];
    }
    
    if (tmpSum != (~srcData[_reportLength])) {
        return nil;
    }
    
    UInt16 year = srcData[3];
    UInt8 month = srcData[4];
    UInt8 day = srcData[5];
    
    UInt8 hour = srcData[6];
    UInt8 minute = srcData[7];
    
    _mmolFlag = NO; // mg/dL
    if (srcData[2] & 0x02) {
        _mmolFlag = YES; // mmol/L
    }
    
    
    NSString *currentTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", year, month, day, hour, minute];
    return currentTime;
}



- (UInt16) bioNimeTotalAmount
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 totalAmount = (srcData[DA_1] << 8 ) + srcData[DA_0];
    _recordIndex = totalAmount;
    DLog(@"BIONIME TOTAL AMOUT = %d", totalAmount);
    return (srcData[DA_1] << 8 ) + srcData[DA_0];
}






- (H2BgRecord *)bioNimeDateTimeValueParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    UInt8 month = ((srcData[DA_1] & 0xC0) >> 4) + ((srcData[DA_0] & 0xC0) >> 6) + 1;
    UInt8 day = srcData[DA_0] & 0x1F + 1;
    
    UInt8 hour = srcData[DA_1] & 0x1F;
    UInt8 minute = srcData[DA_2] & 0x3F;
    
    UInt16 year = srcData[DA_3] & 0x7F + 2000;
    
    UInt16 glucoseValue = 0;
    //Hi Flag
    //1: Record was marked as “Hi”( Over 600 mg/dL)
    if (srcData[DA_3] & 0x80) {
        glucoseValue = 600;
    }else{
        glucoseValue = ((srcData[DA_4] & 0x03) << 8) + srcData[DA_5];
    }
    
    
    
    
    
    H2BgRecord *bioNimeRecord;
    bioNimeRecord = [[H2BgRecord alloc] init];
    
    //bioNimeRecord.smRecordValue_mg = 0;
    
    
    bioNimeRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", year, month, day, hour, minute];
    
    // Control Solution
    if (srcData[DA_4] & 0x04) {
        bioNimeRecord.bgMealFlag = @"C";
    }else{ // Normal
        // Meal Flag
        if (srcData[DA_4] & 0x08) {// Meal Flag
            if (srcData[DA_4] & 0x20) {// Meal Flag
                // After
                bioNimeRecord.bgMealFlag = @"A";
            }else{
                // Before
                bioNimeRecord.bgMealFlag = @"B";
            }
            
        }else{ // AVG or Non
            
        }
    }
    
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
    
    return bioNimeRecord;
}



#pragma mark - GM700SB Command

- (void)bioNimeGb700sbCmmand//:(UInt16)cmdMethod
{
    UInt8 cmdLength = 0;
    UInt16 checkSum = 0;
    Byte cmdBuffer[48] = {0};
    
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
            
            cmdBuffer[3] = 17; // YEAR
            cmdBuffer[4] = 10; // MONTH
            cmdBuffer[5] = 1; // DAY
            
            cmdBuffer[6] = 13; // HOUR
            cmdBuffer[7] = 35; // MINUTE
            _reportLength = 2+6;
            break;
            
        case METHOD_NROFRECORD:
            cmdLength = CMD_LEN_RECORD;
            cmdBuffer[1] = BIONIME_CID_RECORD;
            memcpy(&cmdBuffer[2], &_recordIndex, 2);
            _reportLength = 2+2+6;// Head, Index, Data
            break;
            
        case METHOD_RECORD:
            cmdLength = CMD_LEN_RECORD;
            cmdBuffer[1] = BIONIME_CID_RECORD;
            memcpy(&cmdBuffer[2], &_recordIndex, 2);
            _reportLength = 2+2+6;// Head, Index, Data
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
}

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
