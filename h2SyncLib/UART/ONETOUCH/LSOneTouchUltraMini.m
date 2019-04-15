//
//  LSOneTouchUltraMini.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//

#import "H2AudioFacade.h"
#import "LSOneTouchUltraMini.h"

#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"
#import "H2BleEquipId.h"

@implementation LSOneTouchUltraMini{
}

- (id)init
{
    if (self = [super init]) {
        _didUseMmolUnit = NO;
    }
    return self;
}

+ (LSOneTouchUltraMini *)sharedInstance
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

//unsigned char cmdPowerOn[]={0x002, 0x0E, 0x00, 0x05, 0x09, 0x02, 0x09, 0x00, 0x00, 0x00, 0x00, 0x03, 0xCE, 0xE7};
unsigned char ack1[] = {0x02, 0x06, 0x07, 0x03, 0xFC, 0x72};

//unsigned char cmdSetRtc[]={0x02, 0x0D, 0x03, 0x05, 0x20, 0x02, 0x00, 0x00, 0x00, 0x00, 0x03, 0xA8, 0x4C};


unsigned char cmdVersion[]={0x02, 0x09, 0x00, 0x05, 0x0D, 0x02, 0x03, 0xDA, 0x71};
//unsigned char cmdSerialNr[]=
//{0x02, 0x12, 0x00, 0x05, 0x0B, 0x02, 0x00, 0x00, 0x00, 0x00, 0x84, 0x6A, 0xE8, 0x73, 0x00, 0x03, 0x9B, 0xEA};
unsigned char cmdNumOfRecord[] =
{0x02, 0x0A, 0x03, 0x05, 0x1F, 0xF5, 0x01, 0x03, 0xD8, 0x64};
unsigned char cmdRecord[] =
{0x02, 0x0A, 0x03, 0x05, 0x1F, 0x00, 0x00, 0x03, 0x4B, 0x5F}; // 00


unsigned char cmdCurrentDateTime[] =
{
    0x02, 0x0D, 0x00, 0x05, 0x20, 0x02, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00// 0xEC, 0x61
};
unsigned char cmdCurrentUnit[] =
{
    0x02, 0x0E, 0x00, 0x05, 0x09, 0x02, 0x09, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00// 0xCE, 0xE7
};
unsigned char cmdSerialNumber[] =
{
    0x02, 0x12, 0x00, 0x05, 0x0B, 0x02, 0x00, 0x00, 0x00, 0x00,
    0x84, 0x6A, 0xE8, 0x73, 0x00, 0x03, 0x00, 0x00// 0x9B, 0xEA
};


- (void)UltraMiniCommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    UInt16 crcTmp = 0;
    switch (cmdMethod) {

        case METHOD_SN:
            cmdLength = sizeof(cmdSerialNumber);
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            memcpy(cmdBuffer, cmdSerialNumber, cmdLength);
            break;
            
        case METHOD_TIME:
            cmdLength = sizeof(cmdCurrentDateTime);
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            memcpy(cmdBuffer, cmdCurrentDateTime, cmdLength);
            break;
            
        case METHOD_UNIT:
            cmdLength = sizeof(cmdCurrentUnit);
            cmdTypeId = (currentMeter<<4) + METHOD_UNIT;
            memcpy(cmdBuffer, cmdCurrentUnit, cmdLength);
            break;
            
        case METHOD_NROFRECORD:
            cmdLength = sizeof(cmdNumOfRecord);
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            memcpy(cmdBuffer, cmdNumOfRecord, cmdLength);
            break;
            
        default:
            break;
    }
#ifdef DEBUG_ONETOUCH
    DLog(@"BLE_MINI DEBUG %02X, %02X, %02X", cmdMethod, currentMeter, cmdLength);
#endif
    crcTmp = [self crc_calculate_crc:0xFFFF inSrc:cmdBuffer inLength:cmdLength - 2];
    memcpy(&cmdBuffer[cmdLength - 2], &crcTmp, 2);
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType: cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}

- (void)UltraMiniReadRecord:(UInt16)nIndex
{
    UInt16 ultraMiniCmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_RECORD;
    unsigned char cmdTmp[sizeof(cmdRecord)];
    UInt16 crcTmp = 0;
    
    memcpy(cmdTmp, cmdRecord, sizeof(cmdTmp)-2);
    memcpy(&cmdTmp[5], &nIndex, 2);
    crcTmp = [self crc_calculate_crc:0xFFFF inSrc:cmdTmp inLength:sizeof(cmdTmp)-2];
    memcpy(&cmdTmp[sizeof(cmdTmp)-2], &crcTmp, 2);
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdTmp withCmdLength:sizeof(cmdTmp) cmdType:ultraMiniCmdType
                   returnDataLength:0 mcuBufferOffSetAt:0];
  
}


