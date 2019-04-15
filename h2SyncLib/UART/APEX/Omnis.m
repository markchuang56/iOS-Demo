//
//  Omnis.m
//  h2SyncLib
//
//  Created by h2Sync on 2014/2/7.
//
//
#define MGDL_FLAG                   0x80

#define EMBRACE_CTRL_FLAG               0x01
#define EVO_CTRL_FLAG               0x80

#define STARTBYTE_PC                0xAA
#define OP_INIT                     0x00
#define OP_WRITE_BARCODE            0x0E
#define OP_BARCODE                  0x0F
#define OP_READ_DATETIME            0x07
#define OP_READ_ONE_RECORD          0x0B
#define OP_READ_ALL_RECORD          0x10

#define OP_WRITE_DATETIME           0x16


#define STARTBYTE_METER                0xDD

#define OMNIS_D0                2
#define OMNIS_D1                3
#define OMNIS_D2                4
#define OMNIS_D3                5

#define OMNIS_D4                6
#define OMNIS_D5                7
#define OMNIS_D6                8
#define OMNIS_D7                9

#define OMNIS_CHKSUM            10

#define OMINIS_DIV_FOR_ALL_RECORD   10
#define OMINIS_LEN_FOR_ALL_RECORD   (OMINIS_DIV_FOR_ALL_RECORD * OMNIS_REPORT_LEN)

#define OMNIS_RESEND_TIME       2
#import "Omnis.h"
#import "H2AudioFacade.h"
#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"
#import "H2BleService.h"

#import "H2Records.h"

// Serial Number example
Byte OmnisSerialNr_8[] = {
    '0', '1', '2', '4',         // Parameter 0~3
    '0', '0', 'W', 'W'         // Parameter 4~7
};

@interface Omnis()
{
    
}
- (BOOL)OmnisRecordEndCheck;
@end

@implementation Omnis


- (id)init
{
    if (self = [super init]) {

        _indexSeed = 0;
        _OmnisPreYear = 0x00;
        _OmnisPreYearOther = 0x00;
        
        
        //_omnisMeter_id = 0;
        
        _tmpIndex = 0;
        
        _omnisYear = 0;
        _omnisMonth = 0;
        
        _omnisTotalTime = 0;
        
        _omnisDay = 0;
        _omnisHour = 0;
        _omnisMinute = 0;
        
        _omnisUnit = 0;
        
        _omnisCtrlSolution = 0;
        
    
        
        _omnisValue = 0;
        
        
        _omnisTmpD1_Ctrl = 0;
        _omnisTmpD1_Food = 0;
        _omnisTmpD1_Events = 0;
    }
    
    return self;
}

//Byte OmnisCmdAll[] = {
//    0x00,                           // Start Byte
//    0x00,                           // OP code
//    0x00, 0x00, 0x00, 0x00,         // Parameter 0~3
//    0x00, 0x00, 0x00, 0x00,         // Parameter 4~7
//    0x00                            // CheckSum
//};



- (void)OmnisCommandGeneral:(UInt16)cmdMethod
{
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[11] = {0};
    UInt16 addr = 0;
    UInt8 reportDataLength = OMNIS_REPORT_LEN;
    UInt8 dataOffsetLocation = 0;
    cmdBuffer[0] = STARTBYTE_PC;
    UInt16 tmpDay = 0;
    UInt16 tmpHour = 0;
    UInt16 tmpMinute = 0;
    
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    
    switch (cmdMethod) {
        case METHOD_INIT:
            _OmnisEmbraceCount = EM_CYCLE;
            //_omnisMeter_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"meter_sel"];
            
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            cmdBuffer[1] = OP_INIT;
            break;
            
        case METHOD_4:
            cmdTypeId = (currentMeter<<4) + METHOD_4;
            cmdBuffer[1] = OP_READ_ONE_RECORD;
            addr = 0;
            memcpy(&cmdBuffer[OMNIS_D0], &addr, 2);
            break;
            
        case METHOD_5:
            cmdTypeId = (currentMeter<<4) + METHOD_5;
            cmdBuffer[1] = OP_READ_ONE_RECORD;
            addr = 1;
            memcpy(&cmdBuffer[OMNIS_D0], &addr, 2);
            break;
            
            
        case METHOD_6:
            cmdTypeId = (currentMeter<<4) + METHOD_6;
            cmdBuffer[1] = OP_READ_ONE_RECORD;
            addr = 2;
            memcpy(&cmdBuffer[OMNIS_D0], &addr, 2);
            break;
            
        case METHOD_ACK_RECORD:
            cmdTypeId = (currentMeter<<4) + METHOD_ACK_RECORD;
            cmdBuffer[1] = OP_READ_ALL_RECORD;
            reportDataLength = OMNIS_REPORT_LEN * EMBRACE_REPORT_COEF;
            if ([H2BleService sharedInstance].isBleCable) {
                dataOffsetLocation = EM_DIV_MODE + EM_CYCLE - _OmnisEmbraceCount; // for high speed
                _OmnisEmbraceCount--;
            }
            break;
            
            
       case METHOD_SN:
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
#if 1
            cmdBuffer[1] = OP_BARCODE;
#else
            // Write SN
            cmdBuffer[1] = OP_WRITE_BARCODE;

            memcpy(&cmdBuffer[OMNIS_D0], OmnisSerialNr_8, 8);
#endif
            break;
            
        case METHOD_TIME:
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            cmdBuffer[1] = OP_READ_DATETIME;
            break;
            
        case METHOD_DATE:   // WRITE BGM DATE TIME
            cmdTypeId = (currentMeter<<4) + METHOD_DATE;
            cmdBuffer[1] = OP_WRITE_DATETIME;
            
            cmdBuffer[2] = [H2SystemDateTime sharedInstance].sysYearByte;
            cmdBuffer[3] = [H2SystemDateTime sharedInstance].sysMonth;
            
            tmpDay = [H2SystemDateTime sharedInstance].sysDay;
            tmpHour = ([H2SystemDateTime sharedInstance].sysHour << 5);
            tmpMinute = ([H2SystemDateTime sharedInstance].sysMinute << 10);
            
            tmpMinute |= (tmpHour | tmpDay);
            memcpy(&cmdBuffer[4], &tmpMinute, 2);
            
            break;
 
        default:
            break;
    }
    
    for (int i = 1; i<OMNIS_CHKSUM; i++) {
        cmdBuffer[OMNIS_CHKSUM] += cmdBuffer[i];
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:OMNIS_COMMAND_LEN cmdType: cmdTypeId returnDataLength:reportDataLength mcuBufferOffSetAt:dataOffsetLocation];
}

