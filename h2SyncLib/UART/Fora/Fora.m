//
//  Fora.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/12/9.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "Fora.h"
#import "ForaD40.h"
#import "ForaW310.h"


#import "H2AudioFacade.h"
#import "H2Sync.h"
#import "H2DataFlow.h"
#import "H2Records.h"
#import "H2LastDateTime.h"

#import "H2Report.h"
#import "H2BleTimer.h"

Byte gCmdBuffer[FORA_CMD_LENGTH] = {0};

#import "H2Config.h"
#import "H2Records.h"

#import "H2Omron.h"

#import "H2BleTimer.h"

@interface Fora()
{
    UInt8 cmdLength;
    BOOL isBPArrhy;
}
@end

@implementation Fora

- (void)foraCleanCommandBuffer
{
    for (int i=0; i<16; i++) {
        _foraCmdBuffer[i] = 0;
    }
}
- (void)FORABleGetRecord
{
    
    [self foraCleanCommandBuffer];
    //_lenMinus = 1;
    _cmdIndex = 0;
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
            _foraCmdNext = FORA_CMD_RECORD_TIME;
            [[ForaD40 sharedInstance] h2ForaD40CmdTask];
#ifdef DEBUG_BP
            DLog(@"FORA D40 RECORD START ...");
#endif
            return;
            
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            _foraCmdNext = FORA_CMD_THERMO;
            _foraCmdBuffer[2] = W310_CMD_LEN; // W3B, Length
            memcpy(&_foraCmdBuffer[DATA_1], &_cmdIndex, 2);
            //_foraCmdBuffer[CMD_AT] = FORA_CMD_THERMO; // Command ID
            //_lenMinus = 2;
#ifdef DEBUG_BP
            NSLog(@"W310B INDEX === %04X", _cmdIndex);
#endif
            break;
        default:
            _foraCmdNext = FORA_CMD_RECORD_TIME;
            memcpy(&_foraCmdBuffer[DATA_0], &_cmdIndex, 2);
            //_foraCmdBuffer[CMD_AT] = FORA_CMD_RECORD_TIME; // Command ID
            //_foraCmdMethod = METHOD_RECORD;
            break;
    }
    [self foraCmdMapping];
}



- (id)init
{
    if (self = [super init]) {
        
        isBPArrhy = NO;
        cmdLength = 0;
        _syncStart = NO;
        _curCommand = 0;
        _foraCmdBuffer = (Byte *)malloc(16);
        //_lenMinus = 0;
        
        _cmdIndex = 0;
        _recordTotal = 0;
        
        _model = @"";
        _version = @"";
        _sn = @"";
        
        _currentTime = @"";
        _number = 0;
        _recordTime = @"";
        _recordValue = @"";
        
        // Customer Service And Chracteristic
        
        _h2ForaServiceUUID = [CBUUID UUIDWithString:FORA_METER_SERVICE_UUID];
        _h2ForaCharacteristic_WriteNotifyUUID = [CBUUID UUIDWithString:FORA_METER_CHARACTERISTIC_UUID];
        
        _h2_FORA_Service = nil;
        _h2_FORA_CHAR_WriteNotify  = nil;
        
        _foraData = [[NSMutableData alloc] init];
        [_foraData setLength:0];
                
#ifdef DEBUG_FORA
        DLog(@"The FORA SERVICE UUID  is %@", _h2ForaServiceUUID);
        DLog(@"The FORA CHAR UUID is %@", _h2ForaCharacteristic_WriteNotifyUUID);
        DLog(@"H2 FORA BLE init ....");
#endif
    }
    return self;
}

- (const void *)addressOfCmdIndex{
    return &_cmdIndex;
}

+ (Fora *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_FORA
//    DLog(@"BLE FORA INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}


#pragma mark - FORA BLE TASK ===

- (void)h2FORAInitTask
{
    [self h2ForaInternalStart];
}

- (void)h2ForaInternalStart
{
#ifdef DEBUG_FORA
    DLog(@"BLE FORA INIT TASK +++ ");
#endif
    _foraAppUserId = [H2Records sharedInstance].equipUserIdFilter;
    _foraAppDataType = [H2Records sharedInstance].dataTypeFilter;
    
    [self foraCleanCommandBuffer];
    
    _foraFinished = NO;
    //_lenMinus = 1;
    
    _syncStart = YES;
    [ForaD40 sharedInstance].foraD40Info = NO;
    
    _foraCmdNext = FORA_CMD_READ_MODEL;
    [self foraCmdMapping];
}






#pragma mark - FOR READ RECORD TEST
- (void)h2ForaReadRecord{
#ifdef DEBUG_FORA
    for(int i = 0; i<FORA_CMD_LENGTH; i++)
    {
        DLog(@"FORA COMMAND NEXT %d and %02X", i, gCmdBuffer[i]);
    }
#endif
    [self h2ForaBLEWriteTask:gCmdBuffer withLength:FORA_CMD_LENGTH];
}

- (void)h2ForaBLEWriteTask:(unsigned char *)CmdData withLength:(UInt8)length
{
    NSData *dataToWrite = [[NSData alloc]init];
    // Write ...
    dataToWrite = [NSData dataWithBytes:CmdData length:length];
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_FORA_CHAR_WriteNotify type:CBCharacteristicWriteWithResponse];
}




