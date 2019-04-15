//
//  h2AudioSession.h
//
//  Created by JasonChuang on 14/11/25.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

//Define the protocol for the delegate
@protocol H2AudioSessionDelegate <NSObject>

@required


@optional
- (void)h2ExistCable:(BOOL)cable;
@end



@interface H2AudioSession : NSObject
{
//    BOOL recordeing;
}

@property(nonatomic, strong) NSObject<H2AudioSessionDelegate> *audioSessionDelegate;
@property (nonatomic, strong) MPVolumeView *gh2VolumeView;


+ (H2AudioSession *)sharedInstance;

+ (BOOL)isHeadsetPluggedIn;
- (void)routeChanged:(id)sender;
- (void)setVolumeLevelMax;
- (void)setVolumeLevelMin;
- (void)resetAudioSession;

@end



