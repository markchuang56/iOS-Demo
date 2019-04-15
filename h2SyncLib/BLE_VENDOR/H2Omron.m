//
//  H2Omron.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/8/23.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2Omron.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2AudioFacade.h"

#import "H2Config.h"
#import "H2Sync.h"
#import "H2DataFlow.h"
#import "H2AudioHelper.h"

#import "H2BleOad.h"
#import "H2BgmCable.h"

#import "OMRON_HEM-7280T.h"
#import "H2Records.h"

#import "H2LastDateTime.h"
#import "H2BleTimer.h"

#import "OMRON_HBF-254C.h"
#import "OMRON_HEM-7280T.h"
//#import "OMRON_HEM-6320T.h"

@interface H2Omron()
{
    NSMutableData *a0CmdData;
}

@end



@implementation H2Omron

- (id)init
{
    if (self = [super init]) {
        
        a0CmdData = [[NSMutableData alloc] init];
        //////////////////////
        // OMRON - HBF-254C,
        // OMRON - HEM-7280T
        _OMRON_Service_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_SERVICE_UUID];
        
        _OMRON_Characteristic_A0_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A0_CHARACTERISTIC_UUID];
        
        _OMRON_Characteristic_A1_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A1_CHARACTERISTIC_UUID];
        _OMRON_Characteristic_A2_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A2_CHARACTERISTIC_UUID];
        _OMRON_Characteristic_A3_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A3_CHARACTERISTIC_UUID];
        _OMRON_Characteristic_A4_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A4_CHARACTERISTIC_UUID];
        
        _OMRON_Characteristic_A5_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A5_CHARACTERISTIC_UUID];
        _OMRON_Characteristic_A6_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A6_CHARACTERISTIC_UUID];
        _OMRON_Characteristic_A7_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A7_CHARACTERISTIC_UUID];
        _OMRON_Characteristic_A8_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A8_CHARACTERISTIC_UUID];
        
        _OMRON_Characteristic_A9_UUID = [CBUUID UUIDWithString:OMRON_HEM_7280T_A9_CHARACTERISTIC_UUID];
        
        
        
        // OMRON Service
        _Omron_Service = nil;
        
        // OMRON Caracteristic
        _Omron_Characteristic_A0 = nil;
        
        _Omron_Characteristic_A1 = nil;
        _Omron_Characteristic_A2 = nil;
        _Omron_Characteristic_A3 = nil;
        _Omron_Characteristic_A4 = nil;
        
        _Omron_Characteristic_A5 = nil;
        _Omron_Characteristic_A6 = nil;
        _Omron_Characteristic_A7 = nil;
        _Omron_Characteristic_A8 = nil;
        
        _Omron_Characteristic_A9 = nil;
        
        _cmdLength = 0;
        _omronHemCmd = (Byte *)malloc(OMRRON_COMMAND_SIZE);
        _cmdTimeOutInterval = 1.0f;
        
        _recordTypeFilter = 0;
        _userIdFilter = 0;
        
        _omronDataToWrite = [[NSData alloc]init];
        _omronA0Buffer = (Byte *)malloc(OMRRON_BUFFER_SIZE);
        
        _omronDataLength = 0;
        _omronIndexArray = (Byte *)malloc(128);
        
        _omronDataBuffer = [[NSMutableData alloc] init];
        [_omronDataBuffer setLength:0];
        
        _dialogWillAppear = NO;
        _omronModeFlag = NO;
        
        _omronInputStage = NO;
        
        _bpFlag = 'N';
        _bwFlag = 'N';
        
        _parserCurrentTime = NO;
        _parserUserProfile = NO;
        _parserOrCollectRecord = NO;
        _normalCmdFlow = YES;
        _parserClearIndex = NO;
        
        _userIdStatus = 0;
        _userSetId = 0;
        
        _omronFail = NO;
        _a0NotifyYES = NO;
        _isHem7600TOrHbf = NO;
        
        _omronSerialNumber = [[NSString alloc] init];
        
        _tmpUserProfile = [[UserGlobalProfile alloc] init];
        
        _indexTimeAddr = 0;
        _currentTimeDataLength = 0;
        _hemTagAddr = 0;
        _hemTimeAddr = 0;
        
        _hbfProfileAddr = 0;
        
        _tag1RecordsAddr = 0;
        _tag2RecordsAddr = 0;
        _tag3RecordsAddr = 0;
        _tag4RecordsAddr = 0;
        
        _tmpIndexBuffer = (Byte *)malloc(8);
        
        _qtsForTag_1 = 0;
        _qtsForTag_2 = 0;
        _qtsForTag_3 = 0;
        _qtsForTag_4 = 0;
        
        _addrForTag_1 = 0;
        _addrForTag_2 = 0;
        _addrForTag_3 = 0;
        _addrForTag_4 = 0;
        
        _omronCmdLogArray = [[NSMutableArray alloc] init];
        _omronValueLogArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - HARDWARE INFORMATION
const UInt8 omron_GetHardwareInfo[] = {
    0x08, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x18
};

const UInt8 omronCmdF[] = {
    0x08, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07
};

/*
 #pragma mark - DEFAULT VALUE(TAG and TIME)
 const UInt8 userTag[] =
 {
 0x01, 0x00, 0xFF, 0x01,
 0xCA, 0x01,
 0x08, 0x48
 };
 */
