//
//  H2BleService.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/8/22.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>
// BLE
#import "H2BleEquipId.h"
#import "H2BleProfile.h"
#import "H2BleService.h"

// SYSTEM
#import "h2DebugHeader.h"
#import "h2CmdInfo.h"
#import "H2Config.h"

#import "H2Sync.h"
#import "H2CableFlow.h"
#import "H2DataFlow.h"
#import "H2Records.h"

#import "H2BleOad.h"
#import "H2BleBgm.h"

// BG Customer
#import "Fora.h"
#import "H2BleHmd.h"
#import "BleBtm.h"
#import "ARKRAY_GT-1830.h"
#import "Gm700sb.h"
#import "OneTouchPlusFlex.h"
#import "MicroLife.h"
#import "RocheSetInfo.h"
#import "AndUA651BLE.h"

// BG BLE
#import "ForaD40.h"

// BP Device
#import "OMRON_HEM-7280T.h"
//#import "OMRON_HEM-6320T.h"
#import "OMRON_HEM-9200T.h"

// BW Device
#import "OMRON_HBF-254C.h"
#import "ForaW310.h"

#import "BPMViewController.h"
#import "H2LastDateTime.h"

#import "H2BleTimer.h"


@implementation H2BleService{
    
}


- (id)init
{
    if (self = [super init]) {
        _didUseH2BLE = NO; // For HMD BLE Test , YES;
        
        _bleVendorNotifyDone = NO;
        _bleVendorRunning = NO;
        _blePeripheralIdle = NO;
        
        _normalFlowHasNofity = NO;
        
        _h2ForaW310BDataTemp = [[NSMutableData alloc] init];
        [_h2ForaW310BDataTemp setLength:0];
        
        _isBleCable = NO;
        _didBleCableFinished = NO;
        _isBleEquipment = NO;
        _didNeedMoreTimeForBlePairing = NO;
        _recordMode = NO;
        _isAudioSyncFlow = NO;
        
        _skipRecord = NO;
        
        _blePairingStage = NO;
        _bleSerialNumberStage = NO;
        
        _bleRecordStage = NO;
        _bleOADStage = NO;
        _bleDeleteRecords = NO;

        _bleScanningKey = @"";
        _bleSeverIdentifier = @"";
        
        _bleTempLocalName = @"";
        _bleLocalName = @"";
        _bleTempIdentifier = @"";
        _bleTempModel = @"";
        
        _bleCablePairing = NO;
        
        //_bgmNumber = 0;
        _bgmIndex = 0;
        
        _batteryLevel = -1;
        _batteryRawValue = 0;

        // BLE PERIPHERAL
        _h2ConnectedPeripheral = nil;
        _reconnectPeripheral = nil;
        
        _bleDevInList = NO;
        _bleConnected = NO;
        _bleNormalDisconnected = NO;
        _bleErrorHappen = NO;
        
        _blePairingModeFinished = NO;
        _bleMultiDeviceCanncel = NO;
        _bleScanMultiDevice = NO;
        _bleScanDeviceMax = 1;
        _bleScanDeviceCount = 0;
#ifdef DEBUG_LIB
        DLog(@"BLE SERVICE INIT");
#endif
    }
    return self;
}


+ (H2BleService *)sharedInstance
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

/***********************************************************************
 * @fn : GET VENDOR BLE BLOOD GLUCOSE RECORD,
 *
 *
 *
 **********************************************************************/
- (void)h2BleBgmGetQuantity
{
    [[H2BleBgm sharedInstance] h2BleBgmWriteTask:ACTION_NUMBER_OF_RECORDS];
}

- (void)h2BleBgmGetRecordsMoreThan:(UInt16)rdIndex
{
    [[H2BleBgm sharedInstance] h2BleBgmWriteTask:ACTION_GREATER_THAN];
}

- (void)h2GetVendorRecord
{
    if (_bleVendorRunning) {
        return;
    }
    _bleVendorRunning = YES;
    _bleRecordStage = YES;

    if ([H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_RecordAccessControlPoint != nil) {
        
        _skipRecord = NO;
        
#if 1
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
        DLog(@"MID %08X", (int)[H2DataFlow sharedDataFlowInstance].equipId);
        [[H2BleBgm sharedInstance] h2BleBgmWriteTask:ACTION_GREATER_THAN];
        //[[H2BleBgm sharedInstance] h2BleBgmWriteTask:ACTION_NUMBER_OF_RECORDS];
#else
        unsigned char cmdTemp[12] = {0};
        cmdTemp[0] = 1;
        cmdTemp[1] = 3; // GREATER_THAN_OR_EQUAL;
        cmdTemp[2] = 2; // USER_FACING_TIME
        
        cmdTemp[3] = 0xE0;
        cmdTemp[4] = 0x07;
        
        cmdTemp[5] = 0x0B;
        cmdTemp[6] = 0x0F;
        
        cmdTemp[7] = 0x0C;
        cmdTemp[8] = 0x04;
        cmdTemp[9] = 0x00;
        
        cmdTemp[10] = 0x00;
        cmdTemp[11] = 0x00;
        
        
        cmdTemp[0] = 6;
        cmdTemp[1] = 0; //
        
        NSData *dataToWrite = [[NSData alloc]init];
        
        // Write ...
        dataToWrite = [NSData dataWithBytes:cmdTemp length:02];
        
         [_h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_BleBgm_CHAR_RecordAccessControlPoint type:CBCharacteristicWriteWithResponse];
#endif
        
        
        //if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_BGM_TYSON_HT100) {
        //[[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        //[[H2BleTimer sharedInstance] h2SetBleTimerTask: BLE_BGM_INTERVAL taskSel:BLE_TIMER_BGM_MODE];
        //}
        

        
        
        
/*
 2016-11-16 18:48:12.500969 NorT[15965:9809556] DEBUG_FORA SRC index : 03 and Data : E0
 2016-11-16 18:48:12.501192 NorT[15965:9809556] DEBUG_FORA SRC index : 04 and Data : 07
 
 2016-11-16 18:48:12.501235 NorT[15965:9809556] DEBUG_FORA SRC index : 05 and Data : 0B
 2016-11-16 18:48:12.501278 NorT[15965:9809556] DEBUG_FORA SRC index : 06 and Data : 0F
 
 2016-11-16 18:48:12.501320 NorT[15965:9809556] DEBUG_FORA SRC index : 07 and Data : 0C
 2016-11-16 18:48:12.501362 NorT[15965:9809556] DEBUG_FORA SRC index : 08 and Data : 04
 2016-11-16 18:48:12.501404 NorT[15965:9809556] DEBUG_FORA SRC index : 09 and Data : 00
 
 */
        
        DLog(@"BGM Read Records ...");
        return;
    }
    
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
            [H2Omron sharedInstance].userIdFilter &= 0x0F;
            if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_CARESENS_EXT_B_FORA_D40) {
                if (([H2Omron sharedInstance].recordTypeFilter & 1) == 0) {
                    [ForaD40 sharedInstance].foraD40BgFinished = YES;
                    //NSLog(@"TYPE 1 == 0");
                }
                if (([H2Omron sharedInstance].recordTypeFilter & 2) == 0) {
                    [ForaD40 sharedInstance].foraD40BpFinished = YES;
                    //NSLog(@"TYPE 2 == 0");
                }
            }
            [[Fora sharedInstance] FORABleGetRecord];
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            [H2Omron sharedInstance].userIdFilter &= 0x1F;
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"FORA RECORD ...");
            DLog(@"****************************************************************/");
#endif
            [[Fora sharedInstance] FORABleGetRecord];
            break;
            
            
        case SM_BLE_CARESENS_EXT_C_BTM:
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"BTM RECORD");
            DLog(@"****************************************************************/");
#endif
            [BleBtm sharedInstance].btmRecordRunning = YES;
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
            [[BleBtm sharedInstance] h2BTMGetRecordInit];
            break;
        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
            [H2Omron sharedInstance].userIdFilter &= 0x01;
            [[OneTouchPlusFlex sharedInstance] flexCmdFlowSync];
            break;
            
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_6324T:
            [H2Omron sharedInstance].userIdFilter &= 0x03;
            [[OMRON_HEM_7280T sharedInstance] OMRON_Hem7280T_GetRecordInit];
            break;
            
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_7600T:
            [H2Omron sharedInstance].userIdFilter &= 0x01;
            [[OMRON_HEM_7280T sharedInstance] OMRON_Hem7280T_GetRecordInit];
            break;
            
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
            [H2Omron sharedInstance].userIdFilter &= 0x0F;
            [[OMRON_HBF_254C sharedInstance] OMRON_Hbf254C_GetRecordInit];
            break;
            
        case SM_BLE_OMRON_HEM_9200T:
            
            //j[OMRON_HEM_9200T sharedInstance].hem9200TRecordMode = YES;
            if ([OMRON_HEM_9200T sharedInstance].hem9200TRecordTimeOut) {
                [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
            }

#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"HEM-9200T RECORD");
            DLog(@"****************************************************************/");
#endif
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            //ARKRAY_RECORD_LOOP
            [[ArkrayGBlack sharedInstance] arkrayRecordModeTask];
            break;
            
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
            break;
            
        case SM_BLE_BIONIME_GM700SB:
            [Gm700sb sharedInstance].currentCmdSel = METHOD_NROFRECORD;
            [[Gm700sb sharedInstance] bioNimeGb700sbCmmand];
            // INIT, Enable Access Memory
            //[Gm700sb sharedInstance].currentCmdSel = METHOD_INIT;
            //[[Gm700sb sharedInstance] bioNimeGb700sbCmmand];
            break;
            
        case SM_BLE_GARMIN:
            break;
            
        case SM_BLE_MICRO_LIFE:
            [[MicroLife sharedInstance] mlCmdSync];
            break;
            
        case SM_BLE_AND_UA_651BLE:
            [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2BleProfile sharedBleProfileInstance].bleCharBPMeasurement];
            break;
            
        case SM_BLE_AND_UC_352BLE:
            // TO DO ...
            // while receive notify ...
            //[[OMRON_HEM_9200T sharedInstance] hem9200tSetRecordTimer];
            [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2BleProfile sharedBleProfileInstance].bleBws_CHAR_Measurement];
            break;
            
        default:
