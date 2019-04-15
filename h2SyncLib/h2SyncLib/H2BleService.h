//
//  H2BleService.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/8/22.
//  Copyright © 2017年 h2Sync. All rights reserved.
//




#define CONTOUR_LEN         9
#import <CoreBluetooth/CoreBluetooth.h>

@interface H2BleService : NSObject{
    
}

@property (nonatomic, strong) CBPeripheral *h2ConnectedPeripheral;
@property (nonatomic, strong) CBPeripheral *reconnectPeripheral;

@property (nonatomic, strong) CBUUID *filterUUID;


@property (nonatomic, strong) NSMutableData *h2ForaW310BDataTemp;


@property (readwrite) BOOL didUseH2BLE;
@property (readwrite) BOOL isBleCable;
@property (readwrite) BOOL didBleCableFinished;
@property (readwrite) BOOL isBleEquipment;
@property (readwrite) BOOL didNeedMoreTimeForBlePairing;
@property (readwrite) BOOL recordMode;
@property (readwrite) BOOL isAudioSyncFlow;

@property (readwrite) BOOL bleVendorNotifyDone;
@property (readwrite) BOOL bleVendorRunning;
@property (readwrite) BOOL blePeripheralIdle;

@property (readwrite) BOOL bleSerialNumberMode;
@property (readwrite) BOOL normalFlowHasNofity;


@property (readwrite) BOOL blePairingStage;
@property (readwrite) BOOL bleSerialNumberStage;
@property (readwrite) BOOL bleRecordStage;

@property (readwrite) BOOL bleOADStage;
@property (readwrite) BOOL bleDeleteRecords;

@property (readwrite) BOOL skipRecord;
//@property (readwrite) UInt8 bgmNumber;
@property (readwrite) UInt8 bgmIndex;


@property (readwrite) int batteryLevel;
@property (readwrite) UInt16 batteryRawValue;


@property (nonatomic, strong) NSString *bleScanningKey;
@property (nonatomic, strong) NSString *bleSeverIdentifier;

@property (nonatomic, strong) NSString *bleTempLocalName;
@property (nonatomic, strong) NSString *bleLocalName;
@property (nonatomic, strong) NSString *bleTempIdentifier;
@property (nonatomic, strong) NSString *bleTempModel;


@property (readwrite) BOOL bleCablePairing;
@property (readwrite) int discoverCount;

@property (readwrite) BOOL bleDevInList;
@property (readwrite) BOOL bleConnected;
@property (readwrite) BOOL bleNormalDisconnected;
@property (readwrite) BOOL bleErrorHappen;

@property (readwrite) BOOL blePairingModeFinished;
@property (readwrite) BOOL bleMultiDeviceCanncel;
@property (readwrite) BOOL bleScanMultiDevice;
@property (readwrite) UInt8 bleScanDeviceMax;
@property (readwrite) UInt8 bleScanDeviceCount;

- (void)h2GetVendorRecord;
- (void)h2DeleteVendorRecords;

- (void)vendorBLEInit;


- (BOOL)VENDidDiscoverPeripheral:(CBPeripheral *)peripheral withDevName:(NSString *)devName;
- (void)VENDidConnectPeripheral:(CBPeripheral *)peripheral;

- (void)VendorDidDiscoverServices:(CBPeripheral *)peripheral;
- (void)VendorPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service;


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)VendorDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic;
- (void)vendorDidUpdateNotificationStateForCharacteristic:(CBPeripheral *)peripheral withCharacteristic:(CBCharacteristic *)characteristic;





- (void)resetBleMode;

- (void)h2DeSubscribe;
- (void)bleVendorReportMeterInfo;

// FOR TEST ...
- (void)H2ServiceOmron_DiscoverAllCharacteristics;

- (void)H2ServiceSetUserID:(UInt8)userId;

+ (H2BleService *)sharedInstance;

@end


/*
 //- (CBUUID *)h2UUIDWithValue:(int)value;
 - (CBUUID *)h2UUIDWithValue:(int)value
 {
 NSData *h2SrcTemp=[[NSData alloc]init];
 
 unsigned char charTemp[2] = {0};
 charTemp[1] = value & 0xFF;
 charTemp[0] = (value >> 8) & 0xFF;
 
 h2SrcTemp = [NSData dataWithBytes:charTemp length:2];
 return [CBUUID UUIDWithData: h2SrcTemp];
 }
 */


