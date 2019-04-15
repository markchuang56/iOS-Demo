//
//  ACCompactPlus.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/28.
//
//

#import "H2AudioFacade.h"
#import "ACCompactPlus.h"

#import "H2DebugHeader.h"

#import "H2Config.h"

#import "H2RocheEventProcess.h"
#import "H2DataFlow.h"

#import "H2Records.h"

#define RECORDOFFSET        4
#define HOUR_AT_3           3
#define MINUTE_AT_5         5

#define DAY_AT_7            7
#define MONTH_AT_9          9
#define YEAR_AT_11          11

#define CONTROL_AT_13       13

#define REMARK_AT_16        16




#define CURRENT_OFFSET_AT3          3

#define CURRENT_YEAR_AT0            0
#define CURRENT_MONTH_AT2           2
#define CURRENT_DAY_AT4             4

#define CURRENT_HOUR_AT0            0
#define CURRENT_MINUTE_AT2          2



@implementation H2RocheCompactPlus
{
}


- (id)init
{
    if (self = [super init]) {
    }
    return self;
}



unsigned char compactPlusCmdInit[] = {
    0x0B,
    0x0B, 0x0D
};
unsigned char compactPlusCmdBrand[] = {
    'I', 0x0D
};

unsigned char compactPlusCmdModel[] = {
    'C', ' ', '4', 0x0D
};
unsigned char compactPlusCmdSerialNumber[] = {
    'C', ' ', '3', 0x0D
};
unsigned char compactPlusCmdDate[] = {
    'S', ' ', '1', 0x0D
};
unsigned char compactPlusCmdTime[] = {
    'S', ' ', '2', 0x0D
};
unsigned char compactPlusCmdUnit[] = {
    'S', ' ', '3', 0x0D
};

unsigned char compactPlusCmdNumberOfRecord[] = {
    0x60, 0x0D
};

unsigned char compactPlusCmdReadRecord[] = {
    'a', ' ', 'X', ' ', 'X', 0x0D, 0x06
};
unsigned char compactPlusCmdAck[] = {
    0x06
};

unsigned char compactPlusCmdEnd[] = {
    0x1D, 0x0D
    
};


unsigned char compactPlusCmdReadRecord10[] = {
    'a', ' ', 'X', 'X', ' ', 'X', 'X', 0x0D, 0x06
};
unsigned char compactPlusCmdReadRecord100[] = {
    'a', ' ', 'X', 'X', 'X', ' ', 'X', 'X', 'X', 0x0D, 0x06
};


#pragma mark -
#pragma mark ACCU CHEK COMPACT COMMAND
- (void)CompactPlusCommandGeneral:(UInt16)cmdMethod
{
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    switch (cmdMethod) {
        case METHOD_INIT:
            cmdLength = sizeof(compactPlusCmdInit);
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            memcpy(cmdBuffer, compactPlusCmdInit, cmdLength);
            break;
            
        case METHOD_4:
            cmdLength = sizeof(compactPlusCmdInit);
            cmdTypeId = (currentMeter<<4) + METHOD_4;
            memcpy(cmdBuffer, compactPlusCmdInit, cmdLength);
            break;
            
        case METHOD_BRAND:
            cmdLength = sizeof(compactPlusCmdBrand);
            cmdTypeId = (currentMeter<<4) + METHOD_BRAND;
            memcpy(cmdBuffer, compactPlusCmdBrand, cmdLength);
            break;
            
        case METHOD_MODEL:
            cmdLength = sizeof(compactPlusCmdModel);
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            memcpy(cmdBuffer, compactPlusCmdModel, cmdLength);
            break;
            
        case METHOD_SN:
            cmdLength = sizeof(compactPlusCmdSerialNumber);
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            memcpy(cmdBuffer, compactPlusCmdSerialNumber, cmdLength);
            break;
            
            
            
        case METHOD_DATE:
            cmdLength = sizeof(compactPlusCmdDate);
            cmdTypeId = (currentMeter<<4) + METHOD_DATE;
            memcpy(cmdBuffer, compactPlusCmdDate, cmdLength);
            break;
            
        case METHOD_TIME:
            cmdLength = sizeof(compactPlusCmdTime);
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            memcpy(cmdBuffer, compactPlusCmdTime, cmdLength);
            break;
            
        case METHOD_UNIT:
            cmdLength = sizeof(compactPlusCmdUnit);
            cmdTypeId = (currentMeter<<4) + METHOD_UNIT;
            memcpy(cmdBuffer, compactPlusCmdUnit, cmdLength);
            break;
            
        case METHOD_NROFRECORD:
            cmdLength = sizeof(compactPlusCmdNumberOfRecord);
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            memcpy(cmdBuffer, compactPlusCmdNumberOfRecord, cmdLength);
            break;
            
        case METHOD_END:
            cmdLength = sizeof(compactPlusCmdEnd);
            cmdTypeId = (currentMeter<<4) + METHOD_END;
            memcpy(cmdBuffer, compactPlusCmdEnd, cmdLength);
            break;
            
        default:
            break;
    }

    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}



