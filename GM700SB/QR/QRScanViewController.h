//
//  QRScanViewController.h
//  H2DemoBT
//
//  Created by h2Sync on 2015/10/17.
//  Copyright © 2015年 JasonChuang. All rights reserved.
//


#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@interface QRScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bbitemStart;

@property (strong, nonatomic) NSString *qrString;


- (IBAction)startStopReading:(id)sender;

+ (QRScanViewController *)sharedInstance;

@end