#pragma mark - OM SN CHECKING
- (BOOL)omronCheckSerialNumber:(UInt8)uTag
{
    NSString *subScanKey = @"X";
    NSString *subSerialNumber = @"Y";
    
    // Get Records Command Process or Show Set User Id Dialog
    [H2SyncReport sharedInstance].didSendEquipInformation = NO;
    
    if ([H2Omron sharedInstance].setUserIdMode) {
        
        // Will Show User Tag Dialog
        [[H2Sync sharedInstance] sdkOmronUserTagStatus:uTag];
        
        [H2Omron sharedInstance].omronInputStage = YES;
        [H2Omron sharedInstance].parserFinished = YES;
        
        [[H2BleCentralController sharedInstance] h2BleSetDeviceSerialNumber:[H2Omron sharedInstance].omronSerialNumber];
    }else{
        if([[H2BleService sharedInstance].bleScanningKey length] < OMRON_NAME_LEN){
            _omronFail = YES;
        }
        
        if([[H2Omron sharedInstance].omronSerialNumber length] < OMRON_NAME_LEN){
            _omronFail = YES;
        }
        subScanKey= [[H2BleService sharedInstance].bleScanningKey substringWithRange:NSMakeRange(OMRON_MODEL_LOCATION, OMRON_MODEL_MAC_LEN)];
        subSerialNumber = [[H2Omron sharedInstance].omronSerialNumber substringWithRange:NSMakeRange(OMRON_MODEL_LOCATION, OMRON_MODEL_MAC_LEN)];
#ifdef DEBUG_LIB
        NSLog(@"SCAN KEY - %@", [H2BleService sharedInstance].bleScanningKey);
        NSLog(@"SCAN KEY SUB - %@", subScanKey);
        
        NSLog(@"SN OMRON - %@",[H2Omron sharedInstance].omronSerialNumber);
        NSLog(@"SN OMRON SUB - %@",subSerialNumber);
#endif
        if ([subSerialNumber isEqualToString:subScanKey]) {
            
            [H2SyncReport sharedInstance].didSendEquipInformation = YES;
            [H2Omron sharedInstance].parserFinished = YES;
        }else{
            _omronFail = YES;
            
            if ([H2SyncReport sharedInstance].didSendEquipInformation) {
                [H2SyncReport sharedInstance].didSendEquipInformation = NO;
#ifdef DEBUG_LIB
                DLog(@"METER INFO ... (ERROR)");
#endif
            }
        }
    }
    
    if(_omronFail){
        [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_NOT_FOUND];
    }
    return _omronFail;
}

#pragma mark - GET CURRENT TIME And RECCORDS STATUS
- (void)omronGetIndexCurrentTime
{
#ifdef DEBUG_LIB
    NSLog(@"CT ADDR %04X", [H2Omron sharedInstance].indexTimeAddr);
#endif
    UInt8 getCtTmp[8] = {0};
    UInt8 crcTmp = 0;
    [H2Omron sharedInstance].parserCurrentTime = YES;
    
    getCtTmp[0] = OM_NORMAL_CMDBUF_LEN;
    getCtTmp[1] = OM_FLASH_AREA;
    getCtTmp[2] = OM_READ_FLASH;
    
    getCtTmp[3] = ([H2Omron sharedInstance].indexTimeAddr & 0xFF00)>>8;
    getCtTmp[4] = [H2Omron sharedInstance].indexTimeAddr & 0xFF;
    
    getCtTmp[5] = _currentTimeDataLength;
    
    crcTmp = 0;
    for (int i=0; i<getCtTmp[0]-1; i++) {
        crcTmp ^= getCtTmp[i];
    }
    getCtTmp[getCtTmp[0]-1] = crcTmp;
    memcpy([H2Omron sharedInstance].omronHemCmd, getCtTmp, [H2Omron sharedInstance].cmdLength);
    
}


///////////////
#pragma mark - OMRON NOTIFY
- (void)hem7600TNotify:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_LIB
    NSLog(@"7600T NOTIFY - %@", characteristic);
#endif
    
    // Notification ... TO DO ....
    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A0_UUID]){
#ifdef DEBUG_LIB
        NSLog(@"7600T NOTIFY 0 - %@", characteristic);
#endif
        if([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_7600T ||
           [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HBF_256T ||
           [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HBF_254C){
            _isHem7600TOrHbf = YES;
        }
        
        if (characteristic.isNotifying) {
            _a0NotifyYES = YES;
            _currentTimeDataLength = HEM_GCT_DATA_LEN;
            switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                case SM_BLE_OMRON_HEM_7280T:
                case SM_BLE_OMRON_HEM_7600T:
                    [H2Omron sharedInstance].indexTimeAddr = HEM_7280T_GIDXCT_ADDR;
                    [H2Omron sharedInstance].hemTagAddr = HEM_7280T_SIDXTAG_ADDR;
                    [H2Omron sharedInstance].tag1RecordsAddr = HEM_7280T_RECORD1_ADDR;
                    [H2Omron sharedInstance].tag2RecordsAddr = HEM_7280T_RECORD2_ADDR;
                    break;
                    
                case SM_BLE_OMRON_HEM_6320T:
                case SM_BLE_OMRON_HEM_6324T:
                    [H2Omron sharedInstance].indexTimeAddr = HEM_6320T_GIDXCT_ADDR;
                    [H2Omron sharedInstance].hemTagAddr = HEM_6320T_SIDXTAG_ADDR;
                    [H2Omron sharedInstance].tag1RecordsAddr = HEM_6320T_RECORD1_ADDR;
                    [H2Omron sharedInstance].tag2RecordsAddr = HEM_6320T_RECORD2_ADDR;
                    break;
                    
                case SM_BLE_OMRON_HBF_254C:
                case SM_BLE_OMRON_HBF_256T:
                    _currentTimeDataLength = HBF_GCT_DATA_LEN;
                    [H2Omron sharedInstance].indexTimeAddr = HBF_254C_GIDXCT_ADDR;
                    [H2Omron sharedInstance].hbfProfileAddr = HBF_254C_PROFILE_ADDR;
                    
                    _hemTagAddr = HBF_254C_SIDX_ADDR;
                    [H2Omron sharedInstance].tag1RecordsAddr = HBF_254C_RECORD1_ADDR;
                    [H2Omron sharedInstance].tag2RecordsAddr = HBF_254C_RECORD2_ADDR;
                    [H2Omron sharedInstance].tag3RecordsAddr = HBF_254C_RECORD3_ADDR;
                    [H2Omron sharedInstance].tag4RecordsAddr = HBF_254C_RECORD4_ADDR;
                    break;
                    
                default:
                    break;
            }
            
            if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6324T || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6320T)
            {
                [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A5];
                return;
            }
            
            if(_isHem7600TOrHbf){
                // A0 -> YES, A5, A6, A7, A8
                [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A5];
#ifdef DEBUG_LIB
                NSLog(@"FOR HBF-256T CHECKING ...");
#endif
            }else{
                // A0 -> YES, A0->Start
                [[H2Omron sharedInstance] OmronStartFromA0];
            }
        }
        return;
    }
    
    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A5_UUID]){
#ifdef DEBUG_LIB
        NSLog(@"7600T NOTIFY 5 - %@", characteristic);
#endif
        [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A6];
    }
    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A6_UUID]){
#ifdef DEBUG_LIB
        NSLog(@"7600T NOTIFY 6 - %@", characteristic);
#endif
        [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A7];
    }
    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A7_UUID]){
#ifdef DEBUG_LIB
        NSLog(@"7600T NOTIFY 7 - %@", characteristic);
#endif
        [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A8];
    }
    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A8_UUID]){
#ifdef DEBUG_LIB
        NSLog(@"7600T NOTIFY 8 - %@", characteristic);
        DLog(@"Notification successfully FOR OMRON!! %@ BEGIN", characteristic);
#endif
        if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6324T || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6320T)
        {
            [[H2Omron sharedInstance] OmronStartFromA0];
            return;
        }
        if (_a0NotifyYES) {// HEM-7600T, HBF
            // A0 -> Start
            [[H2Omron sharedInstance] OmronStartFromA0];
        }else{
            if ([H2BleService sharedInstance].blePairingStage){
                _setUserIdMode = YES;
            }else{
                _setUserIdMode = NO;
            }
            // Get Hardware Info for 7280T, 6320T, 6324T and 7600T
            [NSTimer scheduledTimerWithTimeInterval:CMD_INTERVAL_A1 target:self selector:@selector(omronGetHardwareInfo) userInfo:nil repeats:NO];
#ifdef DEBUG_LIB
            DLog(@"DO ANYTHING .... FOR OMRON");
#endif
        }
    }
    
