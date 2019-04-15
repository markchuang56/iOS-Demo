//
//  AllianceDSA.m
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/8/28.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import "H2AudioFacade.h"
#import "H2DebugHeader.h"

#import "H2Config.h"
#import "H2DataFlow.h"

#import "H2Records.h"
#import "H2Timer.h"
#import "AllianceDSA.h"

@interface AllianceDSA()
{
    UInt8 alliCmdMethod;
    UInt8 alliOpcSel;
    
    UInt16 alliIndex;
    UInt16 alliTotalRecords;
    Byte *valueBuffer;
    UInt16 rdTotal;
    UInt16 rdIndex;
    BOOL dsaUnit;
}

@end

@implementation AllianceDSA

- (id)init
{
    if (self = [super init]) {
        alliCmdMethod = 0;
        alliOpcSel = 0;
        alliIndex = 0;
        alliTotalRecords = 0;
        valueBuffer = (Byte *)malloc(32);
        dsaUnit = NO;
    }
    return self;
}

#pragma mark - ========== ALLIANCE DATA UPDATE ============
- (void)allianceValueUpdate
{
    UInt8 cmdSel = 0;
    memcpy(valueBuffer, [H2AudioAndBleSync sharedInstance].dataBuffer , [H2AudioAndBleSync sharedInstance].dataLength);
    
    //for (int i = 0; i<[H2AudioAndBleSync sharedInstance].dataLength; i++) {
    //    DLog(@"BLE DATA addr = %d data = %02X\n", i, [H2AudioAndBleSync sharedInstance].dataBuffer[i]);
    //}
    switch (alliCmdMethod) {
        case METHOD_INIT:
            [self devParser];
            cmdSel = METHOD_VERSION;
            dsaUnit = NO;
            break;
            
        case METHOD_VERSION:
            [self versionParser];
            cmdSel = METHOD_SN;
            break;
            
        case METHOD_SN:
            [self serialNumberParser];
            cmdSel = METHOD_UNIT;
            break;
            
        case METHOD_UNIT:
            [self unitParser];
            cmdSel = METHOD_DATE;
            break;
            
        case METHOD_DATE:
            [self dateTimeParser];
            cmdSel = METHOD_NROFRECORD;
            break;
            
        case METHOD_NROFRECORD:
            [self recordQtyParser];
            return;
            
        case METHOD_RECORD:
            if ([self recordParser]) {
                return;
            }
            
            cmdSel = METHOD_RECORD;
            break;
            
        default:
            break;
    }
    [self allianceCmdFlow:cmdSel];
}

- (void)devParser
{
    //NSLog(@"=========  DS - A DEVICE ==========");
    unsigned char dev[8] = {0};
    memcpy(dev, &valueBuffer[2], DALEN_DEV-3);
    NSString *devString = [NSString stringWithUTF8String:(const char *)dev];
    //NSLog(@"DS-A DEV = %@", devString);
}

- (void)versionParser
{
    //NSLog(@"=========  DS - A FW VERSION ==========");
    unsigned char fw[8] = {0};
    memcpy(fw, &valueBuffer[2], DALEN_FW-3);
    NSString *ver = [NSString stringWithUTF8String:(const char *)fw];
    //NSLog(@"DS-A FW = %@", ver);
}

- (void)serialNumberParser
{
    //NSLog(@"=========  DS - A SN ==========");
    unsigned char sn[32] = {0};
    memcpy(sn, &valueBuffer[2], DALEN_SN-3);
    NSString *snString = [NSString stringWithUTF8String:(const char *)sn];
    //NSLog(@"DS-A SN = %@", snString);
    
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [NSString stringWithFormat:@"%@",snString];
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [NSString stringWithFormat:@"%@",snString];
}

- (void)unitParser
{
    //NSLog(@"=========  DS - A UNIT ==========");
    if (valueBuffer[3] != 1) {
        dsaUnit = YES;
    }
}

- (void)dateTimeParser
{
    UInt16 year = valueBuffer[2];
    UInt8 month = valueBuffer[3];
    UInt8 day = valueBuffer[4];
    UInt8 hour = valueBuffer[5];
    UInt8 minute = valueBuffer[6];
    UInt8 second = valueBuffer[7];
/*
    NSLog(@"=========  DS - A DATE TIME ==========");
    NSLog(@"DS - Y %d", year);
    NSLog(@"DS - M %d", month);
    NSLog(@"DS - D %d", day);
    
    NSLog(@"DS - H %d", hour);
    NSLog(@"DS - m %d", minute);
    NSLog(@"DS - S %d", second);
*/
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",  year + 2000, month, day, hour, minute];
}

- (void)recordQtyParser
{
    //NSLog(@"=========  DS - A QTY ==========");
    UInt16 qty = valueBuffer[2];
    qty <<= 8;
    qty += valueBuffer[3];
    //NSLog(@"QTY = %d", qty);
    
    rdTotal = qty;
    rdIndex = 1;
    [H2SyncReport sharedInstance].didSendEquipInformation = YES;
}

