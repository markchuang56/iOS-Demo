//
//  RocheSetInfo.m
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/8/23.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import "H2Config.h"
#import "h2BrandModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "H2BleService.h"
//#import "OneTouchPlusFlex.h"

#import "LSOneTouchUltraMini.h"
#import "H2BleTimer.h"
#import "H2BleCentralManager.h"
#import "H2Records.h"
#import "H2LastDateTime.h"
#import "H2DebugHeader.h"

#import "RocheSetInfo.h"

@interface RocheSetInfo()
{
    UInt8 guideFlowSel;
    UInt8 guideCmdBuffer[32];
    UInt8 guideCmdLen;
}

@end


@implementation RocheSetInfo

- (id)init
{
    if (self = [super init]) {
        _guideElseServiceID = [CBUUID UUIDWithString:GUIDE_ELSE_SERVICE_UUID];
        
        _guideCharacteristicA0_UUID = [CBUUID UUIDWithString:GUIDE_ELSE_CHAR0_UUID];
        _guideCharacteristicA1_UUID = [CBUUID UUIDWithString:GUIDE_ELSE_CHAR1_UUID];
        
        _guideElseFlexService = nil;
        
        _guideCharacteristicWrite = nil;
        
        guideFlowSel = 0;
        guideCmdLen = 0;
    }
    return self;
}



UInt8 guideInit[] = {
    0x01, 0x01, 0x83, 0x01,  0x00, 0x01, 0x00, 0x06,
    0x00, 0x03, 0x00, 0x02,  0x00, 0x03, 0x6C, 0x41
};

unsigned char guideCmdXXXSecond[] =
{
    0x01, 0x0F, 0x83, 0x02,  0x00, 0x01, 0x01, 0x04,
    0x00, 0x11, 0x01, 0x00,  0x98, 0x06, 0x16, 0x44,
    0x2F, 0x50, 0xF2, 0x2F
};

