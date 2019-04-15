//
//  LSOneTouchUltra2.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//
#define ULTRA2_BUFFER_AT_220  220
#import "H2AudioFacade.h"
#import "LSOneTouchUltra2.h"

#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"

#define ULTRA2_INTERVAL         1.3f



@interface LSOneTouchUltra2()
{
}

@end

@implementation LSOneTouchUltra2
- (id)init
{
    if (self = [super init]) {
        _didUseMmolUnit = NO;
        _ultra2RecordNumber = 0;

        _ultra2RecordIndex = 0;
        
        _ultra2RecordUnit = @"";
    }
    
    return self;
}

+ (LSOneTouchUltra2 *)sharedInstance
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

unsigned char qVersion[]={0x11, 0x0d, 'D', 'M', '?'};
unsigned char qSerialNr[]={0x11, 0x0d, 'D', 'M', '@'};
unsigned char qCurUnit[]={0x11, 0x0d, 'D', 'M', 'S', 'U', '?'};
unsigned char qDateFmt[]={0x11, 0x0d, 'D', 'M', 'F'};
unsigned char qTimeFmt[]={0x11, 0x0d, 'D', 'M', 'S', 'T', '?'}; // time format
unsigned char qRecord[]={0x11, 0x0d, 'D', 'M', 'P'};



- (void)Ultra2CommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    switch (cmdMethod) {

        case METHOD_SN:
            cmdLength = sizeof(qSerialNr);
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            memcpy(cmdBuffer, qSerialNr, cmdLength);
            break;
            
            
        case METHOD_TIME:
            cmdLength = sizeof(qDateFmt);
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            memcpy(cmdBuffer, qDateFmt, cmdLength);
            break;
            
        case METHOD_VERSION:
            cmdLength = sizeof(qVersion);
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            memcpy(cmdBuffer, qVersion, cmdLength);
            break;
            
        case METHOD_UNIT:
            cmdLength = sizeof(qCurUnit);
            cmdTypeId = (currentMeter<<4) + METHOD_UNIT;
            memcpy(cmdBuffer, qCurUnit, cmdLength);
            break;
                        
        default:
            break;
    }
    
    
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}


- (void)Ultra2ReadRecord:(UInt8)currentIndexDiv
{
    UInt16 ultra2CmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_RECORD;
    [[H2AudioFacade sharedInstance] sendCommandDataEx:qRecord withCmdLength:sizeof(qRecord) cmdType:ultra2CmdType returnDataLength:currentIndexDiv mcuBufferOffSetAt:ULTRA2_BUFFER_AT_220];
}

- (void)Ultra2BLEReadRecordAll//:(UInt16)currentMeter
{
    UInt16 ultra2CmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_ACK_RECORD;
    [[H2AudioFacade sharedInstance] sendCommandDataEx:qRecord withCmdLength:sizeof(qRecord) cmdType:ultra2CmdType returnDataLength:0 mcuBufferOffSetAt:0];
}


//////////////////////////////////////////////////////////////////////////////////////////////////

- (NSMutableArray *) ultra2ValueArrayParser:(UInt16)indexOffset
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    NSString *valueString = [[NSString alloc]init];
    
    char tmp[32] = {0};
    char tmpx[8] = {0};
    int dstAddr=0, srcAddr=0, number=0;
    
    NSString *tmpMonth;
    NSString *tmpDay;
    NSString *tmpYear;
    
    NSString *tmpTime;
    
    NSString *tmpValue;
    UInt16 tmpOffset = indexOffset;
    
    do {
        tmpOffset++;
        memcpy(tmp, &inSrc[number * 24], 24);
    
        memcpy(tmpx, &tmp[3], 2);
        tmpMonth = [NSString stringWithUTF8String:(const char *)tmpx];
    
        memcpy(tmpx, &tmp[6], 2);
        tmpDay = [NSString stringWithUTF8String:(const char *)tmpx];
    
        memcpy(tmpx, &tmp[19], 3);
        tmpValue = [NSString stringWithUTF8String:(const char *)tmpx];
    
    
        tmpx[0] = '2';
        tmpx[1] = '0';
        memcpy(&tmpx[2], &tmp[9], 2);
        tmpYear = [NSString stringWithUTF8String:(const char *)tmpx];
    
        memcpy(tmpx, &tmp[11], 5);
        tmpTime = [NSString stringWithUTF8String:(const char *)tmpx];
    
        valueString = [NSString stringWithFormat:@"%03d %@-%@-%@ %@ %@ %@\n", tmpOffset, tmpYear, tmpMonth, tmpDay, tmpTime, tmpValue, @"mg/dL"];
        [valueArray addObject:valueString];
    
    
        for (dstAddr = 0; dstAddr < 8; dstAddr++) {
            tmpx[dstAddr] = 0;
        }
        number++;
        srcAddr += 24;
    } while (srcAddr < length-1);
    
    
    return valueArray;
}

-(NSString *)ultra2DayFormatParser:(char *)inSrc withLength:(UInt16)length
{
    NSString *string = [NSString stringWithUTF8String:inSrc];
    return string;
}
-(NSString *)ultra2TimeFormatParser:(char *)inSrc withLength:(UInt16)length
{
    NSString *string = [NSString stringWithUTF8String:inSrc];
    return string;
}
-(NSString *)ultra2SwVersionParser:(char *)inSrc withLength:(UInt16)length
{
    NSString *string = [NSString stringWithUTF8String:inSrc];
    return string;
}
-(NSString *)ultra2SerialNumberParser:(char *)inSrc withLength:(UInt16)length
{
    NSString *string = [NSString stringWithUTF8String:inSrc];
    return string;
}

-(NSString *)ultra2UnitParser:(char *)inSrc withLength:(UInt16)length
{
    NSString *string = [NSString stringWithUTF8String:inSrc];
    return string;
}



