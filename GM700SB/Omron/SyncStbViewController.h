//
//  STBViewController.h
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
// 

#import <UIKit/UIKit.h>

//#import "MarqueeLabel.h"

@interface SyncStbViewController : UIViewController<UIAlertViewDelegate>

@property(strong, nonatomic) UILabel *labelCableStatus;
- (void)stbViewSetIndex:(NSString *)index;

+ (SyncStbViewController *)sharedInstance;
@end


// [STBViewController sharedInstance] stbViewSetIndex:(NSString *)index;
