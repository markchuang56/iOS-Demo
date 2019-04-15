//
//  H2BionimeEventProcess.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#import "Bionime.h"
#import "H2Config.h"
#import "H2BionimeEventProcess.h"


@interface H2BionimeEventProcess()
{
}
@end


@implementation H2BionimeEventProcess



- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}


+ (H2BionimeEventProcess *)sharedInstance
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

#pragma mark - DISPATCH BIONEME METER DATA

@end