#define ULTRA2_RECORD_SKIP              20
#define ULTRA2_RECORD_LENGTH            16
#define G_CMDHDLEN                      6

- (NSMutableArray *)ultra2DateTimeValueArrayParser:(UInt16)indexOffset
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    NSMutableArray *dayTimeValueArray = [[NSMutableArray alloc] init];
    
    char tmp[32] = {0};
    int srcAddr=ULTRA2_RECORD_SKIP, number=0;
    
    UInt8 tmpMonth;
    UInt8 tmpDay;
    UInt16 tmpYear;
    
    UInt8 tmpHour;
    UInt8 tmpMinute;
    
    UInt16 tmpValue;
    UInt16 tmpOffset = indexOffset;
    
    BOOL futureTime = NO;
    
    UInt8 cc = 0;
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ONETOUCH the src length is %d", length);
#endif
    do {
        futureTime = NO;
        tmpOffset++;
        memcpy(tmp, &inSrc[ULTRA2_RECORD_SKIP + number * ULTRA2_RECORD_LENGTH], ULTRA2_RECORD_LENGTH);
#ifdef DEBUG_ONETOUCH
//        for (int i = 0; i<10; i++) {
//            DLog(@"DEBUG_ONETOUCH the tmp is %02X", tmp[i]);
//        }
#endif
        if (tmp[14] == 0x0D && tmp[15] == 0x0A) {
            tmpMonth = ((tmp[0]&0xF0)>>4)*10 + (tmp[0]&0x0F);
            tmpDay = ((tmp[1]&0xF0)>>4)*10 + (tmp[1]&0x0F);
        
            tmpYear = ((tmp[2]&0xF0)>>4)*10 + (tmp[2]&0x0F)+2000;
        
            tmpHour = ((tmp[3]&0xF0)>>4)*10 + (tmp[3]&0x0F);
            tmpMinute = ((tmp[4]&0xF0)>>4)*10 + (tmp[4]&0x0F);
        
            tmpValue = (tmp[5+2]-0x30)*100 +(tmp[6+2]-0x30)*10 + tmp[7+2]-0x30;
        
            H2BgRecord *ultra2Record;
            ultra2Record = [[H2BgRecord alloc] init];
        
            ultra2Record.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",(unsigned int)tmpYear, (unsigned int)tmpMonth, (unsigned int)tmpDay, (unsigned int)tmpHour, (unsigned int)tmpMinute];
        
#ifdef DEBUG_ONETOUCH
            DLog(@"DEBUG_ONETOUCH the ultra 2 record is %@", ultra2Record.bgDateTime);
#endif
            
            if (_didUseMmolUnit) {
                ultra2Record.bgUnit = BG_UNIT_EX;
                ultra2Record.bgValue_mmol = (float)tmpValue/MMOL_COIF;
            }else{
                ultra2Record.bgUnit = BG_UNIT;
                ultra2Record.bgValue_mg = tmpValue;
            }
            
            
            ultra2Record.bgIndex = tmpOffset;
            
            switch (tmp[11]) {
                case 'A':
                    ultra2Record.bgMealFlag = @"A";
                    break;
                    
                case 'B':
                    ultra2Record.bgMealFlag = @"B";
                    break;
                    
                default:
                    ultra2Record.bgMealFlag = @"N";
                    break;
            }
            //ultra2Record.bgFlag = tmp[11];
            
            cc = (tmp[12] &0x0F) *10 + tmp[13] & 0x0F;
            
            switch (cc) {
                case 0:
                    ultra2Record.bgComment = CM_No_Comment;
                    break;
                case 1:
                    ultra2Record.bgComment = CM_Not_Enough_Food;
                    break;
                case 2:
                    ultra2Record.bgComment = CM_Too_Much_Food;
                    break;
                case 3:
                    ultra2Record.bgComment = CM_Mild_Exercise;
                    break;
                case 4:
                    ultra2Record.bgComment = CM_Hard_Exercise;
                    break;
                case 5:
                    ultra2Record.bgComment = CM_Medication;
                    break;
                case 6:
                    ultra2Record.bgComment = CM_Stress;
                    break;
                case 7:
                    ultra2Record.bgComment = CM_Illness;
                    break;
                case 8:
                    ultra2Record.bgComment = CM_Feel_Hypo;
                    break;
                case 9:
                    ultra2Record.bgComment = CM_Menses;
                    break;
                case 10:
                    ultra2Record.bgComment = CM_Vacation;
                    break;
                case 11:
                    ultra2Record.bgComment = CM_Other;
                    break;
                    
                default:
                    ultra2Record.bgComment = CM_No_Comment;
                    break;
            }
            
            if (tmp[5] != 'C') {
                futureTime = [[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:ultra2Record.bgDateTime];
            }
            
            
            if (!(tmp[5] == 'C' || tmp[10] == '?' || futureTime)) { // Record Data OK
                [dayTimeValueArray addObject:ultra2Record];
            }
        }else{

        }
        _ultra2RecordIndex++;
        number++;
        srcAddr += ULTRA2_RECORD_LENGTH;
#ifdef DEBUG_ONETOUCH
        DLog(@"DEBUG_ONETOUCH the record length is %d", srcAddr);
#endif
    } while (srcAddr < length-G_CMDHDLEN);
    
    
    return dayTimeValueArray;
}



- (H2MeterSystemInfo *)ultra2AudioHeaderParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2MeterSystemInfo *ultra2Header;
    ultra2Header = [[H2MeterSystemInfo alloc]init];
    UInt16 numberOfRecord = 0;
    
    memcpy(&numberOfRecord, srcData, 2);
    
    ultra2Header.smNumberOfRecord = numberOfRecord;
    
    char tmp[32] = {0};
    memcpy(tmp, &srcData[11], 6);
    ultra2Header.smCurrentUnit = [NSString stringWithUTF8String:tmp];
    memcpy(tmp, &srcData[2], 9);
    ultra2Header.smModelName = @"";
    ultra2Header.smSerialNumber = [NSString stringWithUTF8String:tmp];
    
    
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ONETOUCH header of ultra2 %@, %@, %d", ultra2Header.smCurrentUnit, ultra2Header.smModelName, numberOfRecord);
#endif
    return ultra2Header;
}

