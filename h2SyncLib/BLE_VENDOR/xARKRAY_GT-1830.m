//
//  AKRAY_GT-1830.m
//  h2LibAPX
//
//  Created by h2Sync on 2017/3/1.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


#import <CoreBluetooth/CoreBluetooth.h>

#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2AudioFacade.h"

#import "H2Config.h"
#import "H2Sync.h"

#import "ARKRAY_GT-1830.h"

#import "H2BleProfile.h"
#import "H2BleEquipId.h"
#import "H2Records.h"
#import "H2LastDateTime.h"

#import "H2BleTimer.h"

#import "H2Records.h"

@interface ArkrayGBlack()
{
    NSString *pwSerialNumber;
}

@end

@implementation ArkrayGBlack

- (id)init
{
    if (self = [super init]) {
        //////////////////////
        // ARKRAY GLUCOCARD G-BLACK
        _Arkray_ServiceUUID = [CBUUID UUIDWithString:ARK_GBLACK_SERVICE_UUID];
        _ArkrayReport_CharacteristicID = [CBUUID UUIDWithString:BLE_REPORT_ID];
        _ArkrayGeneral_CharacteristicUUID = [CBUUID UUIDWithString:ARK_GENERAL_CHARACTERISTIC_UUID];
        
#ifdef DEBUG_BW
        DLog(@"ARKRAY SERVICE UUID - %@", _Arkray_ServiceUUID);
        DLog(@"ARKRAY REPORT UUID - %@", _ArkrayReport_CharacteristicID);
#endif
        pwSerialNumber = @"";
        
        _GBlack_Service = nil;
        _GBlack_Characteristic_Report = nil;
        _akPassword = (Byte *)malloc(6);
        _akCmdBuffer = (Byte *)malloc(16);
        
        _arkrayHardWareInfoLen = 0;
        
        _arkrayPairingMode = NO;
        _arkrayHardwareInfoMode = NO;
        _arkrayAuxMode = NO;
        _arkrayCmdLoopMode = NO;
        //_arkrayMeterInforDone = NO;
        _arkrayRecordCmd = NO;
        
        _ArkraySvrSerialNumber = [[NSString alloc] init];
        _ArkrayNewSerialNumber = [[NSString alloc] init];
        
        _arkLrIndex = 0;
        _arkLrTotal = 0;
        
        _arkrayTmpIdString = @"";
        _arkModel = [[NSString alloc] init];
        _arkCurrentDate = [[NSString alloc] init];
        
        _arkrayDataBuffer = [[NSMutableData alloc] init];
        
        _h2ArkrayScanTimer = [[NSTimer alloc] init];
        _h2ArkrayScanTimer = nil;
        _arkrayHasNofity = NO;
        
        _h2ArkrayCmdNotFoundTimer  = [[NSTimer alloc] init];
        _h2ArkrayCmdNotFoundTimer = nil;

        _arkrayNotify = NO;
        _arkrayDynamicAck = 0;
        
        _arkrayAuxEot = 0;
        
        //_arkrayHardwardInfoCmd = 0;
        //_arkrayCmdForTest = 0;
        _arkrayDynamicCmd = 0;
        _arkrayNackCmd = 0;
        _arkrayEnqCmd = 0;
        
        _arkrayRecordsEnd = NO;
        _arkrayCmdFinish = NO;
        _arkrayCmdMode = NO;
    }
    
    return self;
}

