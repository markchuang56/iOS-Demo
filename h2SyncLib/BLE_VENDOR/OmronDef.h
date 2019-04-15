//
//  OmronDef.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/12/22.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#ifndef OmronDef_h
#define OmronDef_h



#pragma mark - OMRON_HEM_7280T BT 4.0 UUID STRING

#define OMRON_HEM_7280T_SERVICE_UUID                        @"ECBE3980-C9A2-11E1-B1BD-0002A5D5C51B"


#define OMRON_HEM_7280T_A0_CHARACTERISTIC_UUID              @"B305B680-AEE7-11E1-A730-0002A5D5C51B" // properties = 0x1E 0001 1110
#define OMRON_HEM_7280T_A1_CHARACTERISTIC_UUID              @"DB5B55E0-AEE7-11E1-965E-0002A5D5C51B" // properties = 0xC  0000 1100
#define OMRON_HEM_7280T_A2_CHARACTERISTIC_UUID              @"E0B8A060-AEE7-11E1-92F4-0002A5D5C51B" // properties = 0xC  0000 1100

#define OMRON_HEM_7280T_A3_CHARACTERISTIC_UUID              @"0AE12B00-AEE8-11E1-A192-0002A5D5C51B" // properties = 0xC  0000 1100
#define OMRON_HEM_7280T_A4_CHARACTERISTIC_UUID              @"10E1BA60-AEE8-11E1-89E5-0002A5D5C51B" // properties = 0xC  0000 1100
#define OMRON_HEM_7280T_A5_CHARACTERISTIC_UUID              @"49123040-AEE8-11E1-A74D-0002A5D5C51B" // properties = 0x12  0001 0010

#define OMRON_HEM_7280T_A6_CHARACTERISTIC_UUID              @"4D0BF320-AEE8-11E1-A0D9-0002A5D5C51B" // properties = 0x12 0001 0010
#define OMRON_HEM_7280T_A7_CHARACTERISTIC_UUID              @"5128CE60-AEE8-11E1-B84B-0002A5D5C51B" // properties = 0x12 0001 0010
#define OMRON_HEM_7280T_A8_CHARACTERISTIC_UUID              @"560F1420-AEE8-11E1-8184-0002A5D5C51B" // properties = 0x12  0001 0010
#define OMRON_HEM_7280T_A9_CHARACTERISTIC_UUID              @"8858EB40-AEE8-11E1-BB67-0002A5D5C51B" // properties = 0x10 0001 0000

//#define OMRON_HEM_7280T_AX_CHARACTERISTIC_UUID              @"2A001800-1801-2800-2801-280329012902" // properties = 0x??


#define BLE_METER_FLAG                      0x00008000

#define BLE_NEED_LRECORD_LOCATION           0x00010000
#define BLE_NEED_PAIR_DIALOG                0x00020000
#define BLE_NEED_PIN_DIALOG                 0x00040000
#define BLE_NEED_PASSWORD_DIALOG            0x00080000

#define BLE_MULTI_USERS                     0x00100000

#define BLE_BG_EQUIP                        0x01000000
#define BLE_BP_EQUIP                        0x02000000
#define BLE_BW_EQUIP                        0x04000000


#define OMRON_PAIR_MODE                 0x0F
#define OMRON_PAIR_MODEENDING           0x08
#define OMRON_PAIR_CANCEL               0x01

#define HBF_CMD_4        4
#define HBF_CMD_5        5
#define HBF_CMD_6        6
#define HBF_CMD_7        7

#define HBF_CMD_8        8
#define HBF_CMD_9        9
#define HBF_CMD_A        10
#define HBF_CMD_B        11

#define HBF_CMD_C        12

#define HBF_CMD_E        14



#define HBF_YEAR                0x0E
#define HBF_MON                 0x0F
#define HBF_DAY                 0x10
#define HBF_HOUR                0x11
#define HBF_MIN                 0x12
#define HBF_SEC                 0x13