- (void)OmnisRecord:(UInt16)nIndex
{
    UInt16 OmnisCmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_RECORD;
    Byte cmdBuffer[11] = {0};
    cmdBuffer[0] = STARTBYTE_PC;
    cmdBuffer[1] = OP_READ_ONE_RECORD;
    
    memcpy(&cmdBuffer[OMNIS_D0], &nIndex, 2);
    for (int i = 1; i<OMNIS_CHKSUM; i++) {
        cmdBuffer[OMNIS_CHKSUM] += cmdBuffer[i];
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:OMNIS_COMMAND_LEN cmdType:OmnisCmdType
                   returnDataLength:OMNIS_REPORT_LEN mcuBufferOffSetAt:0];
}

- (void)OmnisRecordAll:(UInt16)nIndex
{
    UInt16 OmnisCmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_VERSION;
    Byte cmdBuffer[11] = {0};
    cmdBuffer[0] = STARTBYTE_PC;
    cmdBuffer[1] = OP_READ_ALL_RECORD;
    
    UInt8 extValue = 0;
    extValue |= H2_HIGH_DATA_FLOW_EN;
    
    memcpy(&cmdBuffer[OMNIS_D0], &nIndex, 2);
    for (int i = 1; i<OMNIS_CHKSUM; i++) {
        cmdBuffer[OMNIS_CHKSUM] += cmdBuffer[i];
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:OMNIS_COMMAND_LEN cmdType:OmnisCmdType
                                     returnDataLength:OMINIS_LEN_FOR_ALL_RECORD mcuBufferOffSetAt:extValue];
}

- (void)OmnisNumberOfRecord:(UInt16)nIndex
{
    UInt16 OmnisCmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_NROFRECORD;
    Byte cmdBuffer[11] = {0};
    
    cmdBuffer[0] = STARTBYTE_PC;
    cmdBuffer[1] = OP_READ_ONE_RECORD;
    
    memcpy(&cmdBuffer[OMNIS_D0], &nIndex, 2);
    for (int i = 1; i<OMNIS_CHKSUM; i++) {
        cmdBuffer[OMNIS_CHKSUM] += cmdBuffer[i];
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:OMNIS_COMMAND_LEN cmdType:OmnisCmdType
                   returnDataLength:OMNIS_REPORT_LEN mcuBufferOffSetAt:0];
}



/////////////////////////////////////////////////////////////////////////////////
//
// APEX PARSER METHOD
//
/////////////////////////////////////////////////////////////////////////////////

#pragma mark OMNIS PARSER
- (BOOL)OmnisRecordEndCheck
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(16);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);

    
    if (inSrc[OMNIS_D0] == 0xFF && inSrc[OMNIS_D1] == 0xFF && inSrc[OMNIS_D2] == 0xFF && inSrc[OMNIS_D3] == 0xFF && inSrc[OMNIS_D4] == 0xFF && inSrc[OMNIS_D5] == 0xFF && inSrc[OMNIS_D6] == 0xFF && inSrc[OMNIS_D7] == 0xFF) {
        
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)OmnisParserCheck
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    _omnisYear = 0;
    _omnisMonth = 0;
    
    _omnisTotalTime = 0;
    
    _omnisDay = 0;
    _omnisHour = 0;
    _omnisMinute = 0;
    
    _omnisUnit = 0;
    _omnisValue = 0;
    
    _omnisTmpD1_Ctrl = 0;
//    _omnisTmpD1_Food = 0;
//    _omnisTmpD1_Events = 0;
    
    UInt16 omnisCheckSum;
    UInt16 omnisCheckSumTmp = 0;
    
//    UInt8 omnisTmpD1_Food = 0;
//    UInt8 omnisTmpD1_Events = 0;
    
    _omnisYear = inSrc[OMNIS_D0] & 0x7F;
    _omnisMonth = (inSrc[OMNIS_D1] & 0xF0) >> 4;
    
    _omnisTmpD1_Ctrl = inSrc[OMNIS_D1] & 0x01;