- (UInt16)ultra2RecordNumberParser:(char *)srcData withLength:(UInt16)length
{

    UInt16 numberOfRecord = 0;
    
    memcpy(&numberOfRecord, srcData, 2);
    
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ONETOUCH header of ultra2 number is %d", numberOfRecord);
#endif
    return numberOfRecord;
}


- (NSString *)ultra2ElseParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 idx=0;
    UInt8 idxEx=0;
#ifdef DEBUG_ONETOUCH
    UInt8 idxIn=0;
#endif
    UInt8 start=0;
    
    UInt8 tmpMonth, tmpDay, tmpHour, tmpMinute;
    UInt16  tmpYear;
    
    char tmp[32] = {0};
    tmp[0] = ' ';

    if (srcData[0] == '?') { // Version Parser
        do {
            if (srcData[1+idx] == ' ') {
                break;
            }
            idx++;
        } while (srcData[idx] != 0x0D);
        memcpy(tmp, &srcData[1], idx);

        
    }else if (srcData[0] == '@'){ // Serial number Parser
        do {
            if (srcData[idx] == '"') {
                start = idx+1;
                break;
            }
            idx++;
        } while (srcData[idx] != 0x0D);
        idx = 0;
        
        do {
            if (srcData[start+idx] == '"') {
                memcpy(tmp, &srcData[start], idx);
                break;
            }
            idx++;
        } while (srcData[idx] != 0x0D);
        
    }else if (srcData[0] == 'F'){ // Current date and time Parser
        do {
            if (srcData[idx] == '"') {
                if(idxEx == 2)
                    start = idx+1;
                if (idxEx == 5) {
                    memcpy(tmp, &srcData[start], idx-start);
#ifdef DEBUG_ONETOUCH
                    for (idxIn = 0; idxIn < idx-start; idxIn++) {
                        DLog(@"DEBUG_ONETOUCH the ultra2 current time idxIn %02d val %02X", idxIn, tmp[idxIn]);
                    }
#endif
                    tmpMonth = (tmp[0]-0x30) * 10 + tmp[1]-0x30;
                    tmpDay = (tmp[3]-0x30) * 10 + tmp[4]-0x30;
                    tmpYear = (tmp[6]-0x30) * 10 + tmp[7]-0x30 + 2000;
                    
                    tmpHour = (tmp[11]-0x30) * 10 + tmp[12]-0x30;
                    tmpMinute = (tmp[14]-0x30) * 10 + tmp[15]-0x30;
                    NSString *string = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",(unsigned int)tmpYear, (unsigned int)tmpMonth, (unsigned int)tmpDay, (unsigned int)tmpHour, (unsigned int)tmpMinute];
#ifdef DEBUG_ONETOUCH
                    DLog(@"DEBUG_ONETOUCH current time %@", string);
#endif
                    return string;
//                    break;
                }
                idxEx++;
               }
            idx++;
        } while (srcData[idx] != 0x0D);
        idx = 0;
        
        do {
            if (srcData[start+idx] == '"') {
                memcpy(tmp, &srcData[start], idx);
                break;
            }
            idx++;
        } while (srcData[idx] != 0x0D);
        
    }else if (srcData[0] == 'S' && srcData[1] == 'U' && srcData[2] == '?'){ // Unit Parser
        do {
            if (srcData[idx] == '"') {
                start = idx+1;
                break;
            }
            idx++;
        } while (srcData[idx] != 0x0D);
        idx = 0;
        
        do {
            if (srcData[start+idx] == '"') {
                if (srcData[start+idx-1] == ' ') {
                    memcpy(tmp, &srcData[start], idx-1);
                }else{
                    memcpy(tmp, &srcData[start], idx);
                }
                break;
            }
            idx++;
        } while (srcData[idx] != 0x0D);
        
    }else{
        
    }
    NSString *string = [NSString stringWithUTF8String:(const char *)tmp];
    return string;

}
/*
HEADER
P<space>nnn, "MeterSN","MG/GL<space>"<space>chsm<CR><LF>"
         1       2           3

(1) Number of datalog records to follow(0~500)
(2) Meter serial number (9 characters)
(3) Unit of mearsure for glucose values

EACH DATALOG RECORD

P<space>"dow","mm/dd/yy","hh:mm:ss<space><space><space>","
          4        5          6
(4) Day of week (SUN, MON, TUE, WED, THU, FRI, SAT)
(5) Date of reading
(6) Time of reading (If two or more readings were taken within
                     the same minute, they will be separated by 8 second intervals)

nnnnnn",
  7
(7) Result format:<space><space><space>xxx<space>
<space><space>xxx<space> blood test result<mg/dL>*
<space><space>xxx? blood test result<mg/dL)* with parity error
C<space>xxx<space> for control test record(mg/dL)*
C<space>xxx? for control test record <mg/dL)* with parity error

"t","cc"<space>00<space>chsm<CR><LF>
 8   9
(8) "t" Alpha value for user flage (see Table 1 below)
(9) "cc" Numerical value from 00-11 to represent a
     user meal comment (fixed to tow chars) (see Table 2 below)

*/

//#define HEADER_LEN                  (33+1)
//#define RECORD_LEN                   (61+1)


#define OFFSET_NUMBER               2
#define OFFSET_SN                   7
#define OFFSET_UNIT                 14

#define OFFSET_DOW                  3
#define OFFSET_DATE                 9
#define OFFSET_TIME                 20

#define OFFSET_VALUE                34
#define OFFSET_FLAG                 41
#define OFFSET_COMMENT              44

