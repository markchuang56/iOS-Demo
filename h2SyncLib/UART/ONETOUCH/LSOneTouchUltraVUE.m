//
//  LSOneTouchUltra2.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//
//#define ULTRA2_BUFFER_AT_220  220
#import "H2AudioFacade.h"
#import "LSOneTouchUltraVUE.h"
#import "LSOneTouchUltraMini.h"

#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"

//#define ULTRA2_INTERVAL         1.3f
#define VUE_BUFFER_SIZE                     48
#define VUE_RECORD_BUFFER_SIZE              48

@interface LSOneTouchUltraVUE()
{
}

@end

@implementation LSOneTouchUltraVUE
- (id)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

+ (LSOneTouchUltraVUE *)sharedInstance
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

/*
unsigned char qModle[]={'D', 'M', 'L',  0x0d};
unsigned char qSerialNr[]={'D', 'M', '@', 0x0d};
unsigned char qVersion[]={'D', 'M', '?', 0x0d};
unsigned char qDateTime[]={'D', 'M', 'F', 0x0d};
unsigned char qCurUnit[]={'D', 'M', 'G', 0x0d};
*/


// unsigned char qTimeFmt[]={'D', 'M', 'S', 'T', '?'}; // time format
// unsigned char qRecord[]={'D', 'M', 'P'};
/*
unsigned char qVersion[]={0x11, 0x0d, 'D', 'M', '?'};
unsigned char qSerialNr[]={0x11, 0x0d, 'D', 'M', '@'};
unsigned char qCurUnit[]={0x11, 0x0d, 'D', 'M', 'S', 'U', '?'};
unsigned char qDateFmt[]={0x11, 0x0d, 'D', 'M', 'F'};
unsigned char qTimeFmt[]={0x11, 0x0d, 'D', 'M', 'S', 'T', '?'}; // time format
unsigned char qRecord[]={0x11, 0x0d, 'D', 'M', 'P'};
*/

/*
unsigned char ultra2CableSwitchOn[] = {
    0x00, CMD_SW_ON, 0x00, 0x00, 0x00
};
*/

unsigned char vueCmdRecord[]={
    0x10, 0x02,
    'H', 'R',
    'X', 'X',
    0x10, 0x03,
    'C', 'C'
};

- (void)UltraVueCommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
//    unsigned char qModle[]={'D', 'M', 'L',  0x0d};
    unsigned char qSerialNr[]={'D', 'M', '@', 0x0d};
    unsigned char qVersion[]={'D', 'M', '?', 0x0d};
    unsigned char qDateTime[]={'D', 'M', 'F', 0x0d};
    unsigned char qCurUnit[]={'D', 'M', 'G', 0x0d};
/*
    unsigned char qRecord[]={ 0x10 ,
        0x02 , 0x48 , 0x52  , 0x00 , 0x00 , 0x10 , 0x03
        , 0x31 , 0x5f
    };
*/
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[12] = {0};
#ifdef DEBUG_VUE
    DLog(@"VUE COMMAND #####");
#endif
    switch (cmdMethod) {

/*
        case METHOD_MODEL:
            cmdLength = sizeof(qModle);
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            memcpy(cmdBuffer, qModle, cmdLength);
            break;
*/
        case METHOD_SN:
#ifdef DEBUG_VUE
            DLog(@"VUE COMMAND ##### - SN");
            for (int i = 0; i < 4; i++) {
                DLog(@"VUE CMD %d, -- %02X - SERIAL NUMBER", i, qSerialNr[i]);
            }
#endif

            cmdLength = sizeof(qSerialNr);
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            memcpy(cmdBuffer, qSerialNr, cmdLength);

#ifdef DEBUG_VUE
            for (int i = 0; i < 4; i++) {
                DLog(@"VUE CMD %d, -- %02X  -- SN ", i, cmdBuffer[i]);
            }
#endif
            break;
            
            
        case METHOD_TIME:
            cmdLength = sizeof(qDateTime);
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            memcpy(cmdBuffer, qDateTime, cmdLength);

#ifdef DEBUG_VUE
            for (int i = 0; i < 4; i++) {
                DLog(@"VUE CMD %d, -- %02X  -- TIME", i, cmdBuffer[i]);
            }
#endif
            break;
            
        case METHOD_VERSION:
            cmdLength = sizeof(qVersion);
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            memcpy(cmdBuffer, qVersion, cmdLength);
            break;
            
        case METHOD_NROFRECORD:
            cmdLength = sizeof(qCurUnit);
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            memcpy(cmdBuffer, qCurUnit, cmdLength);
            break;

        default:
            break;
    }
    
#ifdef DEBUG_VUE
    for (int i = 0; i < 4; i++) {
        DLog(@"VUE CMD %d, -- %02X", i, cmdBuffer[i]);
    }
#endif
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}



- (void)UltraVueReadRecord:(UInt16)nIndex
{
    UInt16 ultraVueCmdType = 0x03A2;
    
    UInt8 cmdLen = 0;
    UInt8 reportLen = 16;
    unsigned char cmdTmp[11] = {0};
    unsigned char cmdCrcSrc[4] = {0};
    UInt16 crcTmp = 0;
    
    memcpy(cmdTmp, vueCmdRecord, sizeof(cmdTmp)-2);
    
    cmdTmp[5] = (unsigned char)(nIndex & 0x00FF);
    
    cmdTmp[4] = (unsigned char)((nIndex >> 8) & 0x00FF);
    
    memcpy(cmdCrcSrc, &cmdTmp[2], sizeof(cmdCrcSrc));
    
    crcTmp = [[LSOneTouchUltraMini sharedInstance] crc_calculate_crc:0xFFFF inSrc:cmdCrcSrc inLength:sizeof(cmdCrcSrc)];
    
    if (cmdTmp[5] == 0x0F ) {
        reportLen = 17;
    }
    if (cmdTmp[5] == 0x10 ) {
        cmdLen = 11;
        cmdTmp[cmdLen-5] = 0x10;
        cmdTmp[cmdLen-4] = 0x10;
        cmdTmp[cmdLen-3] = 0x03;
    }else{
        cmdLen = 10;
    }
    memcpy(&cmdTmp[cmdLen-2], &crcTmp, 2);

#ifdef DEBUG_VUE
    for (int i = 0; i < cmdLen; i++) {
        DLog(@"VUE RECORD CMD %d, and %02X", i, cmdTmp[i]);
    }
#endif
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdTmp withCmdLength:cmdLen cmdType:ultraVueCmdType returnDataLength:reportLen mcuBufferOffSetAt:0];
    
}

