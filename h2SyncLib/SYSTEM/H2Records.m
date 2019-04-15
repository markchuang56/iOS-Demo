//
//  H2Records.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/11.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2Records.h"

@implementation H2Records

- (id)init
{
    if (self = [super init]) {
        
        _dataTypeFilter = 0;
        _equipUserIdFilter = 0;
        _recordBgIndex = 0;
        _recordBpIndex = 0;
        
        _multiUsers = NO;
        
        _currentUser = 0;
        _bgSkipRecords = NO;
        _bgCableSyncFinished = NO;
        
        _bgUser1RecordsArray = [[NSMutableArray alloc] init];
        _bgUser2RecordsArray = [[NSMutableArray alloc] init];
        _bgUser3RecordsArray = [[NSMutableArray alloc] init];
        _bgUser4RecordsArray = [[NSMutableArray alloc] init];
        _bgUser5RecordsArray = [[NSMutableArray alloc] init];
        
        _bpUser1RecordsArray = [[NSMutableArray alloc] init];
        _bpUser2RecordsArray = [[NSMutableArray alloc] init];
        _bpUser3RecordsArray = [[NSMutableArray alloc] init];
        _bpUser4RecordsArray = [[NSMutableArray alloc] init];
        _bpUser5RecordsArray = [[NSMutableArray alloc] init];
        
        _bwUser1RecordsArray = [[NSMutableArray alloc] init];
        _bwUser2RecordsArray = [[NSMutableArray alloc] init];
        _bwUser3RecordsArray = [[NSMutableArray alloc] init];
        _bwUser4RecordsArray = [[NSMutableArray alloc] init];
        _bwUser5RecordsArray = [[NSMutableArray alloc] init];
        
        _bgRecordsArray = [[NSMutableArray alloc] init];
        _bpRecordsArray = [[NSMutableArray alloc] init];
        _bwRecordsArray = [[NSMutableArray alloc] init];
        
        _H2RecordsArray = [[NSMutableArray alloc] init];
        
        _bgTmpRecord = [[H2BgRecord alloc] init];
        _bpTmpRecord = [[H2BpRecord alloc] init];
        _bwTmpRecord = [[H2BwRecord alloc] init];
        
        _multiRecords = [[NSMutableArray alloc] init];
        
        
        // LAST DATE TIME ARRAY
        _bgLastDateTimeArray = [[NSMutableArray alloc] init];
        _bpLastDateTimeArray = [[NSMutableArray alloc] init];
        _bwLastDateTimeArray = [[NSMutableArray alloc] init];
        
        _totalLastDateTimeArray = [[NSMutableArray alloc] init];
        
        
    }
    
    return self;
}