- (BOOL)recordParser
{
    BOOL rdStatus = NO;
    if (rdIndex > rdTotal) {
        rdStatus = YES;
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
    }
    
    [H2Records sharedInstance].bgTmpRecord = [self dsaDateTimeValueParser];
    
    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
        if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
            [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
        }
        [H2AudioAndBleSync sharedInstance].recordIndex++;
        rdStatus = NO;
    }else{
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
        [H2AudioAndBleSync sharedInstance].recordIndex = 0;
        rdStatus = YES;
    }
    //NSLog(@"=========  DS - A RECORD ==========");
    return rdStatus;
}

- (H2BgRecord *)dsaDateTimeValueParser
{
    UInt16 year = valueBuffer[RD_OFFSET];
    UInt8 month = valueBuffer[RD_OFFSET+1];
    UInt8 day = valueBuffer[RD_OFFSET+2];
    
    UInt8 hour = valueBuffer[RD_OFFSET+3];
    UInt8 minute = valueBuffer[RD_OFFSET+4];
    
    UInt16 value = valueBuffer[RD_OFFSET+5];
    value <<= 8;
    value += valueBuffer[RD_OFFSET+6];
    
    H2BgRecord *dsaRecord;
    dsaRecord = [[H2BgRecord alloc] init];
    
    dsaRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",year+2000, month, day, hour, minute];
#ifdef DEBUG_FREESTYLE
    //DLog(@"DEBUG_DSA date time is %@", dsaRecord.bgDateTime);
#endif
    
    if (dsaUnit) {
        dsaRecord.bgUnit = BG_UNIT_EX;
        dsaRecord.bgValue_mmol = (float)value/MMOL_COIF;
        dsaRecord.bgValue_mg = 0;
        
    }else{
        dsaRecord.bgUnit = BG_UNIT;
        dsaRecord.bgValue_mg = value;
        dsaRecord.bgValue_mmol = 0.0;
    }
    
    dsaRecord.bgMealFlag = @"N";
    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:dsaRecord.bgDateTime]) {
        dsaRecord.bgMealFlag = @"C";
    }
    return dsaRecord;
}

#pragma mark - ========== ALLIANCE COMMAND FLOW ============
- (void)allianceCmdFlow:(UInt8)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdTypeId = 0;
    UInt8 cmdBuffer[8] = {0};
    UInt8 chkSum = 0;
    UInt8 dataLen = 0;
    UInt16 tmpIdx = 0;
    alliCmdMethod = cmdMethod;
    cmdBuffer[0] = DSA_CMD_ST;
    
    switch (cmdMethod) {
        case METHOD_INIT:
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            cmdBuffer[1] = OPC_DEV;
            dataLen = DALEN_DEV;
            break;
            
        case METHOD_VERSION:
            cmdTypeId = (currentMeter<<4) + METHOD_VERSION;
            cmdBuffer[1] = OPC_FW;
            dataLen = DALEN_FW;
            break;
            
        case METHOD_SN:
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            cmdBuffer[1] = OPC_SN;
            dataLen = DALEN_SN;
            break;
            
        case METHOD_UNIT:
            cmdTypeId = (currentMeter<<4) + METHOD_UNIT;
            cmdBuffer[1] = OPC_UNIT;
            dataLen = DALEN_UNIT;
            break;
            
        case METHOD_DATE:
            cmdTypeId = (currentMeter<<4) + METHOD_DATE;
            cmdBuffer[1] = OPC_DT;
            dataLen = DALEN_DT;
            break;
            
        case METHOD_NROFRECORD:
            cmdTypeId = (currentMeter<<4) + METHOD_NROFRECORD;
            cmdBuffer[1] = OPC_QTY;
            dataLen = DALEN_QTY;
            break;
            
        case METHOD_RECORD:
            cmdTypeId = (currentMeter<<4) + METHOD_RECORD;
            cmdBuffer[1] = OPC_RIDX;
            dataLen = DALEN_RECORD;
            
            if (rdTotal == 0) {
                [[H2Timer sharedInstance] clearCableTimer];
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                //NSLog(@"DS - A , NO RECORD.");
                return;
            }
            
            tmpIdx = rdIndex;
            cmdBuffer[4] = (UInt8)(tmpIdx >> 8);
            cmdBuffer[5] = (UInt8)(tmpIdx & 0xFF);
            rdIndex++;
            break;
            
        default:
            break;
    }
    alliOpcSel = cmdBuffer[1];
    
    for (int i=0; i<DSA_CMD_LEN-1; i++) {
        chkSum += cmdBuffer[i];
    }
    cmdBuffer[DSA_CMD_LEN-1] = chkSum;
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:DSA_CMD_LEN cmdType:cmdTypeId returnDataLength:dataLen mcuBufferOffSetAt:0];
}

+ (AllianceDSA *)sharedInstance
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
