//
//  QRScanViewController.m
//  H2DemoBT
//
//  Created by h2Sync on 2015/10/17.
//  Copyright © 2015年 JasonChuang. All rights reserved.
//

#import "QRCodeViewController.h"
#import "QRScanViewController.h"

//#import "H2ReportViewController.h"

#import "BleBgmPaired.h"
#import "LibDelegateFunc.h"

#import "sn_qrcode.h"

@interface QRScanViewController ()
@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

-(BOOL)startReading;
-(void)stopReading;

// Audio Section
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

-(void)loadBeepSound;
@end

@implementation QRScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadBeepSound];
    
//        if (_audioPlayer) {
//            NSLog(@"DID PLAY AUDIO ...");
//            [_audioPlayer play];
//        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isReading = NO;
    
    _captureSession = nil;
    
    [self loadBeepSound];
    
    // Custom initialization
    UINavigationBar *navBleBar = [[UINavigationBar alloc]
                                  initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self.view addSubview:navBleBar];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStylePlain
                                target:self action:@selector(qrScanPageBack:)];
    UINavigationItem *navItem = [[UINavigationItem alloc]
                                 initWithTitle:@"SCAN QR"];
    
    navItem.leftBarButtonItem = btnBack;
    [navBleBar pushNavigationItem:navItem animated:NO];
    
    //
    /*
     self.view.translatesAutoresizingMaskIntoConstraints = YES;
     
     __block CGRect frame = self.view.frame;
     frame.origin.x = 0;
     frame.origin.y = 67;
     frame.size.height = 280;
     frame.size.width = 350;
     
     [UIView animateWithDuration:0.5 animations:^{
     
     self.view.frame = frame;
     NSLog(@"H2 DEBUG 1");
     
     }completion:^(BOOL finished) {
     NSLog(@"H2 DEBUG 2");
     }];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SAMPLE CODE
- (IBAction)startStopReading:(id)sender {
    if (!_isReading) {
        if ([self startReading]) {
            [_bbitemStart setTitle:@"Stop"];
            [_lblStatus setText:@"Scanning for QR Code..."];
        }
    }
    else{
        [self stopReading];
        [_bbitemStart setTitle:@"Start!"];
        
//        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    _isReading = !_isReading;
}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    return YES;
}

#pragma mark - DELEGATE ...
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:YES];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
            
            NSString *snString;
            
            snString = _lblStatus.text;
            NSLog(@"DEMO DEBUG, WHAT WE HAVE GET %@", _lblStatus.text);
            
            [LibDelegateFunc sharedInstance].qrStringCode = _lblStatus.text;
//            [QRCodeViewController sharedInstance].lableQRString.text = _lblStatus.text;
            [[NSUserDefaults standardUserDefaults] setObject:_lblStatus.text forKey:@"UDEF_QR_CODE"];
            
            NSLog([[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"], nil);
            //    [_h2SyncViewController meterSelect:nil];
            // notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QRStringNotification" object:self];
            
            NSLog(@"QR SCANNED STRING IS %@", snString);
            [H2SerialNumber sharedInstance].stringBeScanned = [NSString stringWithFormat:@"%@", _lblStatus.text];
            
            // [LibDelegateFunc sharedInstance].qrStringCode = [NSString stringWithFormat:_lblStatus.text, nil];
            [LibDelegateFunc sharedInstance].qrStringCode = [NSString stringWithFormat:_lblStatus.text, nil];
            
            if (_audioPlayer) {
                [_audioPlayer play];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)scanEndAndPlayAudio
{
    if (_audioPlayer) {
        NSLog(@"DID PLAY AUDIO ...");
        [_audioPlayer play];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
// else if Power On State, then start scan


-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - AUDIO SECTION
-(void)loadBeepSound{
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        [_audioPlayer prepareToPlay];
    }
    
    // BACK ...
    NSLog(@"DEMO DEBUG DID COME TO play beep file.");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) qrScanPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (QRScanViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_APEXBIO
    NSLog(@"SN WRITE INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

@end



