//
//  ROConfirm.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/28.
//
//


#import "H2AudioFacade.h"
#import "ROConfirm.h"
#import "H2DebugHeader.h"
#import "h2CmdInfo.h"
#import "H2Config.h"

#import "H2DataFlow.h"

#import "H2Records.h"

#define CONST0X30                   0x30
#define RELION_RESEND_TIME          2
UInt8 gConfirmCmdIdx;
@implementation ReliOnConfirm
{
}


- (id)init
{
    if (self = [super init]) {
        gConfirmCmdIdx = 0;
        
        _reliOnCmdBuffer = (Byte *)malloc(48);
        _reliOnCmdLength = 0;
        _reliOnCmdType = 0;
        
        _reliOnCmdIndex = 0;
        _reliOnDataStart = NO;
    }
    
    return self;
}

+ (ReliOnConfirm *)sharedInstance
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


unsigned char confirmCmdInit[] = {
#if 1
    0x06
#else
    'R', '|'
    , 'C', '|'
#endif
};
unsigned char confirmCmdBrand[] = {
    0x92, 0x05
};

unsigned char confirmCmdModel[] = {
    'R', '|'
    , 'C', '|'
};
unsigned char confirmCmdSerialNumber[] = {
    'R', '|'
    , 'M', '|'
};
//unsigned char confirmCmdDate[] = {
//    'R', '|'
//    , 'N', '|'
//    , '0', '0', 'a', '|'
//};

unsigned char confirmCmdRecord[] = {
    'R', '|'
    , 'N', '|'
    , '0', '0', '0', '|'
};

unsigned char confirmCmdXXX[] = {
    '0', '0', '0', '0',
    '0', '0', '0', '0',
    '0','0'
};




#pragma mark -
#pragma mark GLUCOCARD VITAL COMMAND
- (void)reliOnConfirmResetCounter
{
    gConfirmCmdIdx = 0;
}
- (void)reliOnConfirmSetCounter:(UInt8)cmdIndex
{
   gConfirmCmdIdx = cmdIndex;
}

- (UInt8)reliOnConfirmGetCounter
{
    return gConfirmCmdIdx;
}


- (void)ReliOnCommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    _reliOnCmdIndex = 0;
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = 2;
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
//    [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
    
    memcpy(_reliOnCmdBuffer, confirmCmdXXX, sizeof(confirmCmdXXX));
    
    switch (cmdMethod) {
        case METHOD_INIT:
            _reliOnCmdLength = sizeof(confirmCmdInit);
            _reliOnCmdType = (currentMeter<<4) + METHOD_INIT;
            memcpy(_reliOnCmdBuffer, confirmCmdInit, _reliOnCmdLength);
            break;
            
            
        case METHOD_BRAND:
            _reliOnCmdLength = sizeof(confirmCmdBrand);
            _reliOnCmdType = (currentMeter<<4) + METHOD_BRAND;
            memcpy(_reliOnCmdBuffer, confirmCmdBrand, _reliOnCmdLength);
            break;
            
        case METHOD_MODEL:
            _reliOnCmdLength = sizeof(confirmCmdModel);
            _reliOnCmdType = (currentMeter<<4) + METHOD_MODEL;
            memcpy(_reliOnCmdBuffer, confirmCmdModel, _reliOnCmdLength);
            break;
            
        case METHOD_SN:
            _reliOnCmdLength = sizeof(confirmCmdSerialNumber);
            _reliOnCmdType = (currentMeter<<4) + METHOD_SN;
            memcpy(_reliOnCmdBuffer, confirmCmdSerialNumber, _reliOnCmdLength);
            break;
            
        default:
            break;
    }
    
    [self ReliOnCommandLoop];
    
//    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = NO;
}




- (void)ReliOnCommandLoop
{
    
    DLog(@"RELION COMMAND LOOP ?????? %d", _reliOnCmdIndex);
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:&_reliOnCmdBuffer[_reliOnCmdIndex] withCmdLength:1 cmdType:_reliOnCmdType returnDataLength:0 mcuBufferOffSetAt:0];
    
    _reliOnDataStart = NO;
    _reliOnCmdIndex++;
    if (_reliOnCmdIndex >= _reliOnCmdLength) {
        DLog(@"RELION COMMAND -- %d and %d", _reliOnCmdIndex, _reliOnCmdLength);
        _reliOnDataStart = YES;
    }else{
        DLog(@"RECORD COMMAND -- LOOP");
    }
}



- (void)ReliOnReadRecord:(UInt16)nIndex
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdCycle = 2;
    [H2AudioAndBleResendCfg sharedInstance].resendMeterCmdInterval = 5.0f;
    [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
//    [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
    
    _reliOnCmdIndex = 0;
    _reliOnCmdType = (currentMeter<<4) + METHOD_RECORD;
    
    confirmCmdRecord[4] = [self numericToChar:(unsigned char)(nIndex & 0xF00)>>8];
    confirmCmdRecord[5] = [self numericToChar:(unsigned char)(nIndex & 0xF0)>>4];
    confirmCmdRecord[6] = [self numericToChar:(unsigned char)(nIndex & 0xF)];

    _reliOnCmdLength = sizeof(confirmCmdRecord);
    
    memcpy(_reliOnCmdBuffer, confirmCmdRecord, _reliOnCmdLength);
    
    [self ReliOnCommandLoop];

}