#pragma mark - D40 D40 DATA PROCESS

///////// NEW NEW //////////
- (void)h2FORA_DataProcessTask:(CBCharacteristic *)characteristic
{
    
    [_foraData appendData:characteristic.value];
    memcpy([H2AudioAndBleSync sharedInstance].dataBuffer, [_foraData bytes], _foraData.length);
#ifdef DEBUG_FORA
    DLog(@"FORA DATA LEN %d and %d",  [H2AudioAndBleSync sharedInstance].dataBuffer[2], (int)_foraData.length);
#endif
    if ([H2AudioAndBleSync sharedInstance].dataBuffer[_foraData.length - 2] != FORA_EQUIP_ACK ) {
        return;
    }
    [H2AudioAndBleSync sharedInstance].dataLength = (int)_foraData.length;
    
    [self h2ForaDataProcess];
}

- (void)h2ForaDataProcess
{
    //NSLog(@"FORA-DATA-PROCESS, CUR = %02X", _curCommand);
    [self foraCleanCommandBuffer];
    //for (int i=1; i<16; i++) {
    //    _foraCmdBuffer[i] = 0;
    //}
    [_foraData setLength:0];
    //_foraCmdBuffer[STOP] = FORA_CMD_STOP;
    //_lenMinus = 1;
    
    if ([H2BleTimer sharedInstance].bleRecordModeForTimer) {
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    }
    
    switch (_curCommand) {
        case FORA_CMD_DELETE_ALL:
        case FORA_CMD_PROFILE:
            DLog(@"COMMAND -- WR CLOCK or DEL ALL");
            return;
            
        default:
        case FORA_CMD_READ_MODEL:           // FLOW 0
            [self foraModelProcess];
            break;
            
        case FORA_CMD_READ_CURRENT_TIME:    // FLOW 1
            [self foraCurrentTimeProcess];
            break;
            
        case FORA_CMD_WRITE_CURRENT_TIME:   // FLOW 2
            _foraCmdNext = FORA_CMD_SN_LATER;
            break;
            
        case FORA_CMD_SN_LATER:             // FLOW 3
            _version = [self versionParser];
            _foraCmdNext = FORA_CMD_SN_FORMER;
            break;
            
        case FORA_CMD_SN_FORMER:            // FLOW 4
            if ([self foraSerialNumberProcess]) {
                return;
            }
            break;
            
        case FORA_CMD_FORA_CMD_NUMBER_OF_RECORD: // FLOW 5
            _foraCmdNext = FORA_CMD_RECORD_TIME; // FORAD40_RECORD_TIME;
            _zeroRecord = NO;
            if ([self foraRecordAmountProcess]) {
                return;
            }
            break;
            
        case FORA_CMD_RECORD_TIME: // FLOW 6
            _foraCmdNext = FORA_CMD_RECORD_VALUE; // FORAD40_RECORD_VALUE;
            _recordTime = [self currentTimeParser];
            if ([H2DataFlow sharedDataFlowInstance].equipId & FORA_BP_MASK) {
                [[ForaD40 sharedInstance] h2ForaD40CmdTask];
                return;
            }
            break;
            
        case FORA_CMD_RECORD_VALUE: // FLOW 7
            if ([H2DataFlow sharedDataFlowInstance].equipId & FORA_BP_MASK) {
                // D40, P30 data process
                [[ForaD40 sharedInstance] h2ForaD40RecordTask];
                return;
            }else{ // GD40A,B data process
                [self foraBgRecordProcess];
            }
            break;
            
        case FORA_CMD_THERMO: // FLOW 8
            DLog(@"W310B THERMO ... WILL PROCESS");
            [[ForaW310 sharedInstance] foraW310BRecordProcess];
            break;
            
        case FORA_CMD_TURN_OFF: // FLOW 9
            if ([H2BleService sharedInstance].isBleEquipment || [H2BleService sharedInstance].isBleCable) {
                [H2BleService sharedInstance].bleNormalDisconnected = YES;
            }
            
            if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE) {
                [H2BleService sharedInstance].bleNormalDisconnected = YES;
            }
            
            if (_recordTotal == 0) {
                [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            }

            _foraFinished = YES;
            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            //DLog(@"FORA -- TURN OFF COMMAND");
            //NSLog(@"FORA D40 - NEVER COME HERE !!");
            break;
    }
#ifdef DEBUG_LIB
    [self foraFlowInfo];
#endif
    if (_foraFinished) return;
    [self foraCmdMapping];
}

