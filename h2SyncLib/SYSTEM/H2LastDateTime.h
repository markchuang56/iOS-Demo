//
//  H2LastDateTime.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/11.
//  Copyright © 2017年 h2Sync. All rights reserved.
//



@class H2BgRecord;
@class H2BpRecord;
@class H2BwRecord;

#define DEF_LAST_DATE_TIME      (@"1970-01-01 00:00:00 +0000")

#import <Foundation/Foundation.h>




#pragma mark - SERVER LAST DATE TIME

@interface H2SvrLastDateTime : NSObject

@property (nonatomic, retain) NSMutableArray *totalSvrLastDateTime;
@property (nonatomic, retain) NSMutableArray *totalSvrLdtIndex;

@property (readwrite) UInt16 indexFromServer;

- (void)h2InitTimeAndIndexFromServer;
- (void)h2UpdateLastTimeFromServer:(UInt8)dataType withUserId:(UInt8)uId withSvrLDT:(NSString *)lastDateTime;

//- (void)h2UpdateLdtIndexFromServer:(UInt8)dataType withUserId:(UInt8)uId withSvrIndex:(NSString *)ldtIndex;
- (void)h2UpdateLdtIndexFromServer:(UInt8)dataType withUserId:(UInt8)uId withSvrIndex:(NSNumber *)ldtIndex;

- (NSString *)h2GetCurrentSvrLastTime:(UInt8)dataType withUserId:(UInt8)uId;


+ (H2SvrLastDateTime *)sharedInstance;
@end




