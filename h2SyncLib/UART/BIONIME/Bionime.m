//
//  Bionime.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/5/28.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "H2AudioFacade.h"
#import "Bionime.h"
#import "h2CmdInfo.h"
#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"

// B0 02 42 6E 30 92

@implementation Bionime


- (id)init
{
    if (self = [super init]) {
        _bmIsUnitMmol = NO;
        _bmSerialNrReturnLen = 0;
        _bmCommandAndUnit = 0;
        _bmUnitString = [NSString stringWithFormat:@""];
    }
    return self;
}

+ (Bionime *)sharedInstance
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

/*
unsigned char careSenseNPlusCmdInit[] = {
    0x80
};
unsigned char careSenseNCmdBrand[] = {
    0x8B, 0x11, 0x20, 0x13, 0x24, 0x10, 0x2A
};
unsigned char careSenseNCmdModel[] = {
    0x8B, 0x11, 0x20, 0x13, 0x24, 0x10, 0x2A
};

unsigned char careSenseNCmdSerialNumber[] = {
    0x8B, 0x11, 0x20, 0x18, 0x26, 0x10, 0x22
};
unsigned char careSenseNCmdDate[] = {
    //    0x8B, 0x11, 0x20, 0x18, 0x26, 0x10, 0x22
    0x8B, 0x11, 0x20, 0x18, 0x26, 0x10, 0x22
};

unsigned char careSenseNCmdRecord[] = {

    0x8B, 0x1E, 0x22, 0x13, 0x20, 0x10, 0x28      // 0
};
*/

// B0 02 42 6E 30 92


#pragma mark -
#pragma mark BIONIME COMMAND

- (void)BionimeCommandGeneral:(UInt16)cmdMethod
{
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    UInt8 bionimeReturnLength = 0;
    Byte cmdBuffer[16] = {0};
    cmdBuffer[0] = BM_CMD_HEADER;
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    
    UInt8 cmdCheckSum = 0;
    
    switch (cmdMethod) {
        case METHOD_MODEL: // Query Model
            cmdLength = BM_CMD_LEN_QMODEL;
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            cmdBuffer[1] = BM_CMD_ID_QMODEL; // Command ID
            bionimeReturnLength = BM_RT_LEN_QMODEL;
            break;
            
        case METHOD_VERSION: // Query FW Version
            cmdLength = BM_CMD_LEN_QFWVER;
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            cmdBuffer[1] = BM_CMD_ID_QFWVER; // Command ID
            bionimeReturnLength = BM_RT_LEN_QFWVER;
            break;
            
        case METHOD_4:
//            B0 02 42 6E 30 92
            cmdLength = 6;
            cmdTypeId = (currentMeter<<4) + METHOD_4;
            cmdBuffer[1] = 0x02; // Command ID
            
            cmdBuffer[2] = 0x42;
            cmdBuffer[3] = 0x6E;
            cmdBuffer[4] = 0x30;
            
            bionimeReturnLength = 3;//BM_RT_LEN_QSN;
            break;
            
        case METHOD_5:
            _bmSerialNrReturnLen = 0;
            //            B0 02 42 6E 30 92
            cmdLength = BM_CMD_LEN_QSN;
            cmdTypeId = (currentMeter<<4) + METHOD_5;
            cmdBuffer[1] = BM_CMD_ID_QSN; // Command ID
            
            bionimeReturnLength = 10;//BM_RT_LEN_QSN;
            break;
            
        case METHOD_6:
            cmdLength = 6;
            cmdTypeId = (currentMeter<<4) + METHOD_6;
            cmdBuffer[1] = 0x02; // Command ID
            
            cmdBuffer[2] = 0x42;
            cmdBuffer[3] = 0x6E;
            cmdBuffer[4] = 0x30;
            
            bionimeReturnLength = 3;//BM_RT_LEN_QSN;
            break;
            
        case METHOD_SN:
            cmdLength = BM_CMD_LEN_QSN;
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            cmdBuffer[1] = BM_CMD_ID_QSN; // Command ID

            bionimeReturnLength = _bmSerialNrReturnLen;//BM_RT_LEN_QSN;
            break;

            
        case METHOD_DATE: // Get Current Date Time Unit
            cmdLength = BM_CMD_LEN_G_S_DATE_TIME_UNIT;
            cmdTypeId = (currentMeter<<4) + METHOD_DATE;
            cmdBuffer[1] = BM_CMD_ID_G_S_DATE_TIME_UNIT; // Command ID
            bionimeReturnLength = BM_RT_LEN_G_S_DATE_TIME_UNIT;
            break;
            
        case METHOD_TIME: // SET Current Date Time Unit
            cmdLength = BM_CMD_LEN_G_S_DATE_TIME_UNIT;
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            cmdBuffer[1] = BM_CMD_ID_G_S_DATE_TIME_UNIT; // Command ID
            
            cmdBuffer[2] = _bmCommandAndUnit | BM_CMD_ID_G_S_WRITE_EN;
            
            cmdBuffer[3] = [H2SystemDateTime sharedInstance].sysYearByte;
            cmdBuffer[4] = [H2SystemDateTime sharedInstance].sysMonth;
            cmdBuffer[5] = [H2SystemDateTime sharedInstance].sysDay;
            
            cmdBuffer[6] = [H2SystemDateTime sharedInstance].sysHour;
            cmdBuffer[7] = [H2SystemDateTime sharedInstance].sysMinute;
            
            bionimeReturnLength = BM_RT_LEN_G_S_DATE_TIME_UNIT;
            break;
            
            
        case METHOD_NROFRECORD: // Get Current Date Time Unit
            cmdLength = BM_CMD_LEN_RECORD;
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            cmdBuffer[1] = BM_CMD_ID_RECORD; // Command ID
            bionimeReturnLength = BM_RT_LEN_RECORD;
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i<cmdLength-1; i++) {
        cmdCheckSum += cmdBuffer[i];
    }
    cmdBuffer[cmdLength-1] = cmdCheckSum;
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:bionimeReturnLength mcuBufferOffSetAt:0];
}




