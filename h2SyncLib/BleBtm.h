//
//  BleBtm.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/12/23.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>



#define  BTM_FIRST_SERVICE_ID                           @"FFF0"
#define  BTM_SECOND_SERVICE_ID                          @"FFF3"


#define  BTM_NOTIFY_ID                                  @"FFF1"
#define  BTM_WRITE_ID                                   @"FFF2"

#define  BTM_C_ID                                       @"FFF4"
#define  BTM_D_ID                                       @"FFF5"




#import <Foundation/Foundation.h>

#import "h2BrandModel.h"

@class H2BgRecord;

@interface BleBtm : NSObject


@property (readwrite) BOOL btmFinished;
@property (readwrite) BOOL btmRecordRunning;

@property (readwrite) UInt8 btmPreCmd;

@property (readwrite) UInt16 btmIndex;
@property (readwrite) UInt16 btmTotal;


@property (readwrite) Byte *btmSrcData;
@property (readwrite) UInt16 btmSrcLen;
@property (readwrite) UInt16 btmSrcPreLen;



@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *sn;

@property (nonatomic, strong) NSString *currentTime;
@property (readwrite) UInt16 number;
@property (nonatomic, strong) NSString *recordTime;
@property (nonatomic, strong) NSString *recordValue;

@property (nonatomic, strong) NSString *btmUnit;
//@property (readwrite) UInt8 btmBatterLevel;


// Customer
//@property (nonatomic, strong) CBUUID *h2BtmServiceID;
//@property (strong, readwrite) CBUUID *h2BtmCharacteristic_MeasurementID;

@property (nonatomic, strong) CBUUID *h2BtmFirstServiceID;
@property (nonatomic, strong) CBUUID *h2BtmSecondServiceID;

@property (nonatomic, strong) CBUUID *h2BtmCharacteristic_NotifyID;
@property (nonatomic, strong) CBUUID *h2BtmCharacteristic_WriteID;

//@property (strong, readwrite) CBUUID *h2BtmCharacteristic_AID;
//@property (strong, readwrite) CBUUID *h2BtmCharacteristic_BID;
@property (nonatomic, strong) CBUUID *h2BtmCharacteristic_CID;
@property (nonatomic, strong) CBUUID *h2BtmCharacteristic_DID;


// BTM Service
//@property (nonatomic, strong) CBService *h2_Btm_Service;
@property (nonatomic, strong) CBService *h2_Btm_FirstService;
@property (nonatomic, strong) CBService *h2_Btm_SecondService;

// BTM Characteristic
//@property (nonatomic, strong) CBCharacteristic *h2_Btm_CHAR_Measurement;

@property (nonatomic, strong) CBCharacteristic *h2_Btm_CHAR_Notify;
@property (nonatomic, strong) CBCharacteristic *h2_Btm_CHAR_Write;

//@property (nonatomic, strong) CBCharacteristic *h2_Btm_CHAR_A;
//@property (nonatomic, strong) CBCharacteristic *h2_Btm_CHAR_B;
@property (nonatomic, strong) CBCharacteristic *h2_Btm_CHAR_C;
@property (nonatomic, strong) CBCharacteristic *h2_Btm_CHAR_D;





+ (BleBtm *)sharedInstance;


- (void)BTMCommandGeneral;

- (void)h2BtmSubscribeTask;


- (void)h2BTMReportProcessTask;

- (void)h2BTMGetRecordInit;

- (BOOL)btmLinkParser;
- (NSString *)btmTimeAndUnitParser;
- (NSString *)btmSerialNumberParser;
- (BOOL)btmRecordTotalNumberParser;

- (H2BgRecord *)btmRecordParser;


@end


