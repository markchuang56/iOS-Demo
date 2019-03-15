//
//  STBViewController.h
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MarqueeLabel.h"

@interface STBViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic, strong) NSString *statusTemp;

@property (nonatomic, strong) IBOutlet MarqueeLabel *demoLabel1;

- (void)autoShowBlePairing;

- (void)stbViewSetIndex:(NSString *)indexRecord withIndexLoop:(UInt16)indexLoop;
- (void)h2ShowLongRunStatus:(BOOL)finished;

- (void)showBlePeripheralAfterPairing;

- (void)h2ClearCableStatus;

+ (STBViewController *)sharedInstance;
@end