#pragma mark - DATA COME IN !!
- (void)H2Arkray_BGlackReportProcessTask:(CBCharacteristic *)characteristic
{
    UInt16 akCrc = 0;
    
    UInt8 akBase = 0;
    UInt8 akValue = 0;
    
    UInt8 keyBuffer[32] = {0};
    UInt16 sumValue = 0;
    
    if (_arkrayCmdFinish) {
        [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
#ifdef DEBUG_BW
        DLog(@"ARKRAY SYNC ENDING ...");
#endif
        return;
    }
    
    if (_arkrayRecordsEnd) {
        _arkrayCmdFinish = YES;
        _arkrayRecordsEnd = NO;
       [self ArkrayRecordsFinishLoop];
        return;
    }
    
    Byte *akBuffer = (Byte *)malloc(AK_BUFFER_SIZE);
    [_arkrayDataBuffer appendData:characteristic.value];
    memcpy(akBuffer, [_arkrayDataBuffer bytes], _arkrayDataBuffer.length);
    
#ifdef DEBUG_BW
    DLog(@"PW CHECK LEN = %d", (int)_arkrayDataBuffer.length);
    DLog(@"PW CHECK VAL = %02X, %02X", akBuffer[0], akBuffer[1]);
#endif
    if (_arkrayPairingMode) {
        if (_arkrayDataBuffer.length == 2) {
            _arkrayPairingMode = NO;
            if (akBuffer[0] == 0xD3 && akBuffer[1] == 0xFA) {
                // CLEAR READ SN TIMER
                [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
                if([H2BleService sharedInstance].bleSerialNumberStage){
                    // if SN is right, then start Normal Sync
                    [H2BleService sharedInstance].bleSerialNumberStage = NO;
                }
#ifdef DEBUG_BW
                DLog(@"(ARKRAY) BT-ERR: DOMAIN --> CBATTErrorInsufficientAuthentication --> AT NOTIFICATION");
#endif
                [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_ARKRAY_PASSWORD];
                return;
            }
            if (akBuffer[0] == 0x53 && akBuffer[1] == 0x3E) {
                //[self H2ArkrayKeyCommand];
                [NSTimer scheduledTimerWithTimeInterval:LIST_DEV_DELAY_INTERVAL target:self selector:@selector(arkrayPairDone) userInfo:nil repeats:NO];
#ifdef DEBUG_BW
                DLog(@"REGISTER BE DONE");
#endif
                return;
            }
        }else if (_arkrayDataBuffer.length == ARK_CMD_SECRET_LEN && akBuffer[28] == 0x3E) {
            for (int i=1; i<_arkrayDataBuffer.length ; i++) {
                akCrc = [self numberDeCodeNEW:akBuffer[i]];
                keyBuffer[i-1] = akCrc;
#ifdef DEBUG_BW
                DLog(@"REG %d, Val = %02X, \t Code = %02X", i, akBuffer[i], akCrc);
                if (akBuffer[i+3] == 0xA0) {
                    DLog(@"=====================================");
                    DLog(@"\n\n");
                }
#endif
            }
            
            for (int i=0; i<12; i++) {
                sumValue = (keyBuffer[2*i] << 4) + keyBuffer[2*i+1];
            }
            [self calcDynamicaCmd:keyBuffer];
#ifdef DEBUG_BW
            DLog(@"************************************************");
#endif
            // Password ACK
            _akCmdBuffer[0] = AK_PW_HEADER ^ 0x80;
            [self ArkrayWritePassword];
        }
        return;
    }
    
#ifdef DEBUG_BW
    DLog(@"ARKRAY RECEIVED %@", _arkrayDataBuffer);
    DLog(@"ARKRAY DTAT LEN == %d,", (unsigned)[_arkrayDataBuffer length]);
#endif
    
    if(_arkrayHardwareInfoMode){
#ifdef DEBUG_BW
        NSLog(@"+++++++ ARKRAY NEW - INFO MODE +++++++++");
#endif
        if ((_arkrayDynamicCmd ^ AK_KEYCMD_MASK) == akBuffer[_arkrayDataBuffer.length-1]) {
#ifdef DEBUG_BW
            NSLog(@"ARKRAY NEW - INFO PARSER");
#endif
            // CLEAR READ SN TIMER
            [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
            _arkrayHardWareInfoLen = _arkrayDataBuffer.length;
            _arkrayHardwareInfoMode = NO;
            _arkLrIndex = 0;
            _arkLrTotal = 0;
            _arkrayDynamicAck = akBuffer[_arkrayDataBuffer.length-1];
            _arkrayAuxEot = _arkrayDynamicAck ^ 0x80;
            
            //_arkrayDynamicCmd = _arkrayDynamicAck ^ AK_KEYCMD_MASK;
            _arkrayNackCmd = _arkrayDynamicAck ^ AK_AUX1CMD_MASK;
            _arkrayEnqCmd = _arkrayDynamicAck ^ AK_AUX2CMD_MASK;
            
#ifdef DEBUG_BW
            DLog(@"===============  AUXILIARY EOT = %02X ================", _arkrayAuxEot);
            DLog(@"===============  DYNAMIC ACK = %02X ================", _arkrayDynamicAck);
            
            DLog(@"\n");
            DLog(@"===============  DYNAMIC CMD = %02X ================", _arkrayDynamicAck ^ AK_KEYCMD_MASK);
            DLog(@"===============  DYNAMIC CMD = %02X ================", _arkrayDynamicCmd);
            DLog(@"===============  NACK - CMD = %02X ================", _arkrayNackCmd);
            DLog(@"===============  ENQ  CMD = %02X ================", _arkrayEnqCmd);
#endif
            //_hasRegistered = NO;
            _arkrayCmdSel = 0;
            for (int i=0; i<_arkrayDataBuffer.length; i++) {
                akBase = [ self numberNormalize:akBuffer[i]];
                akValue = [self numberDeCodeNEW:akBase];
#ifdef DEBUG_BW
                DLog(@"R = %02d S = %02X, B = %02X \t V = %02X", i, akBuffer[i], akBase, akValue);
#endif
            }
            if (![self arkrayHardwareInfoParser:akBuffer]) {
                [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_NOT_FOUND];
                return;
            }
            if (![H2BleService sharedInstance].blePairingStage) {
                //[[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
            //}else{
                // AUX COMMAND 1
                _akCmdBuffer[0] = _arkrayNackCmd;
                [NSTimer scheduledTimerWithTimeInterval:ARKRAY_CMD_INTERVAL target:self selector:@selector(ArkrayAuxCmdTask) userInfo:nil repeats:NO];
            }
        }
        return;
    }
    
    // AUX COMMAND 2
    if (_arkrayAuxMode) {
#ifdef DEBUG_BW
        NSLog(@"AUX MODE %d, %02X, ACK = %02X", _arkrayDataBuffer.length, akBuffer[0], _arkrayNackCmd);
#endif
        if (akBuffer[0] == _arkrayAuxEot) {
            _akCmdBuffer[0] = _arkrayEnqCmd;
            [NSTimer scheduledTimerWithTimeInterval:ARKRAY_CMD_INTERVAL target:self selector:@selector(ArkrayAuxCmdTask) userInfo:nil repeats:NO];
        }else{
            _arkrayAuxMode = NO;
            [NSTimer scheduledTimerWithTimeInterval:ARKRAY_CMD_INTERVAL target:self selector:@selector(ArkrayGetRecordCommandLoop) userInfo:nil repeats:NO];
        }
        return;
    }
    
    if (_arkrayCmdLoopMode) {
        if (_arkrayRecordCmd) {
            if (_arkrayDataBuffer.length ==  1 && akBuffer[0] == _arkrayDynamicAck ) {
                // Get Record ACK
                _arkrayRecordCmd = NO;
#ifdef DEBUG_BW
                NSLog(@"RECORD INDEX = %d", _arkLrIndex);
                DLog(@"RECORD STAGE LEN : %d, V = %02X, \t %02X", (UInt8)_arkrayDataBuffer.length, akBuffer[0], _arkrayDynamicAck);
#endif
                if (_arkLrTotal > 0) {
                    _arkrayCmdSel = ARKRAY_RECORD_LOOP;
                    [NSTimer scheduledTimerWithTimeInterval:ARKRAY_CMD_INTERVAL target:self selector:@selector(ArkrayGetRecordCommandLoop) userInfo:nil repeats:NO];
                }else{
                    _arkrayRecordsEnd = YES;
                    [self ArkrayRecordsFinishLoop];
                }
            }else{
                if (_arkrayDataBuffer.length ==  ARK_RECORD_LEN){
                    [_arkrayDataBuffer setLength:0];
                    // DECODE ....
                    [H2Records sharedInstance].bgTmpRecord = [self arkrayRecordParser:akBuffer];
                    
                    if (![[H2Records sharedInstance].bgTmpRecord.bgMealFlag isEqualToString:@"C"]) {
                        if([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                            [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                            [H2Records sharedInstance].bpTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
                            
                            [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
                            [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bgTmpRecord];
                        }else{
                            _arkrayRecordsEnd = YES;
                        }
                    }
                }
            }
            return;
        }else{
            /*
            if (_arkrayDataBuffer.length ==  1 && akBuffer[0] == _arkrayDynamicAck ) {
                if (!_arkrayMeterInforDone) {
                    if (_arkrayCmdSel == ARKRAY_RECORD_SEL) {
                        _arkrayMeterInforDone = YES;
                        [H2SyncReport sharedInstance].didSendEquipInformation = YES;
                        return;
                    }
                }
            }
            */
            // Current day or Current Time Back
            if (_arkrayDataBuffer.length ==  ARKRAY_CURRENT_DATE_LEN || _arkrayDataBuffer.length ==  ARKRAY_CURRENT_TIME_LEN) {
                if (_arkrayDataBuffer.length ==  ARKRAY_CURRENT_DATE_LEN) {
                    [self arkrayCurrentDate:akBuffer];
                }
                if (_arkrayDataBuffer.length ==  ARKRAY_CURRENT_TIME_LEN) {
                    [self arkrayCurrentTime:akBuffer];
                    [H2SyncReport sharedInstance].bgHasBeenSkip = 0;
                }
                if (_arkrayCmdSel == (ARKRAY_RECORD_SEL-2)) {
                    //_arkrayMeterInforDone = YES;
                    [H2SyncReport sharedInstance].didSendEquipInformation = YES;
                    return;
                }
                // Sart Records Loop
            }
            [NSTimer scheduledTimerWithTimeInterval:ARKRAY_CMD_INTERVAL target:self selector:@selector(ArkrayGetRecordCommandLoop) userInfo:nil repeats:NO];
            return;
        }
    }
#ifdef DEBUG_BW
    if ([characteristic.UUID isEqual:_ArkrayReport_CharacteristicID]){
        DLog(@"GET REPORT .. HERE");
    }
#endif
}

#pragma mark - ========= PAIR DONE ========
- (void)arkrayPairDone
{
    [ArkrayGBlack sharedInstance].arkrayCmdMode = NO;
    [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
    [[ArkrayGBlack sharedInstance] updateDynamicCommand];
}

#pragma mark - COMMAND COMMAND !! (PASSWORD)
- (void)ArkrayWritePassword
{
#ifdef DEBUG_BW
    DLog(@"ARKRAY WRITE PW TIMER");
#endif
    NSString *tmpPwStr = @"";
    [_arkrayDataBuffer setLength:0];
    NSData *dataToWrite = [[NSData alloc]init];
    
    _akCmdBuffer[7] = 0xA0;
    
    for (int i = 0; i<6; i++) {
        _akCmdBuffer[1+i] = [self dataTransfer:_akPassword[i]];
        if(_akCmdBuffer[0] == 0x93){
            tmpPwStr = [NSString stringWithFormat:@"%d", _akPassword[i]];
            pwSerialNumber = [pwSerialNumber stringByAppendingString:tmpPwStr];
        }
#ifdef DEBUG_BW
        DLog(@"SRC AK-PW %d and %02X <== %d", i, _akCmdBuffer[1+i], _akPassword[i]);
#endif
    }
    dataToWrite = [NSData dataWithBytes:_akCmdBuffer length:8];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_GBlack_Characteristic_Report type: CBCharacteristicWriteWithResponse];
#ifdef DEBUG_BW
    DLog(@"ARKRAY START --  %@", dataToWrite);
#endif
}

#pragma mark - COMMAND COMMAND !! (KEY COMMAND)
- (void)H2ArkrayKeyCommand
{
    _arkrayCmdFinish = NO;
    _arkrayRecordsEnd = NO;
    _arkrayHardwareInfoMode = YES;
    
    [_arkrayDataBuffer setLength:0];
    NSData *dataToWrite = [[NSData alloc]init];
    
    if ([H2BleService sharedInstance].blePairingStage) {
        _arkrayCmdMode = YES;
    }
    _akCmdBuffer[0] = _arkrayDynamicCmd;
    dataToWrite = [NSData dataWithBytes:_akCmdBuffer length:AK_CMD_AUX_LEN];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_GBlack_Characteristic_Report type: CBCharacteristicWriteWithResponse];
#ifdef DEBUG_BW
    DLog(@"SCAN COMMAND START - %02X", _akCmdBuffer[0]);
    DLog(@"RECORD CMD 1 --  %@ WITH TIMER", dataToWrite);
#endif
}

#pragma mark - COMMAND COMMAND !! (AUXILIARY)
- (void)ArkrayAuxCmdTask
{
    _arkrayAuxMode = YES;
    [_arkrayDataBuffer setLength:0];
    NSData *dataToWrite = [[NSData alloc]init];
    
    dataToWrite = [NSData dataWithBytes:_akCmdBuffer length:AK_CMD_AUX_LEN];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_GBlack_Characteristic_Report type: CBCharacteristicWriteWithResponse];
#ifdef DEBUG_BW
    DLog(@"AUX COMMAND --  %@ ", dataToWrite);
#endif
}

#pragma mark - ========= GET DATE, TIME, RECORDS LOOP COMMAND ==========
- (void)ArkrayGetRecordCommandLoop
{
#ifdef DEBUG_BW
    DLog(@"GET RECORDS FROM LOOP, IDX = %d", _arkLrIndex);
#endif
    _arkrayCmdLoopMode = YES;
    //_arkLrTotal = 0; // ???
    if (_arkLrTotal == 0) {
        //_arkrayRecordsEnd = YES;
        _arkrayCmdFinish = YES;
        [self ArkrayRecordsFinishLoop];
        return;
    }
    [_arkrayDataBuffer setLength:0];
    NSData *dataToWrite = [[NSData alloc]init];
    UInt16 tmpIndex = 0;
#ifdef DEBUG_BW
    if (_arkLrIndex == 0) {
        DLog(@"INDEX == 0");
    }
#endif
    /*
     37	 SRC = 5E, 	 VAL = B3, 000
     38	 SRC = 5E, 	 VAL = B3, 000
     39	 SRC = 5E, 	 VAL = B3, 000
     40	 SRC = 1F, 	 VAL = F2, 005
     41	 SRC = 5E, 	 VAL = B3, 000
     42	 SRC = 5E, 	 VAL = B3, 000
     43	 SRC = 5E, 	 VAL = B3, 000
     44	 SRC = DF, 	 VAL = 32, 006
     45	 SRC = 4D, 	 VAL = A0, 255
     */
    tmpIndex = _arkLrIndex;
    if (_arkrayCmdSel == ARKRAY_RECORD_SEL) {
#ifdef DEBUG_BW
        DLog(@"RECORD COMMAND INDEX %d--", _arkLrIndex);
#endif
        _arkrayRecordCmd = YES;
        for (int i=0; i<4; i++) {
            _akCmdBuffer[3-i] = tmpIndex % 16;
            tmpIndex >>= 4;
        }
#ifdef DEBUG_BW
        DLog(@"(RECORDS LOOP)NUMBER = %d, INDEX = %d", _arkLrTotal, _arkLrIndex);
#endif
        // Get 1 Record Only
        _akCmdBuffer[4] = 0;
        _akCmdBuffer[5] = 0;
        _akCmdBuffer[6] = 0;
        _akCmdBuffer[7] = 1;

        for (int i=0; i<8; i++) {
            _akCmdBuffer[i] = [self dataTransfer:_akCmdBuffer[i]];
            _akCmdBuffer[i] = _akCmdBuffer[i] ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;
        }
        
        _akCmdBuffer[8] = 0xA0 ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;
        
        dataToWrite = [NSData dataWithBytes:_akCmdBuffer length:AK_CMD_RECORD_LEN];
        
        if (_arkLrIndex > 0) {
            _arkLrIndex--;
        }
        if (_arkLrTotal > 0) {
            _arkLrTotal--;
        }
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_GBlack_Characteristic_Report type: CBCharacteristicWriteWithResponse];
#ifdef DEBUG_BW
        DLog(@"LOOP CMD %d --  %@ FOR RECORD", _arkrayCmdSel, dataToWrite);
#endif
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
        return;
    }
    
    /*
     CMD CMD 00	SRC = C6, 	V = 2b, 	 NEW = 00
     CMD CMD 01	SRC = 4D, 	V = a0, 	 NEW = 8B
     CMD CMD 02	SRC = 43, 	V = ae, 	 NEW = 85
     CMD CMD 03	SRC = 4D, 	V = a0, 	 NEW = 8B
     CMD CMD 04	SRC = C6, 	V = 2b, 	 NEW = 00
     CMD CMD 05	SRC = 4D, 	V = a0, 	 NEW = 8B
     CMD CMD 06	SRC = 47, 	V = aa, 	 NEW = 81
     CMD CMD 07	SRC = 4D, 	V = a0, 	 NEW = 8B
     CMD CMD 08	SRC = C6, 	V = 2b, 	 NEW = 00
     CMD CMD 09	SRC = 4D, 	V = a0, 	 NEW = 8B
     CMD CMD 10	SRC = 0B, 	V = e6, 	 NEW = CD
     CMD CMD 11	SRC = 4D, 	V = a0, 	 NEW = 8B
     
     */
    
    _arkrayRecordCmd = NO;
    //UInt8 cmdBuffer[2] = {0xae ^ _arkrayCmdSeed, 0xa0 ^ _arkrayCmdSeed}; //{0x43, 0x4D};
    _akCmdBuffer[0] = AK_BASE_DATE ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck; // 0xae // DATE
    _akCmdBuffer[1] = AK_BASE_END ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck; // 0xa0
    if (_arkrayCmdSel%2 == 0) {
        _akCmdBuffer[0] = AK_BASE_LSTARP ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;//0xC6; // 0x2b
    }else{
        switch (_arkrayCmdSel/2) {
            case 0:
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
                _akCmdBuffer[0] = AK_BASE_DATE ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;//0x43; // 0xae DATE
                break;
                
            case 1:
                _akCmdBuffer[0] = AK_BASE_TIME ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;//0x47; // 0xaa TIME
                break;
                
            case 2:
                _akCmdBuffer[0] = AK_BASE_LEND ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;//0x0B; // 0xe6 LOOP END
                break;
                
            default:
                _akCmdBuffer[0] = 0xFF;
                break;
        }
    }
    
    
    dataToWrite = [NSData dataWithBytes:_akCmdBuffer length:AK_CMD_DT_LEN];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_GBlack_Characteristic_Report type: CBCharacteristicWriteWithResponse];
#ifdef DEBUG_BW
    DLog(@"LOOP CMD %d --  %@ DATE AND TIME", _arkrayCmdSel, dataToWrite);
#endif
    _arkrayCmdSel++;
}


#pragma mark - COMMAND COMMAND !! (FINISH LOOP)
- (void)ArkrayRecordsFinishLoop
{
    [_arkrayDataBuffer setLength:0];
    NSData *dataToWrite = [[NSData alloc]init];
    
    if (_arkrayRecordsEnd) {
        _akCmdBuffer[0] = AK_BASE_RECORD_END ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck; // 0x2f // Records Command end
    }else{
        _akCmdBuffer[0] = AK_BASE_DATE ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck; // 0xae // Command End
    }
    
    _akCmdBuffer[1] = AK_BASE_END ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck; // 0xa0
    
    dataToWrite = [NSData dataWithBytes:_akCmdBuffer length:AK_CMD_DT_LEN];
    
#ifdef DEBUG_BW
    DLog(@"CMD FINISH  --  %@ DONE", dataToWrite);
#endif
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_GBlack_Characteristic_Report type: CBCharacteristicWriteWithResponse];
    
}


#pragma mark - PARSER PARSER !! (HARDWARE INFO)
- (BOOL)arkrayHardwareInfoParser:(Byte *)akCode
{
    UInt8 akModel[ARK_MODEL_LEN];
    UInt8 akSerialNumber[ARK_SN_LEN];
    UInt8 akLastRecord[ARK_LRDT_LEN];
    UInt8 akNumber[ARK_NUMBER_LEN];
    UInt8 baseA = 0;
    UInt8 value = 0;
    
    UInt8 akIdx = 0;
    UInt8 akPackage = 0;
    
    while (akIdx < [ArkrayGBlack sharedInstance].arkrayHardWareInfoLen) {
        baseA = [self numberNormalize:akCode[akIdx]];
        if (baseA == 0xA0) {
            if (akPackage == 0) {
                memcpy(akModel, &akCode[akIdx+1], ARK_MODEL_LEN);
            }
            if (akPackage == 1) {
                memcpy(akSerialNumber, &akCode[akIdx+1], ARK_SN_LEN);
            }
            akPackage++;
        }
        akIdx++;
    }
    
    //memcpy(akModel, &akCode[ARK_MODEL_OFFSET], ARK_MODEL_LEN);
    //memcpy(akSerialNumber, &akCode[ARK_SN_OFFSET], ARK_SN_LEN);
    //memcpy(akLastRecord, &akCode[ARK_LRDT_OFFSET], ARK_LRDT_LEN);
    //memcpy(akNumber, &akCode[ARK_NUMBER_OFFSET], ARK_NUMBER_LEN);
    
    if ([ArkrayGBlack sharedInstance].arkrayHardWareInfoLen == ARK_HDINFO_RECORD_LEN) {
        memcpy(akLastRecord, &akCode[ARK_LRDT_OFFSET], ARK_LRDT_LEN);
        memcpy(akNumber, &akCode[ARK_NUMBER_OFFSET], ARK_NUMBER_LEN);
    }else{
        memcpy(akNumber, &akCode[ARK_NEW_GBLACK_NUMBER_OFFSET], ARK_NUMBER_LEN);
    }
    
    unsigned char srcTmp[12] = {0};
#ifdef DEBUG_BW
    DLog(@"========== MODEL =======\n");
#endif
    for (int i=0; i<ARK_MODEL_LEN; i++) {
        baseA = [self numberNormalize:akModel[i]];
        value = [self numberDeCodeNEW:baseA];
        srcTmp[i] = value;
#ifdef DEBUG_BW
        DLog(@"MODEL : %02d, S = %02X, %02X \t%d\t%02X", i, akModel[i], baseA, value, srcTmp[i]);
#endif
    }
#ifdef DEBUG_BW
    DLog(@"ARKRAY - MODEL IS %@\n", _arkModel);
    DLog(@"============= SN ==========\n");
#endif
    for (int i=0; i<ARK_SN_LEN; i++) {
        baseA = [self numberNormalize:akSerialNumber[i]];
        value = [self numberDeCodeNEW:baseA];
        
        srcTmp[i] = value;
#ifdef DEBUG_BW
        DLog(@"SN : %02d, S = %02X %02X \t%d\t%02X", i, akSerialNumber[i], baseA, value, srcTmp[i] );
#endif
    }
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [NSString stringWithFormat:@"%d%d%d%d%d%d%d",srcTmp[0], srcTmp[1], srcTmp[2], srcTmp[3], srcTmp[4], srcTmp[5], srcTmp[6]];
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [NSString stringWithFormat:@"%d%d%d%d%d%d%d",srcTmp[0], srcTmp[1], srcTmp[2], srcTmp[3], srcTmp[4], srcTmp[5], srcTmp[6]];

#ifdef DEBUG_BW
    DLog(@"ARKRAY 2 - SERIAL NUMBER IS %@\n", [h2MeterModelSerialNumber sharedInstance].smSerialNumber);
    DLog(@"============= LAST INDEX ==========\n");
#endif
    if ([ArkrayGBlack sharedInstance].arkrayHardWareInfoLen == ARK_HDINFO_RECORD_LEN) {
        for (int i=2; i<6; i++) {
            baseA = [self numberNormalize:akLastRecord[i]];
            value = [self numberDeCodeNEW:baseA];
            _arkLrIndex <<= 4;
            _arkLrIndex += value;
#ifdef DEBUG_BW
            DLog(@"LST INDX: %02d, S = %02X %02X \t%d\t INDEX = %04d", i, akLastRecord[i], baseA , value, _arkLrIndex);
#endif
        }
#ifdef DEBUG_BW
        DLog(@"============= LAST RECORD ==========\n");
#endif
        for (int i=0; i<ARK_LRDT_LEN; i++) {
            baseA = [self numberNormalize:akLastRecord[i]];
            value = [self numberDeCodeNEW:baseA];
#ifdef DEBUG_BW
            DLog(@"LST : %02d, S = %02X %02X \t%d", i, akLastRecord[i], baseA , value);
#endif
        }
        [self arkrayRecordParser:akLastRecord];
    }
    
    [H2SyncReport sharedInstance].hasSMSingleRecord = NO;
#ifdef DEBUG_BW
    DLog(@"\n");
    DLog(@"============= TOTAL NUMBER  ==========\n");
#endif
    for (int i=0; i<ARK_NUMBER_LEN; i++) {
        baseA = [self numberNormalize:akNumber[i]];
        value = [self numberDeCodeNEW:baseA];
        _arkLrTotal *= 10;
        _arkLrTotal += value;
#ifdef DEBUG_BW
        DLog(@"INDEX : %02d, S = %02X %02X \t%d \tTOTAL : %04X and %04d", i, akNumber[i], baseA , value, _arkLrTotal, _arkLrTotal);
#endif
    }
#ifdef DEBUG_BW
    NSLog(@"SN VS SCAN KEY");
    NSLog(@"&&&&&&&&&& SN =  %@", [h2MeterModelSerialNumber sharedInstance].smSerialNumber);
    NSLog(@"&&&&& SCAN KEY = %@", [H2BleService sharedInstance].bleScanningKey);
#endif
    NSString *shtSerialNumber;
    if ([H2BleService sharedInstance].blePairingStage) {
#ifdef DEBUG_BW
        DLog(@"(CMD) UPATE-BEGIN");
#endif
        //[self updateDynamicCommand];
#ifdef DEBUG_BW
        DLog(@"(CMD) UPATE-END");
#endif
    }else{
        if([H2BleService sharedInstance].bleScanningKey.length >= 7){
            if (![[h2MeterModelSerialNumber sharedInstance].smSerialNumber isEqualToString:[H2BleService sharedInstance].bleScanningKey]) {
                return NO;
            }
        }else{
            shtSerialNumber = [[h2MeterModelSerialNumber sharedInstance].smSerialNumber substringWithRange:NSMakeRange(1, 6)];
            if (![shtSerialNumber isEqualToString:[H2BleService sharedInstance].bleScanningKey]) {
                return NO;
            }
        }
    }
#ifdef DEBUG_BW
    DLog(@"\n");
#endif
    return YES;
}

- (void)updateDynamicCommand
{
    BOOL isOldDevice = NO;
    UInt16 cIndex = 0;
    NSString *bleIdString;
    NSDictionary *arkrayInfo = [[NSDictionary alloc] init];
    
    UInt8 exSerialNumber[3] = {0};
    exSerialNumber[0] = [self arkrayToAscii:(_arkrayDynamicCmd & 0xF0)>>4];
    exSerialNumber[1] = [self arkrayToAscii:_arkrayDynamicCmd & 0x0F];
    NSString *cmdString =[NSString stringWithFormat:@"%c%c", exSerialNumber[0], exSerialNumber[1]];
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = pwSerialNumber;
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = pwSerialNumber;
    arkrayInfo = @{
                    @"ARKRAY_Identifier":_arkrayTmpIdString,
                    @"ARKRAY_SerialNumber":[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber,
                    @"ARKRAY_Command":cmdString,
                    };
    NSMutableArray *arkrayDevices = [[NSMutableArray alloc] init];
    NSArray *arkrayOldDevices = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_ARKRAY_CMDLIST"];
    if ([arkrayOldDevices count] > 0) {
        for (NSDictionary *dicInfo in arkrayOldDevices) {
            [arkrayDevices addObject:dicInfo];
        }
#ifdef DEBUG_BW
        DLog(@"(CMD)ARKRAY OLD - %@", arkrayOldDevices);
#endif
        for (NSDictionary *dicInfo in arkrayOldDevices) {
            bleIdString = [dicInfo objectForKey: @"ARKRAY_Identifier"];
            //[arkrayDevices addObject:dicInfo];
            if ([bleIdString isEqualToString:_arkrayTmpIdString]) {
                isOldDevice = YES;
                [arkrayDevices replaceObjectAtIndex:cIndex withObject:arkrayInfo];
                break;
            }
            cIndex++;
        }
    }
    if (!isOldDevice) {
#ifdef DEBUG_BW
        DLog(@"(CMD)ARKRAY NEW");
#endif
        [arkrayDevices addObject:arkrayInfo];
    }
#ifdef DEBUG_BW
    DLog(@"(CMD)ARKRAY CURRENT - %@", arkrayDevices);
#endif
    [[NSUserDefaults standardUserDefaults] setObject:arkrayDevices forKey:@"UDEF_ARKRAY_CMDLIST"];
    
    [[H2BleCentralController sharedInstance] h2BleSetDeviceSerialNumber:pwSerialNumber];
    [[H2BleCentralController sharedInstance] H2ReportBleDeviceTimeOut];
    //[[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
}

-(BOOL)getCurrentDynamicCommand
{
    NSString *bleIdString;
    NSString *cmdString;
    UInt8 cmdBuffer[2] = {0};
    
    NSArray *arkrayOldDevices = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_ARKRAY_CMDLIST"];
    
    if ([arkrayOldDevices count] > 0) {
        for (NSDictionary *dicInfo in arkrayOldDevices) {
            bleIdString = [dicInfo objectForKey: @"ARKRAY_Identifier"];
            cmdString = [dicInfo objectForKey: @"ARKRAY_Command"];
            if ([bleIdString isEqualToString:_arkrayTmpIdString]) {
                // COMMAND PROCESS ...
                
                cmdBuffer[0] = [[ArkrayGBlack sharedInstance] arkrayToHex:[cmdString characterAtIndex:0]];
                cmdBuffer[1] = [[ArkrayGBlack sharedInstance] arkrayToHex:[cmdString characterAtIndex:1]];
                
                [ArkrayGBlack sharedInstance].arkrayDynamicCmd = (cmdBuffer[0] << 4) | cmdBuffer[1];
#ifdef DEBUG_LIB
                DLog(@"ARKRAY NEW CMD - %@, VAL = %02X", cmdString, [ArkrayGBlack sharedInstance].arkrayDynamicCmd);
#endif
                return YES;
            }
        }
    }
#ifdef DEBUG_LIB
    NSLog(@"(CMD)ARKRAY CMD NOT FOUND");
#endif
    return NO;
}

- (void)initSn
{
    pwSerialNumber = @"";
    _arkrayCmdFinish = NO;
    _arkrayRecordsEnd = NO;
}
/*
 R = 00 S = 8C, B = AE 	 V = 0D
 R = 01 S = 82, B = A0 	 V = FF
 
 /////////// MODEL ///////////////
 R = 02 S = D1, B = F3 	 V = 01
 R = 03 S = 93, B = B1 	 V = 08
 R = 04 S = 51, B = 73 	 V = 03
 R = 05 S = 91, B = B3 	 V = 00
 R = 06 S = 0D, B = 2F 	 V = 0B
 R = 07 S = 82, B = A0 	 V = FF
 
 ///////// SERIAL NUMBER //////////
 R = 08 S = D0, B = F2 	 V = 05
 R = 09 S = D0, B = F2 	 V = 05
 R = 10 S = 11, B = 33 	 V = 02
 R = 11 S = 50, B = 72 	 V = 07
 R = 12 S = 90, B = B2 	 V = 04
 R = 13 S = D3, B = F1 	 V = 09
 R = 14 S = D0, B = F2 	 V = 05
 R = 15 S = 82, B = A0 	 V = FF
 
 //////////// ??? ////
 R = 16 S = 91, B = B3 	 V = 00
 R = 17 S = 82, B = A0 	 V = FF
 
 //////////// ???? LAST RECORD INFOR ////
 R = 18 S = 91, B = B3 	 V = 00
 R = 19 S = 91, B = B3 	 V = 00
 R = 20 S = 91, B = B3 	 V = 00
 R = 21 S = D0, B = F2 	 V = 05
 R = 22 S = 50, B = 72 	 V = 07
 R = 23 S = CC, B = EE 	 V = 0E
 R = 24 S = 91, B = B3 	 V = 00
 R = 25 S = 91, B = B3 	 V = 00
 
 ////////// LAST RECORD ///////
 R = 26 S = 90, B = B2 	 V = 04
 R = 27 S = 51, B = 73 	 V = 03
 
 R = 28 S = D1, B = F3 	 V = 01
 R = 29 S = 50, B = 72 	 V = 07
 
 R = 30 S = D1, B = F3 	 V = 01
 R = 31 S = 11, B = 33 	 V = 02
 
 R = 32 S = 91, B = B3 	 V = 00
 R = 33 S = 90, B = B2 	 V = 04
 
 R = 34 S = D1, B = F3 	 V = 01
 R = 35 S = 50, B = 72 	 V = 07
 
 R = 36 S = 91, B = B3 	 V = 00
 R = 37 S = 93, B = B1 	 V = 08
 R = 38 S = 91, B = B3 	 V = 00
 R = 39 S = 91, B = B3 	 V = 00
 R = 40 S = 0C, B = 2E 	 V = 0F
 R = 41 S = 0C, B = 2E 	 V = 0F
 ////////// LAST RECORD END ///////
 
 R = 42 S = 82, B = A0 	 V = FF
 
 //////// INDEX RECORDS /////////
 R = 43 S = 91, B = B3 	 V = 00
 R = 44 S = 91, B = B3 	 V = 00
 R = 45 S = 10, B = 32 	 V = 06
 R = 46 S = 58, B = 7A 	 V = 07
 R = 47 S = 90, B = B2 	 V = 04
 R = 48 S = 51, B = 73 	 V = 03
 R = 49 S = 82, B = A0 	 V = FF
 
 R = 50 S = DE, B = FC 	 V = 0D
 R = 51 S = 1F, B = 3D 	 V = 0A
 R = 52 S = 1C, B = 3E 	 V = 06
 
 
 R = 18 S = 5A, B = B3 	 V = 00
 R = 19 S = 5A, B = B3 	 V = 00
 R = 20 S = 5A, B = B3 	 V = 00
 R = 21 S = 1B, B = F2 	 V = 05
 R = 22 S = 9B, B = 72 	 V = 07
 R = 23 S = 07, B = EE 	 V = 0E
 R = 24 S = 5A, B = B3 	 V = 00
 R = 25 S = 5A, B = B3 	 V = 00
 
 R = 26 S = 5B, B = B2 	 V = 04
 R = 27 S = 9A, B = 73 	 V = 03
 R = 28 S = 1A, B = F3 	 V = 01
 R = 29 S = 9B, B = 72 	 V = 07
 R = 30 S = 1A, B = F3 	 V = 01
 R = 31 S = DA, B = 33 	 V = 02
 R = 32 S = 5A, B = B3 	 V = 00
 R = 33 S = 5B, B = B2 	 V = 04
 
 R = 34 S = 1A, B = F3 	 V = 01
 R = 35 S = 9B, B = 72 	 V = 07
 R = 36 S = 5A, B = B3 	 V = 00
 R = 37 S = 58, B = B1 	 V = 08
 R = 38 S = 5A, B = B3 	 V = 00
 R = 39 S = 5A, B = B3 	 V = 00
 R = 40 S = C7, B = 2E 	 V = 0F
 R = 41 S = C7, B = 2E 	 V = 0F
 R = 42 S = 49, B = A0 	 V = FF
 
 R = 43 S = 5A, B = B3 	 V = 00
 R = 44 S = 5A, B = B3 	 V = 00
 R = 45 S = DB, B = 32 	 V = 06
 R = 46 S = 93, B = 7A 	 V = 07
 R = 47 S = 5B, B = B2 	 V = 04
 R = 48 S = 9A, B = 73 	 V = 03
 R = 49 S = 49, B = A0 	 V = FF
 
 R = 50 S = 15, B = FC 	 V = 0D
 R = 51 S = D4, B = 3D 	 V = 0A
 R = 52 S = D7, B = 3E 	 V = 06
 
 
 */

#pragma mark - PARSER PARSER !! (CURRENT DATE)
- (UInt8) arkrayCurrentDate:(Byte *)srcData
{
    unsigned char srcNumber = 0;
    
    int day = 0;
    int month = 0;
    int year = 0;
    
    unsigned char tmpA = 0;
    unsigned char tmpB = 0;
    
    /////////////////////////////////////////
    // Decode ...
    
    tmpA = [self numberNormalize:srcData[2]];
    tmpB = [self numberNormalize:srcData[3]];
    year = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
    tmpA = [self numberNormalize:srcData[4]];
    tmpB = [self numberNormalize:srcData[5]];
    month = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
    tmpA = [self numberNormalize:srcData[6]];
    tmpB = [self numberNormalize:srcData[7]];
    day = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
#ifdef DEBUG_BW
    printf("========= CURRENT DAY ========\n");
    printf("DATE-DAY : %04d-%02d-%02d", year+2000, month, day);
    printf("\n\n");
#endif
    
    _arkCurrentDate = [NSString stringWithFormat:@"%04d-%02d-%02d", year+2000, month, day ];
    return srcNumber;
}

#pragma mark - PARSER PARSER !! (CURRENT TIME)
- (UInt8) arkrayCurrentTime:(Byte *)srcData
{
    unsigned char srcNumber = 0;
    
    int minute = 0;
    int hour = 0;
    
    unsigned char tmpA = 0;
    unsigned char tmpB = 0;
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    /////////////////////////////////////////
    // Decode ...
    
    tmpA = [self numberNormalize:srcData[2]];
    tmpB = [self numberNormalize:srcData[3]];
    hour = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
    tmpA = [self numberNormalize:srcData[4]];
    tmpB = [self numberNormalize:srcData[5]];
    minute = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
#ifdef DEBUG_BW
    printf("========= CURRENT TIME ========\n");
    printf("CT-TIME : %02d:%02d:00 +0000",  hour, minute);
    printf("\n\n");
#endif
    
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:@"%@ %02d:%02d:00 +0000",  _arkCurrentDate, hour, minute];
    
    return srcNumber;
}

#pragma mark - PARSER PARSER !! (RECORDS)
////////////////////////////////////////////////////
// Decode Task
- (H2BgRecord *) arkrayRecordParser:(Byte *)srcData
{
    UInt16 value = 0;
    UInt16 index = 0;
    
    UInt8 minute = 0;
    UInt8 hour = 0;
    
    UInt8 day = 0;
    UInt8 month = 0;
    UInt16 year = 0;
    
    UInt8 status = 0;
    
    unsigned char tmpA = 0;
    unsigned char tmpB = 0;
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    for (int i=0; i<32; i++) {
        tmpA = [self numberNormalize:srcData[i]];
#ifdef DEBUG_BW
        DLog(@"R-INDX: %02d, Dy = %02X Ba = %02X \t Val = %02X", i, srcData[i], tmpA, [self numberDeCodeNEW:tmpA]);
#endif
    }
    
    /////////////////////////////////////////
    // Decode ...
    for (int i=2; i<6; i++) {
        tmpA = [self numberNormalize:srcData[i]];
        tmpA = [self numberDeCodeNEW:tmpA];
        index <<= 4;
        index += tmpA;
    }
    // High Byte
    tmpA = [self numberNormalize:srcData[8]];
    tmpB = [self numberNormalize:srcData[9]];
    value = ([self numberDeCodeNEW:tmpA]<<4) + [self numberDeCodeNEW:tmpB];
    value <<= 8;
    
    // Low Byte
    tmpA = [self numberNormalize:srcData[6]];
    tmpB = [self numberNormalize:srcData[7]];
    value += ([self numberDeCodeNEW:tmpA]<<4) + [self numberDeCodeNEW:tmpB];
    //NSLog(@"NEO VALUE = %d, %4X", value, value);
    
    tmpA = [self numberNormalize:srcData[10]];
    tmpB = [self numberNormalize:srcData[11]];
    minute = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
    tmpA = [self numberNormalize:srcData[12]];
    tmpB = [self numberNormalize:srcData[13]];
    hour = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
    tmpA = [self numberNormalize:srcData[14]];
    tmpB = [self numberNormalize:srcData[15]];
    day = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
    tmpA = [self numberNormalize:srcData[16]];
    tmpB = [self numberNormalize:srcData[17]];
    month = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
    tmpA = [self numberNormalize:srcData[18]];
    tmpB = [self numberNormalize:srcData[19]];
    year = ([self numberDeCodeNEW:tmpA] * 10) + [self numberDeCodeNEW:tmpB];
    
#ifdef DEBUG_BW
    printf("========= Record %02d ========\n", index);
    printf("=========  Value %02d  ========\n", value);
    printf("DATE-TIME : %04d-%02d-%02d %02d:%02d:00 +0000", year+2000, month, day, hour, minute);
    printf("\n\n");
#endif
    
#if 0
    H2MeterRecordInfo *bleBgmRecord = [[H2MeterRecordInfo alloc] init];
    
    bleBgmRecord.smRecordDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", year+2000, month, day, hour, minute];
    bleBgmRecord.smRecordUnit = BG_UNIT;
    bleBgmRecord.smRecordValue_mmol = 0.0f;
    
    bleBgmRecord.smRecordValue_mg = value;
    
    
    tmpA = [self numberNormalize:srcData[22]];
    status = [self numberDeCodeNEW:tmpA];
    if (status > 0 && status < 7) {
        if ((status % 2) == 0) {
            bleBgmRecord.smRecordFlag = 'A';
        }else{
            bleBgmRecord.smRecordFlag = 'B';
        }
    }else{
        bleBgmRecord.smRecordFlag = 'N';
    }
    
    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bleBgmRecord.smRecordDateTime]) {
        bleBgmRecord.smRecordFlag = 'C';
    }
    return bleBgmRecord;
