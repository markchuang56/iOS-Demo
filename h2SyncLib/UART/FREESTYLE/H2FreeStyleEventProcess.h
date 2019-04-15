//
//  H2FreeStyleEventProcess.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#define FREESTYLE_BLE_CMD_INTERVAL                      0.02f
#define FREESTYLE_AUDIO_CMD_INTERVAL                    0.3f

#import <Foundation/Foundation.h>

@interface H2FreeStyleEventProcess : NSObject
{
    
}

@property(readwrite) float freeStyleCmdInterval;


+ (H2FreeStyleEventProcess *)sharedInstance;

- (void)h2FreeStyleInfoRecordProcess;

- (void)h2SyncFreeStyleLiteGeneral;

@end
