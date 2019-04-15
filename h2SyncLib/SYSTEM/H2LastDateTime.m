//
//  H2Records.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/11.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2LastDateTime.h"
#import "H2Records.h"
#import "H2DebugHeader.h"


#pragma mark - SERVER LAST DATE TIME


@interface H2SvrLastDateTime()
{
    NSMutableArray *bgSvrLastDateTime;
    NSMutableArray *bpSvrLastDateTime;
    NSMutableArray *bwSvrLastDateTime;
    
    NSMutableArray *bgSvrLdtIndex;
    NSMutableArray *bpSvrLdtIndex;
    NSMutableArray *bwSvrLdtIndex;
}

@end



@implementation H2SvrLastDateTime
- (id)init
{
    if (self = [super init]) {
        bgSvrLastDateTime = [[NSMutableArray alloc] init];
        bpSvrLastDateTime = [[NSMutableArray alloc] init];
        bwSvrLastDateTime = [[NSMutableArray alloc] init];
        
        
        bgSvrLdtIndex = [[NSMutableArray alloc] init];
        bpSvrLdtIndex = [[NSMutableArray alloc] init];
        bwSvrLdtIndex = [[NSMutableArray alloc] init];
        
        _totalSvrLastDateTime = [[NSMutableArray alloc] init];
        
        _totalSvrLdtIndex = [[NSMutableArray alloc] init];
    }
    return self;
}



- (void)h2InitTimeAndIndexFromServer
{
    DLog(@"RESET LDT FROM SERVER ....");
    // CLEAN
    if ([bgSvrLastDateTime count] > 0) {
        [bgSvrLastDateTime removeAllObjects];
    }
    if ([bpSvrLastDateTime count] > 0) {
        [bpSvrLastDateTime removeAllObjects];
    }
    if ([bwSvrLastDateTime count] > 0) {
        [bwSvrLastDateTime removeAllObjects];
    }
    if ([_totalSvrLastDateTime count] > 0) {
        [_totalSvrLastDateTime removeAllObjects];
    }
    // RESET
    
    for (int i=0; i<5; i++) {
        [bgSvrLastDateTime addObject:DEF_LAST_DATE_TIME];
        [bpSvrLastDateTime addObject:DEF_LAST_DATE_TIME];
        [bwSvrLastDateTime addObject:DEF_LAST_DATE_TIME];
    }
    [_totalSvrLastDateTime addObject:bgSvrLastDateTime];
    [_totalSvrLastDateTime addObject:bpSvrLastDateTime];
    [_totalSvrLastDateTime addObject:bwSvrLastDateTime];

#ifdef DEBUG_LDT
    DLog(@"RESET SVR LAST = %@", _totalSvrLastDateTime);
#endif
    
    
    
    // CLEAN
    if ([bgSvrLdtIndex count] > 0) {
        [bgSvrLdtIndex removeAllObjects];
    }
    if ([bpSvrLdtIndex count] > 0) {
        [bpSvrLdtIndex removeAllObjects];
    }
    if ([bwSvrLdtIndex count] > 0) {
        [bwSvrLdtIndex removeAllObjects];
    }
    if ([_totalSvrLdtIndex count] > 0) {
        [_totalSvrLdtIndex removeAllObjects];
    }
    
    // RESET
    NSNumber *nrIndexInit = [NSNumber numberWithInt:0];
    for (int i=0; i<5; i++) {
        [bgSvrLdtIndex addObject:nrIndexInit]; //@"0"];
        [bpSvrLdtIndex addObject:nrIndexInit]; //@"0"];
        [bwSvrLdtIndex addObject:nrIndexInit]; //@"0"];
    }
    
    [_totalSvrLdtIndex addObject:bgSvrLdtIndex];
    [_totalSvrLdtIndex addObject:bpSvrLdtIndex];
    [_totalSvrLdtIndex addObject:bwSvrLdtIndex];
#ifdef DEBUG_LDT
    DLog(@"RESET SVR INDEX = %@", _totalSvrLdtIndex);
#endif
}

