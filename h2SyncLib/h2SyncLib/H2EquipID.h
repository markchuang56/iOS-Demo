//
//  H2EquipID.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/12/13.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef H2EquipID_h
#define H2EquipID_h

#if 0
H2SSDKDevlopStatusSwitchOn = 0x81,
H2SSDKDevlopStatusSwitchOff,
H2SSDKDevlopStatusUart,
H2SSDKDevlopStatusAuxility,
H2SSDKDevlopStatusExisting,
H2SSDKDevlopStatusFwVersion,
H2SSDKDevlopStatusAck,
H2SSDKDevlopStatus_8,
H2SSDKDevlopStatus_9,
H2SSDKDevlopStatusSnAudio,
H2SSDKDevlopStatusSnBle,
#endif


//CBATTErrorInsufficientAuthentication
/************************************************
 * OAD STATUS
 *
 ***********************************************/
// Synchronous status
#if 1
#define OAD_FINISHED                                0x0A    // oad succeed
#define OAD_OLD_IMAGE                               0x1A    // not new image
#define OAD_UPDATE_STOP                             0x2A  // Canncel update from APP
#define OAD_UPDATE_BUSY                             0x4A
#define OAD_UPDATE_FAIL                             0x8A  //

#define FAIL_OAD_NOT_FOUND                          0x89 // NO BLE device have found
#define FAIL_OAD_PHONE_OFF                          0xC9 // iPhone BT not turn ON
#endif


#define SM_ACCUCHEK_AVIVA                                           0x0010
#define SM_ACCUCHEK_AVIVANANO                               0x0011
#define SM_ACCUCHEK_NANO                                        0x0012
#define SM_ACCUCHEK_PERFOMA                                 0x0013

#define SM_ACCUCHEK_PERFOMA_II                              0x0014
#define SM_ACCUCHEK_EXT_5                   0x15
#define SM_ACCUCHEK_EXT_6                   0x16
#define SM_ACCUCHEK_EXT_7                   0x17

#define SM_ACCUCHEK_EXT_8                   0x18
#define SM_ACCUCHEK_EXT_9                   0x19

#define SM_ACCUCHEK_COMPACTPLUS                             0x001A
#define SM_ACCUCHEK_ACTIVE                                              0x001B
#define SM_ACCUCHEK_EXT_C                                   0x1C
#define SM_ACCUCHEK_EXT_D                                    0x1D
#define SM_ACCUCHEK_EXT_E                                   0x1E
#define SM_ACCUCHEK_EXT_F                                   0x1F



#define SM_BAYER_BREEZE2                                    0x0020
#define SM_BAYER_CONTOUR                                    0x0021
#define SM_BAYER_CONTOURNEXTEZ                          0x0022
#define SM_BAYER_CONTOURXT                                  0x0023
#define SM_BAYER_TS                                             0x0024
#define SM_BAYER_PLUS                                       0x0025
#define SM_BAYER_EXT_6                                  0x0026
#define SM_BAYER_EXT_0126                           0x0126
#define SM_BAYER_EXT_0226                           0x0226
#define SM_BAYER_EXT_0336                       0x0326
#define SM_BAYER_EXT_7                              0x0027

#define SM_BAYER_EXT_8                      0x0028
#define SM_BAYER_EXT_9                      0x0029
#define SM_BAYER_EXT_A                      0x002A
#define SM_BAYER_EXT_B                      0x002B
#define SM_BAYER_EXT_C                      0x002C
#define SM_BAYER_EXT_D                      0x002D
#define SM_BAYER_EXT_E                      0x002E
#define SM_BAYER_EXT_F                      0x002F


#define SM_CARESENS_ISENSN                  0x0030
#define SM_CARESENS_ISENSNPOP               0x0031
#define SM_CARESENS_EXT_2                   0x0032
#define SM_CARESENS_EXT_3                   0x0033
#define SM_CARESENS_EXT_4                   0x0034
#define SM_CARESENS_EXT_5                   0x0035
#define SM_CARESENS_EXT_6                   0x0036
//#define SM_CARESENS_EXT_7                   0x37
#define SM_CARESENS_EXT_7_TB200             0x0037

#define SM_CARESENS_EXT_8_EMBRACE_PRO                   0x0038

#define SM_CARESENS_EXT_9_BIONIME                               0x39
#define SM_CARESENS_EXT_9_BIONIME_GE100                 0x0039
#define SM_CARESENS_EXT_9_BIONIME_GM550                 0x0139
#define SM_CARESENS_EXT_9_BIONIME_GM700S                0x0239

#define SM_CARESENS_EXT_A_HMD_GL                        0x003A
#define SM_CARESENS_EXT_A_HMD_GL_BLE                    0x803A

//#define SM_CARESENS_EXT_B                   0x3B
#define SM_CARESENS_EXT_B_FORA_GD40A                           0x003B

#define SM_CARESENS_EXT_C_DSA                           0x3C
#define SM_CARESENS_EXT_D                   0x3D
#define SM_CARESENS_EXT_E                   0x3E
#define SM_CARESENS_EXT_F                   0x3F


#define SM_FREESTYLE_FREEDOMLITE           0x0040
#define SM_FREESTYLE_LITE                  0x0041
#define SM_FREESTYLE_EXT_2                  0x42
#define SM_FREESTYLE_EXT_3                  0x43
#define SM_FREESTYLE_EXT_4                  0x44
#define SM_FREESTYLE_EXT_5                  0x45
#define SM_FREESTYLE_EXT_6                  0x46
#define SM_FREESTYLE_EXT_7                  0x47

