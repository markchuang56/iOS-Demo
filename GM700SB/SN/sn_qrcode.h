//
//  sn_qrcode.h
//  APX
//
//  Created by h2Sync on 2016/4/25.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#define SN_MODEL_AT_0                   0
#define SN_TYPE_AT_1                    1

#define SN_YEAR_AT_2                    2
#define SN_MONTH_AT_3                   3

#define SN_CUSTOMER_AT_4                4
#define SN_CUSTOMEREX_AT_5              5

#define SN_NUMBER_AT_6                  6

#define SN_CRC_AT_9                     9

#import <Foundation/Foundation.h>

@interface SN_QRCode : NSObject


- (BOOL)snToQRCode;
+ (SN_QRCode *)sharedInstance;

@end


// [SN_QRCode sharedInstance] snToQRCode


@protocol H2SerialNumberDelegate <NSObject>

@required

@optional

@end






@interface H2SerialNumber : NSObject{
}

@property(nonatomic, strong) NSObject <H2SerialNumberDelegate> *serialNumberDelegate;

@property(nonatomic, readwrite) UniChar snModel;
@property(nonatomic, readwrite) UniChar snType;
@property(nonatomic, readwrite) UInt8 snYear;
@property(nonatomic, readwrite) UInt8 snMonth;
@property(nonatomic, readwrite) UniChar snCustomer;
@property(nonatomic, readwrite) UniChar snCustomerEx;

@property(nonatomic, readwrite) UInt32 snNumber;

@property(nonatomic, readwrite) UInt16 qrCycle;

@property(nonatomic, strong) NSString *stringBeScanned;


+ (H2SerialNumber *)sharedInstance;
- (void)haha;

@end
