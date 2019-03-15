//
//  TMSetUserProfile.m
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "MeterTaskViewController.h"

#import "OMUserPfGender.h"
#import "OMUserPfBirthday.h"
#import "OMUserPfBodyHeight.h"
#import "H2Sync.h"
#import "H2AudioHelper.h"

//#import "UserProfileFromApp.h"
#import "LibDelegateFunc.h"



@interface OMUserProfileGenderViewController ()
{
    
    UIButton *btnMale;
    UIButton *btnFemale;
   
    UIButton *btnNext;
    
    
    UILabel *birtdaLabel;
    
    UILabel *birtdayYearLabel;
    UILabel *birtdayMonthLabel;
    UILabel *birtdayDayLabel;
    
    UITextField *birtdayYearTextField;
    UITextField *birtdayMonthTextField;
    UITextField *birtdayDayTextField;
}



@end

@implementation OMUserProfileGenderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        // Back Button
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(genderPageBack:)];
        
        
        // Gender Done Button
        UIBarButtonItem *btnGenderDone = [[UIBarButtonItem alloc]
                                    initWithTitle:@"DONE"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(genderDone:)];
        
        // Add left and right button
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"USER GENDER"];
        navItem.leftBarButtonItem = btnBack;
        navItem.rightBarButtonItem = btnGenderDone;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        // BUTTON
        btnMale = [[UIButton alloc] init];
        btnFemale = [[UIButton alloc] init];
        
        btnNext = [[UIButton alloc] init];
        
        
        btnMale = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFemale = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnMale];
        [bottunArray addObject:btnFemale];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"M"];
        [btnString addObject:@"F"];
        
        if ([LibDelegateFunc sharedInstance].userProfile.uGender > 0) {
            [btnMale setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            [btnFemale setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
        }else{
            [btnMale setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
            [btnFemale setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        }
        
        
        
        //UInt8 spacing = 0;
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            
            btnBleMethod.frame = CGRectMake(GENDER_INIT_H + btnIndex * GENDER_INIT_H_SPACING, GENDER_INIT_V, GENDER_INIT_H_SIZE, GENDER_INIT_V_SIZE);
            
            [btnBleMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnBleMethod.layer setMasksToBounds:YES];
            [btnBleMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnBleMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnBleMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            //[btnBleMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnBleMethod addTarget:self action:@selector(genderMale:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(genderFemale:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
            [self.view addSubview:btnBleMethod];
            btnIndex++;
        }
        
        
        // Next Button
        btnNext.frame = CGRectMake(20, GENDER_NEXT_VERTICAL, 280, 40);
        
        [btnNext.titleLabel setFont:[UIFont systemFontOfSize:26]];
        
        [btnNext.layer setMasksToBounds:YES];
        [btnNext.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnNext.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnNext setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
        
        [btnNext addTarget:self action:@selector(genderNext:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnNext];

        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self.view addSubview:navBar];
    
    UIBarButtonItem *backButtor = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Skip"
                                   style:UIBarButtonItemStylePlain
                                   target:self action:@selector(skipSetting:)];
    UINavigationItem *navItem = [[UINavigationItem alloc]
                                 initWithTitle:@"PROFILE"];
    
    navItem.leftBarButtonItem = backButtor;
    [navBar pushNavigationItem:navItem animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////
//


- (IBAction)genderMale:(id)sender
{
    [LibDelegateFunc sharedInstance].userProfile.uGender = MALE;
    [btnMale setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
    [btnFemale setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
    NSLog(@"THE GENDER IS %d", [LibDelegateFunc sharedInstance].userProfile.uGender);
}
- (IBAction)genderFemale:(id)sender
{
    [LibDelegateFunc sharedInstance].userProfile.uGender = FEMALE;
    [btnMale setBackgroundImage:[UIImage imageNamed:@"gray_button.png.png"] forState:UIControlStateNormal];
    [btnFemale setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
    NSLog(@"THE GENDER IS %d", [LibDelegateFunc sharedInstance].userProfile.uGender);
}

- (IBAction)genderNext:(id)sender
{
    //_userId = USER_ID3_YES;
    //[[H2Sync sharedInstance] h2OmronSetUserId:_userId];
//    [self dismissViewControllerAnimated:YES completion:nil];
    ///////////////////////
    // GO TO Omron User Profile - Birthday
    OMUserProfileBirthdayViewController *userBirthdayController =[[OMUserProfileBirthdayViewController alloc] init];
    [self presentViewController:userBirthdayController animated:YES completion:^{NSLog(@"USER PROFILE BIRTHDAY - DONE");}];
/*
    ///////////////////////
    // GO TO Omron User Profile - Body Height
    OMUserProfileBodyHeightViewController *userBodyHeightController =[[OMUserProfileBodyHeightViewController alloc] init];
    [self presentViewController:userBodyHeightController animated:YES completion:^{NSLog(@"USER PROFILE BODY HEIGHT - DONE");}];
*/
}

- (IBAction)skipSetting:(id)sender
{
    
}

- (IBAction)genderPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)genderDone:(id)sender
{
    MeterTaskViewController *omronController =[[MeterTaskViewController alloc] init];
    [self presentViewController:omronController animated:YES completion:^{NSLog(@"OMRON VIEW DONE(Gender)");}];
}



///////////////////////////////////////////////////////////////////////
// For ...
#pragma mark - UIPICKERVIEW (DELEGATE)AREA !!

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //return [NSString stringWithFormat:@"Choice-%d",row];//Or, your suitable title; like Choice-a, etc.
    return @"HA-HA";
}


- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
    //    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
}


@end

