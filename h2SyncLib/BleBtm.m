//
//  BleBtm.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/12/23.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

#define BTM_CMD_LINK            'l'
#define BTM_CMD_TIME_UNIT       'i'
#define BTM_CMD_SN              'r'

#define BTM_CMD_RECORD_NUMBER           'a'
#define BTM_CMD_RECORD_ALL              'd'
#define BTM_CMD_RECORD_IDX              'b'

#define BTM_CMD_WRITE_DATE_TIME_UNIT       'c'

#define BTM_CMD_METER_OFF               'f'

#define CMD_CR                  0x0D
#define CMD_LF                  0x0A


#define     BTM_CMD_LENGTH                          5
#define     BTM_CMD_RECORD_LEN                      9

#define     BTM_CMD_BEGIN                   0
#define     CMD_CHK_HI_AT                   1
#define     CMD_CHK_LO_AT                   2
#define     CMD_CR_AT                       3
#define     CMD_LF_AT                       4

#define     BTM_REPORT_LENGTH               40
#define     UNIT_LEN                        1
#define     BAT_LEVEL_LEN                   1
#define     TAIL_LEN                        4

#define     SPACE_LEN                           1
#define     VALUE_LEN                           3
#define     MGDL_LEN                            5
#define     FLAG_LEN                            1

#define     UNIT_OFFSET                         20
#define     BAT_LEVEL_OFFSET                    21

#define     RECORD_SPACE_OFFSET                 (10)
#define     RECORD_VALUE_OFFSET                 (20)
#define     FLAG_OFFSET                         (28)



#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2AudioFacade.h"

#import "H2Config.h"

#import "BleBtm.h"
#import "H2BleTimer.h"

#import "H2Records.h"
#import "H2LastDateTime.h"

@implementation BleBtm

- (void)BTMCommandGeneral
{
    
    Byte cmdBuffer[5] = {0};
    
    cmdBuffer[3] = CMD_CR;
    cmdBuffer[4] = CMD_LF;
    unsigned char tmp = 0;
 
//     UInt8 cmdCheckSum = 0;

    UInt8 cmdMethod = METHOD_UNIT;
    
//    unsigned char tmp[30] = {0};
    

    
     
     switch (cmdMethod) {
         case METHOD_UNIT:
         case METHOD_MODEL: // Query Model
             cmdBuffer[0] = BTM_CMD_LINK; // Command ID
             _btmSrcPreLen = 0;
             _btmFinished = NO;
             break;
     
         case METHOD_TIME: // Get Current Date And Time
             cmdBuffer[0] = BTM_CMD_TIME_UNIT; // Command ID
             break;
     
         case METHOD_SN:
             cmdBuffer[0] = BTM_CMD_SN; // Command ID
             break;
     
         case METHOD_NROFRECORD: // Get Record Number
             cmdBuffer[0] = BTM_CMD_RECORD_NUMBER; // Command ID
             break;
     
     
         case METHOD_ACK_RECORD: // Get Record Value
         case METHOD_RECORD: // Get Record Value
             cmdBuffer[0] = BTM_CMD_RECORD_ALL; // Command ID
             break;
     
         case METHOD_END: // TURN OFF METER
             cmdBuffer[0] = BTM_CMD_METER_OFF; // Command ID
             break;
             
         case METHOD_DATE: // SET METER CURRENT TIME
             cmdBuffer[0] = BTM_CMD_WRITE_DATE_TIME_UNIT; // Command ID
             
             
             
             break;
     
         default:
             break;
     }
    

    
    tmp = -cmdBuffer[0];
#ifdef DEBUG_APEXBIO
    DLog(@"BEFORE %02X AFTER %02X ", cmdBuffer[0], tmp);
#endif
    unsigned tmpLO, tmpHI;
    tmpLO = (tmp & 0x0F);
    
    tmpHI = (tmp & 0xF0) >> 4;
    
    if (tmpLO > 9) {
        tmpLO += 'a';
        tmpLO -= 10;
    }else{
        tmpLO += '0';
    }
    
    if (tmpHI > 9) {
        tmpHI += 'a';
        tmpHI -= 10;
    }else{
        tmpHI += '0';
    }
    
    cmdBuffer[1] = tmpHI;
    cmdBuffer[2] = tmpLO;
#ifdef DEBUG_APEXBIO
    for (int i = 0; i<5; i++) {
        DLog(@"CMD IS %d, %02X", i, cmdBuffer[i]);
    }
#endif
    _btmPreCmd = BTM_CMD_LINK;
    NSData *dataToWrite = [[NSData alloc]init];
    
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdBuffer length:5];
    
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_Btm_CHAR_Write type:CBCharacteristicWriteWithResponse];
    
}