#ifdef DEBUG_LIB
    DLog(@"HEM-6320T or (7600T) NOTIFICATION");
#endif
}





- (void)OmronStartFromA0
{
    _userIdStatus = 0;
    _userSetId = 0;
    
    _qtsForTag_1 = 0;
    _qtsForTag_2 = 0;
    _qtsForTag_3 = 0;
    _qtsForTag_4 = 0;
    
    _omronCmdSel = HBF_CMD_4;
    
    _omronInputStage = NO;
    _parserFinished = NO;
    _parserHardwareInfo = NO;
    _parserCurrentTime = NO;
    _parserUserProfile = NO;
    
    _parserOrCollectRecord = NO;
    _parserSetCurrentTime = NO;
    _parserSetTagProfile = NO;
    _parserClearIndex = NO;
    
    [_omronDataBuffer setLength:0];
    
    NSData *dataToWrite = [[NSData alloc]init];
    
    unsigned char cmdBuffer[] = {0x02};
    dataToWrite = [NSData dataWithBytes:cmdBuffer length:sizeof(cmdBuffer)];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A0 type: CBCharacteristicWriteWithResponse];
#ifdef DEBUG_OMRON
    DLog(@"OMRON START --  %@, %02X, %02X", dataToWrite, _userIdFilter, [H2Records sharedInstance].equipUserIdFilter);
#endif
}


#pragma mark - OMRON HEM GET RECORD
- (void)omronHemBpGetRecord:(UInt16)index
{// 0x08, 0x01, 0x00, 0x08,     0x24, 0x0E, 0x00, 0x2B // INDEX 1
    UInt16 address = 0;
    UInt8 hemCmdBuffer[8] = {0};
    
    hemCmdBuffer[0] = OM_NORMAL_CMDBUF_LEN;
    hemCmdBuffer[1] = OM_FLASH_AREA;
    hemCmdBuffer[2] = OM_READ_FLASH;
    
    hemCmdBuffer[5] = BP_RECORD_LEN;
    
    address = _tag1RecordsAddr + (index + [H2Records sharedInstance].currentUser * BP_RECORDS_MAX) * BP_RECORD_LEN;
    
    hemCmdBuffer[3] = (address & 0xFF00)>>8;
    hemCmdBuffer[4] = address & 0xFF;
    
#ifdef DEBUG_OMRON
    DLog(@"BP UID AND INDEX %02X, %d", [H2Records sharedInstance].currentUser, index);
#endif
    
    for (int i=0; i<7; i++) {
        hemCmdBuffer[7] ^= hemCmdBuffer[i];
#ifdef DEBUG_OMRON
        DLog(@"HEM RECORD COMD %d and %02X == %02X", i, hemCmdBuffer[i], hemCmdBuffer[7]);
#endif
    }
    memcpy(_omronHemCmd, hemCmdBuffer, _cmdLength);
}

#pragma mark - OMRON HBF GET RECORD
- (void)omronHbfBwGetRecord:(UInt16)index
{
#ifdef DEBUG_BW
    DLog(@"HBF-254C BW CUR USER %02X, and IDX %d", [H2Records sharedInstance].currentUser, index);
#endif
    UInt16 address = 0;
    UInt8 hbfCmdBuffer[8] = {0};
    
    hbfCmdBuffer[0] = OM_NORMAL_CMDBUF_LEN;
    hbfCmdBuffer[1] = OM_FLASH_AREA;
    hbfCmdBuffer[2] = OM_READ_FLASH;
    
    hbfCmdBuffer[5] = HBF254C_RECORD_LENGTH;
    
    address = [H2Omron sharedInstance].tag1RecordsAddr + index * HBF254C_RECORD_LENGTH;
    address += ([H2Records sharedInstance].currentUser * HBF254C_RECORD_LENGTH * BW_RECORDS_MAX);
    
    hbfCmdBuffer[3] = (address & 0xFF00)>>8;
    hbfCmdBuffer[4] = address & 0xFF;
    
    for (int i=0; i<7; i++) {
        hbfCmdBuffer[7] ^= hbfCmdBuffer[i];
#ifdef DEBUG_BW
        DLog(@"254C NEW RECORD COMD %d and %02X == %02X", i, hbfCmdBuffer[i], hbfCmdBuffer[7]);
#endif
    }
    memcpy(_omronHemCmd, hbfCmdBuffer, _cmdLength);
}


- (UInt8)omronCmdFlowTimerTask
{
#ifdef DEBUG_OMRON
    DLog(@"OMRON COMMAND FLOW TIME OUT  TASK");
#endif
    UInt8 omronErrCode = 0;
    omronErrCode = FAIL_SYNC;
    return omronErrCode;
}