- (void)resetRecordsArray
{
    // BG USER ARRAY
    if ([_bgUser1RecordsArray count] > 0) {
        [_bgUser1RecordsArray removeAllObjects];
    }
    if ([_bgUser2RecordsArray count] > 0) {
        [_bgUser2RecordsArray removeAllObjects];
    }
    if ([_bgUser3RecordsArray count] > 0) {
        [_bgUser3RecordsArray removeAllObjects];
    }
    if ([_bgUser4RecordsArray count] > 0) {
        [_bgUser4RecordsArray removeAllObjects];
    }
    if ([_bgUser5RecordsArray count] > 0) {
        [_bgUser5RecordsArray removeAllObjects];
    }
    
    // BP USER ARRAY
    if ([_bpUser1RecordsArray count] > 0) {
        [_bpUser1RecordsArray removeAllObjects];
    }
    if ([_bpUser2RecordsArray count] > 0) {
        [_bpUser2RecordsArray removeAllObjects];
    }
    if ([_bpUser3RecordsArray count] > 0) {
        [_bpUser3RecordsArray removeAllObjects];
    }
    if ([_bpUser4RecordsArray count] > 0) {
        [_bpUser4RecordsArray removeAllObjects];
    }
    if ([_bpUser5RecordsArray count] > 0) {
        [_bpUser5RecordsArray removeAllObjects];
    }
    
    
    // BW USER ARRAY
    if ([_bwUser1RecordsArray count] > 0) {
        [_bwUser1RecordsArray removeAllObjects];
    }
    if ([_bwUser2RecordsArray count] > 0) {
        [_bwUser2RecordsArray removeAllObjects];
    }
    if ([_bwUser3RecordsArray count] > 0) {
        [_bwUser3RecordsArray removeAllObjects];
    }
    if ([_bwUser4RecordsArray count] > 0) {
        [_bwUser4RecordsArray removeAllObjects];
    }
    if ([_bwUser5RecordsArray count] > 0) {
        [_bwUser5RecordsArray removeAllObjects];
    }
    
    
    
    // TYPE ARRAY
    if ([_bgRecordsArray count] > 0) {
        [_bgRecordsArray removeAllObjects];
    }
    if ([_bpRecordsArray count] > 0) {
        [_bpRecordsArray removeAllObjects];
    }
    if ([_bwRecordsArray count] > 0) {
        [_bwRecordsArray removeAllObjects];
    }
    
    if ([_H2RecordsArray count] > 0) {
        [_H2RecordsArray removeAllObjects];
    }
    
    
    [_bgRecordsArray addObject:_bgUser1RecordsArray];
    [_bgRecordsArray addObject:_bgUser2RecordsArray];
    [_bgRecordsArray addObject:_bgUser3RecordsArray];
    [_bgRecordsArray addObject:_bgUser4RecordsArray];
    [_bgRecordsArray addObject:_bgUser5RecordsArray];
    
    [_bpRecordsArray addObject:_bpUser1RecordsArray];
    [_bpRecordsArray addObject:_bpUser2RecordsArray];
    [_bpRecordsArray addObject:_bpUser3RecordsArray];
    [_bpRecordsArray addObject:_bpUser4RecordsArray];
    [_bpRecordsArray addObject:_bpUser5RecordsArray];
    
    [_bwRecordsArray addObject:_bwUser1RecordsArray];
    [_bwRecordsArray addObject:_bwUser2RecordsArray];
    [_bwRecordsArray addObject:_bwUser3RecordsArray];
    [_bwRecordsArray addObject:_bwUser4RecordsArray];
    [_bwRecordsArray addObject:_bwUser5RecordsArray];
    
    [_H2RecordsArray addObject:_bgRecordsArray];
    [_H2RecordsArray addObject:_bpRecordsArray];
    [_H2RecordsArray addObject:_bwRecordsArray];
}


- (void)buildRecordsArray:(id)record
{
#ifdef DEBUG_INDEX
    DLog(@"BUILD RECORD ARRAY NEW %02X", _currentDataType);
    DLog(@"HEM-9200T  RECORD");
#endif
    switch (_currentDataType) {
        case RECORD_TYPE_BG:
            [self buildBgRecordsArray:record];
            break;
            
        case RECORD_TYPE_BP:
            [self buildBpRecordsArray:_bpTmpRecord];
            break;
            
        case RECORD_TYPE_BW:
            [self buildBwRecordsArray:_bwTmpRecord];
            break;
            
        default:
#ifdef DEBUG_INDEX
            DLog(@"NEW - NO TYPE SEL");
#endif
            break;
    }
#ifdef DEBUG_INDEX
    DLog(@"RECORDS UPDATE \n%@", _H2RecordsArray);
#endif
}

- (void)buildBgRecordsArray:(id)record
{
#ifdef DEBUG_INDEX
    DLog(@"BUILD RECORD ARAAY - BG %02X, %@", _currentUser, record);
#endif
    switch (_currentUser) {
        case NX_TAG_1:
            [_bgUser1RecordsArray addObject:record];
            break;
            
        case NX_TAG_2:
            [_bgUser2RecordsArray addObject:record];
            break;
            
        case NX_TAG_3:
            [_bgUser3RecordsArray addObject:record];
            break;
            
        case NX_TAG_4:
            [_bgUser4RecordsArray addObject:record];
            break;
            
        case NX_TAG_5:
            [_bgUser5RecordsArray addObject:record];
            break;
            
        default:
#ifdef DEBUG_INDEX
            DLog(@"NEW - NO UID SEL");
#endif
            break;
    }
}

