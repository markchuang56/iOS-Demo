//
//  ACAviva.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/29.
//
//

#define CURRENT_OFFSET_AT3        (3+1)

#define CURRENT_YEAR_AT0            0
#define CURRENT_MONTH_AT2           2
#define CURRENT_DAY_AT4             4

#define CURRENT_HOUR_AT0            0
#define CURRENT_MINUTE_AT2          2

#define BRAND_OFFSET                4
#define END_OFFSET                  3

#define MAX_RECORD                  35

#import "H2AudioFacade.h"
#import "ACAviva.h"

#import "H2DebugHeader.h"

#import "H2Config.h"

#import "H2RocheEventProcess.h"
#import "H2DataFlow.h"

#import "H2Records.h"


@implementation H2RocheAviva
{

}
- (id)init
{
    if (self = [super init]) {

    }
    
    return self;
}





unsigned char avivaCmdInit[] = {
    0x0B, 0x0D, 0x06
};
unsigned char avivaCmdBrand[] = {
    'I', 0x0D, 0x06
};

unsigned char avivaCmdModel[] = {
    'C', 0x09, '4', 0x0D, 0x06
};
unsigned char avivaCmdSerialNumber[] = {
    'C', 0x09, '3', 0x0D, 0x06
};
unsigned char avivaCmdDate[] = {
    'S', 0x09, '1', 0x0D, 0x06
};
unsigned char avivaCmdTime[] = {
    'S', 0x09, '2', 0x0D, 0x06
};
unsigned char avivaCmdUnit[] = {
    'S', 0x09, '3', 0x0D, 0x06
};



unsigned char avivaCmdNumberOfRecord[] = {
    0x60, 0x0D, 0x06
};


unsigned char avivaCmdAck[] = {
    0x06
};

unsigned char avivaCmdEnd[] = {
    0x1D, 0x0D, 0x06
    
};

unsigned char avivaCmdRecord1[] = {
    'a', 0x09, 'X', 0x09, 'X', 0x0D, 0x06
};
unsigned char avivaCmdRecord10[] = {
    'a', 0x09, 'X', 'X', 0x09, 'X', 'X', 0x0D, 0x06
};
unsigned char avivaCmdRecord100[] = {
    'a', 0x09, 'X', 'X', 'X', 0x09, 'X', 'X', 'X', 0x0D, 0x06
};



#pragma mark -
#pragma mark COMMAND

- (void)AvivaCommandGeneral:(UInt16)cmdMethod
{
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    switch (cmdMethod) {
        case METHOD_INIT:
            cmdLength = sizeof(avivaCmdInit);
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            memcpy(cmdBuffer, avivaCmdInit, cmdLength);
            break;
            
        case METHOD_4:
            cmdLength = sizeof(avivaCmdInit);
            cmdTypeId = (currentMeter<<4) + METHOD_4;
            memcpy(cmdBuffer, avivaCmdInit, cmdLength);
            break;
            
        case METHOD_BRAND:
            cmdLength = sizeof(avivaCmdBrand);
            cmdTypeId = (currentMeter<<4) + METHOD_BRAND;
            memcpy(cmdBuffer, avivaCmdBrand, cmdLength);
            break;
            
        case METHOD_MODEL:
            cmdLength = sizeof(avivaCmdModel);
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            memcpy(cmdBuffer, avivaCmdModel, cmdLength);
            break;
            
        case METHOD_SN:
            cmdLength = sizeof(avivaCmdSerialNumber);
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            memcpy(cmdBuffer, avivaCmdSerialNumber, cmdLength);
            break;
            
        
            
        case METHOD_DATE:
            cmdLength = sizeof(avivaCmdDate);
            cmdTypeId = (currentMeter<<4) + METHOD_DATE;
            memcpy(cmdBuffer, avivaCmdDate, cmdLength);
            break;
            
        case METHOD_TIME:
            cmdLength = sizeof(avivaCmdTime);
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            memcpy(cmdBuffer, avivaCmdTime, cmdLength);
            break;
            
        case METHOD_UNIT:
            cmdLength = sizeof(avivaCmdUnit);
            cmdTypeId = (currentMeter<<4) + METHOD_UNIT;
            memcpy(cmdBuffer, avivaCmdUnit, cmdLength);
            break;
            
        case METHOD_NROFRECORD:
            cmdLength = sizeof(avivaCmdNumberOfRecord);
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            memcpy(cmdBuffer, avivaCmdNumberOfRecord, cmdLength);
            break;
            
        case METHOD_END:
            cmdLength = sizeof(avivaCmdEnd);
            cmdTypeId = (currentMeter<<4) + METHOD_END;
            memcpy(cmdBuffer, avivaCmdEnd, cmdLength);
            break;
            
        default:
            break;
    }
    

  
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}



