//
//  BleEquipViewController.h
//  SQX
//
//  Created by h2Sync on 2016/2/2.
//  Copyright © 2016年 h2Sync. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface BleGateViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, retain) NSArray *bgmsName;
@property (nonatomic, retain) NSArray *bgmsSerialNumber;


- (id)init:(NSMutableArray *)bleDevices;


+ (BleGateViewController *)sharedInstance;

@end