- (void)BionimeReadRecord:(UInt16)nIndex
{
    // first Index is totalRecord, last Index is 1
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = BM_CMD_LEN_RECORD;
    UInt16 cmdTypeId = (currentMeter<<4) + METHOD_RECORD;
    
    UInt8 cmdNumberOfDataWantReturn = BM_RT_LEN_RECORD;
    
    unsigned char cmdBuffer[cmdLength];
    
    UInt8 cmdCheckSum = 0;
    cmdBuffer[0] = BM_CMD_HEADER;
    cmdBuffer[1] = BM_CMD_ID_RECORD; // Command ID
    
    memcpy(&cmdBuffer[2], &nIndex, 2);
    
#ifdef DEBUG_BIONIME
    DLog(@"DEBUG_CARESENS the Index 0 issue %03X", nIndex);
#endif
    
    
#ifdef DEBUG_BIONIME

#endif
    
    
    for (int i = 0; i<cmdLength-1; i++) {
        cmdCheckSum += cmdBuffer[i];
    }
    cmdBuffer[cmdLength-1] = cmdCheckSum;
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType: cmdTypeId returnDataLength:cmdNumberOfDataWantReturn mcuBufferOffSetAt:0];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// Parser
#define FLAG_MEAL       0x02

- (H2BgRecord *)BionimeDateTimeValueParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    /*
     BM_RECORD_ADDR_IND_L                            2
     #define BM_RECORD_ADDR_IND_H                            3
     #define BM_RECORD_ADDR_DA_0                             4
     #define BM_RECORD_ADDR_DA_1                             5
     #define BM_RECORD_ADDR_DA_2                             6
     #define BM_RECORD_ADDR_DA_3                             7
     #define BM_RECORD_ADDR_DA_4                             8
     #define BM_RECORD_ADDR_DA_5
     */
    BOOL hiValueFlag = NO;
    
