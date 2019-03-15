//
//  LibDelegateFunc.m
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "LibDelegateFunc.h"



#import "STBViewController.h"
#import "TMShowUserId.h"
#import "OmronRecordViewController.h"
#import "MeterTaskViewController.h"

#import "DACollection.h"



@implementation LibDelegateFunc

- (id)init
{
    if (self = [super init]) {
        _cableSerialnumber = @"0";
        _stbTitle = @"NX";
        _indexStatus = 0;
        _syncStatusStringEx = @" ";
        
        _userProfile = [[UserGlobalProfile alloc] init];
        
        _byteStatus = (Byte *)malloc(256);
        
        _bgRecordsResult = [[NSMutableArray alloc] init];
        _bpRecordsResult = [[NSMutableArray alloc] init];
        _bwRecordsResult = [[NSMutableArray alloc] init];
        
        _ldtNewResult = [[NSMutableArray alloc] init];
        
        
        
        _haveFoundBlePeripherals = [[NSMutableArray alloc] init];
        
        _omronRecordsUserA = [[NSMutableArray alloc] init];
        _omronRecordsUserB = [[NSMutableArray alloc] init];
        _omronRecordsUserC = [[NSMutableArray alloc] init];
        _omronRecordsUserD = [[NSMutableArray alloc] init];
        _omronRecordsUserE = [[NSMutableArray alloc] init];
        
        _sdkDefaultBleDevices = [[NSMutableArray alloc] init];
        

        _serverLastDateTimes = [[NSMutableArray alloc] init];
        _bgmInfo = [[H2MeterSystemInfo alloc] init];


        ((H2Sync *)[H2Sync sharedInstance]).libDelegate = (id<H2SyncDelegate >)self;
        NSLog(@"LIB EX INIT ...");
        
        _demoSyncRunning = NO;
        _demoAutoSync = NO;
        _meterTaskAutoSync = NO;
        _stbSync = NO;
        _qrStringCode = [[NSString alloc] init];
        _qrStringCode = @"";
        _syncMsg = [[NSMutableArray alloc] init];
        
        //_recordIndex = [[NSString alloc] init];
        _bgIndexString = [[NSString alloc] init];
        _bpIndexString = [[NSString alloc] init];
        _bwIndexString = [[NSString alloc] init];
        
        _batteryLevelString = [[NSString alloc] init];
        _bleIdentifierString = [[NSString alloc] init];
        
        _equipIdString = [[NSString alloc] init];
        
        _recordSingle = [[NSString alloc] init];
        _loopIndex = [[NSString alloc] init];
        
        _userID = @"A89105";
        _userEMail = @"jChuang@gmail.com";
        
        _h2BleTestLoop = 0;
        _bionimeCount = 0;
        
        _longRunBatterLevel = [[NSString alloc] init];
        _longRunRSSIValue = [[NSString alloc] init];
        _longRunCurrentTime = [[NSString alloc] init];
        _longRunRecordIndex = [[NSString alloc] init];
        
        _middleDateTime = [[NSString alloc] init];
        
        _h2RecordsDataType = 0;
        
        _skipNumbers = [[RecordsSkipped alloc] init];
        _packageForSyncTmp = [[H2PackageForSync alloc] init];
        
    }
    
    return self;
}


/**********************************************************************
 * CABLE STATUS DELEGATE
 *
 *
 ************************************************************************/
#pragma mark - CABLE  AND SYNC STATUS - DELEGATE
- (void)appDelegateCableSyncStatus:(H2SSDKSyncStatus)code
{
    [self demoCableStatusMiddleTask:code withSel:0];
    switch (code) {
        case H2SSDKSyncStatusFail:// = 0, // 同步失敗但不屬於以下情況
            break;
            
        case H2SSDKSyncStatusWithNewRecord: //, // 有新資料
            break;
        case H2SSDKSyncStatusNoNewRecord://, // 沒有新資料
            break;
            
        case H2SSDKSyncStatusBLEDisabled: // = 0xE1, // 藍牙未啟用
            break;
        case H2SSDKSyncStatusBLENotFound://, // 偵測不到 BLE meter 或是 BLE dongle
            break;
        case H2SSDKSyncStatusAuthFailed://, // PIN 輸入錯誤，sync 時，若手機沒有該藍牙裝置時，系統會跳出 PIN 碼給使用者輸入，若輸入錯誤，SDK 會以此來告知
            break;
        case H2SSDKSyncStatusPairTimeout: //, // 與 BLE meter 配對逾時，sync 時，若取消輸入 PIN 碼，或是配對逾時，會以此來告知
            break;
/*
        case H2SSDKSyncStatusDialogNotAppear://, // 沒有出現輸入PIN的對話框
            break;
            
        case H2SSDKSyncStatusCableNotFound://, // 找不到傳輸線(audio cable)
            break;
 */
        case H2SSDKSyncStatusMeterNotFound://,
            break;
            
        default:
            break;
    }
    //if (<#condition#>) {
#if 0
        [NSTimer scheduledTimerWithTimeInterval:BLE_CYCLE_INTERVAL target:self selector:@selector(bleEquipCycleRun) userInfo:nil repeats:NO];
#endif
    //}
    NSLog(@"DEMO-APP SYNC STATUS");
}