- (void)h2OmronDataHandling:(CBCharacteristic *)characteristic
{
    _omronFail = NO;
    [_omronDataBuffer appendData:characteristic.value];
    memcpy(_omronA0Buffer, [_omronDataBuffer bytes], _omronDataBuffer.length);
    if ([characteristic.UUID isEqual:_OMRON_Characteristic_A0_UUID]) {
        [self h2OmronA0CmdFlow];
    }else{
        _omronDataLength = _omronA0Buffer[0];
        if (_omronCmdSel == HBF_CMD_5) {
            [self omronCommandIssue:OM_VALUE_LOG withData:_omronA0Buffer andLength:_omronDataLength];
        }
        if (_omronDataLength != 0 && _omronDataLength <= [_omronDataBuffer length]) {
            [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        }else{
            return;
        }
        
        if ([H2Omron sharedInstance].omronDataLength == 8 && [H2Omron sharedInstance].omronA0Buffer[1] == 0x8F) {
            if ([H2BleService sharedInstance].blePairingStage) {
                [[H2BleCentralController sharedInstance] H2ReportBleDeviceTimeOut];
            }else{
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }
            [H2BleService sharedInstance].bleNormalDisconnected = YES;
#ifdef DEBUG_OMRON
            DLog(@"OMRON NORMAL FINISHED");
#endif
            return;
        }
        [self h2OmronA1DataProcess];
        
        if (_omronFail) {
            [H2BleService sharedInstance].bleNormalDisconnected = YES;
            return;
        }
        
        if (![H2SyncReport sharedInstance].didSyncRecordFinished) {
            //float timeInterval = BLE_RECORD_INTERVAL;
            _cmdTimeOutInterval = BLE_RECORD_INTERVAL;
            if (_omronInputStage) {
                _omronInputStage = NO;
                //timeInterval = OMRON_REGISTER_INTERVAL;
                _cmdTimeOutInterval = OMRON_REGISTER_INTERVAL;
            }
            //[[H2BleTimer sharedInstance] h2SetBleTimerTask:timeInterval taskSel:BLE_TIMER_OMRON_CMD_FLOW];
        }
    }
}

- (void)omronGetHardwareInfo
{
#ifdef DEBUG_LIB
    NSLog(@"OMRON A1 NEW - CMD FLOW - 4");
#endif
    [H2Omron sharedInstance].parserHardwareInfo = YES;
    [[H2Omron sharedInstance].omronDataBuffer setLength:0];
    
    [self omronCommandIssue:OM_COMMAND_LOG withData:(Byte *)omron_GetHardwareInfo andLength:sizeof(omron_GetHardwareInfo)];
    
    NSData *dataHardwareInfo = [[NSData alloc]init];
    dataHardwareInfo = [NSData dataWithBytes:omron_GetHardwareInfo length:sizeof(omron_GetHardwareInfo)];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataHardwareInfo forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A1 type: CBCharacteristicWriteWithResponse];
    
    [H2Omron sharedInstance].omronCmdSel = HBF_CMD_5;
}

- (void)h2OmronA1DataProcess
{
#ifdef DEBUG_LIB
    NSLog(@"OM - XXX DATA READY ? %02X > %02X", _omronDataLength, (int)[_omronDataBuffer length]);
#endif
    if (_omronDataLength > [_omronDataBuffer length]) {
        //NSLog(@"OM - XXX DATA NOT READY!!");
        return;
    }
    if ([H2DataFlow sharedDataFlowInstance].equipId & BLE_BP_EQUIP) {
        [[OMRON_HEM_7280T sharedInstance] h2OmronHem7280TDataProcess];
    }else if ([H2DataFlow sharedDataFlowInstance].equipId & BLE_BW_EQUIP){
        [[OMRON_HBF_254C sharedInstance] h2OmronHbf254CDataProcess];
    }else{
        // ERROR HERE
    }
}

- (void)h2OmronA0CmdFlow
{
    BOOL sendOmronA0Cmd = NO;
    BOOL omronA0Error = NO;
    UInt8 errCode = FAIL_BLE_OMRON_PAIRCANCEL;
    unsigned char cmdBuffer[17] = {0x0};
    unsigned char a0Tmp[] = {
        0x00,
#if 0
        // NEW For HEM-7600T test
        0xD9, 0x67, 0xE3, 0xCE, 0xB1, 0x40, 0x43, 0xD3,
        0xBF, 0xAB, 0xEE, 0x3A, 0xFF, 0x04, 0xD4, 0x5A
#else
        // OLD
        0x3c, 0x27, 0x48, 0xb5, 0xf9, 0xac, 0x41, 0x7a,
        0x94, 0xa3, 0xc0, 0x84, 0x3d, 0x16, 0x54, 0xbb
#endif
    };
    
    
    NSData *dataToWrite = [[NSData alloc]init];
    [a0CmdData setLength:0];
    
    switch (_omronA0Buffer[0]) {
        case 0x82:
            _parserCurrentTime = NO;
            switch (_omronA0Buffer[1]) {
                case 0x0F: // Not Paired
                    if (!_dialogWillAppear) {
                        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
                        [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_DIALOG_INTERVAL taskSel:BLE_TIMER_PIN_MODE];
                    }
                    _dialogWillAppear = YES;
                    // case SM_BLE_OMRON_HEM_6324T: ????
                    //if (![H2BleService sharedInstance].blePairingStage && [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6320T) { // 6320T Only
                    if (![H2BleService sharedInstance].blePairingStage && [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_7600T) { // 7600T TEST
                        
                        // CLEAR READ SN TIMER
                        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
#ifdef DEBUG_LIB
                        NSLog(@"HEM-7600T RETURN");
#endif
                        return;
                    }
                    
                    sendOmronA0Cmd = YES;
                    cmdBuffer[0] = 0x02;
                    dataToWrite = [NSData dataWithBytes:cmdBuffer length:1];
                    a0CmdData = [NSMutableData dataWithBytes:cmdBuffer length:1];
                    break;
                    
                case 0x00: // Has Paired or successful
                    sendOmronA0Cmd = YES;
                    _dialogWillAppear = NO;
                    
                    a0Tmp[0] = 1;
                    if (_setUserIdMode) {
                        a0Tmp[0] = 0;
                    }
                    [self omronCommandIssue:OM_COMMAND_LOG withData:a0Tmp andLength:17];
                    dataToWrite = [NSData dataWithBytes:a0Tmp length:17];
                    a0CmdData = [NSMutableData dataWithBytes:a0Tmp length:17];
                    break;
                    
                case 0x01: // ERROR
                case 0x08: // Canncel at pairing mode for 7200T, 7280T time out at Pairing
                default:
                    [self omronCommandIssue:OM_VALUE_LOG withData:_omronA0Buffer andLength:2];
                    omronA0Error = YES;
                    if (_dialogWillAppear) {
                        errCode = FAIL_BLE_INSUFFICIENT_AUTHENTICATION;
                    }else{ // No Pair Dialog, meter remove pairing
                        errCode = FAIL_BLE_PAIR_TIMEOUT;
                    }
                    break;
                    
            }
            break;
            
        case 0x80:
        case 0x81:
            [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:OMRON_MODE_INTERVAL taskSel:BLE_TIMER_OMRON_MODE];
            [self omronCommandIssue:OM_VALUE_LOG withData:_omronA0Buffer andLength:2];
            switch (_omronA0Buffer[1]) {
                case 0x00:
                case 0x01:
                    _omronCmdSel = HBF_CMD_4;
                    if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6324T || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_6320T)
                    {
                        [NSTimer scheduledTimerWithTimeInterval:CMD_INTERVAL_A1 target:self selector:@selector(omronGetHardwareInfo) userInfo:nil repeats:NO];
                        return;
                    }
                    // Get Hardware Info for 254C, 255T/256T (HBF)
                    if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HBF_256T ||
                        [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HBF_254C){
                        [NSTimer scheduledTimerWithTimeInterval:CMD_INTERVAL_A1 target:self selector:@selector(omronGetHardwareInfo) userInfo:nil repeats:NO];
                        return;
                    }
                    
                    // A0 -> set nofity NO
                    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:NO forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A0];
                    
                    // A5 -> set nofity YES, for 7280T, 6320T, 6324T and 7600T
                    _a0NotifyYES = NO;
                    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A5];
                    /*
                    if([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_7600T) {
                        [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A5];
                    }else{
                        // For 6324T TEST ...
                        [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A5];
                    }
                     */
                    return;
                    
                default: // ERROR
                    omronA0Error = YES;
                    if (!_setUserIdMode) {
                        errCode = FAIL_SYNC;
                    }
                    break;
            }
            break;
            
        default: // ERROR
            omronA0Error = YES;
            break;
    }
