//
//  OneTouchPlusFlex.h
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/7/6.
//  Copyright © 2018年 h2Sync. All rights reserved.
//


#pragma mark - ONE TOUCH PLUS FLEX UUID

#define BLE_PLUS_FLEX_SERVICE_UUID                  @"AF9DF7A1-E595-11E3-96B4-0002A5D5C51B"

#define BLE_PLUS_FLEX_NOTIFY_UUID                   @"AF9DF7A3-E595-11E3-96B4-0002A5D5C51B" // 0x10, 0001 0000
#define BLE_PLUS_FLEX_WRITE_UUID                    @"AF9DF7A2-E595-11E3-96B4-0002A5D5C51B" // 0x0C, 0000 1100


#define CRC_INIT                    0xFFFF

#if 1
#define FLEX_PAIR_MODE
#else
#define FLEX_SYNC_MODE
#endif

#define FLEX_CMD_ADDR_INIT                  0x0409
#define FLEX_CMD_ADDR_KEY                   0x04E6
#define FLEX_CMD_ADDR_PW                    0x0411
#define FLEX_CMD_ADDR_CT                    0x0420
#define FLEX_CMD_ADDR_SETCT                 0x0320

#define FLEX_CMD_ADDR_TOTAL                 0x0427
#define FLEX_CMD_ADDR_Z                     0x030A

#define FLEX_CMD_ADDR_PRESYNC               0x040A
#define FLEX_CMD_ADDR_INDEX                 0x0431

#define FLEX_BACK_ADDR_SCT                  0x0306
#define FLEX_BACK_ADDR_IDX                  0x040F

#define OH_CMD_81               0x81
#define OH_CMD_82               0x82
#define OH_CMD_83               0x83

#define OH_ST               0x2
#define OH_EOT              0x3

#define OH_OFFSET_ST            1
#define OH_OFFSET_LEN           2
#define OH_OFFSET_ADDR          4
#define OH_OFFSET_DATA          6

#define OH_LEN_ST                   1
#define OH_LEN_EOT                  1
#define OH_LEN_LEN                  2
#define OH_LEN_ADDR                 2
#define OH_LEN_CRC                  2

#define FLEX_DIV                    19

#define FLEX_CMD_0          0
#define FLEX_CMD_1          1
#define FLEX_CMD_2          2
#define FLEX_CMD_3          3
#define FLEX_CMD_4          4
#define FLEX_CMD_5          5
#define FLEX_CMD_6          6
#define FLEX_CMD_7          7
#define FLEX_CMD_8          8
#define FLEX_CMD_9          9
#define FLEX_CMD_A          0xA
#define FLEX_CMD_B          0xB
#define FLEX_CMD_C          0xC
#define FLEX_CMD_D          0xD
#define FLEX_CMD_E          0xE
#define FLEX_CMD_F          0xF
#define FLEX_CMD_10          0x10
#define FLEX_CMD_11          0x11
#define FLEX_CMD_12          0x12
#define FLEX_CMD_13          0x13
#define FLEX_CMD_14          0x14
#define FLEX_CMD_15          0x15
#define FLEX_CMD_16          0x16
#define FLEX_CMD_17          0x17
#define FLEX_CMD_18          0x18
#define FLEX_CMD_19          0x19
#define FLEX_CMD_1A          0x1A

#define FLEX_CMD_1B          0x1B
#define FLEX_CMD_1C          0x1C
#define FLEX_CMD_1D          0x1D
#define FLEX_CMD_1E          0x1E
#define FLEX_CMD_1F          0x1F

/*
#define FLEX_CMD_GROUP0          0
#define FLEX_CMD_GROUP1          1
#define FLEX_CMD_GROUP2          2
#define FLEX_CMD_GROUP3          3
*/

//#define FLEX_MAX_IDX            300

#import <Foundation/Foundation.h>


@interface OneTouchPlusFlex : NSObject

#pragma mark - ONE TOUCH PLUS FLEX Object
// UUID
@property (nonatomic, strong) CBUUID *ohPlusFlexServiceID;

@property (nonatomic, strong) CBUUID *ohPlusFlexCharacteristicNotifyID;
@property (nonatomic, strong) CBUUID *ohPlusFlexCharacteristicWriteID;

// OneTouch Plus Flex Service
@property (nonatomic, strong) CBService *ohPlusFlexService;

// OneTouch Plus Flex Characteristic

@property (nonatomic, strong) CBCharacteristic *ohPlusFlexCharacteristicNotify;
@property (nonatomic, strong) CBCharacteristic *ohPlusFlexCharacteristicWrite;


@property (readwrite) UInt8 flexCmdSel;
@property (readwrite) BOOL flexFirstCmd;
//@property (readwrite) BOOL rocheSetting;
//@property (readwrite) UInt8 flexCmdGroupSel;