#pragma mark - VUE VUE PARSER TASK
#pragma mark - SERIAL NUMBER
- (NSString *)ultraVueSerialNumberParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(VUE_BUFFER_SIZE);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);

#ifdef DEBUG_VUE
    for (int i = 0; i<length; i++) {
        DLog(@"VUE - %d and %02X", i, inSrc[i]);
    }
#endif
    
    char tmp[VUE_BUFFER_SIZE] = {0};
    memcpy(tmp, &inSrc[3], 8);
    NSString *string = [NSString stringWithUTF8String:tmp];

#ifdef DEBUG_VUE
    DLog(@"VUE SN : %@ ????", string);
#endif
    
    return string;
 /*
    addr = 0 data = 40
    addr = 1 data = 20
    addr = 2 data = 22
    addr = 3 data = 43 // C
    addr = 4 data = 43 // C
    addr = 5 data = 42 // B
    addr = 6 data = 51 // Q
    addr = 7 data = 46 // F
    addr = 8 data = 30 // 0
    addr = 9 data = 57 // W
    addr = 10 data = 5A // Z
    addr = 11 data = 22
    addr = 12 data = 20
    addr = 13 data = 30
    addr = 14 data = 32
    addr = 15 data = 45
    addr = 16 data = 34
    addr = 17 data = 0D
    addr = 18 data = 0A
*/
}

#pragma mark - CURRENT TIME
- (NSString *)ultraVueCurrentTimeParser
{// E
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(VUE_BUFFER_SIZE);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);

#ifdef DEBUG_VUE
    for (int i = 0; i<length; i++) {
        DLog(@"VUE - %d and %02X", i, inSrc[i]);
    }
#endif
    
    UInt16 vueYear = 0;
    UInt8 vueMonth = 0;
    UInt8 vueDay = 0;
    
    UInt8 vueHour = 0;
    UInt8 vueMinute = 0;
    
    
    vueMonth = (inSrc[9] & 0x0F) * 10 + (inSrc[10] & 0x0F);
//    DLog(@"MON %d, %d %d ==", vueMonth, inSrc[9] & 0x0F,  inSrc[10] & 0x0F);
    
    vueDay = (inSrc[12] & 0x0F) * 10 +  (inSrc[13] & 0x0F);
//    DLog(@"DAY %d, %d %d ==", vueDay, inSrc[12] & 0x0F,  inSrc[13] & 0x0F);
    
    vueYear = (inSrc[15] & 0x0F) * 10 + (inSrc[16] & 0x0F);
    vueYear += 2000;
//    DLog(@"YEAR %d, %d %d ==", vueYear, inSrc[15] & 0x0F,  inSrc[16] & 0x0F);
    
    
    vueHour = (inSrc[20] & 0x0F) * 10 + (inSrc[21] & 0x0F);
//    DLog(@"HOUR %d, %d %d ==", vueHour, inSrc[20] & 0x0F,  inSrc[21] & 0x0F);
    
    vueMinute = (inSrc[23] & 0x0F) * 10 + (inSrc[24] & 0x0F);
//    DLog(@"MINUTE %d, %d %d ==", vueMinute, inSrc[23] & 0x0F,  inSrc[24] & 0x0F);
    
    
    NSString *stringDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",(unsigned int)vueYear, (unsigned int)vueMonth, (unsigned int)vueDay, (unsigned int)vueHour, (unsigned int)vueMinute];
    
#ifdef DEBUG_VUE
    DLog(@"VUE CT : %@ ?????", stringDateTime);
#endif
    
    return stringDateTime;
    /*
     addr = 0 data = 46  // F
     addr = 1 data = 20
     addr = 2 data = 22
     addr = 3 data = 54  // T
     addr = 4 data = 48  // H
     addr = 5 data = 55  // U
     addr = 6 data = 22
     addr = 7 data = 2C
     addr = 8 data = 22
     addr = 9 data = 31      //  1
     addr = 10 data = 32     //  2
     addr = 11 data = 2F
     addr = 12 data = 32     //  2
     addr = 13 data = 39     //  9
     addr = 14 data = 2F
     addr = 15 data = 31     //  1
     addr = 16 data = 36     //  6
     addr = 17 data = 22
     addr = 18 data = 2C
     addr = 19 data = 22
     addr = 20 data = 31     //  1
     addr = 21 data = 36     //  6
     addr = 22 data = 3A
     addr = 23 data = 31     //  1
     addr = 24 data = 35     //  5
     addr = 25 data = 3A
     addr = 26 data = 33     //  3
     addr = 27 data = 37     //  7
     addr = 28 data = 20
     addr = 29 data = 20
     addr = 30 data = 20
     addr = 31 data = 22
     addr = 32 data = 20
     addr = 33 data = 30
     addr = 34 data = 36
     addr = 35 data = 31
     addr = 36 data = 39
     addr = 37 data = 0D
     addr = 38 data = 0A
     */
    
}

#pragma mark - VERSION
- (NSString *)ultraVueVersionParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(VUE_BUFFER_SIZE);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);

#ifdef DEBUG_VUE
    for (int i = 0; i<length; i++) {
        DLog(@"VUE - %d and %02X", i, inSrc[i]);
    }
#endif
    
    char tmp[VUE_BUFFER_SIZE] = {0};
    memcpy(tmp, &inSrc[1], 18);
    NSString *string = [NSString stringWithUTF8String:tmp];
    
