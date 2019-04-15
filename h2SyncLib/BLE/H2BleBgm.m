//
//  H2BleGgm.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/9/25.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


#import "H2BleEquipId.h"
#import "H2BleProfile.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"



// SYSTEM
#import "h2DebugHeader.h"
#import "H2DataFlow.h"

#import "H2AudioFacade.h"

#import "H2Config.h"
#import "CharacteristicReader.h"

#import "ApexGlucoseReading.h"
#import "RecordAccess.h"

#import "RecordAccess.h"
#import "H2Records.h"

#import "H2LastDateTime.h"

#import "H2BleBgm.h"

@implementation H2BleBgm






- (id)init
{
    if (self = [super init]) {
        _recordIndex = 0;
        _recordTotal = 0;
        
        _command = 0;
        
        _willFinished = NO;
        
        _readingIndex = 0;
        
        _model = @"";
        _version = @"";
        _sn = @"";
        
        _currentTime = @"";
        _number = 0;
        _recordTime = @"";
        _recordValue = @"";
        
        _apexDebug = 0;
        
    }
    return self;
}

#pragma mark - BGM WRITE TASK
- (void)h2BleBgmWriteTask:(NSInteger)commandIndex
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Cancel button pressed?
    if (commandIndex == ACTION_CANCEL)
        return;
    _command = commandIndex;
    RecordAccessParam param;
    NSInteger size = 0;
    //    BOOL clearList = YES;
    switch (commandIndex)
    {
            /*
             case ACTION_REFRESH:
             {
             if ([readings count] > 0)
             {
             param.opCode = REPORT_STORED_RECORDS;
             param.operatorType = GREATER_THAN_OR_EQUAL;
             param.value.singleParam.filterType = SEQUENCE_NUMBER;
             GlucoseReading* reading = [readings objectAtIndex:([readings count] - 1)];
             param.value.singleParam.paramLE = CFSwapInt16HostToLittle(reading.sequenceNumber);
             size = 5;
             clearList = NO;
             break;
             } // else, obtain all records
             }
             */
        case ACTION_ALL_RECORDS:
        {
#ifdef DEBUG_TRUE_METRIX
            DLog(@"H2_DEBUG SW %02X", ACTION_ALL_RECORDS);
#endif
            _willFinished = YES;
            param.opCode = REPORT_STORED_RECORDS;
            param.operatorType = ALL_RECORDS;
            size = 2;
#ifdef DEBUG_TRUE_METRIX
            DLog(@"H2_DEBUG OP %02X, %02X", param.opCode, param.operatorType);
#endif
            break;
        }
        case ACTION_FIRST_RECORD:
        {
            param.opCode = REPORT_STORED_RECORDS;
            param.operatorType = FIRST_RECORD;
            size = 2;
            break;
        }
        case ACTION_LAST_RECORD:
        {
            param.opCode = REPORT_STORED_RECORDS;
            param.operatorType = LAST_RECORD;
            size = 2;
            break;
        }
        case ACTION_CLEAR:
        default:
        {
            // do nothing
            break;
        }
        case ACTION_DELETE_ALL:
        {
            param.opCode = DELETE_STORED_RECORDS;
            param.operatorType = ALL_RECORDS;
            size = 2;
            break;
        }
        case ACTION_NUMBER_OF_RECORDS:
            param.opCode = REPORT_NUMBER_OF_STORED_RECORDS;
            param.operatorType = ALL_RECORDS;
            size = 2;
            break;
            
        case ACTION_GREATER_THAN:
            param.opCode = REPORT_STORED_RECORDS;
            _willFinished = YES;
            
#if 1
#ifdef DEBUG_LIB
            DLog(@"BLE BGM GREAT THAN ... %d", [H2SvrLastDateTime sharedInstance].indexFromServer);
#endif
            param.operatorType = GREATER_THAN_OR_EQUAL;
            param.value.singleParam.filterType = SEQUENCE_NUMBER; // SEQUENCE_NUMBER
            
            if([H2SvrLastDateTime sharedInstance].indexFromServer == 0){
                switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                    case SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE:
                    case SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE:
                        break;
                        
                    default:
                        [H2SvrLastDateTime sharedInstance].indexFromServer = 1;
                        break;
                }
            }
#ifdef DEBUG_LIB
            DLog(@"ASCENSIA IDX = %d", [H2SvrLastDateTime sharedInstance].indexFromServer);
#endif
            if ([H2DataFlow sharedDataFlowInstance].equipId == SM_BLE_BGM_TYSON_HT100) {
                if ([H2SvrLastDateTime sharedInstance].indexFromServer >= AMOUNT_TOTAL_TYSON) { // MAX INDEX
                    _willFinished = NO;
                    [H2SvrLastDateTime sharedInstance].indexFromServer -= AMOUNT_PER_SEGMENT;
                }
            }
            
            param.value.singleParam.paramLE = [H2SvrLastDateTime sharedInstance].indexFromServer;
            size = 5;