#pragma mark - UPDATE SERVER LAST DATE TIME
- (void)h2UpdateLastTimeFromServer:(UInt8)dataType withUserId:(UInt8)uId withSvrLDT:(NSString *)lastDateTime
{
    switch (1 << dataType) {
        case RECORD_TYPE_BG:
            [self updateSvrBgLastTime:uId withSvrLDT:lastDateTime];
            break;
            
        case RECORD_TYPE_BP:
            [self updateSvrBpLastTime:uId withSvrLDT:lastDateTime];
            break;
            
        case RECORD_TYPE_BW:
            [self updateSvrBwLastTime:uId withSvrLDT:lastDateTime];
            break;
            
        default:
            break;
    }
#ifdef DEBUG_LDT
    DLog(@"LDT - UPDATE SVR TYPE = %02X", dataType);
    DLog(@"LDT - UPDATE SVR UID = %02X@", uId);
    DLog(@"UPDATE SVR LDT = %@", _totalSvrLastDateTime);
#endif
}

- (void)updateSvrBgLastTime:(UInt8)uId withSvrLDT:(NSString *)lastDateTime
{
    [bgSvrLastDateTime replaceObjectAtIndex:uId withObject:lastDateTime];
}

- (void)updateSvrBpLastTime:(UInt8)uId withSvrLDT:(NSString *)lastDateTime
{
    [bpSvrLastDateTime replaceObjectAtIndex:uId withObject:lastDateTime];
}

- (void)updateSvrBwLastTime:(UInt8)uId withSvrLDT:(NSString *)lastDateTime
{
    [bwSvrLastDateTime replaceObjectAtIndex:uId withObject:lastDateTime];
}

#pragma mark - LAST INDEX OF RECORD
- (void)h2UpdateLdtIndexFromServer:(UInt8)dataType withUserId:(UInt8)uId withSvrIndex:(NSNumber *)ldtIndex
{
    switch (1 << dataType) {
        case RECORD_TYPE_BG:
            [self bgSvrIndexUpdate:uId withSvrIndx:ldtIndex];
            break;
            
        case RECORD_TYPE_BP:
            [self bpSvrIndexUpdate:uId withSvrIndx:ldtIndex];
            break;
            
        case RECORD_TYPE_BW:
            [self bwSvrIndexUpdate:uId withSvrIndx:ldtIndex];
            break;
            
        default:
            break;
    }
#ifdef DEBUG_LDT
    DLog(@"IDX - UPDATE SVR TYPE = %02X", dataType);
    DLog(@"IDX - UPDATE SVR UID = %02X", uId);
    DLog(@"UPDATE SVR L-INDEX = %@", _totalSvrLdtIndex);
#endif
}

- (void)bgSvrIndexUpdate:(UInt8)uId withSvrIndx:(NSNumber *)ldtIndx
{
    [bgSvrLdtIndex replaceObjectAtIndex:uId withObject:ldtIndx];
}

- (void)bpSvrIndexUpdate:(UInt8)uId withSvrIndx:(NSNumber *)ldtIndx
{
    [bpSvrLdtIndex replaceObjectAtIndex:uId withObject:ldtIndx];
}

- (void)bwSvrIndexUpdate:(UInt8)uId withSvrIndx:(NSNumber *)ldtIndx
{
    [bwSvrLdtIndex replaceObjectAtIndex:uId withObject:ldtIndx];
}