/*
    omnisTmpD1_Food = inSrc[OMNIS_D1] & 0x06;
    omnisTmpD1_Events = inSrc[OMNIS_D1] & 0x08;
    
    
    omnisTmpD1_Food = omnisTmpD1_Food >> 1;
    omnisTmpD1_Events = omnisTmpD1_Events >> 3;
*/
    memcpy(&_omnisTotalTime, &inSrc[OMNIS_D2], 2);
    
    _omnisDay = _omnisTotalTime & 0x1F;
    _omnisHour = (_omnisTotalTime & 0x3E0) >> 5;
    _omnisMinute = (_omnisTotalTime & 0xFC00) >> 10;
#ifdef DEBUG_OMNIS
    DLog(@"the year %d, mon %d, day %d, hour %d, min %d", _omnisYear, _omnisMonth, _omnisDay, _omnisHour, _omnisMinute);
#endif
    
    if (inSrc[OMNIS_D0] & MGDL_FLAG) {
        _omnisUnit = 1;
#ifdef DEBUG_OMNIS
        DLog(@"APEX BIO - DEBUG MGDL");
#endif
        
    }else{
        _omnisUnit = 0;
#ifdef DEBUG_OMNIS
        DLog(@"APEX BIO - DEBUG MMOLL");
#endif
    }
    
    memcpy(&_omnisValue, &inSrc[OMNIS_D4], 2);
    memcpy(&omnisCheckSum, &inSrc[OMNIS_D6], 2);
#ifdef DEBUG_OMNIS
    if (_omnisTmpD1_Ctrl > 0) {
        DLog(@"CTRL_SOLUTION ");
    }
#endif
    omnisCheckSumTmp = _omnisYear + _omnisMonth + _omnisDay + _omnisHour + _omnisMinute + _omnisUnit + _omnisValue + _omnisTmpD1_Ctrl;
    
    
    _omnisYear += 2000;
    
#ifdef DEBUG_OMNIS
    DLog(@"APEX - HT-LIKE CHECKING ...  %04X", GLUCOSURE_HT_LIKE);
#endif
    if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == GLUCOSURE_HT_LIKE) {
#ifdef DEBUG_OMNIS
        DLog(@"APEX - HT-LIKE");
#endif
        _omnisTmpD1_Food = inSrc[OMNIS_D1] & 0x06;
        _omnisTmpD1_Events = inSrc[OMNIS_D1] & 0x08;
        
        
        _omnisTmpD1_Food = _omnisTmpD1_Food >> 1;
        _omnisTmpD1_Events = _omnisTmpD1_Events >> 3;
        
        
        omnisCheckSumTmp += (_omnisTmpD1_Food + _omnisTmpD1_Events);
    }
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_OMNIS YES the check sum is %04X, %04X", omnisCheckSum, omnisCheckSumTmp);
#endif
    if (omnisCheckSum == omnisCheckSumTmp || omnisCheckSum == omnisCheckSumTmp - 1) {
#ifdef DEBUG_OMNIS
        for (int i=0; i < length; i++) {
            DLog(@"DEBUG_RECORD YES INDEX %d, and value %02X OK ", i, inSrc[i]);
        }
#endif
//        _omnisYear += 2000;
        return YES;
    }else{
#ifdef DEBUG_OMNIS
        for (int i=0; i < length; i++) {
            DLog(@"DEBUG_RECORD NO INDEX %d, and value %02X FAIL ", i, inSrc[i]);
        }
#endif
        return NO;
        // for TEST
//        return YES;
    }

}



#pragma mark OMNIS PARSER - CHECK
- (BOOL)OmnisEVOParserCheck
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 omnisYear;
    UInt8 omnisMonth;
    
    UInt16 omnisTotalTime;
    
    UInt8 omnisDay;
    
    UInt8 omnisHour;
    UInt8 omnisMinute;
    
    UInt8 omnisUnit;
    UInt8 omnisCtrlSolution;
    
    
    UInt16 omnisValue = 0;
    UInt16 omnisCheckSum;
    UInt16 omnisCheckSumBy;
    
    omnisYear = ((recordData[OMNIS_D5] & 0x7E)>>1);// + 2000;
    
    memcpy(&omnisTotalTime, &recordData[OMNIS_D4], 2);
    omnisMonth = (omnisTotalTime & 0x01E0) >> 5;
    
    omnisDay = recordData[OMNIS_D4] & 0x1F ;
    
    omnisHour = (recordData[OMNIS_D1] & 0x7C) >> 2;
    omnisMinute = (recordData[OMNIS_D3] & 0xFC) >> 2;
    
    
    if (recordData[OMNIS_D1] & MGDL_FLAG) {
        omnisUnit = 1;
    }else{
        omnisUnit = 0;
    }
    
    if (recordData[OMNIS_D5] & EVO_CTRL_FLAG) {
        omnisCtrlSolution = 1;
    }else{
        omnisCtrlSolution = 0;
    }
    

    memcpy(&omnisCheckSum, &recordData[OMNIS_D0], 2);
    omnisCheckSum &= 0x3FF;
    //
    memcpy(&omnisValue, &recordData[OMNIS_D2], 2);
    omnisValue &= 0x3FF;
    
    if (omnisCtrlSolution > 0) {
        return NO;
    }
    
    omnisCheckSumBy = omnisYear + omnisMonth + omnisDay + omnisHour + omnisMinute + omnisUnit + omnisValue  + omnisCtrlSolution;
    
