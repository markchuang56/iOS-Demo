//
//  AudioFacade.h
//
//  Created by JasonChuang on 9/12/12.
//

//#define __H2_DEBUG__

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

//Define the protocol for the delegate
@protocol H2AudioFacadeDelegate <NSObject>

- (void)receiveAudioData:(UInt8)ch;

@end

@interface H2AudioFacade : NSObject

@property(nonatomic, strong) NSObject<H2AudioFacadeDelegate> *delegate;

// TODO: test purpose only, should be REMOVED
@property(readwrite) BOOL sampling;
@property(readwrite) BOOL powering;
@property(readwrite) float rightDivider;

// ALWAYS call this to obtain an AudioFacade instance
+ (H2AudioFacade *)sharedInstance;
// Return TRUE if it's successful, check error if it's not
- (BOOL)audioStart:(NSError **)error;

- (BOOL)isRunning;
//- (BOOL)send:(const UInt8 *)data bytes:(NSInteger)count;
- (NSInteger)bytesInQueue;
- (BOOL)audioStop;


- (BOOL)sendCommandDataEx:(unsigned char *)cmdSrc withCmdLength:(UInt16)cmdLength cmdType :(UInt16)type
returnDataLength:(UInt8)returnLength mcuBufferOffSetAt:(UInt8)mcuBufferAt;

- (BOOL)h2AudioTriggerCommand;

- (BOOL)h2ResendSystemCommand;
- (BOOL)h2ResendMeterCommand;
- (BOOL)h2SendMeterPreCommand;

- (BOOL)commandStop;
- (BOOL)isAudioBusy;


@end