#pragma mark - MODEL PROCESS
- (void)foraModelProcess
{
    NSString *stringTmp;
    stringTmp = [self modelParser];
    if ([H2DataFlow sharedDataFlowInstance].equipId & FORA_BW_MASK) {
        for (int i=0; i<FORA_W310B_MAX_ID; i++) { // One User Only
            if ([H2Records sharedInstance].equipUserIdFilter & (1 << i)) {
                [H2Records sharedInstance].currentUser = i;
                break;
            }
        }
    }
    [H2BleService sharedInstance].bleTempModel = stringTmp;
    [H2SyncReport sharedInstance].reportMeterInfo.smModelName = @"";//stringTmp;
    _foraCmdNext = FORA_CMD_READ_CURRENT_TIME;
}

#pragma mark - READ CT PROCESS
- (void)foraCurrentTimeProcess
{
    _cmdIndex = 0;
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [self currentTimeParser];
    if ([H2DataFlow sharedDataFlowInstance].equipId & FORA_BW_MASK) {
        _foraCmdNext = FORA_CMD_WRITE_CURRENT_TIME; // W310B
    }else{
        _foraCmdNext = FORA_CMD_SN_LATER; // others
    }
}

/********************************************
            DATA PROCESS AREA
 ********************************************/
#pragma mark - ### SERIAL NUMBER PROCESS
- (BOOL)foraSerialNumberProcess
{
    if ([H2BleService sharedInstance].bleSerialNumberStage) {
        [H2BleTimer sharedInstance].bleRecordModeForTimer = YES;
    }
    
    if ([H2BleService sharedInstance].isBleEquipment || [H2BleService sharedInstance].blePairingStage) {
        // CLEAR READ SN TIMER
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
#ifdef DEBUG_FORA
        DLog(@"FORA CLEAR TIMER AT SN STEP");
#endif
    }
    _sn = [self snParser];
    
#ifdef DEBUG_FORA
    DLog(@"FORA COMMAND %02X, %02X", _curCommand, _foraCmdBuffer[CMD_AT]);
    DLog(@"FORA SN FORMER %@", _sn);
#endif
    _sn = [_sn stringByAppendingString:_version];
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = _sn;
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = _sn;
#ifdef DEBUG_FORA
    DLog(@"FORA SN APPENDING ... %@", _sn);
#endif
    if ([H2BleService sharedInstance].blePairingStage) {
        [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
#ifdef DEBUG_FORA
        DLog(@"FORA SN PAIRING ... %@", _sn);
#endif
        return YES;
    }else{
        if ([H2BleService sharedInstance].isBleEquipment) {
#ifdef DEBUG_FORA
            DLog(@"FORA SERIAL NUMBER STAGE ... %@", _sn);
            DLog(@"FORA SERIAL NUMBER DEVICE ... %@", [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
            DLog(@"FORA SERIAL NUMBER SERVER ... %@", [H2BleService sharedInstance].bleScanningKey);
#endif
            
            if ([[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber isEqualToString:[H2BleService sharedInstance].bleScanningKey]) { // GO TO NORMAL SYNC
                // GET RIGHT SN
                [H2BleService sharedInstance].bleSerialNumberStage = NO;
                [ForaD40 sharedInstance].foraD40Info = YES;
#ifdef DEBUG_FORA
                DLog(@"FORA SN GO TO NORMAL SYNC ... %@", _sn);
#endif
            }else{
#ifdef DEBUG_FORA
                DLog(@"FORA DEVICE NOT FOUND %@", _sn);
#endif
                return YES;
            }
        }// Others, audio device
        
    }
    _foraCmdNext = FORA_CMD_FORA_CMD_NUMBER_OF_RECORD;
    return NO;
}



#pragma mark - ### RECORD AMOUNT PROCESS
- (BOOL)foraRecordAmountProcess
{
    [ForaD40 sharedInstance].isBPRecord = NO;
    [ForaD40 sharedInstance].isBPAvg = NO;
    _cmdIndex = 0;
    _recordTotal = [self recordAmountParser];
    
    [H2SyncReport sharedInstance].didSendEquipInformation = YES;
    
    if ([H2DataFlow sharedDataFlowInstance].equipId & FORA_BP_MASK){
        [[ForaD40 sharedInstance] h2ForaD40NumberOfRecordTask];
        return YES;
    }else{
        if (_recordTotal > 0) {
            return YES;
        }else{
            DLog(@"FORA ZEOR RECORD ---");
            _foraCmdMethod = METHOD_END;
            _foraCmdBuffer[CMD_AT] = FORA_CMD_TURN_OFF; // Command ID
            [H2SyncReport sharedInstance].didSendEquipInformation = NO;
        }
    }
    return NO;
}

#pragma mark - ### BG DATA PROCESS
- (void)foraBgRecordProcess
{
    //NSLog(@"FORA-BG - %d/%d", _cmdIndex, _recordTotal);
    BOOL reachOldRecord = NO;
    _foraCmdNext = FORA_CMD_RECORD_TIME; // FORAD40_RECORD_TIME;
    [H2Records sharedInstance].bgTmpRecord = (H2BgRecord *)[self recordValueParserNEW];
    
    if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
        if([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
            [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
            [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bgTmpRecord];
        }else{
            reachOldRecord = YES;
        }
    }
    
    _cmdIndex++;
    _foraCmdBuffer[CMD_AT] = FORA_CMD_RECORD_TIME; // Command ID
    _foraCmdMethod = METHOD_RECORD;
    if (reachOldRecord || _cmdIndex >= _recordTotal) {
        _foraCmdNext = FORA_CMD_TURN_OFF;
    }else{
        DLog(@"FORA W310B -- NOT ending IDX = %02d", _cmdIndex);
        memcpy(&_foraCmdBuffer[DATA_0], &_cmdIndex, 2);
    }
}

/*************************************************
                COMMAND FLOW
 *************************************************/
#pragma mark - ### COMMAND FLOW and COMMAND MAPPING
- (void)foraCmdMapping
{
    //NSLog(@"FORA-CMD-MAPPING NEXT COMMAND - %02X", _foraCmdNext);
    switch (_foraCmdNext) {
        case FORA_CMD_READ_MODEL:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_READ_MODEL; // Command ID
            _foraCmdMethod = METHOD_MODEL;
            break;
            
        case FORA_CMD_READ_CURRENT_TIME:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_READ_CURRENT_TIME; // Command ID, Read Current Time
            _foraCmdMethod = METHOD_DATE;
            break;
            
        case FORA_CMD_WRITE_CURRENT_TIME:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_WRITE_CURRENT_TIME; // Command ID,  Write CT
            _foraCmdMethod = METHOD_TIME;
            [self timeW310bProcess];
            break;
            
        case FORA_CMD_SN_LATER:
            _cmdIndex = 0;
            _foraCmdBuffer[CMD_AT] = FORA_CMD_SN_LATER; // Command ID, Read SN, The Later
            _foraCmdMethod = METHOD_VERSION;
            break;
            
        case FORA_CMD_SN_FORMER:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_SN_FORMER; // Command ID, Read SN, The Former
            _foraCmdMethod = METHOD_SN;
            break;
            
            
        case FORA_CMD_FORA_CMD_NUMBER_OF_RECORD:
            // Command ID, Read the number of records
            _foraCmdBuffer[CMD_AT] = FORA_CMD_FORA_CMD_NUMBER_OF_RECORD;
            _foraCmdMethod = METHOD_NROFRECORD;
            
            _foraCmdBuffer[DATA_0] = 0;
            _foraCmdBuffer[DATA_1] = 0;
            _foraCmdBuffer[DATA_2] = 0;
            _foraCmdBuffer[DATA_3] = 0;
            
            if ([H2DataFlow sharedDataFlowInstance].equipId & FORA_BP_MASK) {
                if ([[ForaD40 sharedInstance] foraD40NextUser]) {
                    [[ForaD40 sharedInstance] h2ForaD40CmdTask];
                }else{
                    DLog(@"NO USER ID HAS SELECTED ...");
                    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_FORA_NO_USER_SEL];
                }
                return;
            }
            break;
            
        case FORA_CMD_RECORD_TIME:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_RECORD_TIME; // Command ID
            _foraCmdMethod = METHOD_RECORD;
            break;
            
            
        case FORA_CMD_RECORD_VALUE:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_RECORD_VALUE; // Command ID
            _foraCmdMethod = METHOD_ACK_RECORD;
            
            memcpy(&_foraCmdBuffer[DATA_0], &_cmdIndex, 2);
            DLog(@"D40 CMD %02X, %02X, TOTAL %02X", _foraCmdBuffer[DATA_0], _foraCmdBuffer[DATA_D40_ID_AT], _recordTotal);
            break;
            
        case FORA_CMD_THERMO:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_THERMO;
            DLog(@"W310B THERMO ... DO NOTHING ....");
            break;
            
        case FORA_CMD_TURN_OFF:
            _foraCmdBuffer[CMD_AT] = FORA_CMD_TURN_OFF;
            _foraCmdMethod = METHOD_END;
            //NSLog(@"FORA-ENDING COMMAND");
            break;
    }
    if (!_foraFinished) {
        [self h2ForaCmdProcess];
    }
}

- (void)h2ForaCmdProcess
{
    //NSLog(@"FORA-COMMAND-PROCESS ...===== %02X, %02X, %02X, %02X,", _foraCmdBuffer[2] , _foraCmdBuffer[3] , _foraCmdBuffer[4] , _foraCmdBuffer[5] );
    
    UInt8 cmdCheckSum = 0;
    
    if (_foraCmdNext == FORA_CMD_TURN_OFF) {
        for (int i = 2; i<6; i++) {
            _foraCmdBuffer[i] = 0;
        }
    }
    
    _foraCmdBuffer[0] = FORA_CMD_HEADER;
    //_foraCmdBuffer[STOP + 1 - _lenMinus] = FORA_CMD_STOP;
    _curCommand = _foraCmdNext;
    
    if (_foraCmdNext == FORA_CMD_THERMO) {
        cmdLength = THERMAL_CMD_LENGTH;
    }else{
        cmdLength = FORA_CMD_LENGTH;
    }
    _foraCmdBuffer[cmdLength - ACK_OFFSET] = FORA_CMD_STOP;
    
    for (int i = 0; i<cmdLength-1; i++) {
        cmdCheckSum += _foraCmdBuffer[i];
    }
    _foraCmdBuffer[cmdLength-1] = cmdCheckSum;
    
#ifdef DEBUG_FORA
    for(int i = 0; i<cmdLength; i++)
    {
        DLog(@"FORA RECORD COMMAND %d and %02X", i, _foraCmdBuffer[i]);
    }
    if ([H2BleService sharedInstance].isBleEquipment) {
        DLog(@"FORA - VENDOR");
    }
    if  ([H2BleService sharedInstance].blePairingStage) {
        DLog(@"FORA - PAIRING");
    }
#endif
    
    
    if ([H2BleService sharedInstance].isBleEquipment || [H2BleService sharedInstance].blePairingStage) {
        if (_foraFinished) {
            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_FORA
            DLog(@"FORA STOP !! STOP !!");
#endif
            
        }else{
            if ([H2BleTimer sharedInstance].bleRecordModeForTimer) {
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
            }
            [self h2ForaBLEWriteTask:_foraCmdBuffer withLength:cmdLength];
            
            if (_foraCmdNext == FORA_CMD_TURN_OFF) {
                if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE){
                    [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                    [H2BleService sharedInstance].bleNormalDisconnected = YES;
                    //_foraD40Finished = YES;
                    //[H2BleTimer sharedInstance].bleRecordModeForTimer = NO;
                    //[[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL*2 taskSel:BLE_TIMER_RECORD_MODE];
                }
            }
            
#ifdef DEBUG_FORA
            DLog(@"FORA - END WR");
#endif
        }
    }else{
#ifdef DEBUG_FORA
        DLog(@"FORA - USE CABLE");
#endif
        [H2AudioAndBleCommand sharedInstance].didTriggerMeterCmd = YES;
        [H2AudioAndBleResendCfg sharedInstance].didResendMeterCmd = YES;
        
        UInt16 typeAndCmd =  ([H2DataFlow sharedDataFlowInstance].equipUartProtocol << 4) + _foraCmdMethod;
        [[H2AudioFacade sharedInstance] sendCommandDataEx:_foraCmdBuffer withCmdLength:FORA_CMD_LENGTH cmdType:typeAndCmd returnDataLength:FORA_REPORT_LENGTH mcuBufferOffSetAt:0];
    }
}

/**************************************************
                DATA PARSER AREA
 **************************************************/
#pragma mark - FORA DTA PARSER AREA
- (NSString *)modelParser
{
    
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(FORA_REPORT_LENGTH);
    if (length <= FORA_REPORT_LENGTH) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }
    
    // DATA_1 + DATA_0 : Device model in four digits(DATA_1 is the higher byte)
    // DATA_3,DATA_2 : nidefined
    
    unsigned char modelTmp[5] = {0};
    
    modelTmp[0] = srcData[DATA_1] & 0xF0;
    modelTmp[0] = (modelTmp[0] >> 4) + 0x30;
    modelTmp[1] = (srcData[DATA_1] & 0x0F) + 0x30;
    
    modelTmp[2] = srcData[DATA_0] & 0xF0;
    modelTmp[2] = (modelTmp[2] >> 4) + 0x30;
    modelTmp[3] = (srcData[DATA_0] & 0x0F) + 0x30;
#ifdef DEBUG_FORA
    for (int i=0; i<4; i++) {
        DLog(@"MODEL %d and %02X", i, modelTmp[i]);
    }
#endif
    
    NSString *model = [NSString stringWithUTF8String:(const char *)modelTmp];
#ifdef DEBUG_FORA
    DLog(@"MODEL String is %@", model);
#endif
    
    return model;
    
}

- (NSString *)versionParser // The Later
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(FORA_REPORT_LENGTH);
    if (length <= FORA_REPORT_LENGTH) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }
#ifdef DEBUG_FORA
    for (int i=0; i<8; i++) {
        DLog(@"SN CHECK %d and %02X == %02X", i, srcData[i], [H2AudioAndBleSync sharedInstance].dataBuffer[i]);
    }
#endif
    unsigned char snLater[9] = {0};
    unsigned tmpValue = 0;

    tmpValue = srcData[DATA_3];
    tmpValue >>= 4;
    snLater[0] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snLater[1] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_3] & 0x0F];
    tmpValue = srcData[DATA_2];
    tmpValue >>= 4;
    snLater[2] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snLater[3] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_2] & 0x0F];
    
    tmpValue = srcData[DATA_1];
    tmpValue >>= 4;
    snLater[4] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snLater[5] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_1] & 0x0F];
    tmpValue = srcData[DATA_0];
    tmpValue >>= 4;
    snLater[6] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snLater[7] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_0] & 0x0F];