- (void)appDelegateCablePairingStatus:(H2SSDKPairStatus)code
{
    [self demoCableStatusMiddleTask:code withSel:1];
    switch (code) {
        case H2SSDKPairStatusBleCableSucceeded: // = 3, // Ble Dongle 配對成功
            break;
        case H2SSDKPairStatusBLEDisabled: // = 0xE1, // 藍牙未啟用
            break;
        case H2SSDKPairStatusBLENotFound: //, // 偵測不到 BLE meter 或是 BLE dongle
            break;
        case H2SSDKPairStatusAuthFailed: //, // PIN 輸入錯誤
            break;
        case H2SSDKPairStatusTimeout: //, // 與 BLE meter 配對逾時
            break;
        //case H2SSDKPairStatusDialogNotAppear:
        //    break;
        default:
        break;
    }
    NSLog(@"DEMO-APP PAIR STATUS");
}

- (void)appDelegateCableDevelop:(H2SSDKDevelopStatus)code
{
    [self demoCableStatusMiddleTask:code withSel:2];
    switch (code) {
        case H2SSDKDevlopStatusMeterID: // = 0x21, // MID 和 FUNCTION 不一致
        case H2SSDKDevlopStatusMeterFunc: //, // 設備無此項功能
        case H2SSDKDevlopStatusUserTag: //, // User Tage 超過此設備最大數
        case H2SSDKDevlopStatusDataType: //, // 設備無提供此項資料
        case H2SSDKDevlopStatusKey: //, // NSDictionary key 沒有找到
        case H2SSDKDevlopStatusBLECableSN: //, // Ble Cable 序號長度問題
            break;
/*
        case H2SSDKDevlopStatusSwitchOn: // = 0x81,
        case H2SSDKDevlopStatusSwitchOff: //,
        case H2SSDKDevlopStatusUart: //,
        case H2SSDKDevlopStatusAuxility: //,
        case H2SSDKDevlopStatusExisting: //,
        case H2SSDKDevlopStatusFwVersion: //,
        case H2SSDKDevlopStatusAck: //,
        case H2SSDKDevlopStatus_8: //,
        case H2SSDKDevlopStatus_9: //,
        case H2SSDKDevlopStatusSnAudio: //,
        case H2SSDKDevlopStatusSnBle: //,
            break;
*/
        default:
            break;
    }
}

- (void)demoCableStatusMiddleTask:(UInt8)code withSel:(UInt8)sel{
    NSLog(@"BLE DEMO STATUS %02X, WHAT = %@, and SEL = %d", code, _syncStatusStringEx, sel);
    NSString *string = [NSString stringWithFormat:@"%02X", code];
    //_syncStatusString = [NSString stringWithFormat:@"%02X", code];
    switch (sel) {
        case 0:
            _syncStatusStringEx = [_syncStatusStringEx stringByAppendingString:@" S"];
            break;
            
        case 1:
            _syncStatusStringEx = [_syncStatusStringEx stringByAppendingString:@" P"];
            break;
            
        case 2:
            _syncStatusStringEx = [_syncStatusStringEx stringByAppendingString:@" D"];
            break;
            
        default:
            break;
    }
    
    _syncStatusStringEx = [_syncStatusStringEx stringByAppendingString:string];
    
    _byteStatus[_indexStatus] = code;
    _indexStatus++;
    
    
    [NSTimer scheduledTimerWithTimeInterval:STATUS_INTERVAL target:self selector:@selector(demoNotifyStatus) userInfo:nil repeats:NO];
}


