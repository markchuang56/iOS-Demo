//
//  H2Timer.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/6/3.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface H2Timer : NSObject

//@property (nonatomic, strong) NSTimer *bleCableSyncFinished;

@property (nonatomic, strong) NSTimer *resendMeterCmd;
@property (nonatomic, strong) NSTimer *resendCableCmd;



- (void)clearCableTimer;
+ (H2Timer *)sharedInstance;
@end

