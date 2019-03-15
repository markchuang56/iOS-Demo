//
//  OmronShowUserId.h
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//



#define HOFFSET_HEM7280T            60
#define HOFFSET_HBF254C             20
#define HOFFSET_GBLACK              20
#define VOFFSET_OMRON               160

#define VOFFSET_CANCEL              420

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface OmronShowUserIdViewController : UIViewController

@property (readwrite) UInt8 userTag;
- (id)init:(UInt8)omronUserTag;

@end