// USER ID
//#define HBF_UID_1               0x20
//#define HBF_UID_2               0x30
//#define HBF_UID_3               0x40
//#define HBF_UID_4               0x50
// USER ID HAS SET


#define SKIP_INDEX
/*
#define CMD_INTERVAL_A0         0.05f

#define CMD_INTERVAL_A2         0.02f
#define CMD_INTERVAL_A3         0.05f

#define CMD_INTERVAL_A0_READ         0.05f
*/

#define CMD_INTERVAL_A1         0.06f

//#define RECORD_INDEX                5

//#define RECORD_INFO                 8
//#define RECORD_INFO_EX               (RECORD_INFO+1)

/*
 #define RECORD_IDX_2             0xBA
 #define RECORD_IDX_3             0xC8
 #define RECORD_IDX_4             0xD6
 #define RECORD_IDX_5             0xE4
 #define RECORD_IDX_6             0xF2
 */

#define BLE_CABLE_SN_LEN            14
#define USER_MAX_2               0x02
#define USER_MAX_3               0x04
#define USER_MAX_4               0x08
#define USER_MAX_5               0x10
#define USER_MAX_6               0x20


//#define A1_CMD_START            4
#define OMRRON_COMMAND_SIZE          32
#define OMRRON_BUFFER_SIZE          256

#define HEM_MAX_TAG             2
#define HBF_MAX_TAG             4


// COMMAND BUFFER LENGHT
#define OM_NORMAL_CMDBUF_LEN                       8
#define OM_MAX_CMDBUF_LEN                          16

// COMMAND TOTAL LENGHT
#define HEM_UID_TOTAL_LEN                       0x1C//(0x1C-6)
#define HEM_TIME_TOTAL_LEN                       0x12

#define HBF_SIDX_CMD_LEN                     0x10
#define HBF_SIDXCT_CMD_LEN                   0x18
#define HBF_SCT_CMD_LEN                      0x12

#define HBF_SPF_CMD_LEN                  0x18



// DATA LENGHT
#define HBF_SIDX_DATA_LEN                    0x08
#define HBF_SIDXCT_DATA_LEN                  0x10
#define HBF_SCT_DATA_LEN                     0x08

#define HBF_SPF_DATA_LEN                    0x10
#define HBF_SPF_TRAIL_LEN                    0x06

#define OM_INDEX_DATA_LEN                    0x08

// GET
#define HEM_GCT_DATA_LEN                    0x26
#define HBF_GCT_DATA_LEN                    0x30
#define HBF_GPF_DATA_LEN                    0x30

// MEMORY INFO
#define HEM_7280T_UID_DATA_LEN              0x2E

#define HEM_UID_TOTAL_DATA_LEN                       0x14//(0x14-6)
#define HEM_TIME_TOTAL_DATA_LEN                       0x0A






// BP INFO
#define BP_RECORDS_MAX                  100
#define BP_RECORD_IDX_MAX                  100

// BW INFO
#define BW_RECORDS_MAX                  (30+1)
#define BW_RECORD_IDX_MAX                  30



// COMMAN PRAMETER
#define OM_FLASH_AREA                           0x01

#define OM_READ_FLASH                           0x00
#define OM_WRITE_FLASH                          0xC0



// MEMORY ADDRESS
// 7280T, 7600T
#define HEM_7280T_GIDXCT_ADDR                   0x0260
#define HEM_7280T_SIDXTAG_ADDR                  0x0286
#define HEM_7280T_TIME_ADDR                 0x029A
//#define HEM_7280T_TIME2_ADDR                 0x0294
// REOCRDS
#define HEM_7280T_RECORD1_ADDR               0x2AC
#define HEM_7280T_RECORD2_ADDR               0x824

// 254C, 255T, 256T
#define HBF_254C_GIDXCT_ADDR                    0x01A0
#define HBF_254C_PROFILE_ADDR                   0x01D0