- (void)demoNotifyStatus
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE_CABLE_STATUS" object:self];
}



#pragma mark - BLE Device Found (PAIRING) STATUS - DELEGATE
- (void)appDelegateBleDevicesHaveFound:(NSMutableArray *)blePeripherals
{
    NSLog(@"HAVE FOUND BLE ....");
    NSString *deviceId;
    NSMutableArray *peripheralsArray = [[NSMutableArray alloc] init];
    NSLog(@"THE PERIPHERALS NUMBER IS %d ", (int)[blePeripherals count]);
    if ([_haveFoundBlePeripherals count] > 0) {
        [_haveFoundBlePeripherals removeAllObjects];
    }
    
    for (ScannedPeripheral *sensor in blePeripherals) {
        NSLog(@"NEW SENSOR %@", sensor);
        [_sdkDefaultBleDevices addObject:sensor];
    }
#if 0 // Crash ...
    [[NSUserDefaults standardUserDefaults] setObject:_sdkDefaultBleDevices  forKey:@"UDEF_BLE_TOTALLY"];
    
    NSArray *tmpDevices = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_BLE_TOTALLY"];
    for (ScannedPeripheral *sensor in tmpDevices) {
        NSLog(@"BLE SDK -- NAME IS %@", sensor.name);
        NSLog(@"BLE SDK -- RSSI IS %d", sensor.RSSI);
        NSLog(@"BLE SDK -- PERIPHERAL IS %@", sensor.peripheral);
        NSLog(@"BLE SDK -- MAC IS %@", sensor.peripheral.identifier);
    }
#endif
    NSString *newSerialNumber;
    NSString *newIdentifier;
    for (ScannedPeripheral *sensor in blePeripherals) {
        NSLog(@"BLE DEMO -- NAME IS %@", sensor.name);
        NSLog(@"BLE DEMO -- RSSI IS %d", sensor.RSSI);
        NSLog(@"BLE DEMO -- PERIPHERAL IS %@", sensor.peripheral);
        NSLog(@"BLE DEMO -- MAC IS %@", sensor.peripheral.identifier);
        
        NSString *pstr = [NSString stringWithFormat:@"%p", sensor.peripheral];
        NSLog(@"BLE DEMO -- PERIPHERAL ADDRESS is %@", pstr, nil);

        deviceId = [sensor.peripheral.identifier UUIDString];
        NSLog(@"BLE DEMO -- MAC STRING IS %@", deviceId);
        
        NSLog(@"BLE DEMO -- MAC STRING 2 IS %@", sensor.bleScanIdentifier);
        NSLog(@"BLE DEMO -- SN STRING IS %@", sensor.bleScanSerialNumber);
        
        NSLog(@"BLE DEMO -- MODEL STRING IS %@", sensor.bleScanModel);
        
        newSerialNumber = sensor.bleScanSerialNumber;
        newIdentifier = sensor.bleScanIdentifier;
        
        NSDictionary *bleInfo =
        @{
          @"BLE_SERIALNUMBER":sensor.bleScanSerialNumber,
          @"BLE_IDENTIFIER":sensor.bleScanIdentifier
        };
        [peripheralsArray addObject:bleInfo];
        [_haveFoundBlePeripherals addObject:sensor];
    }
    
    NSLog(@"PERIPHERALS IS %@", peripheralsArray);
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_HAVE_FOUND" object:self];
}

/********************************
 * ARKRAY DEBUG
 *
 *
 *******************************/
- (void)debugArkraySecretData:(Byte *)secretData
{
    NSString *tmpString = [[NSString alloc] init];
    for (int i=0; i<32; i++) {
        NSLog(@"APP-DEBUG %d = %02X", i, secretData[i]);
        tmpString = [tmpString stringByAppendingString:[NSString stringWithFormat:@"%02X ", secretData[i]]];
    }
    // Array Process ...
    [[DACollection sharedInstance].arkrayGlobalArray addObject:tmpString];
    [[DACollection sharedInstance] saveDataToFile:[DACollection sharedInstance].arkrayGlobalArray withFileName:@"AK"];
}

/*******************************************************************
 * AUDIO CABLE : BATTERY, SN, FW
 * AUDIO CABLE : BATTERY, SN, FW,  BLE-ID DELEGATE
 * BLE METER : BATTERY, SN, BLE-ID DELEGATE
 ******************************************************************/