/*
unsigned char bufBTM[]={
    //        0x73,
    'U',
    'S',
    'V',
    '2',
    'C',
    '2', '0', '0', '0',
    '1', '0', '0'
};
unsigned char btmCh = 'r';
btmCh = 0;
for (int i = 0; i<12; i++) {
    btmCh += bufBTM[i];
}
DLog(@"PRE %02X ", btmCh);
btmCh = -btmCh;
DLog(@"AFTER %02X ", btmCh);
unsigned tmpLO, tmpHI;
tmpLO = (btmCh & 0x0F);

tmpHI = (btmCh & 0xF0) >> 4;

if (tmpLO > 9) {
    tmpLO += 'a';
    tmpLO -= 10;
}else{
    tmpLO += '0';
}

if (tmpHI > 9) {
    tmpHI += 'a';
    tmpHI -= 10;
}else{
    tmpHI += '0';
}

DLog(@"THE BTM LRC IS %2X, %2X", tmpHI, tmpLO);
*/

- (id)init
{
    if (self = [super init]) {
        
        _btmFinished = NO;
        _btmRecordRunning = NO;
        _btmPreCmd = 0;
        
        _btmIndex = 0;
        _btmTotal = 0;
        
        _btmSrcData = (Byte *)malloc(BTM_REPORT_LENGTH);
        _btmSrcLen = 0;
        _btmSrcPreLen = 0;
        
        _model = @"";
        _version = @"";
        _sn = @"";
        
        _currentTime = @"";
        _number = 0;
        _recordTime = @"";
        _recordValue = @"";
        
        _btmUnit = @"";
        //_btmBatterLevel = -1;
        
        // Customer Service And Chracteristic
        
        _h2BtmFirstServiceID = [CBUUID UUIDWithString:BTM_FIRST_SERVICE_ID];
        _h2BtmSecondServiceID = [CBUUID UUIDWithString:BTM_SECOND_SERVICE_ID];
        
        _h2_Btm_FirstService = nil;
        _h2_Btm_SecondService = nil;
        
        _h2BtmCharacteristic_NotifyID = [CBUUID UUIDWithString:BTM_NOTIFY_ID];
        _h2BtmCharacteristic_WriteID = [CBUUID UUIDWithString:BTM_WRITE_ID];
        
//        _h2BtmCharacteristic_AID = [[H2BleService sharedInstance] h2UUIDWithValue:BTM_A_ID];
//        _h2BtmCharacteristic_BID = [[H2BleService sharedInstance] h2UUIDWithValue:BTM_B_ID];
        _h2BtmCharacteristic_CID = [CBUUID UUIDWithString:BTM_C_ID];
        _h2BtmCharacteristic_DID = [CBUUID UUIDWithString:BTM_D_ID];
        
        _h2_Btm_CHAR_Notify = nil;
        _h2_Btm_CHAR_Write = nil;
        
//        _h2_Btm_CHAR_A = nil;
//        _h2_Btm_CHAR_B = nil;
        _h2_Btm_CHAR_C = nil;
        _h2_Btm_CHAR_D = nil;
        
        
#ifdef DEBUG_APEXBIO
        DLog(@"The BTM SERVICE UUID  is %@ YES", _h2BtmFirstServiceID);
        DLog(@"The BTM SERVICE UUID  is %@", _h2BtmSecondServiceID);
        
        DLog(@"The BTM CHAR UUID is %@ -- NOTIFY", _h2BtmCharacteristic_NotifyID);
        DLog(@"The BTM CHAR UUID is %@ -- WRITE", _h2BtmCharacteristic_WriteID);
        
        DLog(@"H2 BTM BLE init ....");
#endif
    }
    return self;
}