#ifdef DEBUG_LIB
            DLog(@"VENDOR H2 CABLE RECORD");
#endif
            break;
    }
}

/***********************************************************************
 * @fn : DELETE VENDOR BLE BLOOD GLUCOSE RECORD,
 *
 *
 *
 **********************************************************************/
- (void)h2DeleteVendorRecords
{
    if (_bleVendorRunning) {
        return;
    }
    _bleVendorRunning = YES;
    _bleRecordStage = YES;
    [H2Records sharedInstance].currentUser = 0;
    
    
    if ([H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_RecordAccessControlPoint != nil) { // FOR TEST
        
        _skipRecord = NO;
        
#if 1
        [[H2BleBgm sharedInstance] h2BleBgmWriteTask:ACTION_ALL_RECORDS];
#else
        unsigned char cmdTemp[12] = {0};
        cmdTemp[0] = 1;
        cmdTemp[1] = 3; // GREATER_THAN_OR_EQUAL;
        cmdTemp[2] = 2; // USER_FACING_TIME
        
        cmdTemp[3] = 0xE0;
        cmdTemp[4] = 0x07;
        
        cmdTemp[5] = 0x0B;
        cmdTemp[6] = 0x0F;
        
        cmdTemp[7] = 0x0C;
        cmdTemp[8] = 0x04;
        cmdTemp[9] = 0x00;
        
        cmdTemp[10] = 0x00;
        cmdTemp[11] = 0x00;
        
        
        cmdTemp[0] = 6;
        cmdTemp[1] = 0; //
        
        NSData *dataToWrite = [[NSData alloc]init];
        
        // Write ...
        dataToWrite = [NSData dataWithBytes:cmdTemp length:02];
        
        [_h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_BleBgm_CHAR_RecordAccessControlPoint type:CBCharacteristicWriteWithResponse];
#endif
        
        
        //if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_BGM_TYSON_HT100) {
        //[[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        //[[H2BleTimer sharedInstance] h2SetBleTimerTask: BLE_BGM_INTERVAL taskSel:BLE_TIMER_BGM_MODE];
        
        DLog(@"BGM DEL Records ...");
        return;
    }
}

/***********************************************************************
 * @fn : VENDOR BLE INI,
 *
 *
 *
 **********************************************************************/

#pragma mark - CULTOMER BLE INIT
- (void)vendorBLEInit
{
    _bleVendorRunning = NO;
    _bleVendorNotifyDone = NO;
    [H2Records sharedInstance].bgSkipRecords = NO;
    //j[OMRON_HEM_9200T sharedInstance].hem9200TRecordMode = NO;
    [OMRON_HEM_9200T sharedInstance].hem9200TRecordTimeOut = NO;
    
    
    [H2AudioAndBleCommand sharedInstance].newRecordAtFinal = NO;
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
        case SM_BLE_BGM_TRUE_METRIX:
        case SM_BLE_OMRON_HEM_9200T:
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            [H2AudioAndBleCommand sharedInstance].newRecordAtFinal = YES;
            break;
            
        default:
            break;
    }
    
#ifdef DEBUG_LIB
    DLog(@"THE EQUIPMENT ID IS %08X - METRIX", (int)[H2DataFlow sharedDataFlowInstance].equipId);
#endif
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
        case SM_BLE_BGM_TRUE_METRIX:
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"The UUID - BLE ACCU CHECK INIT");
            DLog(@"****************************************************************/");
#endif
            // Set Filter UUID
            [H2BleBgm sharedInstance];
            //[BleTrueMetrix sharedInstance];
#if 1
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleBgmServiceID;
#else
            _filterUUID = nil;
#endif
            break;

        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"The UUID FORA INIT");
            DLog(@"****************************************************************/");
#endif
//            _filterUUID = [CBUUID UUIDWithString:FORA_METER_SERVICE_UUID];
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleBgmServiceID;
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleBPServiceUUID;
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleHealthHermoServiceUUID;
            break;

        case SM_BLE_CARESENS_EXT_C_BTM:
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"The UUID BTM INIT");
            DLog(@"****************************************************************/");
#endif
            [BleBtm sharedInstance];
            _filterUUID = [CBUUID UUIDWithString:BTM_FIRST_SERVICE_ID];
            break;


        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"The UUID ONE TOUCH SELECT PLUS FLEX INIT");
            DLog(@"****************************************************************/");
#endif
            // Set Filter UUID
            //[H2BleBgm sharedInstance];
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID;
            break;

        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"The UUID OMRON INIT");
            DLog(@"****************************************************************/");
#endif
            //[H2Records sharedInstance].multiUsers = YES;
            [OMRON_HEM_7280T sharedInstance];
            _filterUUID = [H2Omron sharedInstance].OMRON_Service_UUID;
            //_filterUUID = nil;
            break;
            
        case SM_BLE_OMRON_HEM_9200T:
            [H2Records sharedInstance].dataTypeFilter = RECORD_TYPE_BP;
            [H2Records sharedInstance].equipUserIdFilter = USER_TAG1_MASK;
            [OMRON_HEM_7280T sharedInstance];
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleBPServiceUUID;
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            //... TO DO
            [ArkrayGBlack sharedInstance];
            _filterUUID = [ArkrayGBlack sharedInstance].Arkray_ServiceUUID;
            break;
            
            
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
#ifdef DEBUG_LIB
            DLog(@"/***************************************************************");
            DLog(@"The UUID HMD INIT");
            DLog(@"****************************************************************/");
#endif
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleBgmServiceID;
            break;
            
        case SM_BLE_BIONIME_GM700SB:
            _filterUUID = [Gm700sb sharedInstance].bioNimeServiceID;
            break;
            
        case SM_BLE_GARMIN:
            _filterUUID = nil;
            break;
            
        case SM_BLE_MICRO_LIFE:
            [H2Records sharedInstance].equipUserIdFilter = USER_TAG1_MASK;
            [H2AudioAndBleCommand sharedInstance].newRecordAtFinal = YES;
            _filterUUID = [MicroLife sharedInstance].mlF0ServiceID;
            break;
            
        case SM_BLE_AND_UA_651BLE:
            //_filterUUID = nil;
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleBPServiceUUID;
            break;
            
        case SM_BLE_AND_UC_352BLE:
            _filterUUID = [H2BleProfile sharedBleProfileInstance].bleBwsServiceID;
            break;
            
        default:
            _filterUUID = nil;
            break;
    }
#ifdef DEBUG_LIB
    DLog(@"The FILTER UUID  is %@", _filterUUID);
#endif
}

/***********************************************************************
 * @fn : DID DISCOVER PERIPHERAL,
 *       BLE DEVICE NAME CHECKING
 *
 *
 **********************************************************************/
