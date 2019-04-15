//
//  H2BgmCable.m
//  h2SyncLib
//
//  Created by h2Sync on 2016/1/7.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#define SN_LEN_FOR_COMPARE              3

#import <CoreBluetooth/CoreBluetooth.h>

#import "H2BleEquipId.h"
#import "H2BleProfile.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2AudioFacade.h"

#import "H2Config.h"

#import "H2BleOad.h"
#import "H2BgmCable.h"

#import "H2BleTimer.h"

static BOOL sendingEOM;

@implementation H2BgmCable


- (id)init
{
    if (self = [super init]) {
        
        _didWantToGetSN = NO;
        _h2BgmCableSN = @"0";
        _h2BLEDataToSend = [[NSMutableData alloc]init];
        [_h2BLEDataToSend setLength:0];
        
        _h2BLECableData = [[NSMutableData alloc] init];
        [_h2BLECableData setLength:0];

        _h2ServiceCableUUID = [CBUUID UUIDWithString:H2_CABLE_SERVICE_UUID];

        _h2CharacteristicCableInfoUUID = [CBUUID UUIDWithString:H2_CABLE_INFO_CHARACTERISTIC_UUID];
        _h2CharacteristicMeterInfoUUID = [CBUUID UUIDWithString:H2_METER_INFO_CHARACTERISTIC_UUID];

        // H2 Service
        _h2_ServiceCableInfo = nil;

        _h2_CharacteristicCableInfo = nil;
        _h2_CharacteristicMeterInfo = nil;

        _h2_CharacteristicForWrite = nil;

        // 驗證用，在 devInfo 加入 現在時間
        _h2CharacteristicCableTimeUUID = [CBUUID UUIDWithString:H2_CABLE_TIME_CHARACTERISTIC_UUID];
        _h2_CharacteristicCableTime = nil;
    }
    return self;
}



- (void)cableBLEInit
{
#ifdef DEBUG_LIB
    DLog(@"Cable Init ...");
#endif
    [H2BleService sharedInstance].filterUUID = _h2ServiceCableUUID;
}

// DISCOVER PERIPHERAL -- CABLE
- (BOOL)CABDidDiscoverPeripheral:(CBPeripheral *)peripheral withDevName:(NSString *)devName;
{
    NSString *tmpSN = @"";
    NSString *tmpName = @"";
    if ([devName length] > 12) {
        tmpName = [devName substringWithRange:NSMakeRange(0, 4)];
    }else{
        return NO;
    }
#ifdef DEBUG_LIB
    DLog(@"CALE HEAD = %@", tmpName);
#endif
    
    // H2 CABLE CHECK ...
    if (![tmpName isEqualToString:@"H2BT"]) {
        return NO;
    }
    
    tmpSN = [devName substringWithRange:NSMakeRange(5+8, 14-8)];
    if ([tmpSN isEqualToString:@"000000"]) {
        return  NO;
    }
    
    if ([devName length] >= 19) {
        tmpSN = [devName substringWithRange:NSMakeRange(5, 14)];
#ifdef DEBUG_LIB
        DLog(@"SCAN KEY %@", [H2BleService sharedInstance].bleScanningKey);
        DLog(@"CABLE SN %@", tmpSN);
#endif
        if ([tmpSN isEqualToString:[H2BleService sharedInstance].bleScanningKey]) {
            // GET RIGHT SN
            _h2BgmCableSN = tmpSN;
#ifdef DEBUG_LIB
            DLog(@"THE H2 Name RIGHT is %@", [H2BleService sharedInstance].bleScanningKey);
#endif
            return YES;
        }
    }
    return NO;
}

// DID CONNECT PERIPHERAL
- (void)CABDidConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([H2BleService sharedInstance].blePairingStage) {
        [H2BleService sharedInstance].blePairingStage = NO;
#ifdef DEBUG_LIB
        DLog(@"SCAN H2 BLE PAIR TEST ...");
#endif
        return;
    }
    
    [H2BleService sharedInstance].h2ConnectedPeripheral = peripheral;
    if ([H2BleOad sharedInstance].oadMode)  { // Scan OAD Service
        [peripheral discoverServices:@[[H2BleOad sharedInstance].h2ServiceOADImgUUID]];
    }else{ // Scan H2 Cable Service
        [peripheral discoverServices:@[_h2ServiceCableUUID]];
    }
}