#ifdef DEBUG_FORA
    for (int i=0; i<8; i++) {
        DLog(@"SN Later %d and %02X", i, snLater[i]);
    }
#endif
//    memcpy(snLater, &srcData[DATA_0], 4);
    // The Former 4 bytes come from 0x28
    // and the Later come from 0x27
    NSString *version = [NSString stringWithUTF8String:(const char *)snLater];
#ifdef DEBUG_FORA
    DLog(@"SN Later String is %@", version);
#endif
    return version;
    
}

- (NSString *)snParser  // The Former
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(FORA_REPORT_LENGTH);
    if (length <= FORA_REPORT_LENGTH) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }

    unsigned char snFormer[9] = {0};
    unsigned tmpValue = 0;
    
    tmpValue = srcData[DATA_3];
    tmpValue >>= 4;
    snFormer[0] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[1] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_3] & 0x0F];
    tmpValue = srcData[DATA_2];
    tmpValue >>= 4;
    snFormer[2] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[3] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_2] & 0x0F];
    
    tmpValue = srcData[DATA_1];
    tmpValue >>= 4;
    snFormer[4] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[5] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_1] & 0x0F];
    tmpValue = srcData[DATA_0];
    tmpValue >>= 4;
    snFormer[6] = [[H2SyncReport sharedInstance] h2NumericToChar:tmpValue];
    snFormer[7] = [[H2SyncReport sharedInstance] h2NumericToChar:srcData[DATA_0] & 0x0F];
