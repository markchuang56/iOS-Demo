//
//  H2ReportViewController.h
//  H2DemoBT
//
//  Created by h2Sync on 2015/10/17.
//  Copyright © 2015年 JasonChuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface H2ReportViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>


//@property (strong, nonatomic) NSString *qrString;

- (id)init:(NSString *)qrCode;

+ (H2ReportViewController *)sharedInstance;
@end

