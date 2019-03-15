//
//  DACollection.m
//  FR_W310B
//
//  Created by h2Sync on 2018/3/13.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import "DACollection.h"

@interface DACollection() {
    
    NSString *curDate;
    NSString *curTime;
}

@end

@implementation DACollection

- (id)init
{
    if (self = [super init]) {
        curDate = @"";
        curTime = @"";
        
        _arkrayGlobalArray = [[NSMutableArray alloc] init];
    }
    return self;
}
- (NSString *)howToGetCurrentDateTime
{
    //Byte *_foraCmdBuffer = (Byte *)malloc(6);
    NSDate *now = [[NSDate alloc] init];
    NSLog(@"CT IS ONE --> %@", now);
    
    NSDate *currentTime = [NSDate date];
    NSLog(@"CT IS TWO --> %@", currentTime);
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
    
    //NSString *ctString = [NSString stringWithFormat:@"%04d-%02d-%02dT%02d%02d%02d", [components year], [components month], [components day], [components hour], [components minute], [components second]];
    UInt16 year = [components year];
    UInt8 month = [components month];
    UInt8 day = [components day];
    
    UInt8 hour = [components hour];
    UInt8 minute = [components minute];
    UInt8 second = [components second];
    
    NSString *ctString = [NSString stringWithFormat:@"%04d-%02d-%02dT%02d%02d%02d", year, month, day, hour, minute, second];
    
    NSLog(@"CURRENT TIME IS = %@", ctString);
    
    return ctString;
}



- (void)howToGetCurrentTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *h2CurrentDateTime =  [[NSDate alloc] init];
    NSString *currentDateTime = [NSString stringWithFormat:@"%@", h2CurrentDateTime];
    
    NSString *h2CurrentDate = [currentDateTime substringWithRange:NSMakeRange(0, 10)];
    NSString *h2CurrentTime = [currentDateTime substringWithRange:NSMakeRange(11, 8)];
    
    NSLog(@"DATE IS %@, TIME IS %@", h2CurrentDate, h2CurrentTime);
}

#pragma mark - ====== SYSTEM CURRENT TIME ======
- (Byte *)systemCurrentTime
{
    NSDate *now = [[NSDate alloc] init];
    //#ifdef DEBUG_BW
    NSLog(@"SYTEM CT IS --> %@", now);
    //#endif
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
    
    Byte *timeTmp = (Byte *)malloc(7);
    UInt16 year = [components year];
    memcpy(timeTmp, &year, 2);
    timeTmp[2] = [components month];
    timeTmp[3] = [components day];
    
    timeTmp[4] = [components hour];
    timeTmp[5] = [components minute];
    timeTmp[6] = [components second];
    
    return timeTmp;
}

#pragma mark - WRITE FILE TEST
- (void)howToWriteFile:(NSString *)headForFile
{
    // WRITE FILE TEST
    //NSString *logFile = [NSString stringWithFormat:@"%@_%@_%@",headForFile, h2CurrentDate, h2CurrentTime];
    //NSString *logFile = [NSString stringWithFormat:@"HOW_COME"];
    NSString *logFile = [NSString stringWithFormat:@"HW"];
    NSString *fileName1ST = [NSString stringWithFormat:@"Documents/%@_ONE%@.txt",logFile, headForFile];
    NSString  *filePath1ST = [NSHomeDirectory() stringByAppendingPathComponent:fileName1ST];
    
    NSDictionary *src = [[NSDictionary alloc] init];
    [src writeToFile:filePath1ST atomically:YES];
    
    NSString *fileName2ND = [NSString stringWithFormat:@"Documents/%@_TWO%@.txt",logFile, headForFile];
    NSString  *filePath2ND = [NSHomeDirectory() stringByAppendingPathComponent:fileName2ND];
    
    NSMutableArray *srcArray = [[NSMutableArray alloc] init];
    Byte *da1 = (Byte *)malloc(8);
    NSString *stringOne = [[NSString alloc] init];
    for (int i=0; i<8; i++) {
        da1[i] = i;
        stringOne = [stringOne stringByAppendingString:[NSString stringWithFormat:@"%02X ", da1[i]]];
    }
    
    Byte *da2 = (Byte *)malloc(8);
    NSString *stringTwo = [[NSString alloc] init];
    for (int i=0; i<8; i++) {
        da2[i] = 8-i;
        stringTwo = [stringTwo stringByAppendingString:[NSString stringWithFormat:@"%02X ", da2[i]]];
    }
    [srcArray addObject:stringOne];
    [srcArray addObject:stringTwo];
    [srcArray writeToFile:filePath2ND atomically:YES];
}

- (void)saveDataToFile:(NSArray *)srcData withFileName:(NSString *)fileName
{
    NSString *dateTime = [self howToGetCurrentDateTime];
    NSString *logFile = [NSString stringWithFormat:@"Documents/%@_%@.txt", fileName, dateTime];
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:logFile];
    
    [srcData writeToFile:logPath atomically:YES];
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
        if ((STR_YEAR_EASY + totalYear)%4==0 && (STR_YEAR_EASY + totalYear)%100!=0) {
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
            if(totalDay >= NORMAL_YEAR_365){
                totalDay -= NORMAL_YEAR_365;
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
    ultraMiniYear = STR_YEAR_EASY + totalYear;
    
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

+ (DACollection *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
@end