#pragma mark - BATTERY LEVEL, SERIAL NUMBER, BLE IDENTIFIER
- (void)appDelegateBatteryAndDynamicInfo:(BatDynamicInfo *)dynamicInfo
{
    NSLog(@"DEMO DYNAMIC INFO BATTERY : %d", dynamicInfo.batteryLevel);
    NSLog(@"DEMO DYNAMIC INFO NAME : %@", dynamicInfo.bleLocalName);
    NSLog(@"DEMO DYNAMIC INFO MODEL : %@", dynamicInfo.model);
    NSLog(@"DEMO DYNAMIC INFO SN : %@", dynamicInfo.serialNumber);
    NSLog(@"DEMO DYNAMIC INFO ID : %@", dynamicInfo.bleIdentifier);
    switch (dynamicInfo.devType) {
        case DYNAMIC_AUDIO:
            _bleIdentifierString = [NSString stringWithFormat:@"AUDIO CABLE"];
            break;
        case DYNAMIC_DONGLE:
        case DYNAMIC_BLE_METER:
            _bleIdentifierString = [NSString stringWithFormat:@"B_ID : %@", dynamicInfo.bleIdentifier];
            break;
            
        default:
            _bleIdentifierString = [NSString stringWithFormat:@"B_ID ERROR"];
            break;
    }
    _batteryLevelString = [NSString stringWithFormat:@"BAT %d/%04X ,%@", dynamicInfo.batteryLevel, dynamicInfo.batteryRawData, dynamicInfo.serialNumber];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BATTERY_NOTIFICATION" object:self];
}

/*****************************************************************************
 * METER INFO : SN, CT, MODEL
 *
 * Show Meter Brand, Model, Serial Number, Version, Current Time or Sugar Unit
 *
 *****************************************************************************/
#pragma mark -METER INFORMATION - DELEGATE
- (void)appDelegateMeterInfo:(H2MeterSystemInfo *)devInfo
{
    _bgmInfo = devInfo;
    [[H2Sync sharedInstance] appStartRecordSync:nil]; // Get Records From Meter
    //[[H2Sync sharedInstance] appTerminateBleFlow];
    
    if (devInfo.smWantToReadRecord){
        NSLog(@"WANT TO SYNC, %@", _bgmInfo);
    }else{
        NSLog(@"APP - DON'T WANT TO SYNC");
    }
}






/*************************************************************
 * TOGGLE While Reading reocrds from Meter
 *
 *
 ************************************************************/
#pragma mark - CURRENT RECORD's INDEX - DELEGATE
- (void)appChkBgRecordIndex:(UInt16)bgIndex
{
    _bgIndexString = [NSString stringWithFormat:@"%03d", bgIndex];
    NSLog(@"APP BG INDEX = %@", _bgIndexString);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"INDEX_OAD_RECORD" object:self];
}
- (void)appChkBpRecordIndex:(UInt16)bpIndex
{
    _bpIndexString = [NSString stringWithFormat:@"%03d", bpIndex];
    NSLog(@"BP INDEX = %@", _bpIndexString);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"INDEX_OAD_RECORD" object:self];
}
- (void)appChkBwRecordIndex:(UInt16)bwIndex
{
    _bwIndexString = [NSString stringWithFormat:@"%03d", bwIndex];
    NSLog(@"BW INDEX = %@", _bwIndexString);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"INDEX_OAD_RECORD" object:self];
}




- (void)appDelegateRecordsSkip:(RecordsSkipped *)numbers
{
    NSLog(@"BG SKIP = %02d", numbers.bgSkip);
    NSLog(@"BP SKIP = %02d", numbers.bpSkip);
    NSLog(@"BW SKIP = %02d", numbers.bwSkip);
    
    // debug
    _skipNumbers.bgSkip = numbers.bgSkip;
    _skipNumbers.bpSkip = numbers.bpSkip;
    _skipNumbers.bwSkip = numbers.bwSkip;
}












