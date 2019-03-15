//
//  BleEquipViewController.m
//  SQX
//
//  Created by h2Sync on 2016/2/2.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "H2Sync.h"
#import "BleBgmPaired.h"
#import "ScannedPeripheral.h"
#import "BleEquipViewController.h"

#import "LibDelegateFunc.h"

#import "H2BleEquipId.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface BleEquipViewController ()

@end

@implementation BleEquipViewController

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
        
        _bgmsName = [[NSArray alloc] initWithObjects:
         
         @"0 : ACCU-CHEK Aviva Connect",
         
         @"1 : FORA GD40B",
         @"2 : FORA_TAIDOC",
         @"3 : FORA_D40_70D",
         @"4 : FORA_P30_PLUS",
         @"5 : FORA_W310B",
         
         @"6 : Biosys -BTM",
         
         @"7 : TRUE METRIX",
         
         @"8 : ONE TOUCH PLUS FLEX",
         

         @"9 : OMRON_HEM-7280T",
         @"10 : OMRON_HBF-254C",
         
         @"11 : ARKRAY_GT-1830",
         
         @"12 : OMRON_HEM_9200T",
         @"13 : OMRON_HEM_6320T",
         
         @"14 : TYSON_HT100",
         
         @"15 : CONTOUR_NEXT_ONE",
         
         //@"16 : H2 BLE CABLE",
         @"16 : AVIVA GUIDE",
         
         @"17 : OMRON_HEM-6324T",
         @"18 : OMRON_HEM-7600T",
         @"19 : OMRON_HBF-256T",
         
         @"20 : MI-SCALE",
         
         @"21 : SM_BLE_MI_BAND_2",
         @"22 : SM_BLE_CONTUR_PLUS_ONE",
         @"23 : ARKRAY_NEO_ALPHA",
                     
         @"24 : ACCU_CHEK_INSTANT",
         @"25 : BIONIME_GM700SB",
         
         @"26 : Fora TN'G",
         @"27 : Fora TN'G Voice",
                     
         @"28 : Garmin 手環",
         @"29 : MICRO-LIFE",
         @"30 : A&D UA-651",
         @"31 : A&D UC-352",
                     
         @"3X : CGM Glucose -HMD",
         @"3X : NOTHING",
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
//    NSString *identifier = @"";//@"1D6E5991-B3E7-4985-1CB2-615B70E3D7BC";
    
    NSLog(@"BLE Select Device ... %d and %d", (int)row, (int)[_bgmsName count]);
    

    NSString *rowString =nil;
    UInt8 snTmp[] = {0x35, 0x32, 0x31, 0x33, 0x31, 0x34, 0x32, 0x00};
    NSData *dataBayerSn = [[NSData alloc]init];
    
    dataBayerSn = [NSData dataWithBytes:snTmp length:sizeof(snTmp)];
    
 /*
    rowString = [_bgmsSerialNumber objectAtIndex:row];
    [LibDelegateFunc sharedInstance].qrStringCode = rowString;
*/
    
    NSLog(@"SN ROW STRING IS %@", rowString);
    
    NSString *sn = [[NSString alloc] init];
    sn = @"";
    UInt32 curMeterId = 0;
    if (row < [_bgmsName count]) {
        // GET NAME or SN for comparing
        NSLog(@"DEV ROW SEL = %d", (int)row);
        switch (row) {
            case ROCHE_AVIVA_CONNECT_SEL:
#if 1
                curMeterId = SM_BLE_ACCUCHEK_AVIVA_CONNECT;
                // 4d616342 6f6f6b50 726f3131 2c31
                [LibDelegateFunc sharedInstance].qrStringCode = @"00594317";
#else
                curMeterId = SM_BLE_ACCUCHEK_AVIVA_GUIDE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"92501394765";
                // [LibDelegateFunc sharedInstance].qrStringCode = @"92501335497";
#endif
                break;
                
            case FORA_GD40B_SEL: // Fora GD40B
                
#if 1
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA;
                //                [LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000247";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000236";
                [LibDelegateFunc sharedInstance].qrStringCode = @"427221605000265A";
#else
                curMeterId = SM_BLE_ACCUCHEK_AVIVA_GUIDE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"92501335497";
#endif
                //                [BleBgmPaired sharedInstance].devIdentifier = @"1D6E5991-B3E7-4985-1CB2-615B70E3D7BC";
                //                _bgmIdentifier = @"08A46850-4258-CF3E-FFBD-2A1845F7530C";
                break;
                
            case FORA_TAIDOC_SEL: // FORA_TAIDOC
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_TAIDOC;
                [LibDelegateFunc sharedInstance].qrStringCode = @"428631542002190F";
                //                [LibDelegateFunc sharedInstance].qrStringCode = @"";
                break;
                
            case FORA_D40_SEL_70D: // FORA_D40
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_D40;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"3261217330001625";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"326121610000070D";
                [LibDelegateFunc sharedInstance].qrStringCode = @"3261216100000673";
                break;
                
            case FORA_P30_PLUS: // FORA_P30_PLUS
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_P30PLUS;
                [LibDelegateFunc sharedInstance].qrStringCode = @"3129417330004207";
                break;
                
            case FORA_W30B_SEL: // FORA_W30B
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_W310B;                
                [LibDelegateFunc sharedInstance].qrStringCode = @"2551216020016807";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"255121602001586C";
                break;

            case BTM_SEL: // BTM
                curMeterId = SM_BLE_CARESENS_EXT_C_BTM;
                [LibDelegateFunc sharedInstance].qrStringCode = @"USV2T5000100";
                //                [BleBgmPaired sharedInstance].devIdentifier = @"B3339C6C-EC70-2CC4-93E0-61E169B7BC87";
                break;
                
            case TRUE_METRIX:
                NSLog(@"=== DID COME TO METRIX ===");
                curMeterId = SM_BLE_BGM_TRUE_METRIX;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"TA0584364";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"TA0582669";
                [LibDelegateFunc sharedInstance].qrStringCode = @"TA0582668"; // 1000 Records
                break;
                
            case ONETOUCH:
                NSLog(@"ONE TOUCH ...");
                curMeterId = SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX; //
                //[LibDelegateFunc sharedInstance].qrStringCode = @"GAJDXR2S";
                [LibDelegateFunc sharedInstance].qrStringCode = @"FAKTQVB0";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"FAKTQQ1Z";
                break;
                
            case OMRON_HEM_7280T:
                curMeterId = SM_BLE_OMRON_HEM_7280T;
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_0000041310051547F600";
                break;
                
            case OMRON_HBF_254C:
                curMeterId = SM_BLE_OMRON_HBF_254C;
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_0001050410010E5E3F01";
                break;
                
            case ARKRAY_GT_1830:
                curMeterId = SM_BLE_ARKRAY_G_BLACK;
                [LibDelegateFunc sharedInstance].qrStringCode = @"5527495";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"7707533";
                break;
                
            case ARKRAY_NEO_ALPHA:
                curMeterId = SM_BLE_ARKRAY_NEO_ALPHA;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"6740185";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"6753509";6753509
                //[LibDelegateFunc sharedInstance].qrStringCode = @"740185";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"753509";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"6701319";
                [LibDelegateFunc sharedInstance].qrStringCode = @"2510292";
                break;
                
            case OMRON_HEM_9200T: // OMRON
                curMeterId = SM_BLE_OMRON_HEM_9200T;
                //20170200002A
                [LibDelegateFunc sharedInstance].qrStringCode = @"20170200002A";//@"X";
                break;
                
            case OMRON_HEM_6320T: // OMRON
                curMeterId = SM_BLE_OMRON_HEM_6320T;
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_000001190F061681D701";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_000001190F061681D70X";
                break;
                
                
            case TYSON_HT100: // TYSON
                curMeterId = SM_BLE_BGM_TYSON_HT100;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"TBMT27158147";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"040011D2"; // 250
                
                [LibDelegateFunc sharedInstance].qrStringCode = @"040011BD"; // 500
                break;

            case CONTOUR_NEXT_ONE: // BAYER
                curMeterId = SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE;
#if 0
                [LibDelegateFunc sharedInstance].qrStringCode = [[NSString alloc] initWithData:dataBayerSn encoding:NSUTF8StringEncoding];
#else
                [LibDelegateFunc sharedInstance].qrStringCode = @"5213142";
#endif
                //[LibDelegateFunc sharedInstance].qrStringCode = @"6008308"; // Contour Plus ONE
                NSLog(@"BAYER NEXT ONE %@ WHAT", [LibDelegateFunc sharedInstance].qrStringCode);
                NSLog(@"BAYER NEXT ONE %d WHAT", [[LibDelegateFunc sharedInstance].qrStringCode length]);

                break;
                
                
            case AVIVA_GUIDE_SEL: // BLE CABLE
                curMeterId = SM_BLE_ACCUCHEK_AVIVA_GUIDE;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"92501394765";
                // [LibDelegateFunc sharedInstance].qrStringCode = @"92501335497";
                [LibDelegateFunc sharedInstance].qrStringCode = @"92501345912"; //
                break;
                
            case OMRON_HEM_6324T:
                curMeterId = SM_BLE_OMRON_HEM_6324T;
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_0000002D11030791E000";
                break;
                
            case OMRON_HEM_7600T:
                curMeterId = SM_BLE_OMRON_HEM_7600T;
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_0000001FEC21E590E056";
                break;
                
            case OMRON_HBF_256T:
                curMeterId = SM_BLE_OMRON_HBF_256T;
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_0001000711051631F900";
                break;
                
            case MI_SCALE_SEL:
                //j curMeterId = SM_BLE_MI_SCALE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"0c80b67476";
                break;
                
            case MI_BAND2_SEL:
                //j curMeterId = SM_BLE_MI_BAND_2;
                [LibDelegateFunc sharedInstance].qrStringCode = @"f3fd97892ec3";
                break;
                
            case SM_BLE_CONTOUR_PLUS_ONE_SEL:
                curMeterId = SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"6008274";
                break;
                
            case ACCU_CHEK_INSTANT_SEL:
                curMeterId = SM_BLE_ACCUCHEK_INSTANT;
                [LibDelegateFunc sharedInstance].qrStringCode = @"96000549938";
                break;
                
            case BIONIME_GM700SB_SEL:
                curMeterId = SM_BLE_BIONIME_GM700SB;
                [LibDelegateFunc sharedInstance].qrStringCode = @"2782QAJ0545";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"6008274";
                break;
                
                
            case FORA_TNG_SEL:
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_TNG;
                [LibDelegateFunc sharedInstance].qrStringCode = @"428321747000996E";
                break;
                
            case FORA_TNG_VOICE_SEL:
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA_TN_G_VOICE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"4282216150021590";
                break;
                
            case GARMIN_SEL:
                curMeterId = SM_BLE_GARMIN;
                [LibDelegateFunc sharedInstance].qrStringCode = @"GARMIN";
                break;
                
            case MICRO_LIFE_SEL:
                curMeterId = SM_BLE_MICRO_LIFE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"H2570256670";
                break;
                
            case AND_UA651_SEL:
                curMeterId = SM_BLE_AND_UA_651BLE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"5161100299";
                break;
                
            case AND_UC352_SEL:
                curMeterId = SM_BLE_AND_UC_352BLE;
                [LibDelegateFunc sharedInstance].qrStringCode = @"5150500204";
                break;
                
            case HMD_SEL: // HMD
            case H2_SPACE:
                 curMeterId = SM_CARESENS_EXT_A_HMD_GL_BLE_EX;
                 [LibDelegateFunc sharedInstance].qrStringCode = @"X";
                 break;
                
            default:
                break;
        }
        
        // curMeterId = SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX;
        [[NSUserDefaults standardUserDefaults] setInteger:curMeterId forKey:@"UDEF_METER_ID"];
    }
    
    
    if (curMeterId & 0x8000) {
        [[NSUserDefaults standardUserDefaults] setObject:[LibDelegateFunc sharedInstance].qrStringCode forKey:@"UDEF_METER_SN"];
    }else{
        //[[NSUserDefaults standardUserDefaults] setObject:[LibDelegateFunc sharedInstance].qrStringCode forKey:@"UDEF_QR_CODE"];
    }
    
    
    NSLog(@"NW METER ID %08X", (unsigned int)curMeterId);
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
    [self dismissViewControllerAnimated:YES completion:^{ [[NSNotificationCenter defaultCenter] postNotificationName:@"MID_SN_NOTIFICATION" object:self];}];
}



+ (BleEquipViewController *)sharedInstance
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