#ifdef DEBUG_FORA
    for (int i=0; i<8; i++) {
        DLog(@"SN Former %d and %02X", i, snFormer[i]);
    }
#endif
    /*
    snFormer[0] = srcData[DATA_3];
    snFormer[1] = srcData[DATA_2];
    snFormer[2] = srcData[DATA_1];
    snFormer[3] = srcData[DATA_0];
     */
 //   memcpy(snFormer, &srcData[DATA_0], 4);
    // The Former 4 bytes come from 0x28
    // and the Later come from 0x27
    NSString *sn = [NSString stringWithUTF8String:(const char *)snFormer];
#ifdef DEBUG_FORA
    DLog(@"SN Former String is %@", sn);
#endif
    // sn;
    return sn;
    
}

- (NSString *)currentTimeParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(FORA_REPORT_LENGTH);
    if (length <= FORA_REPORT_LENGTH) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }
    
#ifdef DEBUG_FORA
    for (int i=0; i<length; i++) {
        DLog(@"DEBUG_FORA CT index:%02d and Data:%02X", i, srcData[i]);
    }
#endif
    
    // DATA_1[7:1] for Year
    // DATA_1[1] and DATA_0[7:5] for Month
    // DATA_0[4:0] for Day
    
    // DATA_3[7:5] NA
    // DATA_3[4:0] for Hour
    
    // DATA_2[7:6] NA
    // DATA_2[5:0] for Minute
    
    UInt16 year = 0;
    UInt8 month = 0;
    UInt8 day = 0;
    
    UInt8 hour = 0;
    UInt8 minute = 0;
    
    UInt8 tmp = 0;
    
    if (srcData[DATA_2] & D40_BP_MASK) {
        [ForaD40 sharedInstance].isBPRecord = YES;
#ifdef DEBUG_FORA
        DLog(@"D40 - BP  DATA");
#endif
    }else{
        [ForaD40 sharedInstance].isBPRecord = NO;
#ifdef DEBUG_FORA
        DLog(@"D40 - BG  DATA");
#endif
    }
    
    isBPArrhy = NO;
    if (srcData[DATA_2] & D40_BP_ARRHY_MASK) {
        isBPArrhy = YES;
    }
    
    if (srcData[DATA_3] & D40_BP_AVG_MASK) {
        [ForaD40 sharedInstance].isBPAvg = YES;
    }
    
    [ForaD40 sharedInstance].bpArrhyValue = srcData[DATA_3] & D40_BP_IHB_MASK;
    
    [ForaD40 sharedInstance].bpArrhyValue >>= 5;
    
    
    year = srcData[DATA_1] & FORA_MASK_YEAR;
    year = (year >> 1);
    year += 2000;
    
    tmp = srcData[DATA_0] & FORA_MASK_MONTH_LO;
    month = srcData[DATA_1] & FORA_MASK_MONTH_HI;
    month = (month << 3) + (tmp >> 5);
    
    day = srcData[DATA_0] & FORA_MASK_DAY;
    
    hour = srcData[DATA_3] & FORA_MASK_HOUR;
    minute = srcData[DATA_2] & FORA_MASK_MIN;
    
    NSString *currentTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",year, month, day, hour, minute];
    
    return currentTime;
}

