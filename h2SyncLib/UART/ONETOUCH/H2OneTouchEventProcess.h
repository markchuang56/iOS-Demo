//
//  H2OneTouchEventProcess.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#define ULTRA_MINI_CMD_INTERVAL                     0.05f
#define ULTRA2_RESEND_INTERVAL                      3.0f


//#define ONETOUCH_AUDIO_CMD_INTERVAL                 0.3f

#define TIME_PER_RECORD_FOR_ULTRA2                  0.1f

#import <Foundation/Foundation.h>

@interface H2OneTouchEventProcess : NSObject


@property(readwrite) float ultra2SwitchOnDelayTime;
@property(readwrite) float ultra2RecordTimeOutInterval;


@property(readwrite) BOOL didOneTouchSendGeneralCommand;
@property(readwrite) BOOL didOneTouchSendRecordCommand;

@property(readwrite) BOOL resendUltra2Flag;
@property(readwrite) float resendUltra2cmdSystemInterval;

@property(readwrite) UInt8 ultra2DivCycle;

@property(readwrite) BOOL ultraOldFinished;

+ (H2OneTouchEventProcess *)sharedInstance;
// [H2OneTouchEventProcess sharedInstance].resendUltra2Flag

// [H2OneTouchEventProcess sharedInstance] h2SyncUltra2ReadRecordAll
- (void)h2OneTouchInfoRecordProcess;

#pragma mark - ONE TOUCH ULTRA 2 COMMAND
- (void)h2SyncUltra2CmdTurnOnSwitch;
//- (void)h2DemoSyncDebug:(id)sender;
- (void)h2SyncUltra2General;
- (void)h2SyncUltra2ReadRecord;
- (void)h2SyncUltra2BLEReadRecordAll;

#pragma mark - ULTRA XXX
- (void)h2SyncUltraXXXGeneral;

#pragma mark - VUE VUE GENERAL ###
- (void)h2SyncUltraVueGeneral;


#pragma mark - ONE TOUCH ULTRA MINI COMMAND

- (void)h2SyncUltraMiniGeneral;
- (void)h2SyncUltraMiniReadRecord;

@end


// [H2OneTouchEventProcess sharedInstance].ultra2Index

