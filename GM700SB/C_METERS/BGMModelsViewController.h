//
//  syMetersViewController.h
//  tabH2
//
//  Created by JasonChuang on 13/10/19.
//  Copyright (c) 2013年 JasonChuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "H2Sync.h"


@interface BGMModelsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (id)init:(NSMutableArray *)models withIdBrand:(NSInteger)idBrand;


@end
