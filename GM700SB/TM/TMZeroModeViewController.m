//
//  TMZeroModeViewController.m
//  APX
//
//  Created by h2Sync on 2016/6/22.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "LibDelegateFunc.h"
#import "STBViewController.h"

#import "TMZeroModeViewController.h"

@interface TMZeroModeViewController ()

@end




@interface TMZeroModeViewController ()
{
    UIButton *btnZeroRecord;
    
    UIButton *btnScanBLE;
    UIButton *btnListSeviceAndScan;
    
    UIButton *btnListCharAndReadWriteNotify;
    
    UIButton *btnAddToolToList;
    UIButton *btnShowOrDeleteTool;
}

@end



@implementation TMZeroModeViewController

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
                                    target:self action:@selector(bleSwitchTestPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"BLE SW TEST"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        // DEV
        btnZeroRecord = [[UIButton alloc] init];
        btnScanBLE = [[UIButton alloc] init];
        btnListSeviceAndScan = [[UIButton alloc] init];
        
        btnZeroRecord = [UIButton buttonWithType:UIButtonTypeCustom];
        btnScanBLE = [UIButton buttonWithType:UIButtonTypeCustom];
        btnListSeviceAndScan = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [bottunArray addObject:btnZeroRecord];
        [bottunArray addObject:btnScanBLE];
        [bottunArray addObject:btnListSeviceAndScan];
        
        // TOOL
        
        btnListCharAndReadWriteNotify = [[UIButton alloc] init];
        btnAddToolToList = [[UIButton alloc] init];
        btnShowOrDeleteTool = [[UIButton alloc] init];
        
        btnListCharAndReadWriteNotify = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAddToolToList = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowOrDeleteTool = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [bottunArray addObject:btnListCharAndReadWriteNotify];
        [bottunArray addObject:btnAddToolToList];
        [bottunArray addObject:btnShowOrDeleteTool];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"ZERO RECORD"];
        
        [btnString addObject:@"SCAN BLE"];
        [btnString addObject:@"SCAN SERVICE"];
        
        [btnString addObject:@"SCAN CHAR"];
        
        [btnString addObject:@"TOOL ADD ..."];
        [btnString addObject:@"TOOL SHOW-DEL"];
        
        
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnSwitchMethod in bottunArray) {
            //            btnBleMethod = [UIButton buttonWithType:UIButtonTypeCustom];
            
            
            btnSwitchMethod.frame = CGRectMake(20, 60 + 40 + btnIndex * 60, 280, 40);
            
            [btnSwitchMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnSwitchMethod.layer setMasksToBounds:YES];
            [btnSwitchMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnSwitchMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnSwitchMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            [btnSwitchMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnSwitchMethod addTarget:self action:@selector(zeroRecordTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnSwitchMethod addTarget:self action:@selector(scanBLETask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnSwitchMethod addTarget:self action:@selector(scanServiceTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 3:
                    [btnSwitchMethod addTarget:self action:@selector(scanCharTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 4:
                    [btnSwitchMethod addTarget:self action:@selector(toolAdding:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 5:
                    [btnSwitchMethod addTarget:self action:@selector(toolListingOrDelete:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
            
            
            [self.view addSubview:btnSwitchMethod];
            btnIndex++;
        }
        self.view.backgroundColor = [UIColor whiteColor];
    }
    NSLog(@"TM SWITCH PAGE");
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

- (IBAction)zeroRecordTask:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"ZERO RECODER";
    
//    [H2Sync sharedInstance]
    [[H2Sync sharedInstance] h2ZeroRecordTest:YES];
    // START SW TEST ...
//    [[H2TMSwitch sharedInstance]testModeSwitchStart];
    
//    STBViewController *stbController =[[STBViewController alloc] init];
//    [self presentViewController:stbController animated:YES completion:^{NSLog(@"SW TEST_STB done");}];
}



- (IBAction)scanBLETask:(id)sender
{
    
//    [[H2TMSwitch sharedInstance] testModeSwitchReset];
    
    NSLog(@"RESET AND INIT SW MODE");
    
    //   STBViewController *stbController =[[STBViewController alloc] init];
    //    [self presentViewController:stbController animated:YES completion:^{NSLog(@"SW RESET_STB done");}];
}

- (IBAction)scanServiceTask:(id)sender
{
    //    SNWriteViewController *snwController =[[SNWriteViewController alloc] init];
    //    [self presentViewController:snwController animated:YES completion:^{NSLog(@"SN_WRITE done");}];
    
}

- (IBAction)scanCharTask:(id)sender
{
//    [H2TMSwitch sharedInstance].scanMode = YES;
    // 選擇序號後開始掃描，並連結
    // 可能沒有ID,
    // 有 ID 直接連結，不用掃描
/*
    Byte *tmpHeader;
    tmpHeader = (Byte *)malloc(6);
    //    unsigned char tmp[] = {0x01, 0x06, 0x03, 0x04, 0x05, 0x07};
    memcpy(tmpHeader, cmdHeader, 6);
    
    NSLog(@"TOOL - SCANNING ...");
    
    //    2EE9BC5F-F591-FC91-AB9A-41562D657B67
    NSString *toolID = [NSString stringWithFormat:@"2EE9BC5F-F591-FC91-AB9A-41562D657B67"];
    
    //    NSString *toolID = [NSString stringWithFormat:@"C69FA63F-4A55-0307-8908-D46E104A6468"];
    
    NSLog(@"TOOL'S SN IS %@", [LibDelegateFunc sharedInstance].qrStringCode);
    [[H2TestMode sharedInstance] TMSWToolModeScanAndAdding:[LibDelegateFunc sharedInstance].qrStringCode withIdentifier:toolID meterHeader:tmpHeader];
*/
}

- (IBAction)toolAdding:(id)sender
{
/*
    [H2TMSwitch sharedInstance].scanMode = YES;
    // 掃描序號，顯示掃描結果
    NSDictionary *toolSerialNumberNew = nil;
    toolSerialNumberNew = @{@"TOOL_SerialNumber" : @"", @"TOOL_Identifier" : @""};
    //    toolSerialNumberNew = @{@"TOOL_SerialNumber" : toolSerialNumber, @"TOOL_Identifier" : toolIdentifier };
    
    //    NSString *stringSerialNumberFromQRCode = [toolCable objectForKey: @"TOOL_SerialNumber"];
    
    // 進入掃描 QR Code 頁面
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"qrString"];
    QRCodeViewController *qrScanController = [[QRCodeViewController alloc] init];
    qrScanController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:qrScanController animated:YES completion:^{NSLog(@"done");}];
    NSLog(@"TOOL - ADDING ...");
*/
}

- (IBAction)toolListingOrDelete:(id)sender
{
/*
    [H2TMSwitch sharedInstance].scanMode = NO;
    // 顯示 目前表單內的 TOOL
    NSLog(@"TOOL - SHOW - TOOL CABLE ...");
    ToolCableTableViewController *toolTableController;
    toolTableController = [[ToolCableTableViewController alloc] init:nil];
    toolTableController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:toolTableController animated:YES completion:^{NSLog(@"DONE FOR show TOOL CABLE TABLE");}];
*/
}



- (void)bleSwitchTestPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#if 0

@implementation TMZeroModeViewController

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

@end

#endif