//    NSString *bmDateTimeString;
    UInt16 bmYear = 0;
    UInt8 bmMon = 0;
    UInt8 bmDay = 0;
    UInt8 bmHour = 0;
    
    UInt8 bmMin = 0;
//    NSString *bionimeUint = 0;
    
    UInt8 numberHiByte = 0;
    UInt8 numberLoByte = 0;
    UInt16 value = 0;
    
    UInt8 bmCondition = 0;
//    UInt8 bmRealValue = 0;
    
    H2BgRecord *bionimeRecord;
    bionimeRecord = [[H2BgRecord alloc] init];
    
    
    // Ex.: Month = (DA_1 & 0xC0) >> 4 + (DA_0 & 0xC0) >> 6 + 1
    bmMon = ((recordData[BM_RECORD_ADDR_DA_1] & MONTH_MASK) >> MONTH_BIT_SHIFT_HI) + ((recordData[BM_RECORD_ADDR_DA_0] & MONTH_MASK) >> MONTH_BIT_SHIFT_LO) + 1;
    // Ex.: Day = DA_0 & 0x1F + 1
    bmDay = (recordData[BM_RECORD_ADDR_DA_0] & DAY_MASK) + 1;
    
    
    // Hour (24-hours).
    // Value Range: 0-23, means 00:00 to 23:00.
    // Ex.: Hour = DA_1 & 0x1F
    bmHour = recordData[BM_RECORD_ADDR_DA_1] & HOUR_MASK;
    
    // Minute.
    // Range: 0~59, Means 0~59 minutes.
    // Ex.: Minute = DA_2 & 0x3F
    bmMin = recordData[BM_RECORD_ADDR_DA_2] & MIN_MASK;
    
    
    
    // The last 2 digits of year.
    // Range: 0~99; Means 2000~ 2099 (DEX)
    // Ex: Year = DA_3 & 0x7F + 2000
    
    bmYear = (recordData[BM_RECORD_ADDR_DA_3] & YEAR_MASK) + 2000;
    
    if (recordData[BM_RECORD_ADDR_DA_3] & VALUE_HI_FLAG_MASK) {
        hiValueFlag =  YES;
    }
    
    /*******************************************************************
     * DA_4 Description: Bit Description
     * 7:6
     * CNT_M & CNT_L
     * The medium & low bits of sequence count.
     * Sequence count will count from 0 to 7, and then repeat again.
     * Ex.: Seq. Count = (DA_2 & 0x80) >> 5 + (DA_4 & 0xC0) >> 6
     * 5
     * Please check Bit 3 description.
     * 4
     * The flag of out of acceptable temperature range.
     *
     * 1: out of the acceptable range.
     * 0: within the range.
     * 3
     */
    
    
     /*******************************************************************
     * Please combine Bit 3 & 5 for deciding which marker was used. More detail description please see below:
     * .
     * Bit3
     * Bit 5
     * Description
      *
     * 0
     * 0
     * Add to average calculation(AVG)
      *
     * 0
     * 1
     * NOT add to average calculation(NO AVG)
      *
     * 1
     * 0
     * Before meal
      *
     * 1
     * 1
     * After meal
      */
    bmCondition = ((recordData[BM_RECORD_ADDR_DA_4] & 0x08) >> 3) + ((recordData[BM_RECORD_ADDR_DA_4] & 0x20) >> 4) ;
    switch (bmCondition) {
        case 2:
            bionimeRecord.bgMealFlag = @"A";
            break;
        case 3:
            bionimeRecord.bgMealFlag = @"B";
            break;
            
        default:
            bionimeRecord.bgMealFlag = @"N";
            break;
    }
     /*******************************************************************
     * 2
     * The flag for mark control solution measurement.
     * 1: Use Control solution test.
     * 0: Normal blood glucose test
      */
    if (recordData[BM_RECORD_ADDR_DA_4] & CTRL_SOLUTION_MASK) {
        bionimeRecord.bgMealFlag = @"C";
#ifdef DEBUG_BIONIME
        DLog(@"BIONIME_DEBUG CONTROL SOLUTION EEE --- ");
#endif
    }
      
    /*******************************************************************
     * 1:0
     * Blood glucose value (High bits, Bit 9:8).
     * Ex: Glucose Value = (DA_4 & 0x03) << 8 + DA_5
     */
    if (hiValueFlag) {
        value = 600;
    }else{
        numberHiByte = recordData[BM_RECORD_ADDR_DA_4] & VALUE_HI_MASK;
        numberLoByte = recordData[BM_RECORD_ADDR_DA_5];
        value = (numberHiByte << 8) + numberLoByte;
    }
    
    
    if (value >= 600) {
        value = 600;
    }
    
    if (_bmIsUnitMmol) {
        bionimeRecord.bgValue_mg = 0;
        bionimeRecord.bgValue_mmol = (float)value/MMOL_COIF;
    }else{
        bionimeRecord.bgValue_mg = value;
        bionimeRecord.bgValue_mmol = 0.0f;
    }
    
    bionimeRecord.bgUnit = _bmUnitString;
    
    
    bionimeRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",bmYear, bmMon, bmDay, bmHour, bmMin];
