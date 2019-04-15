//
//  ViewController.m
//  h2Central
//
//  Created by h2Sync on 2015/1/23.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "ScannedPeripheral.h"
#import "H2BleCentralManager.h"

#import "h2Sync.h"
#import "H2DataFlow.h"
#import "H2CableFlow.h"

#import "H2BleEquipId.h"
#import "H2BleProfile.h"
#import "H2BleService.h"

#import "H2BgmCable.h"

#import "H2BleHmd.h"
#import "H2BleOad.h"
#import "Fora.h"
#import "ForaD40.h"

#import "BleBtm.h"
#import "ARKRAY_GT-1830.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"
#import "H2Config.h"
#import "OMRON_HEM-7280T.h"
#import "OMRON_HEM-9200T.h"

#import "H2BleTimer.h"
#import "H2Timer.h"
#import "H2Records.h"


#pragma mark - Device Information Service


@interface H2BleCentralController () <H2BleCentralControllerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSTimer *h2BleStopTimer;
    //NSString *tmpStringBleId;
    BOOL scanMode;
}

@property (nonatomic, strong) CBCharacteristic *h2_CharacteristicCurrent;
@property (nonatomic, readwrite) Byte h2CableIndex;

@end


@implementation H2BleCentralController

@synthesize blePeripherals;


- (void)h2CentralManagerAlloc
{
    _h2CentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
#ifdef DEBUG_LIB
    DLog(@"BLE Central Manager ALLOC");
#endif
}


- (id)init
{
#ifdef DEBUG_LIB
    _rssiCount = 0;
    _rssiValue = 0;
    _rssiValueAvage = 0;
    DLog(@"DEBUG_LIB BLE init .... PRE");
#endif
    if (self = [super init]) {

        [H2BleService sharedInstance];
        //tmpStringBleId = @"";
        
        // Do any additional setup after loading the view.
        blePeripherals = [NSMutableArray arrayWithCapacity:PERIPHERALS_MAX];
        
        _didSkipBLE = NO;
        _bleCanncelConnect = NO;
        
        _blePeripheralsHaveFound = [[NSMutableArray alloc] init];
        //_multiPeriperial = 0;
        _currentPeriperialIndex = 0;
        
        h2BleStopTimer = [[NSTimer alloc] init];
        
        _bleCentralPowerOn = NO;
        _h2CentralManager = nil;
        
#ifdef DEBUG_LIB
        DLog(@"BLE CENTRAL CONTROLLER INIT");
#endif
    }
    return self;
}

/*
*-------------------------------------------------------------
* The CBCentral Manager Delegate Method
*
*
*-------------------------------------------------------------
*/
#pragma mark - The CBCentralManager delegate Method
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
#ifdef DEBUG_LIB
    DLog(@"BLE CENTRAL STATE %@", central);
#endif
    
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
#ifdef DEBUG_LIB
            DLog(@"CB-STATE -- UNKNOWN");
#endif
            break;
            
        case CBCentralManagerStateResetting:
#ifdef DEBUG_LIB
            DLog(@"CB-STATE -- RESETTING");
#endif
            return;
            
        case CBCentralManagerStateUnsupported:
#ifdef DEBUG_LIB
            DLog(@"CB-STATE -- UNSUPPORTED");
#endif
            break;
            
        case CBCentralManagerStateUnauthorized:
#ifdef DEBUG_LIB
            DLog(@"CB-STATE -- UNAUTHORIZED");
#endif
            break;
            
        case CBCentralManagerStatePoweredOff:
            _bleCentralPowerOn = NO;
            [self h2BleConnectReport:FAIL_BLE_PHONE_OFF];
#ifdef DEBUG_LIB
            DLog(@"CB-STATE -- POWEROFF");
#endif
            return;
            
        case CBCentralManagerStatePoweredOn:
            _bleCentralPowerOn = YES;
#ifdef DEBUG_LIB
            DLog(@"CB-STATE -- POWERON");
#endif
            return;
            
        default:
#ifdef DEBUG_LIB
            DLog(@"CB-STATE -- DEFAULT");
#endif
            break;
    }
    
    [self h2BleConnectReport:FAIL_BLE_UNKNOWN];

}

#pragma mark - H2 BLE Status Method

- (void)h2BgmCableSyncBegin
{
#ifdef DEBUG_LIB
    DLog(@"H2 CABLE BEGIN ...");
#endif
    // CLEAR READ SN TIMER
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
#ifdef DEBUG_LIB
        DLog(@"H2 CABLE BEGIN ... CANNEL SN TIMER");
#endif
    
    @autoreleasepool {
        if ([self.bleDelegate conformsToProtocol:@protocol(H2BleCentralControllerDelegate)] &&
            [self.bleDelegate respondsToSelector:@selector(h2BleCableSyncEvent)])
        {
            [self.bleDelegate h2BleCableSyncEvent];
#ifdef DEBUG_LIB
            DLog(@"Did come to CABLE SYNC EVENT .... 2");
#endif
        }
    }
}


- (void)h2BleSetDeviceSerialNumber:(NSString *)snString
{
#ifdef DEBUG_LIB
    DLog(@"BLE - SET OMRON LOCAL NAME - %@", snString);
#endif
    ((ScannedPeripheral *)blePeripherals[0]).bleScanSerialNumber = snString;
    ScannedPeripheral *sensor = [blePeripherals objectAtIndex:0];
    [_blePeripheralsHaveFound addObject:sensor];
}

- (void)h2BleConnectMultiDevice
{
#ifdef DEBUG_LIB
    DLog(@"BLE - CONNECT MULTI DEVICE");
#endif
    [H2BleService sharedInstance].bleConnected = NO;
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        [H2BleService sharedInstance].blePairingStage = NO;
        return;
    }
#ifdef DEBUG_LIB
    DLog(@"DEBUG - DEAD 1");
