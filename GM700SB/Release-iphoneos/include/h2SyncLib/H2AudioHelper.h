//
//  H2AudioHelper.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/9.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol H2AudioHelperDelegate <NSObject>

@optional

// Internal Debug
- (void)h2EngineerChecking:(NSMutableArray *)mutableArray;
- (void)h2EngineerSystemErr:(UInt16)numberOfErr;
- (void)h2EngineerBufferErr:(UInt16)numberOfErr;

@end

@interface H2AudioHelper : NSObject

@property (nonatomic, strong) NSObject<H2AudioHelperDelegate> *libAudioDelegate;
@property(nonatomic, readwrite) BOOL audioMode;

- (void)h2CableCycleTalk:(UInt32)number;

- (BOOL)start:(NSError **)error;
- (void)tmReadWriteH2SerialNumber:(unsigned char *)sn withLength:(UInt8)length reading:(BOOL)reading;
- (void)h2BleDebugScan:(BOOL)enableScan;
- (void)h2SyncDebugTask:(id)sender;

- (void)h2CableTotalRecord:(BOOL)getTotal;
- (void)h2AudioLongRunReport:(NSMutableArray *)dataGroup;

- (void)audioForSession;

+ (H2AudioHelper *)sharedInstance;

@end

// + [H2AudioHelper sharedInstance]

// 0 : audio
// 1 : ble cable sync
// 2 : ble Sync
// 3 : ble cable pairing
// 4 : ble pairing
// 5 : oad update

//#define H2_EQUIPID_ERR                  5
//#define H2_SN_LEN_ERR                   2

#define AUDIO_CABLE_SYNC            0
#define BLE_CABLE_SYNC              1
#define BLE_EQUIP_SYNC              2
#define BLE_CABLE_PAIRING           3
#define BLE_EQUIP_PAIRING           4
#define OAD_UPDATE                  5

#define BLE_DEL_RECORDS             6


@class UserGlobalProfile;

#pragma mark - SYNC PACKAGE

@interface H2PackageForSync : NSObject

// AUDIO_CABLE_SYNC            0
// BLE_CABLE_SYNC              1
// BLE_EQUIP_SYNC              2
// BLE_CABLE_PAIRING           3
// BLE_EQUIP_PAIRING           4
// OAD_UPDATE                  5
@property (readwrite) UInt8 interfaceTask;

// Record's Type
// 0x01 : bg,
// 0x02 : bp,
// 0x04 : bw
@property (readwrite) UInt8 recordTypeInMeter;

// Meter's User Tag
// 0x01 : user 1
// 0x02 : user 2
// 0x04 : user 3
// 0x08 : user 4
// 0x10 : user 5
@property (readwrite) UInt8 userTagInMeter;

// Meter Code (Meter ID)
@property (readwrite) UInt32 equipCode;


//@property (nonatomic, unsafe_unretained) NSString *serialNumber;
// 1. Use BLE Cable Serial Number (QR)for ble scanning
// 2. Use BLE Meter Serial Number for ble scanning
@property (nonatomic, strong) NSString *bleScanningKey;

// Last Date Date Array
// LDT, meter SN, Type, U_Tag ...
@property (nonatomic, strong) NSMutableArray *serverLastDateTimeArray;

// BLE Identifier,(BLE Cable and BLE Meter)
@property (nonatomic, strong) NSString *bleIdentifier;

// Birthday,
// Body Height in mm unit
// Gender : 1 -> Male, 0 -> Female
// User Tag : For Omron Pairing
@property (nonatomic, strong) UserGlobalProfile *userProfile;

// User ID From Register, for Debug
@property (nonatomic, strong) NSString *uIDStringFromRegister;

// User E-Mail From Register, for Debug
@property (nonatomic, strong) NSString *uEMailStringFromRegister;

@end

// DEFAULT
#define BIRTH_YEAR                  1980
#define BIRTH_MONTH                 1
#define BIRTH_DAY                   1

#define MALE                        1
#define FEMALE                      0

#define BODY_HEIGHT                 (160*10)

@interface UserGlobalProfile : NSObject

@property (readwrite) Byte *uBuffer;

@property (readwrite) UInt8 uTag;

@property (readwrite) UInt16 uBirthYear; // age + 1990, maybe not
@property (readwrite) UInt8 uBirthMonth;
@property (readwrite) UInt8 uBirthDay;

@property (readwrite) UInt8 uGender; // 1 : male, 0: Female
@property (readwrite) UInt16 uBodyHeight;// Unit : mm

@end

@interface TS_Sever : NSObject

@property (nonatomic, strong) NSMutableArray *tsServerLastDateTimes;
@property (readwrite) UInt8 tsServerMeterUserId;
@property (readwrite) UInt8 tsServerMeterDataType;
@property (readwrite) UInt32 tsServerMeterIdSel;

+ (TS_Sever *)sharedInstance;

@end

/*
@interface SMSyncStatus : NSObject

@property (assign, nonatomic) statusCode globalStatus;

+ (SMSyncStatus *)sharedInstance;

@end
*/