#ifdef DEBUG_OMNIS
    DLog(@"the check sum %04X, %04X %d, %04X", omnisCheckSumBy, omnisCheckSum, omnisValue, omnisValue);
#endif
    if (omnisCheckSum == omnisCheckSumBy) {
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_OMNIS YES EVO the check sum is %04X, %04X", omnisCheckSum, omnisCheckSumBy);
#endif
        return YES;
    }else{
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_OMNIS EVO NO the check sum is %04X, %04X", omnisCheckSum, omnisCheckSumBy);
#endif
        return NO;
//        return YES; // for TEST
    }
}

#pragma mark OMNIS PARSER - SERIAL NUMBER
- (NSString *)OmnisSNParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);

    Byte tmp[9] = {0};
    NSString *string;
    
    for (int i = OMNIS_D0; i<OMNIS_CHKSUM; i++) {
        tmp[i-OMNIS_D0] = recordData[OMNIS_REPORT_LEN-i];
    }
    string = [NSString stringWithUTF8String:(const char *)tmp];
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_OMNIS the Omnis serial number is %@", string);
#endif
    if (!string) {
        string = @"";
    }
    return string;
}

#pragma mark OMNIS PARSER - CURRENT TIME
- (NSString *)OmnisCurrentTimeParser
{

    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    NSString *dateTimeString;
    UInt16 ominsYear;
    UInt8 ominsMonth;
    
    UInt16 ominsTotalTime;
    
    UInt8 ominsDay;
    
    UInt8 ominsHour;
    UInt8 ominsMinute;
    
    ominsYear = (recordData[OMNIS_D0] & 0x7F) + 2000;
    ominsMonth = recordData[OMNIS_D1] & 0x0F;
    
    memcpy(&ominsTotalTime, &recordData[OMNIS_D2], 2);
    
    ominsDay = ominsTotalTime & 0x1F ;
    ominsHour = (ominsTotalTime & 0x3E0) >> 5;
    ominsMinute = (ominsTotalTime & 0xFC00) >> 10;
    
    dateTimeString = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",ominsYear, ominsMonth, ominsDay, ominsHour, ominsMinute];
    
    return dateTimeString;
}

#pragma mark OMNIS PARSER - EMBRACE
- (H2BgRecord *)OmnisDateTimeValueParserEmbrace//:(UInt16)index
{
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_EMBRACE DID USE THIS METHOD");
#endif
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *omnisRecord;
    omnisRecord = [[H2BgRecord alloc] init];
    
    if ([self OmnisRecordEndCheck]) {
        omnisRecord.bgMealFlag = @"E"; // End of Record
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_EMBRACE DID GET ENDING ...");
#endif
        return omnisRecord;
    }
    
    if ([self OmnisParserCheck]) {
        if (_omnisTmpD1_Ctrl) {
            omnisRecord.bgMealFlag = @"C"; // Control solution data
            return omnisRecord;
        }

        if (_omnisUnit) {
#ifdef DEBUG_OMNIS
            DLog(@"APEX UINT -- MGDL");
#endif
            omnisRecord.bgUnit = BG_UNIT;
            omnisRecord.bgValue_mg = _omnisValue;
        }else{
#ifdef DEBUG_OMNIS
            DLog(@"APEX UINT -- MMOLL");
#endif
            omnisRecord.bgUnit = BG_UNIT_EX;
            omnisRecord.bgValue_mmol = (float)_omnisValue/10;
            omnisRecord.bgValue_mg = 0;
        }
    }else{
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_EMBRACE DID GET FAIL ...");
#endif
        omnisRecord.bgMealFlag = @"F"; // Fail, Meter not match
        return omnisRecord;
    }
    
    
    
    if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == GLUCOSURE_HT_LIKE) {
/*
        _omnisTmpD1_Food = recordData[OMNIS_D1] & 0x06;
        _omnisTmpD1_Events = recordData[OMNIS_D1] & 0x08;
        
        
        _omnisTmpD1_Food = _omnisTmpD1_Food >> 1;
        _omnisTmpD1_Events = _omnisTmpD1_Events >> 3;
*/
        switch (_omnisTmpD1_Food) {
            case 0:
            default:
                omnisRecord.bgMealFlag = @"N";
                break;
            case 1:
                omnisRecord.bgMealFlag = @"B";
                break;
            case 2:
                omnisRecord.bgMealFlag = @"A";
                break;
        }
    }else{
        omnisRecord.bgMealFlag = @"N";
    }
    
    omnisRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",_omnisYear, _omnisMonth, _omnisDay, _omnisHour, _omnisMinute];
    
    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:omnisRecord.bgDateTime]) {
        omnisRecord.bgMealFlag = @"C";
    }
    
    return omnisRecord;
}