#ifdef DEBUG_LIB
    if ([H2BleService sharedInstance].bleDevInList) {
        if (_omronA0Buffer[0] == 0x81 && _omronA0Buffer[1] == 0x01) {
            DLog(@"OM - WILL NO DIALOG");
        }
    }
#endif
    [[H2Omron sharedInstance].omronDataBuffer setLength:0];
    
    if (omronA0Error) {
        // CLEAR READ SN TIMER
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [[H2BleCentralController sharedInstance] h2BleConnectReport:errCode];
    }else{
        if (sendOmronA0Cmd) {
#ifdef DEBUG_OMRON
            DLog(@"DATA A0 IS %@ NEW NEW INIT", dataToWrite);
            DLog(@"OMRON CHAR DATA A0 -- (WILL) WRITE CMD IDX DEF %d", _omronCmdSel);
#endif
            [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(hem7600T_A0Cmd) userInfo:nil repeats:NO];
        }
    }
}

- (void)hem7600T_A0Cmd
{
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:a0CmdData forCharacteristic:_Omron_Characteristic_A0 type: CBCharacteristicWriteWithResponse];
}

#pragma mark - OMRON HEM GET RECORDS COMMAND
- (BOOL)omronHemRecordCmdProcess
{
#ifdef DEBUG_LIB
    NSLog(@"OM-FILTER %02X, Qt's = %d, Qt's = %d", _userIdFilter, _qtsForTag_1, _qtsForTag_2);
#endif
    BOOL goToNextFlow = NO;
    BOOL didAnyTagEnding = NO;
    
    if (_userIdFilter & USER_TAG1_MASK) {
        [H2Records sharedInstance].currentUser = NX_TAG_1;
        if (_qtsForTag_1 > 0) {
            _qtsForTag_1--;
            [self omronHemBpGetRecord:_omronIndexArray[_qtsForTag_1]];
        }else{ // USER 1 Zero data
            didAnyTagEnding = YES;
#ifdef DEBUG_BP
            DLog(@"USER 1 NO DATA");
#endif
        }
    }else if ([H2Omron sharedInstance].userIdFilter & USER_TAG2_MASK){
        [H2Records sharedInstance].currentUser = NX_TAG_2;
        if (_qtsForTag_2 > 0) {
            _qtsForTag_2--;
            [self omronHemBpGetRecord:_omronIndexArray[_qtsForTag_2]];
        }else{ // USER 2 Zero data
            didAnyTagEnding = YES;
#ifdef DEBUG_BP
            DLog(@"USER 2 NO DATA");
#endif
        }
    }else{
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        _omronCmdSel++;
        _normalCmdFlow = YES;
        _parserOrCollectRecord = NO;
        _parserClearIndex = YES;
        goToNextFlow = YES;
    }
    
    
    if (didAnyTagEnding) {
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [self hemGoToNextUser:[H2Records sharedInstance].currentUser];
        goToNextFlow = YES;
    }
    
    return goToNextFlow;
}

- (void)omronIndexCmdProcess
{
    UInt8 crcTmp = 0;
    UInt8 indexTmp[OM_MAX_CMDBUF_LEN] = {0};
    
    _cmdLength = OM_MAX_CMDBUF_LEN;
    indexTmp[0] = _cmdLength;
    indexTmp[1] = OM_FLASH_AREA;
    indexTmp[2] = OM_WRITE_FLASH;
    
    // HBF-254C YES!!
    indexTmp[3] = (_hemTagAddr & 0xFF00)>>8;
    indexTmp[4] = _hemTagAddr & 0xFF;
    
    indexTmp[5] = OM_INDEX_DATA_LEN;
#ifdef DEBUG_LIB
    for(int i=0; i<8; i++){
        NSLog(@"DEBUG %d and %02X", i, _tmpIndexBuffer[i]);
    }
#endif
    memcpy(&indexTmp[6], _tmpIndexBuffer, OM_INDEX_DATA_LEN);
    
    for (int i=0; i<_cmdLength-1; i++) {
        crcTmp ^= indexTmp[i];
    }
    indexTmp[15] = crcTmp;
    memcpy(_omronHemCmd, indexTmp, _cmdLength);
}

