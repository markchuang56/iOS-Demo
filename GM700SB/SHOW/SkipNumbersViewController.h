//
//  SkipNumbersViewController.h
//  FR_W310B
//
//  Created by h2Sync on 2018/1/9.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#define SKIP_ROW_NUMBER 3

@class RecordsHaveBeenSkip;
#import <UIKit/UIKit.h>


@interface SkipNumbersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

//@property(nonatomic, strong) RecordsHaveBeenSkip *numbers;

+ (SkipNumbersViewController *)sharedInstance;

@end
