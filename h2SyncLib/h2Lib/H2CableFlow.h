//
//  H2CableFlow.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/8.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

//#define AUDIO_FLOW

#define SYSTEM_EXIST_RESEND_CYCLE                       4

#define SYSTEM_NORMAL_RESEND_INTERVAL                   1.4f
//#define SYSTEM_NORMAL_RESEND_INTERVAL                   1.0f
#define SYSTEM_NORMAL_RESEND_CYCLE                      2

#define SYSTEM_GET_BUFFER_RESEND_INTERVAL               2.2f


#define METER_NORMAL_RESEND_INTERVAL                    3.2f
#define METER_NORMAL_RESEND_CYCLE                       2

#define CABLE_NORMAL_CMD_INTERVAL                       0.2f

#import <Foundation/Foundation.h>

@interface H2CableFlow : NSObject


@property (nonatomic, strong) NSTimer *cableTimer;

//@property(readwrite)BOOL bleCableReset;
@property(readwrite) UInt8 audioSystemCmd;

- (void)h2CableSystemCommand:(id)sender;

- (void)h2SyncSystemCommandResendTask:(id)sender;
- (void)h2SyncSystemCommandResendTimerSetting;

- (void)h2SyncMeterCommandResendTask:(id)sender;
- (void)h2SyncMeterCommandResendTimerSetting;

- (void)h2SyncTurnOffSwitch;
- (void)h2CableBLERocheTalk;




- (void)h2SystemResendCmdInit;
- (void)h2CableMeterCommandPreProcess;

- (void)h2CableBLEEmbraceRecordEndingTask;

- (BOOL)bleSyncInitTask:(NSString *)bleIdentifierString;

+ (H2CableFlow *)sharedCableFlowInstance;
@end

// [H2CableFlow sharedCableFlowInstance].audioCheckingTimer