#endif
    if ([blePeripherals count] > 0) {
        if (!([h2MeterModelSerialNumber sharedInstance].smSerialNumber == nil || [[h2MeterModelSerialNumber sharedInstance].smSerialNumber isEqualToString:@""])) {
            
            ScannedPeripheral *tmpPeripheral = [blePeripherals objectAtIndex:_currentPeriperialIndex];
            tmpPeripheral.bleScanSerialNumber = [h2MeterModelSerialNumber sharedInstance].smSerialNumber;
            
            tmpPeripheral.bleScanModel = @"";
            [_blePeripheralsHaveFound addObject:tmpPeripheral];
        }
    }else{
        [self h2BleConnectReport:FAIL_BLE_NOT_FOUND];
        [H2BleService sharedInstance].blePairingStage = NO;
        return;
    }
    
#ifdef DEBUG_LIB
    DLog(@"DEBUG - DEAD 2");
#endif
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = @"";
    [H2BleService sharedInstance].bleTempModel = @"";
#ifdef DEBUG_LIB
    DLog(@"DEBUG - DEAD 3");
#endif
    if([H2DataFlow sharedDataFlowInstance].equipId != SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX){
        [self H2BleCentralCanncelConnect:((ScannedPeripheral *)blePeripherals[_currentPeriperialIndex]).peripheral];
    }
    
    _currentPeriperialIndex++;
    if ([blePeripherals count] > _currentPeriperialIndex) {
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_CONNECT_INTERVAL taskSel:BLE_TIMER_BLE_CONNECT_MODE];
        [H2BleService sharedInstance].bleNormalDisconnected = NO;
        [H2BleService sharedInstance].bleMultiDeviceCanncel = YES;
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(goToNextBleDevice) userInfo:nil repeats:NO];
        
        //[self.h2CentralManager connectPeripheral:((ScannedPeripheral *)blePeripherals[_currentPeriperialIndex]).peripheral options:nil];
        [H2BgmCable sharedInstance].didWantToGetSN = YES;
        
#ifdef DEBUG_LIB
        DLog(@"SET SN TIMER -- AT CONNECT MULTIDEVICE");
#endif
    }else{ // SCAN FINISHED
        //[H2BleService sharedInstance].blePairingStage = NO;
        if ([H2BleService sharedInstance].bleSerialNumberStage) {
            // No Correct BLE has found
            [self h2BleConnectReport:FAIL_BLE_NOT_FOUND];
#ifdef DEBUG_LIB
            DLog(@"NO BLE be found in Sync Stage");
#endif
        }else{
            // TO DO : SHOW DEVICE WITH SN, NAME, WE HAVE FOUND, SELECTED BY USER
            [H2BgmCable sharedInstance].didWantToGetSN = NO;
            // check if sn is empty
            if ([_blePeripheralsHaveFound count] > 0) {
                if([H2DataFlow sharedDataFlowInstance].equipId != SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX){
                    [NSTimer scheduledTimerWithTimeInterval:BLE_PAIRING_REPORT_DELAY_TIME target:self selector:@selector(H2ReportBleDeviceTimeOut) userInfo:nil repeats:NO];
                }
            }else{
                [self h2BleConnectReport:FAIL_BLE_NOT_FOUND];
                [H2BleService sharedInstance].blePairingStage = NO;
            }
        }
    }
#ifdef DEBUG_LIB
    if ([_blePeripheralsHaveFound count] > 0) {
        DLog(@"PERIPHERALS HAVE FOUND %@ ", _blePeripheralsHaveFound);
    }
#endif
}

- (void)goToNextBleDevice
{
    [self.h2CentralManager connectPeripheral:((ScannedPeripheral *)blePeripherals[_currentPeriperialIndex]).peripheral options:nil];
}

- (void)H2ReportBleDeviceTimeOut
{
#ifdef DEBUG_LIB
    DLog(@"REPORT BLE DEVICE - TIME OUT");
#endif
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
    [[H2Sync sharedInstance] sdkBleDeviceList:_blePeripheralsHaveFound];
}


- (void)h2BleScanDevEnd
{
    // Stop BLE Scan
    scanMode = NO;
    [self.h2CentralManager stopScan];
    if ([H2SyncStatus sharedInstance].cableSyncStop) {
        return;
    }
    
    if ([blePeripherals count] > 0) {
        [H2BleService sharedInstance].bleScanDeviceCount = [blePeripherals count];
    }
    
#ifdef DEBUG_LIB
    if ([blePeripherals count] > 0) {
        DLog(@"DEBUG_BLE Scanning stopped For TimerOut %ld", (unsigned long)[blePeripherals count]);
    }
    if ([H2BleService sharedInstance].blePairingStage) {
        // DO SOMETHING ...
        DLog(@"DEBUG_BLE PAIRING ...");
    }
#endif
    
    if ([H2BleService sharedInstance].didUseH2BLE) {
        if ([blePeripherals count] > 0){
            if ([blePeripherals count] > 1) {
                // Normally, do not come here ...
                // OR show ERROR
                [self H2ReportBleDeviceTimeOut];
            }else{
                [self.h2CentralManager connectPeripheral:((ScannedPeripheral *)blePeripherals[0]).peripheral options:nil];
                // FOR TEST
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_CONNECT_INTERVAL taskSel:BLE_TIMER_BLE_CONNECT_MODE];
#ifdef DEBUG_LIB
                DLog(@"BLE_DEBUG CABLE MODE SET TIMER ...");
#endif
            }
        }
    }else{
        if ([blePeripherals count] > 0){
#ifdef DEBUG_LIB
            DLog(@"DEBUG_BLE %@ ???", ((ScannedPeripheral *)blePeripherals[0]).peripheral);
            DLog(@"BLE_DEBUG VENDOR MODE SET TIMER ...");
#endif
            // TO DO ... SCAN SN
            [H2BleService sharedInstance].bleNormalDisconnected = NO;
            [self.h2CentralManager connectPeripheral:((ScannedPeripheral *)blePeripherals[0]).peripheral options:nil];
            
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_CONNECT_INTERVAL taskSel:BLE_TIMER_BLE_CONNECT_MODE];
        }
    }
    
    if ([blePeripherals count] == 0) {
        [self h2BleConnectReport:FAIL_BLE_NOT_FOUND];
#ifdef DEBUG_LIB
        DLog(@"NO BLE be found in Scan stage");
#endif
    }
    