- (BOOL)VENDidDiscoverPeripheral:(CBPeripheral *)peripheral withDevName:(NSString *)devName
{
    if (devName == nil) {
        return NO;
    }
    NSString *subBleEquipName = @"X";
    
#ifdef DEBUG_LIB
    DLog(@"Vendor Peripheral Name is %@ and %@", devName, peripheral.name);
    DLog(@"Vendor Peripheral ID %X", (int)[H2DataFlow sharedDataFlowInstance].equipId);
#endif
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
        case SM_BLE_OMRON_HEM_9200T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
            
            if ([devName length] == OMRON_NAME_LEN) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(OMRON_MODEL_LOCATION, OMRON_MODEL_LEN)];
            }else{
                // REPORT ERROR
            }
            break;
            
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
            // @"meter+01335497" // GUIDE
            // @"meter+00549938" // INSTANT
            if ([devName length] > 6) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 6)];
            }
            break;
            
        default:
            break;
    }
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
            if ( [devName isEqualToString:@"Accu-Chek"]){//} || [devName isEqualToString:@"meter+01335497"]) {
#ifdef DEBUG_LIB
                DLog(@"BLE ACCU CHECK -  NAME DONE");
#endif
                return YES;
            }
            break;
           
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
            if ( [subBleEquipName isEqualToString:@"meter+"]) {
#ifdef DEBUG_LIB
                DLog(@"BLE ACCU CHECK -  (GUID) - %@", subBleEquipName);
#endif
                return YES;
            }
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA:
            if ( [devName isEqualToString:@"FORA GD40"]) {
#ifdef DEBUG_LIB
                DLog(@"FORA NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
            if ( [devName isEqualToString:@"TAIDOC TD4286"]) {
#ifdef DEBUG_LIB
                DLog(@"FORA TAIDOC NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
            if ( [devName isEqualToString:@"FORA D40"]) {
                
#ifdef DEBUG_LIB
                DLog(@"FORA D40 NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
            if ( [devName isEqualToString:@"TNG"]) {
                
#ifdef DEBUG_LIB
                DLog(@"FORA TNG NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
            if ( [devName isEqualToString:@"TNG VOICE"]) {
                
#ifdef DEBUG_LIB
                DLog(@"FORA TNG NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
            if ( [devName isEqualToString:@"FORA P30 PLUS"]) {
                
#ifdef DEBUG_LIB
                DLog(@"FORA P30 PLUS NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            if ( [devName isEqualToString:@"FORA W310"]) {
#ifdef DEBUG_LIB
                DLog(@"FORA W310B NAME DONE");
#endif
                return YES;
            }
            break;
#if 0
        case SM_BLE_OMNIS_EXT_3_APEXBIO:
//            if ( [peripheral.name isEqualToString:@"GlucoLogAB123001"]) {
 //           if ( [peripheral.name isEqualToString:@"GlucoLogAB123003"]) {
            if ([devName length] > 8) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 8)];
            }
            if ( [subBleEquipName isEqualToString:@"GlucoLog"]) {
#ifdef DEBUG_LIB
                DLog(@"APEX BIO NAME DONE - %@", subBleEquipName);
#endif
                return YES;
            }
            break;
#endif
        case SM_BLE_CARESENS_EXT_C_BTM:
            if ( [devName isEqualToString:@"Biosys"]) {
#ifdef DEBUG_LIB
                DLog(@"BTM NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_BGM_TRUE_METRIX:
            // Local Name check ...
#ifdef DEBUG_LIB
            DLog(@"TRUE METRIX LOCAL NAME IS %@ - LN", devName);
#endif
            if ( [devName isEqualToString:@"NiproBGM"]) {
                return YES;
            }
            break;
            
        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
#ifdef DEBUG_LIB
            DLog(@"ONE TOUCH LOCAL NAME IS %@ - LN", devName);
#endif
            if ([devName length] > 8) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 8)];
            }
            if ( [subBleEquipName isEqualToString:@"OneTouch"]) {
                return YES;
            }
            break;
            
        case SM_BLE_OMRON_HEM_7280T:
            if ( [subBleEquipName isEqualToString:HEM7280T_MODEL]){
                [H2Omron sharedInstance].omronSerialNumber = devName;
#ifdef DEBUG_LIB
                DLog(@"OMRON_HEM_7280T NAME DONE");
#endif
                return YES;
            }
            break;
        case SM_BLE_OMRON_HEM_7600T:
            // BLE DEV NAME IS BLEsmart_0000001FEC21E590E056 // HEM-7600T-BK
            if ([subBleEquipName isEqualToString:HEM7600T_MODEL]){
                [H2Omron sharedInstance].omronSerialNumber = devName;
#ifdef DEBUG_LIB
                DLog(@"OMRON_HEM-7600T-BK NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_OMRON_HBF_254C:
            if ( [subBleEquipName isEqualToString:HBF254C_MODEL] || [subBleEquipName isEqualToString:HBF254C_MODEL_EX] ){
                [H2Omron sharedInstance].omronSerialNumber = devName;
#ifdef DEBUG_LIB
                DLog(@"OMRON_HMF_254C NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_OMRON_HBF_256T:
            // BLEsmart_0001000711051631F900 // HBF-256T
            if ( [subBleEquipName isEqualToString:HBF256T_MODEL]){
                [H2Omron sharedInstance].omronSerialNumber = devName;
#ifdef DEBUG_LIB
                DLog(@"OMRON_HMF_256T NAME DONE");
#endif
                return YES;
            }
            break;
            
            
            
        case SM_BLE_OMRON_HEM_9200T:
#ifdef DEBUG_LIB
            DLog(@"YES - 9200T NAME %@", devName);
#endif
            if ( [subBleEquipName isEqualToString:HEM9200T_MODEL]){
#ifdef DEBUG_LIB
                DLog(@"GOT HEM-9200T BP");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_OMRON_HEM_6320T:
            if ( [subBleEquipName isEqualToString:HEM6320T_MODEL]){
                [H2Omron sharedInstance].omronSerialNumber = devName;
#ifdef DEBUG_LIB
                DLog(@"YES - 6320T NAME %@, and %@", devName, subBleEquipName);
#endif
                return YES;
            }
            break;
            
        case SM_BLE_OMRON_HEM_6324T:
            // BLEsmart_0000002D11030791E000 // HEM-6324T
            if ( [subBleEquipName isEqualToString:HEM6324T_MODEL]){
                [H2Omron sharedInstance].omronSerialNumber = devName;
#ifdef DEBUG_LIB
                DLog(@"OMRON_HEM-6324T NAME DONE");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
            if ([devName isEqualToString:@"GT-1830"] ) {
#ifdef DEBUG_LIB
                DLog(@"WE HAVE GOT THE GT-1830");
#endif
                return YES;
            }
            break;
            
        case SM_BLE_ARKRAY_NEO_ALPHA:
            if ([devName isEqualToString:@"GlutestNeoAlpha"]) {
#ifdef DEBUG_LIB
                DLog(@"WE HAVE GOT THE ARKRAY = %@", devName);
#endif
                return YES;
            }
            break;
            
        case SM_BLE_BGM_TYSON_HT100:
            if ([devName length] > 8) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 4)];
            }
            if ([subBleEquipName isEqualToString:@"TBMT"] ) {
#ifdef DEBUG_LIB
                DLog(@"TYSON_NAME %@ and %@", devName, subBleEquipName);
#endif
                return YES;
            }
            break;
            
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE: // //Contour7801H5213142
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
#ifdef DEBUG_LIB
            DLog(@"CONTOUR NEXT ONE %@", devName);
#endif
            if ([devName length] > CONTOUR_LEN) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, CONTOUR_LEN)];
            }
            if ([subBleEquipName isEqualToString:@"Contour78"] ) {
#ifdef DEBUG_LIB
                DLog(@"CONTOUR_NEXT_ONE_NAME =  %@ and %@", devName, subBleEquipName);
#endif
                return YES;
            }
            break;
/*
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
#ifdef DEBUG_LIB
            DLog(@"CONTOUR PLUS ONE %@", devName);
#endif
            //  Contour7804H6008308 // Contour Plus ONE
            if ([devName length] > 12) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 12)];
            }
            if ([subBleEquipName isEqualToString:@"Contour7804H"] ) {
                
#ifdef DEBUG_LIB
                DLog(@"CONTOUR_PLUS_ONE_NAME =  %@ and %@", devName, subBleEquipName);
#endif
                return YES;
            }
            break;
*/
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
            if ( [devName isEqualToString:@"CGM Glucose"]) { // CGM Glucose
#ifdef DEBUG_LIB
                DLog(@"HMD NAME DONE");
#endif
                return YES;
            }
            break;
         
        case SM_BLE_BIONIME_GM700SB:
            if ([devName length] > 4) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 4)];
            }
            if ([subBleEquipName isEqualToString:@"2782"]) {
                return YES;
            }
            break;
            
        case SM_BLE_GARMIN:
            NSLog(@"GARMIN NAME - %@", devName);
            //return YES;
            break;
            
        case SM_BLE_MICRO_LIFE:
            //NSLog(@"MICRO_LIFE NAME - %@", devName);
            if ([devName isEqualToString:@"A6 BT"]) {
                return YES;
            }
            break;
            
        case SM_BLE_AND_UA_651BLE:
            // TO GO, A&D_UA-651BLE_31364A
            if ([devName length] > 13) {
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 13)];
                if ([subBleEquipName isEqualToString:@"A&D_UA-651BLE"]) {
                    return YES;
                }
            }
            break;
            
        case SM_BLE_AND_UC_352BLE: // A&D_UC-352BLE_03542B
            if ([devName length] > 13) {
                //NSLog(@"A&D = %@", devName);
                subBleEquipName = [devName substringWithRange:NSMakeRange(0, 13)];
                if ([subBleEquipName isEqualToString:@"A&D_UC-352BLE"]) {
                    return YES;
                }
            }
            break;
            
        default:

            if ([H2DataFlow sharedDataFlowInstance].equipProtocolId == 0x8001) {
#ifdef DEBUG_LIB
                DLog(@"H2 CABLE TEST .. GET ...");
#endif
                return YES;
            }
#ifdef DEBUG_LIB
            DLog(@"VENDOR H2 CABLE DISCOVER PERIPHERAL");
#endif
            break;
    }
    return NO;
}

/***********************************************************************
 * @fn : DID CONNECT PERIPHERAL,
 *
 *
 *
 **********************************************************************/
- (void)VENDidConnectPeripheral:(CBPeripheral *)peripheral;
{
    _h2ConnectedPeripheral = peripheral;
    _skipRecord = NO;
    _bleVendorRunning = NO;
    _bleVendorNotifyDone = NO;

    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBgmServiceID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID, [RocheSetInfo sharedInstance].guideElseServiceID]];
            break;
            
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_TRUE_METRIX:
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBgmServiceID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID]];
            break;
            
        
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBgmServiceID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID, [H2BleProfile sharedBleProfileInstance].bleCurrentTimeServiceUUID]];
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            [peripheral discoverServices:@[[Fora sharedInstance].h2ForaServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID]];
#ifdef DEBUG_LIB
            DLog(@"DID CONNECT UUID FORA is %@, %@", @[[Fora sharedInstance].h2ForaServiceUUID], [H2BleProfile sharedBleProfileInstance].bleBgmServiceID);
#endif
            break;
#if 0
        case SM_BLE_OMNIS_EXT_3_APEXBIO:
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBgmServiceID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID]];
#ifdef DEBUG_LIB
            DLog(@"DID CONNECT APEXBIO is %@", @[[H2BleProfile sharedBleProfileInstance].bleBgmServiceID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID]);
#endif
            break;
#endif
        case SM_BLE_CARESENS_EXT_C_BTM:
            [peripheral discoverServices:@[[BleBtm sharedInstance].h2BtmFirstServiceID, [BleBtm sharedInstance].h2BtmSecondServiceID]];
#ifdef DEBUG_LIB
            DLog(@"DID CONNECT  BTM is %@", [BleBtm sharedInstance].h2BtmFirstServiceID);
            DLog(@"DID CONNECT  BTM is %@", [BleBtm sharedInstance].h2BtmSecondServiceID);
#endif
            break;

        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
            [OneTouchPlusFlex sharedInstance].flexFirstCmd = YES;
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID, [OneTouchPlusFlex sharedInstance].ohPlusFlexServiceID]];
            break;
            
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
            [peripheral discoverServices:@[[H2Omron sharedInstance].OMRON_Service_UUID]];
#ifdef DEBUG_LIB
            DLog(@"OMRON DISCOVER ALL SERVICE %@", [H2Omron sharedInstance].OMRON_Service_UUID);
#endif
            //            [peripheral discoverServices:@[_bleDevInfoServiceUUID, [OMRON_HEM_7280T sharedInstance].OMRON_ServiceHEM_7280T_UUID  ]];
            
            break;
            
        case SM_BLE_OMRON_HEM_9200T:
#ifdef DEBUG_LIB
            DLog(@"9200T - WANT TO DISCOVER ...");
#endif
#if 1
            [[H2Records sharedInstance] resetRecordsArray];
            [[H2SvrLastDateTime sharedInstance] h2InitTimeAndIndexFromServer];

            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBPServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID, [H2BleProfile sharedBleProfileInstance].bleCurrentTimeServiceUUID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID]];
            