#else
            param.operatorType = WITHIN_RANGE_INCLUSIVE;
            param.value.doubleParam.filterType = SEQUENCE_NUMBER; // USER_FACING_TIME
            param.value.doubleParam.paramFromLE = 2;
            param.value.doubleParam.paramToLE = 7;
            size = 7;
#endif
            break;
            
        case ACTION_LESS_THAN:
            break;
    }
    
    
    if (size > 0)
    {
        NSData* dataToWrite = [NSData dataWithBytes:&param length:size];
        
#ifdef DEBUG_TRUE_METRIX
        DLog(@"BLE BGM CMD %d and %@", (int)commandIndex, dataToWrite);
#endif
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:[H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_RecordAccessControlPoint type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - COMMAND CYCLE FOR TYSON HT100
- (void)bleBgmLoopCmdForTysonHT100
{
    [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(bleBgmLoopCmdForTysonHT100Timer) userInfo:nil repeats:NO];
}
- (void)bleBgmLoopCmdForTysonHT100Timer
{
    RecordAccessParam param;
    NSInteger size = 0;
    
    param.opCode = REPORT_STORED_RECORDS;
    
#ifdef DEBUG_LIB
    DLog(@"HT100 BLE BGM GREAT THAN ... %d", [H2SvrLastDateTime sharedInstance].indexFromServer);
#endif
    param.operatorType = GREATER_THAN_OR_EQUAL;
    param.value.singleParam.filterType = SEQUENCE_NUMBER; // SEQUENCE_NUMBER
    
    //if (_cmdSegmentForTyson >= CMD_SEGMENT_MAX) {
    if( [H2SvrLastDateTime sharedInstance].indexFromServer > AMOUNT_PER_SEGMENT){
        [H2SvrLastDateTime sharedInstance].indexFromServer -= AMOUNT_PER_SEGMENT;
    }else{
        [H2SvrLastDateTime sharedInstance].indexFromServer = 1;
        _willFinished = YES;
    }
    
    param.value.singleParam.paramLE = [H2SvrLastDateTime sharedInstance].indexFromServer;
    size = 5;

    if (size > 0)
    {
        NSData* dataToWrite = [NSData dataWithBytes:&param length:size];
    
#ifdef DEBUG_TRUE_METRIX
        DLog(@"TYSON INDEX = %d, BGM CMD  and %@", (int)[H2SvrLastDateTime sharedInstance].indexFromServer, dataToWrite);
#endif
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:[H2BleProfile sharedBleProfileInstance].h2_BleBgm_CHAR_RecordAccessControlPoint type:CBCharacteristicWriteWithResponse];
    }
}

- (void)h2BleBgmReportProcessTask:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_APEXBIO
    DLog(@"APEX BIO PROCESS ...");
#endif
    // Decode the characteristic data
    NSData *data = characteristic.value;
    uint8_t *array = (uint8_t *) data.bytes;
#ifdef DEBUG_APEXBIO
    DLog(@"H2_DEBUG UPDATE CHAR %@", characteristic);
    DLog(@"H2_DEBUG UPDATE VALUE %@", characteristic.value);
#endif
    H2BgRecord *bleBgmRecord;
    bleBgmRecord = [[H2BgRecord alloc] init];
    
    if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].bleBgmCharacteristic_MeasurementID])
    {
        [H2BleService sharedInstance].skipRecord = NO;
        ApexGlucoseReading *reading = [ApexGlucoseReading readingFromBytes:array];
#ifdef DEBUG_APEXBIO
        DLog(@"THE READING IS %d, %@", _readingIndex, reading);
        DLog(@"THE BGM INDEX %d, %04X", reading.sequenceNumber, reading.sequenceNumber);
#endif
        
        bleBgmRecord.bgDateTime = reading.timestampString;
        bleBgmRecord.bgValue_mmol = 0.0f;
        bleBgmRecord.bgMealFlag = reading.glucoseFlag;
        
        _skipContext = YES;
        if (reading.glucoseContextInformationFollows) {
            _skipContext = NO;
        }
        
        if (reading.unit > 0) {
            bleBgmRecord.bgUnit = BG_UNIT_EX;
            bleBgmRecord.bgValue_mmol = reading.glucoseValue_MMOL;
        }else{
            bleBgmRecord.bgUnit = BG_UNIT;
            bleBgmRecord.bgValue_mg = reading.glucoseValue_MG;
        }
        
        if (![bleBgmRecord.bgMealFlag isEqualToString:@"C"]) {
            [H2Records sharedInstance].bgTmpRecord = bleBgmRecord;
            if([[H2SyncReport sharedInstance] h2SyncBgDidGreateThanLastDateTime]){
                if ([[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:bleBgmRecord.bgDateTime]) {
                    [H2BleService sharedInstance].skipRecord = YES;
#ifdef DEBUG_LIB
                    DLog(@"METER TIME ERR - DO NOTHING.");
#endif
                }else{
                    [H2SyncReport sharedInstance].bgLdtIndex = reading.sequenceNumber;
                    if (!reading.glucoseContextInformationFollows && _willFinished) {
                        [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
                        [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
                        [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bgTmpRecord];
                    }
                }
            }else{
                if (!_willFinished) { // HT100 ONLY
                    _willFinished = YES;
                    DLog(@"TYSON DEBUG - WILL FINISHED");
                }
                // skip
                [H2BleService sharedInstance].skipRecord = YES;
                _skipContext = YES;
            }
        }else{
            _skipContext = YES;
        }
        
#ifdef DEBUG_APEXBIO
        DLog(@"ABIO - RECORD - %@", bleBgmRecord.bgDateTime);
        DLog(@"ABIO - RECORD - %d", bleBgmRecord.bgValue_mg);
        DLog(@"ABIO - RECORD - %f", bleBgmRecord.bgValue_mmol);
        DLog(@"ABIO - INDEX - %d", [H2SyncReport sharedInstance].h2BgRecordReportIndex);
        DLog(@"THE INDEX IS %d, %d", _readingIndex, reading.sequenceNumber);
        DLog(@"THE TimeStamp IS %d, %@", _readingIndex, reading.timestamp);
        DLog(@"THE TimeOffset IS %d, %d", _readingIndex, reading.timeOffset);
        
        
        DLog(@"THE Value IS %d, %f", _readingIndex, reading.glucoseConcentration);
        
        DLog(@"THE Unit IS %d, %d", _readingIndex, reading.unit);
        DLog(@"THE Type IS %d, %d", _readingIndex, reading.type);
        DLog(@"THE Location IS %d, %d", _readingIndex, reading.location);
        
        DLog(@"THE Status IS %d, %d", _readingIndex, reading.sensorStatusAnnunciation);
#endif
        //        @property (assign, nonatomic) UInt16 ;
        //        @property (strong, nonatomic) NSDate* ;
        //        @property (assign, nonatomic) SInt16 ;
        //        @property (assign, nonatomic) BOOL glucoseConcentrationTypeAndLocationPresent;
        //        @property (assign, nonatomic) Float32 ;
        //        @property (assign, nonatomic) BgmUnit ;
        //        @property (assign, nonatomic) BgmType ;
        //        @property (assign, nonatomic) BgmLocation ;
        //        @property (assign, nonatomic) BOOL sensorStatusAnnunciationPresent;
        //        @property (assign, nonatomic) UInt16 ;
    }else if ([characteristic.UUID isEqual:[H2BleProfile sharedBleProfileInstance].h2BgmCharacteristic_ContextID]){
        
        if (_skipContext) {
#ifdef DEBUG_LIB
            DLog(@"DID SKIP  CONTEXT - TYSON");
#endif
            return;
        }
        //uint8_t test[] = { 0x5F, 0x00, 0x00, 0x02, 0x01, 0xF0, 0x03, 0x13, 0xF2, 0x00, 0x22, 0x03, 0x03, 0xF0, 0x01, 0xE0 };// test data
        GlucoseReadingContext* context = [GlucoseReadingContext readingContextFromBytes:array];
        
#ifdef DEBUG_APEXBIO
        DLog(@"COME TO -- CONTEXT ...");
#endif
        if (context.mealPresent)
        {
            //context.meal ;
            switch (context.meal) {
                case 1:
                    [H2Records sharedInstance].bgTmpRecord.bgMealFlag = @"B"; // Preprandial (before meal)
                    break;
                    
                case 2:
                    [H2Records sharedInstance].bgTmpRecord.bgMealFlag = @"A"; // Postprandial (after meal)
                    break;
                    
                case 3:
                    [H2Records sharedInstance].bgTmpRecord.bgMealFlag = @"Fasting"; // Fasting
                    break;
                    
                case 4:
                    [H2Records sharedInstance].bgTmpRecord.bgMealFlag = @"Snacks"; // Casual (snacks, drinks, etc.)
                    break;
                    
                case 5:
                    [H2Records sharedInstance].bgTmpRecord.bgMealFlag = @"Bedtime"; // Bedtime
                    break;
                    
                default:
                    [H2Records sharedInstance].bgTmpRecord.bgMealFlag = @"N";
                    break;
/*
                    1	Preprandial (before meal)
                    2	Postprandial (after meal)
                    3	Fasting
                    4	Casual (snacks, drinks, etc.)
                    5	Bedtime
*/
            }
        }
        if (![H2BleService sharedInstance].skipRecord && _willFinished) {
            [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
            [H2Records sharedInstance].currentDataType = RECORD_TYPE_BG;
            [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bgTmpRecord];
        }
    }
}



+ (H2BleBgm *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_APEXBIO
    DLog(@"BLE BGM INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

@end