- (void)plusFlexBufferInit;

- (void)oneTouchValueUpdate:(CBCharacteristic *)characteristic;

- (void)flexCmdFlowInit;
- (void)flexCmdFlowSync;
- (void)plusFlexCmdFlow;//:(UInt8)flowSel
- (void)flexCmdProcess:(unsigned char *) srcData withCmdLen:(UInt16)dataLen cmdLocal:(UInt16)memAddr;

+ (OneTouchPlusFlex *)sharedInstance;

@end

// value = <03022a00 04063600 46003400 35004600 35004300>, notifying = YES>
// value = <41440046 00330043 00370037 00430046 00430000>, notifying = YES>
// value = <4200035a 17>, notifying = YES>

// value = <03022a00 04064300 34003300 43003500 43003300>, notifying = YES>
// value = <41450044 00360042 00350039 00450046 00330000>, notifying = YES>

// value = <03022a00 04064300 35003400 30003800 37004500>, notifying = YES>
// value = <41440031 00410043 00350045 00300042 00360000>, notifying = YES>
// value = <420003a8 6f>, notifying = YES>

// value = <03022a00 04063800 35004600 43003900 33003200>, notifying = YES>
// value = <41440041 00460033 00330037 00320043 00300000>, notifying = YES>
// value = <42000306 c8>, notifying = YES>

// value = <03022a00 04063800 37003600 38003600 32004400>, notifying = YES>
// value = <41440036 00410034 00410039 00410036 00350000>, notifying = YES>
// value = <420003a1 cb>, notifying = YES>

// value = <03022a00 04063600 38004100 46003100 36004500>, notifying = YES>
// value = <41300044 00320032 00430032 00460034 00420000>, notifying = YES>
// value = <42000380 39>, notifying = YES>

// 47 00 87
// value = <03022a00 04064500 41003000 31004600 43004600>, notifying = YES>
// value = <41440045 00330044 00440032 00410046 00450000>, notifying = YES>
// value = <4200039c b7>, notifying = YES>

// 70 82 52
// value = <03022a00 04063000 30003500 43004300 39003000>, notifying = YES>
// value = <41310037 00370042 00310041 00410046 00410000>, notifying = YES>
// value = <42000309 27>, notifying = YES>

// 35 54 18
// value = <03022a00 04063500 45004100 46004100 42004300>, notifying = YES>
// value = <41370042 00360036 00320034 00440041 00440000>, notifying = YES>
// value = <42000359 7c>, notifying = YES>


// 59 70 31
// value = <03022a00 04063000 34004100 36004100 33003400>, notifying = YES>
// value = <41420041 00430037 00350032 00330043 00360000>, notifying = YES>
// value = <420003ff 19>, notifying = YES>

// 53 74 48
// kCBAdvDataManufacturerData = <6d010200 0560d191 78af419c 9833d5e1 7284d232>;
// value = <01020c00 04060100 000003b6 5c>, notifying = YES>
// value = <03022a00 04063000 43004200 45003100 37003000>, notifying = YES>
// value = <41350044 00390037 00300041 00460039 00370000>, notifying = YES>
// value = <420003e9 6b>, notifying = YES>

// 06000109 2000c093 d53878eb c4b84a4c 5c61c248 394a540e b576fb12 8b


/*
 switch (_flexCmdGroupSel) {
 case FLEX_CMD_GROUP0:
 //
 break;
 
 case FLEX_CMD_GROUP1:
 //
 break;
 
 case FLEX_CMD_GROUP2:
 //
 break;
 
 case FLEX_CMD_GROUP3:
 //
 break;
 
 default:
 break;
 }
 */

#if 0
unsigned char flexCmdInit[11] =
{
    0x01, 0x02, 0x0A, 0x00,
    0x04, 0x09, 0x02, 0x02,
    0x03, 0xC6, 0x0F
};
// 13 bytes , value = <01020c00 04060100 000003b6 5c>, notifying = YES>
// value = <01020c00 04060100 000003b6 5c>, notifying = YES>
// value = <01020c00 04060100 000003b6 5c>,

unsigned char flexCmd81[1] = { 0x81 };

unsigned char flexCmdKey[11] =
{
    0x01, 0x02, 0x0A, 0x00,
    0x04, 0xE6, 0x02, 0x08,
    0x03, 0x09, 0xB0
};

unsigned char flexCmd83[1] = { 0x83 };
unsigned char flexCmd82[1] = { 0x82 };

