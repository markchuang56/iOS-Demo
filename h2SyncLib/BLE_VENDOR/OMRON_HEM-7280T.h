//
//  OMRON_HEM-7280T.h
//  h2LibAPX
//
//  Created by h2Sync on 2016/8/16.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#define BP_SMALL_LOC                    6
#define BP_BIG_LOC                      7
#define BP_YEAR_LOC                     8
#define BP_HR_LOC                       9

#define BP_MONDAY_LOC                   10
#define BP_DAYHOUR_LOC                  11

#define BP_MINUTE_LOC                   12
#define BP_SECOND_LOC                   13

#define BP_SYSTOLIC_OFFSET                      25//0x0F

#define BP_RECORD_OFFSET                        6
#define BP_RECORD_LEN                           14




#import <Foundation/Foundation.h>
#import "H2Omron.h"

@interface OMRON_HEM_7280T : NSObject
{
    
}


- (void)h2OmronHem7280TDataProcess;

- (void)OMRON_Hem7280T_GetRecordInit;
// Start : form 1
- (void)OmronHem7280TSetUserId:(UInt8)userId;

- (void)h2OmronHem7280TA1CmdFlow;

+ (OMRON_HEM_7280T *)sharedInstance;

@end





