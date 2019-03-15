//
//  bleDEVViewController.h
//  SQX
//
//  Created by h2Sync on 2016/1/26.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolCableTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (id)init:(NSMutableArray *)toolCables;

+ (ToolCableTableViewController *)sharedInstance;
@end

