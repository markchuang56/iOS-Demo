//
//  H2Config.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/13.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

#pragma mark - H2 definition

//#define MAX_BG_VALUE                                600

#define BLE_DELAY_INTERVAL                          3.0f


// Normal
#pragma mark - ROCHE DEFINE
#define ACCU_CHEK_DELAY                             0x80 //0x40//0x60//0x80



#define ROCHE_CMD_RESEND_CYCLE                      2
#define ROCHE_INIT_CMD_RESEND_CYCLE                 0



#define SMG_MMOL_MAX                    33.3f
#define SMG_MG_MAX                      600

#define NORMAL_YEAR                     365
#define LEAP_YEAR                       366



#import "H2Sync.h"

#import "H2BleCentralManager.h"

#import "h2BrandModel.h"
#import "h2CmdInfo.h"
#import "H2DebugHeader.h"

#import "H2Report.h"
#import <Foundation/Foundation.h>

@interface H2Config : NSObject

@end

#pragma mark - AUDIO AND BLE COMMAND OBJECT
@interface H2AudioAndBleCommand : NSObject{
}

@property(readwrite) Byte *value;

@property(readwrite) UInt8 cmdMethod;
@property(readwrite) UInt8 cmdPreMethod;
@property(readwrite) UInt8 cmdModel;
@property(readwrite) UInt8 cmdBrand;

@property(readwrite) UInt8 cmdLength;
@property(readwrite) UInt8 reportLength;

@property(readwrite) UInt8 uartRxBufferOffset;

@property(readwrite) BOOL didTriggerMeterCmd;

@property(readwrite) float cmdInterval;

@property(readwrite) BOOL newRecordAtFinal;


+ (H2AudioAndBleCommand *)sharedInstance;

@end


#pragma mark - Resend COMMAND OBJECT
@interface H2AudioAndBleResendCfg : NSObject{
    
}

@property(readwrite) UInt8 resendSystemCmdCycle;
@property(readwrite) float resendSystemCmdInterval;
@property(readwrite) BOOL didResendSystemCmd;


@property(readwrite) UInt8 resendMeterCmdCycle;
@property(readwrite) float resendMeterCmdInterval;

@property(readwrite) BOOL didResendMeterCmd;


@property(readwrite) BOOL didNeedSaveRocheTypePreCmd;


@property(readwrite) Byte *resendPreCmdHeaderData;
@property(readwrite) UInt16 resendPreCmdLength;

@property(readwrite) UInt16 resendCmdLength;
@property(readwrite) UInt16 resendCmdType;

+ (H2AudioAndBleResendCfg *)sharedInstance;

@end


#pragma mark - AUDIO AND BLE SYNC OBJECT

@interface H2AudioAndBleSync : NSObject{
}
@property(readwrite) Byte *dataHeader;

@property(atomic, readwrite) Byte *dataBuffer;
@property(readwrite) UInt16 dataLength;

@property(readwrite) UInt16 recordIndex;
@property(readwrite) UInt16 recordTotal;

@property(readwrite) BOOL syncPreState;
@property(readwrite) BOOL syncRunning;

@property(readwrite) BOOL syncIsNormalMode;

@property(readwrite) UInt8 syncBrandSel;
@property(readwrite) UInt8 syncModelSel;
@property(readwrite) UInt8 syncMethodSel;



+ (H2AudioAndBleSync *)sharedInstance;

@end