#define HBF_254C_SIDX_ADDR                       0x0200
#define HBF_254C_STIMER_ADDR                     0x0208
#define HBF_254C_SPF_ADDR                       0x0220

// RECORDS
#define HBF_254C_RECORD1_ADDR               0x0260
#define HBF_254C_RECORD2_ADDR               0x0640
#define HBF_254C_RECORD3_ADDR               0x0A20
#define HBF_254C_RECORD4_ADDR               0x0E00

// 6320T-Z, 6324T
#define HEM_6320T_GIDXCT_ADDR                   0x0F74
#define HEM_6320T_SIDXTAG_ADDR                  0x0F9A
#define HEM_6320T_STIMER_ADDR                 0x0FAE
#define HEM_6320T_TIME2_ADDR                 0x0FA8
// RECORDS
#define HEM_6320T_RECORD1_ADDR               0x0370
#define HEM_6320T_RECORD2_ADDR               (0x0370 + 100 * 0x0E)

// Model
#define HEM7280T_MODEL  @"00000413"
#define HEM7600T_MODEL  @"0000001F"
#define HEM6320T_MODEL  @"00000119"
#define HEM6324T_MODEL  @"0000002D"
#define HBF254C_MODEL   @"00010504"
#define HBF254C_MODEL_EX   @"00010004"
#define HBF256T_MODEL   @"00010007"

#define HEM9200T_MODEL   @"00000116"

#define OMRON_MODEL_LEN                         8
#define OMRON_MODEL_LOCATION                    9
#define OMRON_NAME_LEN                          29
#define OMRON_MODEL_MAC_LEN                     20




#define RECORD_CMD_LEN                  8

#endif /* OmronDef_h */

#if 0
unsigned char hemCmd5_GetCurrentTime[] = {
    // Report Current Time and number of records
    // HEM-7280T
    0x08, 0x01, 0x00, 0x02, 0x60, 0x26, 0x00, 0x4D
};



unsigned char hemCmdClearIndex[] = {
    0x10, 0x01, 0xC0, 0x02,   0x86, 0x08, 0x80, 0x00
    , 0x80, 0x00, 0x80, 0x00,   0x80, 0x00, 0x00, 0xDC
};



/////////////////////////////////////////////////////////
// HEM 7280T USER ID
unsigned char hemUser1Step1Cmd[] = {
    0x16, 0x01, 0xC0, 0x02,     0x86, 0x0E, 0x80, 0x00,
    0x80, 0x00, 0x80, 0x00,     0x80, 0x00, 0x01, 0x00,
    
    0xFF, 0x01, 0xCA, 0x01,     0x00, 0x69, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
};



// Set Current Time
unsigned char hemUser1CurrentTimeCmd[] = {
    0x12, 0x01, 0xc0, 0x02,    0x9a, 0x0a, 0x08, 0x48
    , 0x02, 0x11    // 月年
    , 0x02, 0x0a    // 時日
    , 0x06, 0x16    // 秒分
    , 0x54, 0xc0    // 計算方法
    , 0x00, 0xdf
    
    , 0x00 , 0x00 ,    0x00 , 0x00 , 0x00 , 0x00
    ,0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
    /*
     0x00, 0x94, 0x02, 0x13,     0x10, 0x05, 0x15, 0x7D
     */
};


/////////////////////////////////////////////////////////
// HEM 7280T USER ID
unsigned char hemUser2Id2Cmd[] = {
    0x10, 0x01, 0xC0, 0x02,     0x86, 0x08, 0x80, 0x00,
    0x80, 0x00, 0x80, 0x00,     0x80, 0x00, 0x00, 0x5D
};

