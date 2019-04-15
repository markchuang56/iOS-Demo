//
//  Hmd.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/10/20.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

#import "H2AudioFacade.h"

#import "h2CmdInfo.h"
#import "H2DebugHeader.h"

#import "H2Config.h"

#import "Hmd.h"
#import "H2BleCentralManager.h"

#import "H2DataFlow.h"
#import "H2Records.h"

#define CMD_LEN_INIT                        1
#define CMD_LEN_GENERAL                     3



#define RTN_LEN_INIT                        1
#define RTN_LEN_INIT_EX                     2
#define RTN_LEN_GENERAL                     3


#define CMD_INIT                        0x00
#define CMD_INIT_EX                     0x55

#define CMD_METER_ON                    0xBA
#define CMD_METER_OFF                   0xB5

#define CMD_HMD_PROTOCOL                            0xA8

#define CMD_FUN1_DES_HD                             0x01
#define CMD_FUN2_REC_DES                            0x02
#define CMD_FUN3_DES_TYPE                           0x03

#define CMD_DES_TYPE_BG                             0x01

#define CMD_RTC                     0xA1
#define CMD_REC_NR                  0xAE
#define CMD_PYEAR                   0xAC
#define CMD_MODEL                   0xAD
#define CMD_RECORD                  0xAF



unsigned char cmdInit0[] = {0x00};
// Receive 0x00
#define CMD_LEN_FNC                1
unsigned char cmdInit55[0x55] = {0x55};
// REceive 0x54, 0xF1

unsigned char cmdMeterOn[] = {0xBA};//, 0xA5, 0xA9};
// Meter On-Line
// REceive 0xAA, 0x5A, 0xAA


unsigned char cmdMeterOff[] = {0xB5};//, 0xA5, 0xA9};
// Meter Turn Off
// REceive 0xAA, 0x5A, 0xAA
#define CMD_LEN_FNC                1


#define CMD_LEN_FUN1                (4-1)
#define RTN_LEN_FUN1                (2+48+2)
// Fun 1, Read Descriptor Header
// Send A8 01, ChkSum Hi, and Lo
// Receive A8 01 Byte * 48, ChkSum Hi, and Lo
// CMD : [A8], HMD Protocol Command
// FUN : [01], Read Descriptor Header
// Send [A8], [01], [ChkSum]
// Receive = [A8], [01], [Data1], [Data2], ...[Data48], [ChkSum HI], [ChkSum LO]

#define CMD_LEN_FUN2                (5-1)
#define RTN_LEN_FUN2                (2+40+2)
// CMD : [A8], HMD Protocol Command
// FUN : [02], Read Record Descriptor
// Fun 2, Read Record Descriptor
// Send [A8] [02], [Descriptor Type], [ChkSum HI], [ChkSum LO]
// Receive [A8], [02], [Data1], [Data2], ...[Data40], [ChkSum HI], [ChkSum LO]

// Fun 3,

#define CMD_LEN_RTC                3
#define RTN_LEN_RTC                9
// Read/Write RTC
// Send cmd A1
// Receive [B1][Year],[Month],[Date],[Hour],[Minute],[Second],[ChkSum HI],[ChkSum LO]
// or Receive [A2][Year],[Month],[Date],[Hour],[Minute],[Second],[ChkSum HI],[ChkSum LO]
// Example(Hex):2015(2000 + [Year], August, 08, PM:05:08:39
// A1, A5, A9
// B1, 0F, 08, 08, 11, 08, 27, 01, 10
// or A2, 0F, 08, 08, 11, 08, 27, 01, 10
unsigned char cmdReadRTC[] = {0xA1};//, 0xA5, 0xA9};

#define CMD_LEN_NUMBER                3
#define RTN_LEN_NUMBER                4
// Read Number of Total Record
// Send cmd AE
// Receive : [Data_H], [Data_L], [5A], [AA]
// Example : Total Record No : 291 (0123h)
// Send AE, A5, A9
// Receive : 01, 23, 5A, AA
unsigned char cmdReadNr[] = {0xAE};//, 0xA5, 0xA9};


#define CMD_LEN_PYEAR                3
#define RTN_LEN_PYEAR                3
// Read Production Year
// Send cmd AC, B5, B9
// Receive :[Data], [5C], [BB]
// Example(Hex): Read Product Year(1 byte(0~99) (Real Product Year is 2000 + [Data]), Product Year : 2015 ÷ 15 (0Eh)
// Send : AC, B5, B9
// Receive : 0E, 5C, BB

