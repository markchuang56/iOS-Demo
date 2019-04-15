//
//  JJBayerContour.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//

#define CONST0X30               0x30
#define BRANDNAME_LEN           20
#define SERIALNUMBER_LEN        12

#import "H2AudioFacade.h"
#import "JJBayerContour.h"

#import "H2DebugHeader.h"
#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"

@implementation JJBayerContour
{
}


- (id)init
{
    if (self = [super init]) {
        _didSkipMeterInfo = NO;
        _goToNextYearStage = NO;
        _isSyncSecondStageRunning = NO;
        
        _isSyncSecondStageDidRemoved = NO;
        _didBayerSyncRunning = NO;
        _didBayerMmolUnit = NO;
    }
    return self;
}

+ (JJBayerContour *)sharedInstance
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
- (void)jjBayerCommandGeneral:(UInt16)cmdMethod
{
#ifdef DEBUG_BAYER
    DLog(@"BAYER_DEBUG call this function ....");
#endif
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    switch (cmdMethod) {
        case METHOD_INIT:
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            cmdBuffer[0] = 0x06;
            break;
            
        case METHOD_RECORD:
            cmdTypeId = (currentMeter<<4) + METHOD_RECORD;
            cmdBuffer[0] = 0x06;
            break;
            
        case METHOD_END:
            cmdTypeId = (currentMeter<<4) + METHOD_END;
            cmdBuffer[0] = 0x15;
            break;
            
        case METHOD_4:
            cmdTypeId = (currentMeter<<4) + METHOD_4;
            cmdBuffer[0] = 0x06;
            break;
            
        case METHOD_VERSION:
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            cmdBuffer[0] = 0x06;
            break;
            
        default:
            break;
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:1 cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
    
}





- (H2MeterSystemInfo *)jjContourCurrentTimeParserEx
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2MeterSystemInfo *jjContourSystemInfo;
    jjContourSystemInfo = [[H2MeterSystemInfo alloc] init];
    UInt8 idx=0;
    char date[12] = {0};
    
    char serialNumber[13] = {0};
    
    UInt16 jjYear;
    UInt8 jjMonth;
    UInt8 jjDay;
    
    UInt8 jjHour;
    UInt8 jjMinute;
    
    char tmp[12] = {0};
    char tmpContur[12] = {0};
    char tmpBrand[48] = {0};

    
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    
    memcpy(date, &recordData[idx-12], 12); // get time
    jjYear = (date[0]-CONST0X30)*1000 + (date[1]-CONST0X30)*100 + (date[2]-CONST0X30)*10 + date[3]-CONST0X30;
    jjMonth = (date[4]-CONST0X30)*10 + date[5]-CONST0X30;
    jjDay = (date[6]-CONST0X30 )*10 + date[7]-CONST0X30;
    
    jjHour = (date[8]-CONST0X30)*10 + date[9]-CONST0X30;
    jjMinute = (date[10]-CONST0X30)*10 + date[11]-CONST0X30;
    

    
    jjContourSystemInfo.smCurrentDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",jjYear, jjMonth, jjDay, jjHour, jjMinute];
    
    // get brand and model
    idx =0;
    UInt8 brandLen = BRANDNAME_LEN;
    BOOL modelFail = YES;
    do {
        memcpy(tmp, &recordData[idx], 5);
        memcpy(tmpContur, &recordData[idx], 7);
        NSString *string = [NSString stringWithUTF8String:(const char *)tmp];
        NSString *stringEx = [NSString stringWithUTF8String:(const char *)tmpContur];
        if ([string  isEqual: @"Bayer"] || [stringEx  isEqual: @"Contour"]) {
            if ([stringEx  isEqual: @"Contour"]) {
                brandLen += 2;
            }
            memcpy(tmpBrand, &recordData[idx], brandLen); // get brand name
            memcpy(serialNumber, &recordData[idx+brandLen+1], SERIALNUMBER_LEN);
            if (serialNumber[SERIALNUMBER_LEN-1] == '|') {
                memcpy(serialNumber, &recordData[idx+brandLen], SERIALNUMBER_LEN);
            }
            modelFail = NO;
#ifdef DEBUG_BAYER
            DLog(@"DEBUG_BAYER brand is  here get it %02X, %02X %02X", tmpBrand[0], tmpBrand[1], tmpBrand[2]);
#endif
            break;
        }
        idx++;
    } while (recordData[idx] != 0x0D);
    
    if (modelFail) {
        [H2SyncReport sharedInstance].didSyncFail = YES;
    }
    jjContourSystemInfo.smBrandName = [NSString stringWithUTF8String:(const char *)tmpBrand];
    jjContourSystemInfo.smSerialNumber = [NSString stringWithUTF8String:(const char *)serialNumber];
    
#ifdef DEBUG_BAYER
    NSRange bayerModel = [jjContourSystemInfo.smBrandName rangeOfString:@"Bayer7150"];

    if (bayerModel.location != NSNotFound) {
        DLog(@"DEBUG_BAYER get bayer model name -+-+");
    }
    NSRange bayerSerialNumber = [jjContourSystemInfo.smSerialNumber rangeOfString:@"7150HE295971"];
    
    if (bayerSerialNumber.location != NSNotFound) {
        DLog(@"DEBUG_BAYER get bayer Serial Number -+-+");
    }
#endif
    
    
    return jjContourSystemInfo;
    
    
}
- (NSString *)jjContourUnitParserEx
{

    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;

    char tmp[12] = {0};
    char unit[12] = {0};
    
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    
    idx =0;
    do {
        memcpy(tmp, &recordData[idx], 8);
        NSString *string = [NSString stringWithUTF8String:(const char *)tmp];
        if ([string  isEqual: @"GlucoseA"]) {
            
            do {
                idx++;
                if (recordData[idx] == '|') {
                    do {
                        idx++;
                        if (recordData[idx] == '|') {
                            memcpy(unit, &recordData[idx + 1], 6);
                            break;
                        }
                    }while (recordData[idx] != 0x0D);
/*
                    if (recordData[idx+2] == '.') {
#ifdef DEBUG_BAYER
                        DLog(@"DEBUG_BAYER get something here");
#endif
//                        _mmolFlag = YES;
                        
                        if (recordData[idx + 5 + 1] == '|') {
                            memcpy(unit, &recordData[idx + 5 + 2], 6); // mmol/L
                        }else{
                            memcpy(unit, &recordData[idx + 5 + 1], 6); // mmol/L
                        }
                    }else{
//                        _mmolFlag = NO;
                        
                        if (recordData[idx + 3 + 1] == '|') {
                            memcpy(unit, &recordData[idx + 3 + 2], 5); // mg/dL
                        }else{
                           memcpy(unit, &recordData[idx + 3 + 1], 5); // mg/dL
                        }
                    }
*/
#ifdef DEBUG_BAYER
                    DLog(@"DEBUG_BAYER unit here get it %02X, %02X %02X", unit[0], unit[1], unit[2]);
#endif
                    break;
                }

            } while (recordData[idx] != 0x0D);
            break;
        }
#ifdef DEBUG_BAYER
        DLog(@"DEBUG_BAYER Unit Parser the index is %d", idx);
#endif
        idx++;
    } while (recordData[idx] != 0x0D);
    
    NSString *stringUnit = [NSString stringWithUTF8String:(const char *)unit];
#ifdef DEBUG_BAYER
    DLog(@"DEBUG_BAYER Unit Parser the index is %@", stringUnit);
#endif
    return stringUnit;
    
}

