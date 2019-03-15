//
//  TMShowUserId.h
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


// USER ID HAS SET

/*
#define USER_ID1_YES                0x01
#define USER_ID2_YES                0x02
#define USER_ID3_YES                0x04
#define USER_ID4_YES                0x08
#define USER_ID5_YES                0x10
*/

#define HOFFSET_HEM7280T            60
#define HOFFSET_HBF254C             20
#define HOFFSET_GBLACK              20
#define VOFFSET_OMRON               160

#define VOFFSET_CANCEL              420

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface TMShowUserIdViewController : UIViewController

@property (readwrite) UInt8 userTag;

@end

@interface TMShowUserId : NSObject

@end
