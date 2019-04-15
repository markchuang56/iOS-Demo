//
//  h2AudioSession.m
//
//  Created by JasonChuang on 14/11/25.
//



#import "H2AudioSession.h"
#import "H2DebugHeader.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


//#import <MediaPlayer/MediaPlayer.h>


#import "h2CmdInfo.h"

#import "H2Sync.h"
#import "H2AudioHelper.h"

// BLE
#import "H2BleEquipId.h"
#import "H2BleService.h"

#define AUDIO_MAXIMUM_VOLUME            1.0f
#define AUDIO_MINIMUM_VOLUME            0.3f

static float userVolumeLevel;

@interface H2AudioSession(){
@private
    MPMusicPlayerController *h2Player;
//    MPVolumeView *h2VolumeView;
    UISlider *h2VolumeViewSlider;
}

@end



#pragma mark -
#pragma mark H2AUDIOSESSION IMPLEMENTATION
@implementation H2AudioSession


- (id)init
{
    if (self = [super init]) {
#ifdef DEBUG_AUDIO
        DLog(@"AUDIO SESSION INIT ...");
#endif
        userVolumeLevel = AUDIO_MINIMUM_VOLUME;
        
        [[AVAudioSession sharedInstance] setActive: YES error:nil];
        
        [[AVAudioSession sharedInstance] addObserver:self
                                          forKeyPath:@"outputVolume"
                                             options:0
                                             context:nil];
        
        [h2Player beginGeneratingPlaybackNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(routeChanged:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        
        // system speaker icon hidden
//        _gh2VolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(60, 60, 200, 10)];
        _gh2VolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-80, -80, 200, 10)];
        
        
        
        [_gh2VolumeView setHidden:NO]; // 新加
        [_gh2VolumeView setUserInteractionEnabled:YES]; // 新加
        
        
        h2VolumeViewSlider = nil;

        [_gh2VolumeView setShowsVolumeSlider:YES];
        [_gh2VolumeView setShowsRouteButton:YES];
        [_gh2VolumeView sizeToFit];
        
        for (UIView *view in [_gh2VolumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                h2VolumeViewSlider = (UISlider *)view;
                break;
            }
        }
        
        //        [h2VolumeViewSlider setValue:0.3f animated:NO];
        [h2VolumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
#ifdef DEBUG_AUDIO        
        DLog(@"THE AUDIO VOLUME LEVEL IS %f", [h2VolumeViewSlider value]);
        
        if (MPVolumeSettingsAlertIsVisible()) {
            DLog(@"VOLUME ICON VISIBLE");
        }else{
            DLog(@"VOLUME ICON NOT VISIBLE");
        }
        
//        [[AVAudioSession sharedInstance] outputVolume];
//        DLog(@"AUDIO OUTPUT VOLUME IS %f", [[AVAudioSession sharedInstance] outputVolume]);
#endif
        
//        Float32 volume;
//        UInt32 dataSize = sizeof(Float32);
        
//        AudioSessionGetProperty (
//                                 kAudioSessionProperty_CurrentHardwareOutputVolume,
//                                 &dataSize,
//                                 &volume
 //                                );
        
    }
    return self;
}


+ (H2AudioSession *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO SESSION INSTANCE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

#pragma mark -
#pragma mark Audio Session Method

+ (BOOL)isHeadsetPluggedIn
{
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode : audio session code works only on a device
    return NO;
#else

    NSString *h2AudioRouteString;
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
//    DLog(@"AUDIO PLUG IN IS %d", [route outputs].count);
    for (AVAudioSessionPortDescription *desc in [route outputs]) {
#ifdef DEBUG_AUDIO
        DLog(@"AUDIO_SESSION_DEBUG %@ and %@, %@", [desc portType], AVAudioSessionPortHeadphones, AVAudioSessionPortBuiltInSpeaker);
#endif
        h2AudioRouteString = [desc portType];
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
        {
            [H2SyncSystemMessageInfo sharedInstance].syncInfoAudioStatus = h2AudioRouteString;
#ifdef DEBUG_AUDIO
            DLog(@"GET HEADSET AND --> ");
            DLog(@"DEFAULT VOLUME LEVEL %f", userVolumeLevel);
#endif
            return YES;
        }
    }
#ifdef DEBUG_AUDIO
    DLog(@"NO CABLE - ");
#endif
    return NO;
#endif
}



- (void)routeChanged:(id)sender {
#ifdef DEBUG_AUDIO
    DLog(@"SHOW ROUTE CHANGE +++++");

    if ([H2BleService sharedInstance].isBleCable) {
        DLog(@"HAS BLE CABLE");
    }
    if ([H2BleService sharedInstance].isBleEquipment) {
        DLog(@"HAS BLE VENDOR");
    }
    if ([H2BleService sharedInstance].blePairingStage) {
        DLog(@"PAIRING STAGE");
    }
#endif
    if(![H2AudioHelper sharedInstance].audioMode){
        return;
    }
    if (([H2BleService sharedInstance].isBleCable || [H2BleService sharedInstance].isBleEquipment || [H2BleService sharedInstance].blePairingStage)) {
        return;
    }
    if ([H2AudioHelper sharedInstance].audioMode) {
        BOOL cable;
        cable = [H2AudioSession isHeadsetPluggedIn];
        @autoreleasepool {
            if ([self.audioSessionDelegate conformsToProtocol:@protocol(H2AudioSessionDelegate)] &&
                [self.audioSessionDelegate respondsToSelector:@selector(h2ExistCable:)])  {
                [self.audioSessionDelegate h2ExistCable:cable];
            }
        }
    }
}

- (void)setVolumeLevelMax
{
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO SET MAX - %f", [h2VolumeViewSlider value]);
#endif
    if (![H2BleService sharedInstance].isAudioSyncFlow) {
        return;
    }
    if (!([H2BleService sharedInstance].isBleCable || [H2BleService sharedInstance].isBleEquipment || [H2BleService sharedInstance].blePairingStage)) {
        [h2VolumeViewSlider setValue:AUDIO_MAXIMUM_VOLUME animated:NO];
#ifdef DEBUG_AUDIO
        DLog(@"Set Max Volume %f", [h2VolumeViewSlider value]);
#endif
    }
}

- (void)setVolumeLevelMin
{
#ifdef DEBUG_AUDIO
    DLog(@"AUDIO SET MIN");
#endif
    //if (![H2BleService sharedInstance].isAudioSyncFlow) {
    //    return;
    //}
    
    if (([H2BleService sharedInstance].isBleCable || [H2BleService sharedInstance].isBleEquipment || [H2BleService sharedInstance].blePairingStage)) {
        return;
    }
    
    userVolumeLevel = AUDIO_MINIMUM_VOLUME;
    [h2VolumeViewSlider setValue:userVolumeLevel animated:NO];
    [self resetAudioSession];
    [H2Sync sharedInstance].isAudioCable = NO;
#ifdef DEBUG_AUDIO
    DLog(@"Set Min Volume %f", [h2VolumeViewSlider value]);
#endif
}

- (void)resetAudioSession
{
    _audioSessionDelegate = nil;
    [H2AudioHelper sharedInstance].audioMode = NO;
}

#pragma mark -
#pragma mark Audio Session Delegate
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqual:@"outputVolume"]) {
//        [h2VolumeViewSlider setValue:1.0f animated:NO];
        DLog(@"volume changed! %f", [h2VolumeViewSlider value]);
    }
    
    if(![H2AudioHelper sharedInstance].audioMode){
        [self setVolumeLevelMin];
    }
}


@end




