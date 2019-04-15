//
//  FreeStyleLite.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/28.
//
//

#import "H2AudioFacade.h"
#import "FreeStyleLite.h"

#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"

@implementation FreeStyleLite
{
    H2AudioFacade *_audioFacade;
}


- (id)init
{
    if (self = [super init]) {
        ;
    }
    _audioFacade = [H2AudioFacade sharedInstance];
    return self;
}

+ (FreeStyleLite *)sharedInstance
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

unsigned char freeStyleCmdAll[]={
    '$', 'l', 'o', 'g', ',', '0', '0', '0', 0x0A
};


- (void)FreeStyleCommandGeneral:(UInt16)index withCommandMethod:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    
    cmdLength = sizeof(freeStyleCmdAll);
    memcpy(cmdBuffer, freeStyleCmdAll, cmdLength);
    UInt8 a, b, c;
    
    switch (cmdMethod) {
        case METHOD_INIT:
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            break;
            
        case METHOD_RECORD:
            cmdTypeId = (currentMeter<<4) + METHOD_RECORD;
            break;
            
        default:
            break;
    }
    
    a = index/100;
    b = (index%100)/10;
    c = (index%100)%10;
    cmdBuffer[5] = 0x30 + a;
    cmdBuffer[6] = 0x30 + b;
    cmdBuffer[7] = 0x30 + c;
    
    [_audioFacade sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
    
}


#pragma mark -
#pragma mark FREESTYLE DATA PARSER
- (H2BgRecord *)fsLiteDateTimeValueParser:(BOOL)unitFlag
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 currentMinute;
    UInt16 currentHour;
    
    UInt16 currentDay;
    
    UInt16 currentMonth;
    UInt16 currentYear;
    
    UInt16 currentValue;
    UInt16 idx = 0;
    UInt8 dNumber = 0, dateTimeOfset = 0;
    
    

    do {
        if (recordData[idx] == 0x0D) {
            dNumber++;
        }
        
        idx++;
    } while (dNumber<4);
    dateTimeOfset = idx+1;
    idx = 0;
/*
    DLog(@"the index number is %d", idx);
    DLog(@"the value is %02X", recordData[idx]);
    DLog(@"the value number is %02X", recordData[idx+1]);
    DLog(@"the value number is %02X", recordData[idx+2]);
    DLog(@"the value number is %02X", recordData[idx+3]);
    idx = 0;
*/
    
    
    char str[4] = {0};
    memcpy(str, &recordData[5+dateTimeOfset], 3);
    
    H2BgRecord *fsLiteRecord;
    fsLiteRecord = [[H2BgRecord alloc] init];
    
    NSString *strMon = [NSString stringWithUTF8String:(const char *)str];
    
    currentValue = (recordData[0+dateTimeOfset]-0x30) * 100 + (recordData[1+dateTimeOfset]-0x30) * 10 + recordData[2+dateTimeOfset]-0x30;
    
    if ([strMon isEqualToString:@"Jan"]) {
        currentMonth = 1;
    }else if ([strMon isEqualToString:@"Feb"]){
        currentMonth = 2;
    }else if ([strMon isEqualToString:@"Mar"]){
        currentMonth = 3;
    }else if ([strMon isEqualToString:@"Apr"]){
        currentMonth = 4;
    }else if ([strMon isEqualToString:@"May"]){
        currentMonth = 5;
    }else if ([strMon isEqualToString:@"Jun"]){
        currentMonth = 6;
    }else if ([strMon isEqualToString:@"Jul"]){
        currentMonth = 7;
    }else if ([strMon isEqualToString:@"Aug"]){
        currentMonth = 8;
    }else if ([strMon isEqualToString:@"Sep"]){
        currentMonth = 9;
    }else if ([strMon isEqualToString:@"Oct"]){
        currentMonth = 10;
    }else if ([strMon isEqualToString:@"Nov"]){
        currentMonth = 11;
    }else if ([strMon isEqualToString:@"Dec"]){
        currentMonth = 12;
    }else{
        currentMonth = 0;
    }
    
    currentDay = (recordData[10+dateTimeOfset]-0x30) * 10 + recordData[11+dateTimeOfset]-0x30;
    currentYear = (recordData[13+dateTimeOfset]-0x30) * 1000 + (recordData[14+dateTimeOfset]-0x30) * 100 + (recordData[15+dateTimeOfset]-0x30) * 10 + recordData[16+dateTimeOfset]-0x30;
    currentHour = (recordData[18+dateTimeOfset]-0x30) * 10 + recordData[19+dateTimeOfset]-0x30;
    currentMinute = (recordData[21+dateTimeOfset]-0x30) * 10 + recordData[22+dateTimeOfset]-0x30;
    
    fsLiteRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",currentYear, currentMonth, currentDay, currentHour, currentMinute];