- (void)omronGoToHemA1CmdFlow
{
    [[OMRON_HEM_7280T sharedInstance] h2OmronHem7280TA1CmdFlow];
}

#pragma mark - OMRON HEM RECORDS PARSER
- (void)omronHemRecordsParser
{
    Byte *srcRecord = (Byte *)malloc(8);
    [H2Omron sharedInstance].parserFinished = YES;
    BOOL didAnyTagEnding = NO;
    
    memcpy(srcRecord, &[H2Omron sharedInstance].omronA0Buffer[BP_RECORD_OFFSET], 8);
#ifdef DEBUG_BP
    DLog(@"CURRENT USER == %d", [H2Records sharedInstance].currentUser);
#endif
    [H2Records sharedInstance].bpTmpRecord = [self hemRecord:srcRecord];
    
    switch ([H2Records sharedInstance].currentUser) {
        case NX_TAG_1:
            if (_qtsForTag_1 == 0) {
                didAnyTagEnding = YES;
            }
            break;
            
        case NX_TAG_2:
            if (_qtsForTag_2 == 0) {
                didAnyTagEnding = YES;
            }
            break;
            
        default:
            break;
    }
    
    if ([H2Omron sharedInstance].bpFlag != 'C') {
        if (![[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:[H2Records sharedInstance].bpTmpRecord.bpDateTime]) {
            if ([[H2SyncReport sharedInstance] h2SyncBpDidGreateThanLastDateTime]) {
                [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                _reportIndex++;
#ifdef DEBUG_BP
                DLog(@"HEM INDEX = %d, CURRENT USER %d", [H2Omron sharedInstance].reportIndex, [H2Records sharedInstance].currentUser);
#endif
                [H2Records sharedInstance].bpTmpRecord.bpIndex = [H2Omron sharedInstance].reportIndex;
                [H2Records sharedInstance].bpTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
                [H2Records sharedInstance].currentDataType = RECORD_TYPE_BP;
                [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bpTmpRecord];
            }else{
                didAnyTagEnding = YES;
            }
        }
#ifdef DEBUG_BP
    }else{
        NSLog(@"HEM == C");
#endif
    }
    
    if (didAnyTagEnding) {
        [self hemGoToNextUser:[H2Records sharedInstance].currentUser];
    }
#ifdef DEBUG_BP
    DLog(@"RECORD -- DECODE ENDING");
#endif
}

#pragma mark - HEM GO TO NEXT TAG
- (void)hemGoToNextUser:(UInt8)currentTag
{
    [H2Omron sharedInstance].reportIndex = 0;
    
    [self clearHemTagIndex:currentTag];
    
    // Remove Current User Flag
    [H2Omron sharedInstance].userIdFilter ^= (1 << currentTag);
    
    // Go To Next User
    [H2Records sharedInstance].currentUser++;
    if (_qtsForTag_2>0) {
        [self addrQtyProcess:_qtsForTag_2 withIdx:_addrForTag_2 omronTypeHem:YES];
    }
    if ([H2Records sharedInstance].currentUser <= HEM_MAX_TAG) {
        if([H2Omron sharedInstance].userIdFilter & (1 << [H2Records sharedInstance].currentUser)){
            [H2SyncReport sharedInstance].serverBpLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime:RECORD_TYPE_BP withUserId:(1 << ([H2Records sharedInstance].currentUser))];
        }
    }
}

- (H2BpRecord *)hemRecord:(Byte *)record
{
    H2BpRecord *tmpRecordInfo = [[H2BpRecord alloc] init];
    
    NSString *dateTime = [[NSString alloc] init];
    UInt8 bpDiastolic = 0;
    UInt16 bpSystolic = 0;
    
    UInt16 bpYear = 0;
    UInt8 bpHeardRate = 0;
    
    UInt8 bpMonth = 0;
    UInt8 bpDay = 0;
    UInt8 bpHour = 0;
    
    UInt8 bpMinute = 0;
    UInt8 bpSecond = 0;
    
    [H2Omron sharedInstance].bpFlag = 'N';
    if (record[0] == 0xFF && record[1] == 0xFF) {
        [H2Omron sharedInstance].bpFlag = 'C';
        return tmpRecordInfo;
    }
    
    bpDiastolic = record[0];
    bpSystolic = record[1] + BP_SYSTOLIC_OFFSET;
    
    bpYear = record[2] & 0x3F;// MAX 2063 YEAR
    bpYear += 2000;
    bpHeardRate = record[3];
    
    bpMonth = (record[4]  & 0x3C) >> 2;
    bpDay = record[4] & 0x03;
    bpDay <<= 3;
    bpDay += ((record[5] & 0xE0) >> 5);
    bpHour = record[5] & 0x1F;
    
    
    bpSecond = (record[7] & 0x3F);
#ifdef DEBUG_BP
    DLog(@"SEC %02X, %02X", bpSecond, record[7]);
#endif
    
    bpMinute = (record[6] &0x0F);
    bpMinute <<= 2;
#ifdef DEBUG_BP
    DLog(@"MIN %02X, %02X", bpMinute, record[6]);
#endif
    bpMinute += ((record[7] & 0xC0) >> 6);
    
    dateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", bpYear, bpMonth, bpDay, bpHour, bpMinute, bpSecond];
#ifdef DEBUG_BP
    DLog(@"BP_DATE_TIME %04d-%02d-%02d %02d:%02d:%02d +0000", bpYear, bpMonth, bpDay, bpHour, bpMinute, bpSecond);
    //DLog(@"\n");
    DLog(@"BP  %d / %d mmHg , %d HR", bpSystolic, bpDiastolic, bpHeardRate);
    DLog(@"\n\n");
#endif
    
    if (bpMinute >= 60) {
        [H2Omron sharedInstance].bpFlag = 'C';
    }
    if (bpSecond >= 60) {
        [H2Omron sharedInstance].bpFlag = 'C';
    }
    
    tmpRecordInfo.bpIsArrhythmia = NO;
    tmpRecordInfo.recordType = RECORD_TYPE_BP;
    tmpRecordInfo.bpDateTime = dateTime;
    
    tmpRecordInfo.bpSystolic = [NSString stringWithFormat:@"%d", bpSystolic];
    tmpRecordInfo.bpDiastolic = [NSString stringWithFormat:@"%d", bpDiastolic];
    tmpRecordInfo.bpHeartRate_pulmin = [NSString stringWithFormat:@"%d", bpHeardRate];
    
    return tmpRecordInfo;
}

#pragma mark - CLEAR TAG INDEX

- (void)clearHemTagIndex:(UInt8)user
{
    UInt8 offset = 0;
    if (user == 1) {
        offset = (1 << user);
    }
    // Clear Tag 1
    _tmpIndexBuffer[4+offset] = 0x80;
    _tmpIndexBuffer[5+offset] = 0x00;
}


- (void)clearHbfTagIndex:(UInt8)user
{
    //_tmpIndexBuffer[4+user] = 0x80;
    _tmpIndexBuffer[4+user] = 0x00;
}


- (void)omronBufferInit
{
    _cmdLength = OM_NORMAL_CMDBUF_LEN;
    [_omronDataBuffer setLength:0];
    for (int i=0; i<OMRRON_COMMAND_SIZE; i++) {
        _omronHemCmd[i] = 0;
    }
}

- (void)omronHardwareInfoParser
{
    [H2Omron sharedInstance].parserHardwareInfo = NO;
    [H2Omron sharedInstance].parserFinished = YES;
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [H2Omron sharedInstance].omronSerialNumber;
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2Omron sharedInstance].omronSerialNumber;
}