#else
    
    
    H2BgRecord *bleBgmRecord = [[H2BgRecord alloc] init];
    
    bleBgmRecord.recordType = RECORD_TYPE_BG;
    bleBgmRecord.meterUserId = 0;
    
    bleBgmRecord.bgDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", year+2000, month, day, hour, minute];
    bleBgmRecord.bgUnit = BG_UNIT;
    bleBgmRecord.bgValue_mmol = 0.0f;
    
    bleBgmRecord.bgValue_mg = value;
    
    
    tmpA = [self numberNormalize:srcData[22]];
    status = [self numberDeCodeNEW:tmpA];
    if (status > 0 && status < 7) {
        if ((status % 2) == 0) {
            bleBgmRecord.bgMealFlag = @"A";
        }else{
            bleBgmRecord.bgMealFlag = @"B";
        }
    }else{
        bleBgmRecord.bgMealFlag = @"N";
    }
    if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bleBgmRecord.bgDateTime]) {
        bleBgmRecord.bgMealFlag = @"C";
    }
    return bleBgmRecord;
#endif
}


#pragma mark - HELPER HELPER!! (NUMBERIC TRANSFER)
- (UInt8)dataTransfer:(UInt8)data
{
    UInt8 value = 0;
    switch (data) {
        case 0: value = 0xB3; break;
        case 1: value = 0xF3; break;
        case 2: value = 0x33; break;
        case 3: value = 0x73; break;
            
        case 4: value = 0xB2; break;
        case 5: value = 0xF2; break;
        case 6: value = 0x32; break;
        case 7: value = 0x72; break;
            
        case 8: value = 0xB1; break;
            
        case 9: value = 0xF1; break;
            
        case 10: value = 0xEF; break;
            
        case 11: value = 0x2F; break;
            
        case 12: value = 0x6F; break;
            
        case 13: value = 0xAE; break;
            
        case 14: value = 0xEE; break;
            
        case 15: value = 0x2E; break;
            
        default: break;
    }
    return value;
}

