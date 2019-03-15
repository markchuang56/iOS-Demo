//
//  BleBgmPaired.m
//  SQX
//
//  Created by h2Sync on 2016/2/4.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "BleBgmPaired.h"

@implementation BleBgmPaired

- (id)init
{
    if (self = [super init]) {
        
        _peripheralsHasPaired = [[NSMutableArray alloc] init];
        _testNumber = 20;
        _testNumber++;
        NSLog(@"TEST VALUE IS INIT %d", _testNumber);
        
//        _devSerialNumber = [[NSString alloc] init];
 //       _devIdentifier = [[NSString alloc] init];
        
//        _serverLastDateTimeInfo = [[NSMutableArray alloc] init];
    }
    NSLog(@"INIT BGM PAIRED ");
    return self;
}





- (void)initPeripheralsHasPaired
{
    
}

+ (BleBgmPaired *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        //        peripheralsHasPaired = [[NSMutableArray alloc] init];
    });
    NSLog(@"BLE BGM VIEW instance value @%@", _sharedObject);
    return _sharedObject;
}

@end
