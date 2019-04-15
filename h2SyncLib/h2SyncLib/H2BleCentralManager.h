//
//  ViewController.h
//  h2Central
//
//  Created by h2Sync on 2015/1/23.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#define PERIPHERALS_MAX             8
#define BLE_MAX_COUNT               3//8
#define CMD_DELAY_TIME              1.5f

#define BLE_DELAY                   2.0f

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "H2DebugHeader.h"


@protocol H2BleCentralControllerDelegate <NSObject>


#define NOTIFY_MTU          20

#define T_DATA_LEN          44

@optional

- (void)h2BleCableSyncEvent;
- (void)receiveBleCableData:(NSData *)bleCableData;
- (void)h2BleConnectStatus:(UInt8)code withGoodCode:(UInt8)selection;

@end



@interface H2BleCentralController : NSObject

@property(nonatomic, strong) NSObject <H2BleCentralControllerDelegate> *bleDelegate;

@property(readwrite) BOOL bleCentralPowerOn;

@property(readwrite) BOOL didSkipBLE;

@property(readwrite) BOOL bleCanncelConnect;

@property (nonatomic, strong) NSMutableArray *blePeripheralsHaveFound;
//@property(readwrite) UInt8 multiPeriperial;
@property(readwrite) UInt8 currentPeriperialIndex;
@property(readwrite) float readSerialNumberInterval;
//@property(readwrite) float bleDialogInterval;


@property (nonatomic, strong) CBCentralManager *h2CentralManager;

@property (nonatomic, strong) NSMutableArray *blePeripherals;


#ifdef DEBUG_LIB
@property (readwrite) UInt16 rssiCount;
@property (readwrite) int rssiValue;
@property (readwrite) int rssiValueAvage;
#endif

- (void)h2BleSetDeviceSerialNumber:(NSString *)snString;
- (void)h2BleConnectMultiDevice;

- (void)h2BleConnectReport:(UInt8)code;

- (void)h2BgmCableSyncBegin;
- (void)H2BleStopAndDisConnect:(CBPeripheral *)ConnectedPeripheral;


- (void)h2BTCableSubscribeTask;
- (void)H2BTCableWriteTask:(NSData *)cmdData withCharacteristicSel:(UInt16)chSel;
- (void)h2BleStart:(id)sender;


- (void)H2BleCentralCanncelConnect:(CBPeripheral *)ConnectedPeripheral;
- (void)h2BleCentralCanncelConnectForVendor;


- (void)h2CentralManagerAlloc;

- (void)H2BleCentralStopScan;

- (void)H2ReportBleDeviceTimeOut;

- (void)h2BleScanDevEnd;


+ (H2BleCentralController *)sharedInstance;

@end