- (void)AvivaReadRecord:(UInt16)nIndex
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    if (nIndex <= 9) {
        
        avivaCmdRecord1[2] = nIndex + 0x30;
        avivaCmdRecord1[4] = nIndex + 0x30;
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:avivaCmdRecord1 withCmdLength:sizeof(avivaCmdRecord1) cmdType:(currentMeter<<4) + METHOD_RECORD
                       returnDataLength:0 mcuBufferOffSetAt:0];
        
    }else if (nIndex >= 10 && nIndex <= 99){
        
        avivaCmdRecord10[3] = (nIndex%10) + 0x30;
        avivaCmdRecord10[6] = (nIndex%10) + 0x30;
        
        avivaCmdRecord10[2] = (nIndex/10) + 0x30;
        avivaCmdRecord10[5] = (nIndex/10) + 0x30;
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:avivaCmdRecord10 withCmdLength:sizeof(avivaCmdRecord10) cmdType:(currentMeter<<4) + METHOD_RECORD
                       returnDataLength:0 mcuBufferOffSetAt:0];
        
    }else{
        
        avivaCmdRecord100[4] = ((nIndex%100)%10)+ 0x30;
        avivaCmdRecord100[8] = ((nIndex%100)%10)+ 0x30;
        
        avivaCmdRecord100[3] = ((nIndex%100)/10)+ 0x30;
        avivaCmdRecord100[7] = ((nIndex%100)/10)+ 0x30;
        
        avivaCmdRecord100[2] = nIndex/100 + 0x30;
        avivaCmdRecord100[6] = nIndex/100 + 0x30;
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:avivaCmdRecord100 withCmdLength:sizeof(avivaCmdRecord100) cmdType:(currentMeter<<4) + METHOD_RECORD
                       returnDataLength:0 mcuBufferOffSetAt:0];
    }
}




#pragma mark -
#pragma mark PARSER


- (NSString *)acAvivaParserEx
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    UInt8 begin = 0;
    UInt8 end = 0;
 
    char srcTmp[48] = {0};
    
    
    do {
        if (srcData[idx] == ROCHE_DATA_STX) {
            begin = idx;
        }
        if (srcData[idx] == ROCHE_DATA_EOT){
            end = idx;
        }
#ifdef DEBUG_AVIVA
        DLog(@"the start %d, end %d %02X", begin, end, srcData[idx]);
#endif
        idx++;
    } while (idx < length);
    if (end <= begin || end == 0) {
        return nil;
    }
#ifdef DEBUG_AVIVA
    DLog(@"the start %d, end %d", begin, end);
    for(int i=begin; i<= end; i++){
        DLog(@"CHECK SUM indix %d and %02X", i, srcData[i]);
    }
#endif
    if (end) {
        memcpy(srcTmp, &srcData[begin+BRAND_OFFSET], end - begin - BRAND_OFFSET - END_OFFSET);
    }

    NSString *string = [NSString stringWithUTF8String:(const char *)srcTmp];
    return string;
}

- (UInt16) acAvivaParserNumberOfRecord
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    UInt8 begin = 0;
    UInt8 end = 0;
    UInt16 number = 0;
    
    char srcTmp[16] = {0};
    
    
    do {
        if (srcData[idx] == ROCHE_DATA_STX) {
            begin = idx;
        }
        if (srcData[idx] == ROCHE_DATA_EOT){
            end = idx;
        }
#ifdef DEBUG_AVIVA
        DLog(@"the start %d, end %d %02X", begin, end, srcData[idx]);
#endif
        idx++;
    } while (idx < length);
    if (end <= begin || end == 0) {
        return 0;
    }