unsigned char cmdReadYear[] = {0xAC};//, 0xB5, 0xB9};

#define CMD_LEN_MODEL                3
#define RTN_LEN_MODEL                3
// Read Model Number
// Send cmd AD
// Send : [AD], [B5], [B9]
// Receive : [Data], [5C], [BB]
// Example(Hex) : Read Model No (1 byte(0~255), Model No : 135 (87h)
// Send: AD, B5, B9
// Receive : 87, 5C, BB
unsigned char cmdReadModel[] = {0xAD};//, 0xB5, 0xB9};

#define CMD_LEN_RECORD                5
#define RTN_LEN_RECORD                9
// Read Record
// Send [AF], [Index_H], [Index_L], [ChkSum]
// Receive [Data1], [Data2], [Data3], [Data4], [Data5], [Data6], [Data7], [ChkSum HI],[ChkSum LO]
unsigned char cmdReadRecord[] = {0xAF};//, Index_HI, Index_LO, CHK_HI, CHK_LO};
// Read Year

// Read Record

#define CMD_LEN_FUN3                (7-1)
#define RTN_LEN_FUN3                (2+8+2)
// CMD : [A8] --> HMD Protocol Command
// FUN : [03] --> Read Descriptor Type --> Record
// DescriptorType : [01] --> Descriptor Type 01 Record
// FUN 3
// Send [A8], [03], [DescriptorType], [IndexH], [IndexL], [ChkSum]
// Receive = [A8], [03], [Data1], [Data2], ... [Data8], [ChkSum HI], [ChkSum LO]

// Meter Status Field
// Data1[7:1] --> Year
// Data1[0] Data2[7:5] --> Month
// Data2[4:0] --> Day
// Data3[7:3] --> Hour
// Data3[2:0]  Data4[7:5] --> Minute
// Data4[4:3] --> Second
// Data4[2:0] Data5[7:4] --> Voltage
// Data5[3:0] Data6[7:6] --> Temperature


// Condition Field
// Data6[5:2] --> Code
// Data6[1:0] Data7[7] --> EventBG
// Data7[6] --> MaskRec
// Data7[5:2] --> Pid


// Result Field
// Data7[1:0] Data8[7:0] --> Glucose Value

// EventBG :
// IF Event Type = 0, EventBG means (0 : AC, 1 : PC, 2 : QCL, 3 : QCH)
// IF Event Type = 1~255, EventBG means (0 : C, 1 : V, 2 : A, 3 : N)

// Glucose Value : (Range : 0~999), (unit is 1 mg/dl)





//
@implementation Hmd



- (id)init
{
    if (self = [super init]) {
        _hmdProductYear = 0;
        _hmdModel = 0;
    }
    return self;
}

+ (Hmd *)sharedInstance
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


#pragma mark - HMD COMMAND