- (void)CableDidDiscoverServices:(CBPeripheral *)peripheral
{
    if ([H2BleOad sharedInstance].oadMode) {
#ifdef DEBUG_LIB
        DLog(@"OAD IS BUSY ... ");
#endif
        for (CBService *service in peripheral.services) {
            // for OAD ...
            if([service.UUID isEqual:[H2BleOad sharedInstance].h2ServiceOADImgUUID]){
#ifdef DEBUG_LIB
                DLog(@"H2 BLE FOUND OAD SERVICE");
#endif
                [H2BleOad sharedInstance].h2_ServiceOAD = service;
                [peripheral discoverCharacteristics:nil forService:service];
            }else{
#ifdef DEBUG_LIB
                DLog(@"H2 BLE OAD ELSE SERVICE");
#endif
            }
        }
    }else{

        for (CBService *service in peripheral.services) {
#ifdef DEBUG_LIB
            DLog(@"H2 BLE FOUND CABLE SERVICE %@", service);
            DLog(@"H2 BLE FOUND CABLE ID %@", _h2ServiceCableUUID);
#endif
            
            if ([service.UUID isEqual:_h2ServiceCableUUID]){
                _h2_ServiceCableInfo = service;
                [peripheral discoverCharacteristics:nil forService:service];

            }else{
#ifdef DEBUG_LIB
                DLog(@"H2 BLE CABLE ELSE SERVICE");
                if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID]){
                     DLog(@"H2 BLE CABLE DEV INFO SERVICE");
                    [peripheral discoverCharacteristics:nil forService:service];
                }
#endif
            }
        }
    }
}