unsigned char guideCmdSecond[] =
{
    0x01, 0x0F, 0x83, 0x02 ,  0x00, 0x01, 0x01, 0x04,
    0x00, 0x11, 0x01, 0x00 ,  0x98, 0x06, 0x16, 0x44,
    0x2F, 0x50, 0xF2, 0x2F ,
    
    0x02, 0x0F, 0xE0, 0x43 , 0x45, 0xD3, 0xE8, 0x08 ,
    0x26, 0x4A, 0x4A, 0xF6 , 0x12, 0x15, 0xA5, 0xE1 ,
    0x7E, 0xFD, 0x99, 0xA9 ,
    
    0x03, 0x0F, 0x0A, 0xA0 , 0xE3, 0xE5, 0x8F, 0x71 ,
    0x28, 0xB1, 0xA4, 0x7C , 0xA0, 0x90, 0xA1, 0x6A ,
    0x40, 0x0B, 0xAF, 0x7F ,
    
    0x04, 0x0F, 0xF8, 0x80 , 0x13, 0x4E, 0x15, 0x98 ,
    0xA4, 0x22, 0x36, 0x28 , 0x66, 0x6E, 0x27, 0xA5 ,
    0x1D, 0x9D, 0x0D, 0xF7 ,
    
    0x05, 0x0F, 0xB0, 0x0E , 0x4D, 0xA8, 0xB9, 0x71 ,
    0x30, 0xD8, 0xDD, 0x96 , 0x29, 0xA8, 0x6D, 0xC6 ,
    0xCB, 0x25, 0xCC, 0x9B ,
    
    0x06, 0x0F, 0x0F, 0x30 , 0xB0, 0x4E, 0x34, 0x67 ,
    0x7B, 0x71, 0x70, 0x8D , 0x37, 0xA6, 0xDB, 0x40 ,
    0xBC, 0x7D, 0x29, 0x00 ,
    
    0x07, 0x0F, 0x5F, 0xA2 , 0xF4, 0xF6, 0x68, 0x20 ,
    0x7E, 0x81, 0x5F, 0x4A , 0xB9, 0x9A, 0xC0, 0xDC ,
    0x7D, 0xF4, 0xD2, 0x86 ,
    
    0x08, 0x0F, 0x17, 0xC8 , 0x08, 0xFC, 0x25, 0x1F ,
    0x48, 0xFE, 0x63, 0x9E , 0x07, 0xAA, 0x07, 0x85 ,
    0x2C, 0x67, 0x22, 0xA2 ,
    
    0x09, 0x0F, 0x8B, 0x3C , 0x02, 0xDF, 0x77, 0x1F ,
    0x28, 0x8A, 0xD5, 0xF8 , 0xBF, 0x37, 0x6E, 0x2B ,
    0xFE, 0xA2, 0x55, 0x08 ,
    
    0x0A, 0x0F, 0x42, 0xD4 , 0x89, 0x2A, 0x33, 0x10 ,
    0x29, 0x17, 0xF0, 0xD9 , 0xC2, 0xD5, 0xA2, 0x90 ,
    0x43, 0xA5, 0x28, 0x28 ,
    
    0x0B, 0x0F, 0xC9, 0xB1 , 0xFF, 0xDB, 0x6F, 0xE5 ,
    0xB3, 0x29, 0xDA, 0xE9 , 0x40, 0x51, 0x46, 0x0B ,
    0x23, 0x4B, 0xF4, 0x60 ,
    
    0x0C, 0x0F, 0x34, 0x6A , 0xAE, 0x22, 0xA7, 0xA4 ,
    0x30, 0x83, 0xDD, 0x85 , 0x4C, 0xB3, 0xD8, 0xB6 ,
    0x33, 0x1F, 0xF8, 0x49 ,
    
    0x0D, 0x0F, 0x01, 0x20 , 0x8F, 0x76, 0x04, 0x27 ,
    0x5F, 0x20, 0x47, 0x35 , 0x44, 0x5E, 0x13, 0x58 ,
    0x8F, 0x4F, 0x32, 0x30 ,
    
    0x0E, 0x0F, 0xE9, 0x14 , 0x3A, 0x22, 0x69, 0xC9 ,
    0x32, 0x72, 0x8F, 0xA0 , 0xC0, 0x3F, 0x9E, 0x06 ,
    0xA2, 0xC1, 0xEA, 0x54 //,
};

unsigned char guideCmd_F[] =
{
    0x0F, 0x0F, 0x05, 0x63 , 0x72, 0x04, 0xB4, 0xF5 ,
    0x8F, 0xAB, 0x92, 0x32 , 0xC4, 0x7B, 0xF2, 0x34 ,
    0xE4, 0x17
    
};


#pragma mark - ========= GUIDE ==========
- (void)guideValueUpdate:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_ONETOUCH
    NSLog(@"ROCHE VALUE UPDATE ....");
#endif
    if (![characteristic.UUID isEqual:_guideCharacteristicA0_UUID]) {
        //NSLog(@"GUIDE Others !!");
        return;
    }
    Byte *guideTmpBuffer = (Byte *)malloc(20);
    memcpy(guideTmpBuffer, [characteristic.value bytes], characteristic.value.length);
#ifdef DEBUG_ONETOUCH
    NSLog(@"ROCHE VALUE UPDATE .... ELSE BACK");
#endif
    if([H2BleService sharedInstance].blePairingStage){
        if(guideTmpBuffer[0] == 0x03 && guideTmpBuffer[1] == 0x03){
            //[[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
            [self guideCommandFlow];
        }
        
        if (guideFlowSel == ROCHE_CMD_FLOW_MAX) {
        //if(guideTmpBuffer[0] == 0x0F && guideTmpBuffer[1] == 0x0F){
            [[H2BleCentralController sharedInstance] h2BleConnectMultiDevice];
            //[self guideCommandFlow];
        }
        
        return;
    }
}

- (void)rocheCmdInit
{
    guideFlowSel = 0;
    guideCmdLen = 0;
    //[self guideCommandFlow];
    
    NSData *dataToWrite = [[NSData alloc]init];
    guideCmdLen = sizeof(guideInit);
    memcpy(guideCmdBuffer, guideInit, guideCmdLen);
    
    //if(guideSend){
        dataToWrite = [NSData dataWithBytes:guideCmdBuffer length:guideCmdLen];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_guideCharacteristicWrite type:CBCharacteristicWriteWithResponse];