- (NSMutableArray *)OmnisDateTimeValueParserEmbraceAll
{
#ifdef DEBUG_OMNIS
    DLog(@"CALL OMNIS DATE TIME VALUE PARSER %d  -- ALL -- OVER FLOW", [H2AudioAndBleSync sharedInstance].dataLength);
#endif
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    NSMutableArray *valueDateTimeArray = [[NSMutableArray alloc] init];
    H2BgRecord *tmpRecordInfo = [[H2BgRecord alloc] init];

#ifdef DEBUG_OMNIS
    int srcAddr = 0;
#endif
    int recordCounter = 0;
    
    
    // cheching data Length
    if (length % OMNIS_REPORT_LEN) {
        tmpRecordInfo.bgMealFlag = @"E";
        [valueDateTimeArray addObject:tmpRecordInfo];
        return valueDateTimeArray;
    }
    
#ifdef DEBUG_OMNIS
    DLog(@"EMBRACE - PARSER ALL");
#endif
    // Parser every Record
    do {
        [H2AudioAndBleSync sharedInstance].dataLength = OMNIS_REPORT_LEN;
        memcpy([H2AudioAndBleSync sharedInstance].dataBuffer, &recordData[recordCounter * OMNIS_REPORT_LEN], OMNIS_REPORT_LEN);
        
        tmpRecordInfo = [self OmnisDateTimeValueParser:0];
        [valueDateTimeArray addObject:tmpRecordInfo];

        if ([tmpRecordInfo.bgMealFlag isEqualToString:@"E"] || [tmpRecordInfo.bgMealFlag isEqualToString:@"F"]) {
            break;
        }
        if ([tmpRecordInfo.bgMealFlag isEqualToString:@"C"]) {
            [valueDateTimeArray removeLastObject];
        }
        recordCounter++;

    } while (recordCounter < length/OMNIS_REPORT_LEN);
    
#ifdef DEBUG_OMNIS
    DLog(@"THE CURRENT ADDRESS %d  -- END ---", srcAddr);
#endif
    return valueDateTimeArray;
}

#pragma mark OMNIS PARSER

- (H2BgRecord *)OmnisDateTimeValueParser:(UInt16)index
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
#ifdef DEBUG_OMNIS
    DLog(@"CALL OMNIS DATE TIME VALUE PARSER");
#endif
    H2BgRecord *omnisRecord = [[H2BgRecord alloc] init];
    
    if ([self OmnisRecordEndCheck]) {
        omnisRecord.bgMealFlag = @"E"; // End of Record
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_EMBRACE DID GET ENDING ALL END...");
#endif
        return omnisRecord;
    }
    
    UInt16 omnisYear;
    UInt8 omnisMonth;
    
    UInt16 omnisTotalTime;
    
    UInt8 omnisDay;
    
    UInt8 omnisHour;
    UInt8 omnisMinute;
    
    UInt8 omnisUnit;
    UInt8 omnisCtrlSolution;
    
    UInt16 omnisValue;
    UInt16 omnisCheckSum;

    omnisYear = inSrc[OMNIS_D0] & 0x7F;
    omnisMonth = (inSrc[OMNIS_D1] & 0xF0) >> 4;
    
    memcpy(&omnisTotalTime, &inSrc[OMNIS_D2], 2);
    
    omnisDay = omnisTotalTime & 0x1F;
    omnisHour = (omnisTotalTime & 0x3E0) >> 5;
    omnisMinute = (omnisTotalTime & 0xFC00) >> 10;
    
    memcpy(&omnisValue, &inSrc[OMNIS_D4], 2);
    if (inSrc[OMNIS_D0] & MGDL_FLAG) {
        omnisRecord.bgUnit = BG_UNIT;
        omnisRecord.bgValue_mg = omnisValue;
        omnisUnit = 1;
    }else{
        omnisRecord.bgUnit = BG_UNIT_EX;
        omnisRecord.bgValue_mmol = (float)omnisValue/10;
        omnisRecord.bgValue_mg = 0;
        omnisUnit = 0;
    }
    
    if (inSrc[OMNIS_D1] & EMBRACE_CTRL_FLAG) {
        omnisRecord.bgMealFlag = @"C";
#ifdef DEBUG_OMNIS
        DLog(@"EMBRACE CONTROL SOLUTION");
#endif
        omnisCtrlSolution = 1;
        return omnisRecord;
    }else{
        omnisRecord.bgMealFlag = @"N";
        omnisCtrlSolution = 0;
    }
    
    // Internal CheckSum
    memcpy(&omnisCheckSum, &inSrc[OMNIS_D6], 2);
#ifdef DEBUG_OMNIS
#if 0
    DLog(@"YEAR        %02X", omnisYear);
    DLog(@"MONTH   %02X", omnisMonth);
    DLog(@"DAY             %02X", omnisDay);
    
    DLog(@"HOUR %02X", omnisHour);
    DLog(@"MIN %02X", omnisMinute);
    
    DLog(@"UNIT %02X", omnisUnit);
    DLog(@"SOLUTION %02X", omnisCtrlSolution);
    
    DLog(@"VALUE %02X", omnisValue);
   
    for (int i=0; i<11; i++) {
        DLog(@"EM-SRC %d, %02X", i, inSrc[i]);
    }
    DLog(@"CHECK SUM IS  %02X, %02X", omnisCheckSum, omnisYear + omnisMonth + omnisDay + omnisHour + omnisMinute + omnisUnit + omnisCtrlSolution + omnisValue);