- (void)h2CableFWUpdateBegin
{
    // CLEAR READ SN TIMER
    [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
#ifdef DEBUG_LIB
        DLog(@"H2 OAD BEGIN ... CANNEL SN TIMER");
#endif
    
    [[H2BleOad sharedInstance] H2OADWriteIdentify];
#ifdef DEBUG_LIB
    DLog(@"FW UPDATE START .... ");
#endif
}

- (void)CablePeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
{
#ifdef DEBUG_LIB
    DLog(@"/*********************************************/");
    DLog(@"                H2SYNC                         ");
    DLog(@"/*     Did come to discover characteristic   */");
    DLog(@"                                               ");
    DLog(@"/*********************************************/");
    
    DLog(@"The Original UUID %@ \n%@ \n", _h2_CharacteristicCableInfo, _h2_CharacteristicMeterInfo/*, _h2_CharacteristicMeterRecord*/);
    DLog(@"CABLE CONNECTED PERIPHERAL %@", [H2BleService sharedInstance].h2ConnectedPeripheral);
#endif
    if ([H2BleOad sharedInstance].oadMode) { // For Update FW
        if ([service.UUID isEqual:[H2BleOad sharedInstance].h2ServiceOADImgUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                if ([characteristic.UUID isEqual:[H2BleOad sharedInstance].h2CharacteristicOADImgIdentifyUUID]){
                    [H2BleOad sharedInstance].h2_CharacteristicIdentify = characteristic;
                    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
#ifdef DEBUG_LIB
                    DLog(@"The OAD IDENTIFY UUID --- %@ \n", [H2BleOad sharedInstance].h2_CharacteristicIdentify);
#endif
                }else if([characteristic.UUID isEqual:[H2BleOad sharedInstance].h2CharacteristicOADImgBlockUUID]){
                    [H2BleOad sharedInstance].h2_CharacteristicBlock = characteristic;
                    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
#ifdef DEBUG_LIB
                    DLog(@"The OAD BLOCK UUID --- %@ \n", [H2BleOad sharedInstance].h2_CharacteristicBlock);
#endif
                }
            }
        }
    }else{ // For BGM CABLE Data Sync
        if ([service.UUID isEqual:_h2ServiceCableUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID isEqual:_h2CharacteristicCableInfoUUID]){
                    _h2_CharacteristicCableInfo = characteristic;
                    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
#ifdef DEBUG_LIB
                    DLog(@"The UUID After Scan CABLE INFO is \n");
                    DLog(@"The UUID --- %@ \n", _h2_CharacteristicCableInfo);
#endif
                }
                if([characteristic.UUID isEqual:_h2CharacteristicMeterInfoUUID]){
                    _h2_CharacteristicMeterInfo = characteristic;
                    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
#ifdef DEBUG_LIB
                    DLog(@"The UUID After Scan METER INFO is \n");
                    DLog(@"The UUID --- %@ \n", _h2_CharacteristicMeterInfo);
#endif
                }
            }
#ifdef DEBUG_LIB
        }else{
            if ([service.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleDevInfoServiceUUID]){
#ifdef DEBUG_LIB
                DLog(@"H2 BLE CABLE DEV INFO SERVICE IN CHARACTERISTIC ...");
#endif
                for (CBCharacteristic *characteristic in service.characteristics) {
#ifdef DEBUG_LIB
                    DLog(@"H2 BLE CABLE DEV INFO SERVICE IN CHARACTERISTIC ... %@", characteristic);
#endif
                    if ([characteristic.UUID isEqual:_h2CharacteristicCableTimeUUID]){
                        _h2_CharacteristicCableTime = characteristic;
#ifdef DEBUG_LIB
                        DLog(@"H2 BLE CABLE GET CABLE TIME CHARACTERISTIC ...");
#endif
                        [peripheral readValueForCharacteristic:characteristic];
                    }
                }
            }
#endif
        }
/*
        if ([service.UUID isEqual:_h2ServiceMeterUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                
                if([characteristic.UUID isEqual:_h2CharacteristicMeterInfoUUID]){
                    _h2_CharacteristicMeterInfo = characteristic;
                    [[H2BleService sharedInstance].h2ConnectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
#ifdef DEBUG_LIB
                    DLog(@"The UUID After Scan METER INFO is \n");
                    DLog(@"The UUID --- %@ \n", _h2_CharacteristicMeterInfo);
#endif
                }
                if([characteristic.UUID isEqual:_h2CharacteristicMeterRecordUUID]){
                    _h2_CharacteristicMeterRecord = characteristic;
#ifdef DEBUG_LIB
                    DLog(@"The UUID After Scan METER RECORD is \n");
                    DLog(@"The UUID --- %@ \n", _h2_CharacteristicMeterRecord);
#endif
                }
            }
        }
*/
    }
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)CableDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
    if ([H2BleOad sharedInstance].oadMode) { // OAD Process

        UInt16 blkNumTmp = 0;
        UInt8 bTmp[2] = {0};
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        
        
        if ([characteristic.UUID isEqual:[H2BleOad sharedInstance].h2CharacteristicOADImgIdentifyUUID]){
            
            if ([[H2BleEquipId sharedEquipInstance].bleEquipBuffer length] > 2) {
                [H2BleOad sharedInstance].oadMode = NO;
                NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
                
                if([stringFromData isEqualToString:@"EOA"]){
#ifdef DEBUG_LIB
                    DLog(@"OAD UPDATE FINISHED ...");
#endif
                    [[H2BleCentralController sharedInstance] h2BleConnectReport:OAD_FINISHED];
                }else{
#ifdef DEBUG_LIB
                    DLog(@"NOT NEW VERSION,  Update Stop ...");
#endif
                   [[H2BleCentralController sharedInstance] h2BleConnectReport:OAD_OLD_IMAGE];
                }
                
            }else{
                memcpy(&blkNumTmp, [[H2BleEquipId sharedEquipInstance].bleEquipBuffer bytes], 2);
                [H2BleOad sharedInstance].blkNum = blkNumTmp;
                memcpy(bTmp, &blkNumTmp, 2);
                [[H2BleOad sharedInstance] H2OADWriteBlock];
            }
            
#ifdef DEBUG_LIB
            DLog(@"The UUID OAD IDENTIFY --- %@ \n", [H2BleOad sharedInstance].h2_CharacteristicIdentify);
            DLog(@"IDENTIFY OAD BLOCK NUM IS %04X, %02X, %02X, %d",blkNumTmp, bTmp[0], bTmp[1], (int)[[H2BleEquipId sharedEquipInstance].bleEquipBuffer length]);
#endif
            
            
        }else if([characteristic.UUID isEqual:[H2BleOad sharedInstance].h2CharacteristicOADImgBlockUUID]){
            
            memcpy(&blkNumTmp, [[H2BleEquipId sharedEquipInstance].bleEquipBuffer bytes], 2);
            [H2BleOad sharedInstance].blkNum = blkNumTmp;
            memcpy(bTmp, &blkNumTmp, 2);
#ifdef DEBUG_LIB
            DLog(@"The UUID OAD BLOCK --- %@ \n", [H2BleOad sharedInstance].h2_CharacteristicBlock);
            DLog(@"BLOCK OAD BLOCK NUM IS %04X, %02X, %02X",blkNumTmp, bTmp[0], bTmp[1]);
#endif
            [[H2BleOad sharedInstance] H2OADWriteBlock];
        }
    }else{
        
        NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        
        // Have we got everything we need?
        if ([stringFromData isEqualToString:@"EOM"] || [stringFromData isEqualToString:@"EOC"] || [stringFromData isEqualToString:@"ERR"]) {
            
            if ([H2BleCentralController sharedInstance].didSkipBLE) {
#ifdef DEBUG_LIB
                DLog(@"DEBUG_BLE SKIP BLE ...");
#endif
                return;// NO;
            }
#ifdef DEBUG_LIB
            DLog(@"Received End String: %@", stringFromData);
#endif
            if (_didWantToGetSN) {
                _didWantToGetSN = NO;
                [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
            }else{
                @autoreleasepool {
                    if ([[H2BleCentralController sharedInstance].bleDelegate conformsToProtocol:@protocol(H2BleCentralControllerDelegate)] &&
                        [[H2BleCentralController sharedInstance].bleDelegate respondsToSelector:@selector(receiveBleCableData:)])
                    {
                        [[H2BleCentralController sharedInstance].bleDelegate receiveBleCableData:_h2BLECableData];
#ifdef DEBUG_LIB
                        DLog(@"Did come to Normal H2SYNC .... BLE CABLE report data");
#endif
                    }
                }
            
            }
            [_h2BLECableData setLength:0];// Fixed crash issue
            
            return;// NO;
        }else{
            // Otherwise, just add the data on to what we already have
            
            // Log it
            //        DLog(@"Received: %@", stringFromData);
            if ([stringFromData isEqualToString:@"CABLE IN"] || [stringFromData isEqualToString:@"METER IN"]) {
                // Sending data to Cable ... command cycle
                [self h2BLESendDataCycle];
            }else{
                // Process cable info and meter Info and Record
                // save data that which comes from cable
                [_h2BLECableData appendData:characteristic.value];
            }
            return;// NO;
        }
    }
}

