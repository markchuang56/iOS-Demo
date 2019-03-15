//
//  PagesViewController.m
//  FR_W310B
//
//  Created by h2Sync on 2017/11/28.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "PagesViewController.h"

#import "ModelPageViewController.h"
#import "VendorViewController.h"

#import "SNWriteViewController.h"


@interface PagesViewController ()
{
    UIButton *btnModelPage;

    UIButton *btnBlePairing;
    UIButton *btnSerialNumberPage;
    
    UIButton *btnDrawingCircle;
    
    UIButton *btnBleDeviceSelect;
    
    UIButton *btnUserIdAndRecordType;
    
    UIButton *btnMeterDelRecords;
    
    NSString *oadSrcPath;
}

@end



@implementation PagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(pagesBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"PAGES TASK"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        // BUTTON
        btnModelPage = [[UIButton alloc] init];
        
        btnBlePairing = [[UIButton alloc] init];
        btnSerialNumberPage = [[UIButton alloc] init];
        
        btnDrawingCircle = [[UIButton alloc] init];
        btnBleDeviceSelect = [[UIButton alloc] init];
        btnUserIdAndRecordType = [[UIButton alloc] init];
        
        btnMeterDelRecords = [[UIButton alloc] init];
        
        // Button Customer
        btnModelPage = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnBlePairing = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSerialNumberPage = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnDrawingCircle = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBleDeviceSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUserIdAndRecordType = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnMeterDelRecords = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnModelPage];
        
        [bottunArray addObject:btnBlePairing];
        [bottunArray addObject:btnSerialNumberPage];
        
        [bottunArray addObject:btnDrawingCircle];
        
        //[bottunArray addObject:btnBleDeviceSelect];
        //[bottunArray addObject:btnUserIdAndRecordType];
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        
        [btnString addObject:@"MODEL PAGE"];
        [btnString addObject:@"VENDOR PAGE"];
        [btnString addObject:@"SN FUNC"];
        
        [btnString addObject:@"SET PROFILE"];
        [btnString addObject:@"BLE DEVICE SEL"];
        [btnString addObject:@"UID & D-TYPE"];
        
        [btnString addObject:@"(B)METER DEL"];
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            
            btnBleMethod.frame = CGRectMake(20, 60 + 40 + btnIndex * (50), 280, 40);
            
            [btnBleMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnBleMethod.layer setMasksToBounds:YES];
            [btnBleMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnBleMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnBleMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            [btnBleMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnBleMethod addTarget:self action:@selector(showModelPage:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 1:
                    [btnBleMethod addTarget:self action:@selector(showVendorPage:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 2:
                    [btnBleMethod addTarget:self action:@selector(showSNPage:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 3:
                    [btnBleMethod addTarget:self action:@selector(jsDrawingCircleTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 4:
                    [btnBleMethod addTarget:self action:@selector(bleDeviceShow:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 5:
                    [btnBleMethod addTarget:self action:@selector(btnUidAndRdType:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 6:
                    [btnBleMethod addTarget:self action:@selector(bleSyncTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
            
            [self.view addSubview:btnBleMethod];
            btnIndex++;
        }
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


- (void)showModelPage:(id)sender
{
    ModelPageViewController *modePagelController =[[ModelPageViewController alloc] init];
    [self presentViewController:modePagelController animated:YES completion:^{NSLog(@"MODEL_PAGE ");}];
}

- (void)showVendorPage:(id)sender
{
    VendorViewController *vendorPagelController =[[VendorViewController alloc] init];
    [self presentViewController:vendorPagelController animated:YES completion:^{NSLog(@"VENDOR_PAGE ");}];
}

- (void)showSNPage:(id)sender
{
    SNWriteViewController *snPagelController =[[SNWriteViewController alloc] init];
    [self presentViewController:snPagelController animated:YES completion:^{NSLog(@"SN_PAGE ");}];
}

- (void)jsDrawingCircleTask:(id)sender
{
    SNWriteViewController *snPagelController =[[SNWriteViewController alloc] init];
    [self presentViewController:snPagelController animated:YES completion:^{NSLog(@"CIRCLE_PAGE ");}];
}



- (void) pagesBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MID_SN_NOTIFICATION" object:self];
    }];
}

@end