- (void)HmdCommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    UInt8 HMDReturnLength = 0;
    Byte cmdBuffer[8] = {0};
    
    UInt8 cmdCheckSum = 0;
    
    switch (cmdMethod) {
            
        case METHOD_INIT:
            cmdLength = CMD_LEN_INIT;
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            HMDReturnLength = RTN_LEN_INIT;
            
            cmdBuffer[0] = CMD_INIT;
            break;
            
        case METHOD_4:
            // Init EX
            cmdLength = CMD_LEN_INIT;
            cmdTypeId = (currentMeter<<4) + METHOD_4;
            HMDReturnLength = RTN_LEN_INIT_EX;
            cmdBuffer[0] = CMD_INIT_EX;
            break;
            
        case METHOD_ACK:
            // Meter ON
            cmdLength = CMD_LEN_GENERAL;
            cmdTypeId = (currentMeter<<4) + METHOD_ACK;
            HMDReturnLength = RTN_LEN_GENERAL;
            
            cmdBuffer[0] = CMD_METER_ON;
            cmdBuffer[1] = 0xA5;
            cmdBuffer[2] = 0xA9;
            break;

        case METHOD_END:
            // Meter OFF
            cmdLength = CMD_LEN_GENERAL;
            cmdTypeId = (currentMeter<<4) + METHOD_END;
            HMDReturnLength = RTN_LEN_GENERAL;
            
            cmdBuffer[0] = CMD_METER_OFF;
            cmdBuffer[1] = 0xA5;
            cmdBuffer[2] = 0xA9;
            break;
            
        case METHOD_DATE: // Get RTC
            cmdLength = CMD_LEN_GENERAL;
            cmdTypeId = (currentMeter<<4) + METHOD_DATE;
            HMDReturnLength = RTN_LEN_RTC;
            
            
            cmdBuffer[0] = CMD_RTC;
            cmdBuffer[1] = 0xA5;
            cmdBuffer[2] = 0xA9;
            break;
            
            
        case METHOD_NROFRECORD: // Get Number Of Record
            cmdLength = CMD_LEN_GENERAL;
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            HMDReturnLength = RTN_LEN_NUMBER;
            
            cmdBuffer[0] = CMD_REC_NR;
            cmdBuffer[1] = 0xA5;
            cmdBuffer[2] = 0xA9;
            break;

            



            
        case METHOD_MODEL: // Query Model
            cmdLength = CMD_LEN_GENERAL;
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            HMDReturnLength = RTN_LEN_MODEL;
            
            cmdBuffer[0] = CMD_MODEL;
            cmdBuffer[1] = 0xB5;
            cmdBuffer[2] = 0xB9;
            break;
            
        case METHOD_TIME: // Product Year
            cmdLength = CMD_LEN_GENERAL;
            cmdTypeId = (currentMeter<<4) + METHOD_TIME;
            HMDReturnLength = RTN_LEN_PYEAR;
            
            cmdBuffer[0] = CMD_PYEAR;
            cmdBuffer[1] = 0xB5;
            cmdBuffer[2] = 0xB9;
            break;
  
            
        case METHOD_SN: // FUN 1, Descriptor Header
            cmdLength = CMD_LEN_FUN1;
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            HMDReturnLength = RTN_LEN_FUN1;
            
            cmdBuffer[0] = CMD_HMD_PROTOCOL;
            cmdBuffer[1] = CMD_FUN1_DES_HD; // Fun ID
            
            for (int i = 0; i<cmdLength - 1; i++) {
                cmdCheckSum += cmdBuffer[i];
            }
            
            cmdBuffer[cmdLength - 1] = cmdCheckSum;
#ifdef DEBUG_LIB
            DLog(@"FUN 1 DEBUG %02X", cmdCheckSum);
#endif
            break;
            
        
            
        case METHOD_VERSION: // FUN 2, Record Descriptor
            cmdLength = CMD_LEN_FUN2;
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            HMDReturnLength = RTN_LEN_FUN2;
            
            cmdBuffer[0] = CMD_HMD_PROTOCOL;
            cmdBuffer[1] = CMD_FUN2_REC_DES; // Fun ID
            cmdBuffer[2] = CMD_DES_TYPE_BG;
            
            for (int i = 0; i<cmdLength - 1; i++) {
                cmdCheckSum += cmdBuffer[i];
            }
        
            cmdBuffer[cmdLength - 1] = cmdCheckSum;
#ifdef DEBUG_LIB
            DLog(@"FUN 2 DEBUG %02X", cmdCheckSum);
#endif
            break;
            

            
            
        default:
            break;
    }
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:HMDReturnLength mcuBufferOffSetAt:0];
    
    
 //   [[H2BleCentralController sharedInstance] H2HmdBLEWriteTask:cmdBuffer withLength:cmdLength];
}


- (void)HmdReadRecord:(UInt16)nIndex
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = CMD_LEN_RECORD -1;
    UInt16 cmdTypeId = (currentMeter<<4) + METHOD_RECORD;
    UInt8 HMDReturnLength = RTN_LEN_RECORD;
    
    Byte cmdBuffer[8] = {0};
    unsigned char tmpArray[2] = {0};
    
    UInt8 cmdCheckSum = 0;
    

    cmdBuffer[0] = CMD_RECORD;  // Command ID
    
    memcpy(tmpArray, &nIndex, 2);
    cmdBuffer[1] = tmpArray[1];
    cmdBuffer[2] = tmpArray[0];
    
    for (int i = 0; i<cmdLength - 1; i++) {
        cmdCheckSum += cmdBuffer[i];
    }
//    memcpy(tmpArray, &cmdCheckSum, 2);
    
//    cmdBuffer[cmdLength - 2] = tmpArray[1];
//    cmdBuffer[cmdLength - 1] = tmpArray[0];
    cmdBuffer[cmdLength - 1] = cmdCheckSum;