#ifdef DEBUG_AVIVA
    DLog(@"the start %d, end %d", begin, end);
#endif
    if (end) {
        memcpy(srcTmp, &srcData[begin+BRAND_OFFSET], end - begin - BRAND_OFFSET - END_OFFSET);
    }
    
    number = (srcTmp[0] & 0x0F)*100 + (srcTmp[1] & 0x0F)*10 + (srcTmp[2] & 0x0F);
    return number;
}






- (H2BgRecord *)acAvivaDateTimeValueParser:(BOOL)mmolUnit
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    BOOL startFlag = NO;
    
    UInt16 avivaValue;
    
    
    UInt8 avivaHour;
    UInt8 avivaMinute;
    
    UInt16 avivaYear;
    UInt8 avivaMonth;
    UInt8 avivaDay;
    
    UInt8 idx = 0;
    UInt8 begin = 0;
    UInt8 end = 0;
    
    H2BgRecord *avivaRecord;
    avivaRecord = [[H2BgRecord alloc] init];
    
    avivaRecord.bgValue_mg = 0;
    UInt8 chTmp = 0;
    for (int i = 1; i<length-4; i++) {
        chTmp += srcData[i];
#ifdef DEBUG_AVIVA
        DLog(@"The Meter %d Data is %2X %2X", i, srcData[i], chTmp);
#endif
    }
#ifdef DEBUG_AVIVA
    DLog(@"The Meter Data is %2X %2X %2X %2X", srcData[length - 4], srcData[length - 3], srcData[length - 2], srcData
          [length - 1]);
#endif
    do { // get start
        if (srcData[idx] == ROCHE_DATA_STX) {
            begin = idx;
            startFlag = YES;
        }
        if (startFlag && srcData[idx] == 0x09) {
            end = idx;
            break;
        }
        idx++;
    } while (idx < length);
    if (end <= begin || end == 0) {
        return nil;
    }
#ifdef DEBUG_AVIVA
    if (end>begin) {
        DLog(@"start here");
    }
#endif
    end++;
    idx=0;
    do { // get value
        if (srcData[end+idx] == 0x09) {
            break;
        }
        idx++;
    } while (idx < length-end-1);
    
    if (idx == 2) {
        avivaValue = (srcData[end+0]-0x30)*10 + (srcData[end+1]-0x30);
    }else{
        avivaValue = (srcData[end+0]-0x30)*100 + (srcData[end+1]-0x30)*10 + (srcData[end+2]-0x30);
    }
    
    end +=idx;
    end++;
    idx=0;
    do { // get time
        if (srcData[end+idx] == 0x09) {
            break;
        }
        idx++;
    } while (idx < length-end-1);
    
    avivaHour = (srcData[end+0]-0x30)*10 + (srcData[end+1]-0x30);
    avivaMinute = (srcData[end+2]-0x30)*10 + (srcData[end+3]-0x30);
    
    // date
    avivaYear = (srcData[end+idx+1]-0x30)*10 + (srcData[end+idx+2]-0x30) + 2000;
    avivaMonth = (srcData[end+idx+3]-0x30)*10 + (srcData[end+idx+4]-0x30);
    avivaDay = (srcData[end+idx+5]-0x30)*10 + (srcData[end+idx+6]-0x30);
    
    
    avivaRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",avivaYear, avivaMonth, avivaDay, avivaHour, avivaMinute];
#ifdef DEBUG_AVIVA
    DLog(@"The last value %02X %02X %02X", srcData[length-2], srcData[length-1], srcData[length-0]);
    DLog(@"the length is %d", length);
#endif
#if 0
    if (length < MAX_RECORD || srcData[length-2] != ROCHE_DATA_EOT) {
#ifdef DEBUG_AVIVA
        DLog(@"error length is %d", length);
#endif
        avivaRecord.smRecordFlag = 'F'; // retry
        return avivaRecord;
    }
#endif
    
#ifdef DEBUG_AVIVA
    DLog(avivaRecord.bgDateTime, nil);