#pragma mark - TOTOL RECORDS (BG, BP, BW)
- (void)appDelegateGetMeterRecordData:(NSDictionary *)records
{
    NSArray *bgRecords = [records objectForKey: @"bg_records"];
    NSArray *bpRecords = [records objectForKey: @"bp_records"];
    NSArray *bwRecords = [records objectForKey: @"bw_records"];
    
    // Clear and Update Records Buffer
    // BG
    if([_bgRecordsResult count] > 0){
        [_bgRecordsResult removeAllObjects];
    }
    // BP
    if([_bpRecordsResult count] > 0){
        [_bpRecordsResult removeAllObjects];
    }
    // BW
    if([_bwRecordsResult count] > 0){
        [_bwRecordsResult removeAllObjects];
    }
    [_bgRecordsResult addObjectsFromArray:bgRecords];
    [_bpRecordsResult addObjectsFromArray:bpRecords];
    [_bwRecordsResult addObjectsFromArray:bwRecords];
    
#if 0
    for (H2BgRecord *bg in bgRecords) {
        NSLog(@"APP BG -- %@ DATE-TIME", bg.bgDateTime);
        NSLog(@"APP BG  -- %02X UID", bg.meterUserId);
        NSLog(@"APP BG -- %@", bg.bgValue);
        NSLog(@"APP BG -- %@ Flag", bg.bgMealFlag);
        NSLog(@"APP BG -- %@ UNIT", bg.bgUnit);
        NSLog(@"APP BG -- %d IDX", bg.bgIndex);
        NSLog(@"\n\n");
    }
    
#endif
    
    for (H2BpRecord *bp in bpRecords) {
        NSLog(@"APP BP - %@", bp);
        NSLog(@"APP BP - %02X", bp.meterUserId);
        NSLog(@"APP BP - %@", bp.bpDateTime);
        NSLog(@"APP BP - %@ %@", bp.bpSystolic, bp.bpUnit);
        NSLog(@"APP BP - %@ %@", bp.bpDiastolic, bp.bpUnit);
        NSLog(@"APP BP - %@ times/min", bp.bpHeartRate_pulmin);
        NSLog(@"\n\n");
    }
    
   
    for (H2BwRecord *bw in bwRecords) {
        NSLog(@"APP BW - %@", bw);
        NSLog(@"APP BW UID - %02X", bw.meterUserId);
        NSLog(@"APP BW 體重 - %@", bw.bwWeight);
        NSLog(@"APP BW BMI - %@", bw.bwBmi);
        NSLog(@"APP BW 肥 - %@", bw.bwFat);
        NSLog(@"APP BW 肌 - %@", bw.bwSkeletalMuscle);
        NSLog(@"\n\n");
    }
    
    // GET LDT
    [[H2Sync sharedInstance] appGetLastDateTime];
}


/*
 {
 "LDT_DateTime" = "2017-11-03 17:03:00 +0000";
 "LDT_DidSyncError" = NO;
 "LDT_Model" = "";
 "LDT_NrIndexOfRecord" = 500;
 "LDT_NrRecordType" = 1;
 "LDT_NrUserTag" = 1;
 "LDT_SerialNumber" = 040011BD;
 "LDT_SkipBgRecords" = 000;
 "LDT_SkipBpRecords" = 000;
 "LDT_SkipBwRecords" = 000;
 }
 */

/*****************************************************************************
 * @fn : REPORT  RECORD LAST DATE TIME
 *
 *
 *
 *****************************************************************************/
