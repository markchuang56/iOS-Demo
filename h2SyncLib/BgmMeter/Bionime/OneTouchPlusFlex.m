//
//  OneTouchPlusFlex.m
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/7/6.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import "H2Config.h"
#import "h2BrandModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "H2BleService.h"
#import "OneTouchPlusFlex.h"

#import "LSOneTouchUltraMini.h"
#import "H2BleTimer.h"
#import "H2BleCentralManager.h"
#import "H2Records.h"
#import "H2LastDateTime.h"
#import "H2DebugHeader.h"

unsigned char flexCmdInit[] =
{ 0x02, 0x02 };
// value = <01020c00 04060100 000003b6 5c>,

unsigned char flexCmdKey[] =
{ 0x02, 0x08 };

unsigned char flexCmdPassword[] = //[20] =
{
    0xD5, 0x62,
    0xAA, 0xC7, 0x10, 0x7E , 0xDC, 0xE2, 0x9E, 0x2E ,
    0x29, 0x0C, 0x8F, 0x42 ,
    0x16, 0xB4
#if 0
    //0x02, 0x02, 0x18, 0x00,
    //0x04, 0x11,
    0x3B, 0x98,
    0x6A, 0xC5, 0x74, 0xF3, 0x87, 0xE7, 0xAA, 0x42,
    0xAF, 0x24, 0x26, 0x59,
    //0x41,
    0x6C, 0xFD//, 0x03, 0xA6, 0x90
//#else
    //0x02, 0x02, 0x18, 0x00,  0x04, 0x11,
    0xEE, 0x9A,
    0x58, 0x08, 0x88, 0x13,  0x3A, 0xD9, 0x38, 0x89,
    0xEF, 0x2A, 0xE6, 0x66,
    //0x41,
    0xD2, 0x48//, 0x03,  0xBA, 0xF5
#endif
};


unsigned char flexCmdCT[] =
{ 0x02 };

unsigned char flexCmdSCT[] =
{
    0x01,
    //0x0B, 0x24, 0xE2, 0x22
    0x0B, 0x24, 0xE7, 0x22
};

unsigned char flexCmdTotal[] =
{ 0x00 };

unsigned char flexCmdMidX[] =
{ 0x02, 0x08 };

unsigned char flexCmdMidY[] =
{ 0x02, 0x07 };

unsigned char flexCmdPreSync[] =
{ 0x02, 0x06 };
unsigned char flexSrcIndex[] =
{
    0x02,
    0x00, 0x00,
    0x00
};





@interface OneTouchPlusFlex()
{
    UInt16 gflexCmdLen;
    UInt16 flexCmdAddr;
    UInt8 flexCmdTmp[32];
    UInt8 gflexCmdBuffer[32];
    
    UInt8 rawIdx;
    UInt16 flexReceiveLen;
    UInt16 flexRawLen;
    UInt8 flexRawBuffer[64];
    
    UInt16 recordIndex;
    UInt16 totalRecords;
    
    BOOL flexPairDone;
    BOOL flexMeterInfo;
    BOOL flexFinished;
    
    NSString *flexUnitString;
}

@end

@implementation OneTouchPlusFlex

- (id)init
{
    if (self = [super init]) {
        
        _ohPlusFlexServiceID = [CBUUID UUIDWithString:BLE_PLUS_FLEX_SERVICE_UUID];
        
        _ohPlusFlexCharacteristicNotifyID = [CBUUID UUIDWithString:BLE_PLUS_FLEX_NOTIFY_UUID];
        _ohPlusFlexCharacteristicWriteID = [CBUUID UUIDWithString:BLE_PLUS_FLEX_WRITE_UUID];
        
        _ohPlusFlexService = nil;
        
        _ohPlusFlexCharacteristicNotify = nil;
        _ohPlusFlexCharacteristicWrite = nil;
        _flexCmdSel = FLEX_CMD_0;
        //_flexCmdGroupSel = FLEX_CMD_GROUP0;
        
        recordIndex = 0;
        totalRecords = 0;
        
        gflexCmdLen = 0;
        flexCmdAddr = 0;
        
        flexPairDone = NO;
        flexMeterInfo = NO;
        flexFinished = NO;
        flexUnitString = @"";
        
        _flexFirstCmd = NO;
    }
    return self;
}

