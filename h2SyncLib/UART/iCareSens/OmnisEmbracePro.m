//
//  OmnisEmbracePro.m
//  h2SyncLib
//
//  Created by h2Sync on 2014/2/17.
//
//


#define START_AT                    0
#define CMD_DATA_LEN_AT             1
#define CMD_DATA_LEN_INV_AT         2
#define COMMAND_AT                  3
#define DATA_AT                     4

#define REPORT_INDEX_HI_AT              4
#define REPORT_INDEX_LO_AT              5
#define REPORT_DATA1_AT              6
#define REPORT_DATA2_AT              7
#define REPORT_DATA3_AT              8
#define REPORT_DATA4_AT              9
#define REPORT_DATA5_AT              10
#define REPORT_DATA6_AT              11



#define START_VALUE                 0x80

#define CMD_TOTAL_NUM_RECORD_REQUEST                        0x0
#define CMD_ONE_RECORD_REQUEST                              0x1
#define CMD_MEASUREMENT_MODE_REQUEST                        0x2
#define CMD_CODE_SETTING                                    0x3
#define CMD_DATE_SETTING                                    0x4

#define CMD_UNIT_SETTING                                    0x5
#define CMD_AVERAGE_DAY_SETTING                             0x6
#define CMD_ALARM_SETTING                                   0x7
#define CMD_DEVICE_ID_SETTING                               0x8
#define CMD_DEVICE_ID_REQUEST                               0x9
#define CMD_SOFTWARE_VERSION_REQUEST                        0xA
#define CMD_POWER_OFF_REQUEST                               0xB
#define CMD_CLEAR_MEMORY                                    0xC
#define CMD_TOTAL_USER_ID_REQUEST                           0xD
#define CMD_CURRENT_USER_ID_REQUEST                         0xE





#import "OmnisEmbracePro.h"
#import "H2AudioFacade.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"
#import "H2BleTimer.h"

@implementation OmnisEmbracePro
{
}


- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}

+ (OmnisEmbracePro *)sharedInstance
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

