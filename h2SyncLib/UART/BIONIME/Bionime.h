//
//  Bionime.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/5/28.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//


#define BM_CMD_HEADER                           0xB0
#define BM_RT_HEADER                            0x4F

#define BM_CMD_ID_QMODEL                        0x00
#define BM_CMD_ID_QFWVER                        0x01
#define BM_CMD_ID_G_S_DATE_TIME_UNIT            0x06
#define BM_CMD_ID_RECORD                        0x07
#define BM_CMD_ID_QSN                           0x18


#define BM_CMD_ID_G_S_WRITE_EN                  0x08


#define BM_RT_ID_QMODEL                         0xFF
#define BM_RT_ID_QFWVER                         0xFE
#define BM_RT_ID_G_S_DATE_TIME_UNIT             0xF9
#define BM_RT_ID_RECORD                         0xF8
#define BM_RT_ID_QSN                            0xE7


#define BM_CMD_LEN_QMODEL                       3
#define BM_CMD_LEN_QFWVER                       3
#define BM_CMD_LEN_G_S_DATE_TIME_UNIT           9
#define BM_CMD_LEN_RECORD                       5
#define BM_CMD_LEN_QSN                          3

#define BM_RT_LEN_QMODEL                        8
#define BM_RT_LEN_QFWVER                        7
#define BM_RT_LEN_G_S_DATE_TIME_UNIT            9
#define BM_RT_LEN_RECORD                        11
#define BM_RT_LEN_QSN                           (4+30)

#pragma mark - BIONIME ELSE DEFINE

#define BM_BIT_WR_RD                            0x08


#define BM_UINT_ADDR_UNIT                            2
#define BM_UINT_ADDR_YEAR                            3
#define BM_UINT_ADDR_MON                             4
#define BM_UINT_ADDR_DAY                             5
#define BM_UINT_ADDR_HOUR                            6
#define BM_UINT_ADDR_MIN                             7



#define BM_UNIT_BIT_WR_RD                           (1<<3)
#define BM_UNIT_BIT_12H                             (1<<2)
#define BM_UNIT_BIT_MMOL                            (1<<1)
#define BM_UNIT_BIT_FIXUNIT                         (1<<0)

/*************************************************************
* YEAR Description:
* Value Range: 0x00 ~ 0x63, Means 2000 ~ 2099.
* MON Description:
* Value Rannge: 0x00 ~ 0x0B, Means Jan.~Dec.
* DAY Description:
* Value Range: 0x00~0x1E, Means 1~31
* HOUR Description:
* Value Range: 0x00~0x17, Means 0~23 hour.
* MIN Description
* Value Range: 0x00 ~0x3B, Means 0~59 Minutes.
*/

#define BM_RECORD_ADDR_IND_L                            2
#define BM_RECORD_ADDR_IND_H                            3
#define BM_RECORD_ADDR_DA_0                             4
#define BM_RECORD_ADDR_DA_1                             5
#define BM_RECORD_ADDR_DA_2                             6
#define BM_RECORD_ADDR_DA_3                             7
#define BM_RECORD_ADDR_DA_4                             8
#define BM_RECORD_ADDR_DA_5                             9


#pragma mark - TOTAL AMOUNT RECORD
/******************************************
*
* Total amount of blood glucose records (low bits).
* Ex.: Total Amount = (DA_1 << 8) + DA_0
*/
#define BM_T_AMOUNT_ADDR_DA_0                             4
#define BM_T_AMOUNT_ADDR_DA_1                             5
/*******************************************************************************
* Maximum amount of blood glucose records that can be stored in meter (low bits).
* Ex.: Max. Amount = (DA_3 << 8 )+ DA_2
*/
#define BM_M_AMOUNT_ADDR_DA_2                             6
#define BM_M_AMOUNT_ADDR_DA_3                             7

#pragma mark - RECORD DECODE DEFINITION
/*******************************************************************************
* DA_0 Description: Bit Description
* 7:6
* Month (low bit).
* Value Range: 0~11, Means Jan. ~ Dec.
* Ex.: Month = (DA_1 & 0xC0) >> 4 + (DA_0 & 0xC0) >> 6 + 1
* 5
* Reserved
* 4:0
* Day.
* Value Range: 0~31, Means day1~day31.
* Ex.: Day = DA_0 & 0x1F + 1
*/
#define MONTH_MASK                              0xC0
#define MONTH_BIT_SHIFT_LO                      6
#define MONTH_BIT_SHIFT_HI                      4

