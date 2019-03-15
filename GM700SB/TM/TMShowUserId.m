//
//  TMShowUserId.m
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "SQXViewController.h"
#import "BleBeFoundViewController.h"
#import "BleBGMViewController.h"

#import "LibDelegateFunc.h"

#import "STBViewController.h"

#import "TMItemViewController.h"

#import "SNWriteViewController.h"

#import "TMShowUserId.h"
#import "BleBGMViewController.h"
#import "OmronRecordViewController.h"

#import "H2BleEquipId.h"

@interface TMShowUserIdViewController ()
{
    UIButton *btnUserId_1;
    UIButton *btnUserId_2;
    UIButton *btnUserId_3;
    
    UIButton *btnUserId_4;
    UIButton *btnUserId_5;
    
    UIButton *btnCancel;
    
    NSString *u1String;
    NSString *u2String;
    NSString *u3String;
    NSString *u4String;
    NSString *u5String;
    
}



@end

@implementation TMShowUserIdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    UInt32 vendorMeterId = 0;
    UInt16 spacing = 70;
    UInt16 hOffset = 20;
     self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(userIdModePageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"USER ID SEL"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        /////////////////////////////////////////
        // User ID String
        u1String = [NSString stringWithFormat:@"%d", 1];
        u2String = [NSString stringWithFormat:@"%d", 2];
        u3String = [NSString stringWithFormat:@"%d", 3];
        u4String = [NSString stringWithFormat:@"%d", 4];
        u5String = [NSString stringWithFormat:@"%d", 5];
        // BUTTON
        btnUserId_1 = [[UIButton alloc] init];
        btnUserId_2 = [[UIButton alloc] init];
        btnUserId_3 = [[UIButton alloc] init];
        btnUserId_4 = [[UIButton alloc] init];
        btnUserId_5 = [[UIButton alloc] init];
        
        btnCancel = [[UIButton alloc] init];
        
        
        btnUserId_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUserId_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUserId_3 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUserId_4 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUserId_5 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnUserId_1];
        [bottunArray addObject:btnUserId_2];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:u1String];
        [btnString addObject:u2String];
        [btnString addObject:u3String];
        
        [btnString addObject:u4String];
        [btnString addObject:u5String];

        
        // Set Button Color
        NSLog(@"USER ID VALUE IS %02X", [LibDelegateFunc sharedInstance].omronUserIdFromEquipment);
        
        if ([LibDelegateFunc sharedInstance].omronUserIdFromEquipment & USER_TAG1_MASK) {
            [btnUserId_1 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        }else{
            [btnUserId_1 setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
        }
        
        if ([LibDelegateFunc sharedInstance].omronUserIdFromEquipment & USER_TAG2_MASK) {
            [btnUserId_2 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        }else{
            [btnUserId_2 setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
        }
        
        if ([LibDelegateFunc sharedInstance].omronUserIdFromEquipment & USER_TAG3_MASK) {
            [btnUserId_3 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        }else{
            [btnUserId_3 setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
        }
        
        if ([LibDelegateFunc sharedInstance].omronUserIdFromEquipment & USER_TAG4_MASK) {
            [btnUserId_4 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        }else{
            [btnUserId_4 setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
        }
        
        if ([LibDelegateFunc sharedInstance].omronUserIdFromEquipment & USER_TAG5_MASK) {
            [btnUserId_5 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        }else{
            [btnUserId_5 setBackgroundImage:[UIImage imageNamed:@"gray_button.png"] forState:UIControlStateNormal];
        }
        
        vendorMeterId = (UInt32)[[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
        
        switch (vendorMeterId) {
            case SM_BLE_OMRON_HEM_7280T:
                spacing = 150;
                hOffset = HOFFSET_HEM7280T;
                break;
                
            case SM_BLE_OMRON_HBF_254C:
                spacing = 75;
                hOffset = HOFFSET_HBF254C;
                [bottunArray addObject:btnUserId_3];
                [bottunArray addObject:btnUserId_4];
                break;
                
            case SM_BLE_CARESENS_EXT_B_FORA_W310B:
            case SM_BLE_ARKRAY_G_BLACK:
            case SM_BLE_ARKRAY_NEO_ALPHA:
                spacing = 65;
                hOffset = HOFFSET_GBLACK;
                [bottunArray addObject:btnUserId_3];
                [bottunArray addObject:btnUserId_4];
                [bottunArray addObject:btnUserId_5];
                break;
                
            default:
                break;
        }
        
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            
            
            //btnBleMethod.frame = CGRectMake(20, 60 + 40 + btnIndex * 60, 280, 40);
            btnBleMethod.frame = CGRectMake(hOffset + btnIndex * spacing, VOFFSET_OMRON, 65, 140);
            
            [btnBleMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnBleMethod.titleLabel setTextColor:[UIColor redColor]];
            //[btnBleMethod.titleLabel setFont:[UIFont fontWithName:@"System" size:17]];
            
            
            [btnBleMethod.layer setMasksToBounds:YES];
            [btnBleMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnBleMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnBleMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            //[btnBleMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnBleMethod addTarget:self action:@selector(setUserid1:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(setUserid2:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(setUserid3:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 3:
                    [btnBleMethod addTarget:self action:@selector(setUserid4:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 4:
                    [btnBleMethod addTarget:self action:@selector(setUserid5:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
            [self.view addSubview:btnBleMethod];
            btnIndex++;
        }
        
        // Cancel Button
        btnCancel.frame = CGRectMake(20, VOFFSET_CANCEL, 280, 40);
        
        [btnCancel.titleLabel setFont:[UIFont systemFontOfSize:26]];
        [btnCancel.titleLabel setTextColor:[UIColor redColor]];
         
        [btnCancel setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        
        [btnCancel.layer setMasksToBounds:YES];
        [btnCancel.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnCancel.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnCancel setTitle:@"CANCEL" forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(setUserid0:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnCancel];
        
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

- (IBAction)setUserid1:(id)sender
{
    _userTag = USER_TAG1_MASK;
    [btnUserId_1 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
    [[H2Sync sharedInstance] demoAppOmronSetUserTag:_userTag];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)setUserid2:(id)sender
{
    _userTag = USER_TAG2_MASK;
    [btnUserId_2 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
    [[H2Sync sharedInstance] demoAppOmronSetUserTag:_userTag];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)setUserid3:(id)sender
{
    _userTag = USER_TAG3_MASK;
    [btnUserId_3 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
    [[H2Sync sharedInstance] demoAppOmronSetUserTag:_userTag];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)setUserid4:(id)sender
{
    _userTag = USER_TAG4_MASK;
    [btnUserId_4 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
    [[H2Sync sharedInstance] demoAppOmronSetUserTag:_userTag];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setUserid5:(id)sender
{
    _userTag = USER_TAG5_MASK;
    [[H2Sync sharedInstance] demoAppOmronSetUserTag:_userTag];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self setUseridTask];
}


- (IBAction)setUserid0:(id)sender
{
    _userTag = 0;
    [[H2Sync sharedInstance] demoAppOmronSetUserTag:_userTag];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)userIdModePageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

@implementation TMShowUserId

@end
