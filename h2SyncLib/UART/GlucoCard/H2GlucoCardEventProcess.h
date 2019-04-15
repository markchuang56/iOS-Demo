//
//  H2GlucoCardEventProcess.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

//#define GLUCOCARD_BLE_CMD_INTERVAL              0.02f
//#define GLUCOCARD_AUDIO_CMD_INTERVAL            0.3f

#import <Foundation/Foundation.h>

@interface H2GlucoCardEventProcess : NSObject

@property(readwrite) float glucoCardCmdInterval;

+ (H2GlucoCardEventProcess *)sharedInstance;

- (void)h2GlucoCardInfoRecordProcess;

- (void)h2SynGlucoCardResetMeter;

#pragma mark - GLUCOCARD VITAL COMMAND
- (void)h2SyncGlucoCardVitalGeneral;
- (void)h2SyncGlucoCardVitalReadRecord;



#pragma mark - RELION CONFIRM COMMAND
- (void)h2SyncReliOnGeneral;
- (void)h2SyncReliOnReadRecord;

//- (void)h2SyncReliOnSetCounter:(UInt8)cmdIndex;
//- (void)h2SyncReliOnResetCounter;

//- (UInt8)h2SyncReliOnGetCounter;

@end