#endif
    end +=idx;
    end++;
    idx=0;
    do { // get remark
        if (srcData[end+idx] == 0x09) {
            break;
        }
        idx++;
    } while (idx < length-end-1);


    if (srcData[end+idx+5] == '4') {
        //avivaRecord.smRecordFlag = 'D'; // Log or Remark
        avivaRecord.bgMealFlag = @"R"; // Log or Remark
        
    }else if (srcData[end+idx+5] == '8'){
        avivaRecord.bgMealFlag = @"E"; // Control solution
    }
    
    if (srcData[end+idx+5+2] != '0') {
        avivaRecord.bgMealFlag = @"E"; // Skip
    }
    if (srcData[end+idx+1] != '0') {
        avivaRecord.bgMealFlag = @"F"; // retry
    }
    
    
    if (mmolUnit) {
        avivaRecord.bgValue_mmol = (float)avivaValue/MMOL_COIF;
        avivaRecord.bgUnit = BG_UNIT_EX;
    }else{
        avivaRecord.bgValue_mg = avivaValue;
        avivaRecord.bgUnit = BG_UNIT;
    }
    if (![avivaRecord.bgMealFlag isEqualToString:@"E"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:avivaRecord.bgDateTime]) {
            avivaRecord.bgMealFlag = @"E";
        }
    }
    
    return avivaRecord;
}


- (NSString *)acAvivaDateParserEx
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    UInt8 begin=0;
    UInt8 end=0;
    
    UInt16 currentYear = 0;
    UInt8 currentMonth = 0;
    UInt8 currentDay = 0;
    
    
    do { // get start
        if (srcData[idx] == ROCHE_DATA_STX) {
            begin = idx;
        }
        if (srcData[idx] == ROCHE_DATA_EOT) {
            end = idx;
            break;
        }
        idx++;
    } while (idx < length);
    
    if (end <= begin || end == 0) {
        return nil;
    }
    
#ifdef DEBUG_AVIVA
    DLog(@"INDEX %d", begin);
    DLog(@"DATE-YEAR  -->  %02X, %02X", srcData[begin+CURRENT_OFFSET_AT3], srcData[begin+CURRENT_OFFSET_AT3+1] );
    DLog(@"DATE-MONTH -->  %02X, %02X", srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MONTH_AT2], srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MONTH_AT2+1]);
    DLog(@"DATE-DAY -->  %02X, %02X", srcData[begin+CURRENT_OFFSET_AT3+CURRENT_DAY_AT4], srcData[begin+CURRENT_OFFSET_AT3+CURRENT_DAY_AT4 + 1]);
#endif
    // date
    currentYear = (srcData[begin+CURRENT_OFFSET_AT3]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+1]-0x30) + 2000;
    currentMonth = (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MONTH_AT2]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MONTH_AT2+1]-0x30);
    currentDay = (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_DAY_AT4]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_DAY_AT4+1]-0x30);
    
    NSString* string = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d",currentYear, currentMonth, currentDay];
    
    return string;
}


- (NSString *)acAvivaTimeParserEx:(NSString *)dateString
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    UInt8 begin=0;
    UInt8 end=0;
    
    UInt8 currentHour = 0;
    UInt8 currentMinute = 0;

    do { // get start
        if (srcData[idx] == ROCHE_DATA_STX) {
            begin = idx;
        }
        if (srcData[idx] == ROCHE_DATA_EOT) {
            end = idx;
            break;
        }
        idx++;
    } while (idx < length);
    
    if (end <= begin || end == 0) {
        return nil;
    }
    
#ifdef DEBUG_AVIVA
    DLog(@"INDEX %d", begin);
    DLog(@"TIME-HOUR --> %02X, %02X",  srcData[begin+CURRENT_OFFSET_AT3],  srcData[begin+CURRENT_OFFSET_AT3+1]);
    DLog(@"TIME-MIN -->  %02X, %02X", srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MINUTE_AT2], srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MINUTE_AT2 + 1]);
#endif
    currentHour = (srcData[begin+CURRENT_OFFSET_AT3]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+1]-0x30);
    currentMinute = (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MINUTE_AT2]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MINUTE_AT2+1]-0x30);
    
    NSString *string = [[NSString alloc] initWithFormat:@"%02d:%02d:00 +0000",currentHour, currentMinute];
    NSString *result= [NSString stringWithFormat:@"%@ %@", dateString, string];
    
    return result;
}


+ (H2RocheAviva *)sharedInstance
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