#endif
#endif
    if (omnisCheckSum == (omnisYear + omnisMonth + omnisDay + omnisHour + omnisMinute + omnisUnit + omnisCtrlSolution + omnisValue)) {
        // Embrace
        omnisYear += 2000;
        
#ifdef DEBUG_OMNIS
        DLog(@"the year %d, mon %d, day %d, hour %d, min %d", omnisYear, omnisMonth, omnisDay, omnisHour, omnisMinute);
        DLog(@"The control solution %@", omnisRecord.bgMealFlag);
#endif
        
    }else{ // Fail
        omnisRecord.bgMealFlag = @"F";
        return omnisRecord;
    }
    
    omnisRecord.bgIndex = index;
    omnisRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",omnisYear, omnisMonth, omnisDay, omnisHour, omnisMinute];
    
    
    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:omnisRecord.bgDateTime]) {
        omnisRecord.bgMealFlag = @"C";
    }
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_OMNIS the OMNIS's unit %@ and index %d", omnisRecord.bgUnit, index);
    DLog(@"DEBUG_OMNIS NORMAL the value %003d and datetime %@", omnisRecord.bgValue_mg, omnisRecord.bgDateTime);
#endif
    return omnisRecord;
}



#pragma mark OMNIS PARSER - DATE TIME VALUE - EVO
- (H2BgRecord *)OmnisDateTimeValueParserEVO
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *omnisRecord;
    omnisRecord = [[H2BgRecord alloc] init];
    
    UInt16 omnisYear;
    UInt8 omnisMonth;
    
    UInt16 omnisTotalTime;
    
    UInt8 omnisDay;
    
    UInt8 omnisHour;
    UInt8 omnisMinute;
    
    UInt8 omnisUnit;
    UInt8 omnisCtrlSolution;
    
    UInt16 omnisValue;
    Byte omnisCheckSum = 0;
    
    if (recordData[OMNIS_D0] == APEXBIO_END && recordData[OMNIS_D1] == APEXBIO_END && recordData[OMNIS_D2] == APEXBIO_END && recordData[OMNIS_D3] == APEXBIO_END && recordData[OMNIS_D4] == APEXBIO_END && recordData[OMNIS_D5] == APEXBIO_END){
        // END
        omnisRecord.bgMealFlag = @"E";
        return omnisRecord;
    }
    
    omnisYear = ((recordData[OMNIS_D5] & 0x7E)>>1);
    
    memcpy(&omnisTotalTime, &recordData[OMNIS_D4], 2);
    omnisMonth = (omnisTotalTime & 0x01E0) >> 5;
    
    omnisDay = recordData[OMNIS_D4] & 0x1F ;
    
    omnisHour = (recordData[OMNIS_D1] & 0x7C) >> 2;
    omnisMinute = (recordData[OMNIS_D3] & 0xFC) >> 2;
    
    
    memcpy(&omnisValue, &recordData[OMNIS_D2], 2);
    omnisValue &= 0x3FF;
    
    if (recordData[OMNIS_D1] & MGDL_FLAG) {
        omnisRecord.bgUnit = BG_UNIT;
        omnisRecord.bgValue_mg = omnisValue;
        omnisUnit = 1;
    }else{
        omnisRecord.bgUnit = BG_UNIT_EX;
        omnisRecord.bgValue_mmol = (float)omnisValue/10;
        omnisRecord.bgValue_mg = 0;
        omnisUnit = 0;
    }
    
    if (recordData[OMNIS_D5] & EVO_CTRL_FLAG) {
        omnisRecord.bgMealFlag = @"C";
        omnisCtrlSolution = 1;
        return omnisRecord;
    }else{
        omnisRecord.bgMealFlag = @"N";
        omnisCtrlSolution = 0;
    }

    int idx = 0;
 
    Byte OriginalCheckSum = recordData[10];
    for (idx = 1; idx<10; idx++) {
        omnisCheckSum += recordData[idx];
    }

#ifdef DEBUG_OMNIS
    DLog(@"EVO ORIGINAL check sum VALUE IS %04X %04X %04X %04X", omnisCheckSum, recordData[1], recordData[10], OriginalCheckSum);
    DLog(@"EVO totally sum %04X", omnisCheckSum);
#endif

    if(omnisCheckSum == OriginalCheckSum){
        // EVO
        omnisYear += 2000;
 
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_OMNIS the omnis  middle and value is %02X, %04X",recordData[OMNIS_D3], (recordData[OMNIS_D3] & 0x03)* 256);
        DLog(@"DEBUG_OMNIS EVO the omnis  value is %d, %04X", omnisValue, omnisValue);
#endif
        
    }else{ // Fail
        omnisRecord.bgMealFlag = @"F";
        return omnisRecord;
    }

//    omnisRecord.bgMealFlag = @"C';
//    omnisRecord.bgIndex = index;
    omnisRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",omnisYear, omnisMonth, omnisDay, omnisHour, omnisMinute];
    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:omnisRecord.bgDateTime]) {
        omnisRecord.bgMealFlag = @"C";
    }
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_OMNIS the OMNIS's unit %@ ", omnisRecord.bgUnit);
    DLog(@"DEBUG_OMNIS EVO the value %003d and datetime %@", omnisRecord.bgValue_mg, omnisRecord.bgDateTime);