- (void)CompactPlusReadRecord:(UInt16)nIndex
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    if (nIndex <= 9) {

        compactPlusCmdReadRecord[2] = nIndex + 0x30;
        compactPlusCmdReadRecord[4] = nIndex + 0x30;
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:compactPlusCmdReadRecord withCmdLength:sizeof(compactPlusCmdReadRecord) cmdType:(currentMeter<<4) + METHOD_RECORD returnDataLength:0 mcuBufferOffSetAt:0];
        
        
    }else if (nIndex >= 10 && nIndex <= 99){

        
        compactPlusCmdReadRecord10[3] = (nIndex%10) + 0x30;
        compactPlusCmdReadRecord10[6] = (nIndex%10) + 0x30;
        
        
        compactPlusCmdReadRecord10[2] = (nIndex/10) + 0x30;
        compactPlusCmdReadRecord10[5] = (nIndex/10) + 0x30;
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:compactPlusCmdReadRecord10 withCmdLength:sizeof(compactPlusCmdReadRecord10) cmdType:(currentMeter<<4) + METHOD_RECORD returnDataLength:0 mcuBufferOffSetAt:0];
        
        
    }else{
        
        compactPlusCmdReadRecord100[4] = ((nIndex%100)%10)+ 0x30;
        compactPlusCmdReadRecord100[8] = ((nIndex%100)%10)+ 0x30;
        
        
        compactPlusCmdReadRecord100[3] = ((nIndex%100)/10)+ 0x30;
        compactPlusCmdReadRecord100[7] = ((nIndex%100)/10)+ 0x30;
        
        
        compactPlusCmdReadRecord100[2] = nIndex/100 + 0x30;
        compactPlusCmdReadRecord100[6] = nIndex/100 + 0x30;
        
        
        [[H2AudioFacade sharedInstance] sendCommandDataEx:compactPlusCmdReadRecord100 withCmdLength:sizeof(compactPlusCmdReadRecord100) cmdType:(currentMeter<<4) + METHOD_RECORD returnDataLength:0 mcuBufferOffSetAt:0];
    }
 
    
}


#pragma mark -
#pragma mark ACCU CHEK COMPACT PLUS PARSER

- (NSString *)acCompactPlusParserEx
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
#ifdef DEBUG_COMPACTPLUS
        DLog(@"the start %d, end %d %02X", begin, end, srcData[idx]);
#endif
        idx++;
    } while (idx < length);
    
    if (end <= begin || end == 0) {
        return nil;
    }
#ifdef DEBUG_COMPACTPLUS
    DLog(@"the start %d, end %d", begin, end);
#endif
    if (end) { // START ID, CHECK SUM , END
        memcpy(srcTmp, &srcData[begin+3], end - begin -3 -2);
    }
    
    NSString* string = [NSString stringWithUTF8String:(const char *)srcTmp];
    return string;
}


- (H2BgRecord *)acCompactPlusDateTimeValueParser:(BOOL)mmolUnit
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 compactPlusValue = 0;
    
    UInt8 compactPlusHour = 0;
    UInt8 compactPlusMinute = 0;
    
    UInt8 compactPlusDay = 0;
    UInt8 compactPlusMonth = 0;
    UInt16 compactPlusYear = 0;
    
    UInt8 idx=0;
    
    H2BgRecord *compactPlusRecord;
    compactPlusRecord = [[H2BgRecord alloc] init];
    compactPlusRecord.bgValue_mg = 0;
    
    do { // get start
        if (srcData[idx] == ROCHE_DATA_EOT) {
            break;
        }
        idx++;
    } while (idx < length);
    
    if (srcData[idx] != ROCHE_DATA_EOT) {
#ifdef DEBUG_COMPACTPLUS
        DLog(@"ERROR, COMPACT PLUS length is %d", length);
#endif
        compactPlusRecord.bgMealFlag = @"F";
        return compactPlusRecord;
    }
    
    idx = 0;
    do { // get start
        if (srcData[idx] == ROCHE_DATA_STX) {
            break;
        }
        idx++;
    } while (idx < length);