#else
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBPServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID, [H2BleProfile sharedBleProfileInstance].bleCurrentTimeServiceUUID]];
            
#endif
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            // Discover all Services for Test
            [peripheral discoverServices:nil];
            break;
            
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBgmServiceID]];
#ifdef DEBUG_LIB
            DLog(@"DID CONNECT UUID HMD is %@", @[[H2BleProfile sharedBleProfileInstance].bleBgmServiceID]);
#endif
            break;
         
        case SM_BLE_BIONIME_GM700SB:
            [peripheral discoverServices:@[[Gm700sb sharedInstance].bioNimeServiceID]];
            break;
            
        case SM_BLE_GARMIN:
            [peripheral discoverServices:nil];
            break;
            
        case SM_BLE_MICRO_LIFE:
            [peripheral discoverServices:@[[MicroLife sharedInstance].mlF0ServiceID]];
            break;
            
        case SM_BLE_AND_UA_651BLE:
            // TO DO
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBPServiceUUID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID, [AndUA651BLE sharedInstance].UA651_Service_UUID]];
            break;
            
        case SM_BLE_AND_UC_352BLE:
            // TEST ...
            [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleBwsServiceID, [H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID, [AndUA651BLE sharedInstance].UA651_Service_UUID]];
            break;
            
        default:
            if ([H2DataFlow sharedDataFlowInstance].equipProtocolId == 0x8001) {
#ifdef DEBUG_LIB
                DLog(@"H2 CABLE TEST .. CONNECT ...");
#endif
                [peripheral discoverServices:@[[H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID]];
            }
            break;
    }
}

/***********************************************************************
 * @fn : DID DISCOVER SERVICES,
 *
 *
 *
 **********************************************************************/
- (void)VendorDidDiscoverServices:(CBPeripheral *)peripheral
{
#ifdef DEBUG_LIB
    int i = 0;
    for (CBService *service in peripheral.services) {
        DLog(@"DISCOVER VENDOR SERVICE Index %d %@", i, service);
        i++;
    }
#endif
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID]) {
            // Device Info
#ifdef DEBUG_LIB
            DLog(@"DISCOVER DEV-INFO");
#endif
#if 0
            [peripheral discoverCharacteristics:@[[H2BleProfile sharedBleProfileInstance].bleSerialNumberUUID] forService:service];
#else
            [peripheral discoverCharacteristics:nil forService:service];
#endif
        }
        
        if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID]) {
            // Battery Level
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
        if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmServiceID])
        {
            // BLE BGM
            [H2BleProfile sharedBleProfileInstance].h2_BleBgm_Service = service;
           [peripheral discoverCharacteristics:nil forService:service];
        }

        // BP
        if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBPServiceUUID]) {
            [peripheral discoverCharacteristics:nil forService:service];
#ifdef DEBUG_BLE_VENDOR
            DLog(@"DISCOVER VENDOR BP SERVICE %@", service);
#endif
        }
        
        // BWS
        if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBwsServiceID]) {
            [peripheral discoverCharacteristics:nil forService:service];
            [H2BleProfile sharedBleProfileInstance].bleBws_Service = service;
#ifdef DEBUG_BLE_VENDOR
            DLog(@"DISCOVER VENDOR BWS SERVICE %@", service);
#endif
        }
        
        // Current Time
        if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleCurrentTimeServiceUUID]) {
            [peripheral discoverCharacteristics:nil forService:service];
            [H2BleProfile sharedBleProfileInstance].bleCTService = service;
#ifdef DEBUG_BLE_VENDOR
            DLog(@"DISCOVER VENDOR CT SERVICE %@", service);
#endif
        }
    }

    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[Fora sharedInstance].h2ForaServiceUUID]) {
                    [Fora sharedInstance].h2_FORA_Service = service;
                    [peripheral discoverCharacteristics:nil forService:service];
                }
            }
#ifdef DEBUG_BLE_VENDOR
            DLog(@"VENDOR DISCOVER SERVICE -- FORA");
#endif
            break;
            
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
        case SM_BLE_BGM_TRUE_METRIX:
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[RocheSetInfo sharedInstance].guideElseServiceID]) {
                    [RocheSetInfo sharedInstance].guideElseFlexService = service;
                    [peripheral discoverCharacteristics:nil forService:service];
                }
                NSLog(@"ACCU_CHEK GUIDE = %@", service);
            }
#ifdef DEBUG_BLE_VENDOR
            DLog(@"VENDOR DISCOVER SERVICE -- APEX BIO");
#endif
            break;
            
        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[OneTouchPlusFlex sharedInstance].ohPlusFlexServiceID]) {
                    [OneTouchPlusFlex sharedInstance].ohPlusFlexService = service;
                    [peripheral discoverCharacteristics:nil forService:service];
                }
            }

            break;
            
        case SM_BLE_CARESENS_EXT_C_BTM:
            for (CBService *service in peripheral.services) {
//                [peripheral discoverCharacteristics:nil forService:service];
                if ([service.UUID isEqual:[BleBtm sharedInstance].h2BtmFirstServiceID]) {
                    [BleBtm sharedInstance].h2_Btm_FirstService = service;
                    [peripheral discoverCharacteristics:nil forService:service];
                }
                
                if ([service.UUID isEqual:[BleBtm sharedInstance].h2BtmSecondServiceID]) {
                    [BleBtm sharedInstance].h2_Btm_SecondService = service;
                    [peripheral discoverCharacteristics:nil forService:service];
                }
            }
#ifdef DEBUG_BLE_VENDOR
            DLog(@"VENDOR DISCOVER SERVICE -- BTM");
#endif
            break;
     
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
            for (CBService *service in peripheral.services)
            {
                // Discovers the characteristics for a given service
                if ([service.UUID isEqual:[H2Omron sharedInstance].OMRON_Service_UUID])
                {
                    [H2Omron sharedInstance].Omron_Service = service;
                    [peripheral discoverCharacteristics:nil forService:service];
#ifdef DEBUG_BLE_VENDOR
                    DLog(@"VENDOR DISCOVER SERVICE -- OMRON_HEM_7280T -- %@", service);
#endif
                }
            }
            break;
            
        case SM_BLE_OMRON_HEM_9200T:
            for (CBService *service in peripheral.services)
            {
                // Discovers the characteristics for a given service
                if ([service.UUID isEqual:[H2Omron sharedInstance].OMRON_Service_UUID])
                {
//                    [H2Omron sharedInstance].Omron_Service = service;
//                    [peripheral discoverCharacteristics:nil forService:service];
#ifdef DEBUG_BLE_VENDOR
                    DLog(@"VENDOR DISCOVER SERVICE -- OMRON_HEM_9200T -- %@", service);
#endif
                }
            }
            break;
            
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            // Show Services we have found ...
            for (CBService *service in peripheral.services)
            {
                if ([service.UUID isEqual:[ArkrayGBlack sharedInstance].Arkray_ServiceUUID ]) {
                    [ArkrayGBlack sharedInstance].GBlack_Service = service;
                    [peripheral discoverCharacteristics:nil forService:service];
                    
                }
            }
            break;
            
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmServiceID]) {
                    [H2BleHmd sharedInstance].h2_HMD_Service = service;
                    
                    [peripheral discoverCharacteristics:@[[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_RecordAccessControlPointID, [H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_MeasurementID, [H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_FeatureID] forService:service];
                }
            }
#ifdef DEBUG_BLE_VENDOR
            DLog(@"VENDOR DISCOVER SERVICE -- HMD");
#endif
            break;
           
        case SM_BLE_BIONIME_GM700SB:
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[Gm700sb sharedInstance].bioNimeServiceID]) {
                    [Gm700sb sharedInstance].bioNimeService = service;
                    [peripheral discoverCharacteristics:nil forService:service];
                    //[peripheral discoverCharacteristics:@[[Gm700sb sharedInstance].bioNimeCharacteristicReadWriteID, [Gm700sb sharedInstance].bioNimeCharacteristicNotifyID, [Gm700sb sharedInstance].bioNimeCharacteristicWriteID] forService:service];
                }
            }
            break;
           
        case SM_BLE_GARMIN:
            for (CBService *service in peripheral.services) {
                //if ([service.UUID isEqual:[Gm700sb sharedInstance].bioNimeServiceID]) {
                [peripheral discoverCharacteristics:nil forService:service];
                //}
            }
            break;
            
        case SM_BLE_MICRO_LIFE:
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[MicroLife sharedInstance].mlF0ServiceID]) {
                    [peripheral discoverCharacteristics:nil forService:service];
                }
            }
            break;
            
        case SM_BLE_AND_UA_651BLE:
            // TO DO
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[AndUA651BLE sharedInstance].UA651_Service_UUID]) {
                    [peripheral discoverCharacteristics:nil forService:service];
                }
            }
            break;
            
        case SM_BLE_AND_UC_352BLE:
            /*
            for (CBService *service in peripheral.services) {
                if ([service.UUID isEqual:[AndUA651BLE sharedInstance].UA651_Service_UUID]) {
                    [peripheral discoverCharacteristics:nil forService:service];
                }
                //if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBwsServiceID]) {
                //    [peripheral discoverCharacteristics:nil forService:service];
                //}
            }
             */
            break;
            
        default:
            if ([H2DataFlow sharedDataFlowInstance].equipProtocolId == 0x8001) {
#ifdef DEBUG_LIB
                DLog(@"H2 CABLE TEST .. DISCOVER SERVICE ...");

                for (CBService *service in peripheral.services) {
                    if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID]) {
                        DLog(@"H2 CABLE TEST ... Dev Info DISCOVER SERVICE ...");
                    }
                }
#endif
            }
#ifdef DEBUG_BLE_VENDOR
        DLog(@"VENDOR DISCOVER SERVICE -- DON'T COME TO HERE ... ERROR");
#endif
            break;
    }
    
}

/***************************************************************************************
 * @fn : DID DISCOVER CHARACTERISTICS FOR SERVICE, Call Back
 *
 *
 *
 *
 ***************************************************************************************/
