//
//  H2BleOad.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/11/30.
//  Copyright © 2015年 h2Sync. All rights reserved.
//


#define WORLD_LEN               4

#import "h2DebugHeader.h"
#import "H2Sync.h"

#import "H2BleCentralManager.h"
#import "H2BleOad.h"
#import "H2BleEquipId.h"
#import "H2BleService.h"

#import "H2BleTimer.h"

@implementation H2BleOad


- (id)init
{
#ifdef DEBUG_LIB
    DLog(@"DEBUG_LIB BLE init .... PRE");
#endif
    if (self = [super init]) {
        
        //        [H2BleService sharedInstance];
        
        _blkNum = 0;
        _crc = 0x00;
        _crcShadow = 0x00;
        
        _ver = 0;
        _lenBlock = 0;
        
        _header = (Byte *)malloc(16);
//        _buffer = (Byte *)malloc(18);
        _imgBuffer = (Byte *)malloc(0x4FFFF);
        
        _oadMode = NO;
        _didOadWriteFinished = NO;
        
        _h2_ServiceOAD = nil;
        
        // OAD
        _h2ServiceOADImgUUID = [CBUUID UUIDWithString:H2_OAD_IMG_SERVICE_UUID];
        
        _h2CharacteristicOADImgIdentifyUUID = [CBUUID UUIDWithString:H2_OAD_IMG_ID_CHARACTERISTIC_UUID];
        _h2CharacteristicOADImgBlockUUID = [CBUUID UUIDWithString:H2_OAD_IMG_BLOCK_CHARACTERISTIC_UUID];
        
        // OAD Identify and Flash Block Caracteristic
        _h2_CharacteristicIdentify = nil;
        _h2_CharacteristicBlock = nil;
        
#ifdef DEBUG_LIB
        DLog(@"DEBUG_LIB OAD init ....");
#endif
    }
    return self;
}





- (void)H2OADRequestIdentify:(NSData *)cmdData withCharacteristicSel:(UInt16)chSel {
    
}
- (void)H2OADRequestBlock:(NSData *)cmdData withCharacteristicSel:(UInt16)chSel {
    
}

#pragma mark - H2 BLE OAD -- WRITE --
- (void)H2OADWriteIdentify {
    
    // Write Identify
    
    // Get Notification
    
    // Write Data
    
    [H2BleService sharedInstance].bleOADStage = YES;
    _blkNum = 0;
    _didOadWriteFinished = NO;
    

    memcpy(&_crc, _imgBuffer, 2);
    memcpy(&_crcShadow, _imgBuffer+2, 2);
    memcpy(&_ver, _imgBuffer+4, 2);
    memcpy(&_lenBlock, _imgBuffer+6, 2);
    
    //_lenBlock /= WORLD_LEN;
    
    _lenBlock >>= 2;
    
    
    NSData *dataToWrite = [[NSData alloc]init];
    
    unsigned char charTemp[OAD_HEADER_LEN] = {0};
    
    
    memcpy(charTemp, _imgBuffer + 4, OAD_HEADER_LEN);
#ifdef DEBUG_LIB
    for (int i=0; i<OAD_BLOCK_LEN; i++) {
        DLog(@"THE OAD HEADER i = %d data %02X", i, charTemp[i]);
    }
#endif

    dataToWrite = [NSData dataWithBytes:charTemp length:sizeof(OAD_HEADER_LEN)];
    
#ifdef DEBUG_LIB
    DLog(@"DEBUG_OAD CRC is            %04X\n", _crc);
    DLog(@"DEBUG_OAD CRC SHARDOW is    %04X\n", _crcShadow);
    DLog(@"DEBUG_OAD VER is            %04X\n", _ver);
    DLog(@"DEBUG_OAD data length is    %04X\n", _lenBlock);
    DLog(@"DEBUG_OAD ID is %02X %02X %02X %02X\n", _imgBuffer[8], _imgBuffer[9], _imgBuffer[10], _imgBuffer[11]);
    DLog(@"DEBUG_OAD ID is %02X %02X %02X %02X\n", _imgBuffer[12], _imgBuffer[13], _imgBuffer[14], _imgBuffer[15]);
#endif
    
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_CharacteristicIdentify type:CBCharacteristicWriteWithResponse];
    [[H2BleTimer sharedInstance] h2SetBleTimerTask:OAD_WRITE_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
    //[[H2BleService sharedInstance] enableRecordTimer:OAD_WRITE_TIME];
}


- (void)H2OADWriteBlock {
    
    // Write Identify
    
    // Get Notification
    
    // Write Data
    
    NSData *dataToWrite = [[NSData alloc]init];
    
    unsigned char charTemp[OAD_LEN] = {0};
    
    memcpy(charTemp, &_blkNum, 2);
    memcpy(&charTemp[2], (_imgBuffer + OAD_BLOCK_LEN * _blkNum), OAD_BLOCK_LEN);
    
    dataToWrite = [NSData dataWithBytes:charTemp length:OAD_BLOCK_LEN + 2];
    
#ifdef DEBUG_LIB
    DLog(@"DEBUG_OAD BLOCK NUMBER is %d", _blkNum);
    for (int i=0; i<OAD_BLOCK_LEN + 2; i++) {
        DLog(@"THE OAD BLOCK i = %d data %02X", i, charTemp[i]);
    }
#endif
    
    [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_h2_CharacteristicBlock type:CBCharacteristicWriteWithResponse];
    
    _blkNum++;
    [[H2Sync sharedInstance] sdkOadWriteProgress:_lenBlock withFraction:_blkNum];
    
    if (_blkNum == _lenBlock) {
        _didOadWriteFinished = YES;
    }else{
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:OAD_WRITE_INTERVAL taskSel:BLE_TIMER_RECORD_MODE];
        //[[H2BleService sharedInstance] enableRecordTimer:OAD_WRITE_TIME];
    }
}


+ (H2BleOad *)sharedInstance
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
    DLog(@"BLE OAD INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
    
}

@end
