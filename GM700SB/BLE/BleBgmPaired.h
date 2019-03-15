//
//  BleBgmPaired.h
//  SQX
//
//  Created by h2Sync on 2016/2/4.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BleBgmPaired : NSObject

@property (nonatomic, strong)NSMutableArray *peripheralsHasPaired;
@property (readwrite)UInt16 testNumber;

//@property (nonatomic, strong) NSString *devSerialNumber;
//@property (nonatomic, strong) NSString *devIdentifier;

//@property (nonatomic, strong) NSMutableArray *serverLastDateTimeInfo;

- (void)initPeripheralsHasPaired;

+ (BleBgmPaired *)sharedInstance;
@end



