//
//  OMRON_HBF-254C.h
//  h2LibAPX
//
//  Created by h2Sync on 2016/8/16.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


// G BLACK SERVICE
// UUID = 040F9E5C-A38E-4F10-B44C-71C3E8B5477B>
/*
Advertisement DATA is  {
    kCBAdvDataIsConnectable = 1;
    kCBAdvDataLocalName = "GT-1830";
    kCBAdvDataServiceUUIDs =     (
                                  "040F9E5C-A38E-4F10-B44C-71C3E8B5477B"
                                  );
}
*/

// Report characteristic
// 0x2A4D

#pragma mark - OMRON_HBF_254C BT 4.0 UUID STRING

#define BW_RECORD_EX                            14
#define BW_RECORD_OFFSET                        6

#define HBF254C_RECORD_LENGTH                   32


#import <Foundation/Foundation.h>

@interface OMRON_HBF_254C : NSObject
{
    
}

@property (nonatomic, strong) NSMutableData *hbfRecordDataArray;


// PARSER
- (void)hbf254CCurrentTimeParser;
- (void)hbf254CUserProfileParser;

- (void)h2OmronHbf254CDataProcess;

- (void)OMRON_Hbf254C_GetRecordInit;
- (void)h2OmronHbf254CA1CmdFlow;
- (void)hbfA1SetUserProfile:(UInt8)userId;

+ (OMRON_HBF_254C *)sharedInstance;


@end