- (UInt8) numberNormalize:(UInt8) aCode
{
    UInt8 srcNumber = 0;
    
    srcNumber = aCode ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;
    return srcNumber;
}

// NEW DECODE
- (UInt8) numberDeCodeNEW:(UInt8)akCode
{
    unsigned char number = 0;
    unsigned char hiNibble = 0;
    unsigned char loNibble = 0;
    
    if ((akCode & 0x30) == 0x30) { // Number < 10
        hiNibble = akCode & 0xC0;
        //printf("... %02X\t", hiNibble);
        hiNibble >>= 6;
        //printf("... %02X\t", hiNibble);
        hiNibble ^= 0x2;
        //printf("... %02X\t", hiNibble);
        
        loNibble = 3 - (akCode & 0x03);
        
        number = (loNibble << 2) + hiNibble;
    }else{ // Number >= 10
        //hiNibble = aCode & 0xC0;
        //printf("... %02X\t", hiNibble);
        //hiNibble >>= 6;
        //printf("... %02X\t", hiNibble);
        //hiNibble ^= 0x2;
        //printf("... %02X\t", hiNibble);
        
        //loNibble = 3 - (aCode & 0x03) + 1;
        switch (akCode) {
            case 0xEF:
                number = 10;
                break;
                
            case 0x2F:
                number = 11;
                break;
                
            case 0x6F:
                number = 12;
                break;
                
            case 0xAE:
                number = 13;
                break;
                
            case 0xEE:
                number = 14;
                break;
                
            case 0x2E:
                number = 15;
                break;
                
            default:
                number = 255;
                break;
        }
    }
    return number;
}

