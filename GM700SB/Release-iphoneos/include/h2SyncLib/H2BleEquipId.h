//
//  TransferService.h
//  h2Ble
//
//  Created by h2Sync on 2015/1/20.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//


#define SM_BLE_ACCUCHEK_AVIVA_CONNECT                                   0x8010
#define SM_CARESENS_EXT_A_HMD_GL_BLE_EX                                 0x803A
#define SM_BLE_CARESENS_EXT_B_FORA                                               0x803B
#define SM_BLE_CARESENS_EXT_B_FORA_TAIDOC                               0x813B


//#define SM_BLE_OMNIS_EXT_3_APEXBIO                                      0x8093

//#define SM_BLE_OMNIS_EXT_3_BTM                              0x8193
#define SM_BLE_CARESENS_EXT_C_BTM                                       0x803C

#define SM_BLE_BGM_TRUE_METRIX                                          0x80A0
#define SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX                                  0x010680A1


// NEW EQUIPMENT ID

// BP, BG, Multi-USER, PAIR
//#define SM_BLE_CARESENS_EXT_B_FORA_D40                                  0x0312803B
// BW, Multi-USER, PAIR
//#define SM_BLE_CARESENS_EXT_B_FORA_W310B                                0x0412803C

// BP, BG, Multi-USER, No Pair Dialog
#define SM_BLE_CARESENS_EXT_B_FORA_D40                                  0x0310803B

// BW, Multi-USER, No Pair Dialog
#define SM_BLE_CARESENS_EXT_B_FORA_W310B                                0x0410803C

// BP, 1-USER, No Pair Dialog
#define SM_BLE_CARESENS_EXT_B_FORA_P30PLUS                              0x0200803B

// BG, 1-USER, No Pair Dialog
#define SM_BLE_CARESENS_EXT_B_FORA_TNG                                  0x0100823B
#define SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE                           0x0100833B

// BP, Multi-USER, PAIR
#define SM_BLE_OMRON_HEM_7280T                                          0x021280B0

// BP, 1-USER, PAIR
#define SM_BLE_OMRON_HEM_7600T                                          0x020281B0

// BW, Multi-USER, PAIR
#define SM_BLE_OMRON_HBF_254C                                           0x041280B1
#define SM_BLE_OMRON_HBF_256T                                           0x041281B1

// BP,APP PIN, PAIR
//#define SM_BLE_ARKRAY_GT_1830                                           0x010A80B2
#define SM_BLE_ARKRAY_G_BLACK                                           0x010A80B2
#define SM_BLE_ARKRAY_NEO_ALPHA                                         0x010A81B2

// BP, PAIR
//#define SM_BLE_OMRON_HEM_9200T                                          0x020280B3
#define SM_BLE_OMRON_HEM_9200T                                          0x020680B3
#define SM_BLE_OMRON_HEM_6320T                                          0x020280B4

// BP, Multi-USER, PAIR
#define SM_BLE_OMRON_HEM_6324T                                          0x021281B4

// BG, Has Pairing Dialog, But No PIN,
// (Don't remove from ble device list)
#define SM_BLE_BGM_TYSON_HT100                                          0x010180A5
#define SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE                               0x010180A6
#define SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE                               0x010180A7

// BG, PIN And Pairing Dialog
//#define SM_BLE_ACCUCHEK_AVIVA_CONNECT                                   0x01078010
#define SM_BLE_ACCUCHEK_AVIVA_GUIDE                                         0x01078011
#define SM_BLE_ACCUCHEK_INSTANT                                             0x01078012

//#define SM_BLE_BGM_TRUE_METRIX                                          0x010780A0

// BG, Pairing Dialog
//#define SM_BLE_BIONIME_GM700SB                                          0x01008010
#define SM_BLE_BIONIME_GM700SB                                              0x01028040

#define SM_BLE_GARMIN                                                       0x08008041
#define SM_BLE_MICRO_LIFE                                                   0x02118048

#define SM_BLE_AND_UA_651BLE                                                0x020281B3
#define SM_BLE_AND_UC_352BLE                                                0x040280C1


#import <CoreBluetooth/CoreBluetooth.h>

@interface H2BleEquipId : NSObject

@property (nonatomic, readwrite) NSMutableData *bleEquipBuffer;

+ (H2BleEquipId *)sharedEquipInstance;

@end