#ifdef DEBUG_LIB
    DLog(@"BLE CABLE -- WHAT HAPPEN ... SCAN END");
#endif
}


- (void)h2BleConnectReport:(UInt8)code
{
    if ([H2BleService sharedInstance].h2ConnectedPeripheral != nil) {
        [[H2BleCentralController sharedInstance] H2BleCentralCanncelConnect:[H2BleService sharedInstance].h2ConnectedPeripheral];
        [H2BleService sharedInstance].h2ConnectedPeripheral = nil;
    }
#ifdef DEBUG_LIB
    DLog(@"Did come to H2SYNC .... 1  and %02X", [H2SyncSystemMessageInfo sharedInstance].syncInfoCableStatus[0]);
#endif
    BOOL errHappen = NO;
   
    if (code & 0x80 || code & 0x10) {
        scanMode = NO;
        errHappen = YES;
    }
    
    UInt8 delegateSel = DELEGATE_SYNC;
    if ([H2BleService sharedInstance].blePairingStage || [H2BleService sharedInstance].bleCablePairing) {
        delegateSel = DELEGATE_PAIRING;
#ifdef DEBUG_LIB
        DLog(@"BLE PAIRING MODE");
#endif
    }
     [[H2BleService sharedInstance] resetBleMode];
    if (errHappen) {
        @autoreleasepool {
            if ([self.bleDelegate conformsToProtocol:@protocol(H2BleCentralControllerDelegate)] &&
                [self.bleDelegate respondsToSelector:@selector(h2BleConnectStatus: withGoodCode:)])
            {
                [self.bleDelegate h2BleConnectStatus:code withGoodCode:delegateSel];
#ifdef DEBUG_LIB
                DLog(@"BLE FAIL AND REPORT STATUS");
#endif
            }
        }
    }
}

- (void)H2BleStopAndDisConnect:(CBPeripheral *)ConnectedPeripheral
{
    // DisConnect Ble device
#ifdef DEBUG_LIB
    DLog(@"BLE DISCONNECT %@", ConnectedPeripheral);
#endif

    scanMode = NO;
    [self.h2CentralManager stopScan];

    // Disable Timer ...
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    
    [H2BleService sharedInstance].isBleCable = NO;
    [H2BleService sharedInstance].isBleEquipment = NO;
    [H2BleService sharedInstance].blePairingStage = NO;
    
    if (ConnectedPeripheral != nil) {
        [self H2BleCentralCanncelConnect:ConnectedPeripheral];
    }
    
    // Set 1 Second Timer
    [[H2BleService sharedInstance] resetBleMode];
}

- (void)H2BleCentralCanncelConnect:(CBPeripheral *)ConnectedPeripheral
{
    _bleCanncelConnect = YES;
    [H2BleService sharedInstance].bleNormalDisconnected = YES;
    if(_h2CentralManager != nil && ConnectedPeripheral != nil){
        [[H2BleService sharedInstance] h2DeSubscribe]; // For Fora, BTM only
        [self.h2CentralManager cancelPeripheralConnection:ConnectedPeripheral];
    }
}

- (void)h2BleCentralCanncelConnectForVendor
{
    _bleCanncelConnect = YES;
    [H2BleService sharedInstance].bleNormalDisconnected = YES;
    if ([H2BleService sharedInstance].blePairingStage) {
        if (((ScannedPeripheral *)blePeripherals[_currentPeriperialIndex]).peripheral != nil) {
            [self.h2CentralManager cancelPeripheralConnection:((ScannedPeripheral *)blePeripherals[_currentPeriperialIndex]).peripheral];
        }
#ifdef DEBUG_LIB
        DLog(@"CANCEL CONNECT AT PARING MODE");
#endif
    }else{
        if ([H2BleService sharedInstance].h2ConnectedPeripheral != nil) {
            [self.h2CentralManager cancelPeripheralConnection:[H2BleService sharedInstance].h2ConnectedPeripheral];
        }
#ifdef DEBUG_LIB
        DLog(@"CANCEL CONNECT AT SYNC MODE");
#endif
    }
}


// CANNCEL FROM USER ...
// 1. SCAN STATE
// 2. PARING STATE
// 3. SN STATE
// 4. RECORD STATE


/**********************************************************************************************************
 *  @fn : DID DISCOVER PERIPHERAL, Call Back,
 *
 *  This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 *
 *
***********************************************************************************************************/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BOOL peripheralNameCompare = NO;
    
    if (RSSI.integerValue > -30 || RSSI.integerValue < -90) {
        return;
    }
    
    if (!scanMode) {
        return;
    }
    
    if ([H2BleService sharedInstance].blePeripheralIdle) {
        return;
    }
    [H2BleService sharedInstance].blePeripheralIdle = YES;
#ifdef DEBUG_LIB
    _rssiCount++;
    _rssiValue += RSSI.integerValue;
    _rssiValueAvage = _rssiValue/_rssiCount;
    
    DLog(@"DEBUG_BLE RSSI VALUE  AVG  IS %02d",  _rssiValueAvage);
    DLog(@"DEBUG_BLE RSSI VALUE %02d and count %02d, AVG IS %02d", _rssiValue, _rssiCount,_rssiValue/_rssiCount);
#endif
    
    NSString *bleDevName = [advertisementData objectForKey: @"kCBAdvDataLocalName"];
    [H2BleService sharedInstance].bleTempLocalName = bleDevName;
#ifdef DEBUG_LIB
    DLog(@"Advertisement DATA is  %@", advertisementData);
    DLog(@"BLE DEV NAME IS %@", bleDevName);
    DLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    NSUUID *serverId = [peripheral identifier];
    DLog(@"THE PERIPHERAL IDENTIFIER %@ and Len %d", serverId, (unsigned)[peripheral.name length]);
    
    DLog(@"THE PERIPHERAL IDENTIFIER GET %@", [peripheral.identifier UUIDString]);
    if ([H2BleService sharedInstance].reconnectPeripheral != nil) {
        DLog(@"THE SERVER IDENTIFIER %@", [[H2BleService sharedInstance].reconnectPeripheral.identifier UUIDString]);
    }
