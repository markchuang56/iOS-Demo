//
//  TMSetUserProfile.h
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>



#define BODYHEIGHT_HORIZOTAL                    20
#define BODYHEIGHT_HORIZOTAL_NEXT               (BODYHEIGHT_HORIZOTAL + 80)
#define BODYHEIGHT_VERTICAL                     100
//#define BODYHEIGHT_NEXT_VERTICAL                360

//BODYHEIGHT_HORIZOTAL

#define BODYHEIGHT_PICKER_H                     20
#define BODYHEIGHT_PICKER_V                     220

#define BODYHEIGHT_PICKER_H_SIZE              280
#define BODYHEIGHT_PICKER_V_SIZE              160


#define BODYHEIGHT_DEFAULT                      (160 * 10)

#define BODYHEIGHT_DONE_VERTICAL                420
 


@interface OMUserProfileBodyHeightViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

//@property(nonatomic, strong) UIPickerView *bPickerView;


@end


