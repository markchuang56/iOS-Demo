//
//  ViewController.h
//  SQX
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#define HBF_YEAR                0x0E
#define HBF_MON                 0x0F
#define HBF_DAY                 0x10
#define HBF_HOUR                0x11
#define HBF_MIN                 0x12
#define HBF_SEC                 0x13

#define HBF_CRC                 0x15


#import "h2MeterRecordInfo.h"
#import "H2Sync.h"
#import "ScannedPeripheral.h"
#import <UIKit/UIKit.h>

#import "MarqueeLabel.h"

@interface SQXViewController : UIViewController //<H2SyncDelegate>



@property (weak, nonatomic) IBOutlet UILabel *currentMeterId;
@property (weak, nonatomic) IBOutlet UILabel *currentQrOrMeterSn;

@property (nonatomic, weak) IBOutlet MarqueeLabel *demoLabelX;


- (IBAction)sqxMeterTask:(id)sender;
- (IBAction)sqxQRCodeForCable:(id)sender;
- (IBAction)sqxBleMeters:(id)sender;
- (IBAction)sqxCableMeters:(id)sender;
- (IBAction)sqxPageTest:(id)sender;


+ (SQXViewController *)sharedInstance;
@end