#endif
    
    // GET PERIPHERAL Name, And Checking it.
    if ([H2BleService sharedInstance].didUseH2BLE) {
        peripheralNameCompare = [[H2BgmCable sharedInstance] CABDidDiscoverPeripheral:peripheral withDevName:bleDevName];
#ifdef DEBUG_LIB
        DLog(@"USE H2 CABLE");
#endif
    }else{// CHECK NAME FOR BLE METER ...
        peripheralNameCompare = [[H2BleService sharedInstance] VENDidDiscoverPeripheral:peripheral withDevName:bleDevName];
#ifdef DEBUG_LIB
        DLog(@"USE VENDOR ");
#endif
    }
    
    if (!peripheralNameCompare) {
        [H2BleService sharedInstance].blePeripheralIdle = NO;
        return;
    }
    
    [H2BleService sharedInstance].bleLocalName = bleDevName;
    [ArkrayGBlack sharedInstance].arkrayTmpIdString = [peripheral.identifier UUIDString];
    ScannedPeripheral *sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:RSSI.intValue isPeripheralConnected:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG_LIB
        DLog(@"H2_DEBUG DISPATCH ...");
        DLog(@"SENSOR %@ ", sensor.peripheral);
        DLog(@"SENSOR name is %@ ", sensor.name);
        DLog(@"SENSOR COUNT is %d ", (int)[blePeripherals count]);
#endif
        if (![blePeripherals containsObject:sensor] && [blePeripherals count] < [H2BleService sharedInstance].bleScanDeviceMax)
        {
            if ([H2BleService sharedInstance].didUseH2BLE) {
                sensor.bleScanSerialNumber = [H2BgmCable sharedInstance].h2BgmCableSN;
                [H2BgmCable sharedInstance].h2BgmCableSN = @"0";
                sensor.bleScanModel = @"";
                [_blePeripheralsHaveFound addObject:sensor];
#ifdef DEBUG_LIB
                DLog(@"THE CABLE SN IS %@ %@", [H2BgmCable sharedInstance].h2BgmCableSN, sensor.bleScanSerialNumber);
#endif
            }
            [blePeripherals addObject:sensor];
#ifdef DEBUG_BLE_VENDOR
            for (ScannedPeripheral *peripheralTX in blePeripherals) {
                DLog(@"H2 DEBUG PERIPHERAL --- %@ \n", peripheralTX.peripheral);
                DLog(@"H2 DEBUG RSSI --- %d \n", peripheralTX.RSSI);
            }
#endif
        }
        // For H2 BLE Cable Pairing ...
        if ([H2BleService sharedInstance].bleCablePairing || [H2BleService sharedInstance].blePairingStage) {
            [self bleCablePairngTask];
            return;
        }
#if 1
        // 發現 OLD BLE
#ifdef DEBUG_LIB
        DLog(@"IS RECONECT ??");
#endif
        if ([H2BleService sharedInstance].reconnectPeripheral != nil) {
#ifdef DEBUG_LIB
            DLog(@"IS RECONECT ?? YES");
#endif
            if (![H2BleService sharedInstance].blePairingStage) {
                if ([[peripheral.identifier UUIDString] isEqualToString:[[H2BleService sharedInstance].reconnectPeripheral.identifier UUIDString]]) {
                    
                    if ([H2BleService sharedInstance].discoverCount > 0) {
                        [H2BleService sharedInstance].discoverCount--;
                    }else{
                        scanMode = NO;
                        [self.h2CentralManager stopScan];
                        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
                        [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_CONNECT_INTERVAL taskSel:BLE_TIMER_BLE_CONNECT_MODE];
                        [self.h2CentralManager connectPeripheral:peripheral options:nil];
#ifdef DEBUG_LIB
                        DLog(@"FORA U-RIGTH TIMER %f ", _readSerialNumberInterval);
#endif
                        return;
                    }
#ifdef DEBUG_LIB
                    DLog(@" GET OLD BLE DEVICE");
#endif
                }
            }else{
#ifdef DEBUG_LIB
                DLog(@"IS RECONECT ?? YES - PAIRING MODE");
#endif
            }
        }
#endif
        [H2BleService sharedInstance].blePeripheralIdle = NO;
    });
}

/*************************************************************
 *
 *  @fn : DID CONNETC PERIPHERAL, Call Back, Scan Service UUID
 *  Did Connect to a peripheral
 *
 *
 *
**************************************************************/
#pragma mark - DID CONNECT ??
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
#ifdef DEBUG_LIB
    DLog(@"Peripheral Connected And Scanning Stopped");
