//
//  ROConfirm.h
//  h2SyncLib
//
//  Created by JasonChuang on 13/8/28.
//
//

#define RELION_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "h2BrandModel.h"
#import "h2CmdInfo.h"
#import "h2MeterRecordInfo.h"

@class H2BgRecord;


@interface ReliOnConfirm : NSObject

@property (readwrite) Byte* reliOnCmdBuffer;
@property (readwrite) UInt16 reliOnCmdLength;
@property (readwrite) UInt16 reliOnCmdType;

@property (readwrite) UInt16 reliOnCmdIndex;
@property (readwrite) BOOL reliOnDataStart;


- (void)ReliOnCommandGeneral:(UInt16)cmdMethod;
- (void)ReliOnReadRecord:(UInt16)nIndex;

- (void)ReliOnCommandLoop;


- (UInt16)reliOnNumberOfParser;
- (H2MeterSystemInfo *)reliOnConfirmCurrentTimeParser;

- (NSString *)reliOnConfirmModelParser;
- (NSString *)reliOnConfirmSNParser;

- (H2BgRecord *)reliOnConfirmDateTimeValueParser;

+ (ReliOnConfirm *)sharedInstance;
// ReliOnCommandLoop
// reliOnCmdBuffer
// reliOnCmdIndex
@end