#ifdef DEBUG_ONETOUCH
        NSLog(@"GUIDE CT CMD = %@", dataToWrite);
#endif
    //}
    
    guideFlowSel++;
#ifdef DEBUG_ONETOUCH
    if(guideFlowSel < ROCHE_CMD_FLOW_MAX){
        NSLog(@"GUIDE NEXT CMD ...");
        //[NSTimer scheduledTimerWithTimeInterval:1.8f target:self selector:@selector(guideCommandFlow) userInfo:nil repeats:NO];
    }
#endif
}

- (void)guideCommandFlow
{
    BOOL guideSend = YES;
    NSData *dataToWrite = [[NSData alloc]init];
#ifdef DEBUG_ONETOUCH
    NSLog(@"GUIDE COMMAND ... %02X", guideFlowSel);
#endif
    switch (guideFlowSel) {
        case 0:
            guideCmdLen = sizeof(guideInit);
            memcpy(guideCmdBuffer, guideInit, guideCmdLen);
            break;
            
        case 1:case 2:case 3:case 4:
        case 5:case 6:case 7:case 8:
        case 9:case 0xA:case 0xB:
        case 0xC:case 0xD:case 0xE:
            guideCmdLen = 20;
            memcpy(guideCmdBuffer, &guideCmdSecond[(guideFlowSel-1)*20], guideCmdLen);
            break;
            
        case 0xF:
            guideCmdLen = 18;
            memcpy(guideCmdBuffer, guideCmd_F, guideCmdLen);
            break;
            
        default:
            guideSend = NO;
            break;
    }
    
    if(guideSend){
        dataToWrite = [NSData dataWithBytes:guideCmdBuffer length:guideCmdLen];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_guideCharacteristicWrite type:CBCharacteristicWriteWithResponse];
#ifdef DEBUG_ONETOUCH
        NSLog(@"GUIDE CT CMD = %@", dataToWrite);
#endif
    }
    
    guideFlowSel++;
    if(guideFlowSel < ROCHE_CMD_FLOW_MAX){
#ifdef DEBUG_ONETOUCH
        NSLog(@"GUIDE NEXT CMD ...");
#endif
        [NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(guideCommandFlow) userInfo:nil repeats:NO];
    }
}


- (void)rocheMeterTimeParser:(CBCharacteristic *)characteristic
{
    
    //if (![characteristic.UUID isEqual:_guideCharacteristicA0_UUID]) {
    //return;
    //}
    
    Byte *timeBuffer = (Byte *)malloc(20);
    memcpy(timeBuffer, [characteristic.value bytes], characteristic.value.length);
    
    UInt16 rocheYear = 0;
    memcpy(&rocheYear, timeBuffer, 2);
    
    UInt8 rocheMonth = timeBuffer[2];
    UInt8 rocheDay = timeBuffer[3];
    
    UInt8 rocheHour = timeBuffer[4];
    UInt8 rocheMinute = timeBuffer[5];
    //UInt8 rocheSecond = timeBuffer[6];
    
#ifdef DEBUG_BW
    //DLog(@"254C == 年 : %d, 月 : %d, 日 : %d", rocheYear, rocheMonth, rocheDay);
    //DLog(@"254C == 時 : %d, 分 : %d, 秒 : %d", rocheHour, rocheMinute, rocheSecond);
#endif
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000", rocheYear, rocheMonth, rocheDay, rocheHour, rocheMinute];
}

/*
 - (void)guideWriteCurrentTime
 {
 
 
 NSData *dataToWrite = [[NSData alloc]init];
 
 dataToWrite = [NSData dataWithBytes:dataCmd length:sizeof(dataCmd)];
 
 [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_guideCharacteristicWrite type:CBCharacteristicWriteWithResponse];
 NSLog(@"GUIDE CT CMD = %@", dataToWrite);
 }
 */

+ (RocheSetInfo *)sharedInstance
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