#define LEN_NUMBER                  3
#define LEN_SN                      9
#define LEN_UNIT                    5          // (MMOL/L 6)

#define LEN_DOW                     3
#define LEN_DATE                    8
#define LEN_TIME                    8

#define LEN_VALUE                   6
#define LEN_FLAG                    1
#define LEN_COMMENT                 2

#define DATE_TIME_VALUE_MASK        0x0F

- (H2MeterSystemInfo *)ultra2BLEHeaderParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2MeterSystemInfo *ultra2Header;
    ultra2Header = [[H2MeterSystemInfo alloc]init];
    
    UInt8 g1TmpNumOfRecord[10] = {0};
    char g2TmpMeterSerialNumber[10] = {0};
    char g3TmpGlucoseUnit[10] = {0};
    
    
    memcpy(g1TmpNumOfRecord, &inSrc[OFFSET_NUMBER], LEN_NUMBER);
    memcpy(g2TmpMeterSerialNumber, &inSrc[OFFSET_SN], LEN_SN);
    memcpy(g3TmpGlucoseUnit, &inSrc[19], LEN_UNIT);
    
    _ultra2RecordNumber = (g1TmpNumOfRecord[0] - 0x30 )* 100 + (g1TmpNumOfRecord[1] - 0x30) * 10 + g1TmpNumOfRecord[2] - 0x30;
    /*
     if (g3TmpGlucoseUnit[0] == 'M' && g3TmpGlucoseUnit[1] == 'G' && g3TmpGlucoseUnit[3] == 'D' && g3TmpGlucoseUnit[4] == 'L') {
     ultra2Header.smCurrentUnit = @"mg/dL";
     }else{
     ultra2Header.smCurrentUnit = @"mmol/L";
     
     }
     */
    ultra2Header.smNumberOfRecord = _ultra2RecordNumber;
    ultra2Header.smModelName = @"";
    ultra2Header.smSerialNumber = [NSString stringWithUTF8String:g2TmpMeterSerialNumber];
    ultra2Header.smCurrentUnit = [NSString stringWithUTF8String:g3TmpGlucoseUnit];
    
    
    if ([ultra2Header.smCurrentUnit isEqualToString:@"MG/DL"]) {
        _ultra2RecordUnit = BG_UNIT;
    }else{
        _ultra2RecordUnit = BG_UNIT_EX;
    }
    
    
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ULTRA 2 Nr of Record %d, %@", _ultra2RecordNumber, ultra2Header.smCurrentUnit);
    
    for (int i = 0; i < LEN_SN; i++) {
        DLog(@"DEBUG_ULTRA 2 SN %d, %X", i, g2TmpMeterSerialNumber[i]);
    }
#endif
    return ultra2Header;
    
}

#pragma mark - DATE TIME VALUE PARSER FOR ALL
- (H2BgRecord *)ultra2BLEDateTimeValueParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    if (length > 60) {
        UInt16 ultra2CheckSumTMP = 0;
        UInt8 ultra2CheckSum0 = 0;
        UInt8 ultra2CheckSum1 = 0;
        UInt8 ultra2CheckSum2 = 0;
        UInt8 ultra2CheckSum3 = 0;
        
        UInt16 ultra2CheckSum = 0;
#ifdef DEBUG_ONETOUCH
        DLog(@"DEBUG_ULTRA2 len %d", length);
#endif
        for (int i=0; i<54; i++) {
            ultra2CheckSumTMP += inSrc[i];
        }
        
        if (inSrc[60-2] >= 'A') {
            ultra2CheckSum0 = 10 + inSrc[60-2] - 'A';
        }else{
            ultra2CheckSum0 = inSrc[60-2] & 0x0F;
        }
        
        if (inSrc[60-3] >= 'A') {
            ultra2CheckSum1 = 10 + inSrc[60-3] - 'A';
            
        }else{
            ultra2CheckSum1 = inSrc[60-3] & 0x0F;
        }
        
        if (inSrc[60-4] >= 'A') {
            ultra2CheckSum2 = 10 + inSrc[60-4] - 'A';
        }else{
            ultra2CheckSum2 = inSrc[60-4] & 0x0F;
        }
        
        if (inSrc[60-5] >= 'A') {
            ultra2CheckSum3 = 10 + inSrc[60-5] - 'A';
        }else{
            ultra2CheckSum3 = inSrc[60-5] & 0x0F;
        }
        
        
        ultra2CheckSum = (ultra2CheckSum3<<12) + (ultra2CheckSum2<<8) + (ultra2CheckSum1<<4) + ultra2CheckSum0;
        
        if (ultra2CheckSum == ultra2CheckSumTMP) {
#ifdef DEBUG_ONETOUCH
            DLog(@"SUM_OK");
#endif
        }else{
#ifdef DEBUG_ONETOUCH
            DLog(@"SUM_FAIL");
#endif
        }
    }
    
    
//    DLog(@"DEBUG_ULTRA2 CHECK SUM %02X,  %02X,  %02X,  %02X", inSrc[60-5], inSrc[60-4], inSrc[60-3], inSrc[60-2]);
#if 0
   // START
    0 50
    1 20
    // Item 1, Record Number
    2 31
    3 38
    4 38
    5 2C
    // Item 2, SN
    6 22
    7 57
    8 4A
     9 4C
     10 34
     11 45
     12 42
     13 41
     14 41
     15 59
     16 22
    
     17 2C
    // Item 3, UNIT
     18 22
     19 4D
     20 47
     21 2F
     22 44
     23 4C
     24 20
     25 22
    
     26 20
    
    // Check SUM
     27 30
     28 35
     29 45
     30 37
     31 0D
     32 0A
#endif