- (H2BgRecord *)jjContourDateTimeValueParser:(UInt16)index// withUnitFlag:(BOOL)mmolUnit
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *jjContourRecord;
    jjContourRecord = [[H2BgRecord alloc] init];
    UInt8 idx=0;
    char date[12] = {0};
    char type[12] = {0};
    char value[12] = {0};
    char unit[10] = {0};
    
    UInt16 jjYear;
    UInt8 jjMonth;
    UInt8 jjDay;
    
    UInt8 jjHour;
    UInt8 jjMinute;
    
    
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    
    memcpy(date, &recordData[idx-12], 12); // get time
    jjYear = (date[0]-CONST0X30)*1000 + (date[1]-CONST0X30)*100 + (date[2]-CONST0X30)*10 + date[3]-CONST0X30;
    jjMonth = (date[4]-CONST0X30)*10 + date[5]-CONST0X30;
    jjDay = (date[6]-CONST0X30 )*10 + date[7]-CONST0X30;
    
    jjHour = (date[8]-CONST0X30)*10 + date[9]-CONST0X30;
    jjMinute = (date[10]-CONST0X30)*10 + date[11]-CONST0X30;
#ifdef DEBUG_BAYER
    for (idx=0; idx<12; idx++) {
            DLog(@"DEBUG_BAYER the time format is %d %02X", idx ,date[idx]);
    }