unsigned char flexCmdPassword[20] =
{
    0x02, 0x02, 0x18, 0x00, 0x04, 0x11, 0x3B, 0x98,
    0x6A, 0xC5, 0x74, 0xF3, 0x87, 0xE7, 0xAA, 0x42,
    0xAF, 0x24, 0x26, 0x59
    /*
     0x02, 0x02, 0x18, 0x00,  0x04, 0x11, 0xEE, 0x9A,
     0x58, 0x08, 0x88, 0x13,  0x3A, 0xD9, 0x38, 0x89,
     0xEF, 0x2A, 0xE6, 0x66
     */
};

unsigned char flexCmdMid[6] =
{
    0x41, 0x6C, 0xFD, 0x03, 0xA6, 0x90
    //0x41, 0xD2, 0x48, 0x03,  0xBA, 0xF5
};

unsigned char flexCmdMidX[10] =
{
    0x01, 0x02, 0x09, 0x00, 0x04, 0x20, 0x02, 0x03,
    0xF9, 0xC3
};

unsigned char flexCmdMidy[10] =
{
    0x01, 0x02, 0x09, 0x00, 0x04, 0x27, 0x00, 0x03,
    0x0B, 0x20
};

unsigned char flexCmdMidz[11] =
{
    0x01, 0x02, 0x0A, 0x00, 0x03, 0x0A, 0x02, 0x08,
    0x03, 0x05, 0x1C
};

unsigned char flexCmdMida[11] =
{
    0x01, 0x02, 0x0A, 0x00, 0x03, 0x0A, 0x02, 0x07,
    0x03, 0x3B, 0x0C
};

unsigned char flexCmdMidb[11] =
{
    0x01, 0x02, 0x0A, 0x00, 0x04, 0x0A, 0x02, 0x06,
    0x03, 0xDE, 0x58
};

unsigned char flexSrcIndex[12] =
{
    //0x01,
    0x02, 0x0C, 0x00,
    0x04, 0x31, 0x02, 0x05,
    0x00, 0x00,
    0x03, 0xEC, 0xE9
};

unsigned char flexCmdIndex[13] =
{
    0x01, 0x02, 0x0C, 0x00,
    0x04, 0x31, 0x02, 0x05,
    0x00, 0x00,
    0x03, 0xEC, 0xE9
};
#endif


#if 0
switch (_flexCmdSel) {
    case FLEX_CMD_0:
    case FLEX_CMD_C:
        dataToWrite = [NSData dataWithBytes:flexPairCmd length:sizeof(flexPairCmd)];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
        break;
        
    case FLEX_CMD_1:
    case FLEX_CMD_4:
    case FLEX_CMD_B:
        //case FLEX_CMD_C:
        dataToWrite = [NSData dataWithBytes:flexCmd1 length:sizeof(flexCmd1)];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
        break;
        
    case FLEX_CMD_3:
        
        dataToWrite = [NSData dataWithBytes:flexCmd3 length:sizeof(flexCmd3)];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
        break;
        
    case FLEX_CMD_5:
        dataToWrite = [NSData dataWithBytes:flexCmd4 length:sizeof(flexCmd4)];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
        break;
        
    case FLEX_CMD_2:
        dataToWrite = [NSData dataWithBytes:flexCmd2 length:sizeof(flexCmd2)];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
        break;
        
        //case FLEX_CMD_4:
        //
        //break;
        
    case FLEX_CMD_6:
        dataToWrite = [NSData dataWithBytes:flexCmd5 length:sizeof(flexCmd5)];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
        NSLog(@"ONE TOUCH NEW CMD = %02X", _flexCmdSel);
        _flexCmdSel += 2;
        //
        break;
        /*
         case FLEX_CMD_8:
         dataToWrite = [NSData dataWithBytes:flexCmd5 length:sizeof(flexCmd5)];
         [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
         NSLog(@"ONE TOUCH NEW CMD = %02X", _flexCmdSel);
         _flexCmdSel += 2;
         break;
         */
    case FLEX_CMD_9:
        dataToWrite = [NSData dataWithBytes:flexCmd6 length:sizeof(flexCmd6)];
        [[H2BleService sharedInstance].h2ConnectedPeripheral writeValue:dataToWrite forCharacteristic:_ohPlusFlexCharacteristicWrite type:CBCharacteristicWriteWithResponse];
        NSLog(@"ONE TOUCH 41 D2 CMD = %02X", _flexCmdSel);
        
        break;
    case FLEX_CMD_A:
        NSLog(@"ONE TOUCH NEW CMD (WOW)EX = %02X", _flexCmdSel);
        break;
        
        //case FLEX_CMD_B:
        //    NSLog(@"ONE TOUCH NEW CMD (WOW)EX = %02X", _flexCmdSel);
        //    _flexCmdSel += 2;
        //    break;
        
        
    default:
        break;
}
#endif