#if 0
    // START
     0 50
    
     1 20
    // Item 4, dow Day of Week
     2 22
     3 46
     4 52
     5 49
     6 22
    
     7 2C // ,
    // Item 5, mm/dd/yy Date of reading
     8 22
     9 30
     10 39
     11 2F
     12 31
     13 38
     14 2F
     15 31
     16 35
     17 22
    
     18 2C // ,
    // Item 6, hh:mm:ss Time of reading
     19 22
     20 30
     21 38
     22 3A
     23 32
     24 35
     25 3A
     26 31
     27 39
    
     28 20
     29 20
     30 20
     31 22
    
     32 2C // ,
    
    // Item 7 Result format
     33 22       // <space><space>XXX<space>   blood test result (mg/dL)*
     34 20       // <space><space>XXX  ?       blood test result (mg/dL)* with parity error
     35 20       //    C   <space>XXX<space>   for control test result (mg/dL)*
     36 31       //    C   <space>XXX  ?       for control test result (mg/dL)* with parity error
     37 30
     38 38
     39 20
     40 22
    
     41 2C ,
    // Item 8, Alpha value for user flag,
     42 22
     43 4E     // N : None, B : Before Meal, A : After Meal
     44 22
    
     45 2C
    
    // Item 9, "CC" Numberical value from 00~11 to represent a user meal comment (fixed to two chars), not use
     46 22
     47 30
     48 30
     49 22
    
     50 2C
    
     51 20
     52 30
     53 30
     54 20
    // Check Sum
     55 30
     56 39
     57 42
     58 42
     59 0D
     60 0A
    
#endif

    UInt8 monthHI, monthLO;
    UInt8 dayHI, dayLO;
    UInt16 yearHI, yearLO;
    
    UInt8 hourHI, hourLO;
    UInt8 minuteHI, minuteLO;
    
    UInt16 tmpValue;
    
    
    H2BgRecord *ultra2Record;
    ultra2Record = [[H2BgRecord alloc] init];
    
   
    
    
//    UInt8 g4TmpDayOfWeek[10] = {0};
    
//    UInt8 g5TmpDateOfReading[10] = {0};
//    UInt8 g6TmpTimeOfReading[10];
    
    UInt8 g7TmpGlucoseValue[10] = {0};
    UInt8 g8TmpUserFlag[10] = {0};
//    UInt8 g9TmpUserMealComment[10] = {0};
    // Day Of Week
    //        memcpy(g4TmpDayOfWeek, &inSrc[OFFSET_DOW], LEN_DOW);
    // Date
    //        memcpy(g5TmpDateOfReading, &inSrc[OFFSET_DATE], LEN_DATE);
    //        memcpy(g6TmpTimeOfReading, &inSrc[OFFSET_TIME], LEN_TIME);
    memcpy(g7TmpGlucoseValue, &inSrc[OFFSET_VALUE], LEN_VALUE);
    // Time
    memcpy(g8TmpUserFlag, &inSrc[OFFSET_FLAG], LEN_FLAG);
    //        memcpy(g9TmpUserMealComment, &inSrc[OFFSET_COMMENT], LEN_COMMENT);
    
    
    monthHI = inSrc[OFFSET_DATE] & 0x0F;
    monthLO = inSrc[OFFSET_DATE + 1] & 0x0F;
    monthHI = monthHI * 10 + monthLO;
    
    dayHI = inSrc[OFFSET_DATE + 3] & 0x0F;
    dayLO = inSrc[OFFSET_DATE + 4] & 0x0F;
    dayHI = dayHI * 10 + dayLO;
    
    yearHI = inSrc[OFFSET_DATE + 6] & 0x0F;
    yearLO = inSrc[OFFSET_DATE + 7] & 0x0F;
    yearHI = yearHI * 10 + yearLO + 2000;
    
    hourHI = inSrc[OFFSET_TIME] & 0x0F;
    hourLO = inSrc[OFFSET_TIME + 1] & 0x0F;
    hourHI = hourHI * 10 + hourLO;
    
    minuteHI = inSrc[OFFSET_TIME + 3] & 0x0F;
    minuteLO = inSrc[OFFSET_TIME + 4] & 0x0F;
    minuteHI = minuteHI * 10 + minuteLO;
    
    if (inSrc[34] == 'C' || inSrc[39] == '?') { // Record Data OK
        ultra2Record.bgMealFlag = @"R";
    }else{
        switch (inSrc[43]) {
            case 'A':
                ultra2Record.bgMealFlag = @"A";
                break;
                
            case 'B':
                ultra2Record.bgMealFlag = @"B";
                break;
                
            default:
                ultra2Record.bgMealFlag = @"N";
                break;
        }
        //ultra2Record.bgFlag = inSrc[43];
    }
    
    
    
    tmpValue = (g7TmpGlucoseValue[2]-0x30)*100 +(g7TmpGlucoseValue[1+2]-0x30)*10 + g7TmpGlucoseValue[2+2]-0x30;
    
    ultra2Record.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", yearHI, monthHI, dayHI, hourHI, minuteHI];
#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ULTRA 2, THE VALUE IS %@ %d", ultra2Record.bgDateTime, tmpValue);
#endif
    ultra2Record.bgValue_mg = tmpValue;
    
    ultra2Record.bgUnit = _ultra2RecordUnit;
    if ([_ultra2RecordUnit isEqualToString:BG_UNIT_EX]) {
        ultra2Record.bgValue_mmol = (float)tmpValue/MMOL_COIF;
    }
    
    if (![ultra2Record.bgMealFlag isEqualToString:@"R"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:ultra2Record.bgDateTime]) {
            ultra2Record.bgMealFlag = @"R";
        }
    }
    
    return ultra2Record;
}