#endif
    idx =0;
    do {
        memcpy(type, &recordData[idx], 7);
        //DLog(@"arry value %d, %02X \n", idx, recordData[idx]);
        NSString *string = [NSString stringWithUTF8String:(const char *)type];
        if ([string  isEqual: @"Glucose"]) {
            do {
                idx++;
                if (recordData[idx + 7 ] == '|') {
                    if (_didBayerMmolUnit) {
                        memcpy(value, &recordData[idx+7 - 5], 5); // floting
                        memcpy(unit, &recordData[idx + 7 + 1], 6); // mmol
                    }else{
                        memcpy(value, &recordData[idx+7 - 3], 3); // integer
                        memcpy(unit, &recordData[idx + 7 + 1], 5); // mmol
                    }
                    
#ifdef DEBUG_BAYER
                    DLog(@"DEBUG_BAYER value here get it %02X, %02X %02X", value[0], value[1], value[2]);
                    DLog(@"DEBUG_BAYER unit here get it %02X, %02X %02X", unit[0], unit[1], unit[2]);
#endif
                    break;
                }
/*
                if (recordData[idx+7] == 0x7C) {
                    memcpy(value, &recordData[idx+7 - 3], 3); // get time
                    memcpy(unit, &recordData[idx + 7 + 1], 5); // get time
#ifdef DEBUG_CONTUR
                    DLog(@"value here get it %02X, %02X %02X", value[0], value[1], value[2]);
                    DLog(@"unit here get it %02X, %02X %02X", unit[0], unit[1], unit[2]);
#endif
                    break;
                }
*/
            } while (recordData[idx+7] != 0x0D);
            break;
        }
        idx++;
    } while (recordData[idx+7] != 0x0D);

    
    if (_didBayerMmolUnit) {
#if 1
        if (value[0] == '|'){ // 4 bytes
            jjContourRecord.bgValue_mg = (value[1] & 0x0F) * 100 + (value[3] & 0x0F) *10 + (value[4] & 0x0F);
        }else{ // 5 bytes
            jjContourRecord.bgValue_mg = (value[0] & 0x0F) * 1000 + (value[1] & 0x0F) * 100 + (value[3] & 0x0F) * 10 + (value[4] & 0x0F);
#ifdef DEBUG_BAYER
            DLog(@"DEBUG_BAYER the value is %02X, %02X, %02X, %02X, %02X", value[0], value[1], value[2], value[3], value[4]);
#endif
        }
        jjContourRecord.bgValue_mmol = (float)jjContourRecord.bgValue_mg / 100;
        jjContourRecord.bgValue_mg = 0;
#else
        if (value[0] == '|'){ // 4 bytes
            jjContourRecord.bgValue_mg = (value[1] & 0x0F) * 10 + (value[3] & 0x0F);
        }else{ // 5 bytes
            jjContourRecord.bgValue_mg = (value[0] & 0x0F) * 100 + (value[1] & 0x0F) * 10 + (value[3] & 0x0F);
#ifdef DEBUG_BAYER
            DLog(@"the value is %02X, %02X, %02X, %02X, %02X", value[0], value[1], value[2], value[3], value[4]);
#endif
        }
        if ((value[4] & 0x0F) >= 5) {
            jjContourRecord.bgValue_mg++;
        }
        jjContourRecord.bgValue_mmol = (float)jjContourRecord.bgValue_mg / 10;
#endif
#ifdef DEBUG_BAYER
        DLog(@"DEBUG_BAYER the value is %02X, %02X, %02X, %02X, %02X", value[0], value[1], value[2], value[3], value[4]);
#endif
//        jjContourRecord.smMmoUnitlViewFlag = YES;
//        jjContourRecord.smMmoUnitlRawFlag = YES;
//        jjContourRecord.smUnitCoef = 100;
    }else{
        if (value[1] == '|') { // 1 byte
            jjContourRecord.bgValue_mg = (value[2] & 0x0F);
        }else if (value[0] == '|'){ // 2 byte
            jjContourRecord.bgValue_mg = (value[1] & 0x0F) * 10 + (value[2] & 0x0F);
        }else{ // 3 byte
            jjContourRecord.bgValue_mg = (value[0] & 0x0F) * 100 + (value[1] & 0x0F) * 10 + (value[2] & 0x0F);
        }
//        jjContourRecord.smMmoUnitlViewFlag = NO;
//        jjContourRecord.smUnitCoef = 1;
    }
    
    // check control solution test
    do {
        idx++;
        if (recordData[idx] == 'B') {
            jjContourRecord.bgMealFlag = @"B"; // Before meal
            break;
        }else if (recordData[idx] == 'A'){
            jjContourRecord.bgMealFlag = @"A"; // After meal
            break;
        }else if (recordData[idx] == 'D'){
            jjContourRecord.bgMealFlag = @"D"; // Log
            break;
        }else if (recordData[idx] == 'E'){
            jjContourRecord.bgMealFlag = @"E"; // control solution code
            break;
        }
    } while (recordData[idx] != 0x0D);
    
    
    jjContourRecord.bgUnit = [NSString stringWithUTF8String:(const char *)unit];

    
    jjContourRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",jjYear, jjMonth, jjDay, jjHour, jjMinute];
    
    jjContourRecord.bgIndex = index;