- (unsigned short)crc_calculate_crc :(unsigned short)initial_crc inSrc : (const unsigned char *)buffer inLength :(unsigned short) length
{
    unsigned short index = 0; unsigned short crc = initial_crc;
    if (buffer != NULL) { // OneTouch Ultra Mini CRC
        for (index = 0; index < length; index++) {
#ifdef DEBUG_ONETOUCH
            DLog(@"VUE DATA %d, %02X", index, buffer[index]);
#endif
            crc = (unsigned short)((unsigned char)(crc >> 8) | (unsigned short)(crc << 8)); crc ^= buffer [index];
            crc ^= (unsigned char)(crc & 0xff) >> 4;
            crc ^= (unsigned short)((unsigned short)(crc << 8) << 4);
            crc ^= (unsigned short)((unsigned short)((crc & 0xff) << 4) << 1); }
    }
#ifdef DEBUG_ONETOUCH
    DLog(@"VUE CRC IS %04X", crc);
#endif
    return crc;
}

/*
addr = 0 data = 32
addr = 1 data = 06
addr = 2 data = 1D
addr = 3 data = 00
addr = 4 data = 00
addr = 5 data = 00
addr = 6 data = 02
addr = 7 data = 06
addr = 8 data = 05
addr = 9 data = 03
addr = 10 data = 9E
addr = 11 data = 14
addr = 12 data = 02
addr = 13 data = 10
addr = 14 data = 01
addr = 15 data = 05
addr = 16 data = 06
addr = 17 data = E2
addr = 18 data = E8
addr = 19 data = 63
addr = 20 data = 53
addr = 21 data = 5B
addr = 22 data = 00
addr = 23 data = 00
addr = 24 data = 00
addr = 25 data = 03
addr = 26 data = 89
addr = 27 data = 43
addr = 28 data = 19
*/

- (H2BgRecord *)ultraMiniDateTimeValueParser//:(BOOL)mmolUnit
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt32 inSecond = 0;
    UInt32 value = 0;
    
    memcpy(&inSecond, &[H2AudioAndBleSync sharedInstance].dataBuffer[11], 4);
    memcpy(&value, &[H2AudioAndBleSync sharedInstance].dataBuffer[15], 4);
#ifdef DEBUG_ONETOUCH
    DLog(@"ULTRA EASY - VALUE IS %d", (int)value);
#endif
/*
    UInt32 totalMinute;
    UInt32 totalHour;
    UInt32 totalDay;
    
    UInt32 ultraMiniSecond;
    UInt32 ultraMiniMinute;
    UInt32 ultraMiniHour;
    UInt32 ultraMiniDay;
    
    
    UInt32 ultraMiniMonth;
    UInt32 ultraMiniYear;
    UInt32 totalYear;
    
    UInt16 x=1972,y=0;
*/

    float mmolValue = 0.0;
    if (value >= 600) {
        value = 600;
    }
    
    mmolValue = (float)value/MMOL_COIF;
/*
    totalMinute = inSecond / 60;
    ultraMiniSecond = inSecond % 60;// - totalMinute * 60;
    totalHour = totalMinute / 60;
    ultraMiniMinute = totalMinute % 60;// - totalHour*60;
    totalDay = totalHour / 24;
    ultraMiniHour = totalHour % 24;// - totalDay * 24;
    totalYear = totalDay / 365;
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ONETOUCH the year is %lu", (long)(1970 + totalYear));
#endif
    //    currentYear = 1970 + totalYear;
    do{
        x += 4;
        y++;
    }while (x < 1970 + totalYear) ;

    ultraMiniDay = totalDay -(totalYear * 365);
    if (ultraMiniDay <= y) {
        totalYear--;
        ultraMiniDay = totalDay -(totalYear * 365);
    }
    ultraMiniYear = 1970 + totalYear;
    ultraMiniDay -= y;
    
    y = 0;

    for (y =0; y<12; y++) {
        if (y == 0) {  // Feb
            if (ultraMiniDay>=31) {
                ultraMiniDay -=31;
            }else{
                break;
            }
        }else if (y==1){ // Jan
            if (ultraMiniYear%4) {
                if (ultraMiniDay >= 28) {
                    ultraMiniDay -= 28;
                }else{
                    break;
                }
            }else{
                if (ultraMiniDay >= 29) {
                    ultraMiniDay -= 29;
                }else{
                    break;
                }
                
            }
            
        }else{ // the others
            if ((!(y%2) && y<7) || ((y%2) && y>= 7)) { // 3, 5, 7, 8, 10, 12
                if (ultraMiniDay>=31) {
                    ultraMiniDay -= 31;
                }else{
                    break;
                }
            }else{ // 4, 6, 9, 11
                if (ultraMiniDay>=30) {
                    ultraMiniDay -= 30;
                }else{
                    break;
                }
                
                
            }
            
        }
    }
    if (y<12) {
        ultraMiniMonth = y+1;
    }else{
        ultraMiniMonth = 1;
        ultraMiniYear++;
    }
    ultraMiniDay++;
    
*/
    H2BgRecord *ultraMiniRecord;
    ultraMiniRecord = [[H2BgRecord alloc] init];


    
