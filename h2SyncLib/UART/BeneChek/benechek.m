//
//  benechek.m
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/12.
//
//

#define BC_CMDTYPE_NUMBER               0x41
#define BC_CMDTYPE_RECORD               0x42
#define BC_CMDTYPE_MODELNAME            0x48
#define BC_CMDTYPE_FUNCTIONCODE         0x49

#import "H2AudioFacade.h"
#import "benechek.h"
#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"

@interface benechek()
{
}
@end


@implementation benechek
- (id)init
{
    if (self = [super init]) {
        ;
    }
    return self;
}

+ (benechek *)sharedInstance
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

unsigned char qNumberOfRecord[] =
{0x24, 0x50, 0x43, 0x4C,
    0x40, 0x00,
    0x00, 0x00,
    0x00, 0x00,
    0x00
};
unsigned char qValueOfRecord[] =
{0x24, 0x50, 0x43, 0x4C,
    0x41, 0x00,
    0x00, 0x00,
    0x04, 0x00,
    0x00, 0x00,
    0x00, 0x00,
    0x00
};
unsigned char qModelName[] =
{'$', 'P', 'C', 'L',
    0x31, 0x00,
    0x00, 0x00,
    0x00, 0x00,
    0x00
};
unsigned char qFunctionCode[] =
{'$', 'P', 'C', 'L',
    0x30, 0x00,
    0x00, 0x00,
    0x00, 0x00,
    0x00
};

- (void)BeneChekCommandGeneral:(UInt16)cmdMethod
{
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    UInt8 index = 0;
    UInt8 sum = 0;
    
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    
    switch (cmdMethod) {

            
        case METHOD_MODEL:
            cmdLength = sizeof(qModelName);
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            memcpy(cmdBuffer, qModelName, cmdLength);
            break;
            
 
        case METHOD_VERSION:
            cmdLength = sizeof(qFunctionCode);
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            memcpy(cmdBuffer, qFunctionCode, cmdLength);
            break;
        case METHOD_NROFRECORD:
            cmdLength = sizeof(qNumberOfRecord);
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            memcpy(cmdBuffer, qNumberOfRecord, cmdLength);
            break;
            
        default:
            break;
    }
    for (index = 1; index < cmdLength - 1; index++) {
        sum += cmdBuffer[index];
    }
    cmdBuffer[cmdLength - 1] = sum;
    
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}

- (void)BeneChekQueryGluValue:(UInt16)indexOfRecord
{
    UInt16 beneChekCmdType = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol << 4) + METHOD_RECORD;
    UInt8 index = 0;
    UInt8 sum = 0;
    UInt16 indexInRecord = indexOfRecord + 1;
    
    unsigned char cmdTmp[sizeof(qValueOfRecord)];
    memcpy(cmdTmp, qValueOfRecord, sizeof(cmdTmp));
    
    for (index=1; index<sizeof(qValueOfRecord)-1; index++) {
        if (index == BC_START_INDEX) {
            memcpy(&cmdTmp[index], &indexInRecord, 2);
        }
        if (index == BC_END_INDEX) {
            memcpy(&cmdTmp[index], &indexInRecord, 2);
        }
        
        sum += cmdTmp[index];
    }
    cmdTmp[sizeof(qValueOfRecord)-1] = sum;

    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdTmp withCmdLength:sizeof(cmdTmp) cmdType:beneChekCmdType
                   returnDataLength:0 mcuBufferOffSetAt:0];
    
}





#define BC_ID           2
#define BC_YEAR         4
#define BC_MONTH        5
#define BC_DAY          6

#define BC_HOUR         7
#define BC_MINUTE       8
#define BC_VALUE        9
#define BC_OFFSET       (8)
- (NSString *)beneChekModelParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *modelSrc;
    modelSrc = (Byte *)malloc(256);
    memcpy(modelSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 modelLength;
    char modelTmp[24] = {0};
    

    
    memcpy(&modelLength, &modelSrc[BC_OFFSET], 2);
    memcpy(modelTmp, &modelSrc[BC_OFFSET+2], modelLength);
#ifdef DEBUG_BENECHEK
    UInt8 index = 0;
    DLog(@"DEBUG_BENECHEK the model length is %02X", modelLength);
    for (index=0; index<modelLength; index++) {
        DLog(@"DEBUG_BENECHEK the model index = %02d, value = %02X", index,modelTmp[index]);
    }
#endif
    for (int i = 0; i<modelLength; i++) {
        if (modelTmp[i] == ' ') {
            modelTmp[i] = '\0';
        }
    }
    NSString *stringModel = [NSString stringWithUTF8String:(const char *)modelTmp];

    return stringModel;
    
}



- (H2BgRecord *)beneChekDateTimeParser:(BOOL)unitFlag
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *dataSrc;
    dataSrc = (Byte *)malloc(256);
    memcpy(dataSrc, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2BgRecord *bcRecord;
    bcRecord = [[H2BgRecord alloc] init];

    
    UInt16 bcIndex;
    
    UInt16 bcYear;
    UInt8 bcMonth;
    UInt8 bcDay;
    
    UInt8 bcHour;
    UInt8 bcMinute;
    
    UInt16 bcValue;
    
    
#ifdef DEBUG_BENECHEK
    UInt16 idx = 0;
    for (idx=0; idx<length; idx++) {
        DLog(@"DEBUG_BENECHEK the benechek idx %02d val %02X", idx, dataSrc[idx]);
    }
#endif
    memcpy(&bcIndex, &dataSrc[BC_OFFSET + BC_ID], 2);
    
    bcYear = dataSrc[BC_OFFSET + BC_YEAR]+2000;
    bcMonth = dataSrc[BC_OFFSET + BC_MONTH];
    bcDay = dataSrc[BC_OFFSET + BC_DAY];
    
    bcHour = dataSrc[BC_OFFSET + BC_HOUR];
    bcMinute = dataSrc[BC_OFFSET + BC_MINUTE];
    
    memcpy(&bcValue, &dataSrc[BC_OFFSET + BC_VALUE], 2);
    
    bcRecord.bgIndex = bcIndex;
    

    bcRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",bcYear, bcMonth, bcDay, bcHour, bcMinute];

    bcRecord.bgValue_mg = bcValue;
    bcRecord.bgUnit = @"N";
    bcRecord.bgValue_mmol = 0.0;
    
    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bcRecord.bgDateTime]) {
        bcRecord.bgMealFlag = @"C";
    }
    return bcRecord;
}

@end