//- (void)bgmCableSync
//{
//    [[H2BleCentralController sharedInstance] h2BgmCableSyncBegin];
//}

- (void)CableDidUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_LIB
    DLog(@"CABLE NOTIFY ... DO SOMETHING ...");
#endif
    if ([characteristic.UUID isEqual:_h2CharacteristicMeterInfoUUID]) {
#ifdef DEBUG_LIB
        DLog(@"METER NOTIFY ... START SYNC");
#endif
        [[H2BleCentralController sharedInstance] h2BgmCableSyncBegin];
//        [NSTimer scheduledTimerWithTimeInterval:CMD_DELAY_TIME target:self selector:@selector(bgmCableSync) userInfo:nil repeats:NO];
    }
    
    if ([characteristic.UUID isEqual:[H2BleOad sharedInstance].h2CharacteristicOADImgBlockUUID]) {
#ifdef DEBUG_LIB
        DLog(@"The OAD BLOCK UpDate Start ...");
#endif
        [self h2CableFWUpdateBegin];
//        [NSTimer scheduledTimerWithTimeInterval:CMD_DELAY_TIME target:self selector:@selector(h2CableFWUpdateBegin) userInfo:nil repeats:NO];
    }
}


//
- (void)h2BLESendDataCycle//:cmdSrc UInt8:cmdLen
{
//    DLog(@"Write  Mode ... index is %d, length is %lu ", self.h2BLESendDataIndex, (unsigned long)self.h2BLEDataToSend.length);
    //    _h2CmdEnd
    NSData *dataToWrite = [[NSData alloc]init];
    
    if (self.h2BLESendDataIndex >= self.h2BLEDataToSend.length) {
        if (sendingEOM ) {
#ifdef DEBUG_LIB
            DLog(@"Write  RETURN HERE --- ");
#endif
            return;
        }
        unsigned char charTemp[3] = {'E', 'O', 'H'};
        
        dataToWrite = [NSData dataWithBytes:charTemp length:sizeof(charTemp)];
        
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_CharacteristicForWrite type:CBCharacteristicWriteWithResponse];
#ifdef DEBUG_LIB
        DLog(@"Write  EOH --- ");
#endif
        sendingEOM = YES;
        return;
        
    }else{
        NSInteger amountToSend = self.h2BLEDataToSend.length - self.h2BLESendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        //        NSData *
        dataToWrite = [NSData dataWithBytes:self.h2BLEDataToSend.bytes+self.h2BLESendDataIndex length:amountToSend];
        // It did send, so update our index
#ifdef DEBUG_LIB
        DLog(@"Write  Normal BEFORE %d, %d", self.h2BLESendDataIndex, (int)amountToSend);
#endif
        self.h2BLESendDataIndex += amountToSend;
#ifdef DEBUG_LIB
        DLog(@"Write  Normal AFTER %d, %d", self.h2BLESendDataIndex, (int)amountToSend);
#endif
    }