#ifdef DEBUG_VUE
    DLog(@"VUE VERSION : %@ ????", string);
#endif
    
    return string;
    
    // F Version
    /*
     addr = 0 data = 3F
     addr = 1 data = 56  // V    -> V03.02.00
     addr = 2 data = 30  // 0
     addr = 3 data = 33  // 3
     addr = 4 data = 2E  // .
     addr = 5 data = 30  // 0
     addr = 6 data = 32  // 2
     addr = 7 data = 2E  // .
     addr = 8 data = 30  // 0
     addr = 9 data = 30  // 0
     addr = 10 data = 20
     addr = 11 data = 31 // 1
     addr = 12 data = 31 // 1
     addr = 13 data = 2F //
     addr = 14 data = 31 // 1
     addr = 15 data = 38 // 8
     addr = 16 data = 2F //
     addr = 17 data = 30 // 0
     addr = 18 data = 39 // 9  --> 2009/11/18
     addr = 19 data = 20
     addr = 20 data = 30
     addr = 21 data = 33
     addr = 22 data = 43
     addr = 23 data = 38
     addr = 24 data = 0D
     addr = 25 data = 0A
     
     */
}



#pragma mark - UNIT
#if 0
- (NSString *)ultraVueUnitParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(VUE_BUFFER_SIZE);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    char tmp[24] = {0};
    memcpy(tmp, &inSrc[1], 18);
    NSString *string = [NSString stringWithUTF8String:tmp];
    return string;
/*
    addr = 0 data = 4C  // L
    addr = 1 data = 2C
    addr = 2 data = 22
    addr = 3 data = 31  // 1
    addr = 4 data = 35  // 5
    addr = 5 data = 22
    addr = 6 data = 20
    addr = 7 data = 30
    addr = 8 data = 31
    addr = 9 data = 32
    addr = 10 data = 32
    addr = 11 data = 0D
    addr = 12 data = 0A
*/
    
    
}
#endif

#pragma mark - NUMBER OF RECORDS
- (UInt16)ultraVueRecordNumberParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(VUE_BUFFER_SIZE);
    unsigned char temp[4] = {0};
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);

#ifdef DEBUG_VUE
    for (int i = 0; i<length; i++) {
        DLog(@"VUE - %d and %02X", i, inSrc[i]);
    }
#endif
    
    UInt8 index = 0;
    UInt8 indexYY = 0;
    for (int i = 0; i<length; i++) {

#ifdef DEBUG_VUE
        DLog(@"NUMBER OF %d %02X ... %d ???", i, inSrc[i], index);
#endif
        
        if (inSrc[i] == 0x22) {
            indexYY++;
        }
        if (indexYY >= 2) {
            break;
        }
        index++;
    }
    
    index--;
    indexYY = 4;
    
    for (int i = index; i >=0 ; i--) {
        if (inSrc[i] == 0x22) {

#ifdef DEBUG_VUE
            DLog(@"DONE");
#endif
            
            break;
        }
        indexYY--;
        temp[indexYY] = inSrc[i];

#ifdef DEBUG_VUE
        DLog(@"NNN %d, %02X, %02X,  %d", i, temp[indexYY], inSrc[i], indexYY);
#endif
        
    }
    UInt16 records = 0;
//    records = (temp[0] & 0x0F)*1000 + (temp[1] & 0x0F)*100 +  (temp[2] & 0x0F)*10 +  (temp[3] & 0x0F);
    records = (temp[1] & 0x0F)*100 +  (temp[2] & 0x0F)*10 +  (temp[3] & 0x0F);

#ifdef DEBUG_VUE
    DLog(@"NUMBER OF %02X %02X ... %02X  %02X 888 ??? %d", temp[0], temp[1], temp[2], temp[3], records);
#endif
    
    return records;
/*
    addr = 0 data = 47      // G
    addr = 1 data = 2C
    addr = 2 data = 22
    addr = 3 data = 36      // 6
    addr = 4 data = 30      // 0
    addr = 5 data = 30      // 0
    addr = 6 data = 22
    addr = 7 data = 20
    addr = 8 data = 30
    addr = 9 data = 31
    addr = 10 data = 34
    addr = 11 data = 44
    addr = 12 data = 0D
    addr = 13 data = 0A
*/
}




- (H2BgRecord *)ultraVueDateTimeValueParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *inSrc;
    inSrc = (Byte *)malloc(VUE_RECORD_BUFFER_SIZE);
    memcpy(inSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);

#ifdef DEBUG_VUE
    for (int i = 0; i<length; i++) {
        DLog(@"VUE - %d and %02X", i, inSrc[i]);
    }
#endif
    
