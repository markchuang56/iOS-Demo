//
//  TMSetUserProfile.h
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>


//#define BIRTHDAY_VERTICAL           300
//#define BODYHEIGHT_VERTICAL           300

#define BIRTHDAY_VERTICAL                   120
#define BIRTHDAY_HORIZOTAL                  80

// 40, 120, 240, 160);
#define BIRTHDAY_PICKER_H                   20
#define BIRTHDAY_PICKER_V                   220

#define BIRTHDAY_PICKER_H_SIZE              280
#define BIRTHDAY_PICKER_V_SIZE              160


#define BIRTHDAY_NEXT_VERTICAL              420

/*
#define HBF_UID_1               0x20
#define HBF_UID_2               0x30
#define HBF_UID_3               0x40
#define HBF_UID_4               0x50
*/


/*
#define BIRTH_YEAR                  1980
#define BIRTH_MONTH                 1
#define BIRTH_DAY                   1
*/

@interface OMUserProfileBirthdayViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, strong) UIDatePicker *bDatePicker;// = [[UIDatePicker alloc] init];
//@property(nonatomic, strong) UIPickerView *bPickerView;// = [[UIDatePicker alloc] init];
@property(nonatomic, strong) NSDateFormatter *bDateFormatter;


@end

/*
@interface TMSetUserProfile : NSObject

@property(readwrite) Byte *userProfileBuffer;

@property (nonatomic, unsafe_unretained) UInt8 userPfId;

@property (nonatomic, unsafe_unretained) UInt8 userPfYear;
@property (nonatomic, unsafe_unretained) UInt8 userPfMonth;
@property (nonatomic, unsafe_unretained) UInt8 userPfDay;

@property (nonatomic, unsafe_unretained) UInt8 userPfGender;
@property (nonatomic, unsafe_unretained) UInt16 userPfHeigh;


+ (TMSetUserProfile *)sharedInstance;
@end
 
*/
