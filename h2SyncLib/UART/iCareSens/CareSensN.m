//
//  CareSensN.m
//  h2SyncLib
//
//  Created by h2Sync on 2014/1/6.
//
//
#import "H2AudioFacade.h"

#import "CareSensN.h"
#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"

@implementation CareSensN
{
}


- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

+ (CareSensN *)sharedInstance
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


unsigned char careSenseNPlusCmdInit[] = {
    0x80
};
unsigned char careSenseNCmdBrand[] = {
    0x8B, 0x11, 0x20, 0x13, 0x24, 0x10, 0x2A
};
unsigned char careSenseNCmdModel[] = {
    0x8B, 0x11, 0x20, 0x13, 0x24, 0x10, 0x2A
};

unsigned char careSenseNCmdSerialNumber[] = {
    0x8B, 0x11, 0x20, 0x18, 0x26, 0x10, 0x22
};
unsigned char careSenseNCmdDate[] = {
//    0x8B, 0x11, 0x20, 0x18, 0x26, 0x10, 0x22
    0x8B, 0x11, 0x20, 0x18, 0x26, 0x10, 0x22
};

unsigned char careSenseNCmdRecord[] = {
//    0x8B, 0x1E, 0x22, 0x11, 0x28, 0x10, 0x28
//    0x8B, 0x1E, 0x22, 0x10, 0x28, 0x10, 0x28
//    0x8B, 0x1E, 0x22, 0x11, 0x20, 0x10, 0x28
    
//    0x8B, 0x1E, 0x22, 0x13, 0x20, 0x10, 0x28      // 0
//    0x8B, 0x1E, 0x22, 0x12, 0x28, 0x10, 0x28      // 1
//    0x8B, 0x1E, 0x22, 0x12, 0x20, 0x10, 0x28        // 2
//    0x8B, 0x1E, 0x22, 0x11, 0x28, 0x10, 0x28        // 3
//    0x8B, 0x1E, 0x22, 0x11, 0x20, 0x10, 0x28        // 4
//    0x8B, 0x1E, 0x22, 0x10, 0x28, 0x10, 0x28        // 5
//    0x8B, 0x1E, 0x22, 0x10, 0x20, 0x10, 0x28        // 6
    
    
    0x8B, 0x1E, 0x22, 0x13, 0x20, 0x10, 0x28      // 0
};


#pragma mark -
#pragma mark CARESENSE N COMMAND

- (void)CareSensCommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    UInt8 carSensReturnLength = 0;
    Byte cmdBuffer[48] = {0};
    
    switch (cmdMethod) {
        case METHOD_INIT:
            cmdLength = sizeof(careSenseNPlusCmdInit);
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            memcpy(cmdBuffer, careSenseNPlusCmdInit, cmdLength);
            carSensReturnLength = 3;
            break;
            
        case METHOD_BRAND:
            cmdLength = sizeof(careSenseNCmdBrand);
            cmdTypeId = (currentMeter<<4) + METHOD_BRAND;
            memcpy(cmdBuffer, careSenseNCmdBrand, cmdLength);
            carSensReturnLength = 30;
            break;
            
        case METHOD_MODEL:
            cmdLength = sizeof(careSenseNCmdModel);
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            memcpy(cmdBuffer, careSenseNCmdModel, cmdLength);
            carSensReturnLength = 30;
            break;
            
        case METHOD_SN:
            cmdLength = sizeof(careSenseNCmdSerialNumber);
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            memcpy(cmdBuffer, careSenseNCmdSerialNumber, cmdLength);
            carSensReturnLength = 6;
            break;
            
            
            
        case METHOD_DATE:
            cmdLength = sizeof(careSenseNCmdDate);
            cmdTypeId = (currentMeter<<4) + METHOD_DATE;
            memcpy(cmdBuffer, careSenseNCmdDate, cmdLength);
            carSensReturnLength = 6;
            break;

        default:
            break;
    }
//    [H2AudioAndBleCommand sharedInstance].didSendMeterCmd = YES;
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:carSensReturnLength mcuBufferOffSetAt:0];
}




