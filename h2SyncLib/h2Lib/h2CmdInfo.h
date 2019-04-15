//
//  h2CmdInfo.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/10/3.
//
//

#import <Foundation/Foundation.h>

#define BUFFERIDLE          0x00
#define BUFFERBUSY          0x01
#define BUFFEROK            0x02

#define MMOL_COIF           18.0182

#define UART_1200               0
#define UART_2400               1
#define UART_4800               2
#define UART_9600               3
#define UART_19200              4
#define UART_38400              5
#define UART_56000              6
#define UART_115200             7
#define UART_128000             8


//#define UART_NONE               0x00
//#define UART_ODD                0x10
//#define UART_EVEN               0x30
#define UART_ODD_MASK                0x10
#define UART_EVEN_MASK               0x30



//#define UART_1STOP              0x00
#define UART_2STOP_MASK              0x40

//#define UART_8BIT               0x00
#define UART_7BIT_MASK               0x80


#define NORINV_SWITCH_ADDR                              2
#define UART_BAUDRATE_ADDR                              3
#define DATE_FOR_COMPARE_ADDR                           5

#define SW_GRT                              0
#define SW_GTR                              1
#define SW_RTG                              2
#define SW_TRG                              3
#define SW_RGT                              4
#define SW_TGR                              5

#define SW_NorNorTR_MASK             0x00
#define SW_InvInvTR_MASK             0x10
#define SW_InvNorTR_MASK             0x20
#define SW_NorInvTR_MASK             0x30

//#define SW_NorNorTR             0x00
//#define SW_InvInvTR             0x10
//#define SW_InvNorTR             0x20
//#define SW_NorInvTR             0x30



#define UART_MINIB_MASK                 0x40

//#define UART_IR_NA                 0x00
#define UART_IR_MASK                 0x80


#define BLE_MCU_RESET                   0x00

#define BLE_MCU_SW                      0x01
#define BLE_MCU_BIONIME                 0x02
#define BLE_MCU_APEXBIO                 0x03
#define BLE_MCU_RST                     0x00
#define BLE_MCU_PM3                     0xFF


#pragma mark -
#pragma mark METER BRAND ID
#define VENDOROFFSET            1


#define CMD_BLE_RESET                  0x90

#define CMD_SW_ON                   0x91
#define CMD_SW_OFF                  0x92
#define CMD_UART_INIT               0x93
#define CMD_CABLE_VERSION           0x96
#define CMD_CABLE_EXISTING          0x95
#define CMD_EX_METER_TALK           0x94
//#define CMD_GET_AUDIO_BUFFER_TALK           0x94

#define CMD_INTERFACE_TEST          0x98
#define CMD_GET_BUFFER              0x99
#define CMD_SN_TALK                 0x9A

#define CMD_ROCHE_TALK                 0x9C


#define ACK_TEST                    0x08
#define ACK_SN                      0x0B


#define CMD_RESEND_NORMAL                       0x00

#define CMD_RESEND_ROCHE_INIT                   0x01
#define CMD_RESEND_ROCHE_RESET_MCU              0x11

#define CMD_RESEND_BAYER                        0x02
#define CMD_RESEND_GLUCODE                      0x03
#define CMD_RESEND_ULTRA2                       0x04



// Data Process finally ....
// 1. Sync Fail Process
// 2. Send Equipment Info
// 3. Single or Multi Records Process
// 4. Finished Process

#define TASK_FAIL                               1
#define TASK_EQUIP_INFO                         2
#define TASK_SM_RECORDS                         3
#define TASK_FINISH                             4




#pragma mark -
#pragma mark H2SYNC SYSTEM COMMAND STRUCTURE

@interface H2SyncSystemCommand : NSObject{
}

@property(readwrite) UInt8 cmdLength;

@property(readwrite) UInt16 cmdSystemTypeId ;

@property(readwrite) UInt8 cmdSystemDataLength;
@property(readwrite) UInt8 cmdMcuBufferOffsetAt;

@property(readwrite) Byte *cmdData;

+ (H2SyncSystemCommand *)sharedInstance;
@end


#pragma mark - H2SYNC METER COMMAND

@interface H2SyncMeterCommand : NSObject{
}

@property(readwrite) UInt8 cmdLength;

@property(readwrite) UInt16 cmdMeterTypeId;

@property(readwrite) UInt8 cmdMeterDataLength;
@property(readwrite) UInt8 cmdMcuBufferOffsetAt;

@property(readwrite) Byte *cmdData;


+ (H2SyncMeterCommand *)sharedInstance;
@end







#pragma mark - H2COMMAND INFORMATION
@interface H2CmdInfo : NSObject{
    

}

//nonatomic, strong
@property(atomic, readwrite) UInt16 receivedDataLength;
@property(atomic, readwrite) UInt8 cmdPreMethod;
@property(atomic, readwrite) BOOL cmdSavePreMethod;


//@property(nonatomic, unsafe_unretained) UInt8 cmdUartSel;
//@property(nonatomic, unsafe_unretained) UInt8 cmdSwitchSel;
@property(readwrite) UInt8 cmdIrDAMiniBNorInvZeroSwitch;
@property(readwrite) UInt8 cmdUartLenStopParityBaudRate;


@property(readwrite) UInt16 meterRecordCurrentIndex;

@property(readwrite) UInt16 meterRecordReportIndex;
@property(readwrite) BOOL meterIndexEqualToOne;

+ (H2CmdInfo *)sharedInstance;

@end
// [h2CmdInfo sharedInstance];

#pragma mark - CABLE STATUS PARAMETER

@interface H2CableParameter : NSObject{
}

@property(nonatomic, strong) NSString *h2AudioRoute;
@property(readwrite) UInt8 cmdCableStatus;


@property(readwrite) BOOL didSkipExistCmd;
//@property(readwrite) BOOL didFinishedExistCmd;
@property(readwrite) BOOL didFinishedVersionCmd;

@property(readwrite) UInt32 CableVersionNumber;


@property(readwrite) BOOL cmdGroupInitFlag;


@property(nonatomic, strong) NSString *sdkAndCableVersion;

+ (H2CableParameter *)sharedInstance;

@end




#pragma mark - SYNC STATUS

@interface H2SyncStatus : NSObject{
}

@property(readwrite) BOOL didReportFinished;
@property(readwrite) BOOL didReportSyncFail;

@property(readwrite) BOOL sdkFlowActive;
//@property(readwrite) BOOL cablePreSyncStep;
@property(readwrite) BOOL cableSyncStop;

@property(readwrite) BOOL didMeterUartReady;


+ (H2SyncStatus *)sharedInstance;
@end







