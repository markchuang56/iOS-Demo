//
//  H2BgmCable.h
//  h2SyncLib
//
//  Created by h2Sync on 2016/1/7.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#pragma mark - H2 BT 4.0 UUID STRING
// H2 BGM CALBE
#define H2_CABLE_SERVICE_UUID                       @"AE618100-3266-4BBA-9626-06CBE7657213"

#define H2_CABLE_INFO_CHARACTERISTIC_UUID           @"AE618101-3266-4BBA-9626-06CBE7657213"
#define H2_METER_INFO_CHARACTERISTIC_UUID           @"AE618102-3266-4BBA-9626-06CBE7657213"


// 現在時間
#define H2_CABLE_TIME_CHARACTERISTIC_UUID             @"AE611234-3266-4BBA-9626-06CBE7657213"             //0x1234

#import <Foundation/Foundation.h>

@interface H2BgmCable : NSObject
{
    
}

@property(readwrite) BOOL didWantToGetSN;
@property (nonatomic, strong)NSString *h2BgmCableSN;

@property (nonatomic, readwrite) UInt8 h2BLESendDataIndex;
@property (nonatomic, strong) NSMutableData *h2BLEDataToSend;
@property (nonatomic, strong) NSMutableData *h2BLECableData;


@property (nonatomic, strong)CBUUID *h2ServiceCableUUID;

@property (nonatomic, strong)CBUUID *h2CharacteristicCableInfoUUID;
@property (nonatomic, strong)CBUUID *h2CharacteristicMeterInfoUUID;

@property (nonatomic, strong)CBUUID *h2CharacteristicCableTimeUUID;



// H2 Service
@property (nonatomic, strong) CBService *h2_ServiceCableInfo;
//@property (nonatomic, strong) CBService *h2_ServiceMeterInfo;

// Cable Info Caracteristic
@property (nonatomic, strong) CBCharacteristic *h2_CharacteristicCableInfo;

// Meter Info
@property (nonatomic, strong) CBCharacteristic *h2_CharacteristicMeterInfo;

// Current Characteristic
@property (nonatomic, strong) CBCharacteristic *h2_CharacteristicForWrite;

// cable time characteristic Object
@property (nonatomic, strong) CBCharacteristic *h2_CharacteristicCableTime;


- (void)cableBLEInit;

- (BOOL)CABDidDiscoverPeripheral:(CBPeripheral *)periphera withDevName:(NSString *)devName;
- (void)CABDidConnectPeripheral:(CBPeripheral *)peripheral;

- (void)CableDidDiscoverServices:(CBPeripheral *)peripheral;
- (void)CablePeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service;


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)CableDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic;
- (void)CableDidUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic;




- (void)H2BgmCableWriteTask:(NSData *)cmdData withCharacteristicSel:(UInt16)chSel;


+ (H2BgmCable *)sharedInstance;

@end


