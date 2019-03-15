//
//  BGMRecordViewController.h
//  SQX
//
//  Created by h2Sync on 2016/1/26.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#define BG_ROW_NUMBER           4
#define BP_ROW_NUMBER           7
#define BW_ROW_NUMBER           (6+2)

#import <UIKit/UIKit.h>

@interface BGMRecordsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)init;


+ (BGMRecordsViewController *)sharedInstance;
@end


@interface BPMRecordsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)init;


+ (BPMRecordsViewController *)sharedInstance;
@end


@interface BWMRecordsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)init;


+ (BWMRecordsViewController *)sharedInstance;
@end
