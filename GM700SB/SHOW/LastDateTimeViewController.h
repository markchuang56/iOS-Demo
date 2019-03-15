//
//  LastDateTimeViewController.h
//  FR_W310B
//
//  Created by h2Sync on 2017/10/25.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LDT_ROW_NUMBER              (9-3)

@interface LastDateTimeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)init:(BOOL)isNewLdt;
+ (LastDateTimeViewController *)sharedInstance;

@end
