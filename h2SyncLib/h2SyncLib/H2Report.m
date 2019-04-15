//
//  H2Report.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/14.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "H2DebugHeader.h"
#import "H2Report.h"
#import "H2Config.h"
#import "Fora.h"
#import "H2Records.h"
#import "H2LastDateTime.h"

#import "H2BleBgm.h"


@implementation H2SyncReport

- (id)init
{
    if (self = [super init]) {
        
        _h2BgRecordReportIndex = 0;
        _h2BpRecordReportIndex = 0;
        _h2BwRecordReportIndex = 0;
        
        _bgLdtIndex = 0;
        
        _h2BgRecordReportArray = [[NSMutableArray alloc] init];
        _h2BpRecordReportArray = [[NSMutableArray alloc] init];
        _h2BwRecordReportArray = [[NSMutableArray alloc] init];
        
        _h2MultableLastDateTime = [[NSMutableArray alloc] init];
        
        _recordsArray = [[NSMutableArray alloc] init];
 
         //_tmpBgRecord = [[H2BgRecord alloc] init];
         _reportMeterInfo = [[H2MeterSystemInfo alloc] init];
        
        _h2StatusCode = 0;
        
        _bgHasBeenSkip = 0;
        _bpHasBeenSkip = 0;
        _bwHasBeenSkip = 0;
        
        
        _isMeterWithNewRecords = NO;
        _didSyncRecordFinished = NO;
        _hasSMSingleRecord = NO;
        _hasMultiRecords = NO;
        _didSendEquipInformation = NO;
        _didEquipInfoDone = NO;
        _didSyncFail = NO;
        
        _serverBgLastDateTime = @"";
        _serverBpLastDateTime = @"";
        _serverBwLastDateTime = @"";
        
        _cableBayerLastDateTime = @"";
        
        _userIdentifier = @"";
        _userEMail = @"";

        _tmpDateTimeForVue = @"";
    }
    return self;
}

+ (H2SyncReport *)sharedInstance
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

- (void)h2SyncNewMeterChecking
{
    
#ifdef DEBUG_LIB
    // FOR TEST
    if ([H2SyncDebug sharedInstance].zeroRecord) {
        [H2AudioAndBleSync sharedInstance].recordTotal = 0;
    }
#endif
    _didSendEquipInformation = YES;
    
    if ([H2AudioAndBleSync sharedInstance].recordTotal == 0) {
        _didSyncRecordFinished = YES;
    }
}