#endif
    return omnisRecord;
}


#pragma mark OMNIS PARSER - MODEL
- (H2BgRecord *)OmnisModelFormatParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *omnisRecord;
    omnisRecord = [[H2BgRecord alloc] init];
    
    UInt16 omnisYear;
    UInt8 omnisMonth;
    
    UInt16 omnisTotalTime;
    
    UInt8 omnisDay;
    
    UInt8 omnisHour;
    UInt8 omnisMinute;
    
    UInt8 omnisUnit;
    UInt8 omnisCtrlSolution;
    
    UInt16 omnisValue;
    UInt16 omnisCheckSum;
    UInt16 omnisCheckSumTmp;
    
    omnisYear = recordData[OMNIS_D0] & 0x7F;
    omnisMonth = (recordData[OMNIS_D1] & 0xF0) >> 4;
    
    memcpy(&omnisTotalTime, &recordData[OMNIS_D2], 2);
    
    omnisDay = omnisTotalTime & 0x1F;
    omnisHour = (omnisTotalTime & 0x3E0) >> 5;
    omnisMinute = (omnisTotalTime & 0xFC00) >> 10;
    
    
    if (recordData[OMNIS_D0] & MGDL_FLAG) {
        //omnisRecord.bgUnit = @"mg/dL";
        omnisUnit = 1;
    }else{
        omnisUnit = 0;
        //omnisRecord.bgUnit = @"mmol/L";
    }
    
    if (recordData[OMNIS_D1] & EMBRACE_CTRL_FLAG) {
        //omnisRecord.bgMealFlag = @"E';
        omnisCtrlSolution = 1;
    }else{
        //omnisRecord.bgMealFlag = @"N';
        omnisCtrlSolution = 0;
    }
    
    memcpy(&omnisCheckSum, &recordData[OMNIS_D6], 2);
    memcpy(&omnisValue, &recordData[OMNIS_D4], 2);
    
    omnisCheckSumTmp = omnisYear + omnisMonth + omnisDay + omnisHour + omnisMinute + omnisUnit + omnisValue + omnisCtrlSolution;
    
    if (([H2DataFlow sharedDataFlowInstance].equipUartProtocol & 0xFF) == GLUCOSURE_HT_LIKE) { // GLUCOSURE HT
        
        _omnisTmpD1_Food = recordData[OMNIS_D1] & 0x06;
        _omnisTmpD1_Events = recordData[OMNIS_D1] & 0x08;
        
        
        _omnisTmpD1_Food = _omnisTmpD1_Food >> 1;
        _omnisTmpD1_Events = _omnisTmpD1_Events >> 3;
        omnisCheckSumTmp += (_omnisTmpD1_Food + _omnisTmpD1_Events);
    }
    
    
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_OMNIS CHECK SUM IS TMP - %04X, SRC - %04X", omnisCheckSumTmp, omnisCheckSum);
#endif
    
    if (omnisCheckSum == omnisCheckSumTmp || omnisCheckSum == (omnisCheckSumTmp -1)) {
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_OMNIS CHECK SUM - YES VIVO");
#endif
        // Embrace, VIVO, G2, HT, GlucoreSure Voice
        omnisYear += 2000;
        
        if (recordData[OMNIS_D0] & MGDL_FLAG) {
            omnisRecord.bgValue_mg = omnisValue;
            omnisRecord.bgUnit = BG_UNIT;
        }else{
            omnisRecord.bgUnit = BG_UNIT_EX;
            omnisRecord.bgValue_mmol = (float)omnisValue/10;
            omnisRecord.bgValue_mg = 0;
        }
        
    }else{ // EVO
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_OMNIS CHECK SUM - NO EVO");
#endif
        omnisRecord.bgMealFlag = @"F";
        return omnisRecord;
    }
    
    omnisRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",omnisYear, omnisMonth, omnisDay, omnisHour, omnisMinute];
    
//    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:omnisRecord.bgDateTime]) {
//        omnisRecord.bgMealFlag = @"C';
//    }
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_OMNIS the OMNIS's unit %@ ", omnisRecord.bgUnit);
    DLog(@"DEBUG_OMNIS FORMAT the value %003d and datetime %@", omnisRecord.bgValue_mg, omnisRecord.bgDateTime);
#endif
    return omnisRecord;
}