#ifdef DEBUG_BAYER
    DLog(@"DEBUG_BAYER DATA TIME IS %@, VALUE IS %d", jjContourRecord.bgDateTime, jjContourRecord.bgValue_mg);
    DLog(@"DEBUG_BAYER the external infomation is %@", jjContourRecord.bgMealFlag);
#endif
    if (![jjContourRecord.bgMealFlag isEqualToString:@"E"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:jjContourRecord.bgDateTime]) {
            jjContourRecord.bgMealFlag = @"E";
        }
    }
    
    return jjContourRecord;
}


#pragma mark - BLE PARSER
- (H2BgRecord *)jjContourBLEDateTimeValueParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *jjContourRecord;
    jjContourRecord = [[H2BgRecord alloc] init];
    
    UInt8 idx=0;
    char date[12] = {0};
//    char type[12] = {0};
    char value[12] = {0};
    char unit[10] = {0};
    
    UInt16 jjYear;
    UInt8 jjMonth;
    UInt8 jjDay;
    
    UInt8 jjHour;
    UInt8 jjMinute;
    
    
    do {
        idx++;
    } while (recordData[idx] != 0x0D && idx < length -3);
    
    // Copy Date Time Data
    memcpy(date, &recordData[idx-12], 12); // get time
    
    // Year, Month and Day Process
    jjYear = (date[0]-CONST0X30) * 1000 + (date[1]-CONST0X30) * 100 + (date[2]-CONST0X30) * 10 + date[3]-CONST0X30;
    jjMonth = (date[4]-CONST0X30) * 10 + date[5]-CONST0X30;
    jjDay = (date[6]-CONST0X30 ) * 10 + date[7]-CONST0X30;
    
    // Hour and Minute Process
    jjHour = (date[8]-CONST0X30) * 10 + date[9]-CONST0X30;
    jjMinute = (date[10]-CONST0X30) * 10 + date[11]-CONST0X30;
#ifdef DEBUG_BAYER
    for (idx=0; idx<12; idx++) {
        DLog(@"DEBUG_BAYER the time format is %d %02X", idx ,date[idx]);
    }
#endif
    // Unit Process
    idx =0;
    do {
        idx++;
        
    } while (recordData[idx] != '/' && idx < length -3);