- (UInt16)recordAmountParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(FORA_REPORT_LENGTH);
    if (length <= FORA_REPORT_LENGTH) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }
    
    // DATA_1 + DATA_0 = Storage Number(Word)
    UInt16 number;
    UInt16 numberTmp;
    memcpy(&number, &srcData[DATA_0], 2);
    memcpy(&numberTmp, &srcData[DATA_2], 2);
#ifdef DEBUG_FORA
    DLog(@"FORA NR of RECORD %d Without Ctrl %d ...", number, numberTmp);
#endif
    return number;
    
}

- (void)timeW310bProcess
{
    Byte  *timeBuffer;
    timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
    
    UInt8 year = timeBuffer[0]; //[components year];
    UInt8 month = timeBuffer[1]; //[components month];
    UInt8 day = timeBuffer[2]; //[components day];
    
    UInt8 hour = timeBuffer[3]; //[components hour];
    UInt8 minute = timeBuffer[4]; //[components minute];
    
    
    
    _foraCmdBuffer[DATA_1] = year;//-2000;
    _foraCmdBuffer[DATA_1] <<= 1;
    
    if (month & 0x08) {
        _foraCmdBuffer[DATA_1] |= 1;
    }
    _foraCmdBuffer[DATA_0] = month;
    _foraCmdBuffer[DATA_0] <<= 5;
    _foraCmdBuffer[DATA_0] |= day;
    
    _foraCmdBuffer[DATA_2] = minute;
    _foraCmdBuffer[DATA_3] = hour;
    
#ifdef DEBUG_BW
    //UInt8 second = [components second];
    DLog(@"DEMO-DEBUG Y:%04X, M:%02X, D:%02X", year, month, day);
    //DLog(@"DEMO-DEBUG H:%02X, MIN:%02X, SEC:%02X", hour, minute, second);
    DLog(@"OMRON Y:%04X, M:%02X, D:%02X", year, month, day);
#endif
}