- (unsigned char)numericToChar:(unsigned char)num
{
    unsigned char ch;
    switch (num) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
            ch = num+0x30;
            break;
        case 0x0A: ch = 'A'; break;
        case 0x0B: ch = 'B'; break;
        case 0x0C: ch = 'C'; break;
        case 0x0D: ch = 'D'; break;
        case 0x0E: ch = 'E'; break;
        case 0x0F: ch = 'F'; break;
            
        default:
            ch = '0';
            break;
    }
    return ch;
}


/////////////////////////////////////////////////////

#pragma mark -
#pragma mark PARSER METHOD FOR RELION

- (UInt16)reliOnNumberOfParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    UInt16 recordsNumber = 0;
    srcData = (Byte *)malloc(32);
    
    if (length >= 8 && length<32) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
        for (int i=0; i<length; i++) {
            DLog(@"RELION DATA %d, %02X", i, srcData[i]);
        }
        if (srcData[0] == 'D') {
            UInt8 idx = 0;
            while (idx < length) {
                if (srcData[idx] == '|') {
                    break;
                }
                idx++;
            }
            //
            DLog(@"IDX VALUE IS %d AND %02X, %02X, %02X, %02X,", idx, srcData[idx], srcData[idx+1], srcData[idx+2], srcData[idx+3]);
            
            recordsNumber = (srcData[idx+1] & 0x0F) *100 + (srcData[idx+2] & 0x0F) * 10 + (srcData[idx+3] & 0x0F);
         }
    }
    
    return recordsNumber;
    
/*
    2017-01-11 15:48:17.288974 EMT[1135:663635] yes addr = 0 data = 44
    2017-01-11 15:48:17.311809 EMT[1135:663635] yes addr = 1 data = 7C
    2017-01-11 15:48:17.312074 EMT[1135:663635] yes addr = 2 data = 30
    2017-01-11 15:48:17.312241 EMT[1135:663635] yes addr = 3 data = 33
    2017-01-11 15:48:17.334872 EMT[1135:663635] yes addr = 4 data = 31
    2017-01-11 15:48:17.335097 EMT[1135:663635] yes addr = 5 data = 7C
    2017-01-11 15:48:17.358084 EMT[1135:663635] yes addr = 6 data = 0D
    2017-01-11 15:48:17.358304 EMT[1135:663635] yes addr = 7 data = 0A
*/
}

- (H2MeterSystemInfo *)reliOnConfirmCurrentTimeParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2MeterSystemInfo *reliOnConfirmSystemInfo;
    reliOnConfirmSystemInfo = [[H2MeterSystemInfo alloc] init];
    UInt8 idx=0, lastIdx=0;
    char date[12] = {0};
    
    UInt16 reliOnYear;
    UInt8 reliOnMonth;
    UInt8 reliOnDay;
    
    UInt8 reliOnHour;
    UInt8 reliOnMinute;
    
    char tmpBrand[16] = {0};
    char tmpModel[16] = {0};
    char tmpSerialNumber[16] = {0};
    
    char unit[4] = {0};
    
    
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    
    memcpy(date, &recordData[idx-12], 12); // get date and time
    reliOnYear = (date[0]-CONST0X30)*1000 + (date[1]-CONST0X30)*100 + (date[2]-CONST0X30)*10 + date[3]-CONST0X30;
    reliOnMonth = (date[4]-CONST0X30)*10 + date[5]-CONST0X30;
    reliOnDay = (date[6]-CONST0X30 )*10 + date[7]-CONST0X30;
    
    reliOnHour = (date[8]-CONST0X30)*10 + date[9]-CONST0X30;
    reliOnMinute = (date[10]-CONST0X30)*10 + date[11]-CONST0X30;
    
    memcpy(unit, &recordData[idx-12-3], 3); // get unit
#ifdef DEBUG_RELION
    DLog(@"DEBUG_RELION the unit is %02X, %02X, %02X, %02X ----", unit[0], unit[1], unit[2], unit[3]);
