//
//  TMSetUserProfile.h
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>


#import <UIKit/UIKit.h>


#define GENDER_INIT_H                       50
#define GENDER_INIT_H_SPACING               150
#define GENDER_INIT_V                       120

#define GENDER_INIT_H_SIZE                  65
#define GENDER_INIT_V_SIZE                  140

#define GENDER_NEXT_VERTICAL                420

@interface OMUserProfileGenderViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

//@property(nonatomic, strong) UIDatePicker *bDatePicker;// = [[UIDatePicker alloc] init];
//@property(nonatomic, strong) UIPickerView *bPickerView;// = [[UIDatePicker alloc] init];
//@property(nonatomic, strong) NSDateFormatter *bDateFormatter;


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