- (void)appDelegateLastDateTimeArray:(NSMutableArray *)ldtArray
{
    NSString *newSerialNr;
    
    NSNumber *nrDataType = [NSNumber numberWithInt:0];
    NSNumber *nrUserTag = [NSNumber numberWithInt:0];
    NSNumber *nrLdtIndex = [NSNumber numberWithInt:0];
    
    
    NSString *svrSerialNr;
    
    NSNumber *nrSvrDataType = [NSNumber numberWithInt:0];
    NSNumber *nrSvrUserTag = [NSNumber numberWithInt:0];
    NSNumber *nrSvrLdtIndex = [NSNumber numberWithInt:0];
    
    BOOL newEquipment = YES;
    UInt8 svrObjIndex = 0;
    UInt8 sdkIndex = 0;
    
    if([_ldtNewResult count] > 0){
        [_ldtNewResult removeAllObjects];
    }
    
    
    for (NSDictionary *newDateTime in ldtArray) {
        [_ldtNewResult addObject:newDateTime];
    }
    
    
    if ([_serverLastDateTimes count] > 0) {
        for (NSDictionary *newDateTime in ldtArray) { // NEW LDT LOOP
            NSLog(@"APP LDT =  %@", newDateTime);
            newSerialNr =[newDateTime objectForKey: @"LDT_SerialNumber"];
            
            nrDataType = [newDateTime objectForKey: @"LDT_NrRecordType"];
            nrUserTag = [newDateTime objectForKey: @"LDT_NrUserTag"];
            nrLdtIndex = [newDateTime objectForKey: @"LDT_NrIndexOfRecord"];
            
            NSLog(@"APP NEW TYPE - %@, %d", nrDataType, [nrDataType intValue]);
            NSLog(@"APP NEW TAG - %@, %d", nrUserTag, [nrUserTag intValue]);
            NSLog(@"APP NEW IDX - %@, %d", nrLdtIndex, [nrLdtIndex intValue]);
            NSLog(@"\n");
            
            svrObjIndex = 0;
            newEquipment = YES;
            for (NSDictionary *svrDateTime in _serverLastDateTimes){ // SVR LOOP
                svrSerialNr = [svrDateTime objectForKey: @"LDT_SerialNumber"];
                
                nrSvrDataType = [svrDateTime objectForKey: @"LDT_NrRecordType"];
                nrSvrUserTag  = [svrDateTime objectForKey: @"LDT_NrUserTag"];
                nrSvrLdtIndex  = [svrDateTime objectForKey: @"LDT_NrIndexOfRecord"];
                
                NSLog(@"APP SVR TYPE - %@, %d", nrSvrDataType, [nrSvrDataType intValue]);
                NSLog(@"APP SVR TAG - %@, %d", nrSvrUserTag, [nrSvrUserTag intValue]);
                NSLog(@"APP SVR IDX - %@, %d", nrSvrLdtIndex, [nrSvrLdtIndex intValue]);
                NSLog(@"\n");
                
                if ([newSerialNr isEqualToString:svrSerialNr] &&
                    //NSLog(@"SN %@, %@", newSerialNr, svrSerialNr);
                    nrDataType == nrSvrDataType &&// CHECKING TYPE
                        //NSLog(@"DATA TYPE %@, %@", nrDataType, nrSvrDataType);
                    nrUserTag == nrSvrUserTag) { // CHECKING TAG
                            NSLog(@"USER ID %@, %@", nrUserTag, nrSvrUserTag);
                            NSLog(@"LDT DONE ...");
                    newEquipment = NO;
                    [_serverLastDateTimes replaceObjectAtIndex:svrObjIndex withObject:newDateTime];
                    break;
                }
                svrObjIndex++;
            }
            
            if (newEquipment) {
                NSLog(@"APP NEW LDT = %@", newDateTime);
                [_serverLastDateTimes addObject:newDateTime];
            }
            NSLog(@"OBJ SDK IDX %d and SVR IDX %d", sdkIndex, svrObjIndex);
            sdkIndex++;
        }
    }else{
        for (NSDictionary *newDateTime in ldtArray) {
            NSLog(@"LDT =  %@", newDateTime);
            [_serverLastDateTimes addObject:newDateTime];
        }
    }
    
    NSLog(@"TOTAL LDT IS %02X, %@", (int)[_serverLastDateTimes count], _serverLastDateTimes);
}



