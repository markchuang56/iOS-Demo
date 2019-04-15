//
//  AKRAY_GT-1830.h
//  h2LibAPX
//
//  Created by h2Sync on 2017/3/1.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


/****************************************************************
 * Arkray Glucocard G-BLACK SM UUID
 *
 ****************************************************************/

// G BLACK SERVICE
// UUID = 040F9E5C-A38E-4F10-B44C-71C3E8B5477B>
//#define ARK_GBLACK_SERVICE_UUID                        @"040F9E5C-A38E-4F10-B44C-71C3E8B5477B" //
/*
 Advertisement DATA is  {
 kCBAdvDataIsConnectable = 1;
 kCBAdvDataLocalName = "GT-1830";
 kCBAdvDataServiceUUIDs =     (
 "040F9E5C-A38E-4F10-B44C-71C3E8B5477B"
 );
 }
 */


/*
 BLEsmart_000001190F061681D701, state = disconnected>
 
 */

#define LAST_KEY_CMD                         0xFF // Command Loop 

// Report characteristic
// 0x2A4D
///#define     BLE_REPORT_ID                         0x2A4D // 0x28, 0010 1000

#define ARKRAY_RECORD_LOOP                             4
#define ARKRAY_RECORD_SEL                             6

//#define ARKRAY_DYNAMIC_OFFSET                             6

#define LIST_DEV_DELAY_INTERVAL                     3.0f


#define NEO_CMD_INTERVAL                        0.1f

#define AK_PW_HEADER                                0x93
#define CMD_END                                     0xA0
#define ARKRAY_BASE_ACK                             0x3E

#define AK_PASSWORD_MODE_INTERVAL                        0.2f//0.12f//0.32f


#define AK_BUFFER_SIZE                          (1024 << 2)


#define AK_KEYCMD_MASK                              0x04
#define AK_AUX1CMD_MASK                             0xC4
#define AK_AUX2CMD_MASK                             0xC0

#define AK_CMD_AUX_LEN                          1
#define AK_CMD_DT_LEN                           2
#define AK_CMD_RECORD_LEN                       9


#define AK_BASE_LSTARP                          0x2b
#define AK_BASE_END                             0xa0

#define AK_BASE_DATE                            0xae
#define AK_BASE_TIME                            0xaa

#define AK_BASE_LEND                            0xe6
#define AK_BASE_RECORD_END                          0x2f

#define ARK_CMD_SECRET_LEN                               29
// Arkray Hardware, Model, Serial Number, Last Record, Number fo record
#define ARK_HDINFO_RECORD_LEN                                          53
#define ARK_MODEL_OFFSET                            2
#define ARK_SN_OFFSET                               8
#define ARK_LRDT_OFFSET                             16
#define ARK_NUMBER_OFFSET                           43
#define ARK_NEW_GBLACK_NUMBER_OFFSET                19


#define ARK_RECORD_LEN                              32
#define ARK_MODEL_LEN                               4
#define ARK_SN_LEN                                  7
#define ARK_LRDT_LEN                                26
#define ARK_NUMBER_LEN                              3

#define ARKRAY_CURRENT_DATE_LEN                 12
#define ARKRAY_CURRENT_TIME_LEN                 10

//////
//  Encryption is insufficient.


#define AK00_NUMERIC        0xB3
#define AK01_NUMERIC        0xF3
#define AK02_NUMERIC        0x33
#define AK03_NUMERIC        0x73
#define AK04_NUMERIC        0xB2
#define AK05_NUMERIC        0xF2
#define AK06_NUMERIC        0x32
#define AK07_NUMERIC        0x72
#define AK08_NUMERIC        0xB1
#define AK09_NUMERIC        0xF1


#define AK0A_NUMERIC        0xEF
#define AK0B_NUMERIC        0x2F
#define AK0C_NUMERIC        0x6F
#define AK0D_NUMERIC        0xAE
#define AK0E_NUMERIC        0xEE
#define AK0F_NUMERIC        0x2E

///////////////////////////////
#define ARK_PHS_PAIR                   0

#define ARK_PHS_BUILD                   1
#define ARK_PHS_TRANSFER                2
#define ARK_PHS_TERMINATION             3
#define ARK_PHS_REMOTE                  4

//#define ARK_MODE_ACTION                 0
//#define ARK_MODE_ADDRESS                1
//#define ARK_MODE_DATA                   2

#define ARK_ACTION_R                    'R'
#define ARK_ACTION_B                    'B'

#define ARK_ADDR_DATE                   0
#define ARK_ADDR_TIME                   1

#define ARK_ADDR_EEP                    2
#define ARK_ADDR_INDEX                  3

#define ARK_ADDR_OFF                    5




#import <Foundation/Foundation.h>

@interface ArkrayGBlack : NSObject

//////////////////////
// ARKRAY ARKRAY
@property (nonatomic, strong) CBUUID *Arkray_ServiceUUID;
@property (nonatomic, strong) CBUUID *ArkrayReport_CharacteristicID;
@property (nonatomic, strong) CBUUID *ArkrayGeneral_CharacteristicUUID;


// Arkray G-BLACK Service
@property (nonatomic, strong) CBService *GBlack_Service;


// Arkray G-BLACK Caracteristic
@property (nonatomic, strong) CBCharacteristic *GBlack_Characteristic_Report;

@property (nonatomic, readwrite) NSMutableData *arkrayDataBuffer;

@property (readwrite) Byte *akPassword;
@property (readwrite) Byte *akCmdBuffer;
@property (readwrite) UInt8 arkrayHardWareInfoLen;

@property (nonatomic, strong) NSString *ArkraySvrSerialNumber;
@property (nonatomic, strong) NSString *ArkrayNewSerialNumber;

@property (readwrite) BOOL arkrayShowDialog;
@property (readwrite) BOOL arkraySyncPhs;
@property (readwrite) BOOL arkrayActive;

@property (readwrite) UInt16 arkLrIndex;
@property (readwrite) UInt16 arkLrTotal;

@property (readwrite) UInt8 arkrayCmdSel;

@property (nonatomic, strong) NSString *arkrayTmpIdString;

@property (nonatomic, strong) NSString *arkModel;
//@property (nonatomic, strong) NSString *arkSerialNumber;
@property (nonatomic, strong) NSString *arkCurrentDate;

//////////////////////////
@property (readwrite) UInt8 arkrayDynamicCmd;
@property (readwrite) UInt8 arkrayNackCmd;
@property (readwrite) UInt8 arkrayEnqCmd;

@property (readwrite) UInt8 arkrayAuxEot;
@property (readwrite) UInt8 arkrayDynamicAck;



- (void)arkrayValueUpdate:(CBCharacteristic *)characteristic;


- (void)passwordInit;
- (void)arkraySyncCommand;
- (void)arkrayRecordModeTask;

- (UInt8)numberDeCodeNEW:(UInt8)akCode;

- (UInt8)arkrayToAscii:(UInt8)ch;
- (UInt8)arkrayToHex:(UInt8)ch;

- (BOOL)getCurrentDynamicCommand;
- (void)h2ArkrayCmdNotFoundTask;

- (void)updateDynamicCommand;

+ (ArkrayGBlack *)sharedInstance;

@end
