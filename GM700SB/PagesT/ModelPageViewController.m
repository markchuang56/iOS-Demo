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
#import "ModelPageViewController.h"
#import "H2Sync.h"
#import "H2AudioHelper.h"

#import "LibDelegateFunc.h"

#import "ModelPageViewController.h"


#define MODEL_COLUMN_MAX                                    5
#define MODEL_ROW_MAX                                           26
#define MODEL_ROW_MAX_NUM                                   160



@interface ModelPageViewController ()
{
    UILabel *bodyHeightLabel;
    UITextField *bodyHeightTextField;
    UIButton *btnDone;
    Byte *qrSrc;
}



@end



@implementation ModelPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(modelPageBack:)];
        
        UIBarButtonItem *btnBodyHeightDone = [[UIBarButtonItem alloc]
                                            initWithTitle:@"DONE"
                                            style:UIBarButtonItemStylePlain
                                            target:self action:@selector(userProfileDone:)];
        
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"MODEL PAGE"];
        
        navItem.leftBarButtonItem = btnBack;
        navItem.rightBarButtonItem = btnBodyHeightDone;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        UIPickerView * picker = [UIPickerView new];
        picker.frame = CGRectMake(BODYHEIGHT_PICKER_H, BODYHEIGHT_PICKER_V, BODYHEIGHT_PICKER_H_SIZE, BODYHEIGHT_PICKER_V_SIZE);
        
        picker.delegate = self;
        picker.dataSource = self;
        picker.showsSelectionIndicator = YES;
        [self.view addSubview:picker];
        
        
        
        
        //[picker reloadComponent:33];
        // Picker Init ...
        
        // 中間值
        for (int i=0; i<MODEL_COLUMN_MAX; i++) {
            if (i>3) {
                [picker selectRow:4 inComponent:i animated:YES];
            }else{
                [picker selectRow:13 inComponent:i animated:YES];
            }
        }
        
        
        
        
        // Done Button
        btnDone = [[UIButton alloc] init];
        btnDone = [UIButton buttonWithType:UIButtonTypeCustom];

        btnDone.frame = CGRectMake(20, BODYHEIGHT_DONE_VERTICAL, 280, 40);
        
        [btnDone.titleLabel setFont:[UIFont systemFontOfSize:24]];
        
        [btnDone.layer setMasksToBounds:YES];
        [btnDone.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnDone.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnDone setTitle:@"PROFILE DONE" forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(userProfileDone:) forControlEvents:UIControlEventTouchUpInside];
        [btnDone setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        [self.view addSubview:btnDone];
        
        ////////////////////////////////
        // Body Height Label
        bodyHeightLabel = [[UILabel alloc] init];
        bodyHeightLabel.frame = CGRectMake(BODYHEIGHT_HORIZOTAL , BODYHEIGHT_VERTICAL, 80, 40);
        [bodyHeightLabel setFont:[UIFont systemFontOfSize:26]];
        bodyHeightLabel.text = @"QR  : ";
        [self.view addSubview:bodyHeightLabel];
        
        /////////////////////////////
        // BodyHeight Field
        bodyHeightTextField = [[UITextField alloc] init];
        bodyHeightTextField.frame = CGRectMake(BODYHEIGHT_HORIZOTAL_NEXT, BODYHEIGHT_VERTICAL, 160, 40);
        [bodyHeightTextField setFont:[UIFont systemFontOfSize:26]];
         bodyHeightTextField.contentMode = UIViewContentModeRight;
        bodyHeightTextField.text = [NSString stringWithFormat:@"ABCD123456"];
        [self.view addSubview:bodyHeightTextField];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        qrSrc = (Byte *)malloc(16);
        for (int i=0; i<16; i++) {
            qrSrc[i] = 0;
        }
        
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

/////////////////////////////////////////////////////////
// TEST AREA !! UIDatePicker

    


///////////////////////////////////////////////////////////////////////
// For User Body Height
#pragma mark - UIPICKERVIEW AREA !!

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return MODEL_COLUMN_MAX;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component > 3) {
         return MODEL_ROW_MAX_NUM;
    }
    return MODEL_ROW_MAX;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //UInt8 mode = (MODEL_ROW_MAX >> 1) + row;
    
    UInt8 mode =  row;
    if (component > 3) {
        return [NSString stringWithFormat:@"%d ", mode];
    }else{
        //mode += (MODEL_ROW_MAX >> 1);
        unsigned char ch = [ self numToChar:mode];
        return [NSString stringWithFormat:@"%C ", (unichar)ch];
    }
    
    
}
//4)Next, you need to get the event when someone click on the title(As you want to navigate to other controller/screen):

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
//    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
   // UInt8 mode = (MODEL_ROW_MAX >> 1) + row;
    
    //UInt16 enderSwap = CFSwapInt16(mode);
    
    UInt8 mode =  row;
    unsigned char chTmp;
    if (component > 3) {
        chTmp = mode + '0';
        NSLog(@"SEL --> %d",  mode);
    }else{
       // mode += (MODEL_ROW_MAX >> 1);
        chTmp = [ self numToChar:mode];
        
        NSLog(@"SEL --> %C",  (unichar)chTmp);
    }
    
    qrSrc[component] = chTmp;
    for (int i=0; i<16; i++) {
        NSLog(@"QR %d = %02X", i, qrSrc[i]);
    }
    
    //return [NSString stringWithFormat:@"%C ", (unichar)ch];
    
    ///////////////////////
    //
//    bodyHeightTextField.text = [NSString stringWithFormat:@"%d.%d 公分", (UInt16)(bHeight/10), (UInt16)(bHeight%10)];
    //Now, if you want to navigate then;
    // Say, OtherViewController is the controller, where you want to navigate:
//    OtherViewController *objOtherViewController = [OtherViewController new];
//    [self.navigationController pushViewController:objOtherViewController animated:YES];
    
    
//    [LibDelegateFunc sharedInstance].userProfile.uBodyHeight = bHeight;
}

- (IBAction)modelPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)userProfileDone:(id)sender
{
    MeterTaskViewController *omronController =[[MeterTaskViewController alloc] init];
    [self presentViewController:omronController animated:YES completion:^{NSLog(@"OMRON VIEW DONE(UserProfile)");}];
}

- (IBAction)skipSetting:(id)sender
{
    
}

- (unsigned char)numToChar:(UInt8)num
{
    unsigned char ch = 'A' + num;
    return ch;
}
@end