#endif
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
        return;
    }
    
    [H2BleTimer sharedInstance].bleRecordModeForTimer = NO;
    _bleCanncelConnect = NO;
    [H2BleService sharedInstance].normalFlowHasNofity = NO;
    [H2BleService sharedInstance].bleSerialNumberMode = NO;
    [H2BleService sharedInstance].bleConnected = YES;
    // Clear CONNTECT TIMER
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    

    // Debug ...
    if (![H2BleService sharedInstance].blePairingStage && [H2BleService sharedInstance].isBleEquipment) {
        [[H2Sync sharedInstance] demoSdkSyncCableStatus:SUCCEEDED_CABLE_EXIST delegateCode:DELEGATE_DEVELOP];
    }
    
    // BLE BGM Characteristic
    [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_Measurement = nil;
    [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_Feature = nil;
    [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_RecordAccessControlPoint = nil;
    [H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_MeasurementContext = nil;
    
    [H2BleProfile sharedBleProfileInstance].bleCharSerialNumber = nil;
    
    [H2BleService sharedInstance].bleTempIdentifier = [peripheral.identifier UUIDString];
#ifdef DEBUG_LIB
    DLog(@"SN = %f ", _readSerialNumberInterval);
    DLog(@"Peripheral Connected And Scanning Stopped ID IS %@", [H2BleService sharedInstance].bleTempIdentifier);
#endif
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    [H2BleService sharedInstance].bleTempModel = @"";
    
    [[H2BleTimer sharedInstance] h2SetBleTimerTask:_readSerialNumberInterval taskSel:BLE_TIMER_READ_SN];

    
    // DISCOVER SERVICE .... SERVICE CHECKING !!
    // Search only for services that match our UUID

    if ([H2BleService sharedInstance].didUseH2BLE) { // CABLE
        [[H2BgmCable sharedInstance] CABDidConnectPeripheral:peripheral];
    }else{
        [[H2BleService sharedInstance] VENDidConnectPeripheral:peripheral];
    }
}

/**********************************************************************************
 *
 *  @fn : DID disDISCOVER SERVICE , Call Back
 *
 *
 *
 *
 *********************************************************************************/
#pragma mark - DID DISCONNECT
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // FOR BLE CABLE
    NSLog(@"BLE -- DISCONNECT ...");
    [[H2Timer sharedInstance] clearCableTimer];
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
#ifdef DEBUG_LIB_XXX
    if ([H2BleService sharedInstance].isBleCable) {
        DLog(@"BLE_DISCONNECT -  BLE CABLE HAS SET");
        if ([H2BleService sharedInstance].didBleCableFinished) {
            [H2BleService sharedInstance].didBleCableFinished = NO;
            [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
        }
    }
#endif
    
    if([self errorHappenAtDisconnectStage:error]){
        return;
    }
    
    // update FW finished, show SUCCED
    if ([H2BleOad sharedInstance].oadMode) {
        [H2BleOad sharedInstance].oadMode = NO;
        [self h2BleConnectReport:OAD_UPDATE_FAIL];
        [[H2BleService sharedInstance] resetBleMode];
        return;
    }
    if ([H2BleService sharedInstance].isBleCable) {
        // SYNC FINISHED, REPORT SYNC ERROR AT RECORD TIMER
        if (!_bleCanncelConnect) {
            [self h2BleConnectReport:0x8A];
        }
        [[H2BleService sharedInstance] resetBleMode];
        return;
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
#ifdef DEBUG_LIB
    DLog(@"TM FAIL CONNECT %@, and Err - %@", peripheral, error);
#endif
}

/**********************************************************************************
 *
 *  @fn : DID DISCOVER SERVICE , Call Back
 *
 * explore peripheral Service
 *
 *
 *********************************************************************************/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
#ifdef DEBUG_LIB
    DLog(@"WHAT WE HAVE FOUND ... %@", peripheral);
#endif
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
        return;
    }
    if ([H2BleService sharedInstance].didUseH2BLE) {
        
        [[H2BgmCable sharedInstance] CableDidDiscoverServices:peripheral];
    }else{
#ifdef DEBUG_LIB
        DLog(@"WHAT HAPPENS !!! %@", peripheral.services);
#endif
        if (peripheral.services != nil) {
#ifdef DEBUG_LIB
            DLog(@"GET SERVICES = %@", peripheral.services);
#endif
            [[H2BleService sharedInstance] VendorDidDiscoverServices:peripheral];
        }else{ // What Condition?
#ifdef DEBUG_LIB
            DLog(@"NO SERVICES HAS FOUND");
#endif
            [self bleSeriveNotFound];
        }
    }
}

- (void)bleSeriveNotFound
{
    // CLEAR READ SN TIMER
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_ACCUCHEK_AVIVA_CONNECT:
        case SM_BLE_ACCUCHEK_AVIVA_GUIDE:
        case SM_BLE_ACCUCHEK_INSTANT:
        case SM_BLE_ARKRAY_G_BLACK:
        case SM_BLE_ARKRAY_NEO_ALPHA:
            [self h2BleConnectReport:FAIL_BLE_MODE];
            break;
            
        default:
            [self h2BleConnectReport:FAIL_BLE_NORESPONSE];
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
#pragma mark - BLE DISCOVER CHAR Did Discover Characteristic
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
        return;
    }
#ifdef DEBUG_LIB
    DLog(@"/*********************************************/");
    DLog(@"                NORMAL                         ");
    DLog(@"/*     Did come to discover characteristic  For Vendor */");
    DLog(@"                                               ");
    DLog(@"/*********************************************/");
#endif
    
    if ([H2BleService sharedInstance].didUseH2BLE) { // CABLE
        [[H2BgmCable sharedInstance] CablePeripheral:peripheral didDiscoverCharacteristicsForService:service];
    }else{ // VENDOR
        [[H2BleService sharedInstance] VendorPeripheral:peripheral didDiscoverCharacteristicsForService:service];
    }
}

/*
typedef NS_ENUM(NSInteger, CBATTError) {
    CBATTErrorSuccess NS_ENUM_AVAILABLE(NA, 6_0)	= 0x00,
    CBATTErrorInvalidHandle							= 0x01,
    CBATTErrorReadNotPermitted						= 0x02,
    CBATTErrorWriteNotPermitted						= 0x03,
    CBATTErrorInvalidPdu							= 0x04,
    CBATTErrorInsufficientAuthentication			= 0x05,
    CBATTErrorRequestNotSupported					= 0x06,
    CBATTErrorInvalidOffset							= 0x07,
    CBATTErrorInsufficientAuthorization				= 0x08,
    CBATTErrorPrepareQueueFull						= 0x09,
    CBATTErrorAttributeNotFound						= 0x0A,
    CBATTErrorAttributeNotLong						= 0x0B,
    CBATTErrorInsufficientEncryptionKeySize			= 0x0C,
    CBATTErrorInvalidAttributeValueLength			= 0x0D,
    CBATTErrorUnlikelyError							= 0x0E,
    CBATTErrorInsufficientEncryption				= 0x0F,
    CBATTErrorUnsupportedGroupType					= 0x10,
    CBATTErrorInsufficientResources					= 0x11
};
*/

/******************************************************************
 * @fn : delegate method, BLE update value
 *
 *
 *
 ******************************************************************/
#pragma mark - BLE Report Data
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if ([self errorHappenAtUpateValueStage:error]) {
        return;
    }
    
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
        return;
    }
    
    [[H2BleEquipId sharedEquipInstance].bleEquipBuffer setLength:0];
    [[H2BleEquipId sharedEquipInstance].bleEquipBuffer appendData:characteristic.value];
    
