//
//  BWSViewController.m
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/11/30.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import "BWSViewController.h"

#import "Constants.h"
#import "CharacteristicReader.h"
#import "H2Records.h"
#import "h2DebugHeader.h"

@implementation BWSViewController

- (H2BwRecord *)BWSDidUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
#ifdef DEBUG_BP
    DLog(@"BLE BP - DECODE");
#endif
    H2BwRecord *recordTmp = [[H2BwRecord alloc] init];
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    // Decode the characteristic data
    NSData *data = characteristic.value;
    uint8_t *array = (uint8_t *) data.bytes;
    
    UInt8 flags = [CharacteristicReader readUInt8Value:&array];
    BOOL lb = (flags & 0x01) > 0;
    BOOL timestampPresent = (flags & 0x02) > 0;
    BOOL userIdPresent = (flags & 0x04) > 0;
    BOOL bmiPresent = (flags & 0x08) > 0;
#ifdef DEBUG_BP
    DLog(@"DID COME TO BPM - PARSER ...");
#endif
    
    UInt16 uc352Value = [CharacteristicReader readUInt16Value:&array];
    float tmpValue = 0.0f;
    // Update units
    if (lb)
    {
        _bwsUnit = BW_UNIT_LB;
        tmpValue = (float)uc352Value / 200 * 2.2046;
    }else{
        _bwsUnit = BW_UNIT;
        tmpValue = (float)uc352Value / 200;
    }
    
    _bwsValue = [NSString stringWithFormat:@"%.2f", tmpValue];
    recordTmp.bwWeight = _bwsValue;
    // Read timestamp
    if (timestampPresent)
    {
        NSDate* date = [CharacteristicReader readDateTime:&array];
        
        if (date == nil) {
#ifdef DEBUG_BP
            DLog(@"BP DATE is NIL");
#endif
            recordTmp.bwDateTime = @"";
        }else{
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            //[dateFormat setDateFormat:@"dd.MM.yyyy, hh:mm"];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
            NSString* dateFormattedString = [dateFormat stringFromDate:date];
            
            _timestamp = dateFormattedString;
            recordTmp.bwDateTime = [NSString stringWithFormat:@"%@ +0000", [_timestamp substringWithRange:NSMakeRange(0, 19)]];
        }
        
    }else{
        _timestamp = @"n/a";
        recordTmp.bwDateTime = _timestamp;
    }
    
    //if (uc352Value >= 0x7FF) {
    //    _timestamp = @"n/a";
    //    recordTmp.bwDateTime = _timestamp;
    //}
    
    // User Id
    
    if (userIdPresent)
    {
        DLog(@"BWS WITH USER ID");
    }
    
    
    if (bmiPresent) {
        DLog(@"BWS WITH BMI");
        // bwHeightCm, bwHeightInch, bwBmi
    }
    
    
#ifdef DEBUG_BP
    DLog(@"BWS = %@ %@", _bwsValue, _bwsUnit);

    DLog(@"BWS TIME - %@ ", _timestamp);
    DLog(@"Bws WEIGHT - %@", recordTmp.bwWeight);
#endif
    
    recordTmp.bwUnit = _bwsUnit;
    recordTmp.recordType = RECORD_TYPE_BW;
    
    return recordTmp;
}

+ (BWSViewController *)sharedInstance
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
