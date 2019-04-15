//
//  OMRON_HEM-9200T.h
//  h2LibAPX
//
//  Created by h2Sync on 2017/4/26.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HEM_9200T_EX_INTERVAL                   3.0f
#define HEM_9200T_CURRENT_TIME_INTERVAL         (30.0f - HEM_9200T_EX_INTERVAL)
#define HEM_9200T_RECORD_INTERVAL               2.0f

@interface OMRON_HEM_9200T : NSObject

@property (nonatomic, strong) NSTimer *hem9200tCurrentTimer;
@property (nonatomic, strong) NSTimer *hem9200tSyncTimer;

@property (readwrite) BOOL hem9200TRecordTimeOut;
@property (readwrite) BOOL hem9200tSyncModeHasRecord;

@property (readwrite) BOOL hem9200tSerialNumberDone;
@property (readwrite) BOOL hem9200tCurrentTimeDone;



- (void)hem9200TRecordParser:(CBCharacteristic *)characteristic;

- (void)hem9200tSetCurrentTimer;
- (void)hem9200tClearCurrentTimer;
- (void)hem9200tCurrentTimerTask;

- (void)hem9200tClearRecordTimer;
- (void)hem9200tSetRecordTimer;


+ (OMRON_HEM_9200T *)sharedInstance;
@end