/*
    BLE DATA addr = 0 data = 10
    BLE DATA addr = 1 data = 02
    BLE DATA addr = 2 data = 00 // Index HI
    BLE DATA addr = 3 data = 01 // Index LO
    BLE DATA addr = 4 data = 13 // Value LO
    BLE DATA addr = 5 data = 01 // Value HI
    BLE DATA addr = 6 data = 6F // Time LO
    BLE DATA addr = 7 data = DC // Time LO
    BLE DATA addr = 8 data = CE // Time HI
    BLE DATA addr = 9 data = 1E // Time HI
    BLE DATA addr = 10 data = 48
    BLE DATA addr = 11 data = 2B
    BLE DATA addr = 12 data = 10
    BLE DATA addr = 13 data = 03
    BLE DATA addr = 14 data = 98
    BLE DATA addr = 15 data = 39
 
 or
 
 BLE DATA addr = 0 data = 10
 BLE DATA addr = 1 data = 02
 BLE DATA addr = 2 data = 00
 BLE DATA addr = 3 data = 10
 BLE DATA addr = 4 data = 10   // REPEAT
 BLE DATA addr = 5 data = B5
 BLE DATA addr = 6 data = 01
 BLE DATA addr = 7 data = 73
 BLE DATA addr = 8 data = 0D
 BLE DATA addr = 9 data = D1
 BLE DATA addr = 10 data = 1E
 BLE DATA addr = 11 data = FD
 BLE DATA addr = 12 data = 52
 BLE DATA addr = 13 data = 10
 BLE DATA addr = 14 data = 03
 BLE DATA addr = 15 data = BC
 
 
 2017-03-29 16:41:55.154 EMT[420:104234] VUE VUE  DEBUG ....
 2017-03-29 16:41:55.154 EMT[420:104234] VUE - 0 and 10
 2017-03-29 16:41:55.155 EMT[420:104234] VUE - 1 and 02
 2017-03-29 16:41:55.155 EMT[420:104234] VUE - 2 and 00
 2017-03-29 16:41:55.159 EMT[420:104234] VUE - 3 and A6
 2017-03-29 16:41:55.159 EMT[420:104234] VUE - 4 and 01
 2017-03-29 16:41:55.159 EMT[420:104234] VUE - 5 and 01
 2017-03-29 16:41:55.160 EMT[420:104234] VUE - 6 and 15
 2017-03-29 16:41:55.160 EMT[420:104234] VUE - 7 and 10
 2017-03-29 16:41:55.160 EMT[420:104234] VUE - 8 and 10
 2017-03-29 16:41:55.161 EMT[420:104234] VUE - 9 and 5C
 2017-03-29 16:41:55.161 EMT[420:104234] VUE - 10 and 1E
 2017-03-29 16:41:55.161 EMT[420:104234] VUE - 11 and 4D
 2017-03-29 16:41:55.162 EMT[420:104234] VUE - 12 and BD
 2017-03-29 16:41:55.162 EMT[420:104234] VUE - 13 and 10
 2017-03-29 16:41:55.164 EMT[420:104234] VUE - 14 and 03
 2017-03-29 16:41:55.165 EMT[420:104234] VUE - 15 and 1F
 2017-03-29 16:41:55.166 EMT[420:104234] VUE NEW TIME 10, 10, 5C, 1E
 
 */
    UInt32 inSecond = 0;
    UInt16 value = 0;
    H2BgRecord *ultraVueRecord;
    ultraVueRecord = [[H2BgRecord alloc] init];
    
    
    UInt8 vueIndex = 0;
    BOOL vueRecordYes = NO;
    //UInt8 indexOffset = 0;
    //UInt8 valueOffset = 0;
    while (vueIndex < length - 1) {
        if (inSrc[vueIndex] == 0x10 &&  inSrc[vueIndex+1] == 0x03) {
            vueRecordYes = YES;
            break;
        }
        vueIndex++;
    };
    
    if (vueRecordYes == NO) {
        ultraVueRecord.bgMealFlag = @"C";
        return ultraVueRecord;
    }
#ifdef DEBUG_VUE
    DLog(@"VUE LOCATION = %d", vueIndex);
    if (vueIndex > 12) {
        DLog(@"VUE LOCATION GREAT THAN = %d", vueIndex);
    }
#endif
    // NEW PROCESS
    switch (vueIndex) {
        case 12:
            // DON'T DO ANY THING ...
            break;
            
        case 13:
        case 14:
        case 15:
        case 16:
#ifdef DEBUG_VUE
            DLog(@"VUE NEW PROCESS = %d", vueIndex);
#endif
            vueIndex = 0;
            while (vueIndex < length - 1 && inSrc[vueIndex+1] != 0x03) {
                if ( inSrc[vueIndex] == 0x10 && inSrc[vueIndex+1] == 0x10) {
                    memcpy(&inSrc[vueIndex] , &inSrc[vueIndex+1] , length-vueIndex-1);
                }
                vueIndex++;
            };
            break;
            
            
        default:
            ultraVueRecord.bgMealFlag = @"C";
            return ultraVueRecord;
            break;
    }
    
    // Date Time
    memcpy(&inSecond, &inSrc[6], 4);
    
    // Value
    value = inSrc[5] & 0x0F; // HIGH BYTE
    value <<= 8;
    value += inSrc[4]; // LOW BYTE
    // Bit 0 ???
    value = value >> 1;
    
#if 0
    
    if ( inSrc[vueIndex-2] == 0x10 || inSrc[vueIndex-1] == 0x10) {
        indexOffset = 1;
    }
/*
    if (inSrc[vueIndex-2 -4 -indexOffset] == 0x10  && inSrc[vueIndex-2 -3 -indexOffset] == 0x10) {
        valueOffset = indexOffset +1;
    }
*/

    if ((inSrc[vueIndex-2 -4 -indexOffset] == 0x10 && inSrc[vueIndex-2 -3 -indexOffset] == 0x10)
        ||  (inSrc[vueIndex-2 -3 -indexOffset] == 0x10 && inSrc[vueIndex-2 -2 -indexOffset] == 0x10)) {
        valueOffset = indexOffset +1;
    }


    //UInt8 indexOffset = 0;
    //if (inSrc[3] == 0x10) {
    //    indexOffset = 1;
    //}
    
//#ifdef DEBUG_VUE
 //   if ((inSrc[5+indexOffset] & 0xF0) > 0) {
//        DLog(@"BIG DATA %02X ***********",  inSrc[5+indexOffset] & 0xF0);
 //   }
//#endif
    
    //inSrc[5+indexOffset] &= 0x0F; // High Byte
    //memcpy(&value, &inSrc[4+indexOffset], 2);
    //memcpy(&inSecond, &inSrc[6+indexOffset], 4);
    
    memcpy(&inSecond, &inSrc[vueIndex - 2 - 4 - indexOffset], 4);
    
    value = inSrc[vueIndex - 2 - 4 -1 -valueOffset] & 0x0F; // HIGH BYTE
    value <<= 8;
    value += inSrc[vueIndex - 2 - 4 -2 -valueOffset]; // LOW BYTE
    // Bit 0 ???
    value = value >> 1;
    