//    ultraMiniRecord.bgIndex = index;
    
/*
    ultraMiniRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000",(unsigned int)ultraMiniYear, (unsigned int)ultraMiniMonth, (unsigned int)ultraMiniDay, (unsigned int)ultraMiniHour, (unsigned int)ultraMiniMinute, (unsigned int)ultraMiniSecond];
*/
    ultraMiniRecord.bgDateTime = [self dateTimeParser:inSecond];
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ONETOUCH date time is %@", ultraMiniRecord.bgDateTime);
#endif

    if (_didUseMmolUnit) {
        ultraMiniRecord.bgValue_mmol = mmolValue;
        ultraMiniRecord.bgUnit = BG_UNIT_EX;
#ifdef DEBUG_ONETOUCH
        DLog(@"DEBUG_ONETOUCH the mmol debug ------- ");
#endif
    }else{
        ultraMiniRecord.bgUnit = BG_UNIT;
        ultraMiniRecord.bgValue_mg = value;
    }
    
    if (![ultraMiniRecord.bgMealFlag isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:ultraMiniRecord.bgDateTime]) {
            ultraMiniRecord.bgMealFlag = @"C";
        }
    }
    
    return ultraMiniRecord;
}

- (NSString *)ultraMiniSerialNumberParserEx
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    UInt8 idx=0;
    
    char srcTmp[12] = {0};
    
    
    do {
        if (srcData[idx] == 0x03) {
            break;
        }
        idx++;
    } while (idx < length);
    idx += 3;
    
    do {
        if (srcData[idx] == 0x05) {
            break;
        }
        idx++;
    } while (idx < length);
    
    if ((length - idx) > 10) {
        memcpy(srcTmp, &srcData[idx+2], 9);
    }
    
    NSString *serialNumber = [NSString stringWithUTF8String:(const char *)srcTmp];
#ifdef DEBUG_ONETOUCH
    NSRange miniSerialNumber = [serialNumber rangeOfString:@"FFZ049BER"];    
    if (miniSerialNumber.location != NSNotFound) {
        DLog(@"DEBUG_ONETOUCH get ultra mini Serial Number -+-+");
    }
#endif
    return serialNumber;
}

- (NSString *)ultraMiniCurrentDateTimeParserEx
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    
    UInt32 dateTime = 0;
    
    
    do {
        if (srcData[idx] == 0x03) {
            break;
        }
        idx++;
    } while (idx < length);
    idx += 3;
    
    do {
        if (srcData[idx] == 0x05) {
            break;
        }
        idx++;
    } while (idx < length);
    
    memcpy(&dateTime, &srcData[idx+2], 4);
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ONETOUCH time is %2X, %2X, %2X, %2X,", srcData[idx+2], srcData[idx+3], srcData[idx+4], srcData[idx+5]);
#endif
    NSString *string = [self dateTimeParser:dateTime];

    return string;
}