- (void)demoDefaultLDT
{
    NSNumber *nrIndex = [NSNumber numberWithInt:1];
    NSNumber *nrRecordType = [NSNumber numberWithInt:1];
    NSNumber *nrUserTag = [NSNumber numberWithInt:1];
    
    NSDictionary *lastDateTime = @{
                     //@"LDT_DateTime" :  @"2017-04-07 08:27:00 +0000", // Date and Time String
                     @"LDT_DateTime" :  @"2015-07-08 17:30:00 +0000", // Date and Time String
                     @"LDT_Model" :@"",
                     @"LDT_SerialNumber" : @"WW004210",
                     //@"LDT_NrSkipBgRecords" : nrSkipBgRecords, // Totol Skip BG Records(Time Error)
                     //@"LDT_NrSkipBpRecords" : nrSkipBpRecords, // Totol Skip BP Records(Time Error)
                     //@"LDT_NrSkipBwRecords" : nrSkipBwRecords, // Totol Skip BW Records(Time Error)
                     
                     @"LDT_NrIndexOfRecord" : nrIndex,
                     @"LDT_NrRecordType": nrRecordType, // Record Type
                     //@"LDT_RecordType": nrRecordType, // Record Type
                     @"LDT_NrUserTag": nrUserTag// Meter User ID
                     };
    
    [_serverLastDateTimes addObject:lastDateTime];
    /*
    {
        "LDT_DateTime" = "2017-04-07 08:27:00 +0000";
        "LDT_Model" = "";
        "LDT_NrIndexOfRecord" = 0;
        "LDT_NrRecordType" = 1;
        "LDT_NrSkipBgRecords" = 0;
        "LDT_NrSkipBpRecords" = 0;
        "LDT_NrSkipBwRecords" = 0;
        "LDT_NrUserTag" = 1;
        "LDT_SerialNumber" = 3780OHA3058;
    }
     */
}
/*
 {
 "LDT_DateTime" = "2015-08-08 17:30:00 +0000";
 "LDT_Model" = "";
 "LDT_NrIndexOfRecord" = 0;
 "LDT_NrRecordType" = 1;
 "LDT_NrSkipBgRecords" = 0;
 "LDT_NrSkipBpRecords" = 0;
 "LDT_NrSkipBwRecords" = 0;
 "LDT_NrUserTag" = 1;
 "LDT_SerialNumber" = WW004210;
 }
 
 */


#pragma mark - Error Message Record
- (void)debugMessageForUsers:(NSDictionary *)syncInfoMessage{
    
    NSLog(@"APP BLE SYNC MSG : %@", syncInfoMessage);
    _bionimeCount++;
    
    //[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(bionimeLoop) userInfo:nil repeats:NO];
    if ([_syncMsg count] > 0) {
        [_syncMsg removeAllObjects];
    }

    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoCableStatus"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoBatteryValue"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoAudioDetect"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoRocheNakTimes"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoSystemCommandBuffer"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoMeterCommandBuffer"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoCurrentCommandHeader"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoCurrentGlobalBuffer"]];
    
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoMeterBrand"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoMeterModel"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoMeterSerialNumber"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoMeterVersion"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncInfoSdkAndFWVer"]];
    
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncMeterId"]];
    [_syncMsg addObject:[syncInfoMessage objectForKey: @"syncBleLocalName"]];
    
    // WRITE FILE TEST
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSDate *h2CurrentDateTime =  [[NSDate alloc] init];
    NSString *currentDateTime = [NSString stringWithFormat:@"%@", h2CurrentDateTime];
    
    NSString *h2CurrentDate = [currentDateTime substringWithRange:NSMakeRange(0, 10)];
    NSString *h2CurrentTime = [currentDateTime substringWithRange:NSMakeRange(11, 8)];
    
    
    NSLog(@"DATE IS %@, TIME IS %@", h2CurrentDate, h2CurrentTime);
    
    NSString *logFile = [NSString stringWithFormat:@"%@_%@_%@",_qrStringCode, h2CurrentDate, h2CurrentTime];
    
    
    NSString *qrFileName = [NSString stringWithFormat:@"Documents/%@.txt",logFile];
    
    // Added By Jason
    // Create paths to output images
    NSString  *logFilePath = [NSHomeDirectory() stringByAppendingPathComponent:qrFileName];
    
    // Write image to PNG
    [syncInfoMessage writeToFile:logFilePath atomically:YES];
}