- (void)buildBpRecordsArray:(H2BpRecord *)record
{
#ifdef DEBUG_INDEX
    DLog(@"BUILD RECORD ARAAY - BP %02X, %@", _currentUser, record);
#endif
    switch (_currentUser) {
        case NX_TAG_1:
            [_bpUser1RecordsArray addObject:record];
            break;
            
        case NX_TAG_2:
            [_bpUser2RecordsArray addObject:record];
            break;
            
        case NX_TAG_3:
            [_bpUser3RecordsArray addObject:record];
            break;
            
        case NX_TAG_4:
            [_bpUser4RecordsArray addObject:record];
            break;
            
        case NX_TAG_5:
            [_bpUser5RecordsArray addObject:record];
            break;
            
        default:
            break;
    }
}

- (void)buildBwRecordsArray:(H2BwRecord *)record
{
#ifdef DEBUG_INDEX
    DLog(@"BUILD RECORD ARAAY - BW %02X, %@", _currentUser, record);
#endif
    switch (_currentUser) {
        case NX_TAG_1:
            [_bwUser1RecordsArray addObject:record];
            break;
            
        case NX_TAG_2:
            [_bwUser2RecordsArray addObject:record];
            break;
            
        case NX_TAG_3:
            [_bwUser3RecordsArray addObject:record];
            break;
            
        case NX_TAG_4:
            [_bwUser4RecordsArray addObject:record];
            break;
            
        case NX_TAG_5:
            [_bwUser5RecordsArray addObject:record];
            break;
            
        default:
            break;
    }
}





+ (H2Records *)sharedInstance
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





@implementation H2BgRecord

- (id)init
{
    if (self = [super init]) {
        _recordType = 1; // BG
        _bgIndex = 0;
        
        _bgDateTime = @"";
        _meterUserId = 0;
        
        // BG
        _bgValue_mg = 0;
        _bgValue_mmol = 0.0f;
        
        _bgValue = @"";
        
        _bgUnit = @"N";
        
        _bgComment = 0x0000;
        _bgMealFlag = @"N";
        
        _bgHasUnit = NO;
        
        _bgParserSuccessful = YES;
    }
    
    return self;
}

+ (H2BgRecord *)sharedInstance
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

@implementation H2BpRecord

- (id)init
{
    if (self = [super init]) {
        _recordType = 2; // BP
        _bpIndex = 0;
        
        _bpDateTime = @"";
        _meterUserId = 0;
        _bpUnit = @"mmHg";
        
        // BP
        _recordIsBp = NO;
        _bpIsArrhythmia = NO;
        _mamArrhythmia = NO;
        _bpIhbValue = 0;

        _bpSystolic = @"";
        _bpDiastolic = @"";
        _bpHeartRate_pulmin = @"";
    }
    
    
    return self;
}

+ (H2BpRecord *)sharedInstance
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

@implementation H2BwRecord

- (id)init
{
    if (self = [super init]) {
        _recordType = 4; // BW
        _bwIndex = 0;
        
        _bwDateTime = @"";
        _meterUserId = 0;
        _bwUnit = @"Kg";
        
        // BW
//        _bwDataWithUserId = 0;
        _bwGender = @"N"; //Gender. Female = 0, Male =1
        
        _bwHeightCm = @"0.00";
        _bwHeightInch = @"0.00";

        _bwAge = 0;
        //_bwUnit = 0; // Kg=0, lb=1, st=2
        
        _bwWeight = @"";
//        _bwLb = @"";
        _bwBmi = @"";
        
        _bwFat = @"0.00";
        _bwSkeletalMuscle = @"0.00";
        _bwRestingMetabolism = @"0.00";
        
        _bwLevel = @"0";
        
        //_bwIsSomeThing = NO;
        
    }
    return self;
}

+ (H2BwRecord *)sharedInstance
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

@implementation BatDynamicInfo

- (id)init
{
    if (self = [super init]) {
        _devType = 0;
        _batteryLevel = -1;
        _batteryRawData = 0;
        
        _cableVersion = @"";
        
        _serialNumber = @"";
        _model = @"";
        
        _bleIdentifier = @"";
        _bleLocalName = @"";
    }
    return self;
}

@end

@implementation RecordsSkipped : NSObject

- (id)init
{
    if (self = [super init]) {
        _bgSkip = 0;
        _bpSkip = 0;
        _bwSkip = 0;
    }
    return self;
}

/*
 + (RecordsSkipped *)sharedInstance
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
 */
@end