- (BOOL)ultra2BLECheckSumTest
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    if (length == ULTRA2_BLE_RECORD_LENGTH) {
        UInt16 ultra2CheckSumTMP = 0;
        UInt8 ultra2CheckSum0 = 0;
        UInt8 ultra2CheckSum1 = 0;
        UInt8 ultra2CheckSum2 = 0;
        UInt8 ultra2CheckSum3 = 0;
        
        UInt16 ultra2CheckSum = 0;
#ifdef DEBUG_ONETOUCH
        DLog(@"DEBUG_ULTRA2 len %d ", length);
#endif
        for (int i=0; i<54; i++) {
            ultra2CheckSumTMP += inSrc[i];
        }
#if 0
        for (int i=0; i<54; i++) {
            ultra2CheckSum += inSrc[i];
            DLog(@"DEBUG_ULTRA2 value %d %02X, checkSum %04X", i, inSrc[i], ultra2CheckSum );
        }
        for (int i=0; i<length; i++) {
            DLog(@"DEBUG_ULTRA2 value %d %02X, checkSum", i, inSrc[i] );
        }
#endif
        if (inSrc[60-2] >= 'A') {
            ultra2CheckSum0 = 10 + inSrc[60-2] - 'A';
        }else{
            ultra2CheckSum0 = inSrc[60-2] & 0x0F;
        }
        
        if (inSrc[60-3] >= 'A') {
            ultra2CheckSum1 = 10 + inSrc[60-3] - 'A';
            
        }else{
            ultra2CheckSum1 = inSrc[60-3] & 0x0F;
        }
        
        if (inSrc[60-4] >= 'A') {
            ultra2CheckSum2 = 10 + inSrc[60-4] - 'A';
        }else{
            ultra2CheckSum2 = inSrc[60-4] & 0x0F;
        }
        
        if (inSrc[60-5] >= 'A') {
            ultra2CheckSum3 = 10 + inSrc[60-5] - 'A';
        }else{
            ultra2CheckSum3 = inSrc[60-5] & 0x0F;
        }
        
        
        ultra2CheckSum = (ultra2CheckSum3<<12) + (ultra2CheckSum2<<8) + (ultra2CheckSum1<<4) + ultra2CheckSum0;
        
        if (ultra2CheckSum == ultra2CheckSumTMP) {
#ifdef DEBUG_ONETOUCH
            DLog(@"SUM_OK");
#endif
            return YES;
        }else{
            return NO;
        }
    }else if (length == ULTRA2_BLE_HEADER_LENGTH){
        return NO;
    }else{
        return NO;
    }
}


- (void)UltraXXXCommandGeneral:(UInt16)cmdMethod
{
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    
    cmdTypeId = 0x05A0;
    switch (cmdMethod) {
            
        case METHOD_SN:
            cmdLength = sizeof(qSerialNr);
            memcpy(cmdBuffer, qSerialNr, cmdLength);
            break;
            
            
        case METHOD_TIME:
            cmdLength = sizeof(qDateFmt);
            memcpy(cmdBuffer, qDateFmt, cmdLength);
            break;
            
        case METHOD_VERSION:
            cmdLength = sizeof(qVersion);
            memcpy(cmdBuffer, qVersion, cmdLength);
            break;
            
        case METHOD_UNIT:
            cmdLength = sizeof(qCurUnit);
            memcpy(cmdBuffer, qCurUnit, cmdLength);
            _ultraOldCmdIndex = 0;
            _ultraOldRecordsSart = NO;
            break;
            
        case METHOD_RECORD:
            cmdLength = sizeof(qRecord);
            memcpy(cmdBuffer, qRecord, cmdLength);
            break;
            
        default:
            break;
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}


- (void)UltraOldCommandLoop:(UInt16)cmdMethod
{
    
    UInt16 cmdTypeId = 0x0602;
    _ultraOldCmdLength = sizeof(qRecord);
    [[H2AudioFacade sharedInstance] sendCommandDataEx:&qRecord[_ultraOldCmdIndex] withCmdLength:1 cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
    _ultraOldCmdIndex++;
    if (_ultraOldCmdIndex >= _ultraOldCmdLength) {
#ifdef DEBUG_ULTRA_XXX
        DLog(@"RECORD COMMAND -- %d and %d", _ultraOldCmdIndex, _ultraOldCmdLength);
#endif
        _ultraOldCmdIndex = 0;
        _ultraOldRecordsSart = YES;
    }else{
#ifdef DEBUG_ULTRA_XXX
        DLog(@"RECORD COMMAND -- LOOP");
#endif
        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(UltraOldLoop) userInfo:nil repeats:NO];
    }
}

- (void)UltraOldLoop
{
    [self UltraOldCommandLoop:0];
}


- (NSString *)ultraXXXParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    char xxTmp[24] = {0};
    
    
    //inSrc
    
    UInt16 xxYear = 0;
    UInt16 xxMonth = 0;
    UInt16 xxDay = 0;
    
    UInt16 xxHour = 0;
    UInt16 xxMinute = 0;
    
    NSString *xxxString;
    
    switch (inSrc[0]) {
        case '@':
            memcpy(xxTmp, &inSrc[3], 9);
            xxxString = [NSString stringWithUTF8String:xxTmp];
            break;
            
        case 'F':
            xxYear = (inSrc[15] & 0x0F) * 10 + (inSrc[16] & 0x0F) + 2000;
            xxMonth = (inSrc[9] & 0x0F) * 10 + (inSrc[10] & 0x0F);
            xxDay = (inSrc[12] & 0x0F) * 10 + (inSrc[13] & 0x0F);
            
            xxHour = (inSrc[20] & 0x0F) * 10 + (inSrc[21] & 0x0F);
            xxMinute = (inSrc[23] & 0x0F) * 10 + (inSrc[24] & 0x0F);
            
            xxxString = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",(unsigned int)xxYear, (unsigned int)xxMonth, (unsigned int)xxDay, (unsigned int)xxHour, (unsigned int)xxMinute];
            break;
            
        case '?':
            memcpy(xxTmp, &inSrc[1], 19);
            xxxString = [NSString stringWithUTF8String:xxTmp];
            break;
            
        case 'S':
            memcpy(xxTmp, &inSrc[5], 5);
            xxxString = [NSString stringWithUTF8String:xxTmp];
            if (![xxxString isEqualToString:@"MG/DL"]) {
                memcpy(xxTmp, &inSrc[5], 6);
                xxxString = [NSString stringWithUTF8String:xxTmp];
                _ultra2RecordUnit = BG_UNIT_EX;
            }else{
                _ultra2RecordUnit = BG_UNIT;
#ifdef DEBUG_ULTRA_XXX
                DLog(@"UNIT IS CORRECT ****");
#endif
            }
            
            break;
            
        case 'P':
            break;
            
        default:
#ifdef DEBUG_ULTRA_XXX
            DLog(@"XXX - ERROR : ?????");
#endif
            break;
    }
#ifdef DEBUG_ULTRA_XXX
    DLog(@"VUE CT : %@ ?????", xxxString);
#endif
    return xxxString;
    /*
     inSrc[0]  == '@';
     inSrc[0]  == 'F';
     inSrc[0]  == '?';
     inSrc[0]  == 'S';
     */
}