- (void)EmbraceProCommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdTypeId = 0;
    UInt8 CHKSUM_AT = 0;
    UInt8 COMMAND_LEN = 0;
    UInt8 RETURN_LEN = 0;
    UInt8 dataLen = 7;
    
    Byte cmdBuffer[48] = {0};

    switch (cmdMethod) {
        case METHOD_INIT:

            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            
            CHKSUM_AT = 4;
            COMMAND_LEN = 6;
            RETURN_LEN = COMMAND_LEN + 2;
            
            cmdBuffer[COMMAND_AT] = CMD_TOTAL_NUM_RECORD_REQUEST;
            cmdBuffer[START_AT] = START_VALUE;
            
            
            cmdBuffer[CMD_DATA_LEN_AT] = 1;
            cmdBuffer[CMD_DATA_LEN_INV_AT] = ~1;
            
            cmdBuffer[CHKSUM_AT] = ~(cmdBuffer[START_AT] ^ cmdBuffer[CMD_DATA_LEN_INV_AT]);
            cmdBuffer[CHKSUM_AT+1] = ~(cmdBuffer[CMD_DATA_LEN_AT] ^ cmdBuffer[COMMAND_AT]);
            break;
            

            
        case METHOD_BRAND:
            cmdTypeId = (currentMeter<<4) + METHOD_BRAND;
            
            // SET MODE YEAR MONTH SN
            
            CHKSUM_AT = 4 + dataLen;
            COMMAND_LEN = 6 + dataLen;
            RETURN_LEN = COMMAND_LEN;// + 7;
            cmdBuffer[COMMAND_AT] = CMD_DEVICE_ID_SETTING;
            
            cmdBuffer[START_AT] = START_VALUE;
            
            cmdBuffer[CMD_DATA_LEN_AT] = 1 + dataLen;
            cmdBuffer[CMD_DATA_LEN_INV_AT] = ~(1 + dataLen);
            
            Byte  *timeBuffer;
            timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
            
            UInt16 year = timeBuffer[0]; //[components year];
            year += 2000;
            memcpy(&cmdBuffer[COMMAND_AT+1], &year, 2);
            
            cmdBuffer[COMMAND_AT+3] =timeBuffer[1]; //month;
            cmdBuffer[COMMAND_AT+4] =timeBuffer[2]; //day;
            
            cmdBuffer[COMMAND_AT+5] =timeBuffer[3]; //hour;
            cmdBuffer[COMMAND_AT+6] = timeBuffer[4]; //minute;
            cmdBuffer[COMMAND_AT+7] = timeBuffer[15]; //second;
            
            cmdBuffer[CHKSUM_AT] = ~(cmdBuffer[START_AT] ^ cmdBuffer[CMD_DATA_LEN_INV_AT] ^ cmdBuffer[4] ^ cmdBuffer[6] ^ cmdBuffer[8] ^ cmdBuffer[10]);
            cmdBuffer[CHKSUM_AT+1] = ~(cmdBuffer[CMD_DATA_LEN_AT] ^ cmdBuffer[COMMAND_AT] ^ cmdBuffer[5] ^ cmdBuffer[7] ^ cmdBuffer[9]);
            
            for (int i = 0; i < COMMAND_LEN + 2; i++) {
                DLog(@"EM_PRO DEBUG --- SN index %d and data %02X", i, cmdBuffer[i]);
            }
            
            break;
            
        case METHOD_SN:
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            
            CHKSUM_AT = 4;
            COMMAND_LEN = 6;
            RETURN_LEN = COMMAND_LEN + 7;
            cmdBuffer[COMMAND_AT] = CMD_DEVICE_ID_REQUEST;
            
            cmdBuffer[START_AT] = START_VALUE;
            
            cmdBuffer[CMD_DATA_LEN_AT] = 1;
            cmdBuffer[CMD_DATA_LEN_INV_AT] = ~1;
            
            cmdBuffer[CHKSUM_AT] = ~(cmdBuffer[START_AT] ^ cmdBuffer[CMD_DATA_LEN_INV_AT]);
            cmdBuffer[CHKSUM_AT+1] = ~(cmdBuffer[CMD_DATA_LEN_AT] ^ cmdBuffer[COMMAND_AT]);
            break;
            
        case METHOD_UNIT:
            cmdTypeId = (currentMeter<<4) + METHOD_UNIT;
            
            CHKSUM_AT = 5;
            COMMAND_LEN = 7;
            RETURN_LEN = COMMAND_LEN;
            
            //    cmd[COMMAND_AT] = CMD_SOFTWARE_VERSION_REQUEST;
            
            cmdBuffer[COMMAND_AT] = CMD_UNIT_SETTING; // for test
            
            cmdBuffer[START_AT] = START_VALUE;
            
            
            cmdBuffer[CMD_DATA_LEN_AT] = 1+1;
            cmdBuffer[CMD_DATA_LEN_INV_AT] = ~(1+1);
            
            cmdBuffer[COMMAND_AT + 1] = 1;
            
            cmdBuffer[CHKSUM_AT] = ~(cmdBuffer[START_AT] ^ cmdBuffer[CMD_DATA_LEN_INV_AT] ^ cmdBuffer[COMMAND_AT + 1]);
            cmdBuffer[CHKSUM_AT+1] = ~(cmdBuffer[CMD_DATA_LEN_AT] ^ cmdBuffer[COMMAND_AT]);

            break;
            
        case METHOD_NROFRECORD:
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            CHKSUM_AT = 4;
            COMMAND_LEN = 6;
            RETURN_LEN = COMMAND_LEN + 2;
            
            cmdBuffer[START_AT] = START_VALUE;
            
            cmdBuffer[CMD_DATA_LEN_AT] = 1;
            cmdBuffer[CMD_DATA_LEN_INV_AT] = ~1;
            
            cmdBuffer[COMMAND_AT] = CMD_TOTAL_NUM_RECORD_REQUEST;
            
            cmdBuffer[CHKSUM_AT] = ~(cmdBuffer[START_AT] ^ cmdBuffer[CMD_DATA_LEN_INV_AT]);
            cmdBuffer[CHKSUM_AT+1] = ~(cmdBuffer[CMD_DATA_LEN_AT] ^ cmdBuffer[COMMAND_AT]);
            break;
            
        case METHOD_VERSION:
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            CHKSUM_AT = 4;
            COMMAND_LEN = 6;
            RETURN_LEN = COMMAND_LEN + 2;
            
            cmdBuffer[COMMAND_AT] = CMD_SOFTWARE_VERSION_REQUEST;
            
            //    cmd[COMMAND_AT] = CMD_UNIT_SETTING; // for test
            cmdBuffer[START_AT] = START_VALUE;
            
            
            cmdBuffer[CMD_DATA_LEN_AT] = 1;
            cmdBuffer[CMD_DATA_LEN_INV_AT] = ~1;
            
            cmdBuffer[CHKSUM_AT] = ~(cmdBuffer[START_AT] ^ cmdBuffer[CMD_DATA_LEN_INV_AT]);
            cmdBuffer[CHKSUM_AT+1] = ~(cmdBuffer[CMD_DATA_LEN_AT] ^ cmdBuffer[COMMAND_AT]);
            break;
            
        case METHOD_END:
            cmdTypeId = (currentMeter<<4) + METHOD_END;
            
            CHKSUM_AT = 4;
            COMMAND_LEN = 6;
            RETURN_LEN = COMMAND_LEN;
            
            cmdBuffer[COMMAND_AT] = CMD_POWER_OFF_REQUEST;
            cmdBuffer[START_AT] = START_VALUE;
            
            
            cmdBuffer[CMD_DATA_LEN_AT] = 1;
            cmdBuffer[CMD_DATA_LEN_INV_AT] = ~1;
            
            cmdBuffer[CHKSUM_AT] = ~(cmdBuffer[START_AT] ^ cmdBuffer[CMD_DATA_LEN_INV_AT]);
            cmdBuffer[CHKSUM_AT+1] = ~(cmdBuffer[CMD_DATA_LEN_AT] ^ cmdBuffer[COMMAND_AT]);
            break;
            
        default:
            break;
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:COMMAND_LEN cmdType:cmdTypeId returnDataLength:RETURN_LEN mcuBufferOffSetAt:0];
}