#ifdef DEBUG_LIB
    DLog(@"RECORD DEBUG %02X", cmdCheckSum);
#endif
    
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType: cmdTypeId returnDataLength:HMDReturnLength mcuBufferOffSetAt:0];
}


// FUN 3
- (void)HmdRecordAck:(UInt16)nIndex
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = CMD_LEN_FUN3;
    UInt16 cmdTypeId = (currentMeter<<4) + METHOD_ACK_RECORD;
    UInt8 HMDReturnLength = RTN_LEN_FUN3;
    
    Byte cmdBuffer[8] = {0};
    unsigned char tmpArray[2] = {0};
    
    UInt8 cmdCheckSum = 0;
    
    
    cmdBuffer[0] = CMD_HMD_PROTOCOL;  // Command Protocol
    cmdBuffer[1] = CMD_FUN3_DES_TYPE;  // Command Descriptor TYPE
    cmdBuffer[2] = CMD_DES_TYPE_BG;  // Command TYPE_BG
    
    memcpy(tmpArray, &nIndex, 2);
    cmdBuffer[3] = tmpArray[1];
    cmdBuffer[4] = tmpArray[0];
    
    for (int i = 0; i<cmdLength - 2; i++) {
        cmdCheckSum += cmdBuffer[i];
    }
    
#ifdef DEBUG_LIB
    DLog(@"FUN 3 DEBUG %02X", cmdCheckSum);
#endif
    
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType: cmdTypeId returnDataLength:HMDReturnLength mcuBufferOffSetAt:0];
}

#pragma mark - HMD PARSER 



- (NSString *)HmdModelVerSerialNrParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(HMD_BUFFER_LONG_LEN);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    

    // Number Of Total Record
    // Send cmd AE
    // Receive : [Data_H], [Data_L], [5A], [AA]
    // Example : Total Record No : 291 (0123h)
    // Send AE, A5, A9
    // Receive : 01, 23, 5A, AA
    UInt16 NrOfRecord = 0;
    UInt16 NrOfRecordLO = 0;
    
    NrOfRecord = recordData[0];
    NrOfRecordLO = recordData[1];
    NrOfRecord = (NrOfRecord << 8 ) + NrOfRecordLO;
    
    
    

    // Read Production Year
    // Send cmd AC, B5, B9
    // Receive :[Data], [5C], [BB]
    // Example(Hex): Read Product Year(1 byte(0~99) (Real Product Year is 2000 + [Data]), Product Year : 2015 ÷ 15 (0Eh)
    // Send : AC, B5, B9
    // Receive : 0E, 5C, BB
    UInt16 ProductYear = 0;
    ProductYear = recordData[0];
    
    
    
    // Read Model Number
    // Send cmd AD
    // Send : [AD], [B5], [B9]
    // Receive : [Data], [5C], [BB]
    // Example(Hex) : Read Model No (1 byte(0~255), Model No : 135 (87h)
    // Send: AD, B5, B9
    // Receive : 87, 5C, BB
//    UInt16 ModelNr = recordData[0];
    
    
    UInt8 tmpBuffer[32] = {0};
    NSString *bionimeModeVersionSerialNumber;


    bionimeModeVersionSerialNumber = [NSString stringWithUTF8String:(const char *)tmpBuffer];
#ifdef DEBUG_HMD
    DLog(@"DEBUG_BIONIME -- MODEL VER SN -- %@", bionimeModeVersionSerialNumber);
#endif
    // FUNC 2
    return bionimeModeVersionSerialNumber;
}



#pragma mark - CURRENT DATE TIME (RTC)
- (NSString *)HmdCurrentDateTimeParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(HMD_BUFFER_SHORT_LEN);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    NSString *hmdTimeString;
    UInt16 hmdYear = recordData[1] + 2000;
    UInt8 hmdMon = recordData[2];
    UInt8 hmdDay = recordData[3];
    
    UInt8 hmdHour = recordData[4];
    UInt8 hmdMin = recordData[5];
    
    
    // Receive [B1][Year],[Month],[Date],[Hour],[Minute],[Second],[ChkSum HI],[ChkSum LO]
    // or Receive [A2][Year],[Month],[Date],[Hour],[Minute],[Second],[ChkSum HI],[ChkSum LO]
    // Example(Hex):2015(2000 + [Year], August, 08, PM:05:08:39
    // A1, A5, A9
    // B1, 0F, 08, 08, 11, 08, 27, 01, 10
    // or A2, 0F, 08, 08, 11, 08, 27, 01, 10
    
    
    
    
    hmdTimeString = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",hmdYear, hmdMon, hmdDay, hmdHour, hmdMin];