- (void)CareSensReadRecord:(UInt16)nIndex
{
    // first Index is totalRecord, last Index is 1
    
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = sizeof(careSenseNCmdRecord);
    UInt16 cmdTypeId = (currentMeter<<4) + METHOD_RECORD;
    UInt8 cmdNumberOfDataWantReturn = 24;
    
    unsigned char tmpCommand[cmdLength];
    memcpy(tmpCommand, careSenseNCmdRecord, cmdLength);
    
#ifdef DEBUG_CARESENS
    DLog(@"DEBUG_CARESENS the Index 0 issue %03X", nIndex);
#endif
    UInt8 tmp = 0;
    tmp = (nIndex - 1) >> 5;
    switch (tmp) {
        case 0:
            careSenseNCmdRecord[2] = 0x22;
            tmpCommand[2] = 0x22;
            break;
        case 1:
            careSenseNCmdRecord[2] = 0x23;
            tmpCommand[2] = 0x23;
            break;
        case 2:
            careSenseNCmdRecord[2] = 0x24;
            tmpCommand[2] = 0x24;
            break;
        case 3:
            careSenseNCmdRecord[2] = 0x25;
            tmpCommand[2] = 0x25;
            break;
        case 4:
            careSenseNCmdRecord[2] = 0x28;
            tmpCommand[2] = 0x28;
            break;
        case 5:
            careSenseNCmdRecord[2] = 0x29;
            tmpCommand[2] = 0x29;
            break;
        case 6:
            careSenseNCmdRecord[2] = 0x2C;
            tmpCommand[2] = 0x2C;
            break;
        case 7:
            careSenseNCmdRecord[2] = 0x2D;
            tmpCommand[2] = 0x2D;
            break;
            
        default:
            break;
    }
#ifdef DEBUG_CARESENS
    DLog(@"DEBUG_CARESENS the Index X issue %d, %02X, %02X", nIndex, tmpCommand[2], careSenseNCmdRecord[2]);
#endif
    
    
    tmp = (nIndex - 1) >> 1;
    tmp &= 0x0F;
    careSenseNCmdRecord[3] &= 0xF0;
    tmpCommand[3] &= 0xF0;
    careSenseNCmdRecord[3] |= tmp;
    tmpCommand[3] |= tmp;
#ifdef DEBUG_CARESENS
    DLog(@"DEBUG_CARESENS the Index 1 issue %d, %02X, %02X", nIndex, tmpCommand[3], careSenseNCmdRecord[3]);
#endif
    tmp = ((nIndex - 1) & 0x01) << 3;
    
    tmp &= 0x0F;
    
    careSenseNCmdRecord[4] &= 0xF0;
    tmpCommand[4] &= 0xF0;
    careSenseNCmdRecord[4] |= tmp;
    tmpCommand[4] |= tmp;
#ifdef DEBUG_CARESENS
    DLog(@"DEBUG_CARESENS the Index 2 issue %d, %02X, %02X", nIndex, tmpCommand[4], careSenseNCmdRecord[4]);
#endif
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:tmpCommand withCmdLength:cmdLength cmdType: cmdTypeId returnDataLength:cmdNumberOfDataWantReturn mcuBufferOffSetAt:0];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// Parser
#define FLAG_MEAL       0x02

- (H2BgRecord *)careSenseNDateTimeValueParser//:(UInt16)index
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    UInt16 dateTimeValue[8]; // YY MM DD hh mm ss value Remark
    UInt16 value = 0;
    
    H2BgRecord *careSenseNRecord;
    careSenseNRecord = [[H2BgRecord alloc] init];
    
    careSenseNRecord.bgValue_mg = 0;
    careSenseNRecord.bgValue_mmol = 0.0;
    if (length >= 24) {
 
        for (int i = 0; i < 8; i++) {
            dateTimeValue[i] = (recordData[3*i+1] & 0x0F) * 16 + (recordData[3*i+2] & 0x0F);
        }

    
        careSenseNRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",dateTimeValue[0] + 2000, dateTimeValue[1], dateTimeValue[2], dateTimeValue[3], dateTimeValue[4]];
#ifdef DEBUG_CARESENS
        DLog(@"DEBUG_CARESENS record infomation");
        DLog(@"DEBUG_CARESENS date time is %@", careSenseNRecord.smRecordDateTime);
#endif

        
        if (recordData[22] & FLAG_MEAL) {
            careSenseNRecord.bgMealFlag = @"A";
            //careSenseNRecord.smRecordValue_mg = dateTimeValue[6] + ((recordData[23] & 0x08)>>3)*256 - 16;
            value = dateTimeValue[6] + ((recordData[23] & 0x08)>>3)*256 - 16;
            
        }else{
            careSenseNRecord.bgMealFlag = @"B";
//            careSenseNRecord.smRecordValue_mg = dateTimeValue[6];
            value = dateTimeValue[6];
            if (recordData[23] & 0x03) {
                //careSenseNRecord.smRecordValue_mg += + (recordData[23] & 0x03)*256;
//                careSenseNRecord.smRecordValue_mg += (recordData[23] & 0x03)*256;
                value += (recordData[23] & 0x03)*256;
            }
        }
//        careSenseNRecord.smRecordValue = dateTimeValue[6];
#ifdef DEBUG_CARESENS
        DLog(@"DEBUG_CARESENS the value is %03d", careSenseNRecord.smRecordValue_mg);
#endif
        careSenseNRecord.bgValue_mg = value;
        careSenseNRecord.bgUnit = @"N";
        careSenseNRecord.bgValue_mmol = 0.0;

    }
    if (![careSenseNRecord.bgMealFlag isEqualToString:@"C"]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:careSenseNRecord.bgDateTime]) {
            careSenseNRecord.bgMealFlag = @"C";
        }
    }
    return careSenseNRecord;
}


- (H2MeterSystemInfo *)careSenseNSystemInfoParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *recordData;
    recordData = (Byte *)malloc(256);
    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    H2MeterSystemInfo *careSensSystemInfo;
    careSensSystemInfo = [[H2MeterSystemInfo alloc] init];
    
    UInt16 numberOfRecord = 0;
#ifdef DEBUG_CARESENS
    for (int i = 0; i < length; i++) {
        DLog(@"DEBUG_CARESENS record info %02d -> %02X", i, recordData[i]);
    }
    DLog(@"DEBUG_CARESENS record info %02X, %02X -> %02X, %02X", recordData[1], recordData[1] & 0x0F, recordData[2], recordData[2] & 0x0F);
#endif
    if (length >= 3) {
        numberOfRecord = (recordData[1] & 0x0F) * 16 + (recordData[2] & 0x0F);
#ifdef DEBUG_CARESENS
        DLog(@"DEBUG_CARESENS the number of reocrd is %d", numberOfRecord);
#endif
    }

    
    return careSensSystemInfo;
}




@end


