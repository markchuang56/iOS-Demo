//
//  BleBGMViewController.m
//  SQX
//
//  Created by h2Sync on 2016/2/2.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "H2Sync.h"
#import "BleBgmPaired.h"
#import "ScannedPeripheral.h"
#import "BleBGMViewController.h"

#import "LibDelegateFunc.h"

#import "H2BleEquipId.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface BleBGMViewController ()

@end

@implementation BleBGMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (id)init:(NSMutableArray *)bleDevices
{
    self = [super init];
    if (self) {
        
        _bgmsName =
        [[NSArray alloc] initWithObjects:
         @"ACCU-CHEK Aviva Connect",
         
         @"FORA GD40B",
         @"FORA_TAIDOC",
         
         @"FORA_D40_70D",
         @"FORA_P30_PLUS",
         @"FORA_W310B",
         //         @"Apexbio1013_43",
         //@"Apexbio Test",
         @"Biosys -BTM",
         
         @"TRUE METRIX",
         @"ONE TOUCH PLUS FLEX",
         
         //@"CGM Glucose -HMD",
         
         nil];
        
        _bgmsSerialNumber =
        [[NSArray alloc] initWithObjects:
         @"ACCU-CHEK Aviva Connect",
         
         @"FORA GD40B",
         @"TAIDOC TD4286",
         @"FORA D40_70D",
         @"FORA D40_673",
         @"FORA_W310B",
         
         //         @"Apexbio1013_43",
         //@"Apexbio Test",
         @"Biosys -BTM",
         
         @"True Mestrix",
         @"ONE TOUCH PLUS FLEX",
         
         //@"CGM Glucose -HMD",
         
         nil];
        // Custom initialization
        //        peripherals = [[NSMutableArray alloc]init];
        //        [peripherals addObjectsFromArray:bleDevices];
        
        UINavigationBar *navDevBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navDevBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(bgmBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"BLE Meters"];
        
        navItem.leftBarButtonItem = btnBack;
        [navDevBar pushNavigationItem:navItem animated:NO];
        
        UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460)];
        aTableView.dataSource = self; aTableView.delegate = self;
        [self.view addSubview:aTableView];
    }
    return self;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_bgmsName count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             DisclosureButtonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: DisclosureButtonCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    
    NSString *rowString =nil;
    
    NSLog(@"row %lu cel %p", (unsigned long)row, cell);
    
    rowString = [_bgmsName objectAtIndex:row];
    
    if (row < 6) {
        rowString = [rowString stringByAppendingString:[_bgmsSerialNumber objectAtIndex:row]];
    }
    
    
    
    cell.textLabel.text = rowString;
    
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"select this section %ld row %ld", (long)indexPath.section, (long)indexPath.row];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(title,nil);
    
    NSUInteger row = indexPath.row;
    
    NSString *rowString =nil;
    rowString = [_bgmsSerialNumber objectAtIndex:row];
    
    [LibDelegateFunc sharedInstance].qrStringCode = rowString;
    
    NSLog(@"SN ROW STRING IS %@", rowString);
    
    NSString *sn = [[NSString alloc] init];
    sn = @"";
    UInt32 curMeterId = 0;//0x0020; // for ONE TOUCH CABLE
    if (row < [_bgmsName count]) {
        // GET NAME or SN for comparing
        switch (row) {
            case ROCHE_AVIVA_CONNECT_SEL:
                curMeterId = SM_BLE_ACCUCHEK_AVIVA_CONNECT;
                // 4d616342 6f6f6b50 726f3131 2c31
                //[LibDelegateFunc sharedInstance].qrStringCode = @"00594317";
                [LibDelegateFunc sharedInstance].qrStringCode = @"92501335497";
                break;
                
            case FORA_GD40B_SEL: // Fora GD40B
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA;
                //                [LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000247";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000236";
                [LibDelegateFunc sharedInstance].qrStringCode = @"427221605000265A";
                break;
                
            case FORA_TAIDOC_SEL: // FORA_TAIDOC
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_TAIDOC;
                [LibDelegateFunc sharedInstance].qrStringCode = @"428631542002190F";
//                [LibDelegateFunc sharedInstance].qrStringCode = @"";
                break;
                
            case FORA_D40_SEL_70D: // FORA_D40
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_D40;
                [LibDelegateFunc sharedInstance].qrStringCode = @"326121610000070D";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"3261216100000673";
                break;
                
            case FORA_P30_PLUS: // FORA_P30_PLUS
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_P30PLUS;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"3261216100000673";
                [LibDelegateFunc sharedInstance].qrStringCode = @"3129417330004207";
                break;
                
            case FORA_W30B_SEL: // FORA_W30B
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_W310B;
                [LibDelegateFunc sharedInstance].qrStringCode = @"255121602001586C";
                break;

            case BTM_SEL: // BTM
                curMeterId = SM_BLE_CARESENS_EXT_C_BTM;
                [LibDelegateFunc sharedInstance].qrStringCode = @"USV2T5000100";
                break;
                
            case TRUE_METRIX:
                curMeterId = SM_BLE_BGM_TRUE_METRIX;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"TA0584364";
                [LibDelegateFunc sharedInstance].qrStringCode = @"TA0582669";
                break;
                
            case ONETOUCH:
                curMeterId = SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX;
                [LibDelegateFunc sharedInstance].qrStringCode = @"GAJDXR2S";
                break;
                
            default:
                break;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:curMeterId forKey:@"UDEF_METER_ID"];
    }
    
    //    [[H2Sync sharedInstance] h2BleSerialNumber:rowString withIdentifier:identifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BGM_SHOW" object:self];
    NSLog(@"BLE CURRENT METER ID is %04X", [[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"]);
    
    
    [BleBgmPaired sharedInstance].testNumber++;
    NSLog(@"TEST VALUE IS %d", [BleBgmPaired sharedInstance].testNumber);
    
    NSLog(@"h2 SN %@", [BleBgmPaired sharedInstance].peripheralsHasPaired);
    if ([[BleBgmPaired sharedInstance].peripheralsHasPaired count] > 0) {
        for (ScannedPeripheral *sensor in [BleBgmPaired sharedInstance].peripheralsHasPaired) {
            if ([sensor.bleScanSerialNumber isEqualToString:sn]) {
                // Connect And Sync
                NSLog(@"GOT IT!!");
                break;
            }
        }
        NSLog(@"A NEW BGM HAS SELECTED");
    }else{
        NSLog(@"NEW BGM HAS SELECTED");
    }
    [self bgmBack:nil];
}

- (void) bgmBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


+ (BleBGMViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
//        peripheralsHasPaired = [[NSMutableArray alloc] init];
    });
    NSLog(@"BLE BGM VIEW instance value @%@", _sharedObject);
    return _sharedObject;
}


@end
