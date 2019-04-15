//
//  H2iCareSensEventProcess.h
//  h2SyncLib
//
//  Created by h2Sync on 2015/8/15.
//  Copyright (c) 2015年 h2Sync. All rights reserved.
//

//#define ICARESENS_BLE_CMD_INTERVAL              0.02f
#define ICARESENS_AUDIO_CMD_INTERVAL            0.05f


#import <Foundation/Foundation.h>

@interface H2iCareSensEventProcess : NSObject

@property(readwrite) NSString *bionimeModel;
@property(readwrite) NSString *bionimeGM550Version;

@property(readwrite) UInt8 embraceProWriteSerialNumberCount;


@property(readwrite) BOOL didiCareSensSendGeneralCommand;
@property(readwrite) BOOL didiCareSensSendRecordCommand;

+ (H2iCareSensEventProcess *)sharedInstance;

- (void)h2CareSensInfoRecordProcess;

#pragma mark - CARESENSE N COMMAND
- (void)h2SyncCareSensNGeneral;
- (void)h2SyncCareSensNReadRecord;

#pragma mark - EXT_DEC OMNIS EMBRACE PRO
- (void)h2SyncEmbraceProGeneral;
- (void)h2SyncEmbraceProReadRecord;

#pragma mark -
#pragma mark - EXT_DEC -- BIONIME
- (void)h2SyncBionimeGeneral;
- (void)h2SyncBionimeReadRecord;


#pragma mark - HMD COMMAND
- (void)h2SyncHmdGeneral;
- (void)h2SyncHmdReadRecord;

- (void)h2SyncHmdRecordAck;


@end

//[H2iCareSensEventProcess sharedInstance] h2CareSensInfoRecordProcess