- (void)omronWriteA1Task
{
    NSData *dataToWrite = [[NSData alloc]init];
    if (_normalCmdFlow) {
        [H2Omron sharedInstance].omronCmdSel++;
#ifdef DEBUG_BP
        DLog(@"OMRON NORMAL COMMAND");
#endif
    }else{
#ifdef DEBUG_BP
        DLog(@"OMRON RECORD COMMAND");
#endif
    }
    
    dataToWrite = [NSData dataWithBytes:[H2Omron sharedInstance].omronHemCmd length:[H2Omron sharedInstance].cmdLength];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A1 type: CBCharacteristicWriteWithResponse];
    
    
#ifdef DEBUG_BP
    DLog(@"OMRON NEXT INDEX %02X", [H2Omron sharedInstance].omronCmdSel);
    DLog(@"OMRON DATA A1 CMD IS %@ ", dataToWrite);
#endif
}


- (void)omronSencondCommand
{
    NSData *dataToWrite = [[NSData alloc]init];
    dataToWrite = [NSData dataWithBytes:&_omronHemCmd[OM_MAX_CMDBUF_LEN] length:OM_MAX_CMDBUF_LEN];
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A2 type: CBCharacteristicWriteWithResponse];
#ifdef DEBUG_BP
    DLog(@"HEM STEP2 U-TAG WIRTE A2 92F4 -->  DATA:-- %@ ", dataToWrite);
#endif
}


- (void)cmdDone
{
    memcpy(_omronHemCmd, omronCmdF, _cmdLength);
}


- (void)addrQtyProcess:(UInt8)qty withIdx:(UInt8)addrIdx omronTypeHem:(BOOL)typeHem
{
    UInt8 diffIdx = 0;
    if (qty>addrIdx) {
        diffIdx = qty-addrIdx;
        if (typeHem) {
#ifdef DEBUG_BP
            NSLog(@"HEM");
#endif
            for (int i=diffIdx; i>0; i--) {
                _omronIndexArray[diffIdx-i] = BP_RECORD_IDX_MAX-i;
            }
        }else{
            //NSLog(@"HBF");
            for (int i=diffIdx; i>0; i--) {
#ifdef DEBUG_BP
                NSLog(@"HBF %d", i);
#endif
                _omronIndexArray[diffIdx-i] = BW_RECORD_IDX_MAX-i;
            }
        }
        if (addrIdx > 0) {
//            NSLog(@"ELSE ...");
            for (int i=0; i<addrIdx; i++) {
#ifdef DEBUG_BP
                NSLog(@"ELSE ... %d", i);
#endif
                _omronIndexArray[diffIdx+i] = i;
            }
        }
    }else{
#ifdef DEBUG_BP
        NSLog(@"OTHER");
#endif
        for (int i=qty; i>0; i--) {
            _omronIndexArray[i-1] = (--addrIdx);
        }
    }
#ifdef DEBUG_BP
    UInt8 cmdLen = qty;
    for (int i=0; i<cmdLen; i++) {
        NSLog(@"SND %02d, = %02X GOOD", i, _omronIndexArray[i]);
    }
#endif
    
#if 0
    if (qty>addrIdx) {
        diffIdx = qty-addrIdx;
        if (typeHem) {
            for (int i=0; i<diffIdx; i++) {
                _omronIndexArray[i] = BP_RECORD_IDX_MAX-diffIdx-i;
            }
        }else{
            for (int i=0; i<diffIdx; i++) {
                _omronIndexArray[i] = BW_RECORD_IDX_MAX-diffIdx-i;
            }
        }
        if (addrIdx > 0) {
            for (int i=0; i<addrIdx; i++) {
                _omronIndexArray[diffIdx+i] = i;
            }
        }
    }else{
        for (int i=qty; i>0; i--) {
            _omronIndexArray[i-1] = (--addrIdx);
        }
        /*
        for (int i=0; i<qty; i++) {
            _omronIndexArray[i] = addrIdx - qty + i;
        }
         */
    }
#endif
}

- (UInt8)omronNumericTransfer:(UInt8)data
{
    UInt8 target = 0;
    if (data >= 10) {
        target = 'A' + data - 10;
    }else{
        target = '0' + data;
    }
    return target;
}

- (void)omronCommandIssue:(UInt8)sel withData:(Byte *)data andLength:(UInt8)len
{
    unsigned char omBuffer[OM_LOG_LEN*2+1] = {0};
    UInt8 logLen = len;
    if (len > OM_LOG_LEN) {
        logLen = OM_LOG_LEN;
    }
    for (int i=0; i<logLen; i++) {
        omBuffer[2*i] = [self omronNumericTransfer:(data[i]>>4)&0x0F];
        omBuffer[2*i+1] = [self omronNumericTransfer:data[i]&0x0F];
    }
    
    NSString *stringC = [NSString stringWithUTF8String:(const char *)omBuffer];
    
    switch (sel) {
        case OM_VALUE_LOG:
            [_omronValueLogArray addObject:stringC];
            break;
            
        case OM_COMMAND_LOG:
        default:
            [_omronCmdLogArray addObject:stringC];
            break;
    }
}

