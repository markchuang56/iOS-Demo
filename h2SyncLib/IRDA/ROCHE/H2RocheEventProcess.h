//
//  H2RocheEventProcess.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#define ROCHE_AUDIO_CMD_INTERVAL                0.02f
#define ROCHE_BLE_CMD_INTERVAL                  0.12f
#define ROCHE_RESEND_TIME_MAX                   3
#define ROCHE_DATA_STX                          0x02
#define ROCHE_DATA_EOT                          0x04

#import <Foundation/Foundation.h>

@interface H2RocheEventProcess : NSObject

@property(readwrite) BOOL didSkipMeterEndCmd;

@property(readwrite) BOOL didSendMeterPreCmd;

@property(readwrite) UInt8 resendCount;

@property(readwrite) BOOL didRocheSendGeneralCommand;
@property(readwrite) BOOL didRocheSendRecordCommand;




+ (H2RocheEventProcess *)sharedInstance;

- (void)h2RocheInfoRecordProcess;

- (void)h2SynRocheResetMeter;
#pragma mark - M_DCL -- ACCU CHEK COMPACTPLUS DEFINE

- (void)h2SyncCompactPlusGeneral;
- (void)h2SyncCompactPlusReadRecord;

#pragma mark - M_DCL -- ACCU CHEK AVIVA

- (void)h2SyncAvivaGeneral;
- (void)h2SyncAvivaReadRecord;

@end

// [H2RocheEventProcess sharedInstance] didAudioSkipOffSW
// [H2RocheEventProcess sharedInstance] h2SyncAvivaReadRecord