#ifdef DEBUG_LIB
    DLog(@"The value of %@",dataToWrite);
#endif
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_CharacteristicForWrite type:CBCharacteristicWriteWithResponse];
}

- (void)H2BgmCableWriteTask:(NSData *)cmdData withCharacteristicSel:(UInt16)chSel {
    
    //    NSData *dataToWrite = [[NSData alloc]init];
    
    //    unsigned char charTemp[4] = {1, 2, 3, 4};
    //    _h2CableIndex++;
    //    if (_h2CableIndex >= 7) {
    //        _h2CableIndex = 0;
    //    }
    //    memcpy(&charTemp[1], &_h2CableIndex, 1);
    
    //    dataToWrite = [NSData dataWithBytes:charTemp length:sizeof(charTemp)];
    sendingEOM = NO;
    
    [_h2BLECableData setLength:0];
    [_h2BLEDataToSend setLength:0];
    self.h2BLESendDataIndex = 0;
#ifdef DEBUG_LIB
    DLog(@"DEBUG_LIB cmd length is %lu", (unsigned long)cmdData.length);
#endif
    
    //    [self.h2BLEDataToSend appendBytes:charTemp length:sizeof(charTemp)];
#ifdef DEBUG_LIB
    DLog(@"DEBUG_LIB CMD %@ %@", self.h2BLEDataToSend, cmdData);
#endif
    [self.h2BLEDataToSend appendBytes:cmdData.bytes length:cmdData.length];
    if (chSel) {
        _h2_CharacteristicForWrite = _h2_CharacteristicMeterInfo;
    }else{
        _h2_CharacteristicForWrite = _h2_CharacteristicCableInfo;
    }
    [self h2BLESendDataCycle];
}


- (void)h2BLEResetCmdBuffer
{
    sendingEOM = NO;
}

+ (H2BgmCable *)sharedInstance
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