#define DAY_MASK                                0x1F

/*********************************************************************************
* DA_1 Description: Bit Description
* 7:6
* Month (high bit).
* Value Range: 0~11, Means Jan.~ Dec.
*
* Ex.: Month = (DA_1 & 0xC0) >> 4 + (DA_0 & 0xC0) >> 6 + 1
* 5
* Reserved
* 4:0
* Hour (24-hours).
* Value Range: 0-23, means 00:00 to 23:00.
* Ex.: Hour = DA_1 & 0x1F
*/
#define HOUR_MASK                                   0x1F

/*****************************************************************
* DA_2 Description: Bit Description
* 7
* CNT_H
* The high bit of sequence count.
* Sequence count will count from 0 to 7, and then repeat again.
* Ex.: Seq. Count = (DA_2 & 0x80) >> 5 + (DA_4 & 0xC0) >> 6
* 6
* Reserved
* 5:0
* Minute.
* Range: 0~59, Means 0~59 minutes.
*Ex.: Minute = DA_2 & 0x3F
*/
#define MIN_MASK                                    0x3F

/******************************************************************
* DA_3 Description: Bit Description
* 7
* Hi Flag
* 1: Record was marked as “Hi”( Over 600 mg/dL)
* 0: Normal record
* 6:0
* The last 2 digits of year.
* Range: 0~99; Means 2000~ 2099 (DEX)
* Ex: Year = DA_3 & 0x7F + 2000
*/
#define VALUE_HI_FLAG_MASK                         0x80
#define YEAR_MASK                                   0x7F

#define CTRL_SOLUTION_MASK                                   (1<<2)
#define VALUE_HI_MASK                                   (0x03)
/*******************************************************************
* DA_4 Description: Bit Description
* 7:6
* CNT_M & CNT_L
* The medium & low bits of sequence count.
* Sequence count will count from 0 to 7, and then repeat again.
* Ex.: Seq. Count = (DA_2 & 0x80) >> 5 + (DA_4 & 0xC0) >> 6
* 5
* Please check Bit 3 description.
* 4
* The flag of out of acceptable temperature range.
*
* 1: out of the acceptable range.
* 0: within the range.
* 3
* Please combine Bit 3 & 5 for deciding which marker was used. More detail description please see below:
* .
* Bit3
* Bit 5
* Description
* 0
* 0
* Add to average calculation(AVG)
* 0
* 1
* NOT add to average calculation(NO AVG)
* 1
* 0
* Before meal
* 1
* 1
* After meal
* 2
* The flag for mark control solution measurement.
* 1: Use Control solution test.
* 0: Normal blood glucose test
* 1:0
* Blood glucose value (High bits, Bit 9:8).
* Ex: Glucose Value = (DA_4 & 0x03) << 8 + DA_5
*/

/*******************************************************************
* DA_5 Description: Bit Description
* 7:0
* Blood glucose value (Low bits, Bit 7:0).
* Ex: Glucose Value = (DA_4 & 0x03) << 8 + DA_5
*/

#define VALUE_BIT_HI_MASK                           0x03
#define VALUE_BIT_HI_SHIFT                          8

// Support SN mode and fw ver.
// GM550 B10, B21, B25

#define BIONIME_RESEND_INTERVAL                     3.0f

#define BIONIME_GM550                       (@"GM550")
#define BIONIME_GM550_B010                  (@"B010")
#define BIONIME_GM550_B021                  (@"B021")
#define BIONIME_GM550_B025                  (@"B025")

#import <Foundation/Foundation.h>


@class H2BgRecord;

@interface Bionime : NSObject

@property(readwrite) BOOL bmIsUnitMmol;
@property(readwrite) UInt8 bmSerialNrReturnLen;
@property(nonatomic, strong) NSString *bmUnitString;

@property(readwrite) UInt8 bmCommandAndUnit;


- (void)BionimeCommandGeneral:(UInt16)cmdMethod;

- (void)BionimeReadRecord:(UInt16)nIndex;

- (void)BionimeSerialNrLenParser;

- (NSString *)BionimeModelVerSerialNrParser;
- (NSString *)BionimeCurrentDateTimeUnitParser;


- (UInt16)BionimeTotalRecordParser;


- (H2BgRecord *)BionimeDateTimeValueParser;


+ (Bionime *)sharedInstance;
@end


