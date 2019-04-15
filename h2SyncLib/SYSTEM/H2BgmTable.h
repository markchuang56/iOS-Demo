//
//  H2BgmTable.h
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/11.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface H2BgmTable : NSObject


@property (nonatomic, retain) NSArray *h2BrandList;
@property (nonatomic, retain) NSArray *h2DemoModel;
@property (nonatomic, retain) NSArray *h2AccuChekModel;
@property (nonatomic, retain) NSArray *h2BayerModel;
@property (nonatomic, retain) NSArray *h2CareSensModel;
@property (nonatomic, retain) NSArray *h2FreeStyleModel;
@property (nonatomic, retain) NSArray *h2GlucoCardModel;
@property (nonatomic, retain) NSArray *h2OneTouchModel;
@property (nonatomic, retain) NSArray *h2ReliOnModel;
@property (nonatomic, retain) NSArray *h2BeneChekModel;
@property (nonatomic, retain) NSArray *h2EXT_9_Model;
@property (nonatomic, retain) NSArray *h2EXT_A_Model;
@property (nonatomic, retain) NSArray *h2EXT_B_Model;
@property (nonatomic, retain) NSArray *h2EXT_C_Model;
@property (nonatomic, retain) NSArray *h2EXT_D_Model;
@property (nonatomic, retain) NSArray *h2EXT_E_Model;
@property (nonatomic, retain) NSArray *h2EXT_F_Model;
@property (nonatomic, retain) NSArray *h2EXT_10_Model;

@property (nonatomic, retain) NSArray *h2OneTouchUltraModel;

@property (nonatomic, retain) NSArray *h2Bionime_Type;



+ (H2BgmTable *)brandSharedInstance;

@end


