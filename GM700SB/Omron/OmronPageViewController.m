//
//  OmronPageViewController.m
//  OEMT
//
//  Created by h2Sync on 2017/3/27.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "LibDelegateFunc.h"
#import "OmronRecordViewController.h"
#import "OmronPageViewController.h"

#import "H2BleEquipId.h"

@interface OmronPageViewController ()
{
    UIButton *btnShowUser1Records;
    UIButton *btnShowUser2Records;
    UIButton *btnShowUser3Records;
    UIButton *btnShowUser4Records;
}

@end

@implementation OmronPageViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(recordsPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"SHOW RECORDS"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        // BUTTON
        btnShowUser1Records = [[UIButton alloc] init];
        btnShowUser2Records = [[UIButton alloc] init];
        btnShowUser3Records = [[UIButton alloc] init];
        btnShowUser4Records = [[UIButton alloc] init];
        
        // Button Customer
        btnShowUser1Records = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowUser2Records = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowUser3Records = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowUser4Records = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnShowUser1Records];
        [bottunArray addObject:btnShowUser2Records];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"] == SM_BLE_OMRON_HBF_254C) {
            [bottunArray addObject:btnShowUser3Records];
            [bottunArray addObject:btnShowUser4Records];
        }
        if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BW){
            
        }
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"OM U1 RECORDS"];
        [btnString addObject:@"OM U2 RECORDS"];
        [btnString addObject:@"OM U3 RECORDS"];
        [btnString addObject:@"OM U4 RECORDS"];
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            
            btnBleMethod.frame = CGRectMake(20, 100 + 40 + btnIndex * (60+20), 280, 40);
            
            [btnBleMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnBleMethod.layer setMasksToBounds:YES];
            [btnBleMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnBleMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnBleMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            [btnBleMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnBleMethod addTarget:self action:@selector(showU1Records:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(showU2Records:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(showU3Records:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 3:
                    [btnBleMethod addTarget:self action:@selector(showU4Records:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
            
            
            [self.view addSubview:btnBleMethod];
            btnIndex++;
        }
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    UInt8 cmd[] = {
        0x18, 0x01, 0xc0, 0x02, 0x00, 0x10, 0x82, 0x00
        , 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x03
        , 0x86, 0x84, 0x00, 0x00, 0xAE, 0xE8, 0x00, 0xBE
    };
    UInt8 tmp = 0;
    for (int i=0; i<sizeof(cmd); i++) {
        tmp ^= cmd[i];
        //NSLog(@"CMD %d, %02X, %02X", i, tmp, cmd[i]);
        NSLog(@"OMRON PAGE VIEW INIT");
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


#pragma mark - SHOW RECORDS

- (IBAction)showU1Records:(id)sender
{
    
    if([[LibDelegateFunc sharedInstance].bpRecordsResult count]> 0){
        [[LibDelegateFunc sharedInstance].bpRecordsResult removeAllObjects];
    }
    if([[LibDelegateFunc sharedInstance].bwRecordsResult count]> 0){
        [[LibDelegateFunc sharedInstance].bwRecordsResult removeAllObjects];
    }
    
    if([[LibDelegateFunc sharedInstance].omronRecordsUserA count] > 0){
        if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BP){
            [[LibDelegateFunc sharedInstance].bpRecordsResult addObjectsFromArray:[LibDelegateFunc sharedInstance].omronRecordsUserA];
        }
        if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BW){
            [[LibDelegateFunc sharedInstance].bwRecordsResult addObjectsFromArray:[LibDelegateFunc sharedInstance].omronRecordsUserA];
        }
        
    }else{
        
    }
    
     [self showRecordsPage];
}

- (IBAction)showU2Records:(id)sender
{
    if([[LibDelegateFunc sharedInstance].bpRecordsResult count]> 0){
        [[LibDelegateFunc sharedInstance].bpRecordsResult removeAllObjects];
    }
    if([[LibDelegateFunc sharedInstance].bwRecordsResult count]> 0){
        [[LibDelegateFunc sharedInstance].bwRecordsResult removeAllObjects];
    }
    
    if([[LibDelegateFunc sharedInstance].omronRecordsUserB count] > 0){
        if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BP){
            [[LibDelegateFunc sharedInstance].bpRecordsResult addObjectsFromArray:[LibDelegateFunc sharedInstance].omronRecordsUserB];
        }
        if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BW){
            [[LibDelegateFunc sharedInstance].bwRecordsResult addObjectsFromArray:[LibDelegateFunc sharedInstance].omronRecordsUserB];
        }
    }
    
     [self showRecordsPage];
}


    

- (IBAction)showU3Records:(id)sender
{
    if([[LibDelegateFunc sharedInstance].bwRecordsResult count]> 0){
        [[LibDelegateFunc sharedInstance].bwRecordsResult removeAllObjects];
    }
    if([[LibDelegateFunc sharedInstance].omronRecordsUserC count] > 0){
        [[LibDelegateFunc sharedInstance].bwRecordsResult addObjectsFromArray:[LibDelegateFunc sharedInstance].omronRecordsUserC];
    }
    
     [self showRecordsPage];
}

- (IBAction)showU4Records:(id)sender
{
    if([[LibDelegateFunc sharedInstance].bwRecordsResult count]> 0){
        [[LibDelegateFunc sharedInstance].bwRecordsResult removeAllObjects];
    }
    if([[LibDelegateFunc sharedInstance].omronRecordsUserD count] > 0){
        [[LibDelegateFunc sharedInstance].bwRecordsResult addObjectsFromArray:[LibDelegateFunc sharedInstance].omronRecordsUserD];
    }
    
    [self showRecordsPage];
}

- (IBAction)recordsPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showRecordsPage
{
    OmronRecordViewController *omRecordsController = [[OmronRecordViewController alloc] init];
    if (omRecordsController != nil) {
        omRecordsController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:omRecordsController animated:YES completion:^{NSLog(@"DONE FOR -->  OMRON RCORDS");}];
    }else{
        NSLog(@"CONTROL IS NIL ....");
    }
}


@end