- (NSString *)h2GetCurrentSvrLastTime:(UInt8)dataType withUserId:(UInt8)uId
{
#ifdef DEBUG_LDT
    DLog(@"============== GET SVR LAST DATE TIME & INDEX ==================");
    DLog(@"SVR D-TYPE %02X", dataType);
    DLog(@"SVR UID %02X", uId);
    DLog(@"SVR TOTAL %@", _totalSvrLastDateTime);
#endif
    NSString *currentSvrLDT;
    NSArray *svrLdtArray;
    
    //NSString *stringIndex;
    NSNumber *stringIndex;
    NSArray *svrIndexArray;
    
    for (int i=0; i<3; i++) {
        if (dataType & (1 << i)) {
            svrLdtArray = [_totalSvrLastDateTime objectAtIndex:i];
            svrIndexArray = [_totalSvrLdtIndex objectAtIndex:i];
#ifdef DEBUG_LDT
            DLog(@" %d, TYPE ARRAY %@", i, svrLdtArray);
#endif
            for (int k=0; k<5; k++) {
                if (uId & (1 << k)) {
                    currentSvrLDT = [svrLdtArray objectAtIndex:k];
                    stringIndex = [svrIndexArray objectAtIndex:k];
#ifdef DEBUG_LDT
                    DLog(@" %d, dateTIME %@", i, currentSvrLDT);
#endif
                    break;
                }
            }
        }
    }
#ifdef DEBUG_LDT
    DLog(@"GET SVR LDT %02X, %@", uId, currentSvrLDT);
#endif
    _indexFromServer = [stringIndex intValue];
/*
    if ([stringIndex isEqualToString:@""]) {
        _indexFromServer = 0;
    }else{
        _indexFromServer = [stringIndex intValue];
    }
*/
#ifdef DEBUG_LDT
    DLog(@"GET SVR IDX = %04X", _indexFromServer);
#endif
    return currentSvrLDT;
}


+ (H2SvrLastDateTime *)sharedInstance
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




//- (void)h2UpdateLdtIndexFromServer:(UInt8)dataType withUserId:(UInt8)uId withSvrIndex:(NSString *)ldtIndex
/*
 {
 switch (1 << dataType) {
 case RECORD_TYPE_BG:
 [self bgSvrIndexUpdate:uId withSvrIndx:ldtIndex];
 break;
 
 case RECORD_TYPE_BP:
 [self bpSvrIndexUpdate:uId withSvrIndx:ldtIndex];
 break;
 
 case RECORD_TYPE_BW:
 [self bwSvrIndexUpdate:uId withSvrIndx:ldtIndex];
 break;
 
 default:
 break;
 }
 #ifdef DEBUG_LDT
 DLog(@"IDX - UPDATE SVR TYPE = %02X", dataType);
 DLog(@"IDX - UPDATE SVR UID = %02X", uId);
 DLog(@"UPDATE SVR L-INDEX = %@", _totalSvrLdtIndex);
 #endif
 }
 
 - (void)bgSvrIndexUpdate:(UInt8)uId withSvrIndx:(NSString *)ldtIndx
 {
 [bgSvrLdtIndex replaceObjectAtIndex:uId withObject:ldtIndx];
 }
 
 - (void)bpSvrIndexUpdate:(UInt8)uId withSvrIndx:(NSString *)ldtIndx
 {
 [bpSvrLdtIndex replaceObjectAtIndex:uId withObject:ldtIndx];
 }
 
 - (void)bwSvrIndexUpdate:(UInt8)uId withSvrIndx:(NSString *)ldtIndx
 {
 [bwSvrLdtIndex replaceObjectAtIndex:uId withObject:ldtIndx];
 }
 */

/*
 - (UInt16)h2GetCurrentSvrLdtIndex:(UInt8)dataType withUserId:(UInt8)uId
 {
 DLog(@"============== GET SVR INDEX OF RECORD ==================");
 DLog(@"SVR D-TYPE %02X", dataType);
 DLog(@"SVR UID %02X", uId);
 DLog(@"SVR TOTAL %@", _totalSvrLdtIndex);
 UInt16 ldtIndex = 0;
 NSString *stringIndex;
 NSArray *svrIndexArray;
 for (int i=0; i<3; i++) {
 if (dataType & (1 << i)) {
 svrIndexArray = [_totalSvrLdtIndex objectAtIndex:i];
 DLog(@" %d, TYPE ARRAY %@", i, svrIndexArray);
 for (int k=0; k<5; k++) {
 if (uId & (1 << k)) {
 stringIndex = [svrIndexArray objectAtIndex:k];
 DLog(@" %d, STRING INDEX =  %@", i, stringIndex);
 break;
 }
 }
 }
 }
 ldtIndex = [stringIndex intValue];
 DLog(@"GET SVR INDEX %02X, %d", uId, ldtIndex);
 return  ldtIndex;
 }
 */