#endif
    
#ifdef DEBUG_VUE
    //DLog(@"VUE NEW TIME %02X, %02X, %02X, %02X", inSrc[vueIndex-2 -4 -indexOffset], inSrc[vueIndex-2 -3 -indexOffset], inSrc[vueIndex-2 -2 -indexOffset], inSrc[vueIndex-2 -1 -indexOffset]);
    DLog(@"VUE NEW TIME %02X, %02X, %02X, %02X", inSrc[6], inSrc[7], inSrc[8], inSrc[9]);
    DLog(@"VUE NEW VALUE %02X, %02X, and %d mg/dL", inSrc[4], inSrc[5], value);
    
    for (int i = 0; i<length; i++) {
        DLog(@"ULTRA DATA IS - %d and %02X", i, inSrc[i]);
    }
#endif

#ifdef DEBUG_VUE
    DLog(@"BG VALUE = %d BG", value);
#endif
    
    UInt32 totalMinute;
    UInt32 totalHour;
    UInt32 totalDay;
    
    UInt32 ultraVueMinute;
    UInt32 ultraVueHour;
    UInt32 ultraVueDay;
    
    
    UInt32 ultraVueMonth;
    UInt32 ultraVueYear;
    UInt32 totalYear;
    
    UInt16 y=0;
    totalMinute = inSecond / 60;
    totalHour = totalMinute / 60;
    ultraVueMinute = totalMinute - totalHour*60;
    totalDay = totalHour / 24;
    ultraVueHour = totalHour - totalDay * 24;
    
    totalDay--;
//    totalYear = totalDay / 365;
    
#if 1
    
    
    
    
#ifdef DEBUG_VUE
    DLog(@"2015 天數 %d, %d", (365 * 13 + 366 * 3), (int)totalDay - (365 * 13 + 366 * 3));
    
    DLog(@"2016 天數 %d, %d", (365 * 13 + 366 * 4), (int)totalDay-(365 * 13 + 366 * 4));
    
    
    DLog(@"2019 天數 %d, %d", (365 * 16 + 366 * 4), (int)totalDay - (365 * 16 + 366 * 4));
    
    DLog(@"2020 天數 %d, %d", (365 * 16 + 366 * 5), (int)totalDay-(365 * 16 + 366 * 5));
#endif
    
/*
#ifdef DEBUG_ONETOUCH
    DLog(@"年數 是 %d", (int)(totalYear));
    DLog(@"DEBUG_ONETOUCH the year is %lu", (long)(STR_YEAR_VUE + totalYear));
#endif
    do{
        x += 4;
        y++;
    }while (x <= STR_YEAR_VUE + totalYear) ;
    
    DLog(@"假潤年  %d  Total", y);
    
    // add this
    y -= ((STR_YEAR_VUE + totalYear)/100 - 19);
    
    ultraVueDay = totalDay -(totalYear * 365);
    
    DLog(@"潤年  %d  天數 %d", y, (int)ultraVueDay);
    
    if (ultraVueDay > y) {
        ultraVueDay -= y;
    }else{
        totalYear--;
        if (ultraVueYear%4 == 1) {
            ultraVueDay += 366;
        }else{
            ultraVueDay += 365;
        }
        ultraVueDay -= y;
    }
    
    ultraVueYear = STR_YEAR_VUE + totalYear;
    
    
    
//    DLog(@"前年 或是 去年 %d  剩餘天數 %d", (int)ultraVueYear，(int)ultraVueDay);
    DLog(@"(今年 and 明年)天數 %d", (int)ultraVueDay);
*/
    
    totalYear = 0;
    while(totalDay>0){
#ifdef DEBUG_VUE
        DLog(@" YEAR YEAR  %d and DAY DAY %d", (int)totalYear, (int) totalDay);
#endif
        if ((STR_YEAR_VUE + totalYear)%4==0 && (STR_YEAR_VUE + totalYear)%100!=0) {
            if(totalDay>=LEAP_YEAR){
                totalDay -= LEAP_YEAR;
#ifdef DEBUG_VUE
                DLog(@" YEAR YEAR  %d 潤年 ----", (int)totalYear);
#endif
            }else{
#ifdef DEBUG_VUE
                DLog(@" YEAR YEAR  %d 潤年 結束", (int)totalYear);
#endif
                break;
            }
        }else{
            if(totalDay>=NORMAL_YEAR){
                totalDay -= NORMAL_YEAR;
#ifdef DEBUG_VUE
                DLog(@" YEAR YEAR  %d 平年 ---", (int)totalYear);
#endif
            }else{
#ifdef DEBUG_VUE
                DLog(@" YEAR YEAR  %d 平年 結束", (int)totalYear);
#endif
                break;
            }
        }
        totalYear++;
#ifdef DEBUG_VUE
        DLog(@" YEAR YEAR  %d 後面", (int)totalYear);
#endif
    };
    
    ultraVueDay  = totalDay;
    ultraVueYear = STR_YEAR_VUE + totalYear;
    
#ifdef DEBUG_VUE
    DLog(@"(天數 %d, 年 %d", (int)ultraVueDay, (int)ultraVueYear);
    DLog(@"最後天數 %d", (int)ultraVueDay);
#endif
    
#endif
    
    


    y = 0;
    
    for (y =0; y<12; y++) {
        if (y == 0) {  // Jan
            if (ultraVueDay>=31) {
                ultraVueDay -=31;
            }else{
                break;
            }
        }else if (y==1){ // Feb
            if (ultraVueYear%4) {
                if (ultraVueDay >= 28) {
                    ultraVueDay -= 28;
                }else{
                    break;
                }
            }else{
                if (ultraVueDay >= 29) {
                    ultraVueDay -= 29;
                }else{
                    break;
                }
                
            }
        }else{ // the others
            if ((!(y%2) && y<7) || ((y%2) && y>= 7)) { // 3, 5, 7, 8, 10, 12
                if (ultraVueDay>=31) {
                    ultraVueDay -= 31;
                }else{
                    break;
                }
            }else{ // 4, 6, 9, 11
                if (ultraVueDay>=30) {
                    ultraVueDay -= 30;
                }else{
                    break;
                }
            }
        }
    }
    if (y<12) {
        ultraVueMonth = y+1;
    }else{
        ultraVueMonth = 1;
        ultraVueYear++;
    }
    ultraVueDay++;
    
    
    ultraVueRecord.bgDateTime  = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",(unsigned int)ultraVueYear, (unsigned int)ultraVueMonth, (unsigned int)ultraVueDay, (unsigned int)ultraVueHour, (unsigned int)ultraVueMinute];
    
    
    
    

