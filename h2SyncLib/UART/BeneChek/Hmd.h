//
//  Hmd.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/10/20.
//  Copyright © 2015年 h2Sync. All rights reserved.
//

#define HMD_BUFFER_LONG_LEN         64
#define HMD_BUFFER_SHORT_LEN        16

#import <Foundation/Foundation.h>

#import "h2BrandModel.h"

@class H2BgRecord;

@interface Hmd : NSObject

//@property(readwrite) BOOL bmIsUnitMmol;
//@property(readwrite) UInt8 bmSerialNrReturnLen;
//@property(nonatomic, strong) NSString *bmUnitString;

@property(readwrite) UInt8 hmdProductYear;
@property(readwrite) UInt8 hmdModel;


- (void)HmdCommandGeneral:(UInt16)cmdMethod;
- (void)HmdReadRecord:(UInt16)nIndex;
- (void)HmdRecordAck:(UInt16)nIndex;





- (NSString *)HmdModelVerSerialNrParser;

- (NSString *)HmdCurrentDateTimeParser;

- (NSString *)HmdModelParser;
- (NSString *)HmdSerialNrParser;
- (UInt16)HmdTotalRecordNumberParser;


- (H2BgRecord *)HmdDateTimeValueParser;


+ (Hmd *)sharedInstance;




@end
