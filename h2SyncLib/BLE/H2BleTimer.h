//
//  H2BleTimer.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/8/22.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


/*
 
 */


#define OAD_WRITE_INTERVAL                      1.0f

// NORMAL
#define BLE_RECORD_INTERVAL                                     3.0f
#define BLE_RECONNECT_INTERVAL                                  2.0f
#define BLE_EXTEND_INTERVAL                                     1.2f
 
#define BLE_BGM_INTERVAL                                        3.0f

// OMRON AREA
#define OMRON_MODE_INTERVAL                 3.0f
//#define OMRON_RECORD_INTERVAL               1.5f
#define OMRON_REGISTER_INTERVAL             15.0f

#define OMRON_CMD_INTERVAL                 0.02f


/////////////////////////////////////////////////////////
#define BLE_SCAN_FOR_PAIRING_INTERVAL                           10.0f
#define BLE_SCAN_FOR_SYNC_INTERVAL                              5.0f

#define BLE_CONNECT_INTERVAL                                5.0f

#define BLE_PREPIN_INTERVAL                                     1.0f
#define BLE_NOTIFY_INTERVAL                                     5.0f
#define BLE_DIALOG_INTERVAL                                     35.0f

#define BLE_ARKRAY_CMD_INTERVAL                                     4.0f

#define BLE_FLUS_FLEX_INTERVAL                                     5.0f
#define BLE_FLUS_FLEX_RS_INTERVAL                                     5.0f

#if 1
#define BLE_READ_SN_INTERVAL                                6.0f //6.0f //5.0f//3.0f // For W310B using 8.0f
#define BLE_PIN_INTERVAL                                    30.0f //25.0f//30.0f// FOR VERDOR PAIRING
#define BLE_USER_INPUT_INTERVAL                             30.0f
#else
#define BLE_READ_SN_INTERVAL                                360.0f //5.0f//3.0f
#define BLE_PIN_INTERVAL                                    500.0f//30.0f// FOR VERDOR PAIRING
#define BLE_USER_INPUT_INTERVAL                             30.0f
#endif




#define BLE_STOP_TIME                                   1.0f

#define BLEDEVBEFOUND                                   4

#define BLE_PAIRING_REPORT_DELAY_TIME                                2.0f

#import <Foundation/Foundation.h>

#define BLE_TIMER_SCAN_MODE                                 1
#define BLE_TIMER_BLE_CONNECT_MODE                          2
#define BLE_TIMER_READ_SN                                   3

#define BLE_TIMER_PREPIN_MODE                               4
#define BLE_TIMER_PIN_MODE                                  5
#define BLE_TIMER_USER_INPUT                                6

#define BLE_TIMER_RECORD_MODE                               8

#define BLE_TIMER_OMRON_MODE                                9
#define BLE_TIMER_OMRON_CMD_FLOW                            10

//#define BLE_TIMER_BGM_MODE                                  11
#define BLE_TIMER_ARKRAY_NOTIFY                             12
#define BLE_TIMER_ARKRAY_CMD_CHECK                          13

#define BLE_TIMER_OMRON_HEM_CMD_FLOW                        14
#define BLE_TIMER_OMRON_HBF_CMD_FLOW                        15

#define BLE_TIMER_BGM_DATA_MODE                               16

#define BLE_TIMER_OH_PLUS_FLEX                               17

@interface H2BleTimer : NSObject

@property (nonatomic, strong) NSTimer *h2BleNormalTimer;

@property (readwrite) UInt8 bleTimerTaskSel;

@property (readwrite) BOOL bleRecordModeForTimer;




- (void)h2SetBleTimerTask:(float)interval taskSel:(UInt8)taskSel;
- (void)h2ClearBleTimerTask;

- (void)h2ReadSerialNumberTimeOut;

- (Byte *)systemCurrentTime;

+ (H2BleTimer *)sharedInstance;

@end