#ifdef DEBUG_ONETOUCH
    DLog(@"DEBUG_ONETOUCH date time is %@", ultraVueRecord.bgDateTime);
#endif
    ultraVueRecord.bgUnit = BG_UNIT;
    ultraVueRecord.bgValue_mg = value;
    if (![ultraVueRecord.bgMealFlag isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:ultraVueRecord.bgDateTime]) {
            ultraVueRecord.bgMealFlag = @"C";
        }
    }
    
    return ultraVueRecord;
}




/*
 //////////////////////////////////////////////////////////////////////////////////////////////////




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

-(NSString *)ultraVueVersionParser:(char *)inSrc withLength:(UInt16)length
{
    NSString *string = [NSString stringWithUTF8String:inSrc];
    return string;
}

-(NSString *)ultraVueSerialNumberParser:(char *)inSrc withLength:(UInt16)length
{
    for (int i=0; i<length; i++) {
        DLog(@"VUE DEBUG - %d, and %02X", i, inSrc[i]);
    }
    unsigned char tmp[16] = {0};
    tmp[0]  = 'A';
    if (length > 16) {
        //memcpy(tmp, inSrc, 8)
    }
    NSString *string = [NSString stringWithUTF8String:tmp];
    return string;
}

-(NSString *)ultra2UnitParser:(char *)inSrc withLength:(UInt16)length
{
    NSString *string = [NSString stringWithUTF8String:inSrc];
    return string;
}
*/