#ifdef DEBUG_COMPACTPLUS
    DLog(@"test word %c, %c, %c", srcData[idx+1], srcData[idx+2], srcData[idx+3]);
    DLog(@"The last value %02X %02X %02X", srcData[length-2], srcData[length-1], srcData[length-0]);
    DLog(@"the record length is %d", length);
#endif

    
    
    if ((srcData[idx+1] == '1') && (srcData[idx+2] == '2') && (srcData[idx+3] == '0')) {
        compactPlusValue = (srcData[idx+RECORDOFFSET+0]-0x30)*100 + (srcData[idx+RECORDOFFSET+1]-0x30)*10 + (srcData[idx+RECORDOFFSET+2]-0x30);
        
        
        compactPlusHour = (srcData[idx+RECORDOFFSET+HOUR_AT_3]-0x30)*10 + (srcData[idx+RECORDOFFSET+HOUR_AT_3+1]-0x30);
        compactPlusMinute = (srcData[idx+RECORDOFFSET+MINUTE_AT_5]-0x30)*10 + (srcData[idx+RECORDOFFSET+MINUTE_AT_5+1]-0x30);
        
        // date
        
        compactPlusDay = (srcData[idx+RECORDOFFSET+DAY_AT_7]-0x30)*10 + (srcData[idx+RECORDOFFSET+DAY_AT_7+1]-0x30);
        compactPlusMonth = (srcData[idx+RECORDOFFSET+MONTH_AT_9]-0x30)*10 + (srcData[idx+RECORDOFFSET+MONTH_AT_9+1]-0x30);
        compactPlusYear = (srcData[idx+RECORDOFFSET+YEAR_AT_11]-0x30)*10 + (srcData[idx+RECORDOFFSET+YEAR_AT_11+1]-0x30) + 2000;
        
        
        
        
        compactPlusRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",compactPlusYear, compactPlusMonth, compactPlusDay, compactPlusHour, compactPlusMinute];
#ifdef DEBUG_COMPACTPLUS
        DLog(compactPlusRecord.bgDateTime, nil);
#endif
        
        if (mmolUnit) {
            compactPlusRecord.bgValue_mmol = (float)compactPlusValue/MMOL_COIF;
            compactPlusRecord.bgUnit = BG_UNIT_EX;
        }else{
            compactPlusRecord.bgValue_mg = compactPlusValue;
            compactPlusRecord.bgUnit = BG_UNIT;
        }
        
        if (srcData[idx+RECORDOFFSET+REMARK_AT_16]== '1') { // REMARK
            compactPlusRecord.bgMealFlag = @"R";
        }
        if (srcData[idx+RECORDOFFSET+CONTROL_AT_13]== '2') { // CONTROL SOLUTION
            compactPlusRecord.bgMealFlag = @"E";
        }
    }else{
        compactPlusRecord.bgMealFlag = @"E";
    }
    if (compactPlusDay == 0 || compactPlusMonth == 0) {
        compactPlusRecord.bgMealFlag = @"E";
    }
    if (![compactPlusRecord.bgMealFlag isEqualToString:@"E"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:compactPlusRecord.bgDateTime]) {
            compactPlusRecord.bgMealFlag = @"E";
        }
    }
    
    return compactPlusRecord;
}






- (NSString *)acCompactPlusDateParserEx
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
    

    
    // date
    currentYear = (srcData[begin+CURRENT_OFFSET_AT3]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+1]-0x30) + 2000;
    currentMonth = (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MONTH_AT2]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MONTH_AT2+1]-0x30);
    currentDay = (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_DAY_AT4]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_DAY_AT4+1]-0x30);
    
    NSString *string = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d",currentYear, currentMonth, currentDay];
    
    return string;
}


- (NSString *)acCompactPlusTimeParserEx:(NSString *)dateString
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
    
    
    currentHour = (srcData[begin+CURRENT_OFFSET_AT3]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+1]-0x30);
    currentMinute = (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MINUTE_AT2]-0x30)*10 + (srcData[begin+CURRENT_OFFSET_AT3+CURRENT_MINUTE_AT2+1]-0x30);
    
    NSString* string = [[NSString alloc] initWithFormat:@"%02d:%02d:00 +0000",currentHour, currentMinute];
    NSString *result= [NSString stringWithFormat:@"%@ %@", dateString, string];
    
    return result;
}


+ (H2RocheCompactPlus *)sharedInstance
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