- (UInt16)ultraXXXNumberOfRecordsParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(64);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 totalRecords = (inSrc[2]&0x0F)*100 + (inSrc[3]&0x0F)*10 + (inSrc[4]&0x0F);
    
    return totalRecords;
    
    /*
     addr = 0 data = 50
     addr = 1 data = 20
     addr = 2 data = 30  // 0
     addr = 3 data = 35  // 5
     addr = 4 data = 34  // 4
     addr = 5 data = 2C
     addr = 6 data = 22
     addr = 7 data = 44      // D
     addr = 8 data = 56
     addr = 9 data = 47      // G
     addr = 10 data = 43     // C
     addr = 11 data = 33 // 3
     addr = 12 data = 32 // 2
     addr = 13 data = 45
     addr = 14 data = 54
     addr = 15 data = 54
     addr = 16 data = 22
     addr = 17 data = 2C
     addr = 18 data = 22
     addr = 19 data = 4D // M
     addr = 20 data = 47 // G
     addr = 21 data = 2F
     addr = 22 data = 44 // D
     addr = 23 data = 4C // L
     addr = 24 data = 20
     addr = 25 data = 22
     addr = 26 data = 20
     addr = 27 data = 30
     addr = 28 data = 35
     addr = 29 data = 44
     addr = 30 data = 32
     addr = 31 data = 0D
     addr = 32 data = 0A
     
     */
}

#define X_RD_MON_AT                    9
#define X_RD_DAY_AT                    12
#define X_RD_YEAR_AT                   15

#define X_RD_HOUR_AT                   20
#define X_RD_MIN_AT                    23

#define X_RD_SECOND_AT                 26

#define X_RD_VALUE_AT                  36
- (H2BgRecord *)ultraXXXRecordsParser
{
    H2BgRecord *ultraXXXRecord;
    ultraXXXRecord = [[H2BgRecord alloc] init];
#ifdef DEBUG_ULTRA_XXX
    DLog(@"ULTRA XXX --RECORDS--");
#endif
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(256);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    
    
    
    UInt16 rdMonth =  (inSrc[X_RD_MON_AT]&0x0F)*10 + (inSrc[X_RD_MON_AT+1]&0x0F);
    UInt16 rdDay =  (inSrc[X_RD_DAY_AT]&0x0F)*10 + (inSrc[X_RD_DAY_AT+1]&0x0F);
    UInt16 rdYear =  (inSrc[X_RD_YEAR_AT]&0x0F)*10 + (inSrc[X_RD_YEAR_AT+1]&0x0F) + 2000;
    
    UInt16 rdHour =  (inSrc[X_RD_HOUR_AT]&0x0F)*10 + (inSrc[X_RD_HOUR_AT+1]&0x0F);
    UInt16 rdMinute =  (inSrc[X_RD_MIN_AT]&0x0F)*10 + (inSrc[X_RD_MIN_AT+1]&0x0F);
    UInt16 rdSecond =  (inSrc[X_RD_SECOND_AT]&0x0F)*10 + (inSrc[X_RD_SECOND_AT+1]&0x0F);
    
    UInt16 rdValue = (inSrc[X_RD_VALUE_AT]&0x0F)*100 + (inSrc[X_RD_VALUE_AT+1]&0x0F)*10 + (inSrc[X_RD_VALUE_AT+2]&0x0F);
    
    
    
    
    
    //ultraXXXRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", rdYear, rdMonth, rdDay, rdHour, rdMinute];
    
    ultraXXXRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", rdYear, rdMonth, rdDay, rdHour, rdMinute, rdSecond];
    
#ifdef DEBUG_ULTRA_XXX
    DLog(@"DEBUG_ULTRA XXX, THE VALUE IS %@ %d ====", ultraXXXRecord.bgDateTime, rdValue);
#endif
    ultraXXXRecord.bgValue_mg = rdValue;
    
    ultraXXXRecord.bgUnit = _ultra2RecordUnit;
    if ([_ultra2RecordUnit isEqualToString:BG_UNIT_EX]) {
        ultraXXXRecord.bgValue_mmol = (float)rdValue/MMOL_COIF;
    }
    
    if (![ultraXXXRecord.bgMealFlag isEqualToString:@"R"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:ultraXXXRecord.bgDateTime]) {
            ultraXXXRecord.bgMealFlag = @"R";
        }
    }
    
    
    
    
    return ultraXXXRecord;
    /*
     addr = 0 data = 50
     addr = 1 data = 20
     addr = 2 data = 22
     addr = 3 data = 4D // week
     addr = 4 data = 4F //
     addr = 5 data = 4E //
     addr = 6 data = 22
     addr = 7 data = 2C
     addr = 8 data = 22
     addr = 9 data = 30     // 0
     addr = 10 data = 35    // 5
     addr = 11 data = 2F
     addr = 12 data = 30    // 0
     addr = 13 data = 35    // 5
     addr = 14 data = 2F
     addr = 15 data = 31    // 1
     addr = 16 data = 34    // 4
     addr = 17 data = 22
     addr = 18 data = 2C
     addr = 19 data = 22
     addr = 20 data = 31    // 1
     addr = 21 data = 39    // 9
     addr = 22 data = 3A
     addr = 23 data = 32    // 2
     addr = 24 data = 32    // 2
     addr = 25 data = 3A
     addr = 26 data = 34    // 4
     addr = 27 data = 30    // 0
     addr = 28 data = 20
     addr = 29 data = 20
     addr = 30 data = 20
     addr = 31 data = 22
     addr = 32 data = 2C
     addr = 33 data = 22
     addr = 34 data = 20
     addr = 35 data = 20
     addr = 36 data = 30    // 0
     addr = 37 data = 38    // 8
     addr = 38 data = 31    // 1
     addr = 39 data = 20
     addr = 40 data = 22
     addr = 41 data = 2C
     addr = 42 data = 20
     addr = 43 data = 30
     addr = 44 data = 30
     addr = 45 data = 20
     addr = 46 data = 30
     addr = 47 data = 38
     addr = 48 data = 32
     addr = 49 data = 36
     addr = 50 data = 0D
     addr = 51 data = 0A
     */
    
    
    
    
}




