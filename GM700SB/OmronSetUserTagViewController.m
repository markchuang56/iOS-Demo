//
//  OmronSetUserTagViewController.m
//  FR_W310B
//
//  Created by h2Sync on 2017/11/3.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "OmronSetUserTagViewController.h"

//#import "MeterTaskViewController.h"

#import "OMUserPfGender.h"
#import "OMUserPfBirthday.h"
//#import "OMUserPfBodyHeight.h"
#import "H2Sync.h"
#import "H2AudioHelper.h"

//#import "UserProfileFromApp.h"
#import "LibDelegateFunc.h"

@interface OmronSetUserTagViewController ()
{
    UILabel *uTagLabel;
    UITextField *uTagTextField;
    UIButton *btnDone;
    
    UInt8 uTagMax;
}



@end

@implementation OmronSetUserTagViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
- (id)init
{
    //self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self = [super init];
    if (self) {
        uTagMax = 5;
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(uTagPageBack:)];
        
        UIBarButtonItem *btnUTagDone = [[UIBarButtonItem alloc]
                                              initWithTitle:@"DONE"
                                              style:UIBarButtonItemStylePlain
                                              target:self action:@selector(goToGender:)];
        
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"USER TAG"];
        
        navItem.leftBarButtonItem = btnBack;
        navItem.rightBarButtonItem = btnUTagDone;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        
        // Picker View For User TAG
        _tagPickerView = [[UIPickerView alloc] init];
        
        _tagPickerView.frame = CGRectMake(20, 300, 280, 120);
        [self.view addSubview:_tagPickerView];
        
        
        UIPickerView * picker = [UIPickerView new];
        //picker.frame = CGRectMake(20, 400, 280, 120);
        
        picker.frame = CGRectMake(UTAG_PICKER_H, UTAG_PICKER_V, UTAG_PICKER_H_SIZE, UTAG_PICKER_V_SIZE);
        
        picker.delegate = self;
        picker.dataSource = self;
        picker.showsSelectionIndicator = YES;
        [self.view addSubview:picker];
        
        //[picker reloadComponent:33];
        // Picker Init ...
        [picker selectRow:800 inComponent:0 animated:YES];
        
        
        
        // Done Button
        btnDone = [[UIButton alloc] init];
        btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnDone.frame = CGRectMake(20, UTAG_DONE_VERTICAL, 280, 40);
        
        [btnDone.titleLabel setFont:[UIFont systemFontOfSize:24]];
        
        [btnDone.layer setMasksToBounds:YES];
        [btnDone.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnDone.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnDone setTitle:@"To -> GENDER" forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(goToGender:) forControlEvents:UIControlEventTouchUpInside];
        [btnDone setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        [self.view addSubview:btnDone];
        
        ////////////////////////////////
        // Body Height Label
        uTagLabel = [[UILabel alloc] init];
        uTagLabel.frame = CGRectMake(UTAG_HORIZOTAL , UTAG_VERTICAL, 80, 40);
        [uTagLabel setFont:[UIFont systemFontOfSize:26]];
        uTagLabel.text = @"編 號  : ";
        [self.view addSubview:uTagLabel];
        
        /////////////////////////////
        // BodyHeight Field
        uTagTextField = [[UITextField alloc] init];
        uTagTextField.frame = CGRectMake(UTAG_HORIZOTAL_NEXT, UTAG_VERTICAL, 160, 40);
        [uTagTextField setFont:[UIFont systemFontOfSize:26]];
        uTagTextField.contentMode = UIViewContentModeRight;
        uTagTextField.text = [NSString stringWithFormat:@"%d 用戶", UTAG_DEFAULT];
        [self.view addSubview:uTagTextField];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

///////////////////////////////////////////////////////////////////////
// For User Body Height
#pragma mark - UIPICKERVIEW AREA !!

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return uTagMax;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //UInt8 tag = (uTagMax >> 1) + row;
    UInt8 tag = row+1;
    //return [NSString stringWithFormat:@"Choice-%d",row];//Or, your suitable title; like Choice-a, etc.
    return [NSString stringWithFormat:@"%d 用戶", tag];//Or, your suitable title; like Choice-a, etc.
}
//4)Next, you need to get the event when someone click on the title(As you want to navigate to other controller/screen):

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
    //    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
    //UInt16 tag = (uTagMax >> 1) + row;
    UInt16 tag = row+1;
    //NSLog(@"PICKER VIEW SELECT = %d And BH = %d.%d 公分", row, bHeight/10, bHeight%10);
    //UInt16 enderSwap = CFSwapInt16(bHeight);
    //NSLog(@"THE BODY HEIGTH , RAW = %04X and SWAP = %04X", bHeight, enderSwap);
    
    ///////////////////////
    //
    uTagTextField.text = [NSString stringWithFormat:@"%d 用戶", tag];
    //Now, if you want to navigate then;
    // Say, OtherViewController is the controller, where you want to navigate:
    //    OtherViewController *objOtherViewController = [OtherViewController new];
    //    [self.navigationController pushViewController:objOtherViewController animated:YES];
    
    
    [LibDelegateFunc sharedInstance].userProfile.uTag = tag;
    NSLog(@"UTAG - %d", [LibDelegateFunc sharedInstance].userProfile.uTag);
}

- (IBAction)uTagPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goToGender:(id)sender
{
    ///////////////////////
    // For Omron User GENDER
    OMUserProfileGenderViewController *userGenderController =[[OMUserProfileGenderViewController alloc] init];
    [self presentViewController:userGenderController animated:YES completion:^{NSLog(@"USER PROFILE GENDER - DONE");}];
}



@end