/*
 
ac061a00 0201
 4020 22
 43 43 42 51 46 30 57 5a    // CCBQF0WZ
 2220
 30 32 45 34
 0d 0a8e
 
 
 
 
 
 
4C 2C 22
31 35  // 15
22
20
30 31 32 32 // 0122
0D
0A

2016-12-26 16:08:06.869414 EMT[3191:1590560] BLE HEADER addr = 0 data = AC
2016-12-26 16:08:06.869456 EMT[3191:1590560] BLE HEADER addr = 1 data = 06
2016-12-26 16:08:06.869497 EMT[3191:1590560] BLE HEADER addr = 2 data = 14
2016-12-26 16:08:06.869538 EMT[3191:1590560] BLE HEADER addr = 3 data = 00
2016-12-26 16:08:06.869689 EMT[3191:1590560] BLE HEADER addr = 4 data = 02
2016-12-26 16:08:06.871966 EMT[3191:1590560] BLE HEADER addr = 5 data = 01


ae062e00 0201
46
20 22
4d 4f 4e
22 2c 22
31 32 // MONTH
2f
32 36 // DAY
2f
31 36 // HOUR
22
2c 
22
31 37 // MINUTE
3a
30 36 // SECOND
3a
35 34
20 20 20 
22 20
30 36 30 46 // O6OF
0d 0a
d9

2016-12-26 16:08:06.989005 EMT[3191:1590560] BLE DATA addr = 0 data = 46
2016-12-26 16:08:06.989048 EMT[3191:1590560] BLE DATA addr = 1 data = 20
2016-12-26 16:08:06.989090 EMT[3191:1590560] BLE DATA addr = 2 data = 22
2016-12-26 16:08:06.989131 EMT[3191:1590560] BLE DATA addr = 3 data = 4D
2016-12-26 16:08:06.989174 EMT[3191:1590560] BLE DATA addr = 4 data = 4F
2016-12-26 16:08:06.989256 EMT[3191:1590560] BLE DATA addr = 5 data = 4E
2016-12-26 16:08:06.989303 EMT[3191:1590560] BLE DATA addr = 6 data = 22
2016-12-26 16:08:06.989345 EMT[3191:1590560] BLE DATA addr = 7 data = 2C
2016-12-26 16:08:06.989387 EMT[3191:1590560] BLE DATA addr = 8 data = 22
2016-12-26 16:08:06.989429 EMT[3191:1590560] BLE DATA addr = 9 data = 31
2016-12-26 16:08:06.989593 EMT[3191:1590560] BLE DATA addr = 10 data = 32
2016-12-26 16:08:06.989637 EMT[3191:1590560] BLE DATA addr = 11 data = 2F
2016-12-26 16:08:06.989766 EMT[3191:1590560] BLE DATA addr = 12 data = 32
2016-12-26 16:08:06.989855 EMT[3191:1590560] BLE DATA addr = 13 data = 36
2016-12-26 16:08:06.989898 EMT[3191:1590560] BLE DATA addr = 14 data = 2F
2016-12-26 16:08:06.989940 EMT[3191:1590560] BLE DATA addr = 15 data = 31
2016-12-26 16:08:06.989982 EMT[3191:1590560] BLE DATA addr = 16 data = 36
2016-12-26 16:08:06.990024 EMT[3191:1590560] BLE DATA addr = 17 data = 22
2016-12-26 16:08:06.990066 EMT[3191:1590560] BLE DATA addr = 18 data = 2C
2016-12-26 16:08:06.990107 EMT[3191:1590560] BLE DATA addr = 19 data = 22
2016-12-26 16:08:06.990183 EMT[3191:1590560] BLE DATA addr = 20 data = 31
2016-12-26 16:08:06.990231 EMT[3191:1590560] BLE DATA addr = 21 data = 37
2016-12-26 16:08:06.990274 EMT[3191:1590560] BLE DATA addr = 22 data = 3A
2016-12-26 16:08:06.990315 EMT[3191:1590560] BLE DATA addr = 23 data = 30
2016-12-26 16:08:06.990552 EMT[3191:1590560] BLE DATA addr = 24 data = 36
2016-12-26 16:08:06.990597 EMT[3191:1590560] BLE DATA addr = 25 data = 3A
2016-12-26 16:08:06.990639 EMT[3191:1590560] BLE DATA addr = 26 data = 35
2016-12-26 16:08:06.990680 EMT[3191:1590560] BLE DATA addr = 27 data = 34
2016-12-26 16:08:06.990763 EMT[3191:1590560] BLE DATA addr = 28 data = 20
2016-12-26 16:08:06.990806 EMT[3191:1590560] BLE DATA addr = 29 data = 20
2016-12-26 16:08:06.990848 EMT[3191:1590560] BLE DATA addr = 30 data = 20
2016-12-26 16:08:06.990890 EMT[3191:1590560] BLE DATA addr = 31 data = 22
2016-12-26 16:08:06.990931 EMT[3191:1590560] BLE DATA addr = 32 data = 20
2016-12-26 16:08:06.990973 EMT[3191:1590560] BLE DATA addr = 33 data = 30
2016-12-26 16:08:06.991014 EMT[3191:1590560] BLE DATA addr = 34 data = 36
2016-12-26 16:08:06.991056 EMT[3191:1590560] BLE DATA addr = 35 data = 30
2016-12-26 16:08:06.991097 EMT[3191:1590560] BLE DATA addr = 36 data = 46
2016-12-26 16:08:06.991625 EMT[3191:1590560] BLE DATA addr = 37 data = 0D
2016-12-26 16:08:06.991671 EMT[3191:1590560] BLE DATA addr = 38 data = 0A
2016-12-26 16:08:06.991840 EMT[3191:1590560] BLE HEADER addr = 0 data = AE
2016-12-26 16:08:06.991886 EMT[3191:1590560] BLE HEADER addr = 1 data = 06
2016-12-26 16:08:06.991928 EMT[3191:1590560] BLE HEADER addr = 2 data = 2E
2016-12-26 16:08:06.991969 EMT[3191:1590560] BLE HEADER addr = 3 data = 00
2016-12-26 16:08:06.992011 EMT[3191:1590560] BLE HEADER addr = 4 data = 02
2016-12-26 16:08:06.992052 EMT[3191:1590560] BLE HEADER addr = 5 data = 01



af062100 0201
3f 56 30 33 // V03.02.00 11/18/09
2e
30 32 // 02
2e
30 30 // 00
20
31 31 // 11
2f
31 38 // 18
2f
30 39 // 09
20
30 33 43 38 // 03C8
0d 0a
a9

2016-12-26 16:08:07.109118 EMT[3191:1590560] BLE DATA addr = 0 data = 3F
2016-12-26 16:08:07.109169 EMT[3191:1590560] BLE DATA addr = 1 data = 56
2016-12-26 16:08:07.109240 EMT[3191:1590560] BLE DATA addr = 2 data = 30
2016-12-26 16:08:07.109286 EMT[3191:1590560] BLE DATA addr = 3 data = 33
2016-12-26 16:08:07.109328 EMT[3191:1590560] BLE DATA addr = 4 data = 2E
2016-12-26 16:08:07.109370 EMT[3191:1590560] BLE DATA addr = 5 data = 30
2016-12-26 16:08:07.109553 EMT[3191:1590560] BLE DATA addr = 6 data = 32
2016-12-26 16:08:07.109602 EMT[3191:1590560] BLE DATA addr = 7 data = 2E
2016-12-26 16:08:07.109645 EMT[3191:1590560] BLE DATA addr = 8 data = 30
2016-12-26 16:08:07.109687 EMT[3191:1590560] BLE DATA addr = 9 data = 30
2016-12-26 16:08:07.109729 EMT[3191:1590560] BLE DATA addr = 10 data = 20
2016-12-26 16:08:07.109771 EMT[3191:1590560] BLE DATA addr = 11 data = 31
2016-12-26 16:08:07.109812 EMT[3191:1590560] BLE DATA addr = 12 data = 31
2016-12-26 16:08:07.109854 EMT[3191:1590560] BLE DATA addr = 13 data = 2F
2016-12-26 16:08:07.110632 EMT[3191:1590560] BLE DATA addr = 14 data = 31
2016-12-26 16:08:07.110679 EMT[3191:1590560] BLE DATA addr = 15 data = 38
2016-12-26 16:08:07.110722 EMT[3191:1590560] BLE DATA addr = 16 data = 2F
2016-12-26 16:08:07.110764 EMT[3191:1590560] BLE DATA addr = 17 data = 30
2016-12-26 16:08:07.110806 EMT[3191:1590560] BLE DATA addr = 18 data = 39
2016-12-26 16:08:07.110916 EMT[3191:1590560] BLE DATA addr = 19 data = 20
2016-12-26 16:08:07.110960 EMT[3191:1590560] BLE DATA addr = 20 data = 30
2016-12-26 16:08:07.111002 EMT[3191:1590560] BLE DATA addr = 21 data = 33
2016-12-26 16:08:07.111044 EMT[3191:1590560] BLE DATA addr = 22 data = 43
2016-12-26 16:08:07.111086 EMT[3191:1590560] BLE DATA addr = 23 data = 38
2016-12-26 16:08:07.111128 EMT[3191:1590560] BLE DATA addr = 24 data = 0D
2016-12-26 16:08:07.111170 EMT[3191:1590560] BLE DATA addr = 25 data = 0A
2016-12-26 16:08:07.111213 EMT[3191:1590560] BLE HEADER addr = 0 data = AF
2016-12-26 16:08:07.111507 EMT[3191:1590560] BLE HEADER addr = 1 data = 06
2016-12-26 16:08:07.111551 EMT[3191:1590560] BLE HEADER addr = 2 data = 21
2016-12-26 16:08:07.111593 EMT[3191:1590560] BLE HEADER addr = 3 data = 00
2016-12-26 16:08:07.111634 EMT[3191:1590560] BLE HEADER addr = 4 data = 02
2016-12-26 16:08:07.111676 EMT[3191:1590560] BLE HEADER addr = 5 data = 01


// Number Of Records
a3061500 0201
47                          ; G
2c 22
36 30 30                    // 600
22 20
30 31 34 44                 // 014D
0d 0a 89

2016-12-26 16:08:07.228802 EMT[3191:1590560] BLE DATA addr = 0 data = 47
2016-12-26 16:08:07.228987 EMT[3191:1590560] BLE DATA addr = 1 data = 2C
2016-12-26 16:08:07.229032 EMT[3191:1590560] BLE DATA addr = 2 data = 22
2016-12-26 16:08:07.229074 EMT[3191:1590560] BLE DATA addr = 3 data = 36
2016-12-26 16:08:07.229116 EMT[3191:1590560] BLE DATA addr = 4 data = 30
2016-12-26 16:08:07.229157 EMT[3191:1590560] BLE DATA addr = 5 data = 30
2016-12-26 16:08:07.229201 EMT[3191:1590560] BLE DATA addr = 6 data = 22
2016-12-26 16:08:07.229243 EMT[3191:1590560] BLE DATA addr = 7 data = 20
2016-12-26 16:08:07.229328 EMT[3191:1590560] BLE DATA addr = 8 data = 30
2016-12-26 16:08:07.229371 EMT[3191:1590560] BLE DATA addr = 9 data = 31
2016-12-26 16:08:07.229413 EMT[3191:1590560] BLE DATA addr = 10 data = 34
2016-12-26 16:08:07.229455 EMT[3191:1590560] BLE DATA addr = 11 data = 44
2016-12-26 16:08:07.229496 EMT[3191:1590560] BLE DATA addr = 12 data = 0D
2016-12-26 16:08:07.229538 EMT[3191:1590560] BLE DATA addr = 13 data = 0A
2016-12-26 16:08:07.229580 EMT[3191:1590560] BLE HEADER addr = 0 data = A3
2016-12-26 16:08:07.229827 EMT[3191:1590560] BLE HEADER addr = 1 data = 06
2016-12-26 16:08:07.229917 EMT[3191:1590560] BLE HEADER addr = 2 data = 15
2016-12-26 16:08:07.229959 EMT[3191:1590560] BLE HEADER addr = 3 data = 00
2016-12-26 16:08:07.230001 EMT[3191:1590560] BLE HEADER addr = 4 data = 02
2016-12-26 16:08:07.230042 EMT[3191:1590560] BLE HEADER addr = 5 data = 01



ab061400 0201
4c                      // L
2c 22
31 35                   // 15
22 20
30 31 32 32             // 0122
0d0af2

2016-12-26 16:08:07.347287 EMT[3191:1590560] BLE DATA addr = 0 data = 4C
2016-12-26 16:08:07.347329 EMT[3191:1590560] BLE DATA addr = 1 data = 2C
2016-12-26 16:08:07.347371 EMT[3191:1590560] BLE DATA addr = 2 data = 22
2016-12-26 16:08:07.347413 EMT[3191:1590560] BLE DATA addr = 3 data = 31
2016-12-26 16:08:07.347631 EMT[3191:1590560] BLE DATA addr = 4 data = 35
2016-12-26 16:08:07.347679 EMT[3191:1590560] BLE DATA addr = 5 data = 22
2016-12-26 16:08:07.347722 EMT[3191:1590560] BLE DATA addr = 6 data = 20
2016-12-26 16:08:07.347764 EMT[3191:1590560] BLE DATA addr = 7 data = 30
2016-12-26 16:08:07.347806 EMT[3191:1590560] BLE DATA addr = 8 data = 31
2016-12-26 16:08:07.347848 EMT[3191:1590560] BLE DATA addr = 9 data = 32
2016-12-26 16:08:07.347890 EMT[3191:1590560] BLE DATA addr = 10 data = 32
2016-12-26 16:08:07.347932 EMT[3191:1590560] BLE DATA addr = 11 data = 0D
2016-12-26 16:08:07.348035 EMT[3191:1590560] BLE DATA addr = 12 data = 0A
2016-12-26 16:08:07.348079 EMT[3191:1590560] BLE HEADER addr = 0 data = AB
2016-12-26 16:08:07.348121 EMT[3191:1590560] BLE HEADER addr = 1 data = 06
2016-12-26 16:08:07.348163 EMT[3191:1590560] BLE HEADER addr = 2 data = 14
2016-12-26 16:08:07.348204 EMT[3191:1590560] BLE HEADER addr = 3 data = 00
2016-12-26 16:08:07.348245 EMT[3191:1590560] BLE HEADER addr = 4 data = 02
2016-12-26 16:08:07.348411 EMT[3191:1590560] BLE HEADER addr = 5 data = 01

*/
#if 0
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
//            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"meter_unit"]) {
                ultra2Record.bgUnit = BG_UNIT_EX;
                ultra2Record.bgValue_mmol = (float)tmpValue/MMOL_COIF;
            }else{
                ultra2Record.bgUnit = BG_UNIT;
                ultra2Record.bgValue_mg = tmpValue;
            }
            
            
            ultra2Record.bgIndex = tmpOffset;
            
            ultra2Record.bgFlag = tmp[11];
            
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

#endif


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

#if 0
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

#endif

#if 0

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
    
    
    //        if (inSrc[OFFSET_FLAG]) {
    //            ultra2Record.bgFlag
    //        }
    
    if (inSrc[34] == 'C' || inSrc[39] == '?') { // Record Data OK
        ultra2Record.bgMealFlag = @"R";
    }else{
        ultra2Record.bgFlag = inSrc[43];
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

#endif

@end