#pragma mark - NORMAL RECORD VALUE PARSER
- (id)recordValueParserNEW
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(FORA_REPORT_LENGTH);
    if (length <= FORA_REPORT_LENGTH) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }
    
#ifdef DEBUG_FORA
    for (int i=0; i<length; i++) {
        DLog(@"DEBUG_FORA VAL index:%02d and Data:%02X", i, srcData[i]);
    }
#endif
    

    UInt16 bpSystolic = 0;
    if ([ForaD40 sharedInstance].isBPRecord) {
        
        H2BpRecord *bpRecord;
        bpRecord = [[H2BpRecord alloc] init];
#if 0
        foraRecord.recordDataType = RECORD_TYPE_BP;
        /*
         IHB = 0 : Heart beats are normal
         IHB = 1 : IHB is marked by Tachycardia ( > 110)
         IHB = 2 : IHB is marked by Bradycardia ( < 50)
         IHB = 3 : IHB is marked by Unstable or Varied Heart
         Rate ( ±20%)
         //        IHB = 4 : IHB is marked by Atrail Fibrillation
         
         Arrhy=0 :normal heart beats
         Arrhy=1 : arrhythmia
         IHB=0 : Normal Heart Beats
         IHB=1 : Tachycardia(>110) or Bradycardia(<50)
         IHB=2 : Varied Heart Rate ( ±20%)
         IHB=3 : Atrail Fibrillation (AF)
         */
        foraRecord.recordIsBp = YES;
        if (isBPArrhy) {
            foraRecord.bpIsArrhythmia = YES;
            foraRecord.bpIhbValue = _bpArrhyValue;
        }
        //        if (_isBPAvg) {
        
        //        }
#endif
        if (isBPArrhy) {
            bpRecord.bpIsArrhythmia = YES;
        }
        
        UInt8 sysLen = 2;
        if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_CARESENS_EXT_B_FORA_P30PLUS) {
            sysLen = 1;
        }
        
        memcpy(&bpSystolic, &srcData[DATA_0], sysLen);

        bpRecord.bpSystolic = [NSString stringWithFormat:@"%d.00", bpSystolic];
        bpRecord.bpDiastolic = [NSString stringWithFormat:@"%d.00", srcData[DATA_2]];
        bpRecord.bpHeartRate_pulmin = [NSString stringWithFormat:@"%d.00", srcData[DATA_3]];

        
        bpRecord.bpDateTime = [[NSString alloc] initWithFormat:@"%@",_recordTime];
#ifdef DEBUG_FORA
        DLog(@"HR %@ time/min", bpRecord.bpHeartRate_pulmin);