- (void)EmbraceProReadRecord:(UInt16)nIndex
{
    UInt16 embraceProCmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_RECORD;
    unsigned char cmd[12] = {0};
    
    UInt8 CHKSUM_AT = 6;
    UInt8 COMMAND_LEN = 8;
    
    UInt8 RETURN_LEN = COMMAND_LEN + 6;
    
    cmd[COMMAND_AT] = CMD_ONE_RECORD_REQUEST;
    cmd[START_AT] = START_VALUE;
    
    
    cmd[CMD_DATA_LEN_AT] = 1+2;
    cmd[CMD_DATA_LEN_INV_AT] = ~(cmd[CMD_DATA_LEN_AT]);
    
    // Big Endian
    cmd[COMMAND_AT + 1] = (nIndex & 0xFF00)>>8;
    cmd[COMMAND_AT + 2] = nIndex & 0xFF;
    
    cmd[CHKSUM_AT] = ~(cmd[START_AT] ^ cmd[CMD_DATA_LEN_INV_AT] ^ cmd[COMMAND_AT + 1]);
    cmd[CHKSUM_AT+1] = ~(cmd[CMD_DATA_LEN_AT] ^ cmd[COMMAND_AT] ^ cmd[COMMAND_AT + 2]);
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmd withCmdLength:COMMAND_LEN cmdType: embraceProCmdType returnDataLength:RETURN_LEN mcuBufferOffSetAt:0];
    
}

#pragma mark -
#pragma mark PARSER METHOD FOR EMBRACE PRO