/*
 
 
 
 
 
 
 addr = 0 data = 53
 addr = 1 data = 55
 addr = 2 data = 3F
 addr = 3 data = 2C
 addr = 4 data = 22
 addr = 5 data = 4D //
 addr = 6 data = 47
 addr = 7 data = 2F
 addr = 8 data = 44
 addr = 9 data = 4C
 addr = 10 data = 20
 addr = 11 data = 22
 addr = 12 data = 20
 addr = 13 data = 30
 addr = 14 data = 32
 addr = 15 data = 43
 addr = 16 data = 41
 addr = 17 data = 0D
 addr = 18 data = 0A
 
 
 
 addr = 0 data = 3F
 addr = 1 data = 50  // P
 addr = 2 data = 30  // 0
 addr = 3 data = 32
 addr = 4 data = 2E
 addr = 5 data = 30
 addr = 6 data = 30
 addr = 7 data = 2E
 addr = 8 data = 30
 addr = 9 data = 37
 addr = 10 data = 20
 addr = 11 data = 20
 addr = 12 data = 20
 addr = 13 data = 2F
 addr = 14 data = 20
 addr = 15 data = 20
 addr = 16 data = 2F
 addr = 17 data = 20
 addr = 18 data = 20
 addr = 19 data = 20
 addr = 20 data = 30
 addr = 21 data = 33
 addr = 22 data = 35
 addr = 23 data = 32
 addr = 24 data = 0D
 addr = 25 data = 0A
 
 
 
 
 addr = 0 data = 46
 addr = 1 data = 20
 addr = 2 data = 22
 addr = 3 data = 54
 addr = 4 data = 55
 addr = 5 data = 45
 addr = 6 data = 22
 addr = 7 data = 2C
 addr = 8 data = 22
 addr = 9 data = 30  // Month
 addr = 10 data = 31
 addr = 11 data = 2F
 addr = 12 data = 30 // Day
 addr = 13 data = 33
 addr = 14 data = 2F
 addr = 15 data = 31 // Year
 addr = 16 data = 37
 addr = 17 data = 22
 addr = 18 data = 2C
 addr = 19 data = 22
 addr = 20 data = 31 // Hour
 addr = 21 data = 37
 addr = 22 data = 3A
 addr = 23 data = 35 // Minute
 addr = 24 data = 39
 addr = 25 data = 3A
 addr = 26 data = 35 // Second
 addr = 27 data = 35
 addr = 28 data = 20
 addr = 29 data = 20
 addr = 30 data = 20
 addr = 31 data = 22
 addr = 32 data = 20
 addr = 33 data = 30
 addr = 34 data = 36
 addr = 35 data = 31
 addr = 36 data = 36
 addr = 37 data = 0D
 addr = 38 data = 0A
 
 
 addr = 0 data = 40
 addr = 1 data = 20
 addr = 2 data = 22
 addr = 3 data = 44
 addr = 4 data = 56
 addr = 5 data = 47
 addr = 6 data = 43
 addr = 7 data = 33
 addr = 8 data = 32
 addr = 9 data = 45
 addr = 10 data = 54
 addr = 11 data = 54
 addr = 12 data = 22
 addr = 13 data = 20
 addr = 14 data = 30
 addr = 15 data = 33
 addr = 16 data = 31
 addr = 17 data = 41
 addr = 18 data = 0D
 addr = 19 data = 0A
 
 */

/*
 
 
 // Serial Number
 11 0d 44 4d 40
 . . D M @
 40 20 22 44 56 47 43 33 32 45 54 22 20 30 33 31 41
 0d 0a
 
 == '@' // Serial Number
 == 'F' // Current
 == '?' // Version
 == 'S' // Unit
 
 // Current Time
 11 0d 44 4d 46
 ..DMF
 46
 20
 22 57 45 44 22 2c 22 31 32 2f 32 38 2f 31 36 22 2c 22 32 30 3a 30 31 3a 32 35 20 22
 20 30 35 46 41
 0d
 0a
 
 F
 
 "WED","12/28/16","20:01:25 " 05FA
 .
 .
 
 // Version
 0d 11 0d 44 4d 3f
 . . . D M ?
 
 3f
 50 30 32 2e 30 2e 30 37 20 2f 20 2f 20 30 33 35 32
 0d 0a
 
 ?
 P 0 2 . 0 . 0 7 /  /  0 3 5 2 . .
 
 
 // UNIT
 11 0d 44 4d 53 55 3f
 ..DMSU?
 
 53 55 3f 2c 22 4d 47 2f 44 4c 20 22 20 30 32 43 41
 0d 0a
 
 SU?,"MG/DL "
 02CA
 .
 */
@end



