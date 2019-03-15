//
//  TMItemViewController.m
//  APX
//
//  Created by h2Sync on 2016/4/20.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "SQXViewController.h"
//#import "BLEViewController.h"
#import "BleBeFoundViewController.h"
#import "BleBGMViewController.h"

#import "LibDelegateFunc.h"

#import "STBViewController.h"

#import "TMItemViewController.h"

#import "SNWriteViewController.h"

#import "TMSwitch.h"

#import "TMZeroModeViewController.h"

@interface TMItemViewController ()
{
    UIButton *btnSwitchBle;
    UIButton *btnSwitchAudio;
    UIButton *btnSerialNumber;
    
    UIButton *btnSwitchBiOnime;
    UIButton *btnSwitchApex;
    UIButton *btnSwitchBayer;
    
    UIButton *btnZeroMode;

}



@end

@implementation TMItemViewController
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
                                    target:self action:@selector(testModePageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"TEST MODE SEL"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        // LABEL
/*
        labelBleDevice = [[UILabel alloc] init];
        
        labelBleDevice.frame = CGRectMake(20, 50, 160, 40);
        
        [labelBleDevice setFont:[UIFont fontWithName:@"System" size:26]];
        
        [labelBleDevice setBackgroundColor:[UIColor whiteColor]];
        [labelBleDevice setTextColor:[UIColor redColor]];
        
        [labelBleDevice.layer setMasksToBounds:YES];
        [labelBleDevice.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [labelBleDevice.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        
        labelBleDevice.text = @"NO QR STRING";
        [self.view addSubview:labelBleDevice];
*/
        // BUTTON
        btnSwitchBle = [[UIButton alloc] init];
        btnSwitchAudio = [[UIButton alloc] init];
        btnSerialNumber = [[UIButton alloc] init];
        
        btnSwitchBiOnime = [[UIButton alloc] init];
        btnSwitchApex = [[UIButton alloc] init];
        btnSwitchBayer = [[UIButton alloc] init];
        
        btnZeroMode = [[UIButton alloc] init];
        
        
        
        btnSwitchBle = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSwitchAudio = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSerialNumber = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnSwitchBiOnime = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSwitchApex = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSwitchBayer = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnZeroMode = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnSwitchBle];
        [bottunArray addObject:btnSwitchAudio];
        [bottunArray addObject:btnSerialNumber];
        
        [bottunArray addObject:btnSwitchBiOnime];
        [bottunArray addObject:btnSwitchApex];
        [bottunArray addObject:btnSwitchBayer];
        
        [bottunArray addObject:btnZeroMode];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"TM SW BLE"];
        [btnString addObject:@"TM SW AUDIO"];
        [btnString addObject:@"TM SN"];
        
        [btnString addObject:@"TM SW BIONIME"];
        [btnString addObject:@"TM SW APEX"];
        [btnString addObject:@"TM SW BAYER"];
        
        [btnString addObject:@"ZERO RECORD"];
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            //            btnBleMethod = [UIButton buttonWithType:UIButtonTypeCustom];
            
            
            btnBleMethod.frame = CGRectMake(20, 60 + 40 + btnIndex * 60, 280, 40);
            
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
                    [btnBleMethod addTarget:self action:@selector(tmSwitchBle:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(tmSwitchAudio:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(tmSerialNumber:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 3:
                    [btnBleMethod addTarget:self action:@selector(tmSwtitchBionime:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 4:
                    [btnBleMethod addTarget:self action:@selector(tmSwitchApex:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 5:
                    [btnBleMethod addTarget:self action:@selector(tmSwitchBayer:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 6:
                    [btnBleMethod addTarget:self action:@selector(tmZeroRecord:) forControlEvents:UIControlEventTouchUpInside];
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


- (IBAction)tmSwitchBle:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE SWITCH";
    
    TMSwitchViewController *tmSwitchController =[[TMSwitchViewController alloc] init];
    [self presentViewController:tmSwitchController animated:YES completion:^{NSLog(@"TM SWMODE done");}];
}



- (IBAction)tmSwitchAudio:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE PAIRING";
    UInt8 result = 0;
    result = [[H2Sync sharedInstance] h2BlePairing:[LibDelegateFunc sharedInstance].userID withUserEmail:[LibDelegateFunc sharedInstance].userEMail];
    
    NSLog(@"PAIR RETURN VALUE %d", result);
    
    NSLog(@"BLE PAIR METER ID is %04X", [[NSUserDefaults standardUserDefaults] integerForKey:@"meter_sel"]);
    
    
    STBViewController *stbController =[[STBViewController alloc] init];
    [self presentViewController:stbController animated:YES completion:^{NSLog(@"PAIR_STB done");}];
}

- (IBAction)tmSerialNumber:(id)sender
{
    SNWriteViewController *snwController =[[SNWriteViewController alloc] init];
    [self presentViewController:snwController animated:YES completion:^{NSLog(@"SN_WRITE done");}];
/*
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE SYNC";
    NSLog(@"BLE METER ID is %04X", [[NSUserDefaults standardUserDefaults] integerForKey:@"meter_sel"]);
    
    
    BOOL snStatus = NO;
    NSString *uuidString;
    
    NSMutableArray *pUuidAndSn = [[NSMutableArray alloc] init];
    
    
    pUuidAndSn = [[NSUserDefaults standardUserDefaults] objectForKey:@"PERIPHERALS_OBJ"];
    
    NSLog(@"THE OUTPUT IS %@", pUuidAndSn);
    
    NSLog(@"USER SELECT SN IS %@", [LibDelegateFunc sharedInstance].qrStringCode);
    
    for (NSDictionary *info in pUuidAndSn){
        NSLog(@"the CURRENT serial number is %@", [info objectForKey: @"BLE_SERIALNUMBER"]);
        
        
        if ([[LibDelegateFunc sharedInstance].qrStringCode isEqualToString:[info objectForKey: @"BLE_SERIALNUMBER"]]) {
            // SET YES, AND TRANSFER STRING TO CBUUID
            snStatus = YES;
            uuidString = [info objectForKey: @"BLE_IDENTIFIER"];
            
            NSLog(@"UUID String IS ---- %@", uuidString );
            
            
            break;
        }
        
    }
    
    
    if (snStatus) {
        NSLog(@"OK -- SN AT CONNECT");
        
    }else{
        NSLog(@"ERROR SN AT CONNECT");
    }
    
    // for test
    if ([[LibDelegateFunc sharedInstance].serverLastDateTimes count] > 0) {
        [[LibDelegateFunc sharedInstance].serverLastDateTimes removeAllObjects];
    }
    
    //   [[H2Sync sharedInstance] h2BlePreSync:[LibDelegateFunc sharedInstance].serverLastDateTimes withSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode];
    
    UInt8 status = [[H2Sync sharedInstance] h2BlePreSync:uuidString withLastDateTime:[LibDelegateFunc sharedInstance].serverLastDateTimes withSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode];
    
    
    //   - (UInt8)h2BlePreSync:(NSString *)identifierString withLastDateTime:(NSArray *)serverLastDateTimeArray withSerialNumber:(NSString *)sn;
    
    NSLog(@"RECONNECCT STATUS IS %d", status);
    
    STBViewController *stbController =[[STBViewController alloc] init];
    [self presentViewController:stbController animated:YES completion:^{NSLog(@"SYNC_STB done");}];
*/
}

- (IBAction)tmSwtitchBionime:(id)sender
{
    
}

- (IBAction)tmSwitchApex:(id)sender
{
    
}

- (IBAction)tmSwitchBayer:(id)sender
{
    
}

#pragma mark - ZERO MODE TEST
- (IBAction)tmZeroRecord:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"ZERO MODE";
    
    TMZeroModeViewController *tmZeroModeController =[[TMZeroModeViewController alloc] init];
    [self presentViewController:tmZeroModeController animated:YES completion:^{NSLog(@"TM ZERO MODE done");}];
}

- (void)testModePageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