#endif
        [H2Omron sharedInstance].bpFlag = 'N';
        //if ([H2Omron sharedInstance].bpFlag != 'C') {
            if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bpRecord.bpDateTime]) {
                [H2Omron sharedInstance].bpFlag = 'C';
            }
        //}
        
        return bpRecord;
    }else{
        H2BgRecord *bgOldRecord;
        bgOldRecord = [[H2BgRecord alloc] init];
        
        bgOldRecord.recordType = RECORD_TYPE_BG;
        // DATA_1 DATA_0 : The measure result
        // DATA_3 DATA_2 : Parameters
        // [Glucose Type]
        // 0x0 : Gen
        // 0x1 : AC(before meal)
        // 0x2 : PC(after meal)
        // 0x3 : QC(quality control)
        // DATA_3[7:6] : Clucose Type
        // DATA_3[5:2] : NA
        // DATA_3[1:0] : Code HI
        // DATA_2[7:0] : Code LO
        
        UInt16 value = 0;
        UInt8 type = 0;
        
        UInt16 code = 0;
        
        code = srcData[DATA_3] &  0x03;
        code = (code << 8) + srcData[DATA_2];
        
        memcpy(&value, &srcData[DATA_0], 2);
        type = srcData[DATA_3] & MASK_CLUCOSE_TYPE;
        type = (type >> 6);
#ifdef DEBUG_FORA
        DLog(@"FORA TYPE %d %02X %02X", type, srcData[DATA_3], srcData[DATA_3] & MASK_CLUCOSE_TYPE);
        DLog(@"FORA CODE %d ", code);
#endif
        
        switch (type) {
            case TYPE_AC_BEFORE:
                bgOldRecord.bgMealFlag = @"B";
#ifdef DEBUG_FORA
                DLog(@"RECORD FLAG B ");
#endif
                break;
            case TYPE_PC_AFTER:
                bgOldRecord.bgMealFlag = @"A";
#ifdef DEBUG_FORA
                DLog(@"RECORD FLAG A ");
#endif
                break;
            case TYPE_QC_CTRL:
                bgOldRecord.bgMealFlag = @"C";
#ifdef DEBUG_FORA
                DLog(@"RECORD FLAG C ");
#endif
                break;
            case TYPE_GEN:
            default:
                bgOldRecord.bgMealFlag = @"N";
#ifdef DEBUG_FORA
                DLog(@"RECORD FLAG N ");
#endif
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
        
        bgOldRecord.bgValue_mg = value;
        bgOldRecord.bgValue_mmol = 0.0;
        bgOldRecord.bgUnit = @"N";
        
#ifdef DEBUG_FORA
        DLog(@"DEBUG_FORA record infomation VALUE is %d", bgOldRecord.bgValue_mg);
        DLog(@"DEBUG_FORA date time is %@", bgOldRecord.bgDateTime);
#endif
    
    
        bgOldRecord.bgDateTime = [[NSString alloc] initWithFormat:@"%@",_recordTime];
        if (![bgOldRecord.bgMealFlag isEqualToString:@"C"]) {
            if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bgOldRecord.bgDateTime]) {
            bgOldRecord.bgMealFlag = @"C";
            }
        }
    return bgOldRecord;
    }
}

#pragma mark - FORA DEBUG
- (void)foraFlowInfo
{
    if ([H2Sync sharedInstance].isAudioCable) {
        DLog(@"FORA -- WITH -- MAC ....");
    }else{
        DLog(@"FORA -- WITHOUT -- MAC ....");
    }
    if ([H2BleService sharedInstance].didUseH2BLE) {
        DLog(@"FORA -- WITH -- H2 BLE ....");
    }else{
        DLog(@"FORA -- WITHOUT -- H2 BLE ....");
    }
    if ([H2BleService sharedInstance].isBleCable) {
        DLog(@"FORA -- WITH -- H2 BLE CABLE ....");
    }else{
        DLog(@"FORA -- WITHOUT -- H2 BLE CABLE ....");
    }
    
    if ([H2BleService sharedInstance].isBleEquipment) {
        DLog(@"FORA -- WITH -- VENDOR BLE ....");
    }else{
        DLog(@"FORA -- WITHOUT -- VENDOR BLE ....");
    }
    DLog(@"COMMAND -- 71 -- ELSE .... %X -- %X PRE", _foraCmdBuffer[CMD_AT], _curCommand);
    if (_foraFinished) {
        DLog(@"COMMAND -- FINISH - YA");
        return;
    }else{
        DLog(@"COMMAND -- FINISH - NOT YA");
    }
}

@end

#if 0
// Delete ALL Records
_foraCmdBuffer[STOP] = FORA_CMD_STOP;
_foraCmdBuffer[2] = 0;
_foraCmdBuffer[3] = 0;
_foraCmdBuffer[4] = 0;
_foraCmdBuffer[5] = 0;
_foraCmdBuffer[CMD_AT] = FORA_CMD_DELETE_ALL; // Command ID
#endif

#if 0
// WRITE CLOCK
_foraCmdBuffer[STOP] = FORA_CMD_STOP;
_foraCmdBuffer[2] = ((3<<5) + 18); // M + D
_foraCmdBuffer[3] = (16<<1) + 1; // Y + M
_foraCmdBuffer[4] = 32; // MINUTE
_foraCmdBuffer[5] = 18;// HOUR
_foraCmdBuffer[CMD_AT] = FORA_CMD_WRITE_CURRENT_TIME; // Command ID
#endif





//#define MASK_CLUCOSE_TYPE                           0xC0
//#define MASK_CODE_HI                                0x03