#ifdef DEBUG_LIB
    DLog(@"BLE REPORT DATA HERE ...");
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    DLog(@"BLE DEBUG The Length of the VENDOR OR H2 data is %d %@", (int)[[H2BleEquipId sharedEquipInstance].bleEquipBuffer length], [H2BleEquipId sharedEquipInstance].bleEquipBuffer);
    DLog(@"BLE DEBUG  STRING: %@", stringFromData);
    DLog(@"BLE DEBUG  CHAR: %@", characteristic);
#endif
    if ([H2BleService sharedInstance].didUseH2BLE) { // CABLE DATA UPDATE ...
        
        [[H2BgmCable sharedInstance] CableDidUpdateValueForCharacteristic:characteristic];
        
    }else{ // Vendor BLE Device

        // DO VENDOR ... REPORT DATA PROCESS
        [H2AudioAndBleSync sharedInstance].dataLength = [[H2BleEquipId sharedEquipInstance].bleEquipBuffer length];
        if ([H2AudioAndBleSync sharedInstance].dataLength > 0) {
            memcpy([H2AudioAndBleSync sharedInstance].dataBuffer, [[H2BleEquipId sharedEquipInstance].bleEquipBuffer bytes], [H2AudioAndBleSync sharedInstance].dataLength);
        }
#ifdef DEBUG_LIB
        for (int i=0; i<[[H2BleEquipId sharedEquipInstance].bleEquipBuffer length]; i++) {
            DLog(@"DEBUG_FORA SRC index : %02d and Data : %02X", i, [H2AudioAndBleSync sharedInstance].dataBuffer[i]);
        }
#endif
        [[H2BleService sharedInstance] VendorDidUpdateValueForCharacteristic:characteristic];
    }
}

#pragma mark - WRITE PROPERTY RESPOND
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error) {
#ifdef DEBUG_LIB
        DLog(@"Error writing characteristic value: %@", [error localizedDescription]);
#endif
    }else{
#ifdef DEBUG_LIB
        DLog(@"Write successfully !!");
#endif
        if ([H2Records sharedInstance].bgCableSyncFinished) {
            [H2Records sharedInstance].bgCableSyncFinished = NO;
            [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
#ifdef DEBUG_LIB
            DLog(@"BLE CABLE FINISHED ...");
#endif
        }
    }
}

#pragma mark - NOTIFICATION PROCESS
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
        return;
    }
    if([self errorHappenAtNotifyStage:error]){
        return;
    }else{
        if ([H2BleService sharedInstance].didUseH2BLE) { // CABLE
            [[H2BgmCable sharedInstance] CableDidUpdateNotificationStateForCharacteristic:characteristic];
        }else{ // Vendor :(CBPeripheral *)peripheral withCharacteristic
            [[H2BleService sharedInstance] vendorDidUpdateNotificationStateForCharacteristic:peripheral withCharacteristic:characteristic];
        }
#ifdef DEBUG_LIB
        DLog(@"Notification successfully !! BLE_NOTIFY !! %@", characteristic);
#endif
    }
    
    
    
    if (error) {
#ifdef DEBUG_LIB
        DLog(@"Error changing Notification state: %@", [error localizedDescription]);
#endif
    }else{

        
    }
    
}



/*
 *-------------------------------------------------------------
 * H2 SYNC self definition Method
 *
 *
 *-------------------------------------------------------------
 */
#pragma mark - H2 BLE -- SCAN --
/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)h2BgmScan
{
#ifdef DEBUG_LIB
    DLog(@"BLE SCAN - STEP 0");
#endif
    float bleScanInterval = BLE_SCAN_FOR_SYNC_INTERVAL;
    _readSerialNumberInterval = BLE_READ_SN_INTERVAL;
    //_bleDialogInterval = BLE_READ_SN_INTERVAL;
    scanMode = YES;
    [H2BleService sharedInstance].discoverCount = BLEDEVBEFOUND;
    
#ifdef DEBUG_LIB
    DLog(@"DEFAULT SN TIME INTERVAL %f, SCAN INTERVAL = %f", _readSerialNumberInterval, bleScanInterval);
#endif
    if ([H2BleService sharedInstance].blePairingStage) {
        bleScanInterval = BLE_SCAN_FOR_PAIRING_INTERVAL;
        
    }else{
        if ([H2BleService sharedInstance].isBleEquipment) { // Only for Vendor BGM
            [H2BleService sharedInstance].bleSerialNumberStage = YES;
        }
    }
#ifdef DEBUG_LIB
    DLog(@"CURRENT SCAN INTERVAL = %f", bleScanInterval);
#endif
    
    // else if Power On State, then start scan
    [[H2BleTimer sharedInstance] h2SetBleTimerTask:bleScanInterval taskSel:BLE_TIMER_SCAN_MODE];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    if ([blePeripherals count] > 0) {
        [blePeripherals removeAllObjects];
    }

    
    if ([H2BleService sharedInstance].filterUUID != nil)
    {
        [self.h2CentralManager scanForPeripheralsWithServices:@[[H2BleService sharedInstance].filterUUID] options:options];
#ifdef DEBUG_LIB
        DLog(@"METRIX SCAN - 3 TYSON");
        DLog(@"H2_DEBUG SCAN ...%@ --- %@", options, [H2BleService sharedInstance].filterUUID);
#endif
    }else{
        [self.h2CentralManager scanForPeripheralsWithServices:nil options:options];
#ifdef DEBUG_LIB
        DLog(@"METRIX SCAN - 4");
        DLog(@"FILTER ID IS NIL ----");
#endif
    }

    
#if 0
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

    [self.h2CentralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
#endif
#ifdef DEBUG_LIB
    DLog(@"DEBUG -- BLE SCAN ...");
#endif
    
}


#pragma mark - H2 BLE -- SUBSCRIBE --
- (void)h2BTCableSubscribeTask {
#if 0
    if (_h2_CharacteristicCableInfo.isNotifying == NO) {
        [_h2DiscoveredPeripheral setNotifyValue:YES forCharacteristic:_h2_CharacteristicCableInfo];
    }
    
    
    if (_h2_CharacteristicMeterInfo.isNotifying == NO) {
        [_h2DiscoveredPeripheral setNotifyValue:YES forCharacteristic:_h2_CharacteristicMeterInfo];
    }
#endif
#ifdef DEBUG_LIB
    DLog(@"H2 BLE SYNC Notify Task");
#endif
}



#pragma mark - H2 BLE -- WRITE --


- (void)H2BTCableWriteTask:(NSData *)cmdData withCharacteristicSel:(UInt16)chSel {
    
    [[H2BgmCable sharedInstance] H2BgmCableWriteTask:cmdData withCharacteristicSel:chSel];
}



- (void)h2BleStart:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(bleNormalStart) userInfo:nil repeats:NO];
}