#define SM_FREESTYLE_EXT_8                  0x48
#define SM_FREESTYLE_EXT_9                  0x49
#define SM_FREESTYLE_EXT_A                  0x4A
#define SM_FREESTYLE_EXT_B                  0x4B
#define SM_FREESTYLE_EXT_C                  0x4C
#define SM_FREESTYLE_EXT_D                  0x4D
#define SM_FREESTYLE_EXT_E                  0x4E
#define SM_FREESTYLE_EXT_F                  0x4F


#define SM_GLUCOCARD_01                    0x0050
#define SM_GLUCOCARD_VITAL                 0x0051
#define SM_GLUCOCARD_EXT_2                 0x52
#define SM_GLUCOCARD_EXT_3                 0x53
#define SM_GLUCOCARD_EXT_4                 0x54
#define SM_GLUCOCARD_EXT_5                 0x55
#define SM_GLUCOCARD_EXT_6                 0x56
#define SM_GLUCOCARD_EXT_7                 0x57

#define SM_GLUCOCARD_EXT_8                 0x58
#define SM_GLUCOCARD_EXT_9                 0x59
#define SM_GLUCOCARD_EXT_A                 0x5A
#define SM_GLUCOCARD_EXT_B                 0x5B
#define SM_GLUCOCARD_EXT_C                 0x5C
#define SM_GLUCOCARD_EXT_D                 0x5D
#define SM_GLUCOCARD_EXT_E                 0x5E
#define SM_GLUCOCARD_EXT_F                 0x5F



#define SM_ONETOUCH_ULTRA2                  0x0060
#define SM_ONETOUCH_ULTRA_                  0x0160
#define SM_ONETOUCH_ULTRAEASY               0x0061
#define SM_ONETOUCH_ULTRALIN                0x0062
#define SM_ONETOUCH_ULTRAMINI               0x0063
#define SM_ONETOUCH_ULTRA_VUE               0x006A

#define SM_ONETOUCH_EXT_4              0x64
#define SM_ONETOUCH_EXT_5              0x65
#define SM_ONETOUCH_EXT_6              0x66
#define SM_ONETOUCH_EXT_7              0x67

#define SM_ONETOUCH_EXT_8              0x68
#define SM_ONETOUCH_EXT_9              0x69
#define SM_ONETOUCH_EXT_A              0x6A
#define SM_ONETOUCH_EXT_B              0x6B
#define SM_ONETOUCH_EXT_C              0x6C
#define SM_ONETOUCH_EXT_D              0x6D
#define SM_ONETOUCH_EXT_E              0x6E
#define SM_ONETOUCH_EXT_F              0x6F



#define SM_RELION_CONFIRM                       0x0070
#define SM_RELION_PRIME                         0x0071
#define SM_RELION_EXT_2                   0x72
#define SM_RELION_EXT_3                   0x73
#define SM_RELION_EXT_4                   0x74
#define SM_RELION_EXT_5                   0x75
#define SM_RELION_EXT_6                   0x76
#define SM_RELION_EXT_7                   0x77

#define SM_RELION_EXT_8                   0x78
#define SM_RELION_EXT_9                   0x79
#define SM_RELION_EXT_A                   0x7A
#define SM_RELION_EXT_B                   0x7B
#define SM_RELION_EXT_C                   0x7C
#define SM_RELION_EXT_D                   0x7D
#define SM_RELION_EXT_E                   0x7E
#define SM_RELION_EXT_F                   0x7F



#define SM_BENECHEK_PLUS_JET                    0x0080
#define SM_BENECHEK_PT_GAMA                     0x0081
#define SM_BENECHEK_EXT_2                 0x82
#define SM_BENECHEK_EXT_3                 0x83
#define SM_BENECHEK_EXT_4                 0x84
#define SM_BENECHEK_EXT_5                 0x85
#define SM_BENECHEK_EXT_6                 0x86
#define SM_BENECHEK_EXT_7                 0x87

#define SM_BENECHEK_EXT_8                 0x88
#define SM_BENECHEK_EXT_9                 0x89
#define SM_BENECHEK_EXT_A                 0x8A
#define SM_BENECHEK_EXT_B                 0x8B
#define SM_BENECHEK_EXT_C                 0x8C
#define SM_BENECHEK_EXT_D                 0x8D
#define SM_BENECHEK_EXT_E                 0x8E
#define SM_BENECHEK_EXT_F                 0x8F



#define SM_OMNIS_EMBRACE                                0x0090
#define SM_OMNIS_EMBRACE_EVO                            0x0091
#define SM_EVENCARE_G2                                  0x0092
#define SM_GLUCOSURE_VIVO                               0x0093
#define SM_EVENCARE_G3                                  0x0094
#define SM_OMNIS_AUTOCODE                               0x0095
#define SM_EXT_OMNIS6                               0x96
#define SM_Embrace_TOTAL                            0x97
//#define SM_EXT_OMNIS_8                                  0x0098
#define SM_APEX_BG001_C                                  0x0098
#define SM_APEX_BGM014                                      0x0198

#define SM_EXT_OMNIS_9                            0x99
#define SM_EXT_OMNIS_A                            0x9A
#define SM_EXT_OMNIS_B                            0x9B
#define SM_EXT_OMNIS_C                            0x9C
#define SM_EXT_OMNIS_D                            0x9D
#define SM_EXT_OMNIS_E                            0x9E
#define SM_EXT_OMNIS_F                            0x9F

#endif /* H2EquipID_h */