#ifdef DEBUG_FREESTYLE
    DLog(@"DEBUG_FREESTYLE date time is %@", fsLiteRecord.bgDateTime);
#endif


    fsLiteRecord.bgUnit = @"N";
    fsLiteRecord.bgValue_mg = currentValue;
    fsLiteRecord.bgValue_mmol = 0.0;
    
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    do {
        idx++;
    } while (recordData[idx] != 0x0D);
    //    do {
    //        idx++;
    //    } while (recordData[idx] != 0x0D);
    if((recordData[idx-2]-0x30)*10 + recordData[idx-1]-0x30)
    {
        fsLiteRecord.bgMealFlag = @"E";
    }
    
    if (![fsLiteRecord.bgMealFlag isEqualToString:@"E"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:fsLiteRecord.bgDateTime]) {
            fsLiteRecord.bgMealFlag = @"E";
        }
    }
    
        
    return fsLiteRecord;
}



#define SYS_YEAR        8
#define SYS_MONTH       0
#define SYS_DAY         5
#define SYS_HOUR        13
#define SYS_MINUTE      16
- (H2MeterSystemInfo *)fsLiteSystemInfoParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2MeterSystemInfo *fsLiteSystemInfo;
    fsLiteSystemInfo = [[H2MeterSystemInfo alloc] init];
    
    
    UInt16 sysMinute;
    UInt16 sysHour;
    
    UInt16 sysDay;
    
    UInt16 sysMonth;
    UInt16 sysYear;
    

    UInt8 idx=0;
    UInt8 idxCurrent = 0;
    
    char modelName[32] = {0};
    char version[32] = {0};
    char systemDateTime[32] = {0};
    
    char systemLastDateTime[32] = {0};
    
    char stringStop[48] = {0};
    
    char modelTmp[16] = {0};
#ifdef DEBUG_FREESTYLE
    for (int i=0; i<length; i++) {
        DLog(@"FS- IDX %d SRC %02X, DST %02X", i, [H2AudioAndBleSync sharedInstance].dataBuffer[i], recordData[i]);
    }
#endif
//length
    
    if (recordData[0] != 0x0D || recordData[1] != 0x0A) {
#ifdef DEBUG_FREESTYLE
        DLog(@"FS - START ERROR");
#endif
        fsLiteSystemInfo.formatError = YES;
        return fsLiteSystemInfo;
    }
    
    idx = 0;
    for (int i=0; i<length; i++) {
        if (recordData[i] == 0x0D) {
            idx++;
        }
    }
#ifdef DEBUG_FREESTYLE
    DLog(@"FS SYS LEN CHECK = %d", idx);
#endif
    
    if (idx < 7) {
        fsLiteSystemInfo.formatError = YES;
        return fsLiteSystemInfo;
    }
    
    idx = 0;
    do { // get model name
        idx++;
    } while (recordData[idx] != 0x0D);
#ifdef DEBUG_FREESTYLE
    DLog(@"the idx value  %02x %02x %02x", idx, recordData[2],recordData[5]);