#pragma mark - SINGLE RECORD - DELEGATE
- (void)appChkBgSingleRecord:(H2BgRecord *)bgRecord
{
    NSLog(@"APP BG (NEW) SINGLE : %@", bgRecord);
    NSLog(@"APP BG SINGLE : %@", bgRecord);
    
    _singleRecordValue = [NSString stringWithFormat:@"IDX : %03d, VAL : %@ %@", bgRecord.bgIndex, bgRecord.bgValue, bgRecord.bgUnit];
    _singleRecordDateTime = [NSString stringWithFormat:@"%@", bgRecord.bgDateTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SINGLE_RECORD_NOTIFICATION" object:self];
}

- (void)appChkBpSingleRecord:(H2BpRecord *)bpRecord
{
    NSLog(@"APP BP SINGLE : %@", bpRecord);
    
    _singleRecordValue = [NSString stringWithFormat:@"IDX : %03d, VAL : %@, %@ %@", bpRecord.bpIndex, bpRecord.bpSystolic, bpRecord.bpDiastolic, bpRecord.bpUnit];
    _singleRecordDateTime = [NSString stringWithFormat:@"%@", bpRecord.bpDateTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SINGLE_RECORD_NOTIFICATION" object:self];
}

- (void)appChkBwSingleRecord:(H2BwRecord *)bwRecord
{
    NSLog(@"APP BW SINGLE : %@", bwRecord);
    _singleRecordValue = [NSString stringWithFormat:@"IDX : %03d, VAL : %@ %@", bwRecord.bwIndex, bwRecord.bwWeight, bwRecord.bwUnit];
    _singleRecordDateTime = [NSString stringWithFormat:@"%@", bwRecord.bwDateTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SINGLE_RECORD_NOTIFICATION" object:self];
}

#pragma mark - OAD REPORT
- (void)appDelegateOadWriteStatus:(UInt16)deno withFraction:(UInt16)fraction
{
    NSLog(@"THE DENO IS %d and FRACTION IS %d", deno, fraction);
    
    NSString *denoAndFraction;
    denoAndFraction = [NSString stringWithFormat:@"%d / %d", fraction, deno];
    [[STBViewController sharedInstance] stbViewSetIndex:denoAndFraction withIndexLoop:(BLE_TEST_LOOP_TARGET -_h2BleTestLoop)];
    
    _bgIndexString = denoAndFraction;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"INDEX_OAD_RECORD" object:self];
}

#pragma mark - LONG RUN TEST
- (void)h2LibLongRun
{
    //[[BLEViewController sharedInstance] bleLongRunTest];
}

- (void)appGetRecordsAndLastDateTime
{
    [[H2Sync sharedInstance] appGetLastDateTime];
    NSLog(@"APP GET RECORDS AND LDT - (NEW)");
}

#pragma mark - USER ID AREA
- (void)demoAppDelegateReportUserTag:(UInt8)userTagStatus
{
    NSLog(@"Report User ID Here ...., %02X == DEMO", userTagStatus);
    _omronUserIdFromEquipment = userTagStatus;
    NSLog(@"SOURCE ID %d", _omronUserIdFromEquipment);
    
//#ifdef SKIP_SET_UID
    //[[H2Sync sharedInstance] appOmronSetUserTag:1];//_userTag];
    NSLog(@"WILL DO NOTHING ...");
//#else
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OMRON_USER_ID_NOTIFICATION" object:self];
//#endif
}



#pragma mark - ARKYAT PROCESS AREA
- (void)appDelegateArkrayPasswordRequest
{
    NSLog(@"ARKRAY SHOW DIALOG -- NOW");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ARKRAY_NOTIFICATION" object:self];
}

#pragma mark - BLE EQUIPMENT CYCLE
- (void)bleEquipCycleRun
{
    [[MeterTaskViewController sharedInstance] bleSyncTask:nil];
    NSLog(@"BLE EQUIP CYCLE RUN");
}

- (void)demoGlobalSync
{
    // syncStatus =
    [[H2Sync sharedInstance] appGlobalPreSync:_packageForSyncTmp];
}

#pragma mark - BIONIME GM700SB LOOP
- (void)bionimeLoop
{
    // TO DO ...
    [[MeterTaskViewController sharedInstance] bionimePairAgain];
}
+ (LibDelegateFunc *)sharedInstance
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
    NSLog(@"LIB DELEGATE AND FUNC INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}
@end
// Advertisement DATA is  {
// kCBAdvDataIsConnectable = 1;
// kCBAdvDataLocalName = "OneTouch QVB0";
// kCBAdvDataManufacturerData = <6d010200 a39e514a 57a0e5b6 ebfa85ea 0aaa1db4>;
// kCBAdvDataManufacturerData = <6d010200 706a4405 abd52524 d7e06df6 f5b21df7>;
// kCBAdvDataServiceUUIDs =     (
//                               "Device Information"
//                               );
// }
// kCBAdvDataManufacturerData = <06000109 200255c4 50a0a380 908a3d00 07059dad 755c1f76 d5c90584 c4>;
// kCBAdvDataManufacturerData = <06000109 20004ede 1a14f0c8 39315add aaefff41 b36fa19f 315fcb62 0e>;
// kCBAdvDataManufacturerData = <06000109 20026e6a 95a25bb7 c6843bea d2b6c5a6 6c68bc06 50c000c8 69>;