- (H2MeterSystemInfo *)omnisEmbraceProCurrentTimeParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2MeterSystemInfo *omnisEmbraceProSystemInfo;
    omnisEmbraceProSystemInfo = [[H2MeterSystemInfo alloc] init];
    
    return omnisEmbraceProSystemInfo;
}


- (UInt16)omnisEmbraceProNumberOfRecordParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    //H2BgRecord *omnisEmbraceProRecord;
    //omnisEmbraceProRecord = [[H2BgRecord alloc] init];
    
    UInt16 embraceProNumber;
    

    
//    DLog(@"thc check sum Low %02X", ~(recordData[START_AT]^recordData[CMD_DATA_LEN_INV_AT]^recordData[REPORT_INDEX_HI_AT]^recordData[REPORT_DATA1_AT]^recordData[REPORT_DATA3_AT]^recordData[REPORT_DATA5_AT]));
//    DLog(@"thc check sum High %02X", ~(recordData[CMD_DATA_LEN_AT]^recordData[COMMAND_AT]^recordData[REPORT_INDEX_LO_AT]^recordData[REPORT_DATA2_AT]^recordData[REPORT_DATA4_AT]^recordData[REPORT_DATA6_AT]));
    
    
    // Big endian
    embraceProNumber = recordData[REPORT_INDEX_HI_AT]*256 + recordData[REPORT_INDEX_LO_AT];
    DLog(@"the record number is %d", embraceProNumber);
    
    return embraceProNumber;
}



- (H2BgRecord *)omnisEmbraceProDateTimeValueParser//:(UInt16)nIndex
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *omnisEmbraceProRecord;
    omnisEmbraceProRecord = [[H2BgRecord alloc] init];
    
    UInt16 embraceProYear;
    UInt8 embraceProMon;
    UInt8 embraceProDay;
    
    UInt8 embraceProHour;
    UInt8 embraceProMin;
    
    UInt8 embraceProEvent;
    
    UInt8 embraceProCode;
    UInt8 embraceProId;
    UInt8 embraceProValue;
    
//    UInt16 embraceProIndex;
    
    DLog(@"thc check sum Low %02X", ~(recordData[START_AT]^recordData[CMD_DATA_LEN_INV_AT]^recordData[REPORT_INDEX_HI_AT]^recordData[REPORT_DATA1_AT]^recordData[REPORT_DATA3_AT]^recordData[REPORT_DATA5_AT]));
    DLog(@"thc check sum High %02X", ~(recordData[CMD_DATA_LEN_AT]^recordData[COMMAND_AT]^recordData[REPORT_INDEX_LO_AT]^recordData[REPORT_DATA2_AT]^recordData[REPORT_DATA4_AT]^recordData[REPORT_DATA6_AT]));
    
    
    embraceProYear = (recordData[REPORT_DATA1_AT]&0xFE)>>1;
    embraceProYear += 2000;
    
    embraceProMon = ((recordData[REPORT_DATA1_AT]&0x01)<<3) + ((recordData[REPORT_DATA2_AT]&0xE0)>>5);
    embraceProDay = recordData[REPORT_DATA2_AT]&0x1F;
    
    embraceProHour = ((recordData[REPORT_DATA5_AT]&0x07)<<2) + ((recordData[REPORT_DATA6_AT]&0xC0)>>6);
    embraceProMin = recordData[REPORT_DATA6_AT]&0x3F;
    
    embraceProEvent = (recordData[REPORT_DATA5_AT]&0xC0)>>6;
    embraceProId = (recordData[REPORT_DATA5_AT]&0x38)>>3;
    
    embraceProCode = (recordData[REPORT_DATA3_AT]&0xFC)>>2;
    embraceProValue = ((recordData[REPORT_DATA3_AT]&0x03)>>2)*256 + (recordData[REPORT_DATA4_AT]&0xFF);
    
    // Big endian
