//
//  BWSViewController.h
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/11/30.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class H2BwRecord;

@interface BWSViewController : NSObject

/*
@property (nonatomic, strong) NSString *systolic;
@property (nonatomic, strong) NSString *systolicUnit;

@property (nonatomic, strong) NSString *diastolic;
@property (nonatomic, strong) NSString *diastolicUnit;

@property (nonatomic, strong) NSString *meanAp;
@property (nonatomic, strong) NSString *meanApUnit;

@property (nonatomic, strong) NSString *pulse;
*/
@property (nonatomic, strong) NSString *bwsValue;
@property (nonatomic, strong) NSString *bwsUnit;
@property (nonatomic, strong) NSString *timestamp;



- (H2BwRecord *)BWSDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic;


+ (BWSViewController *)sharedInstance;

@end




NS_ASSUME_NONNULL_END