- (void)serviceBtmSubscribe
{
    [[BleBtm sharedInstance] h2BtmSubscribeTask];
}

#pragma mark - BLE DISCOVER CHAR Did Discover Characteristic
- (void)VendorPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
{
#ifdef DEBUG_BLE_VENDOR
    DLog(@"/*************************************************/");
    DLog(@"\n");
    DLog(@"/*     Did VENDOR Come to discover characteristic   */");
    DLog(@"\n");
    DLog(@"/*************************************************/");
    int idx = 0;
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        DLog(@"The VENDOR Index %d and CHAR --- %@ \n", idx, characteristic);
        idx++;
    }
#endif
    
    // BLE BGM Characteristic
    if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmServiceID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_MeasurementID]) {
                [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_Measurement = characteristic;
                 [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                
#ifdef DEBUG_BLE_VENDOR
                DLog(@"BLE BGM - MEASUREMENT  %@", characteristic);
#endif
            }
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_FeatureID]) {
                [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_Feature = characteristic;
#ifdef DEBUG_BLE_VENDOR
                DLog(@"BLE BGM - FEATURE  %@", characteristic);
#endif
            }
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_RecordAccessControlPointID]) {
                [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_RecordAccessControlPoint = characteristic;
                 [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
#ifdef DEBUG_BLE_VENDOR
                DLog(@"BLE BGM - RECORD ACCESS CONTROL POINT  %@", characteristic);
#endif
            }
            
            // Roche Meter Time
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDateTimeUUID]) {
                [peripheral readValueForCharacteristic:characteristic];
            }
            
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].h2BgmCharacteristic_ContextID]) {
                [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_MeasurementContext = characteristic;
                [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
#ifdef DEBUG_BLE_VENDOR
                DLog(@"BLE BGM - MEASUREMENT CONTEXT  %@", characteristic);
#endif
            }
            
        }
    }

    
    // BP
    if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBPServiceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBPMeasurementUUID]) {
                [H2BleProfile sharedBleProfileInstance].bleCharBPMeasurement = characteristic;
                if ([H2DataFlow sharedDataFlowInstance].equipId != SM_BLE_AND_UA_651BLE) {
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
#ifdef DEBUG_LIB
                    DLog(@"BP NOMAL MODE");
#endif
            }
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBPFreatureUUID]) {
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
    
    // BWS
    if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBwsServiceID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBwsCharacteristic_MeasurementID]) {
                [H2BleProfile sharedBleProfileInstance].bleBws_CHAR_Measurement = characteristic;
                if ([H2DataFlow sharedDataFlowInstance].equipId != SM_BLE_AND_UC_352BLE) {
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
#ifdef DEBUG_LIB
                DLog(@"BWS NOMAL MODE");
#endif
            }
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBwsCharacteristic_FeatureID]) {
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
    
    // CT
    if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleCurrentTimeServiceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleCurrentTimeCharacteristicUUID]) {
                [H2BleProfile sharedBleProfileInstance].bleCharCurrentTime = characteristic;
                
                switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                    case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
                    case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
                        if (!_blePairingStage) {
                            [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                        }
                        break;
                        
                    case SM_BLE_OMRON_HEM_9200T:
                        [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                        break;
                        
                    default:
                        break;
                }
                
                
            }
        }
        return;
    }
    
    // Device Info Service
#ifdef DEBUG_LIB
    DLog(@" SERVICE : %@ VS %@ ", service.UUID, [H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID);
#endif
    if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            // NORMAL BLE DEVICE INFOD
#ifdef DEBUG_BLE_VENDOR
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleSystemUUID]) {
                //[peripheral readValueForCharacteristic:characteristic];
            }
            
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleManufacturerUUID]) {
                //[peripheral readValueForCharacteristic:characteristic];
            }
#endif
            // SN
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleSerialNumberUUID]) {
                _bleSerialNumberMode = YES;
                [H2BleProfile sharedBleProfileInstance].bleCharSerialNumber = characteristic;
                
                if ([H2BleService sharedInstance].didNeedMoreTimeForBlePairing) {
                    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
                    [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_PREPIN_INTERVAL taskSel:BLE_TIMER_PREPIN_MODE];
                }
                switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                    case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
                    case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
                        if (_blePairingStage) {
                            [peripheral readValueForCharacteristic:characteristic];
                        }
                        break;
                        
                    default:
                        [peripheral readValueForCharacteristic:characteristic];
                        break;
                }
                
                if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_BGM_TYSON_HT100) {
                    [H2Records sharedInstance].bgSkipRecords = YES;
                }

#ifdef DEBUG_BLE_VENDOR
                DLog(@"READ BLE SERIAL NUMBER  %@", characteristic);
#endif
            }
        }
    }
    
    // Battery Level Service
    if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBatteryServiceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBatteryLevelCharacteristicUUID]) {
                // SET Battery Notification ...
                if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_AND_UA_651BLE || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_AND_UC_352BLE) {
                    [_h2ConnectedPeripheral readValueForCharacteristic:characteristic];
                }else{
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }

    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_TRUE_METRIX:
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[RocheSetInfo sharedInstance].guideCharacteristicA0_UUID]){
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                    NSLog(@"GUIDE ELSE CHAR 0");
                    
                    [RocheSetInfo sharedInstance].guideCharacteristicWrite = characteristic;
                }

                if ([characteristic.UUID isEqual:[RocheSetInfo sharedInstance].guideCharacteristicA1_UUID]){
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                    NSLog(@"GUIDE ELSE CHAR 1");
                    
                }

            }
            return;
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[Fora sharedInstance].h2ForaCharacteristic_WriteNotifyUUID]){
                    [Fora sharedInstance].h2_FORA_CHAR_WriteNotify = characteristic;
#ifdef DEBUG_BLE_VENDOR
                    DLog(@"The FORA CHAR 1 UUID --- %@ \n", characteristic.UUID);
                    DLog(@"The FORA CHAR 2 UUID --- %@ \n", [Fora sharedInstance].h2ForaCharacteristic_WriteNotifyUUID);
#endif
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
#ifdef DEBUG_BLE_VENDOR
            DLog(@"VENDOR DISCOVER SERVICE -- FORA");
#endif
            break;
            
        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[OneTouchPlusFlex sharedInstance].ohPlusFlexCharacteristicNotifyID]) {
                    [OneTouchPlusFlex sharedInstance].ohPlusFlexCharacteristicNotify = characteristic;
                    [[OneTouchPlusFlex sharedInstance] plusFlexBufferInit];
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[OneTouchPlusFlex sharedInstance].ohPlusFlexCharacteristicNotify];
                    NSLog(@"PLUS FLEX CH 0");
                }
                
                if ([characteristic.UUID isEqual:[OneTouchPlusFlex sharedInstance].ohPlusFlexCharacteristicWriteID]) {
                    [OneTouchPlusFlex sharedInstance].ohPlusFlexCharacteristicWrite = characteristic;
                    
                    
                    //[[OneTouchPlusFlex sharedInstance] plusFlexCmdFlow];
                    NSLog(@"PLUS FLEX CH 1");
                }
                
            }
            break;
            
        case SM_BLE_CARESENS_EXT_C_BTM:
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[BleBtm sharedInstance].h2BtmCharacteristic_WriteID]) {
                    [BleBtm sharedInstance].h2_Btm_CHAR_Write = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"BTM VENDOR CHAR  B(Write) %@ GOT IT !! GOT IT !!", characteristic);
#endif
                    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(serviceBtmSubscribe) userInfo:nil repeats:NO];
                }
                
                if ([characteristic.UUID isEqual:[BleBtm sharedInstance].h2BtmCharacteristic_NotifyID]) {
                    [BleBtm sharedInstance].h2_Btm_CHAR_Notify = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"BTM VENDOR CHAR  A(Notify) %@", characteristic);
#endif
                }
                
                if ([characteristic.UUID isEqual:[BleBtm sharedInstance].h2BtmCharacteristic_CID]) {
                    [BleBtm sharedInstance].h2_Btm_CHAR_C = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"BTM VENDOR CHAR  C %@", characteristic);
#endif
                }
                
                if ([characteristic.UUID isEqual:[BleBtm sharedInstance].h2BtmCharacteristic_DID]) {
                    [BleBtm sharedInstance].h2_Btm_CHAR_D = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"BTM VENDOR CHAR  D %@", characteristic);
#endif
                }
            }
#ifdef DEBUG_BLE_VENDOR
            DLog(@"VENDOR DISCOVER CHAR -- BTM");
#endif
            break;
            
//        case SM_BLE_OMNIS_EXT_3_APEXBIO:
//            break;
            
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
#ifdef DEBUG_BLE_VENDOR
            DLog(@"VENDOR DISCOVER CHAR -- OMRON_HEM_7280T");
#endif
            [H2Omron sharedInstance].Omron_Characteristic_A0 =
            [[CBMutableCharacteristic alloc] initWithType:[H2Omron sharedInstance].OMRON_Characteristic_A0_UUID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotifyEncryptionRequired value:nil permissions:CBAttributePermissionsReadEncryptionRequired];
            
            if ([service.UUID isEqual:[H2Omron sharedInstance].OMRON_Service_UUID]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A0_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A0 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 0 -  %@", characteristic);
#endif
                    }
                    
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A1_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A1 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 1 -  %@", characteristic);
#endif
                    }
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A2_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A2 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 2 -  %@", characteristic);
#endif
                    }
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A3_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A3 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 3 -  %@", characteristic);
#endif
                    }
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A4_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A4 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 4 -  %@", characteristic);
#endif
                    }
                    
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A5_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A5 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 5 -  %@", characteristic);
#endif
                    }
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A6_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A6 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 6 -  %@", characteristic);
#endif
                    }
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A7_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A7 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 7 -  %@", characteristic);
#endif
                    }
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A8_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A8 = characteristic;
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 8 -  %@", characteristic);
#endif
                    }
                    if ([characteristic.UUID isEqual:[H2Omron sharedInstance].OMRON_Characteristic_A9_UUID]) {
                        [H2Omron sharedInstance].Omron_Characteristic_A9 = characteristic;
                        [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[H2Omron sharedInstance].Omron_Characteristic_A0];
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"OMRON CHAR 9 -  %@", characteristic);
#endif
                    }
                }
            }
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            // Characteristics TO DO ..
            if ([service.UUID isEqual:[ArkrayGBlack sharedInstance].Arkray_ServiceUUID]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[ArkrayGBlack sharedInstance].ArkrayReport_CharacteristicID] || [characteristic.UUID isEqual:[ArkrayGBlack sharedInstance].ArkrayGeneral_CharacteristicUUID]) {
                        [ArkrayGBlack sharedInstance].GBlack_Characteristic_Report = characteristic;
                        [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
                        if (_blePairingStage) {
                            [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_DIALOG_INTERVAL taskSel:BLE_TIMER_ARKRAY_NOTIFY];
                        }else{
                            [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_DIALOG_INTERVAL taskSel:BLE_TIMER_ARKRAY_NOTIFY];
                            //[[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_NOTIFY_INTERVAL taskSel:BLE_TIMER_ARKRAY_NOTIFY];
                        }
                        
#ifdef DEBUG_BLE_VENDOR
                        DLog(@"ARKRAY GET REPORT CHAR -  %@", characteristic);
#endif
                    }
                }
            }
            break;
            
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_MeasurementID]){
                    [H2BleHmd sharedInstance].h2_HMD_CHAR_Measurement = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"The UUID HMD CHAR MEASUREMENT --- %@ \n", characteristic);