//    embraceProIndex = recordData[REPORT_INDEX_HI_AT]*256 + recordData[REPORT_INDEX_LO_AT];
    
    omnisEmbraceProRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",embraceProYear, embraceProMon, embraceProDay, embraceProHour, embraceProMin];
    
    omnisEmbraceProRecord.bgUnit = @"N";
    omnisEmbraceProRecord.bgValue_mg = embraceProValue;
        
    
    DLog(@"the value %003d and datetime %@", omnisEmbraceProRecord.bgValue_mg, omnisEmbraceProRecord.bgDateTime);
    
    switch (embraceProEvent) {
        case 0:
        default:
            omnisEmbraceProRecord.bgMealFlag = @"N";
            break;
        case 1:
            omnisEmbraceProRecord.bgMealFlag = @"A";
            break;
        case 2:
            omnisEmbraceProRecord.bgMealFlag = @"B";
            break;
        case 3:
//            omnisEmbraceProRecord.smRecordFlag = 'E';
            omnisEmbraceProRecord.bgMealFlag = @"C";
            break;
            
    }
    if (![omnisEmbraceProRecord.bgMealFlag   isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:omnisEmbraceProRecord.bgDateTime]) {
            omnisEmbraceProRecord.bgMealFlag = @"C";
        }
    }
    
    return omnisEmbraceProRecord;
}


- (BOOL)omnisEmbraceProSerialNumberParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(256);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    if (srcData[REPORT_DATA1_AT] == 0xFF && srcData[REPORT_DATA2_AT] == 0xFF) {
        return NO;
    }
/*
    DLog(@"thc check sum Low %02X", ~(srcData[START_AT]^srcData[CMD_DATA_LEN_INV_AT]^srcData[REPORT_INDEX_HI_AT]^srcData[REPORT_DATA1_AT]^srcData[REPORT_DATA3_AT]^srcData[REPORT_DATA5_AT]));
    DLog(@"thc check sum High %02X", ~(srcData[CMD_DATA_LEN_AT]^srcData[COMMAND_AT]^srcData[REPORT_INDEX_LO_AT]^srcData[REPORT_DATA2_AT]^srcData[REPORT_DATA4_AT]^srcData[REPORT_DATA6_AT]));
*/
    
    
    unsigned char snFormer[15] = {0};
    unsigned tmpValue = 0;
    
    tmpValue = srcData[COMMAND_AT+1];
    tmpValue >>= 4;
    snFormer[0] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[1] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[COMMAND_AT+1] & 0x0F];
    
    tmpValue = srcData[COMMAND_AT+2];
    tmpValue >>= 4;
    snFormer[2] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[3] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[COMMAND_AT+2] & 0x0F];
    
    tmpValue = srcData[COMMAND_AT+3];
    tmpValue >>= 4;
    snFormer[4] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[5] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[COMMAND_AT+3] & 0x0F];
    
    tmpValue = srcData[COMMAND_AT+4];
    tmpValue >>= 4;
    snFormer[6] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[7] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[COMMAND_AT+4] & 0x0F];
    
    tmpValue = srcData[COMMAND_AT+5];
    tmpValue >>= 4;
    snFormer[8] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[9] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[COMMAND_AT+5] & 0x0F];
    
    tmpValue = srcData[COMMAND_AT+6];
    tmpValue >>= 4;
    snFormer[10] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[11] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[COMMAND_AT+6] & 0x0F];
    
    tmpValue = srcData[COMMAND_AT+7];
    tmpValue >>= 4;
    snFormer[12] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[13] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[COMMAND_AT+7] & 0x0F];
    
    
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [NSString stringWithUTF8String:(const char *)snFormer];
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
#ifdef DEBUG_BIONIME
    DLog(@"DEBUG_EMPRO -- VER SN -- %@", [h2MeterModelSerialNumber sharedInstance].smSerialNumber);
#endif
    
#ifdef DEBUG_LIB
    for (int i=0; i<15; i++) {
        DLog(@"SN Former %d and %02X", i, snFormer[i]);
    }
#endif
    
    return YES;
}

@end