#pragma mark OMNIS PARSER - MODEL EVO
- (H2BgRecord *)OmnisEVOModelFormatParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *omnisRecord;
    omnisRecord = [[H2BgRecord alloc] init];
    
    UInt16 omnisYear;
    UInt8 omnisMonth;
    
    UInt16 omnisTotalTime;
    
    UInt8 omnisDay;
    
    UInt8 omnisHour;
    UInt8 omnisMinute;
    
    UInt8 omnisUnit;
    UInt8 omnisCtrlSolution;
    
    UInt16 omnisMiddleValue;
    UInt16 omnisValue;
    UInt16 omnisCheckSum;
    
    omnisYear = ((recordData[OMNIS_D5] & 0x7E)>>1);
    
    memcpy(&omnisTotalTime, &recordData[OMNIS_D4], 2);
    omnisMonth = (omnisTotalTime & 0x01E0) >> 5;
    
    omnisDay = recordData[OMNIS_D4] & 0x1F ;
    
    omnisHour = (recordData[OMNIS_D1] & 0x7C) >> 2;
    omnisMinute = (recordData[OMNIS_D3] & 0xFC) >> 2;
    
    omnisMiddleValue = (recordData[OMNIS_D3] & 0x03)<<8;
    memcpy(&omnisValue, &recordData[OMNIS_D2], 2);
    omnisValue &= 0x3FF;
    
    
    if (recordData[OMNIS_D1] & MGDL_FLAG) {
        //omnisRecord.bgUnit = @"mg/dL";
        omnisUnit = 1;
    }else{
        omnisUnit = 0;
        //omnisRecord.bgUnit = @"mmol/L";
    }
    
    if (recordData[OMNIS_D5] & EVO_CTRL_FLAG) { //EMBRACE_CTRL_FLAG) {
        //omnisRecord.bgMealFlag = @"E';
        omnisCtrlSolution = 1;
    }else{
        //omnisRecord.bgMealFlag = @"N';
        omnisCtrlSolution = 0;
    }
/*
    //memcpy(&omnisCheckSum, &recordData[OMNIS_D6], 2);
    omnisCheckSum = (recordData[OMNIS_D1] & 0x03);
    omnisCheckSum = (omnisCheckSum < 8);
    omnisCheckSum += recordData[OMNIS_D0];
*/
    memcpy(&omnisCheckSum, &recordData[OMNIS_D0], 2);
    omnisCheckSum &= 0x3FF;
    
    
    if (omnisCheckSum == (omnisYear + omnisMonth + omnisDay + omnisHour + omnisMinute + omnisUnit + omnisCtrlSolution + omnisValue)) {
        // Embrace
        omnisYear += 2000;
        
        if (recordData[OMNIS_D1] & MGDL_FLAG) {
            omnisRecord.bgValue_mg = omnisValue;
            omnisRecord.bgUnit = BG_UNIT;
        }else{
            omnisRecord.bgUnit = BG_UNIT_EX;
            omnisRecord.bgValue_mmol = (float)omnisValue/10;
            omnisRecord.bgValue_mg = 0;
        }
/*
        if (recordData[OMNIS_D0] & MGDL_FLAG) {
            omnisRecord.bgValue_mg = omnisValue;
            omnisRecord.bgUnit = @"mg/dL";
        }else{
            omnisRecord.bgUnit = @"mmol/L";
            omnisRecord.bgValue_mmol = (float)omnisValue/10;
            omnisRecord.bgValue_mg = 0;
        }
*/
    }else{ // EVO
        omnisRecord.bgMealFlag = @"F";
        return omnisRecord;
/*
        omnisYear = ((recordData[OMNIS_D5] & 0x7E)>>1) + 2000;
        
        memcpy(&omnisTotalTime, &recordData[OMNIS_D4], 2);
        omnisMonth = (omnisTotalTime & 0x01E0) >> 5;
        
        omnisDay = recordData[OMNIS_D4] & 0x1F ;
        
        omnisHour = (recordData[OMNIS_D1] & 0x7C) >> 2;
        omnisMinute = (recordData[OMNIS_D3] & 0xFC) >> 2;
        
        omnisMiddleValue = (recordData[OMNIS_D3] & 0x03)<<8;
        memcpy(&omnisValue, &recordData[OMNIS_D2], 2);
        omnisValue &= 0x3FF;
        
        if (recordData[OMNIS_D1] & MGDL_FLAG) {
            omnisRecord.bgValue_mg = omnisValue;
            omnisRecord.bgUnit = @"mg/dL";
        }else{
            omnisRecord.bgUnit = @"mmol/L";
            omnisRecord.bgValue_mmol = (float)omnisValue/10;
            omnisRecord.bgValue_mg = 0;
        }
        
        
#ifdef DEBUG_OMNIS
        DLog(@"DEBUG_OMNIS the omnis  middle and value is %04X %02X, %04X", omnisMiddleValue, recordData[OMNIS_D3], (recordData[OMNIS_D3] & 0x03)* 256);
        DLog(@"DEBUG_OMNIS the omnis  value is %d, %04X", omnisValue, omnisValue);
#endif
*/
    }
    
    omnisRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",omnisYear, omnisMonth, omnisDay, omnisHour, omnisMinute];
//    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:omnisRecord.bgDateTime]) {
//        omnisRecord.bgMealFlag = @"C';
//    }
#ifdef DEBUG_OMNIS
    DLog(@"DEBUG_OMNIS the OMNIS's unit %@", omnisRecord.bgUnit);
    DLog(@"DEBUG_OMNIS EVO_FMT the value %003d and datetime %@", omnisRecord.bgValue_mg, omnisRecord.bgDateTime);
#endif
    return omnisRecord;
}

- (void)OmnisInitExt:(UInt16)currentMeter
{
    UInt16 cmdTypeId = (currentMeter<<4) + METHOD_INIT;
    Byte cmdBuffer[11] = {0};
    
    cmdBuffer[0] = STARTBYTE_PC;
    cmdBuffer[1] = OP_INIT;
    
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:OMNIS_COMMAND_LEN cmdType:cmdTypeId
                   returnDataLength:OMNIS_REPORT_LEN mcuBufferOffSetAt:0];
    
}





+ (Omnis *)sharedInstance
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




