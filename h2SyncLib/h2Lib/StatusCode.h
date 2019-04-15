//
//  StatusCode.h
//  h2SyncLib
//
//  Created by h2Sync on 2018/1/19.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#ifndef StatusCode_h
#define StatusCode_h


#define DELEGATE_SYNC                   0
#define DELEGATE_PAIRING                1
#define DELEGATE_DEVELOP                2

// cable status code list
#define SUCCEEDED_SWITCH_ON                    0x01
#define SUCCEEDED_SWITCH_OFF                   0x02
#define SUCCEEDED_CABLE_UART_INIT              0x03
#define SUCCEEDED_PRE_COMMAND                  0x04
#define SUCCEEDED_CABLE_EXIST                  0x05
#define SUCCEEDED_CABLE_VERSION                0x06

#define SUCCEEDED_ROCHE_TALK                    0x0C
#define SUCCEEDED_NEW_TIME_FMT                    0x0F

/************************************************
 * AUDIO STATUS
 *
 ***********************************************/
#define FAIL_SWITCH_ON                      0x81
#define FAIL_SWITCH_OFF                     0x82
#define FAIL_CABLE_UART_INIT                0x83
#define FAIL_CABLE_IN                       0x84
#define FAIL_CABLE_EXIST                    0x85
#define FAIL_CABLE_VERSION                  0x86
#define FAIL_METER_EXISTING                 0x87
#define FAIL_SYNC                           0x8A

/************************************************
 * BLE STATUS
 *
 ***********************************************/
#define FAIL_AUDIO_MID                                      0x21
#define FAIL_EQUIPID_IF                                     0x22
#define FAIL_USERTAG                                        0x23
#define FAIL_DATATYPE                                       0x24
#define FAIL_KEY_ERROR                                      0x25
#define FAIL_BLE_CABLE_SN                                   0x26
#define FAIL_SDK_BUSY                                       0x27





// 成功
#define SUCCEEDED_NEW                            0x0A
#define SUCCEEDED_OLD                            0x1A
#define SUCCEEDED_PAIR                           0x2A

#define FAIL_BLE_PHONE_OFF                          0xE2 // iPhone BT not turn ON
#define FAIL_BLE_NOT_FOUND                          0xE3 // NO BLE device have found

// PIN Error or Canncel
#define FAIL_BLE_INSUFFICIENT_AUTHENTICATION        0xE4 //

#define FAIL_BLE_PAIR_TIMEOUT                       0xE5 // Pairing Time out

#define FAIL_BLE_MODE                               0xE6 // Mode Error
#define FAIL_BLE_UNKNOWN                                    0xE8



#define FAIL_BLE_CMD_ERR                                    0xA1 // SYNC ERR
#define FAIL_BLE_ARKRAY_CMD_NOT_FOUND                       0xA2 // Pair ERR, Retry
#define FAIL_BLE_ARKRAY_PASSWORD                            0xA3 // Pair Err, Remove & Retry
#define FAIL_BLE_ARKRAY_PWSLOWLY                            0xA5 // Pair Err, Remove & Retry


#define FAIL_BLE_OMRON_PAIRCANCEL                           0xA6 // Maybe Change ...

// W310
#define FAIL_BLE_FORA_NO_USER_SEL                           0xA7
#define FAIL_LDT_FMT                                        0xA8


#define FAIL_BLE_NORESPONSE                                 0xA9
#define FAIL_BLE_NEO_DISCONNECT                             0xAB

// Command Error OR Command Not Found ...

// Time Out, because User remove Paired device from BG equipment ble paired list,
// or auto remove in True Metrix(max paired 4 devices)
// Ascensia Next ONE
// Roche accu Guide or Connect


#endif /* StatusCode_h */