+ (H2Omron *)sharedInstance
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


/////////////////////////////////////////////////////////
// HEM 6320T-Z, 6324T, 7280T, 7600T
/*
 unsigned char hemUserTagCmd[] = {
 0x16, 0x01, 0xC0, 0x0F,     0x9A, 0x0E, 0x80, 0x00,
 0x80, 0x00, 0x80, 0x00,     0x80, 0x00, 0x01, 0x00,
 
 0xFF, 0x01, 0xCA, 0x01,     0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
 };
 */
// Set Current Time
/*
 unsigned char hemTag1CurrentTimeCmd[] = {
 // 6320T
 0x12, 0x01, 0xc0, 0x0F,    0xAE, 0x0a, 0x08, 0x48
 , 0x02, 0x11    // 月年
 , 0x02, 0x0a    // 時日
 , 0x06, 0x16    // 秒分
 , 0x54, 0xc0    // 計算方法
 , 0x00, 0xdf
 
 , 0x00 , 0x00 ,    0x00 , 0x00 , 0x00 , 0x00
 ,0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
 };
 */
/*
 unsigned char hemCurrentTimeCmd[] = {
 0x12, 0x01, 0xc0, 0x0F,    0xAE, 0x0a, 0x08, 0x48
 , 0x02, 0x11    // 月年
 , 0x02, 0x0a    // 時日
 , 0x06, 0x16    // 秒分
 , 0x54, 0xc0    // 計算方法
 , 0x00, 0xdf
 
 , 0x00 , 0x00 ,    0x00 , 0x00 , 0x00 , 0x00
 ,0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
 };
 #if 0
 - (void)hem7600TNotify:(CBCharacteristic *)characteristic
 {
 NSLog(@"7600T NOTIFY - %@", characteristic);
 BOOL isHem7600T = NO;
 
 if([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_7600T){
 isHem7600T = YES;
 }
 
 // Notification ... TO DO ....
 if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A0_UUID]){
 NSLog(@"7600T NOTIFY 0 - %@", characteristic);
 if (characteristic.isNotifying) {
 a0NotifyYES = YES;
 _currentTimeDataLength = HEM_GCT_DATA_LEN;
 switch ([H2DataFlow sharedDataFlowInstance].equipId) {
 case SM_BLE_OMRON_HEM_7280T:
 case SM_BLE_OMRON_HEM_7600T:
 [H2Omron sharedInstance].indexTimeAddr = HEM_7280T_GIDXCT_ADDR;
 [H2Omron sharedInstance].hemTagAddr = HEM_7280T_SIDXTAG_ADDR;
 [H2Omron sharedInstance].tag1RecordsAddr = HEM_7280T_RECORD1_ADDR;
 [H2Omron sharedInstance].tag2RecordsAddr = HEM_7280T_RECORD2_ADDR;
 break;
 
 case SM_BLE_OMRON_HEM_6320T:
 case SM_BLE_OMRON_HEM_6324T:
 [H2Omron sharedInstance].indexTimeAddr = HEM_6320T_GIDXCT_ADDR;
 [H2Omron sharedInstance].hemTagAddr = HEM_6320T_SIDXTAG_ADDR;
 [H2Omron sharedInstance].tag1RecordsAddr = HEM_6320T_RECORD1_ADDR;
 [H2Omron sharedInstance].tag2RecordsAddr = HEM_6320T_RECORD2_ADDR;
 break;
 
 case SM_BLE_OMRON_HBF_254C:
 case SM_BLE_OMRON_HBF_256T:
 _currentTimeDataLength = HBF_GCT_DATA_LEN;
 [H2Omron sharedInstance].indexTimeAddr = HBF_254C_GIDXCT_ADDR;
 [H2Omron sharedInstance].hbfProfileAddr = HBF_254C_PROFILE_ADDR;
 
 _hemTagAddr = HBF_254C_SIDX_ADDR;
 [H2Omron sharedInstance].tag1RecordsAddr = HBF_254C_RECORD1_ADDR;
 [H2Omron sharedInstance].tag2RecordsAddr = HBF_254C_RECORD2_ADDR;
 [H2Omron sharedInstance].tag3RecordsAddr = HBF_254C_RECORD3_ADDR;
 [H2Omron sharedInstance].tag4RecordsAddr = HBF_254C_RECORD4_ADDR;
 break;
 
 default:
 break;
 }
 
 if(isHem7600T){
 [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A5];
 }else{
 [[H2Omron sharedInstance] OmronStartFromA0];
 }
 return;
 }else{
 a0NotifyYES = NO;
 NSLog(@"A0 is NOTHING ... START ....");
 [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A5];
 return;
 }
 }
 
 if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A5_UUID]){
 NSLog(@"7600T NOTIFY 5 - %@", characteristic);
 [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A6];
 }
 if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A6_UUID]){
 NSLog(@"7600T NOTIFY 6 - %@", characteristic);
 [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A7];
 }
 if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A7_UUID]){
 NSLog(@"7600T NOTIFY 7 - %@", characteristic);
 [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A8];
 }
 if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A8_UUID]){
 NSLog(@"7600T NOTIFY 8 - %@", characteristic);
 #ifdef DEBUG_LIB
 DLog(@"Notification successfully FOR OMRON!! %@ BEGIN", characteristic);
 #endif
 if (a0NotifyYES) {// HEM-7600T
 [[H2Omron sharedInstance] OmronStartFromA0];
 }else{
 if ([H2BleService sharedInstance].blePairingStage){
 _setUserIdMode = YES;
 }else{
 _setUserIdMode = NO;
 }
 
 [NSTimer scheduledTimerWithTimeInterval:CMD_INTERVAL_A1 target:self selector:@selector(omronGetHardwareInfo) userInfo:nil repeats:NO];
 #ifdef DEBUG_LIB
 DLog(@"DO ANYTHING .... FOR OMRON");
 #endif
 }
 }
 
 #ifdef DEBUG_LIB
 DLog(@"HEM-6320T or (7600T) NOTIFICATION");
 #endif
 }
 
 #endif
 */
