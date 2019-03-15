//
//  SyncResultViewController.m
//  FR_W310B
//
//  Created by h2Sync on 2017/10/26.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "EquipRecordsViewController.h"

#import "LastDateTimeViewController.h"

#import "EquipInfoViewController.h"
#import "SyncMessageViewController.h"

#import "LibDelegateFunc.h"

#import "SyncResultViewController.h"

#import "SkipNumbersViewController.h"


@interface SyncResultViewController ()
{
    UIButton *btnShowBgResult;
    UIButton *btnShowBpResult;
    UIButton *btnShowBwResult;
    
    UIButton *btnShowNewLastDateTime;
    UIButton *btnShowTotalLastDateTime;
    
    UIButton *btnShowMeterInfo;
    UIButton *btnShowSyncMessage;
    
    UIButton *btnShopSkipNumber;
}

@end

@implementation SyncResultViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UINavigationBar *navBleBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(resultPageBack:)];
        //        UINavigationItem *navItem = [[UINavigationItem alloc]
        //                                     initWithTitle:@"BLE FUNCTION"];
        
        //UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:[LibDelegateFunc sharedInstance].stbTitle];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"RESULT BTN"];
        
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        // BUTTON
        btnShowBgResult = [[UIButton alloc] init];
        btnShowBpResult = [[UIButton alloc] init];
        btnShowBwResult = [[UIButton alloc] init];
        
        btnShowNewLastDateTime = [[UIButton alloc] init];
        btnShowTotalLastDateTime = [[UIButton alloc] init];
        
        btnShowMeterInfo = [[UIButton alloc] init];
        btnShowSyncMessage = [[UIButton alloc] init];
        
        
        btnShopSkipNumber = [[UIButton alloc] init];
        
        
        
        btnShowBgResult = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowBpResult = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowBwResult = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnShowNewLastDateTime = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowTotalLastDateTime = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnShowMeterInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowSyncMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnShopSkipNumber = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnShowBgResult];
        [bottunArray addObject:btnShowBpResult];
        [bottunArray addObject:btnShowBwResult];
        
        [bottunArray addObject:btnShowNewLastDateTime];
        [bottunArray addObject:btnShowTotalLastDateTime];
        
        [bottunArray addObject:btnShowMeterInfo];
        [bottunArray addObject:btnShowSyncMessage];
        
        [bottunArray addObject:btnShopSkipNumber];
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"SHOW BG RESULT"];
        [btnString addObject:@"SHOW BP RESULT"];
        [btnString addObject:@"SHOW BW RESULT"];
        
        [btnString addObject:@"SHOW NEW LDT"];
        [btnString addObject:@"SHOW TOTAL LDT"];
        
        [btnString addObject:@"SHOW METER INFO"];
        [btnString addObject:@"SHOW SYNC MESSAGE"];
        
        [btnString addObject:@"SHOW SKIP RECORDS"];
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            //            btnBleMethod = [UIButton buttonWithType:UIButtonTypeCustom];
            
            btnBleMethod.frame = CGRectMake(20, 60 + btnIndex * 45, 280, 40);
            //            btnBleMethod.frame = CGRectMake(20, 40 + btnIndex * 100, 280, 40);
            
            [btnBleMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnBleMethod.layer setMasksToBounds:YES];
            [btnBleMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnBleMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnBleMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            [btnBleMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"]
                                    forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnBleMethod addTarget:self action:@selector(showBgRecords:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(showBpRecords:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(showBwRecords:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 3:
                    [btnBleMethod addTarget:self action:@selector(showNewDateTime:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 4:
                    [btnBleMethod addTarget:self action:@selector(showTotalDateTime:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 5:
                    [btnBleMethod addTarget:self action:@selector(showMeterInfo:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 6:
                    [btnBleMethod addTarget:self action:@selector(showSyncMessage:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 7:
                    [btnBleMethod addTarget:self action:@selector(showSkipRecords:) forControlEvents:UIControlEventTouchUpInside];
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
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"SINGLE_RECORD_NOTIFICATION" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)showBgRecords:(id)sender
{
    BGMRecordsViewController *bgController;
    bgController = [[BGMRecordsViewController alloc] init];
    bgController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bgController animated:YES completion:^{NSLog(@"DONE FOR show BG RECORD");}];
}

- (IBAction)showBpRecords:(id)sender
{
    BPMRecordsViewController *bpController;
    bpController = [[BPMRecordsViewController alloc] init];
    bpController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bpController animated:YES completion:^{NSLog(@"DONE FOR show BP RECORD");}];
}


- (IBAction)showBwRecords:(id)sender
{
    BWMRecordsViewController *bwController;
    bwController = [[BWMRecordsViewController alloc] init];
    bwController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bwController animated:YES completion:^{NSLog(@"DONE FOR show BW RECORD");}];
}

#pragma mark - LDT AREA
- (IBAction)showNewDateTime:(id)sender
{
    LastDateTimeViewController *ldtController;
    ldtController = [[LastDateTimeViewController alloc] init:YES];
    ldtController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ldtController animated:YES completion:^{NSLog(@"DONE FOR show NEW LDT");}];
}


- (IBAction)showTotalDateTime:(id)sender
{
    LastDateTimeViewController *ldtTotalController;
    ldtTotalController = [[LastDateTimeViewController alloc] init:NO];
    ldtTotalController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:ldtTotalController animated:YES completion:^{NSLog(@"DONE FOR show TOTAL LDT");}];
}


- (IBAction)showMeterInfo:(id)sender
{
    EquipInfoViewController *bgmInfoController;
    bgmInfoController = [[EquipInfoViewController alloc] init:nil];
    bgmInfoController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bgmInfoController animated:YES completion:^{NSLog(@"DONE FOR show BLE BGM INFO");}];
}

- (IBAction)showSyncMessage:(id)sender
{
    SyncMessageViewController *msgController;
    msgController = [[SyncMessageViewController alloc] init:nil];
    msgController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:msgController animated:YES completion:^{NSLog(@"DONE FOR show BLE SYNC MESSAGE");}];
}

- (IBAction)showSkipRecords:(id)sender
{
    SkipNumbersViewController *skipController;
    skipController = [[SkipNumbersViewController alloc] init];
    skipController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:skipController animated:YES completion:^{NSLog(@"DONE FOR show SKIP NUMBERS");}];
}


- (void) resultPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (SyncResultViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
@end