#endif
    if (idx < 3 || idx > sizeof(modelName)) {
        //
    }
    memcpy(modelName, &recordData[2], idx-2);
    for (int i=0; i<idx-2; i++) {
#ifdef DEBUG_FREESTYLE
        DLog(@"modelName[%d], %02X", i, modelName[i]);
#endif
        if (modelName[i] == '-') {
            modelTmp[i] = '\0';
            break;
        }else{
            modelTmp[i] = modelName[i];
        }
    }

    idxCurrent = idx+2;

    idx =0;

    
    do { // get version
        idx++;
    } while (recordData[idxCurrent + idx] != 0x0D);
    
    memcpy(version, &recordData[idxCurrent], idx);
    idxCurrent += idx;
    idxCurrent += 2;

    idx =0;
    
    do { // get system date time
        idx++;
    } while (recordData[idxCurrent + idx] != 0x0D);
    
    memcpy(systemDateTime, &recordData[idxCurrent], idx);

    if (length > 70) {
    
        idxCurrent += idx;
        idxCurrent += 2;
        idx = 0;
        do { // STOP
            idx++;
        } while (recordData[idxCurrent + idx] != 0x0D);
    
        memcpy(stringStop, &recordData[idxCurrent], idx);
#ifdef DEBUG_FREESTYLE
        NSString *stringEnd = [NSString stringWithUTF8String:(const char *)stringStop];
        DLog(@"stop string is %@", stringEnd);
        if ([stringEnd isEqualToString:@"Log Not Found"]) {
            DLog(@"i got it system =============== %d, %d", idxCurrent, idx);
        }
        for (idx=0; idx<12; idx++) {
            DLog(@"the value is %d %02X", idx, recordData[idxCurrent + idx]);
        }
#endif
    }
    
    char chMonth[4] = {0};
    memcpy(chMonth, &systemDateTime, 3);
    NSString *stringMonth = [NSString stringWithUTF8String:(const char *)chMonth];
    
    if ([stringMonth isEqualToString:@"Jan"]) {
        sysMonth = 1;
    }else if ([stringMonth isEqualToString:@"Feb"]){
        sysMonth = 2;
    }else if ([stringMonth isEqualToString:@"Mar"]){
        sysMonth = 3;
    }else if ([stringMonth isEqualToString:@"Apr"]){
        sysMonth = 4;
    }else if ([stringMonth isEqualToString:@"May"]){
        sysMonth = 5;
    }else if ([stringMonth isEqualToString:@"Jun"]){
        sysMonth = 6;
    }else if ([stringMonth isEqualToString:@"Jul"]){
        sysMonth = 7;
    }else if ([stringMonth isEqualToString:@"Aug"]){
        sysMonth = 8;
    }else if ([stringMonth isEqualToString:@"Sep"]){
        sysMonth = 9;
    }else if ([stringMonth isEqualToString:@"Oct"]){
        sysMonth = 10;
    }else if ([stringMonth isEqualToString:@"Nov"]){
        sysMonth = 11;
    }else if ([stringMonth isEqualToString:@"Dec"]){
        sysMonth = 12;
    }else{
        sysMonth = 0;
    }

    sysDay = (systemDateTime[SYS_DAY]-0x30) * 10 + systemDateTime[SYS_DAY+1]-0x30;
    sysYear = (systemDateTime[SYS_YEAR]-0x30) * 1000 + (systemDateTime[SYS_YEAR+1]-0x30) * 100 + (systemDateTime[SYS_YEAR+2]-0x30) * 10 + systemDateTime[SYS_YEAR+3]-0x30;
    sysHour = (systemDateTime[SYS_HOUR]-0x30) * 10 + systemDateTime[SYS_HOUR+1]-0x30;
    sysMinute = (systemDateTime[SYS_MINUTE]-0x30) * 10 + systemDateTime[SYS_MINUTE+1]-0x30;
    
    fsLiteSystemInfo.smCurrentDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",sysYear, sysMonth, sysDay, sysHour, sysMinute];
    