#endif
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                if([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_RecordAccessControlPointID]){
                    [H2BleHmd sharedInstance].h2_HMD_CHAR_RecordAccessControlPoint = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"The UUID HMD CHAR RECORD ACCESS --- %@ \n", characteristic);
#endif
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_FeatureID]) {
                    [H2BleHmd sharedInstance].h2_HMD_CHAR_Feature = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"The UUID HMD CHAR FEATURE --- %@ \n", characteristic);
#endif
                }
            }
            break;
          
        case SM_BLE_BIONIME_GM700SB:
            // Discover Characteristics ...
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                if ([characteristic.UUID isEqual:[Gm700sb sharedInstance].bioNimeCharacteristicReadWriteID]){
                    [Gm700sb sharedInstance].bioNimeCharacteristicReadWrite = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"BIO_NIME RW --- %@ \n", characteristic);
#endif
                }
                if([characteristic.UUID isEqual:[Gm700sb sharedInstance].bioNimeCharacteristicNotifyID]){
                    [Gm700sb sharedInstance].bioNimeCharacteristicNotify = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"BIO_NIME NOTIFY --- %@ \n", characteristic);
#endif
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                if ([characteristic.UUID isEqual:[Gm700sb sharedInstance].bioNimeCharacteristicWriteID]) {
                    [Gm700sb sharedInstance].bioNimeCharacteristicWrite = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"TBIO_NIME WRITE --- %@ \n", characteristic);
#endif
                }
            }
            break;
            
        case SM_BLE_GARMIN:
            NSLog(@"GARMIN CHAR");
            break;
            
        case SM_BLE_MICRO_LIFE:
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:[MicroLife sharedInstance].mlF1CharacteristicID]) {
                    [MicroLife sharedInstance].mlF1Characteristic = characteristic;
                    [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
                if ([characteristic.UUID isEqual:[MicroLife sharedInstance].mlF2CharacteristicID]) {
                    [MicroLife sharedInstance].mlF2Characteristic = characteristic;
                }
#ifdef DEBUG_LIB
                NSLog(@"MICRO_LIFE CHAR == %@", characteristic);
#endif
            }
            break;
            
        case SM_BLE_AND_UA_651BLE: //
        case SM_BLE_AND_UC_352BLE:
            // TO DO
            for (CBCharacteristic *characteristic in service.characteristics) {
#ifdef DEBUG_LIB
                NSLog(@"UA-651 BLE CHAR == %@", characteristic);
#endif
                if ([characteristic.UUID isEqual:[AndUA651BLE sharedInstance].UA651_Characteristic_UUID]) {
                    [AndUA651BLE sharedInstance].AndUa651_Characteristic = characteristic;
                }
                
                if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDateTimeUUID]){
                    NSLog(@"A&D READ CT ...");
                    [H2BleProfile sharedBleProfileInstance].bleCharDateTime = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
            break;
            
        default:
#ifdef DEBUG_LIB
             DLog(@"COME TO DEFAULT -> CHARACHERISTICS ...");
#endif
            if ([H2DataFlow sharedDataFlowInstance].equipProtocolId == 0x8001) {
#ifdef DEBUG_LIB
                DLog(@"H2 CABLE TEST .. DISCOVER  ...characteristics");
#endif
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleSerialNumberUUID]){
#ifdef DEBUG_LIB
                        DLog(@"H2 CABLE TEST .. DISCOVER  ...GET SERIAL NUMBER CHARACHERISTICS ...");
#endif
                    }
                }
            }
            break;
    }
}
/********************************************************************************
 * @fn : DID UPDATE VALUE FOR CHARACTERISTIC
 *
 *
 *
 *
 *********************************************************************************/
- (void)VendorDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
    Byte byteTemp = 0xFF;
    //NSLog(@"BLE - GOOD = %@", characteristic);
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_RecordAccessControlPointID])
    {
         [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        //DLog(@"BGM RECORD ACCESS CONTROL POINT");
        if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_BGM_TRUE_METRIX) {
#ifdef DEBUG_LIB
            DLog(@"TURE METRIX ENDING CHECKING");
#endif
            UInt16 records = [[H2SyncReport sharedInstance].h2BgRecordReportArray count];
            UInt8 bleCmd = [H2BleBgm sharedInstance].command;
            if ( bleCmd == ACTION_GREATER_THAN && records == 0) {// Get Great Then Command and Zeor Record
                unsigned char bufTmp[4] = {0};
                if ([characteristic.value length] <= 4) {
                    memcpy(bufTmp, [characteristic.value bytes], 4);
                }
                if (bufTmp[0] == 6 && bufTmp[1] == 0 && bufTmp[2] == 1 && bufTmp[3] == 6) {
                    [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
                    [[H2BleBgm sharedInstance] h2BleBgmWriteTask:ACTION_ALL_RECORDS];
#ifdef DEBUG_LIB
                    DLog(@"TURE METRIX GET ALL");
#endif
                    return;
                }
            }
        }
           
        if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_BGM_TYSON_HT100) {
            if ([H2BleBgm sharedInstance].willFinished) {
                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
            }else{
                [[H2BleBgm sharedInstance] bleBgmLoopCmdForTysonHT100];
            }
        }else{
            [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
#ifdef DEBUG_LIB
            DLog(@"TURE METRIX FINISHED ....");
#endif
        }
    }
    
    // NORMAL BLE DEVICE INFOD
#ifdef DEBUG_LIB
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleSystemUUID]) {
        DLog(@"SYSTEM ID");
    }
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleManufacturerUUID]) {
        DLog(@"MANUFACTUREER ID");
    }