#ifdef DEBUG_BIONIME
        DLog(@"DEBUG_BIONIME record infomation");
        DLog(@"DEBUG_BIONIME date time is %@", bionimeRecord.bgDateTime);
#endif
//j        bionimeRecord.smRecordIndex = index;
    
    if (![bionimeRecord.bgMealFlag isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bionimeRecord.bgDateTime]) {
            bionimeRecord.bgMealFlag = @"C";
        }
    }
    
    return bionimeRecord;
}

#pragma mark - CALC SN RETURN LEN

- (void)BionimeSerialNrLenParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(16);
    if (length < 16) {
        memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }
    _bmSerialNrReturnLen = 3;
    if (length >= 3) {
        _bmSerialNrReturnLen = 1 + 1 + recordData[2] + 1 + 1;
    }
#ifdef DEBUG_BIONIME
    DLog(@"DEBUG_BIONIME SN Return Length is %d", _bmSerialNrReturnLen);
#endif
}

#pragma mark - THE OTHER PARSER OFR BIONIME

- (NSString *)BionimeModelVerSerialNrParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 tmpBuffer[32] = {0};
    NSString *bionimeModeVersionSerialNumber;
    UInt8 bioSel = recordData[1];
    UInt8 dataOffset = 0;
    UInt8 stringLen = 0;
    UInt8 snCheckSum = 0;
    switch (bioSel) {
        case BM_RT_ID_QMODEL:
            dataOffset = 2;
            stringLen = BM_RT_LEN_QMODEL - 3;
            break;
        case BM_RT_ID_G_S_DATE_TIME_UNIT:
            break;
            
        case BM_RT_ID_QFWVER:
            dataOffset = 2;
            stringLen = BM_RT_LEN_QFWVER - 3;
            break;
            
        case BM_RT_ID_QSN:
            dataOffset = 3;
            stringLen = recordData[2];
            
            for (int i = dataOffset; i<stringLen; i++) {
                snCheckSum += recordData[i + dataOffset];
            }
            break;
            
        default:
            break;
    }
    memcpy(tmpBuffer, &recordData[dataOffset], stringLen);
//#define BM_RT_ID_RECORD                         0xF8

    bionimeModeVersionSerialNumber = [NSString stringWithUTF8String:(const char *)tmpBuffer];
#ifdef DEBUG_BIONIME
    DLog(@"DEBUG_BIONIME -- MODEL VER SN -- %@", bionimeModeVersionSerialNumber);
#endif
    return bionimeModeVersionSerialNumber;
}