#ifdef DEBUG_BAYER
    DLog(@"DEBUG_BAYER BLE Source get it %02X, %02X %02X", recordData[idx], recordData[idx+1], recordData[idx+2]);
#endif
    if (recordData[idx+1] == 'L') {
        memcpy(value, &recordData[idx-4 -1 - 5], 5); // floting
        memcpy(unit, &recordData[idx -4], 6); // mmol/l
    }else{
        memcpy(value, &recordData[idx -2 -1 -3], 3); // integer
        memcpy(unit, &recordData[idx -2], 5); // mg/dL
    }
#ifdef DEBUG_BAYER
    DLog(@"DEBUG_BAYER BLE value here get it %02X, %02X %02X", value[0], value[1], value[2]);
    DLog(@"DEBUG_BAYER BLE unit here get it %02X, %02X %02X", unit[0], unit[1], unit[2]);
#endif
    
    
    if (recordData[idx+1] == 'L') {
        if (value[0] == '|'){ // 4 bytes
            jjContourRecord.bgValue_mg = (value[1] & 0x0F) * 100 + (value[3] & 0x0F) *10 + (value[4] & 0x0F);
        }else{ // 5 bytes
            jjContourRecord.bgValue_mg = (value[0] & 0x0F) * 1000 + (value[1] & 0x0F) * 100 + (value[3] & 0x0F) * 10 + (value[4] & 0x0F);
#ifdef DEBUG_BAYER
            DLog(@"DEBUG_BAYER the value is %02X, %02X, %02X, %02X, %02X", value[0], value[1], value[2], value[3], value[4]);
#endif
        }

        jjContourRecord.bgValue_mmol = (float)jjContourRecord.bgValue_mg / 100;
        jjContourRecord.bgValue_mg = 0;
#ifdef DEBUG_BAYER
        DLog(@"DEBUG_BAYER the value is %02X, %02X, %02X, %02X, %02X", value[0], value[1], value[2], value[3], value[4]);
#endif
    }else{
        if (value[1] == '|') { // 1 byte
            jjContourRecord.bgValue_mg = (value[2] & 0x0F);
        }else if (value[0] == '|'){ // 2 byte
            jjContourRecord.bgValue_mg = (value[1] & 0x0F) * 10 + (value[2] & 0x0F);
        }else{ // 3 byte
            jjContourRecord.bgValue_mg = (value[0] & 0x0F) * 100 + (value[1] & 0x0F) * 10 + (value[2] & 0x0F);
        }
    }
    
    // check control solution test
    do {
        idx++;
        if (recordData[idx] == 'B') {
            jjContourRecord.bgMealFlag = @"B"; // Before meal
            break;
        }else if (recordData[idx] == 'A'){
            jjContourRecord.bgMealFlag = @"A"; // After meal
            break;
        }else if (recordData[idx] == 'D'){
            jjContourRecord.bgMealFlag = @"D"; // Log
            break;
        }else if (recordData[idx] == 'E'){
            jjContourRecord.bgMealFlag = @"E"; // control solution code
            break;
        }
    } while (recordData[idx] != 0x0D);
    
    
    jjContourRecord.bgUnit = [NSString stringWithUTF8String:(const char *)unit];
    
    
    jjContourRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",jjYear, jjMonth, jjDay, jjHour, jjMinute];
    
    if (![jjContourRecord.bgMealFlag isEqualToString:@"E"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:jjContourRecord.bgDateTime]) {
            jjContourRecord.bgMealFlag = @"E";
        }
    }
//    jjContourRecord.bgIndex = index;
#ifdef DEBUG_BAYER
    DLog(@"DEBUG_BAYER DATA TIME IS %@", jjContourRecord.bgDateTime);
    DLog(@"DEBUG_BAYER DATA VALUE IS %d and %2.3f", jjContourRecord.bgValue_mg, jjContourRecord.bgValue_mmol);
    DLog(@"DEBUG_BAYER the external infomation is %@", jjContourRecord.bgMealFlag);
#endif
    
    return jjContourRecord;
}
@end