#endif
    if ([characteristic.UUID isEqual:[RocheSetInfo sharedInstance].guideCharacteristicA0_UUID]) {
#ifdef DEBUG_LIB
        DLog(@"GUIDE CURRENT TIME === VALUE UPDATE ===");
#endif
        [[RocheSetInfo sharedInstance] guideValueUpdate:characteristic];
        return;
    }
    // Scan and GET SN,
    // Serial Number Characteristic on Device Info Service
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleSerialNumberUUID]) {
#ifdef DEBUG_LIB
        DLog(@"SERIAL NUMBER ID");
#endif
        // Clear 1 second PAIRING TIMER
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        
        _bleSerialNumberMode = NO; // Clear SN Mode
        _normalFlowHasNofity = YES; // Maybe for Roche ONLY
        
        [characteristic.value getBytes:&byteTemp range:NSMakeRange([characteristic.value length]-1, 1)];
        NSData *snData = [[NSData alloc] init];
        if (byteTemp == 0x00) {
            snData = [characteristic.value subdataWithRange:NSMakeRange(0, [characteristic.value length]-1)];
#ifdef DEBUG_LIB
            DLog(@"SN RAW LAST BYTE EQUAL TO 0");
#endif
        }else{
            snData = [characteristic.value subdataWithRange:NSMakeRange(0, [characteristic.value length])];
        }
        [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [[NSString alloc] initWithData:snData encoding:NSUTF8StringEncoding];

        [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber;
#ifdef DEBUG_LIB
        DLog(@"SERIAL NUMBER ID SERVER %@, METER %@", _bleScanningKey, [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber);
#endif
        if (_blePairingStage) {
            switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
                case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
                case SM_BLE_ACCUCHEK_INSTANT:
                    return;
                    break;
                    
                default:
                    break;
            }
        }
        
        // OMRON HEM-9200T
        if([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_9200T){
            [OMRON_HEM_9200T sharedInstance].hem9200tSerialNumberDone = YES;
            // SET CURRENT TIME NOTIFY
            
            if ([OMRON_HEM_9200T sharedInstance].hem9200tCurrentTimeDone) {
                [self hem9200tStartRecords];
            }else{
                // TO DO
                [[OMRON_HEM_9200T sharedInstance] hem9200tSetCurrentTimer];
            }
            return;
        }else{
            if(_blePairingStage){
                [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
                return;
            }
            if(_bleSerialNumberStage){
                // if SN is right, then start Normal Sync
                if ([[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber isEqualToString:_bleScanningKey]) { // GO TO NORMAL SYNC
                    // GET RIGHT SN
#ifdef DEBUG_APEXBIO
                    DLog(@"BLE BGM SN IS CORRECT ...");
#endif
                    [H2Records sharedInstance].bgSkipRecords = NO;
                    _bleSerialNumberStage = NO;
                    // NSLog(@"SN DONE ...");
                    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
                        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
                        case SM_BLE_ACCUCHEK_INSTANT:
                            if ([H2BleBgm sharedInstance].willFinished) {
                                [H2SyncReport sharedInstance].didSyncRecordFinished = YES;
                                [H2BleService sharedInstance].bleNormalDisconnected = YES;
                                [[H2Records sharedInstance] resetRecordsArray];
                                [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_SYNC];
                                return;
                            }
                            break;
                            
                        default:
                            break;
                    }
                    if([H2DataFlow sharedDataFlowInstance].equipId != SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX){
                        [self bleVendorReportMeterInfo];
                    }
                }else{
                    [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
                }
            }
        }
        return;
    }
    
    // Current Time
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleCurrentTimeCharacteristicUUID]) {
        UInt8 buffer[8] = {0};
        UInt16 ctYear = 0;
        UInt8 ctMonth = 0;
        UInt8 ctDay = 0;
        
        UInt8 ctHour = 0;
        UInt8 ctMinute = 0;
        UInt8 ctSecond = 0;

#ifdef DEBUG_LIB
        if ([H2BleService sharedInstance].blePairingStage) {
            if([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_9200T){
                DLog(@"PAIRING FOR 9200T");
            }
        }
#endif
        memcpy(buffer, characteristic.value.bytes, 8);
        
        if (buffer[0] == 0) {
            return;
        }
        memcpy(&ctYear, buffer, 2);
        ctMonth = buffer[2];
        ctDay = buffer[3];
        
        ctHour = buffer[4];
        ctMinute = buffer[5];
        ctSecond = buffer[6];
#ifdef DEBUG_APEXBIO
        DLog(@"BLE CT IS :%04d-%02d-%02d %02d:%02d:%02d +0000", ctYear, ctMonth, ctDay, ctHour, ctMinute, ctSecond);
#endif
        NSString *timeString = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", ctYear, ctMonth, ctDay, ctHour, ctMinute, ctSecond];
        [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = timeString;
        
        //NSLog(@"CT DONE -- %@", [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime);
        switch ([H2DataFlow sharedDataFlowInstance].equipId) {
            case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
            case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
                if (!_blePairingStage) {
                    [_h2ConnectedPeripheral readValueForCharacteristic:[H2BleProfile sharedBleProfileInstance].bleCharSerialNumber];
                }
                break;
            
            case SM_BLE_OMRON_HEM_9200T:
                [OMRON_HEM_9200T sharedInstance].hem9200tCurrentTimeDone = YES;
                if ([OMRON_HEM_9200T sharedInstance].hem9200tSerialNumberDone) {
                    [[OMRON_HEM_9200T sharedInstance] hem9200tClearCurrentTimer];
                    if (_blePairingStage) {
                        [H2BleService sharedInstance].bleNormalDisconnected = YES;
                        [[H2BleCentralController sharedInstance] h2BleSetDeviceSerialNumber:[h2MeterModelSerialNumber sharedInstance].smSerialNumber];
                        [[H2BleCentralController sharedInstance] H2ReportBleDeviceTimeOut];
                    }else{
                        [self hem9200tStartRecords];
                    }
                }
                break;
                
            default:
                break;
        }
        return;
    }
    
    // BP
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBPMeasurementUUID]) {
        [[OMRON_HEM_9200T sharedInstance] hem9200TRecordParser:characteristic];
    }
    
    // BWS
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBwsCharacteristic_MeasurementID]) {
        // TO DO ...
        NSLog(@"BWS VALUE = %@", characteristic);
        [[AndUA651BLE sharedInstance]bwsNormalRecordParser:characteristic];
    }
    
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBatteryLevelCharacteristicUUID]) {
        //UInt16 level = 0;
        memcpy(&_batteryRawValue, [characteristic.value bytes], 1);
        
        _batteryLevel = _batteryRawValue/10;
        
#ifdef DEBUG_LIB
        DLog(@"BGM BATTERY LEVEL %04d", _batteryLevel);
#endif
        if (characteristic.isNotifying) {
            [_h2ConnectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
        }
        return;
    }
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            if ([Fora sharedInstance].syncStart) {
                [[Fora sharedInstance] h2FORA_DataProcessTask:characteristic];
            }
#ifdef DEBUG_LIB
            DLog(@"FORA UPDATE VALUE ...");
#endif
            break;
            
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
        case SM_BLE_BGM_TRUE_METRIX:
        case SM_BLE_BGM_TYSON_HT100:
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDateTimeUUID]) {
                // METER TIME PARSER
                [[RocheSetInfo sharedInstance] rocheMeterTimeParser:characteristic];
            }
            
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_MeasurementID]) {
                [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_RECORD_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
            }
            
            if (![H2Records sharedInstance].bgSkipRecords) {// Skip Records For HT100,
                [[H2BleBgm sharedInstance] h2BleBgmReportProcessTask:characteristic];
                
#ifdef DEBUG_LIB
                DLog(@"TYSON RD 4");
#endif
            }
            break;
            
        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
            [[OneTouchPlusFlex sharedInstance] oneTouchValueUpdate:characteristic];
            break;
            
        case SM_BLE_CARESENS_EXT_C_BTM:
            [[BleBtm sharedInstance] h2BTMReportProcessTask];
            break;
            
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
            [[H2Omron sharedInstance] h2OmronDataHandling:characteristic];
            break;
            
        case SM_BLE_OMRON_HEM_9200T:
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            // Report Process ...
            [[ArkrayGBlack sharedInstance] arkrayValueUpdate:characteristic];
            break;
           
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
            [[H2BleBgm sharedInstance] h2BleBgmReportProcessTask:characteristic]; // For TEST
            break;
            
        case SM_BLE_BIONIME_GM700SB:
            // REPORT PROCESS ...
            [[Gm700sb sharedInstance] bioNimeGb700sbDataProcess:characteristic];
            break;
            
        case SM_BLE_GARMIN:
            NSLog(@"GARMIN VALUE");
            break;
            
        case SM_BLE_MICRO_LIFE:
            //NSLog(@"MICRO_LIFE VALUE");
            [[MicroLife sharedInstance] microLifeValueUpdate:characteristic];
            break;
            
        case SM_BLE_AND_UA_651BLE:
        case SM_BLE_AND_UC_352BLE:
            // TO GO
            NSLog(@"UA-651 BLE VALUE");
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDateTimeUUID]) {
                // METER TIME PARSER
                NSLog(@"A&D CURRENT TIME");
                [[RocheSetInfo sharedInstance] rocheMeterTimeParser:characteristic];
                
                // Write ...
                [[AndUA651BLE sharedInstance] writeBleDateTime];
            }
            break;
            
        default:
            break;
    }
    
    if ([H2SyncReport sharedInstance].didSendEquipInformation) {
#ifdef DEBUG_LIB
        DLog(@"SEND METER INFO ...");
#endif
        [self bleVendorReportMeterInfo];
        return;
    }
    
    if ([H2SyncReport sharedInstance].hasSMSingleRecord) {
        // TO DO ...
        [self bleSingleRecordProcess:nil];
        [[H2Sync sharedInstance] sdkReportMeterDateTimeValueSingle:nil];
    }
    
    if ([H2SyncReport sharedInstance].hasMultiRecords) {
        // TO DO ...
        [[H2Sync sharedInstance] sdkReportMeterDateTimeValueSingle:nil];
        [H2SyncReport sharedInstance].hasMultiRecords = NO;
#ifdef DEBUG_LIB
        DLog(@"BLE DEBUG -- NEED REPORT MULTI RECORDS");
#endif
    }
#ifdef DEBUG_LIB
    DLog(@"FORA - 1970 ...");
#endif
    
    if ([H2SyncReport sharedInstance].didSyncRecordFinished) {
        [H2BleService sharedInstance].bleNormalDisconnected = YES;
#ifdef DEBUG_LIB
        DLog(@"FORA - GO TO SYNC ENDING TASK");
#endif
        [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
    }
}


- (void)bleSingleRecordProcess:(id)record
{
#ifdef DEBUG_INDEX
    DLog(@"BLE SINGLE PROCESS (BG, BP, BW)");
#endif
    switch ([H2Records sharedInstance].currentDataType) {
        case RECORD_TYPE_BP:
            [[H2SyncReport sharedInstance].recordsArray addObject:[H2Records sharedInstance].bpTmpRecord];
             break;
             
        case RECORD_TYPE_BW:
             [[H2SyncReport sharedInstance].recordsArray addObject:[H2Records sharedInstance].bwTmpRecord];
             break;
             
        case RECORD_TYPE_BG:
        default:
            [[H2SyncReport sharedInstance].recordsArray addObject:[H2Records sharedInstance].bgTmpRecord];
#ifdef DEBUG_LIB
            DLog(@"ADD UID %02X", [H2Records sharedInstance].bgTmpRecord.meterUserId);
#endif
            break;
    }
}


#pragma mark - DID UPDATE NOTIFICATION
- (void)vendorDidUpdateNotificationStateForCharacteristic:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_LIB
    DLog(@"VENDOR DID NOTIFY IS %@ ...", characteristic);
#endif
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_RecordAccessControlPointID]) {
#ifdef DEBUG_LIB
         DLog(@"BLE BGM RECORD ACCESS CONTROL POINT TEST ...");
        if (characteristic.isNotifying) {
            _bleVendorNotifyDone = YES;
            NSLog(@"BLE NOTIFY - YES");
        }else{
            NSLog(@"BLE NOTIFY - NO");
        }
#endif
        return;
    }
    
    if ([characteristic.UUID isEqual:[RocheSetInfo sharedInstance].guideCharacteristicA0_UUID] && _blePairingStage) {
        NSLog(@"ROCHE SETTING ...");
        [[RocheSetInfo sharedInstance] rocheCmdInit];
    }
    
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBatteryLevelCharacteristicUUID]) {
        [peripheral readValueForCharacteristic:characteristic];
#ifdef DEBUG_LIB
        DLog(@"BATTERY NOTIFY DONE ...");
#endif
        return;
    }
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            if ([characteristic.UUID isEqual:[Fora sharedInstance].h2ForaCharacteristic_WriteNotifyUUID]){
                // INIT
                [[Fora sharedInstance] h2FORAInitTask];
#ifdef DEBUG_BLE_VENDOR
                DLog(@"VENDOR DISCOVER SERVICE -- FORA NOTIFY DONE AND INIT");
#endif
            }
            break;

        case SM_BLE_CARESENS_EXT_C_BTM:
        case SM_BLE_OMRON_HEM_9200T:
#ifdef DEBUG_LIB
            DLog(@"HEM-9200T OR BTM NOTIFICATION");
#endif
            break;
            
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
        case SM_BLE_OMRON_HEM_6324T:
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_7600T:
            [[H2Omron sharedInstance] hem7600TNotify:characteristic];
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            if ([characteristic.UUID isEqual:[ArkrayGBlack sharedInstance].ArkrayReport_CharacteristicID] || [characteristic.UUID isEqual:[ArkrayGBlack sharedInstance].ArkrayGeneral_CharacteristicUUID]) {
                [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
                
                if ([characteristic isNotifying]) {
#ifdef DEBUG_LIB
                    DLog(@"ARKRAY NOTIFY SAY - YES");// and WILL Show DIALOG");
#endif
                    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(arkrayNotifyTask) userInfo:nil repeats:NO];
                }
            }

            break;
            
        case SM_CARESENS_EXT_A_HMD_GL_BLE_EX:
            if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_RecordAccessControlPointID]) {
                if (_bleVendorNotifyDone) {
                    return;
                }
                _bleVendorNotifyDone = YES;
#ifdef DEBUG_LIB
                DLog(@"Notification successfully FOR HMD!! %@ and get record for test..", characteristic);
#endif
            }
            break;
            
        case SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX:
            if ([characteristic.UUID isEqual:[OneTouchPlusFlex sharedInstance].ohPlusFlexCharacteristicNotifyID]) {
                NSLog(@"PLUS FLEX NODIFY - DONE");
                NSLog(@"ONE TOUCH NOTIFY ... %@", characteristic);
                if (characteristic.isNotifying) {
                    [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_FLUS_FLEX_INTERVAL taskSel:BLE_TIMER_OH_PLUS_FLEX];
                    [[OneTouchPlusFlex sharedInstance] flexCmdFlowInit];
                    //[OneTouchPlusFlex sharedInstance].flexCmdSel = FLEX_CMD_0;
                    //[[OneTouchPlusFlex sharedInstance] plusFlexCmdFlow];
                    NSLog(@"PLUS FLEX INIT ...");
                }
                // TO DO ...
            }
            break;
            
        case SM_BLE_BIONIME_GM700SB:
            if ([characteristic.UUID isEqual:[Gm700sb sharedInstance].bioNimeCharacteristicNotifyID]) {
#ifdef DEBUG_LIB
                DLog(@"BIO_NIME %@ - NOTIFY DONE", characteristic);
#endif
                if ([Gm700sb sharedInstance].bionimeCommand) {
                    [Gm700sb sharedInstance].bionimeCommand = NO;
                    // RESEND COMMAND
                    [[Gm700sb sharedInstance] bioNimeGb700sbCmmand];
                }
                if (characteristic.isNotifying) {
                    [[Gm700sb sharedInstance] bioNimeGb700sbA1ModeChange];
                    return;
                }
                [Gm700sb sharedInstance].bionimeCommand = YES;
#ifdef DEBUG_LIB
                DLog(@"BIO_NIME NOTIFY --- %@ \n", characteristic);
#endif
                [_h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:[Gm700sb sharedInstance].bioNimeCharacteristicNotify];
#ifdef DEBUG_LIB
                DLog(@"BIO_NIME %@ - NOTIFY DONE", characteristic);
#endif
                return;
            }
            break;
         
        case SM_BLE_GARMIN:
            NSLog(@"GARMIN NOTIFY");
            break;
            
        case SM_BLE_MICRO_LIFE:
            if ([characteristic.UUID isEqual:[MicroLife sharedInstance].mlF1CharacteristicID]) {
                //NSLog(@"MICRO LIFE NOTIFY (F2) == %@", characteristic);
                [[MicroLife sharedInstance] mlCmdInit];
            }
            break;
            
        case SM_BLE_AND_UA_651BLE:
            // TO DO
            break;
            
        case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
        case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
            if (!_blePairingStage) {
                if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleCurrentTimeCharacteristicUUID]) {
                    [peripheral readValueForCharacteristic:characteristic];
#ifdef DEBUG_LIB
                    DLog(@"CURRENT TIME NOTIFY DONE ...");
#endif
                }
            }
            break;
            
        default:
            break;
    }
}



/****************************************************************************
 * @fn : Vendor Meter Infomation
 *
 *
 ****************************************************************************/
#pragma mark - VENDOR REPORT

/****************************************************************************
 * @fn : Vendor Meter Infomation
 *
 *
 ****************************************************************************/



- (void)resetBleMode
{
    [H2BleOad sharedInstance].oadMode = NO;
    _didUseH2BLE = NO;
    
    _isBleCable = NO;
    _isBleEquipment = NO;
    
    _blePairingStage = NO;
    _bleSerialNumberStage = NO;
    _bleRecordStage = NO;
    
    _bleOADStage = NO;
    
    //[H2Sync sharedInstance].isAudioCable = [H2AudioSession isHeadsetPluggedIn];
}


- (void)h2DeSubscribe
{
    
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            if ([Fora sharedInstance].h2_FORA_CHAR_WriteNotify.isNotifying) {
                [_h2ConnectedPeripheral setNotifyValue:NO forCharacteristic:[Fora sharedInstance].h2_FORA_CHAR_WriteNotify];
            }
            break;
            
        case SM_BLE_CARESENS_EXT_C_BTM:
            if ([BleBtm sharedInstance].h2_Btm_CHAR_Notify.isNotifying) {
                [_h2ConnectedPeripheral setNotifyValue:NO forCharacteristic:[BleBtm sharedInstance].h2_Btm_CHAR_Notify];
            }
            break;
            
        default:
            break;
    }
}

- (void)bleVendorReportMeterInfo
{
    [H2SyncReport sharedInstance].didSendEquipInformation = YES;
    _bleVendorNotifyDone = YES;
    if (_isBleEquipment) {
        _bleTempModel = @"";
    }
    [[H2Sync sharedInstance] sdkSendSerialNumberBatteryLevel:DYNAMIC_BLE_METER];
     [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(bleVendorSendMeterInfo) userInfo:nil repeats:NO];
}

- (void)bleVendorSendMeterInfo
{
    [[H2Sync sharedInstance] sdkEquipInfoProcess:[H2Records sharedInstance].dataTypeFilter withSvrUserId:[H2Records sharedInstance].equipUserIdFilter];
#ifdef DEBUG_LIB
    DLog(@"BLE VENDOR REPORT - METER INFO -- TRUE MCTRIX DEBUT");
#endif
}

///////////////////////////////////////////////
// OMRON TASK

#pragma mark - OMRON TASK
- (void)H2ServiceOmron_DiscoverAllCharacteristics
{
    [_h2ConnectedPeripheral discoverCharacteristics:nil forService:[H2Omron sharedInstance].Omron_Service];
}




- (void)H2ServiceSetUserID:(UInt8)userId
{
#ifdef DEBUG_LIB
    DLog(@"/***************************************************************");
    DLog(@"SET USER ID - TASK");
    DLog(@"****************************************************************/");
#endif

    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_CARESENS_EXT_B_FORA:
        case SM_BLE_CARESENS_EXT_B_FORA_TAIDOC:
        case SM_BLE_CARESENS_EXT_B_FORA_TNG:
        case SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE:
        case SM_BLE_CARESENS_EXT_B_FORA_D40:
        case SM_BLE_CARESENS_EXT_B_FORA_P30PLUS:
            break;
            
        case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            [[ForaW310 sharedInstance] foraW310BSetUserProfile:userId];
            break;
        
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T: // For TEST
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T: // For TEST
            [[OMRON_HEM_7280T sharedInstance] OmronHem7280TSetUserId:userId];
            break;
            
        case SM_BLE_OMRON_HBF_254C:
        case SM_BLE_OMRON_HBF_256T:
            [[OMRON_HBF_254C sharedInstance] hbfA1SetUserProfile:userId];
            break;
            
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            break;
            
        default:
            break;
    }
}


- (BOOL)hem9200tStartRecords
{
    if ([[H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber isEqualToString:_bleScanningKey]) {
        // GO TO NORMAL SYNC, // GET RIGHT SN
        _bleSerialNumberStage = NO;
        [self bleVendorReportMeterInfo];
        [[OMRON_HEM_9200T sharedInstance] hem9200tSetRecordTimer];
#ifdef DEBUG_APEXBIO
        DLog(@"9200T CT SYNC BLE BGM SN IS CORRECT ...");
#endif
        return YES;
    }else{
        [[H2BleCentralController sharedInstance] h2BleConnectReport:FAIL_BLE_NOT_FOUND];
        return NO;
    }
}

- (void)arkrayNotifyTask
{
    if (_blePairingStage) {
        // CLEAR READ SN TIMER
        if([ArkrayGBlack sharedInstance].arkrayShowDialog){
            return;
        }
        [ArkrayGBlack sharedInstance].arkrayShowDialog = YES;
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_USER_INPUT_INTERVAL taskSel:BLE_TIMER_USER_INPUT];
        [[H2Sync sharedInstance] sdkArkrayRegisterNotify];
#ifdef DEBUG_LIB
        DLog(@"ARKRAY === REGISTER MODE and WILL CLEAR SN TIMER");
#endif
    }else{
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_ARKRAY_CMD_INTERVAL taskSel:BLE_TIMER_ARKRAY_CMD_CHECK];
#ifdef DEBUG_LIB
        DLog(@"ARKRAY NEW 1 SN - %@", _bleScanningKey);
#endif
        if ([[ArkrayGBlack sharedInstance] getCurrentDynamicCommand]) {
            [[ArkrayGBlack sharedInstance] arkraySyncCommand];
            // NSLog(@"ARKRAY OLD COMMAND DONE");
        }else{
            [[ArkrayGBlack sharedInstance] h2ArkrayCmdNotFoundTask];
            // NSLog(@"ARKRAY OLD COMMAND NOT FOUND");
        }
#ifdef DEBUG_LIB
        DLog(@"ARKRAY === NORMAL RUN");
#endif
    }
}


@end