- (void)plusFlexBufferInit
{
    rawIdx = 0;
    
    flexReceiveLen = 0;
    flexRawLen = 0;
    
    gflexCmdLen = 0;
    flexCmdAddr = 0;
    for (int i=0; i<sizeof(flexCmdTmp); i++) {
        flexCmdTmp[i] = 0;
        gflexCmdBuffer[i] = 0;
        
        flexRawBuffer[i] = 0;
        
        flexPairDone = NO;
        flexMeterInfo = NO;
        flexFinished = NO;
    }
}

#pragma mark - VALUE UPDATE
- (void)oneTouchValueUpdate:(CBCharacteristic *)characteristic
{
    if (![characteristic.UUID isEqual:_ohPlusFlexCharacteristicNotifyID]) {
#ifdef DEBUG_ONETOUCH
        NSLog(@"OH Others !!");
#endif
        return;
    }

#ifdef DEBUG_ONETOUCH
    NSLog(@"FLEX BACK ...");
#endif
    Byte *flexBuffer = (Byte *)malloc(20);
    memcpy(flexBuffer, [characteristic.value bytes], characteristic.value.length);
    
    flexPairDone = NO;
    flexMeterInfo = NO;
    flexFinished = NO;
    _flexFirstCmd = NO;
    if (characteristic.value.length > 1) {
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [self dataCollection:flexBuffer withLen:characteristic.value.length];
    }
    // PAIR MODE RETURN
    // METER INFO NOTIFY
    if([H2BleService sharedInstance].blePairingStage){
        if (flexPairDone) {
            if ([H2BleService sharedInstance].h2ConnectedPeripheral != nil) {
                [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
            }
            
            [NSTimer scheduledTimerWithTimeInterval:BLE_PAIRING_REPORT_DELAY_TIME target:self selector:@selector(plusFlexReportPairStatus) userInfo:nil repeats:NO];
            flexPairDone = NO;
#ifdef DEBUG_ONETOUCH
            NSLog(@"FLEX PAIR MODE DONE ");
#endif
            return;
        }
    }
    
    
    if (flexMeterInfo) {
        flexMeterInfo = NO;
        [[H2BleService sharedInstance] bleVendorReportMeterInfo];
#ifdef DEBUG_ONETOUCH
        NSLog(@"FLEX INFO NOTIFY ...");
#endif
        return;
    }
    
    if (flexFinished) {
        flexFinished = NO;
        [H2BleService sharedInstance].bleNormalDisconnected = YES;
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
        if ([H2BleService sharedInstance].h2ConnectedPeripheral != nil) {
            [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
        }
        return;
    }
    
    switch (_flexCmdSel) {
        case FLEX_CMD_0:
#ifdef DEBUG_ONETOUCH
            NSLog(@"CMD 0 BACK ...");
#endif
            if(characteristic.value.length > 1){
                _flexCmdSel++;
                [self plusFlexCmdFlow];
                
                _flexCmdSel++;
#ifdef DEBUG_ONETOUCH
                NSLog(@" 偶數 ... %02X", _flexCmdSel);
#endif
                [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
            }
            break;
            
        case FLEX_CMD_1:
            //NSLog(@"CMD 1 FAIL ...");
            break;
            
        case FLEX_CMD_2:
            if(characteristic.value.length > 1){
                _flexCmdSel++;
                [self plusFlexCmdFlow];
            }
            break;
            
        case FLEX_CMD_3:
            //NSLog(@"CMD 3 BACK ...");
            _flexCmdSel++;
            [self plusFlexCmdFlow];
            break;
            
        case FLEX_CMD_4:
            //NSLog(@"CMD 4 BACK ...");
            _flexCmdSel++;
            [self plusFlexCmdFlow];
            
            _flexCmdSel++;
            [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
            break;
            
        case FLEX_CMD_5:
            //NSLog(@"CMD 5 BACK ...");
            break;
            
        case FLEX_CMD_6:
            //NSLog(@"CMD 6 BACK ...");
            _flexCmdSel++;
            [self plusFlexCmdFlow];
            break;
            
        case FLEX_CMD_7:
            //NSLog(@"CMD 7 BACK ...");
            if(characteristic.value.length > 1){
                _flexCmdSel++;
                [self plusFlexCmdFlow];
                
                _flexCmdSel++;
                [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
            }
            break;
            
        case FLEX_CMD_8:
            //NSLog(@"CMD 8 BACK ...");
            //
            break;
            
        case FLEX_CMD_9:
        case FLEX_CMD_B:
        case FLEX_CMD_D:
        case FLEX_CMD_F:
        case FLEX_CMD_11:
            //NSLog(@"CMD = %02X BACK ...", _flexCmdSel);
            if(characteristic.value.length > 1){
                //NSLog(@"MORE");
                _flexCmdSel++;
                [self plusFlexCmdFlow];
                
                _flexCmdSel++;
                [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
            }else{
                //NSLog(@"LESS");
            }
            break;
            
#ifdef FLEX_PAIR_MODE
        case FLEX_CMD_13:
        case FLEX_CMD_14:
            //NSLog(@"CMD 13, 14 BACK ...");
            if(characteristic.value.length > 1){
                //NSLog(@"MORE");
                _flexCmdSel++;
                [self plusFlexCmdFlow];
            }else{
                //NSLog(@"LESS");
            }
            break;
            
        case FLEX_CMD_15:
            //NSLog(@"CMD 15 BACK ...");
            if(characteristic.value.length > 1){
                //NSLog(@"MORE");
                _flexCmdSel++;
                [self plusFlexCmdFlow];
                
                _flexCmdSel++;
                [NSTimer  scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
            }else{
                //NSLog(@"LESS");
            }
            break;
            
        case FLEX_CMD_17:
            //NSLog(@"CMD 17 BACK ...");
            if (flexBuffer[0] == 0xC1) {
                _flexCmdSel++;
                [self plusFlexCmdFlow];
                
            }else{
                if(characteristic.value.length > 1){
                    //NSLog(@"CMD 17 BACK ... FOR SNIFFER");
                    _flexCmdSel++;
                    [self plusFlexCmdFlow];
                }
                
            }
            break;
            
        case FLEX_CMD_18:
            //NSLog(@"CMD 18 BACK ...");
            if(characteristic.value.length > 1){
                _flexCmdSel++; // 19
                [self plusFlexCmdFlow];
                
                //_flexCmdIndex = 10;
                recordIndex = 0;
                
                _flexCmdSel++; // 1A
                [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
            }
            break;
            
        case FLEX_CMD_1A:
            //NSLog(@"CMD 1A BACK ...");
            if(characteristic.value.length > 1){
                _flexCmdSel++; // 1B
                [self plusFlexCmdFlow];
            }
            break;
            
        case FLEX_CMD_1B:
            //NSLog(@"CMD 1B BACK ...");
            
            if (recordIndex < totalRecords) {
                _flexCmdSel = FLEX_CMD_19; // 19
                [self plusFlexCmdFlow];
                
                
                _flexCmdSel++; // 1A
                [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
                
            }else{
                //flexFinished = YES;
                _flexCmdSel = 0x30; // 1B
                
                [H2BleService sharedInstance].bleNormalDisconnected = YES;
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                if ([H2BleService sharedInstance].h2ConnectedPeripheral != nil) {
                    [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
                }
                return;
            }
            
            break;
#endif
            
#ifdef FLEX_SYNC_MODE
        case FLEX_CMD_13:
            //NSLog(@"CMD 13 BACK ...");
            if(characteristic.value.length > 1){
                //NSLog(@"MORE");
                _flexCmdSel++;
                [self plusFlexCmdFlow];
                
                _flexCmdSel++;
                [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
            }else{
                //NSLog(@"LESS");
            }
            break;
            
        case FLEX_CMD_14:
            //NSLog(@"CMD 14 BACK ... ERROR ");
            if(characteristic.value.length > 1){
                //NSLog(@"MORE");
                //_flexCmdSel++;
                //[self plusFlexCmdFlow];
            }else{
                //NSLog(@"LESS");
            }
            break;
            
        case FLEX_CMD_15:
            //NSLog(@"CMD 15 BACK ... GOOD ");
            if(characteristic.value.length > 1){
                //NSLog(@"MORE");
                _flexCmdSel++;
                [self plusFlexCmdFlow];
            }else{
                if (flexBuffer[0] == 0xC1) {
                    _flexCmdSel++;
                    [self plusFlexCmdFlow];
                }
                //NSLog(@"LESS");
            }
            break;
#endif
            
        case FLEX_CMD_10:
            //NSLog(@"CMD F BACK ...");
            break;
            
        default:
            break;
    }

}


#pragma mark - PLUS FLEX COMMAND AREA


- (void)plusFlexCmdFlow
{
    BOOL sendCmd = YES;
    NSData *dataToWrite = [[NSData alloc]init];
    switch (_flexCmdSel) {
        case FLEX_CMD_0:
        case FLEX_CMD_9:
            [self flexCmdProcess:flexCmdInit withCmdLen:sizeof(flexCmdInit) cmdLocal:FLEX_CMD_ADDR_INIT];
            break;
            
        case FLEX_CMD_1:
        case FLEX_CMD_4:
        case FLEX_CMD_8:
        case FLEX_CMD_A:
        case FLEX_CMD_C:
        case FLEX_CMD_E:
        case FLEX_CMD_10:
        case FLEX_CMD_12:
#ifdef FLEX_PAIR_MODE
        case FLEX_CMD_15: // PAIR MODE
        case FLEX_CMD_17: // PAIR MODE
        case FLEX_CMD_19: // PAIR MODE
        case FLEX_CMD_1B: // PAIR MODE
        case FLEX_CMD_1D: // PAIR MODE
#endif
#ifdef FLEX_SYNC_MODE
        case FLEX_CMD_15: // SYNC MODE
#endif
            gflexCmdBuffer[0] = OH_CMD_81;
            gflexCmdLen = 1;
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
            break;
            
        case FLEX_CMD_2:
        case FLEX_CMD_13:
            [self flexCmdProcess:flexCmdKey withCmdLen:sizeof(flexCmdKey) cmdLocal:FLEX_CMD_ADDR_KEY];
            
            break;
            
        case FLEX_CMD_3:
#ifdef FLEX_PAIR_MODE
        case FLEX_CMD_14: // PAIR MODE
#endif
            gflexCmdBuffer[0] = OH_CMD_83;
            gflexCmdLen = 1;
            break;
            
        case FLEX_CMD_5:
            gflexCmdBuffer[0] = OH_CMD_82;
            gflexCmdLen = 1;
            break;
            
        case FLEX_CMD_6:
            [self flexCmdProcess:flexCmdPassword withCmdLen:sizeof(flexCmdPassword) cmdLocal:FLEX_CMD_ADDR_PW];
            break;
            
        case FLEX_CMD_7:
            // AUTO ...
            break;
            
        case FLEX_CMD_B:
            [self flexCmdProcess:flexCmdCT withCmdLen:sizeof(flexCmdCT) cmdLocal:FLEX_CMD_ADDR_CT];
            
            //[self flexCmdProcess:flexCmdSCT withCmdLen:sizeof(flexCmdSCT) cmdLocal:FLEX_CMD_ADDR_SETCT];
            
            break;
            
        case FLEX_CMD_D:
#ifdef FLEX_SYNC_MODE
        case FLEX_CMD_14: // SYNC MODE
#endif
#ifdef FLEX_PAIR_MODE
        case FLEX_CMD_16: // PAIR MODE
#endif
            [self flexCmdProcess:flexCmdTotal withCmdLen:sizeof(flexCmdTotal) cmdLocal:FLEX_CMD_ADDR_TOTAL];
            break;
            
        case FLEX_CMD_F:
            [self flexCmdProcess:flexCmdMidX withCmdLen:sizeof(flexCmdMidX) cmdLocal:FLEX_CMD_ADDR_Z];
            break;
            
        case FLEX_CMD_11:
            [self flexCmdProcess:flexCmdMidY withCmdLen:sizeof(flexCmdMidY) cmdLocal:FLEX_CMD_ADDR_Z];
            break;
            
#ifdef FLEX_PAIR_MODE
        case FLEX_CMD_1A: // PAIR MODE
            //
            memcpy(&flexSrcIndex[1], &recordIndex, 2);
            [self flexCmdProcess:flexSrcIndex withCmdLen:sizeof(flexSrcIndex) cmdLocal:FLEX_CMD_ADDR_INDEX];
            recordIndex++;
            break;
#endif
            


            
#ifdef FLEX_PAIR_MODE
            case FLEX_CMD_18: // PAIR MODE
            [self flexCmdProcess:flexCmdPreSync withCmdLen:sizeof(flexCmdPreSync) cmdLocal:FLEX_CMD_ADDR_PRESYNC];
                //NSLog(@"ONE TOUCH NEW CMD (WOW)EX = %02X", _flexCmdSel);
                break;
#endif
#ifdef FLEX_SYNC_MODE
        case FLEX_CMD_16:
            [self flexCmdProcess:flexCmdPreSync withCmdLen:sizeof(flexCmdPreSync) cmdLocal:FLEX_CMD_ADDR_PRESYNC];
            break;
#endif
            
        case FLEX_CMD_1C: // PAIR MODE
            sendCmd = NO;
            //NSLog(@"ONE TOUCH NEW CMD (WOW)EX = %02X", _flexCmdSel);
            break;
            
        default:
            sendCmd = NO;
            break;
    }
    
    
    // Write ...
    if (sendCmd) {
        if (gflexCmdBuffer[OH_OFFSET_ST] == OH_ST) {
            flexCmdAddr = gflexCmdBuffer[OH_OFFSET_ADDR];
            flexCmdAddr <<= 8;
            flexCmdAddr += gflexCmdBuffer[OH_OFFSET_ADDR+1];
        }
        if (gflexCmdLen > 20) {
            dataToWrite = [NSData dataWithBytes:gflexCmdBuffer length:20];
            
            gflexCmdLen -= 20;
            memcpy(gflexCmdBuffer, &gflexCmdBuffer[20], gflexCmdLen);
        }else{
            dataToWrite = [NSData dataWithBytes:gflexCmdBuffer length:gflexCmdLen];
        }
        
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
    }
#ifdef DEBUG_ONETOUCH
    NSLog(@"PLUS FLEX SEL = %02X", _flexCmdSel);
    NSLog(@"PLUS FLEX CMD = %@", dataToWrite);
#endif
}

#pragma mark - ====== FLEX PARSER ======
- (void)dataCollection:(Byte *)dataSrc withLen:(NSInteger)dataLen
{
    UInt16 crcTmp = 0;
    UInt16 rawAddr = 0;
    Byte *tmpData = (Byte *)malloc(64);
    for (int i=0; i<64; i++) {
        tmpData[i] = 0;
    }
    flexReceiveLen += dataLen;
    flexReceiveLen--;
    
    
    if (dataSrc[OH_OFFSET_ST] == OH_ST) {
        memcpy(&flexRawLen, &dataSrc[OH_OFFSET_LEN], 2);
        //memcpy(&rawAddr, &dataSrc[OH_OFFSET_ADDR], 2);
        rawAddr = dataSrc[OH_OFFSET_ADDR];
        rawAddr <<= 8;
        rawAddr += dataSrc[OH_OFFSET_ADDR+1];
    }
    
    //NSLog(@" %02X, %d, LEN = %02X, %02X", dataSrc[0], rawIdx, flexReceiveLen, flexRawLen);
    memcpy(&flexRawBuffer[rawIdx * FLEX_DIV], &dataSrc[1], dataLen-1);
    rawIdx++;
    if (flexReceiveLen == flexRawLen) {
        //NSLog(@"DONE (IN) ... %02X", flexRawLen);
        flexReceiveLen = 0;
        rawIdx = 0;
        gflexCmdBuffer[0] = 0;
        gflexCmdBuffer[1] = 0;
        gflexCmdBuffer[2] = 0;
        // CRC CHECK
        crcTmp = [[LSOneTouchUltraMini sharedInstance] crc_calculate_crc:CRC_INIT inSrc:flexRawBuffer inLength:flexRawLen-2];
        
        //NSLog(@"DONE (CRC) ... %04X == %02X, %02X", crcTmp, flexRawBuffer[flexRawLen-2], flexRawBuffer[flexRawLen-1]);
        
        //NSLog(@"DONE (CMD ADDR) ... %04X", flexCmdAddr);
        memcpy(tmpData, &flexRawBuffer[OH_OFFSET_DATA-1], flexRawLen-8);
        BOOL ctrl = NO;
        if (flexRawBuffer[7] & 1) { // Control Solution checking
            ctrl = YES;
        }
        switch (flexCmdAddr) {
            case FLEX_CMD_ADDR_INIT:
                [self plusFlexUintParser:tmpData];
                break;
                
            case FLEX_CMD_ADDR_KEY: // 34 BYTE
                break;
                
            case FLEX_CMD_ADDR_PW:
                // ZEOR DATA
                //NSLog(@"PW BACK");
                flexPairDone = YES;
                break;
                
            case FLEX_CMD_ADDR_CT:
                [self plusFlexCurrentTimeParser:tmpData];
                break;
                
            case FLEX_CMD_ADDR_TOTAL:
                [self plusFlexTotalParser:tmpData];
                flexMeterInfo = YES;
                break;
                
            case FLEX_CMD_ADDR_Z:
                // 0 DATA
                //NSLog(@"0 DATA LEN");
                break;
                
            case FLEX_CMD_ADDR_PRESYNC:
                // PRE SYNC
                //NSLog(@"PRE SYNC");
                break;
                
            case FLEX_CMD_ADDR_INDEX:
                // RECORD DATA BACK
                if (rawAddr == FLEX_BACK_ADDR_IDX) {
                    flexFinished = YES;
                    //NSLog(@"NO RECORD!!");
                    return;
                }
                
                if (recordIndex >= totalRecords){//} || recordIndex == FLEX_MAX_IDX) {
                    flexFinished = YES;
                }
                
                if (ctrl) {
                    [H2SyncReport sharedInstance].bgHasBeenSkip++;
                    return;
                }
                
                [H2Records sharedInstance].bgTmpRecord  = [self plusFlexDateTimeValueParser:tmpData];
                if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                    [H2Records sharedInstance].bgTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
                    
                    [H2SyncReport sharedInstance].serverBgLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime: RECORD_TYPE_BG withUserId:(1 << [H2Records sharedInstance].currentUser)];
                    
                    if ([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]) {
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                        [H2Records sharedInstance].recordBgIndex++;
                        [H2Records sharedInstance].bgTmpRecord.bgIndex = [H2Records sharedInstance].recordBgIndex;
                        
                        [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
                        [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bgTmpRecord];
                    }else{
                        flexFinished = YES;
                    }
                }
                break;
                
            default:
                break;
        }
#ifdef DEBUG_ONETOUCH
        NSLog(@"VAL = %02X, %02X, %02X, %02X", tmpData[0], tmpData[1], tmpData[2], tmpData[3]);
        NSLog(@"VAL = %02X, %02X, %02X, %02X", tmpData[4], tmpData[5], tmpData[6], tmpData[7]);
        NSLog(@"VAL = %02X, %02X, %02X, %02X", tmpData[8], tmpData[9], tmpData[10], tmpData[11]);
        NSLog(@"VAL = %02X, %02X, %02X, %02X", tmpData[12], tmpData[13], tmpData[14], tmpData[15]);
#endif
    }
}
/*
#define BG_UNIT                 @"mg/dL"
#define BG_UNIT_EX              @"mmol/L"
*/
- (void)plusFlexUintParser:(Byte *)dataSrc
{
    //NSLog(@"FLEX UNIT BACK, %02X", dataSrc[0]);
    if (dataSrc[0] > 0) {
        flexUnitString = BG_UNIT_EX;
        //NSLog(@"FLEX UNIT MMOL/L");
    }else{
        flexUnitString = BG_UNIT;
        //NSLog(@"FLEX UNIT MG/DL");
    }
    
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentUnit = flexUnitString;
}

- (void)plusFlexCurrentTimeParser:(Byte *)dataSrc
{
    //NSLog(@"FLEX CT BACK");
    UInt32 flexTime = 0;
    memcpy(&flexTime, dataSrc, 4);
    
    NSString *timeString = @"";
    timeString = [[LSOneTouchUltraMini sharedInstance] dateTimeParser:flexTime];
    //NSLog(@"FLEX CT BACK = %@", timeString);
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = timeString;
}

- (void)plusFlexTotalParser:(Byte *)dataSrc
{
    UInt16 rdTotal = 0;
    memcpy(&rdTotal, dataSrc, 2);
    memcpy(&totalRecords, dataSrc, 2);
#ifdef DEBUG_ONETOUCH
    NSLog(@"FLEX TOTAL BACK = %04X, %04X", rdTotal, totalRecords);
#endif
}

- (H2BgRecord *)plusFlexDateTimeValueParser:(Byte *)dataSrc
{
    //NSLog(@"FLEX RECORD BACK");
    
    H2BgRecord *recordInfo;
    recordInfo = [[H2BgRecord alloc] init];
    
    UInt32 rdTime = 0;
    memcpy(&rdTime, &dataSrc[5], 4);
    
    UInt16 rdValue = 0;
    memcpy(&rdValue, &dataSrc[9], 2);
    
    if (rdValue >= 600) {
        rdValue = 600;
    }
    
    if ([flexUnitString isEqualToString:BG_UNIT_EX]) {
        recordInfo.bgValue_mmol = (float)rdValue/MMOL_COIF;
        recordInfo.bgValue_mg = 0;
    }else{
        recordInfo.bgValue_mmol = 0.0f;
        recordInfo.bgValue_mg = rdValue;
    }
    recordInfo.bgUnit = flexUnitString;
    
    NSString *rdTimeString = @"";
    rdTimeString = [[LSOneTouchUltraMini sharedInstance] dateTimeParser:rdTime];
    
    recordInfo.bgDateTime = [NSString stringWithFormat:@"%@", rdTimeString];
    
    if (![recordInfo.bgMealFlag isEqualToString:@"C"]) {
        // TO DO
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:recordInfo.bgDateTime]) {
            recordInfo.bgMealFlag = @"C";
        }
    }
#ifdef DEBUG_ONETOUCH
    NSLog(@"FLEX RD VALUE and TIME = %d, %02.2f, %@", rdValue, recordInfo.bgValue_mmol, recordInfo.bgDateTime);
#endif
    return recordInfo;
}



#pragma mark - ****** COMMAND PROCESS ******
- (void)flexCmdFlowInit
{
    [OneTouchPlusFlex sharedInstance].flexCmdSel = FLEX_CMD_0;
    [NSTimer scheduledTimerWithTimeInterval:BLE_PAIRING_REPORT_DELAY_TIME target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
    //NSLog(@"PLUS FLEX FLOW START ....");
}

- (void)flexCmdFlowSync
{
    _flexCmdSel++;
    [self plusFlexCmdFlow];
    
    _flexCmdSel++;
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(plusFlexCmdFlow) userInfo:nil repeats:NO];
}

- (void)flexCmdProcess:(unsigned char *) srcData withCmdLen:(UInt16)dataLen cmdLocal:(UInt16)memAddr
{
    unsigned char localBuffer[32] = {0};
    UInt16 totalTmpLen = 0;
    totalTmpLen = OH_LEN_ST + OH_LEN_LEN + OH_LEN_ADDR + dataLen + OH_LEN_EOT + OH_LEN_CRC;
    gflexCmdLen = totalTmpLen;
    
    localBuffer[OH_OFFSET_ST] = OH_ST;
    memcpy(&localBuffer[OH_OFFSET_LEN], &totalTmpLen, 2);
    
    localBuffer[OH_OFFSET_ADDR] = (unsigned char)(memAddr >> 8);
    localBuffer[OH_OFFSET_ADDR+1] = (unsigned char)(memAddr % 256);
    if(dataLen>0){
        memcpy(&localBuffer[OH_OFFSET_DATA], srcData, dataLen);
    }
    
    localBuffer[OH_OFFSET_DATA+dataLen] = OH_EOT;
    
    UInt16 crcTmp = [[LSOneTouchUltraMini sharedInstance] crc_calculate_crc:CRC_INIT inSrc:&localBuffer[OH_LEN_ST] inLength:totalTmpLen-2];
    //goFlex(localBuffer, totalLen-2);
    memcpy(&localBuffer[OH_OFFSET_ST+totalTmpLen-2], &crcTmp, 2);
    memcpy(localBuffer, &localBuffer[OH_OFFSET_ST], totalTmpLen);
    
    gflexCmdBuffer[0] = totalTmpLen/FLEX_DIV + 1;
    
    for(int i=0; i<(totalTmpLen/FLEX_DIV) + 1; i++){
        if(totalTmpLen>(i+1)*FLEX_DIV){
            memcpy(&gflexCmdBuffer[1+i*(FLEX_DIV+1)], &localBuffer[i*FLEX_DIV], FLEX_DIV);
        }else{
            memcpy(&gflexCmdBuffer[1+i*(FLEX_DIV+1)], &localBuffer[i*FLEX_DIV], totalTmpLen-FLEX_DIV*i);
        }
        if(i>0){
            gflexCmdBuffer[i*(FLEX_DIV+1)] = 'A'+i-1;
        }
        gflexCmdLen++;
    }
#ifdef DEBUG_ONETOUCH
    for (int i=0; i<totalTmpLen+1; i++) {
        NSLog(@"CMD %d, = %02X", i, gflexCmdBuffer[i]);
    }
#endif
    //printf("======== THE END ==========\n");
    //for(int i=0; i<=totalLen+20; i++){
    //    printf(" VAL %d, %02X \n", i, gFlexBuffer[i]);
    //}
    //printf("GOOD OH!!");
}

- (void)plusFlexReportPairStatus
{
    [[H2BleCentralController sharedInstance] H2ReportBleDeviceTimeOut];
}


/*
 
unsigned char transfer(char ch)
{
    unsigned char result = '0';
    if(ch >= 'A'){
        result = ch - 'A' + 0xA;
    }else{
        result = ch - '0';
    }
    
    return result;
}

unsigned char ohToAscii(char ch)
{
    unsigned char result = '0';
    if(ch >= 0xA){
        result = ch + 'A' - 0xA;
    }else{
        result = ch + '0';
    }
    
    return result;
}
*/

+ (OneTouchPlusFlex *)sharedInstance
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

/*
 
 
 
 - (void)plusFlexCmdGroup2Flow
 {
 
 }
 
 - (void)plusFlexCmdGroup3Flow
 {
 
 }
 */

/*
 unsigned char flexSrcIndex[] = // [12] =
 {
 //0x01,
 0x02, 0x0C, 0x00,
 0x04, 0x31, 0x02, 0x05,
 0x00, 0x00,
 0x03, 0xEC, 0xE9
 };
 
 unsigned char flexCmdIndex[] = //[13] =
 {
 0x01, 0x02, 0x0C, 0x00,
 0x04, 0x31, 0x02, 0x05,
 0x00, 0x00,
 0x03, 0xEC, 0xE9
 };
 */






