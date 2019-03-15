//
//  BleBGMViewController.h
//  SQX
//
//  Created by h2Sync on 2016/2/2.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface BleBGMViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, retain) NSArray *bgmsName;
@property (nonatomic, retain) NSArray *bgmsSerialNumber;


//@property (nonatomic, retain) NSString *bgmSerialNumber;
//@property (nonatomic, retain) NSString *bgmIdentifier;

- (id)init:(NSMutableArray *)bleDevices;

//- (void)initPeripheralsHasPaired;
+ (BleBGMViewController *)sharedInstance;

@end

