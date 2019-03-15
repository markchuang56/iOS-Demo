//
//  SyncMessageViewController.h
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncMessageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)init:(NSMutableArray *)msg;
+ (SyncMessageViewController *)sharedInstance;

@end