//- (NSString*)BionimeFwVerParser:(char*)recordData withLength:(UInt16)length;
//{
//    NSString *bionimeMode;
//    return bionimeMode;
//}

//                             2

#pragma mark - CURRENT DATE TIME UNIT
- (NSString *)BionimeCurrentDateTimeUnitParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    NSString *bionimeDateTimeString;
    UInt16 bionimeYear = 0;
    UInt8 bionimeMon = 0;
    UInt8 bionimeDay = 0;
    UInt8 bionimeHour = 0;
    
    UInt8 bionimeMin = 0;
    NSString *bionimeUint;
    
//    BOOL bionimeIsTime12 = NO;

    if (recordData[BM_UINT_ADDR_YEAR] < 100) {
        bionimeYear = recordData[BM_UINT_ADDR_YEAR] + 2000;
    }else{
        
    }
    
    if (recordData[BM_UINT_ADDR_MON] < 12) {
        bionimeMon = recordData[BM_UINT_ADDR_MON] + 1;
    }else{
        // error
    }
    
    if (recordData[BM_UINT_ADDR_DAY] < 31) {
        bionimeDay = recordData[BM_UINT_ADDR_DAY] + 1;
    }else{
        
    }
    
    if (recordData[BM_UINT_ADDR_HOUR] < 24) {
        bionimeHour = recordData[BM_UINT_ADDR_HOUR];
    }else{
        
    }
    
    
    if (recordData[BM_UINT_ADDR_MIN] < 60) {
        bionimeMin = recordData[BM_UINT_ADDR_MIN];
    }else{
        
    }
    
    _bmCommandAndUnit = recordData[BM_UINT_ADDR_UNIT];
    if (recordData[BM_UINT_ADDR_UNIT] & BM_UNIT_BIT_MMOL) {
        bionimeUint = BG_UNIT_EX;
        _bmIsUnitMmol = YES;
        _bmUnitString = BG_UNIT_EX;
    }else{
        _bmIsUnitMmol = NO;
        bionimeUint = BG_UNIT;
        _bmUnitString = BG_UNIT;
    }
    
 
    
    
    bionimeDateTimeString = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",bionimeYear, bionimeMon, bionimeDay, bionimeHour, bionimeMin];
#ifdef DEBUG_BIONIME
    DLog(@"DEBUG_BIONIME -- CURRENT TIME -- %@", bionimeDateTimeString);
#endif
    return bionimeDateTimeString;
}


//- (NSString*)BionimeSerialNumberParser:(char*)recordData withLength:(UInt16)length
//{
//    NSString *bionimeMode;
//    return bionimeMode;
//}

- (UInt16)BionimeTotalRecordParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 numberHiByte = 0;
    UInt8 numberLoByte = 0;
    
    UInt16 bionimeTotalAmount = 0;
    if (recordData[BM_RECORD_ADDR_IND_L] == 0 && recordData[BM_RECORD_ADDR_IND_H] == 0) {
        memcpy(&numberHiByte, &recordData[BM_RECORD_ADDR_DA_1], 1);
        numberHiByte = recordData[BM_RECORD_ADDR_DA_1];
        numberLoByte = recordData[BM_RECORD_ADDR_DA_0];
//        bionimeTotalAmount = (recordData[BM_RECORD_ADDR_DA_1] << 8) + recordData[BM_RECORD_ADDR_DA_0];
        bionimeTotalAmount = (numberHiByte << 8) + numberLoByte;// + recordData[BM_RECORD_ADDR_DA_0];
    }
    
#ifdef DEBUG_BIONIME
    DLog(@"DEBUG_BIONIME -- TOTAL NUMBER X -- %d %02X, %02X, %02X", bionimeTotalAmount, recordData[BM_RECORD_ADDR_DA_1], recordData[BM_RECORD_ADDR_DA_0], numberHiByte);
#endif
    return bionimeTotalAmount;
}

@end