- (NSString *)dateTimeParser:(UInt32)inSecond
{
    UInt32 totalMinute;
    UInt32 totalHour;
    UInt32 totalDay;

    UInt32 ultraMiniMinute;
    UInt32 ultraMiniHour;
    UInt32 ultraMiniDay;


    UInt32 ultraMiniMonth;
    UInt32 ultraMiniYear;
    UInt32 totalYear;
    
    UInt16 yearOffset = STR_YEAR_EASY;
    
    if ([H2DataFlow sharedDataFlowInstance].equipId== SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX) {
        yearOffset = STR_YEAR_FLEX;
    }
    
    UInt16 y=0;
    totalMinute = inSecond / 60;
    totalHour = totalMinute / 60;
    ultraMiniMinute = totalMinute - totalHour*60;
    totalDay = totalHour / 24;
    ultraMiniHour = totalHour - totalDay * 24;

#ifdef DEBUG_ONETOUCH
    DLog(@"2015 天數 %d, %d", (365 * 13 + 366 * 3), (int)totalDay - (365 * 13 + 366 * 3));
    
    DLog(@"2016 天數 %d, %d", (365 * 13 + 366 * 4), (int)totalDay-(365 * 13 + 366 * 4));
    
    
    DLog(@"2019 天數 %d, %d", (365 * 16 + 366 * 4), (int)totalDay - (365 * 16 + 366 * 4));
    
    DLog(@"2020 天數 %d, %d", (365 * 16 + 366 * 5), (int)totalDay-(365 * 16 + 366 * 5));
#endif
    
    // new ...
    totalDay--;
    totalYear = 0;
    while(totalDay>0){
#ifdef DEBUG_ONETOUCH
        DLog(@" YEAR YEAR  %d and DAY DAY %d", (int)totalYear, (int) totalDay);
#endif
        if ((yearOffset + totalYear)%4==0 && (yearOffset + totalYear)%100!=0) {
            if(totalDay>=LEAP_YEAR){
                totalDay -= LEAP_YEAR;
#ifdef DEBUG_ONETOUCH
                DLog(@" YEAR YEAR  %d 潤年 ----", (int)totalYear);
#endif
            }else{
#ifdef DEBUG_ONETOUCH
                DLog(@" YEAR YEAR  %d 潤年 結束", (int)totalYear);
#endif
                break;
            }
        }else{
            if(totalDay>=NORMAL_YEAR){
                totalDay -= NORMAL_YEAR;
#ifdef DEBUG_ONETOUCH
                DLog(@" YEAR YEAR  %d 平年 ---", (int)totalYear);
#endif
            }else{
#ifdef DEBUG_ONETOUCH
                DLog(@" YEAR YEAR  %d 平年 結束", (int)totalYear);
#endif
                break;
            }
        }
        totalYear++;
#ifdef DEBUG_ONETOUCH
        DLog(@" YEAR YEAR  %d 後面", (int)totalYear);
#endif
    };
    
    ultraMiniDay  = totalDay;
    ultraMiniYear = yearOffset + totalYear;

#ifdef DEBUG_ONETOUCH
    DLog(@"(天數 %d, 年 %d", (int)ultraMiniDay, (int)ultraMiniYear);
    DLog(@"最後天數 %d", (int)ultraMiniDay);
#endif
    
    y = 0;

    for (y =0; y<12; y++) {
        if (y == 0) {  // Jan
            if (ultraMiniDay>=31) {
                ultraMiniDay -=31;
            }else{
                break;
            }
        }else if (y==1){ // Feb
            if (ultraMiniYear%4) {
                if (ultraMiniDay >= 28) {
                    ultraMiniDay -= 28;
                }else{
                    break;
                }
            }else{
                if (ultraMiniDay >= 29) {
                    ultraMiniDay -= 29;
                }else{
                    break;
                }
            
            }
        }else{ // the others
            if ((!(y%2) && y<7) || ((y%2) && y>= 7)) { // 3, 5, 7, 8, 10, 12
                if (ultraMiniDay>=31) {
                    ultraMiniDay -= 31;
                }else{
                    break;
                }
            }else{ // 4, 6, 9, 11
                if (ultraMiniDay>=30) {
                    ultraMiniDay -= 30;
                }else{
                    break;
                }
            }
        }
    }
    if (y<12) {
        ultraMiniMonth = y+1;
    }else{
        ultraMiniMonth = 1;
        ultraMiniYear++;
    }
    ultraMiniDay++;


    NSString *stringDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",(unsigned int)ultraMiniYear, (unsigned int)ultraMiniMonth, (unsigned int)ultraMiniDay, (unsigned int)ultraMiniHour, (unsigned int)ultraMiniMinute];
#ifdef DEBUG_ONETOUCH
    DLog(@"ULTRA EASY - 年月日: %@", stringDateTime);
#endif
    return stringDateTime;
}

@end
