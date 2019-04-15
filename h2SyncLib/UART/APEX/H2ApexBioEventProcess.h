//
//  H2SMApexBio.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/14.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//


#define BLE_EMBRACE_ENDING_INTERVAL                     4.0f


#define METER_EMBRACE_RESEND_INTERVAL                   8.0f

#define EMBRACE_SEED                                    150
#define OMNIS_RESEND_INTERVAL                           3.0f


//#define OMNIS_AUDIO_SW_ON_CMD_INTERVAL                  2.4f
#define OMNIS_AUDIO_SW_ON_CMD_INTERVAL                  3.2f


#import <Foundation/Foundation.h>

@interface H2ApexBioEventProcess : NSObject{
    
}

@property(nonatomic, strong) NSTimer *embraceEndingTimer;
@property(readwrite) BOOL EmbraceOverLoading;
@property(readwrite) BOOL EmbraceOverBleMode;
@property(readwrite) UInt8 skipEmbraceRecordOffset;

@property(readwrite) BOOL OmnisParserFlag;


- (void)ApexBioEventProcess;

+ (H2ApexBioEventProcess *)sharedInstance;

#pragma mark M_DCL -- OMNIS

- (void)H2SMApexBioOmnisGeneral;
- (void)H2SMApexBioOmnisCmdRecord;

- (void)H2SMApexBioOmnisCmdNumberOfRecord;
- (void)H2SMApexBioOmnisCmdNumberOfRecordAll;
- (void)H2SMApexBioOmnisCmdRecordAllTurnOn;
- (void)H2SMApexBioOmnisCmdRecordAllCoef;

@end