- (UInt8)h2SyncOmnisDidGreateThanPrevious
{
    
#ifdef DEBUG_LIB
    DLog(@"NEW TIME (OMNIS) ... %@", [H2Records sharedInstance].bgTmpRecord.bgDateTime);
    DLog(@"OLD TIME (OMINS) ... %@", _serverBgLastDateTime);
#endif
    
    // NEW
    NSString *newYearString = [[H2Records sharedInstance].bgTmpRecord.bgDateTime substringWithRange:NSMakeRange(0,4)];
    NSString *newMonthString = [[H2Records sharedInstance].bgTmpRecord.bgDateTime substringWithRange:NSMakeRange(5,2)];
    NSString *newDayString = [[H2Records sharedInstance].bgTmpRecord.bgDateTime substringWithRange:NSMakeRange(8,2)];
    
    NSString *newHourString = [[H2Records sharedInstance].bgTmpRecord.bgDateTime substringWithRange:NSMakeRange(11,2)];
    NSString *newMinString = [[H2Records sharedInstance].bgTmpRecord.bgDateTime substringWithRange:NSMakeRange(14,2)];
    
    unsigned long newYearValue = [newYearString intValue];
    unsigned long newMonthValue = [newMonthString intValue];
    unsigned long newDayValue = [newDayString intValue];
    
    unsigned long newHourValue = [newHourString intValue];
    unsigned long newMinValue = [newMinString intValue];
    
    unsigned long newDateTimeValue = newYearValue * 1000000 + newMonthValue * 31 * 24 * 60 + newDayValue * 24 * 60 + newHourValue * 60 + newMinValue;
    
    // OLD
    NSString *oldYearString = [_serverBgLastDateTime substringWithRange:NSMakeRange(0,4)];
    NSString *oldMonthString = [_serverBgLastDateTime substringWithRange:NSMakeRange(5,2)];
    NSString *oldDayString = [_serverBgLastDateTime substringWithRange:NSMakeRange(8,2)];
    
    NSString *oldHourString = [_serverBgLastDateTime substringWithRange:NSMakeRange(11,2)];
    NSString *oldMinString = [_serverBgLastDateTime substringWithRange:NSMakeRange(14,2)];
    
    unsigned long oldYearValue = [oldYearString intValue];
    unsigned long oldMonthValue = [oldMonthString intValue];
    unsigned long oldDayValue = [oldDayString intValue];
    
    unsigned long oldHourValue = [oldHourString intValue];
    unsigned long oldMinValue = [oldMinString intValue];
    
    unsigned long oldDateTimeValue = oldYearValue * 1000000+ oldMonthValue * 31 * 24 * 60 + oldDayValue * 24 * 60 + oldHourValue * 60 + oldMinValue;
#ifdef DEBUG_LIB
    DLog(@"STRING TO NUMBER TEST TOTAL NEW - %lu", newDateTimeValue);
    DLog(@"STRING TO NUMBER TEST YEAR NEW - %lu", newYearValue * 1000000);
    DLog(@"STRING TO NUMBER TEST MONTH NEW - %lu", newMonthValue);
    DLog(@"STRING TO NUMBER TEST DAY NEW - %lu", newDayValue);
    
    DLog(@"STRING TO NUMBER TEST MIN NEW - %lu", newHourValue);
    DLog(@"STRING TO NUMBER TEST SEC NEW - %lu", newMinValue);
//
    DLog(@"STRING TO NUMBER TEST TOTAL OLD - %lu", oldDateTimeValue);
    DLog(@"STRING TO NUMBER TEST YEAR OLD - %lu", oldYearValue * 1000000);
    DLog(@"STRING TO NUMBER TEST MONTH OLD - %lu", oldMonthValue);
    DLog(@"STRING TO NUMBER TEST DAY OLD - %lu", oldDayValue);
    
    DLog(@"STRING TO NUMBER TEST MIN OLD - %lu", oldHourValue);
    DLog(@"STRING TO NUMBER TEST SEC OLD - %lu", oldMinValue);
#endif
    if (newDateTimeValue > oldDateTimeValue) { // GREAT THAN
        return GREAT_THAN;
    }else if(newDateTimeValue < oldDateTimeValue){ // LESS THAN
        return LESS_THAN;
    }else{ // EQUAL TO
        return EQUTO_TO;
    }
}

