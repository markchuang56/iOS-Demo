//
//  OmronSetUserTagViewController.h
//  FR_W310B
//
//  Created by h2Sync on 2017/11/3.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#define UTAG_HORIZOTAL                    20
#define UTAG_HORIZOTAL_NEXT               (UTAG_HORIZOTAL + 80)
#define UTAG_VERTICAL                     100

#define UTAG_PICKER_H                     20
#define UTAG_PICKER_V                     220

#define UTAG_PICKER_H_SIZE              280
#define UTAG_PICKER_V_SIZE              160


#define UTAG_DEFAULT                      1

#define UTAG_DONE_VERTICAL                420

#import <UIKit/UIKit.h>

@interface OmronSetUserTagViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, strong) UIPickerView *tagPickerView;
@end