+ (BleBtm *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_APEXBIO
    DLog(@"BLE BTM INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}



- (void)h2BtmSubscribeTask {
    
    if (_h2_Btm_CHAR_Notify.isNotifying == NO) {
        [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:_h2_Btm_CHAR_Notify];
    }


    if (_h2_Btm_CHAR_C.isNotifying == NO) {
        [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:_h2_Btm_CHAR_C];
        [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(BTMCommandGeneral) userInfo:nil repeats:NO];
#ifdef DEBUG_APEXBIO
        DLog(@"BTM Notify Task AND Call General Command");
#endif
    }


    
#ifdef DEBUG_APEXBIO
    DLog(@"BTM Notify Task");
#endif
}




- (void)h2BTMReportProcessTask
{
    Byte cmdBuffer[BTM_CMD_RECORD_LEN] = {0};
//    cmdBuffer[CMD_CR_AT] = CMD_CR;
//    cmdBuffer[CMD_LF_AT] = CMD_LF;
    
    UInt8 cmdLen = BTM_CMD_LENGTH;
    UInt16 tmpIdx = 0;
    
    
    _btmSrcLen = [H2AudioAndBleSync sharedInstance].dataLength;
    
    if (_btmSrcPreLen > 0) {
        if (_btmSrcLen <= BTM_REPORT_LENGTH) {
            memcpy(&_btmSrcData[_btmSrcPreLen], [H2AudioAndBleSync sharedInstance].dataBuffer, _btmSrcLen);
        }else{
            memcpy(&_btmSrcData[_btmSrcPreLen], [H2AudioAndBleSync sharedInstance].dataBuffer, BTM_REPORT_LENGTH);
        }
        _btmSrcLen += _btmSrcPreLen;
    }else{
        _btmSrcPreLen = _btmSrcLen;
        if (_btmSrcLen <= BTM_REPORT_LENGTH) {
            memcpy(_btmSrcData, [H2AudioAndBleSync sharedInstance].dataBuffer, _btmSrcLen);
        }else{
            memcpy(_btmSrcData, [H2AudioAndBleSync sharedInstance].dataBuffer, BTM_REPORT_LENGTH);
        }
    }
    
    if ([H2AudioAndBleSync sharedInstance].dataBuffer[[H2AudioAndBleSync sharedInstance].dataLength-1] != CMD_LF) {
        return;
    }
    _btmSrcPreLen = 0;
#ifdef DEBUG_APEXBIO
    DLog(@" Did Come BTM Process TASK LEN %d... %d", _btmSrcLen, [H2AudioAndBleSync sharedInstance].dataLength);
    if (_btmSrcLen > 0) {
        for (int i=0; i<_btmSrcLen; i++) {
            DLog(@"BTM INDEX AND VALUE IS %d and %02X", i, _btmSrcData[i]);
        }
    }
#endif
    unsigned char tmp = 0;
    
    if ([H2BleTimer sharedInstance].bleRecordModeForTimer) {
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    }
    
    switch (_btmPreCmd) {
        case BTM_CMD_LINK:
            cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_TIME_UNIT; // Command ID, Read Current Time
            _btmIndex = 0;
            _btmTotal = 0;
            //_btmBatterLevel = -1;
            [self btmLinkParser];
            
#ifdef DEBUG_BTM
            
#endif
            break;
            
        case BTM_CMD_TIME_UNIT:
            cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_SN; // Command ID, Read SN, The Later
            [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime =[self btmTimeAndUnitParser];
            
#ifdef DEBUG_BTM
            
#endif
            break;
            
        case BTM_CMD_SN:
            cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_RECORD_NUMBER; // Command ID, Read SN, The Former
            
            // Clear 1 second PAIRING TIMER
            // CLEAR READ SN TIMER
            
            if ([H2BleService sharedInstance].bleSerialNumberStage) {
                [H2BleTimer sharedInstance].bleRecordModeForTimer = YES;
            }
            [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
            
            [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [self btmSerialNumberParser];
            
            [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
            if([H2BleService sharedInstance].blePairingStage){
                [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
                return;
            }
            if([H2BleService sharedInstance].bleSerialNumberStage){
                // if SN is right, then start Normal Sync
                if ([[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber isEqualToString:[H2BleService sharedInstance].bleScanningKey]) {
                    // GO TO NORMAL SYNC, GET RIGHT SN
                    [H2BleService sharedInstance].bleSerialNumberStage = NO;
#ifdef DEBUG_APEXBIO
                    DLog(@"BTM SN IS CORRECT ...");
#endif
                }else{
                    [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
                    return;
                }
            }
            
            break;
            
        case BTM_CMD_RECORD_NUMBER:

            [self btmRecordTotalNumberParser];
            _btmIndex++;
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            return;
            
#ifdef DEBUG_BTM
            
#endif
            break;
            
        case BTM_CMD_RECORD_ALL:
            cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_METER_OFF; // Command ID
            break;
            
        case BTM_CMD_METER_OFF:
            
#ifdef DEBUG_BTM
            DLog(@" BTM METER OFF ... HERE ");
#endif
            _btmFinished = YES;
//            return;
            break;

        case BTM_CMD_RECORD_IDX:
            //[[H2BleTimer sharedInstance] h2ClearBleTimerTask];
            
            _btmIndex++;
            if (_btmIndex <= _btmTotal) {
                cmdLen = BTM_CMD_RECORD_LEN;
                cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_RECORD_IDX; // Command ID
            }else{
                _btmRecordRunning = NO;
                cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_METER_OFF; // Command ID
            }
            
            //if ([H2Records sharedInstance].dataTypeFilter & RECORD_TYPE_BG) { // GET BG
            //}
            [H2Records sharedInstance].bgTmpRecord  = [self btmRecordParser];
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
                    _btmRecordRunning = NO;
                    cmdLen = BTM_CMD_LENGTH;
                    cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_METER_OFF; // Command ID
                }
            }
            
            
            
            
/*
             [H2Records sharedInstance].bgTmpRecord = [self btmRecordParser];
             
             if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
             
             if([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
             
             [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
             }else{
             _btmRecordRunning = NO;
             cmdLen = BTM_CMD_LENGTH;
             cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_METER_OFF; // Command ID
             }
             }
             
             
             
*/
            if (_btmRecordRunning) {
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
            }
    
#ifdef DEBUG_BTM
            DLog(@"BTM COMMAND %02X, %02X", _btmPreCmd, cmdBuffer[BTM_CMD_BEGIN]);
            DLog(@"BTM RECORD VALUE %d, %d", _btmIndex, _btmTotal);
#endif

            break;
            

        default:
#ifdef DEBUG_BTM
            DLog(@"BTM NOT SUPPORT COMMAND ...");
#endif
            break;
    }
    
    if (_btmFinished) {
#ifdef DEBUG_BTM
        DLog(@"BTM FINISHED ...");
        DLog(@"BTM STOP !! STOP !!");
#endif
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
        return;
    }
    _btmPreCmd = cmdBuffer[BTM_CMD_BEGIN];
    if (_btmPreCmd == BTM_CMD_RECORD_IDX) {
#ifdef DEBUG_BTM
        DLog(@"THE INDEX %d %d", _btmIndex, (_btmIndex%10));
#endif
        cmdBuffer[4] = _btmIndex%10;
        cmdBuffer[4] += 0x30;
        tmpIdx = _btmIndex/10;
        
        cmdBuffer[3] = tmpIdx%10;
        cmdBuffer[3] += 0x30;
        tmpIdx /= 10;
        
        cmdBuffer[2] = tmpIdx%10;
        cmdBuffer[2] += 0x30;
        cmdBuffer[1] = tmpIdx/10;
        cmdBuffer[1] += 0x30;
        
        
        for (int i=0; i<BTM_CMD_RECORD_LEN-4; i++) {
            tmp += cmdBuffer[i];
        }
        tmp = -tmp;
    }else{
        tmp = -cmdBuffer[BTM_CMD_BEGIN];
    }
#ifdef DEBUG_BTM
    DLog(@"BEFORE %02X AFTER %02X ", cmdBuffer[BTM_CMD_BEGIN], tmp);
#endif
    unsigned tmpLO, tmpHI;
    tmpLO = (tmp & 0x0F);
    
    tmpHI = (tmp & 0xF0) >> 4;
    
    if (tmpLO > 9) {
        tmpLO += 'a';
        tmpLO -= 10;
    }else{
        tmpLO += '0';
    }
    
    if (tmpHI > 9) {
        tmpHI += 'a';
        tmpHI -= 10;
    }else{
        tmpHI += '0';
    }
    
    cmdBuffer[cmdLen-4] = tmpHI;
    cmdBuffer[cmdLen-3] = tmpLO;
    
    cmdBuffer[cmdLen-2] = CMD_CR;
    cmdBuffer[cmdLen-1] = CMD_LF;
    
//    cmdBuffer[CMD_CHK_HI_AT] = tmpHI;
//    cmdBuffer[CMD_CHK_LO_AT] = tmpLO;
    
#ifdef DEBUG_BTM
    for (int i = 0; i<cmdLen; i++) {
        DLog(@"CMD IS %d, %02X", i, cmdBuffer[i]);
    }
    
    DLog(@"BTM CMD LEN IS %d", cmdLen);
#endif
    
    NSData *dataToWrite = [[NSData alloc]init];
    
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdBuffer length:cmdLen];
    
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_Btm_CHAR_Write type:CBCharacteristicWriteWithResponse];
    
}


#pragma mark - BTM PARSER AREA ...

- (BOOL)btmLinkParser
{
    if (_btmSrcData[0] == 'l') {
#ifdef DEBUG_BTM
        DLog(@"THE VALUE IS %02X", _btmSrcData[0]);
#endif        
        return YES;
    }
    return NO;
}

- (NSString *)btmTimeAndUnitParser
{
    unsigned char tmp[30] = {0};
    NSString *meterTime;
    memcpy(tmp, &_btmSrcData[1], _btmSrcLen - (1 + UNIT_LEN + BAT_LEVEL_LEN + TAIL_LEN));
#ifdef DEBUG_BTM
    for (int i=0; i<_btmSrcLen; i++) {
        DLog(@"currentTime id %d and Data %02X", i, _btmSrcData[i]);
    }
#endif
    if (_btmSrcData[UNIT_OFFSET] == '1') {
#ifdef DEBUG_BTM
        DLog(@"BTM UINT is MG/DL");
#endif
        _btmUnit = BG_UNIT;
    }else if(_btmSrcData[UNIT_OFFSET] == '2')
    {
#ifdef DEBUG_BTM
        DLog(@"BTM UINT is MMOL/L");
#endif
        _btmUnit = BG_UNIT_EX;
    }else{
        _btmUnit = @"";
    }
    UInt8 batRawLevel = _btmSrcData[BAT_LEVEL_OFFSET];
    int batTmpLevel = -1;
    //[H2SyncSystemMessageInfo sharedInstance].syncRowBatteryValue = batLevel-0x30;
    [H2BleService sharedInstance].batteryRawValue = batRawLevel- 0x30;
    
    
    switch (_btmSrcData[BAT_LEVEL_OFFSET]) {
        case '1':
            batTmpLevel = 3;//1;
            break;
        case '2':
            batTmpLevel = 5;//2;
            break;
        case '3':
            batTmpLevel = 7;//3;
            break;
        case '4':
            batTmpLevel = 10;//4;
            break;
            
        default:
            batTmpLevel = 1;
            break;
    }
    [H2BleService sharedInstance].batteryLevel = batTmpLevel;
    tmp[4] = '-';
    tmp[7] = '-';
    
    for (int i = 0; i<20; i++) {
        DLog(@"INDEX %d and VALUE %02X", i, tmp[i]);
    }
    meterTime = [NSString stringWithUTF8String:(const char *)tmp];
    meterTime = [meterTime stringByAppendingString:@" +0000"];
#ifdef DEBUG_BTM
    DLog(@"BTM UINT %02X and %@", _btmSrcData[UNIT_OFFSET], _btmUnit);
    DLog(@"BTM BATTERY LEVEL %02X and %d", _btmSrcData[BAT_LEVEL_OFFSET], batTmpLevel);
    DLog(@"BTM DATE TIME IS %@", meterTime);
#endif
    return meterTime;
}


- (NSString *)btmSerialNumberParser
{
    unsigned char tmp[30] = {0};
    NSString *sn;
    memcpy(tmp, _btmSrcData, _btmSrcLen-4);
    sn = [NSString stringWithUTF8String:(const char *)tmp];
#ifdef DEBUG_BTM
    DLog(@"BTM SN IS %@", sn);
#endif
    return sn;
}

- (BOOL)btmRecordTotalNumberParser
{
    if (_btmSrcLen < 8) {
        return NO;
    }
    _btmTotal =
    (_btmSrcData[0] & 0x0F) * 1000 +
    (_btmSrcData[1] & 0x0F) * 100 +
    (_btmSrcData[2] & 0x0F) * 10 +
    (_btmSrcData[3] & 0x0F);
#ifdef DEBUG_BTM
    DLog(@"BMT TOTAL NUMBER %d, %02X, %02X, %02X, %02X, ", _btmTotal, _btmSrcData[0], _btmSrcData[1], _btmSrcData[2], _btmSrcData[3]);
#endif
    return YES;
}

- (H2BgRecord *)btmRecordParser
{
    unsigned char tmp[30] = {0};
    H2BgRecord *recordInfo;
    recordInfo = [[H2BgRecord alloc] init];
    
    UInt8 offset = 0;
    UInt16 value = 0;
    
    UInt16 valueHi = 0;
    UInt16 valueMiddle = 0;

    
    if ([_btmUnit isEqualToString: BG_UNIT_EX]) {
        offset = 2;
        valueHi = _btmSrcData[RECORD_VALUE_OFFSET] & 0x0F;
        valueMiddle = _btmSrcData[RECORD_VALUE_OFFSET + 1] & 0x0F;
        value = (valueHi * 100) + (valueMiddle * 10) + (_btmSrcData[RECORD_VALUE_OFFSET + 3] & 0x0F);
        
        recordInfo.bgValue_mg = 0;
        recordInfo.bgValue_mmol = (float)value/10;
        if (recordInfo.bgValue_mmol >= 33.0f) {
            recordInfo.bgValue_mmol = 33.0f;
        }
#ifdef DEBUG_BTM
        DLog(@"THE VALUE OF MMOL ID %f", recordInfo.bgValue_mmol);
#endif
    }else{
        valueHi = _btmSrcData[RECORD_VALUE_OFFSET] & 0x0F;
        valueMiddle = _btmSrcData[RECORD_VALUE_OFFSET + 1] & 0x0F;
        value = (valueHi * 100) + (valueMiddle * 10) + (_btmSrcData[RECORD_VALUE_OFFSET + 2] & 0x0F);
        
        if (value >= 600) {
            value = 600;
        }
        recordInfo.bgValue_mmol = 0.0f;
        recordInfo.bgValue_mg = value;
    }
    
    recordInfo.bgUnit = _btmUnit;
    
    
    for (int i=0; i<4; i++) {
//        value += (_btmSrcData[RECORD_VALUE_OFFSET + i] & 0x0F) *;
#ifdef DEBUG_BTM
        DLog(@"BTM VALUE %d %2X ", value, _btmSrcData[RECORD_VALUE_OFFSET + i]);
#endif
    }
    
    DLog(@"BTM FLAG IS %02X and %d ", _btmSrcData[FLAG_OFFSET + offset], offset);

    switch (_btmSrcData[FLAG_OFFSET + offset]) {
        case '0':
            recordInfo.bgMealFlag = @"N";
            break;
            
        case '1':
            recordInfo.bgMealFlag = @"C";
            break;
            
        case '2':
            recordInfo.bgMealFlag = @"B";
            break;
            
        case '3':
            recordInfo.bgMealFlag = @"A";
            break;
            
        default:
            break;
    }
    
    
//    memcpy(tmp, _btmSrcData, _btmSrcLen - (SPACE_LEN + VALUE_LEN + MGDL_LEN + offset + FLAG_LEN + TAIL_LEN));
    if (_btmSrcLen > RECORD_VALUE_OFFSET) {
        memcpy(tmp, _btmSrcData, 19);
    }
    
#ifdef DEBUG_BTM
    DLog(@"BTM SPACE BEFORE %2X and Minus %d", tmp[RECORD_SPACE_OFFSET], (SPACE_LEN + VALUE_LEN + MGDL_LEN + offset + TAIL_LEN));
    DLog(@"Minus space %d, value %d, mgdl %d, offset %d, tail %d", SPACE_LEN, VALUE_LEN, MGDL_LEN, offset, TAIL_LEN);
#endif
    tmp[RECORD_SPACE_OFFSET] = 0x20;
#ifdef DEBUG_BTM
    DLog(@"BTM SPACE AFTER %02X ", tmp[RECORD_SPACE_OFFSET]);
#endif
//    dateTime = [NSString stringWithUTF8String:(const char *)tmp];
//    dateTime = [dateTime stringByAppendingString:@" +0000"];
//    recordInfo.smRecordDateTime = dateTime;
    
    recordInfo.bgDateTime = [NSString stringWithUTF8String:(const char *)tmp];
    recordInfo.bgDateTime = [recordInfo.bgDateTime stringByAppendingString:@" +0000"];
    
    if (![recordInfo.bgMealFlag isEqualToString:@"C"]) {
        // TO DO
        //if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:recordInfo.smRecordDateTime]) {
        if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:recordInfo.bgDateTime]) {
            recordInfo.bgMealFlag = @"C";
        }
    }
    
#ifdef DEBUG_BTM
//    DLog(@"BTM DATA TIME IS %@ %@", dateTime, recordInfo.smRecordDateTime);
    DLog(@"BTM DATA TIME IS %@", recordInfo.bgDateTime);
#endif
//    recordInfo.smRecordDateTime = dateTime;
    return recordInfo;
}




- (void)h2BTMGetRecordInit
{
    Byte cmdBuffer[BTM_CMD_RECORD_LEN] = {0};

    UInt8 cmdLen = BTM_CMD_LENGTH;
    UInt16 tmpIdx = 0;
    unsigned char tmp = 0;

    //            cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_RECORD_ALL; // Command ID, Read Total Record
            
    cmdBuffer[BTM_CMD_BEGIN] = BTM_CMD_RECORD_IDX;
    cmdLen = BTM_CMD_RECORD_LEN;
    
    _btmPreCmd = cmdBuffer[BTM_CMD_BEGIN];
    if (_btmPreCmd == BTM_CMD_RECORD_IDX) {
#ifdef DEBUG_BTM
        DLog(@"THE INDEX %d %d", _btmIndex, (_btmIndex%10));
#endif
        cmdBuffer[4] = _btmIndex%10;
        cmdBuffer[4] += 0x30;
        tmpIdx = _btmIndex/10;
        
        cmdBuffer[3] = tmpIdx%10;
        cmdBuffer[3] += 0x30;
        tmpIdx /= 10;
        
        cmdBuffer[2] = tmpIdx%10;
        cmdBuffer[2] += 0x30;
        cmdBuffer[1] = tmpIdx/10;
        cmdBuffer[1] += 0x30;
        
        
        for (int i=0; i<BTM_CMD_RECORD_LEN-4; i++) {
            tmp += cmdBuffer[i];
        }
        tmp = -tmp;
    }else{
        tmp = -cmdBuffer[BTM_CMD_BEGIN];
    }
#ifdef DEBUG_BTM
    DLog(@"BEFORE %02X AFTER %02X ", cmdBuffer[BTM_CMD_BEGIN], tmp);
#endif
    unsigned tmpLO, tmpHI;
    tmpLO = (tmp & 0x0F);
    
    tmpHI = (tmp & 0xF0) >> 4;
    
    if (tmpLO > 9) {
        tmpLO += 'a';
        tmpLO -= 10;
    }else{
        tmpLO += '0';
    }
    
    if (tmpHI > 9) {
        tmpHI += 'a';
        tmpHI -= 10;
    }else{
        tmpHI += '0';
    }
    
    cmdBuffer[cmdLen-4] = tmpHI;
    cmdBuffer[cmdLen-3] = tmpLO;
    
    cmdBuffer[cmdLen-2] = CMD_CR;
    cmdBuffer[cmdLen-1] = CMD_LF;
    
    
#ifdef DEBUG_BTM
    for (int i = 0; i<cmdLen; i++) {
        DLog(@"CMD IS %d, %02X", i, cmdBuffer[i]);
    }
    
    DLog(@"BTM CMD LEN IS %d", cmdLen);
#endif
    
    NSData *dataToWrite = [[NSData alloc]init];
    
    // Write ...
    dataToWrite = [NSData dataWithBytes:cmdBuffer length:cmdLen];
    
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_Btm_CHAR_Write type:CBCharacteristicWriteWithResponse];
    
}


@end
