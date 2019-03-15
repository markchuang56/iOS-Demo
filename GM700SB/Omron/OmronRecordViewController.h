//
//  BGMRecordViewController.h
//  SQX
//
//  Created by h2Sync on 2016/1/26.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#define ROW_OMRON_BP                5
#define ROW_OMRON_BW                9



#import <UIKit/UIKit.h>

@interface OmronRecordViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)init;


+ (OmronRecordViewController *)sharedInstance;
@end