#ifdef DEBUG_BIONIME
    DLog(@"DEBUG_BIONIME -- CURRENT TIME -- %@", hmdTimeString);
#endif
    return hmdTimeString;
}

#define MASK_MON            0xF0
#define MASK_VAL_HI         0x03
#define MASK_VAL_LO         0xFF
#define MASK_DAY            0xF8
#define MASK_EVENT          0x0C

#define MASK_HOR_HI         0x07
#define MASK_HOR_LO         0xC0
#define MASK_MIN            0x3F

#define MASK_YEAR_OFFSET        0x0F

- (H2BgRecord *)HmdDateTimeValueParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(HMD_BUFFER_SHORT_LEN);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    
    
    // Receive [Data1], [Data2], [Data3], [Data4], [Data5], [Data6], [Data7], [ChkSum HI],[ChkSum LO]
    // Data1(7:4) : Month : Range 1~12
    // Data1(1:0), Data2(7:0) Glucose Value : Range : 0~999, unit : mg/dL
    // Data3(7:3) : Day : Range : 1~31
    // Data3(2:0) Data4(7:6): Hour : Range : 0~23
    // Data4(5:0) : Minute : Range : 0~59
    // Data5(3:0) : Offset Year : Range : 0~15
    //    Formula : Year = 2000 + Product Year + Offset Year
    //    Example : Offset Year = 1, Product Year = 15, ==> Year = 2000 + 15 + 1 = 2016
    // Data5(7:4) : Code : Range : 0~15
    // Data6(6:0) : Voltage : Range : 0~127
    //    Formula : Battery voltage = (Voltage * 0.01) + 2.23
    //    Example : Voltage = 127, Battery voltage = (127 * 0.01) + 2.23 = 3.50(V)
    // Data6(7), Data1(3:2) : Range : 0~3
    // Event(2:0) : (0: AC, 1: PC, 2:QC, 3:QCH)
    // Example : Event = 1, PC(飯後)
    // Data7(5:0) : Temperature : Range : 0~255
    // Formula : Meter Temperature = 0.8 * Temperature
    // Example : Temperature = 32, Meter Temperature = 0.8 * 32 = 26(℃)
    // Data7(7:6) : Resv : nuse.
    
    
    UInt16 bmYear = 0;
    UInt8 bmMon = 0;
    UInt8 bmDay = 0;
    
    UInt8 bmHour = 0;
    UInt8 bmHourLO = 0;
    UInt8 bmMin = 0;
    
    // Data1(7:4) : Month : Range 1~12
    bmMon = recordData[0] & MASK_MON;
    bmMon = bmMon >> 4;
    
    // Data3(7:3) : Day : Range : 1~31
    bmDay = recordData[2] & MASK_DAY;
    bmDay = bmDay >> 3;
    
    // Data3(2:0) Data4(7:6): Hour : Range : 0~23
    bmHour = recordData[2] & MASK_HOR_HI;
    bmHourLO = recordData[3] & MASK_HOR_LO;
    bmHour = (bmHour << 2) + (bmHourLO >> 6);
    
    // Data4(5:0) : Minute : Range : 0~59
    bmMin = recordData[3] & MASK_MIN;
    

    UInt16 value = 0;
    UInt8 valueLO = 0;
    
    // Data1(1:0), Data2(7:0) Glucose Value : Range : 0~999, unit : mg/dL
    value = recordData[0] & MASK_VAL_HI;
    valueLO = recordData[1] & MASK_VAL_LO;
    value = (value << 8) + valueLO;
    
    UInt8 event = 0;

    // Data6(7), Data1(3:2) : Range : 0~3
    // Event(2:0) : (0: AC, 1: PC, 2:QC, 3:QCH)
    event = recordData[0] & MASK_EVENT;
    event = event >> 2;

    
    
    
    
    
    // Data5(3:0) : Offset Year : Range : 0~15
    //    Formula : Year = 2000 + Product Year + Offset Year
    //    Example : Offset Year = 1, Product Year = 15, ==> Year = 2000 + 15 + 1 = 2016
    bmYear = (recordData[4] & MASK_YEAR_OFFSET) + _hmdProductYear + 2000;
    
    
    H2BgRecord *hmdRecord;
    hmdRecord = [[H2BgRecord alloc] init];
    
    
    switch (event) {
        case 0:
            hmdRecord.bgMealFlag = @"B";
            break;
        case 1:
            hmdRecord.bgMealFlag = @"A";
            break;
            
        default:
            hmdRecord.bgMealFlag = @"C";
            break;
    }
    
    
    /*******************************************************************
     * 1:0
     * Blood glucose value (High bits, Bit 9:8).
     * Ex: Glucose Value = (DA_4 & 0x03) << 8 + DA_5
     */
    if (value > SMG_MG_MAX) {
        value = SMG_MG_MAX;
    }
    
    hmdRecord.bgValue_mg = value;
    hmdRecord.bgValue_mmol = 0.0;
