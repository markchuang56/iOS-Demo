//
//  H2BeneChekEventProcess.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//
#define BENECHEK_BLE_CMD_INTERVAL              0.02f
#define BENECHEK_AUDIO_CMD_INTERVAL            0.3f


#import <Foundation/Foundation.h>

@interface H2BeneChekEventProcess : NSObject

//@property(readwrite) float beneChekCmdInterval;

+ (H2BeneChekEventProcess *)sharedInstance;

- (void)h2BeneChekInfoRecordProcess;

#pragma mark - BENECHECK COMMAND DEFINE
- (void)h2SyncBeneChekGeneral;
- (void)h2SyncBeneChekReadRecord;


@end
