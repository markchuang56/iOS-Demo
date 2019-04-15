//
//  AllianceDSA.h
//  h2SyncLib
//
//  Created by Jason Chuang on 2018/8/28.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#define DSA_CMD_ST              'A'
#define DSA_CMD_LEN             7

#define OPC_DEV                 0xA1
#define OPC_FW                  0xA2
#define OPC_SN                  0xA3
#define OPC_UNIT                0xA6
#define OPC_DT                  0xA7
#define OPC_QTY                 0xA8
#define OPC_RIDX                0xA9

#define DALEN_DEV               7
#define DALEN_FW                7
#define DALEN_SN                19
#define DALEN_UNIT              5
#define DALEN_DT                9
#define DALEN_QTY               5
#define DALEN_RECORD            13

#define RD_OFFSET               4


#import <Foundation/Foundation.h>

@interface AllianceDSA : NSObject

- (void)allianceValueUpdate;
- (void)allianceCmdFlow:(UInt8)cmdMethod;

+ (AllianceDSA *)sharedInstance;

@end