unsigned char hemUser2CurrentTimeCmd[] = {
    0x18, 0x01, 0xC0, 0x02,     0x94, 0x10, 0x01, 0x00
    , 0xFF, 0x01, 0xCA, 0x01,     0x08, 0x48
    , 0x02, 0x11    // 月年
    , 0x12, 0x0C    // 時日
    , 0x18, 0x33    // 秒分
    , 0x54, 0xCC    // 計算方法
    , 0x00, 0x95
    , 0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
};
#endif


//unsigned char hbfCmd4_GetHardwareInfo[] = {
//    0x08, 0x00, 0x00, 0x00,    0x00, 0x10, 0x00, 0x18
//};

//unsigned char hbfCmd5_GetIdxCurrentTime[] = {
// Report Current Time and number of records
//    0x08, 0x01, 0x00, 0x01,0xA0, 0x30, 0x00, 0x98
//};




/*
 unsigned char hbfCmdClearIndex[] = {
 0x10, 0x01, 0xC0, 0x02,   0x00, 0x08, 0x00, 0x00
 , 0x80, 0x00, 0x80, 0x00,   0x80, 0x00, 0x00, 0xDC
 };
 */
#if 0
unsigned char hbfCmdE_UserPorfile[] = {// 71/03/05
    // SET User 1, else fixed for test
    0x18, 0x01, 0xc0, 0x02, 0x20, 0x10, 0x57, 0x01
    , 0x01, 0x01, 0x06, 0x40, 0x81, 0x82, 0x83, 0x85
    , 0x86, 0x84, 0x00, 0x00, 0xB5, 0xEB, 0x00, 0xB2
    /*
     0x18, 0x01, 0xc0, 0x02, 0x20, 0x10, 0x47, 0x03
     , 0x05, 0x01, 0x06, 0x40, 0x81, 0x82, 0x83, 0x85
     , 0x86, 0x84, 0x00, 0x00, 0xab, 0x4d, 0x00, 0x0c
     */
    , 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    
    //0x18 , 0x01 , 0xC0 , 0x02 , 0x50 , 0x10 , 0x57 , 0x01       , 0x01 , 0x00 , 0x06 , 0x40 , 0x81 , 0x82 , 0x83 , 0x85,
    //0x86 , 0x84 , 0x00 , 0x00 , 0xB4 , 0xD6 , 0x00 , 0xEF       , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
};
#endif



/////////////////////////////////////////////////////////
// HEM 6320T-Z, 6324T, 7280T, 7600T
/*
 unsigned char hemUserTagCmd[] = {
 0x16, 0x01, 0xC0, 0x0F,     0x9A, 0x0E, 0x80, 0x00,
 0x80, 0x00, 0x80, 0x00,     0x80, 0x00, 0x01, 0x00,
 
 0xFF, 0x01, 0xCA, 0x01,     0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
 };
 */
// Set Current Time
/*
 unsigned char hemTag1CurrentTimeCmd[] = {
 // 6320T
 0x12, 0x01, 0xc0, 0x0F,    0xAE, 0x0a, 0x08, 0x48
 , 0x02, 0x11    // 月年
 , 0x02, 0x0a    // 時日
 , 0x06, 0x16    // 秒分
 , 0x54, 0xc0    // 計算方法
 , 0x00, 0xdf
 
 , 0x00 , 0x00 ,    0x00 , 0x00 , 0x00 , 0x00
 ,0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
 };
 */
/*
 unsigned char hemCurrentTimeCmd[] = {
 0x12, 0x01, 0xc0, 0x0F,    0xAE, 0x0a, 0x08, 0x48
 , 0x02, 0x11    // 月年
 , 0x02, 0x0a    // 時日
 , 0x06, 0x16    // 秒分
 , 0x54, 0xc0    // 計算方法
 , 0x00, 0xdf
 
 , 0x00 , 0x00 ,    0x00 , 0x00 , 0x00 , 0x00
 ,0x00, 0x00, 0x00, 0x00,      0x00, 0x00, 0x00, 0x00
 };
 */