- (void)bleNormalStart
{
#ifdef DEBUG_LIB
    DLog(@"METRIX ST - 0");
    _rssiCount = 0;
    _rssiValue = 0;
    DLog(@"BLE DEBUG - START METRIX");
#endif
    if ([_blePeripheralsHaveFound count] > 0) {
        [_blePeripheralsHaveFound removeAllObjects];
    }
    
    [H2BleService sharedInstance].discoverCount = BLEDEVBEFOUND;
    _currentPeriperialIndex = 0;
    [H2BleService sharedInstance].bleRecordStage = NO;
    [H2BleService sharedInstance].bleOADStage = NO;

    
#ifdef DEBUG_LIB
    DLog(@"METRIX ST - 2");
#endif
    if ([H2BleService sharedInstance].isBleEquipment) {
#ifdef DEBUG_LIB
        DLog(@"METRIX ST - 3");
        DLog(@"BLE VENDOR MODE");
#endif
        [H2BleService sharedInstance].didUseH2BLE = NO;
        [[H2BleService sharedInstance] vendorBLEInit];
    }else{
#ifdef DEBUG_LIB
        DLog(@"BLE H2 CABLE MODE");
#endif
        [H2BleService sharedInstance].didUseH2BLE = YES;
        
        [[H2BgmCable sharedInstance] cableBLEInit];
    }

    // Setup the CBCentral Manager
    [H2CableParameter sharedInstance].didSkipExistCmd = NO;
    if (_bleCentralPowerOn) {
#ifdef DEBUG_LIB
        DLog(@"METRIX ST - 4");
        DLog(@"BEL POWER ON");
#endif
        [self h2BgmScan];
    }else{
        _h2CentralManager = nil;
#ifdef DEBUG_LIB
        DLog(@"METRIX ST - 5");
        DLog(@"CENTRAL MANAGER STATUS B %@", _h2CentralManager);
#endif
        if (_h2CentralManager == nil) {
            _h2CentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
#ifdef DEBUG_LIB
            DLog(@"METRIX ST - 6");
            DLog(@"CENTRAL MANAGER STATUS A %@", _h2CentralManager);
#endif
        }
#ifdef DEBUG_LIB
        DLog(@"BLE POWER ON/OFF DELAY");
#endif
    }
    
    DLog(@"DEBUG -- START");
}

- (void)H2BleCentralStopScan
{
    [self.h2CentralManager stopScan];
}


- (void)bleCablePairngTask
{
    if ([H2BleService sharedInstance].bleScanMultiDevice) {
        [H2BleService sharedInstance].blePeripheralIdle = NO;
        return;
    }
    if ([H2BleService sharedInstance].discoverCount > 0) {
        [H2BleService sharedInstance].discoverCount--;
        [H2BleService sharedInstance].blePeripheralIdle = NO;
    }else{
        scanMode = NO;
        [self.h2CentralManager stopScan];
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        
        if ([H2BleService sharedInstance].bleCablePairing) {
            [[H2Sync sharedInstance] demoSdkSyncCableStatus:SUCCEEDED_PAIR delegateCode:DELEGATE_PAIRING];
            [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(H2ReportBleDeviceTimeOut) userInfo:nil repeats:NO];
        }else{
            [self h2BleScanDevEnd];
        }
    }
#ifdef DEBUG_LIB
    DLog(@"CHECKING QR CODE ...");
#endif
}

- (BOOL)errorHappenAtDisconnectStage:(NSError *)error
{
#ifdef DEBUG_LIB
    if (error) {
        NSLog(@"DISCONNECT BT-ERR DOMAIN = %@", error.domain);
        DLog(@"DISCONNECT BT-ERR: CODE = %02X", (unsigned int)error.code);
        DLog(@"ERROR - Value: %@", [error localizedDescription]);
    }
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
        DLog(@"CHECKING - NORMALE DISCONNECT");
    }else{
        DLog(@"CHECKING - ABNORMALE DISCONNECT");
    }
