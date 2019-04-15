//
//  H2BayerEventProcess.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#define METER_BAYER_RESEND_INTERVAL       6.5f

#define BAYER_BLE_CMD_INTERVAL              0.02f
#define BAYER_AUDIO_CMD_INTERVAL            0.3f


#import <Foundation/Foundation.h>

@interface H2BayerEventProcess : NSObject


@property(readwrite) NSMutableArray *serverSrcLastDateTimes;
@property(readwrite) UInt8 bayerParam;
@property(readwrite) UInt8 bayerTag;



+ (H2BayerEventProcess *)sharedInstance;

- (void)h2BayerInfoRecordProcess;

#pragma mark - BAYER CONTOUR COMMAND
- (void)h2SyncBayerGeneral;

@end
