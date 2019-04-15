//
//  H2SystemEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

//

#import "H2RocheEventProcess.h"
#import "H2BayerEventProcess.h"
#import "H2OneTouchEventProcess.h"
#import "H2FreeStyleEventProcess.h"

#import "H2GlucoCardEventProcess.h"
#import "H2iCareSensEventProcess.h"


#import "JJBayerContour.h"


#import "H2Config.h"
#import "H2Sync.h"
#import "H2SystemEventProcess.h"



@implementation H2SystemEventProcess

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}



+ (H2SystemEventProcess *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred = 0;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
    
}


@end


