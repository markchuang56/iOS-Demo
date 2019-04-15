//
//  Fora.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/12/9.
//  Copyright © 2015年 h2Sync. All rights reserved.
//




// FORA UUID Base: 1212-efde-1523-785feabcd123
// FORA Service UUID: 0x1523
// FORA Characteristic: 0x1524 (write/notify)

#define FORA_METER_SERVICE_UUID                     @"00001523-1212-EFDE-1523-785FEABCD123"
#define FORA_METER_CHARACTERISTIC_UUID              @"00001524-1212-EFDE-1523-785FEABCD123"
// Service //00001523-1212-EFDE-1523-785FEABCD123>

#define FORA_BP_MASK                                0x02000000
#define FORA_BW_MASK                                0x04000000

#define FORA_D40_MAX_ID                             4
#define FORA_W310B_MAX_ID                            5

#define ID_OFFSET                                   2

#define FORA_CMD_LENGTH                                 8
#define THERMAL_CMD_LENGTH                              7
#define W310_CMD_LEN                                    2
#define FORA_REPORT_LENGTH                              8

#define CMD_AT                              1

#define DATA_0                              2
#define DATA_1                              3
#define DATA_2                              4
#define DATA_3                              5

#define DATA_D40_ID_AT                              5
#define D40_MAX_USER_ID                             4

#define STOP                                        6
#define ACK_OFFSET                                        2

#define D40_BP_MASK                                     0x80
#define D40_BP_ARRHY_MASK                               0x40

#define D40_BP_AVG_MASK                                 0x80
#define D40_BP_IHB_MASK                                 0x60


#define BLE_AUTO_MODE_RESTART_INTERVAL                                    5.0f

#define FORA_CMD_HEADER                                 0x51
#define FORA_CMD_STOP                                   0xA3
#define FORA_REPORT_STOP                                0xA5

#define FORA_CMD_READ_CURRENT_TIME                  0x23
#define FORA_CMD_READ_MODEL                         0x24
#define FORA_CMD_RECORD_TIME                        0x25
#define FORA_CMD_RECORD_VALUE                       0x26
#define FORA_CMD_SN_LATER                            0x27
#define FORA_CMD_SN_FORMER                            0x28
#define FORA_CMD_FORA_CMD_NUMBER_OF_RECORD          0x2B
#define FORA_CMD_TURN_OFF                           0x50

#define FORA_CMD_THERMO                            0x71
#define FORA_CMD_PROFILE                            0x72

#define FORA_PROFILE_LEN                            7

#define FORA_CMD_WRITE_CURRENT_TIME                 0x33
#define FORA_CMD_DELETE_ALL                         0x52


#define FORA_MASK_YEAR                               0xFE
#define FORA_MASK_MONTH_HI                           0x01
#define FORA_MASK_MONTH_LO                           0xE0
#define FORA_MASK_DAY                                0x1F

#define FORA_MASK_HOUR                               0x1F
#define FORA_MASK_MIN                                0x3F


#define MASK_CLUCOSE_TYPE                           0xC0
#define MASK_CODE_HI                                0x03

#define TYPE_GEN                                    0
#define TYPE_AC_BEFORE                              1
#define TYPE_PC_AFTER                               2
#define TYPE_QC_CTRL                                3


#define W310B_DATA_LEN                              34

#define FORA_ALL_USER_ID                            0

#define FORA_EQUIP_ACK                              0xA5


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "h2BrandModel.h"



@interface Fora : NSObject

@property (readwrite) UInt8 foraAppUserId;
@property (readwrite) UInt8 foraAppDataType;

@property (readwrite) BOOL foraFinished;
@property (readwrite) BOOL zeroRecord;
@property (readwrite) BOOL syncStart;

@property (readwrite) UInt8 curCommand;
@property (readwrite) Byte *foraCmdBuffer;

@property (readwrite) UInt8 foraCmdMethod;
@property (readwrite) UInt8 foraCmdNext;

//@property (readwrite) UInt8 lenMinus;


@property (readwrite) UInt16 cmdIndex;
@property (readwrite) UInt16 recordTotal;

@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *sn;

@property (nonatomic, strong) NSString *currentTime;
@property (readwrite) UInt16 number;
@property (nonatomic, strong) NSString *recordTime;
@property (nonatomic, strong) NSString *recordValue;

// Customer
@property (nonatomic, strong) CBUUID *h2ForaServiceUUID;
@property (nonatomic, strong) CBUUID *h2ForaCharacteristic_WriteNotifyUUID;


// FORA Service
@property (nonatomic, strong) CBService *h2_FORA_Service;

// FORA Characteristic
@property (nonatomic, strong) CBCharacteristic *h2_FORA_CHAR_WriteNotify;


@property (nonatomic, strong) NSMutableData *foraData;



+ (Fora *)sharedInstance;

- (void)h2FORAInitTask;
- (void)FORABleGetRecord;

- (const void *)addressOfCmdIndex;
- (void)h2ForaBLEWriteTask:(unsigned char *)hmdCmdData withLength:(UInt8)length;
//- (BOOL)h2ForaW310BRecordProcess;

/*
- (NSString *)modelParser;
- (NSString *)versionParser;
- (NSString *)snParser;
- (UInt16)numberParser;
*/
- (id)recordValueParserNEW;

- (void)h2ForaCmdProcess;
- (void)h2FORA_DataProcessTask:(CBCharacteristic *)characteristic;
- (void)h2ForaDataProcess;

@end