- (UInt8)arkrayToAscii:(UInt8)ch
{
    UInt8 result = 0;
    if (ch >= 0x0A) {
        result = ch + 'A'- 0x0A;
    }else{
        result = ch + '0';
    }
    return result;
}

- (UInt8)arkrayToHex:(UInt8)ch
{
    UInt8 result = 0;
    if ((ch & 0xF0) == 0x40) { // A, B, C, D, E, F
        result = ch - 'A'+ 0x0A;
    }else{
        result = ch - '0';
    }
    return result;
}

- (void)h2ArkrayCmdNotFoundTask
{
    [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_ARKRAY_CMD_NOT_FOUND];
#ifdef DEBUG_BW
    DLog(@"ARKRAY COMMAND NOT FOUND");
#endif
}

#pragma mark - CALCULATE DYNAMIC KEY !!
- (void)calcDynamicaCmd:(Byte *)secret
{
    UInt8 slaveSrc[12] = {0};
    UInt8 masterSrc[12] = {0};
    memcpy(slaveSrc, secret, 12);
    memcpy(masterSrc, &secret[12], 12);
    
    UInt16 slaveAdd[6] = {0};
    UInt16 masterAdd[6] = {0};
    NSLog(@"\n");
    for (int i=0; i<6; i++) {
        slaveAdd[i] = (slaveSrc[2*i] << 4) + slaveSrc[2*i+1];
        masterAdd[i] = (masterSrc[2*i] << 4) + masterSrc[2*i+1];
#ifdef DEBUG_BW
        NSLog(@"SLAVE MASTER VALUE : %d, %02X, %02X", i, slaveAdd[i], masterAdd[i]);
#endif
    }
    
    int A1 = ((((UInt8) slaveAdd[0]) + slaveAdd[1]) + masterAdd[0]) & 255;
    int A2 = (((UInt8) slaveAdd[2]) + masterAdd[4]) & 255;
    int A3 = ((((UInt8) slaveAdd[3]) + masterAdd[2]) + masterAdd[5]) & 255;
    int A4 = (((UInt8) slaveAdd[4]) + masterAdd[3]) & 255;
    int A5 = (((UInt8) slaveAdd[5]) + masterAdd[1]) & 255;
    UInt8 K1 = ((((((UInt8) A1) + A2) + A3) + A4) + A5) & 255;
    UInt8 K2 = (K1 ^ 170) & 255;
    UInt8 K3 = (((((A2 << 2) ^ A1) ^ A3) ^ (A4 << 3)) ^ (A5 << 2)) & 255;
    UInt8 K4 = (K1 ^ K3) & 255;

#ifdef DEBUG_BW
    NSLog(@"\n");
    NSLog(@"K1 = %02X", K1);
    NSLog(@"K2 = %02X", K2);
    NSLog(@"K3 = %02X", K3);
    NSLog(@"K4 = %02X", K4);
#endif
    
    UInt8 data = 22;
    UInt16 tmpx = 0;
    UInt16 tmpy = 0;
    UInt16 tmpz = 0;
    UInt16 tmpw = 0;
    
    tmpx = [self rotateLeft:(data ^ K1) withKeta:4];
    tmpy = [self rotateLeft:(tmpx ^ K2) withKeta:3];
    tmpz = [self rotateLeft:(tmpy ^ K3) withKeta:5];
    tmpw = [self rotateLeft:(tmpz ^ K4) withKeta:2];
    //UInt8 dynamicCmd = (UInt8)(tmpw & 0xFF);
    
    _arkrayDynamicCmd = (UInt8)(tmpw & 0xFF);
#ifdef DEBUG_BW
    NSLog(@"****** THE CMD = %02X ******", _arkrayDynamicCmd);
#endif
    //if (_arkrayDynamicCmd > ARKRAY_DYNAMIC_OFFSET) {
    //    _arkrayHardwardInfoCmd = _arkrayDynamicCmd - ARKRAY_DYNAMIC_OFFSET;
    //}else{
    //    _arkrayHardwardInfoCmd = _arkrayDynamicCmd + ARKRAY_DYNAMIC_OFFSET;
    //}
}

- (UInt16) rotateLeft:(UInt16)data withKeta:(UInt16)Keta{
    UInt16 buffer = ((data + 255) + 1) & 255;
    UInt16 tmp = ((buffer >> (8 - Keta)) & 255);
    tmp &= 0x7FFF;
    return ((buffer << Keta) & 255) | tmp;//((buffer >>> (8 - Keta)) & 255);
}


+ (ArkrayGBlack *)sharedInstance
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