//    hmdRecord.smRecordUnit = @"mg/dL";
    hmdRecord.bgUnit = @"N";
    
    
    hmdRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",bmYear, bmMon, bmDay, bmHour, bmMin];
#ifdef DEBUG_HMD
    DLog(@"DEBUG_HMD record infomation");
    DLog(@"DEBUG_HMD date time is %@", hmdRecord.bgDateTime);
#endif
    
    if (![hmdRecord.bgMealFlag isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:hmdRecord.bgDateTime]) {
            hmdRecord.bgMealFlag = @"C";
        }
    }
    
    return hmdRecord;
}



- (NSString *)HmdModelParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(HMD_BUFFER_SHORT_LEN);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 srcModel = srcData[0];
#ifdef DEBUG_HMD
    for (int i = 0; i<length; i++) {
        DLog(@" MODEL index %d and Data %02X", i,  srcData[i]);
    }
#endif
    NSString *model = [[NSString alloc] initWithFormat:@"%03d",srcModel];
    return model;
}

- (NSString *)HmdSerialNrParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(HMD_BUFFER_LONG_LEN);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt8 tmpBuffer[5] = {0};
    UInt8 srcTmp;
    
    srcTmp = srcData[41] & 0xF0;
    srcTmp = srcTmp >> 4;
    if (srcTmp > 9) {
        srcTmp = (srcTmp-10) + 'A';
    }else{
        srcTmp = srcTmp + '0';
    }
    tmpBuffer[0] = srcTmp;
    
    srcTmp = srcData[41] & 0x0F;
    if (srcTmp > 9) {
        srcTmp = (srcTmp-10) + 'A';
    }else{
        srcTmp = srcTmp + '0';
    }
    tmpBuffer[1] = srcTmp;
    
    srcTmp = srcData[42] & 0xF0;
    srcTmp = srcTmp >> 4;
    if (srcTmp > 9) {
        srcTmp = (srcTmp-10) + 'A';
    }else{
        srcTmp = srcTmp + '0';
    }
    tmpBuffer[2] = srcTmp;
    
    srcTmp = srcData[42] & 0x0F;
    if (srcTmp > 9) {
        srcTmp = (srcTmp-10) + 'A';
    }else{
        srcTmp = srcTmp + '0';
    }
    tmpBuffer[3] = srcTmp;
    
    NSString *tmpString = [NSString stringWithUTF8String:(const char *)tmpBuffer];
    UInt8 snNumberHi = srcData[43];
    UInt8 snNumberMid = srcData[44];
    UInt8 snNumberLo = srcData[45];
    
    UInt32 snNumber = (snNumberHi << 16) + (snNumberMid << 8) + snNumberLo;
    
#ifdef DEBUG_HMD
    for (int i = 0; i<length; i++) {
        DLog(@" SERIAL NUMBER index %d and Data %02X", i,  srcData[i]);
    }
#endif
    //NSString *sn = [[NSString alloc] initWithFormat:@"%@%06d", tmpString, (UInt32)snNumber];
    NSString *sn = [[NSString alloc] initWithFormat:@"%@%06d", tmpString, (unsigned int)snNumber];
    
    return sn;
}

- (UInt16)HmdTotalRecordNumberParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(HMD_BUFFER_LONG_LEN);
    memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
#ifdef DEBUG_HMD
    for (int i = 0; i<length; i++) {
        DLog(@" TOTAL RECORD index %d and Data %02X", i,  srcData[i]);
    }
#endif
    UInt8 recordNumberLo = srcData[10];
    UInt16 totalRecord = srcData[9];
    totalRecord = (totalRecord << 8) + recordNumberLo;
    return totalRecord;
}


@end
