//
//  H2BleGgm.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/9/25.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>


#define ACTION_CANCEL                                   0
#define ACTION_REFRESH                                  1
#define ACTION_ALL_RECORDS                              2
#define ACTION_FIRST_RECORD                             3
#define ACTION_LAST_RECORD                              4
#define ACTION_CLEAR                                    5
#define ACTION_DELETE_ALL                               6
#define ACTION_NUMBER_OF_RECORDS                        7
#define ACTION_GREATER_THAN                             8
#define ACTION_LESS_THAN                                9

#define AMOUNT_PER_SEGMENT                              30
#define AMOUNT_TOTAL_TYSON                              500


@interface H2BleBgm : NSObject
@property (readwrite) BOOL skipContext;
@property (readwrite) BOOL willFinished;

@property (readwrite) UInt8 command;

@property (readwrite) UInt16 recordIndex;
@property (readwrite) UInt16 recordTotal;

@property (readwrite) UInt16 readingIndex;

@property (readwrite) NSString *model;
@property (readwrite) NSString *version;
@property (readwrite) NSString *sn;

@property (readwrite) NSString *currentTime;
@property (readwrite) UInt16 number;
@property (readwrite) NSString *recordTime;
@property (readwrite) NSString *recordValue;

@property (readwrite) UInt8 apexDebug;

- (void)h2BleBgmWriteTask:(NSInteger)commandIndex;
- (void)bleBgmLoopCmdForTysonHT100;

- (void)h2BleBgmReportProcessTask:(CBCharacteristic *)characteristic;

+ (H2BleBgm *)sharedInstance;
@end

