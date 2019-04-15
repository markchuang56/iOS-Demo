//
//  OmnisEmbracePro.h
//  h2SyncLib
//
//  Created by h2Sync on 2014/2/17.
//
//

#define EMBRACEPRO_RESEND_INTERVAL       3.0f

#import <Foundation/Foundation.h>
#import "H2BrandModel.h"
#import "h2CmdInfo.h"

@class H2BgRecord;

@interface OmnisEmbracePro : NSObject

- (void)EmbraceProCommandGeneral:(UInt16)cmdMethod;
- (void)EmbraceProReadRecord:(UInt16)nIndex;



- (UInt16)omnisEmbraceProNumberOfRecordParser;
- (H2BgRecord *)omnisEmbraceProDateTimeValueParser;

- (BOOL)omnisEmbraceProSerialNumberParser;

+ (OmnisEmbracePro *)sharedInstance;
@end


