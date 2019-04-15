//
//  H2DataFlow.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/9.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#define BLE_FLAG_MASK                   0x8000
#define GPROTOCOL_MASK                  0xFFFF
#define UART_PROTOCOL_MASK              0xFF


#import <Foundation/Foundation.h>

@interface H2DataFlow : NSObject

@property (nonatomic, retain) NSData *dataForEngineer;

@property(readwrite) UInt32 equipId;
@property(readwrite) UInt8 equipFunction;
@property(readwrite) UInt16 equipProtocolId;
@property(readwrite) UInt8 equipUartProtocol;


@property(readwrite)BOOL sdkActivity;

@property(readwrite)BOOL cableUartStage;

@property(nonatomic, strong) NSString *cableSN;
@property(nonatomic, strong) NSString *cableFW;

- (void)bleCableDataParser:(NSData *)bleCableData;
- (void)audioCableDataParser:(uint8_t)ch;



- (void)h2SyncReportBufferInit;
- (NSString *)cableNumberProcess:(NSData *)serialNumber;


#pragma mark - METER EX SETTING
- (void)h2RocheResetMeterTask;
//- (void)h2SyncOneTouchUltra2ReadRecordAll;
- (void)h2SyncUltra2ReadRecordTask;
- (void)h2BayerExternalSetting;
- (void)h2GlucoCardResetMeterTask;
- (void)h2EmbraceGetAllRecord;
- (void)h2EmbraceExternalSetting;

- (void)h2CableUartInit:(id)sender;
- (void)h2CableSendAudioCommand;

- (void)h2SyncInit:(id)sender;

+ (H2DataFlow *)sharedDataFlowInstance;
@end

// [H2DataFlow sharedDataFlowInstance].sdkActivity
/*
 
 [H2DataFlow sharedDataFlowInstance].equipId = 0;
 [H2DataFlow sharedDataFlowInstance].equipFunction = 0;
 [H2DataFlow sharedDataFlowInstance].equipBleProtocol = 0;
 [H2DataFlow sharedDataFlowInstance].equipUartProtocol = 0;
 
 
 
 */




