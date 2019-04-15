//
//  RocheSetInfo.h
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/8/23.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#define GUIDE_ELSE_SERVICE_UUID                     @"00000000-0000-1000-1000-000000000000"

#define GUIDE_ELSE_CHAR0_UUID                       @"00000000-0000-1000-1000-000000000001"
#define GUIDE_ELSE_CHAR1_UUID                       @"00000000-0000-1000-1000-000000000002"

#define ROCHE_CMD_FLOW_MAX                          0x10

#import <Foundation/Foundation.h>

@interface RocheSetInfo : NSObject

@property (nonatomic, strong) CBUUID *guideElseServiceID;

@property (nonatomic, strong) CBUUID *guideCharacteristicA0_UUID;
@property (nonatomic, strong) CBUUID *guideCharacteristicA1_UUID;

@property (nonatomic, strong) CBService *guideElseFlexService;

@property (nonatomic, strong) CBCharacteristic *guideCharacteristicWrite;

- (void)guideValueUpdate:(CBCharacteristic *)characteristic;

- (void)rocheCmdInit;
- (void)guideCommandFlow;
//- (void)guideWriteCurrentTime;
- (void)rocheMeterTimeParser:(CBCharacteristic *)characteristic;

+ (RocheSetInfo *)sharedInstance;

@end