//    fsLiteSystemInfo.smModelName = [NSString stringWithUTF8String:(const char *)modelName];
//    fsLiteSystemInfo.smSerialNumber = fsLiteSystemInfo.smModelName;
    fsLiteSystemInfo.smSerialNumber = [NSString stringWithUTF8String:(const char *)modelName];
    fsLiteSystemInfo.smVersion =[ NSString stringWithUTF8String:(const char *)version];
#ifdef DEBUG_FREESTYLE
    DLog(@"the last model name is %@", fsLiteSystemInfo.smModelName);
    // last Date Time
#endif
    memcpy(chMonth, &systemLastDateTime, 3);
    stringMonth = [NSString stringWithUTF8String:(const char *)chMonth];
    
    if ([stringMonth isEqualToString:@"Jan"]) {
        sysMonth = 1;
    }else if ([stringMonth isEqualToString:@"Feb"]){
        sysMonth = 2;
    }else if ([stringMonth isEqualToString:@"Mar"]){
        sysMonth = 3;
    }else if ([stringMonth isEqualToString:@"Apr"]){
        sysMonth = 4;
    }else if ([stringMonth isEqualToString:@"May"]){
        sysMonth = 5;
    }else if ([stringMonth isEqualToString:@"Jun"]){
        sysMonth = 6;
    }else if ([stringMonth isEqualToString:@"Jul"]){
        sysMonth = 7;
    }else if ([stringMonth isEqualToString:@"Aug"]){
        sysMonth = 8;
    }else if ([stringMonth isEqualToString:@"Sep"]){
        sysMonth = 9;
    }else if ([stringMonth isEqualToString:@"Oct"]){
        sysMonth = 10;
    }else if ([stringMonth isEqualToString:@"Nov"]){
        sysMonth = 11;
    }else if ([stringMonth isEqualToString:@"Dec"]){
        sysMonth = 12;
    }else{
        sysMonth = 0;
    }
    sysDay = (systemLastDateTime[SYS_DAY]-0x30) * 10 + systemLastDateTime[SYS_DAY+1]-0x30;
    sysYear = (systemLastDateTime[SYS_YEAR]-0x30) * 1000 + (systemLastDateTime[SYS_YEAR+1]-0x30) * 100 + (systemLastDateTime[SYS_YEAR+2]-0x30) * 10 + systemLastDateTime[SYS_YEAR+3]-0x30;
    sysHour = (systemLastDateTime[SYS_HOUR]-0x30) * 10 + systemLastDateTime[SYS_HOUR+1]-0x30;
    sysMinute = (systemLastDateTime[SYS_MINUTE]-0x30) * 10 + systemLastDateTime[SYS_MINUTE+1]-0x30;
    
//    fsLiteSystemInfo.bgLastDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",sysYear, sysMonth, sysDay, sysHour, sysMinute];
 
    return fsLiteSystemInfo;
}




- (BOOL)fsLiteLogNotFoundParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    UInt8 idxCurrent = 0;
    
    char stringStop[48] = {0};
    
    
    do { // get model name
        idx++;
    } while (recordData[idx] != 0x0D);
    

    idxCurrent = idx+2;
    idx =0;
    do { // get version
        idx++;
    } while (recordData[idxCurrent + idx] != 0x0D);
    

    idxCurrent += idx;
    idxCurrent += 2;
    idx =0;
    do { // get system date time
        idx++;
    } while (recordData[idxCurrent + idx] != 0x0D);
    

    if (length > 70) {
        
        idxCurrent += idx;
        idxCurrent += 2;
        idx = 0;
        do { // STOP
            idx++;
        } while (recordData[idxCurrent + idx] != 0x0D);
        if (idx>24) {
            return NO;
        }
        memcpy(stringStop, &recordData[idxCurrent], idx);
        NSString *stringEnd = [NSString stringWithUTF8String:(const char *)stringStop];
//        DLog(@"stop string is %@", stringEnd);
        if ([stringEnd isEqualToString:@"Log Not Found"]) {
#ifdef DEBUG_FREESTYLE
            DLog(@"i got it record =============== %d, %d", idxCurrent, idx);
#endif
            return YES;
        }
    }
    return NO;
}


@end