- (BOOL)h2SyncBgDidGreateThanLastDateTime
{

#ifdef DEBUG_LIB
    DLog(@"BG - NEW TIME ... %@", [H2Records sharedInstance].bgTmpRecord.bgDateTime);
    DLog(@"BG - OLD TIME ... %@", _serverBgLastDateTime);
#endif
    if ([_serverBgLastDateTime isEqualToString:@""]) {
        _serverBgLastDateTime = DEF_LAST_DATE_TIME;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *meterDateTime =  [[NSDate alloc]init];
    meterDateTime = [dateFormatter dateFromString:[H2Records sharedInstance].bgTmpRecord.bgDateTime];
    
    NSDate *serverDateTime =  [[NSDate alloc]init];
    serverDateTime = [dateFormatter dateFromString:_serverBgLastDateTime];
    
    
    NSComparisonResult result = [meterDateTime compare:serverDateTime];
    if (result == NSOrderedDescending){ // new
        return YES;
    }else{
        [H2BleBgm sharedInstance].willFinished = YES;
        return NO;
    }
}

- (BOOL)h2SyncBgDidGreateThanLastDateTimeNEW
{
    
#ifdef DEBUG_LIB
    DLog(@"BG - NEW TIME ... %@", [H2Records sharedInstance].bgTmpRecord.bgDateTime);
    DLog(@"BG - OLD TIME ... %@", _serverBgLastDateTime);
#endif
    if ([_serverBgLastDateTime isEqualToString:@""]) {
        _serverBgLastDateTime = DEF_LAST_DATE_TIME;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *meterDateTime =  [[NSDate alloc]init];
    meterDateTime = [dateFormatter dateFromString:[H2Records sharedInstance].bgTmpRecord.bgDateTime];
    
    NSDate *serverDateTime =  [[NSDate alloc]init];
    serverDateTime = [dateFormatter dateFromString:_serverBgLastDateTime];
    
    
    NSComparisonResult result = [meterDateTime compare:serverDateTime];
    if (result == NSOrderedDescending){ // new
        return YES;
    }else{
        [H2BleBgm sharedInstance].willFinished = YES;
        return NO;
    }
}

- (BOOL)h2SyncBpDidGreateThanLastDateTime
{
    
#ifdef DEBUG_LIB
    DLog(@"BP - NEW TIME ... %@", [H2Records sharedInstance].bpTmpRecord.bpDateTime);
    DLog(@"BP - OLD TIME ... %@", _serverBpLastDateTime);
#endif
    if ([_serverBpLastDateTime isEqualToString:@""]) {
        _serverBpLastDateTime = DEF_LAST_DATE_TIME;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *meterDateTime =  [[NSDate alloc]init];
    //meterDateTime = [dateFormatter dateFromString:_tmpRecord.smRecordDateTime];
    meterDateTime = [dateFormatter dateFromString:[H2Records sharedInstance].bpTmpRecord.bpDateTime];
    
    NSDate *serverDateTime =  [[NSDate alloc]init];
    serverDateTime = [dateFormatter dateFromString:_serverBpLastDateTime];
    
    
    NSComparisonResult result = [meterDateTime compare:serverDateTime];
    if (result == NSOrderedDescending){ // new
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)h2SyncBwDidGreateThanLastDateTime
{
    
#ifdef DEBUG_LIB
    DLog(@"BW (TIME CHECK) - NEW TIME ... %@", [H2Records sharedInstance].bwTmpRecord.bwDateTime);
    DLog(@"BW (TIME CHECK) - OLD TIME ... %@", _serverBwLastDateTime);
#endif
    if ([_serverBwLastDateTime isEqualToString:@""]) {
        _serverBwLastDateTime = DEF_LAST_DATE_TIME;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *meterDateTime =  [[NSDate alloc]init];
    //meterDateTime = [dateFormatter dateFromString:_tmpRecord.smRecordDateTime];
    meterDateTime = [dateFormatter dateFromString:[H2Records sharedInstance].bwTmpRecord.bwDateTime];
    
    NSDate *serverDateTime =  [[NSDate alloc]init];
    serverDateTime = [dateFormatter dateFromString:_serverBwLastDateTime];
    
    
    NSComparisonResult result = [meterDateTime compare:serverDateTime];
    if (result == NSOrderedDescending){ // new
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)didGreateMoreThanSystemTime:(NSString *)meterRecordTimeString
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *meterRecordDateTime = [meterRecordTimeString substringWithRange:NSMakeRange(0, 19)];
    NSDate *meterRecordTime =  [[NSDate alloc]init];
    meterRecordTime = [timeFormatter dateFromString:meterRecordDateTime];
    long recordDateTimeValue = [meterRecordTime timeIntervalSince1970];
#ifdef DEBUG_LIB
    DLog(@"METER Time %ld, %@", recordDateTimeValue, meterRecordTime);
    DLog(@"System Time %ld, %@", (long)[[NSDate date] timeIntervalSince1970], [NSDate date]);
    DLog(@"THE VALUE DIFF IS %ld MINUTE", (recordDateTimeValue - ((long)[[NSDate date] timeIntervalSince1970] +1800 ))/60);
#endif
    
    //    NSString *timeString = @"2015-11-06 15:02:35 +0000";
    //    meterTime = [timeFormatter dateFromString:@"2015-11-06 15:01:35"];// +0000"];
//    meterRecordTime = [timeFormatter dateFromString:[meterRecordTimeString substringWithRange:NSMakeRange(0, 19)]];
    //    meterTime = [timeFormatter dateFromString:timeString];
#ifdef DEBUG_LIB
    DLog(@"\n\n");
    DLog(@"THE METER Time is %@", meterRecordTime);
#endif
    
    
    
    if (((recordDateTimeValue - ((long)[[NSDate date] timeIntervalSince1970] +1800 ))/60) > 0){
        
#ifdef DEBUG_LIB
        DLog(@"METER GREAT THAN ... PHONE \n\n");
#endif
        switch ([H2Records sharedInstance].currentDataType) {
            case RECORD_TYPE_BG:
                _bgHasBeenSkip++;
                break;
                
            case RECORD_TYPE_BP:
                _bpHasBeenSkip++;
                break;
                
            case RECORD_TYPE_BW:
                _bwHasBeenSkip++;
                break;
                
            default:
                break;
        }
        return YES;
    }else{// Meter Record Time LESS THAN SYSTEM TIME
#ifdef DEBUG_LIB
        DLog(@"METER LESS THAN ... PHONE\n\n");
#endif
        return NO;
    }
}


- (BOOL)XXXXh2SyncBgDidGreateThanLastDateTime
{
    
#ifdef DEBUG_LIB
    DLog(@"BG - NEW TIME ... %@", [H2Records sharedInstance].bgTmpRecord.bgDateTime);
    DLog(@"BG - OLD TIME ... %@", _serverBgLastDateTime);
#endif
    if ([_serverBgLastDateTime isEqualToString:@""]) {
        _serverBgLastDateTime = DEF_LAST_DATE_TIME;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *meterDateTime =  [[NSDate alloc]init];
    meterDateTime = [dateFormatter dateFromString:[H2Records sharedInstance].bgTmpRecord.bgDateTime];
    
    NSDate *serverDateTime =  [[NSDate alloc]init];
    serverDateTime = [dateFormatter dateFromString:_serverBgLastDateTime];
    
    
    NSComparisonResult result = [meterDateTime compare:serverDateTime];
    if (result == NSOrderedDescending){ // new
        return YES;
    }else{
        [H2BleBgm sharedInstance].willFinished = YES;
        return NO;
    }
}


- (BOOL)h2SyncBgDidGreateThanVueLastDateTime
{
    
#ifdef DEBUG_LIB
    DLog(@"BG - RECORD DATE TIME ... %@", [H2Records sharedInstance].bgTmpRecord.bgDateTime);
    DLog(@"BG - VUE LAST DATE TIME ... %@", _tmpDateTimeForVue);
#endif
    if ([_tmpDateTimeForVue isEqualToString:@""]) {
        _tmpDateTimeForVue = DEF_LAST_DATE_TIME;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *meterDateTime =  [[NSDate alloc]init];
    meterDateTime = [dateFormatter dateFromString:[H2Records sharedInstance].bgTmpRecord.bgDateTime];
    
    NSDate *vueDateTime =  [[NSDate alloc]init];
    vueDateTime = [dateFormatter dateFromString:_tmpDateTimeForVue];
    
    
    NSComparisonResult result = [meterDateTime compare:vueDateTime];
    if (result == NSOrderedDescending){ // new
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)kmTimeFormatting:(NSString **)dateTime
{
    if ((*dateTime).length < 20) {
        return NO;
    }
    
    UInt8 date1 = [(*dateTime) characterAtIndex:4];
    UInt8 date2 = [(*dateTime) characterAtIndex:7];
    
    //UInt8 date3 = [(*dateTime) characterAtIndex:10];
    
    UInt8 time1 = [(*dateTime) characterAtIndex:13];
    UInt8 time2 = [(*dateTime) characterAtIndex:16];
    
    //0x2D, 0x3A
    if (date1 != '-' || date2 != '-' || time1 != ':' || time2 != ':') {
        return NO;
    }
    
    //if (date3 == 'T') {
    //    return NO;
    //}
    
    NSString *dateTmp = [(*dateTime) substringWithRange:NSMakeRange(0, 10)];
    NSString *timeTmp = [(*dateTime) substringWithRange:NSMakeRange(11, 8)];
    
    //NSString *dateTimetmp = [NSString stringWithFormat:@"%@ %@ +0000", dateTmp, timeTmp];
    
    (*dateTime) = [NSString stringWithFormat:@"%@ %@ +0000", dateTmp, timeTmp];
    
 /*
    UInt8 ch = 0;
    for(NSUInteger i=0; i<_serverBgLastDateTime.length; i++){
        ch = [_serverBgLastDateTime characterAtIndex:i];
        DLog(@"IDX = %d, VAL = %02X", (int)i, ch);
    }
  */
    return YES;
}

- (unsigned char)h2NumericToChar:(unsigned char)num
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
            ch = num + 0x30;
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

@end

#pragma mark - SYSTEM CURRENT DATE TIME OBJECT
@implementation H2SystemDateTime
- (id)init
{
    if (self = [super init]) {
        
        _sysYear = 0;
        _sysMonth = 0;
        _sysDay = 0;
        
        _sysHour = 0;
        _sysMinute = 0;
        
        _writeMeterDateTime = NO;
        
        _sysYearByte = 0;
    }
    return self;
}




+ (H2SystemDateTime *)sharedInstance
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

#pragma mark - FOR DEBUG PROCESS

@implementation H2SyncDebug

- (id)init
{
    if (self = [super init]) {
        
        _debugErrorCountMeter = 0;
        _debugErrorCountSystem = 0;
        _willReportStatus = NO;
        _zeroRecord = NO;
    }
    return self;
}


+ (H2SyncDebug *)sharedInstance
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


// [H2SyncDebug sharedInstance].willReportStatus