#endif
    if (unit[1] == '0') {
        reliOnConfirmSystemInfo.smMmolUnitFlag = YES; //
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"meter_unit"];
    }else{
        reliOnConfirmSystemInfo.smMmolUnitFlag = NO;
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"meter_unit"];
    }
    
    reliOnConfirmSystemInfo.smCurrentDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",reliOnYear, reliOnMonth, reliOnDay, reliOnHour, reliOnMinute];
    
    // get brand and model
    idx =0;

    do {                                    // 1
        if (recordData[idx] == '|') {
            lastIdx = idx;
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    
    idx++;
    do {                                    // 2
        if (recordData[idx] == '|') {
            lastIdx = idx;
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    
    idx++;
    do {                                    // 3
        if (recordData[idx] == '|') {
            lastIdx = idx;
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    
    idx++;
    do {                                    // 4
        if (recordData[idx] == '|') {
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    if (idx-lastIdx < 10) {
        memcpy(tmpBrand, &recordData[lastIdx+1], idx-lastIdx-1);
    }
#ifdef DEBUG_RELION
    for (int i = 0; i < idx-lastIdx; i++) {
        DLog(@"DEBUG_RELION A the index is %d %02X", i, tmpBrand[i]);
    }
#endif
    lastIdx = idx;
    idx++;
    do {                                    // 5
        if (recordData[idx] == '|') {
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    if (idx-lastIdx > 20) {
        memcpy(tmpModel, &recordData[lastIdx+1], 7);
        memcpy(tmpSerialNumber, &recordData[idx-12], 12);
    }
   
#ifdef DEBUG_RELION
    for (int i = 0; i < 7; i++) {
        DLog(@"DEBUG_RELION B the index is %d %02X", i, tmpModel[i]);
    }
    for (int i = 0; i < 12; i++) {
        DLog(@"DEBUG_RELION C the index is %d %02X", i, tmpSerialNumber[i]);
    }
#endif
    
    reliOnConfirmSystemInfo.smModelName = [NSString stringWithUTF8String:(const char *)tmpModel];
    reliOnConfirmSystemInfo.smSerialNumber = [NSString stringWithUTF8String:(const char *)tmpSerialNumber];
    
    
    return reliOnConfirmSystemInfo;
}

- (NSString *)reliOnConfirmModelParser
{

    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    UInt8 idx=0;
    unsigned int tmpModel = 0;
    unsigned char tmp[3] = {0};
    NSString *string;
    do {
        if (recordData[idx] == '|') {
            memcpy(tmp, &recordData[idx+1], 2);
            string = [NSString stringWithUTF8String:(const char *)tmp];
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    
    tmpModel = [string intValue];
#ifdef DEBUG_RELION
    DLog(@"DEBUG_RELION the model is %02d", tmpModel);
#endif
    
    return string;
}

- (NSString *)reliOnConfirmSNParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    unsigned int tmpModel = 0;
    unsigned char tmp[4] = {0};
    NSString *string;
    
    do {
        if (recordData[idx] == '|') {
            memcpy(tmp, &recordData[idx+1], 3);
            string = [NSString stringWithUTF8String:(const char *)tmp];
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    
    tmpModel = [string intValue];
#ifdef DEBUG_RELION
    DLog(@"DEBUG_RELION the SN is %02d", tmpModel);
#endif
    return string;
}
#define RO_VALUE_AT             0
#define RO_MIN_AT               2
#define RO_HR_AT                3
#define RO_DAY_AT               4
#define RO_MON_AT               5
#define RO_YEAR_AT              6
#define RO_FLAG              7

- (H2BgRecord *)reliOnConfirmDateTimeValueParser//:(UInt16)index
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *reliOnConfirmRecord;
    reliOnConfirmRecord = [[H2BgRecord alloc] init];
    UInt8 idx=0;
    unsigned int dateTimeValue[8] = {0};
    unsigned char tmp[3] = {0};
    NSString *string;
    NSScanner *scanner;
    UInt16 value = 0;

    do {
        if (recordData[idx] == '|') {
            for (int i = 0; i < 8; i++) {
                memcpy(tmp, &recordData[idx+2*i+1], 2);
                string = [NSString stringWithUTF8String:(const char *)tmp];
                if (i == 0) {
                    scanner = [NSScanner scannerWithString:string];
                    [scanner setScanLocation:0];
                    [scanner scanHexInt:&dateTimeValue[i]];
                }else{
                    dateTimeValue[i] = [string intValue];
                }
            }
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    
    reliOnConfirmRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",dateTimeValue[RO_YEAR_AT]+2000, dateTimeValue[RO_MON_AT], dateTimeValue[RO_DAY_AT], dateTimeValue[RO_HR_AT], dateTimeValue[RO_MIN_AT]];
    
    
    value = dateTimeValue[RO_VALUE_AT];
    
    reliOnConfirmRecord.bgUnit = @"N";
    reliOnConfirmRecord.bgValue_mg = value;
    reliOnConfirmRecord.bgValue_mmol = 0.0;

    
    
    
#ifdef DEBUG_RELION
    DLog(@"DEBUG_RELION the value %003d and datetime %@", reliOnConfirmRecord.bgValue_mg, reliOnConfirmRecord.bgDateTime);
#endif
    if (dateTimeValue[RO_FLAG] & 0x02) {
        reliOnConfirmRecord.bgMealFlag = @"A";
    }else if (dateTimeValue[RO_FLAG] & 0x04){
        reliOnConfirmRecord.bgMealFlag = @"C";
    }else{
        reliOnConfirmRecord.bgMealFlag = @"N";
    }
    
    if (![reliOnConfirmRecord.bgMealFlag isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:reliOnConfirmRecord.bgDateTime]) {
            reliOnConfirmRecord.bgMealFlag = @"C";
        }
    }
    
    return reliOnConfirmRecord;
}


@end