#endif
    
    //NSLog(@"斷線 FOUND = %d, and BLE_IDX = %d", [blePeripherals count], _currentPeriperialIndex);
    if ([H2BleService sharedInstance].blePairingModeFinished) {
        return YES;
    }
    // Be Careful
    if ([ArkrayGBlack sharedInstance].arkraySyncPhs) {
        [ArkrayGBlack sharedInstance].arkraySyncPhs = NO;
        [self h2BleConnectReport:FAIL_BLE_NEO_DISCONNECT];
        return YES;
    }
    if ([H2BleService sharedInstance].bleScanMultiDevice) {
        if ([H2BleService sharedInstance].bleMultiDeviceCanncel) {
            [H2BleService sharedInstance].bleMultiDeviceCanncel = NO;
            return YES;
        }
        // Scan Ending or Not
        
        if ([blePeripherals count] > (_currentPeriperialIndex+1)) {
            _currentPeriperialIndex++;
            [[H2BleTimer sharedInstance] h2SetBleTimerTask:BLE_CONNECT_INTERVAL taskSel:BLE_TIMER_BLE_CONNECT_MODE];
            [H2BleService sharedInstance].bleNormalDisconnected = NO;
            [self.h2CentralManager connectPeripheral:((ScannedPeripheral *)blePeripherals[_currentPeriperialIndex]).peripheral options:nil];
        }else{
#ifdef DEBUG_LIB
            NSLog(@"SECOND BLE DISCONNECT ...");
#endif
            [[H2Sync sharedInstance] sdkBleDeviceList:_blePeripheralsHaveFound];
        }
        return YES;
    }
    
    [H2SyncStatus sharedInstance].sdkFlowActive = NO;
    if ([H2BleService sharedInstance].bleNormalDisconnected) {
#ifdef DEBUG_LIB
        DLog(@"NORMALE DISCONNECT - RETURN!! ");
#endif
        return NO;
    }
    if ([H2BleService sharedInstance].bleErrorHappen) {
#ifdef DEBUG_LIB
        DLog(@"AlREADY REPORT ERROR CODE");
#endif
        return NO;
    }
    
    if ([H2BleService sharedInstance].isBleCable){
        [self h2BleConnectReport:FAIL_SYNC];
#ifdef DEBUG_LIB
        DLog(@"BLE DONGLE DISCONNECT HERE ..!!");
#endif
        return YES;
    }
    
    if ([ForaD40 sharedInstance].foraD40Finished) {
        [ForaD40 sharedInstance].foraD40Finished = NO;
        [H2BleService sharedInstance].bleNormalDisconnected = YES;
        [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
        return NO;
    }
    
    UInt8 h2ErrorCode = 0;
    if ([error.domain isEqualToString:CBErrorDomain]) {
#ifdef DEBUG_LIB
        NSLog(@"BLE ERROR DOMAIN - DISCONECT");
#endif
        switch (error.code) {
            case CBErrorPeripheralDisconnected:
            default:
                if( [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_7600T){
                    h2ErrorCode = FAIL_BLE_INSUFFICIENT_AUTHENTICATION;
                }else{ // MODE Error For ARKRAY
                    h2ErrorCode = FAIL_BLE_MODE;
                }
                
                if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ARKRAY_G_BLACK || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ARKRAY_NEO_ALPHA) {
                    // 無配對...
                    h2ErrorCode = FAIL_BLE_PAIR_TIMEOUT;
                }
                
                if( [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ACCUCHEK_AVIVA_CONNECT || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ACCUCHEK_AVIVA_GUIDE
                   || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ACCUCHEK_INSTANT){
                    
                    if ([H2BleTimer sharedInstance].bleTimerTaskSel == BLE_TIMER_READ_SN) {
                        h2ErrorCode = FAIL_BLE_PAIR_TIMEOUT;
                    }
                }
                
                if( [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_OMRON_HEM_9200T){
                    [[OMRON_HEM_9200T sharedInstance] hem9200tClearCurrentTimer];
                    if (![OMRON_HEM_9200T sharedInstance].hem9200tCurrentTimeDone || ![OMRON_HEM_9200T sharedInstance].hem9200tSerialNumberDone) {
                        h2ErrorCode = FAIL_BLE_INSUFFICIENT_AUTHENTICATION;
                    }
                }
                
                break;
        }
        // Error for Roche, Dialog flash ...
        
        [self h2BleConnectReport:h2ErrorCode];
        return YES;
    }
    return NO;
}

- (BOOL)errorHappenAtUpateValueStage:(NSError *)error
{
    UInt8 h2ErrorCode = 0;
#ifdef DEBUG_LIB
    if([error.domain isEqualToString:CBATTErrorDomain]){
        DLog(@"(UPDATE) BT-ERR: DOMAIN %02X", (unsigned int)error.code);
        DLog(@"ERROR - Writing characteristic Value: %@", [error localizedDescription]);
    }
#endif
    if([error.domain isEqualToString:CBATTErrorDomain])
    {
        // TURE METRIX
        if (error.code > CBATTErrorSuccess) {
            [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
            h2ErrorCode = FAIL_BLE_INSUFFICIENT_AUTHENTICATION;
            // if SN is right, then start Normal Sync
            if([H2BleService sharedInstance].bleSerialNumberStage){
                [H2BleService sharedInstance].bleSerialNumberStage = NO;
            }
            [self h2BleConnectReport:h2ErrorCode];
            return YES;
        }
    }
    return NO;
}

- (BOOL)errorHappenAtNotifyStage:(NSError *)error
{
    UInt8 h2ErrorCode = 0;
#ifdef DEBUG_LIB
    DLog(@"(NOTIFICATION) BT-ERR: DOMAIN %02X AT NOTIFICATION", (unsigned int)error.code);
#endif
    if([error.domain isEqualToString:CBATTErrorDomain]){
        // CBATTErrorInsufficientAuthorization For Arkary, BT pairing at memory reading mode
        if(error.code > CBATTErrorSuccess){
            // CLEAR READ SN TIMER
            [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
            
            DLog(@"(NOTIFICATION) BT-ERR ----------");
            if ([H2BleService sharedInstance].normalFlowHasNofity) {
                h2ErrorCode = FAIL_BLE_INSUFFICIENT_AUTHENTICATION;
            }else{
                h2ErrorCode = FAIL_BLE_MODE;
            }
            
            
            if( [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ACCUCHEK_AVIVA_CONNECT || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ACCUCHEK_AVIVA_GUIDE || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ACCUCHEK_INSTANT){
             
                if ([H2BleTimer sharedInstance].bleTimerTaskSel == BLE_TIMER_PREPIN_MODE) {
                    h2ErrorCode = FAIL_BLE_PAIR_TIMEOUT;
                }
            }
            
            if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ARKRAY_G_BLACK || [H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_ARKRAY_NEO_ALPHA) {
                // 手機移除配對，meter 還存在配對(同步模式)，
                if(error.code == CBATTErrorInsufficientAuthorization){
                    h2ErrorCode = FAIL_BLE_PAIR_TIMEOUT;
                }
            }
            
            if([H2BleService sharedInstance].bleSerialNumberStage){
                // if SN is right, then start Normal Sync
                [H2BleService sharedInstance].bleSerialNumberStage = NO;
            }
            [self h2BleConnectReport:h2ErrorCode];
            return YES;
        }
        
    }
    return NO;
}


+ (H2BleCentralController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_LIB
    DLog(@"H2BleCentralController  INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}


@end




