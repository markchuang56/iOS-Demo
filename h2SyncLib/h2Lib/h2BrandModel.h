//
//  h2BrandModel.h
//  h2SyncLib
//
//  Created by h2Sync on 2014/7/9.
//  Copyright (c) 2014年 h2Sync. All rights reserved.
//

#ifndef _H2BRANDMODEL_
#define _H2BRANDMODEL_

#define CMD_HEADER_LEN          6
#define MODEL_METHOD_AT_0       0
#define BRAND_AT_1              1

#define BRAND_SYSTEM            0

#define BRAND_ACCUCHEK          1
#define BRAND_BAYER             2
#define BRAND_CARESENS          3
#define BRAND_FREESTYLE         4
#define BRAND_GLUCOCARD         5
#define BRAND_ONETOUCH          6
#define BRAND_RELION            7
#define BRAND_BENECHEK          8
#define BRAND_EXT_OMNIS             9

#define BRAND_EXT_A             0xA
#define BRAND_EXT_B             0xB
#define BRAND_EXT_C             0xC
#define BRAND_EXT_D             0xD
#define BRAND_EXT_E             0xE
#define BRAND_EXT_F             0xF
#define BRAND_EXT_10             0x10
#define BRAND_EXT_11             0x11
#define BRAND_EXT_12             0x12
#define BRAND_EXT_13             0x13
#define BRAND_EXT_14             0x14
#define BRAND_EXT_15             0x15


#pragma mark -
#pragma mark METER MODEL ID

#define MODEL_AVIVA                    0
#define MODEL_AVIVA_NANO               1
#define MODEL_NANO                     2
#define MODEL_PREFORMA                 3

#define MODEL_ACCU_CHEK_EX_4                 4
#define MODEL_ACCU_CHEK_EX_5                 5
#define MODEL_ACCU_CHEK_EX_6                 6
#define MODEL_ACCU_CHEK_EX_7                 7
#define MODEL_ACCU_CHEK_EX_8                 8
#define MODEL_ACCU_CHEK_EX_9                 9

#define MODEL_COMPACTPLUS                   0x0A
#define MODEL_ACTIVE                        0x0B
#define MODEL_ACCU_CHEK_EX_C                 0x0C
#define MODEL_ACCU_CHEK_EX_D                 0x0D
#define MODEL_ACCU_CHEK_EX_E                 0x0E
#define MODEL_ACCU_CHEK_EX_F                 0x0F



#define MODEL_BREEZE2                  0
/*
 #define MODEL_CONTOUR                  1
 #define SM_CONTOURNEXTEZ               2
 #define MODEL_CONTOURXT                3
 */

#define MODEL_CARESENS_N                0
#define MODEL_CARESENS_POP              1
#define MODEL_TYSON_TB200               7
#define MODEL_OMNIS_EMBRACE_PRO    		8
#define MODEL_BIONIME                   9
#define MODEL_HMD                       10
#define MODEL_FORA                      11
#define MODEL_ALLIANCE                  12

/*
 #define MODEL_FREESTYLE_FREEDOMLITE     0
 #define MODEL_FREESTYLE_LITE    		1
 
 
 #define MODEL_GLUCOCARD_01    			0
 #define MODEL_GLUCOCARD_VITAL    		1
 */
#define MODEL_ONETOUCH_ULTRA2    		0
#define MODEL_ONETOUCH_ULTRAEASY    	1
#define MODEL_ONETOUCH_ULTRALIN         2
#define MODEL_ONETOUCH_ULTRAMINI    	3

#define MODEL_ONETOUCH_EX_4    	4
#define MODEL_ONETOUCH_EX_5    	5
#define MODEL_ONETOUCH_EX_6    	6
#define MODEL_ONETOUCH_EX_7    	7

#define MODEL_ONETOUCH_EX_8    	8
#define MODEL_ONETOUCH_EX_9    	9
#define MODEL_ONETOUCH_EX_VUE    	10
#define MODEL_ONETOUCH_EX_B    	11
#define MODEL_ONETOUCH_EX_C    	12
#define MODEL_ONETOUCH_EX_D    	13
#define MODEL_ONETOUCH_EX_E    	14
#define MODEL_ONETOUCH_EX_F    	15





#pragma mark -
#pragma mark METER COMMAND METHOD ID


#define METHOD_INIT                 0
#define METHOD_NROFRECORD           1
#define METHOD_RECORD               2
#define METHOD_UNIT                 3
#define METHOD_4                    4
#define METHOD_5                    5
#define METHOD_6                    6
#define METHOD_ACK                  7
#define METHOD_ACK_RECORD           8
#define METHOD_END                  9
#define METHOD_BRAND                0x0A
#define METHOD_MODEL                0x0B
#define METHOD_SN                   0x0C
#define METHOD_DATE                 0x0D
#define METHOD_TIME                 0x0E
#define METHOD_VERSION                0x0F

#endif

#import <Foundation/Foundation.h>

@interface h2BrandModel : NSObject

@end
