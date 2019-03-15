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
#import "BleGateViewController.h"

#import "LibDelegateFunc.h"

#import "H2BleEquipId.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface BleGateViewController ()

@end

@implementation BleGateViewController

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
         
         @"0 : BLE BGM",
         @"1 : BLE FORA",
         @"2 : BLE OMRON",
         @"3 : BLE ARKRAY",
         @"4 : BLE ELSE",
         @"5 : BLE MI",
         @"6 : BLE ONE TOUCH PLUS FLEX",
         nil];

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
    
    NSLog(@"BLE Select Device ... %d and %d", row, [_bgmsName count]);
    

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
        switch (row) {
            case ROCHE_AVIVA_CONNECT_SEL:
                curMeterId = SM_BLE_ACCUCHEK_AVIVA_CONNECT;
                // 4d616342 6f6f6b50 726f3131 2c31
                [LibDelegateFunc sharedInstance].qrStringCode = @"00594317";
                break;
                
            case FORA_GD40B_SEL: // Fora GD40B
                curMeterId = SM_BLE_CARESENS_EXT_B_FORA;
                //                [LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000247";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000236";
                [LibDelegateFunc sharedInstance].qrStringCode = @"427221605000265A";
                
                
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
                curMeterId = SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX;
                [LibDelegateFunc sharedInstance].qrStringCode = @"GAJDXR2S";
                break;
                
            case OMRON_HEM_7280T:
                curMeterId = SM_BLE_OMRON_HEM_7280T;
                //[LibDelegateFunc sharedInstance].qrStringCode = @"7280T-XXX";
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_0000041310051547F600";
                break;
                
            case OMRON_HBF_254C:
                curMeterId = SM_BLE_OMRON_HBF_254C;
                [LibDelegateFunc sharedInstance].qrStringCode = @"BLEsmart_0001050410010E5E3F01";
                break;
                
            case ARKRAY_GT_1830:
                curMeterId = SM_BLE_ARKRAY_G_BLACK;
                [LibDelegateFunc sharedInstance].qrStringCode = @"5527495";
                break;
                
            case ARKRAY_NEO_ALPHA:
                curMeterId = SM_BLE_ARKRAY_NEO_ALPHA;
                [LibDelegateFunc sharedInstance].qrStringCode = @"6740185";
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
                [LibDelegateFunc sharedInstance].qrStringCode = @"92501394765";
                //[LibDelegateFunc sharedInstance].qrStringCode = @"92501335497";
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
                // curMeterId = SM_BLE_MI_SCALE;
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
                
            case HMD_SEL: // HMD
            case H2_SPACE:
                 curMeterId = SM_CARESENS_EXT_A_HMD_GL_BLE_EX;
                 [LibDelegateFunc sharedInstance].qrStringCode = @"X";
                 break;
                
            default:
                break;
        }
        
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

- (void)meterID
{/*
    NSNumber *mid = [NSNumber numberWithInt:2];
    NSDictionary *dicRocheConnect = [[NSDictionary alloc] init];
    dicRocheConnect = @{
                        @"BLE_MID" : mid,
                        @"BLE_MSN" : @"",
                        };
   */
    
    /*
    static const UInt32 meterIdForBleBgm[]{
        
    };
    
    static const UInt32 snForBleBgm[]{
        
    };
    
    static const UInt32 meterIdForBleBgm[]{
        
    };
    
    static const UInt32 meterIdForBleBgm[]{
        
    };
    
    static const UInt32 meterIdForBleBgm[]{
        
    };
    */
    
    /* BLE BGM */
    NSNumber *midRocheConnect = [NSNumber numberWithInt:SM_BLE_ACCUCHEK_AVIVA_CONNECT];
    NSDictionary *dicRocheConnect = [[NSDictionary alloc] init];
    dicRocheConnect = @{ // 4d616342 6f6f6b50 726f3131 2c31
                        @"BLE_MID" : midRocheConnect,
                        @"BLE_MSN" : @"00594317",
                        };
    
    
    NSNumber *midRocheGuide = [NSNumber numberWithInt:SM_BLE_ACCUCHEK_AVIVA_GUIDE];
    NSDictionary *dicRocheGuide = [[NSDictionary alloc] init];
    dicRocheGuide = @{
                      @"BLE_MID" : midRocheGuide,
                      @"BLE_MSN" : @"92501394765",
                      };
    //[LibDelegateFunc sharedInstance].qrStringCode = @"92501335497";
    
    
    NSNumber *midMetrix = [NSNumber numberWithInt:SM_BLE_BGM_TRUE_METRIX];
    NSDictionary *dicMetrix = [[NSDictionary alloc] init];
    dicMetrix = @{
                  @"BLE_MID" : midMetrix,
                  @"BLE_MSN" : @"TA0582668",
                  };
    //[LibDelegateFunc sharedInstance].qrStringCode = @"TA0584364";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"TA0582669";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"TA0582668"; // 1000 Records
    
    NSNumber *midContourNextOne = [NSNumber numberWithInt:SM_BLE_BGM_BAYER_CONTOUR_NEXT_ONE];
    NSDictionary *dicContourNextOne = [[NSDictionary alloc] init];
    dicContourNextOne = @{
                          @"BLE_MID" : midContourNextOne,
                          @"BLE_MSN" : @"00594317",
                          };
    //[LibDelegateFunc sharedInstance].qrStringCode = @"6008308"; // Contour Plus ONE ???
    
    NSNumber *midContourPlusOne = [NSNumber numberWithInt:SM_BLE_BGM_BAYER_CONTOUR_PLUS_ONE];
    NSDictionary *dicContourPlusOne = [[NSDictionary alloc] init];
    dicContourPlusOne = @{
                          @"BLE_MID" : midContourPlusOne,
                          @"BLE_MSN" : @"6008274",
                          };
    
    
    NSNumber *midTysonHT100 = [NSNumber numberWithInt:SM_BLE_BGM_TYSON_HT100];
    NSDictionary *dicTysonHT100 = [[NSDictionary alloc] init];
    dicTysonHT100 = @{
                      @"BLE_MID" : midTysonHT100,
                      @"BLE_MSN" : @"040011BD",
                      };
    //[LibDelegateFunc sharedInstance].qrStringCode = @"TBMT27158147";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"040011D2"; // 250
    //[LibDelegateFunc sharedInstance].qrStringCode = @""; // 500


    
    /* FORA */
    NSNumber *midGD40B = [NSNumber numberWithInt:SM_BLE_CARESENS_EXT_B_FORA];
    NSDictionary *dicForaGD40B = [[NSDictionary alloc] init];
    dicForaGD40B = @{
                        @"BLE_MID" : midGD40B,
                        @"BLE_MSN" : @"427221605000265A",
                        };
    
    //[LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000247";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"4272215370000236";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"427221605000265A";
    

    NSNumber *midTaidoc = [NSNumber numberWithInt:SM_BLE_CARESENS_EXT_B_FORA_TAIDOC];
    NSDictionary *dicForaTaidoc = [[NSDictionary alloc] init];
    dicForaTaidoc = @{
                        @"BLE_MID" : midTaidoc,
                        @"BLE_MSN" : @"428631542002190F",
                        };
    // [LibDelegateFunc sharedInstance].qrStringCode = @"428631542002190F";
    //                [LibDelegateFunc sharedInstance].qrStringCode = @"";
    
    
    NSNumber *midForaD40 = [NSNumber numberWithInt:SM_BLE_CARESENS_EXT_B_FORA_D40];
    NSDictionary *dicForaD40 = [[NSDictionary alloc] init];
    dicForaD40 = @{
                        @"BLE_MID" : midForaD40,
                        @"BLE_MSN" : @"3261216100000673",
                        };
    
    //[LibDelegateFunc sharedInstance].qrStringCode = @"3261217330001625";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"326121610000070D";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"3261216100000673";
    
    NSNumber *midForaP30Plus = [NSNumber numberWithInt:SM_BLE_CARESENS_EXT_B_FORA_P30PLUS];
    NSDictionary *dicForaP30Plus = [[NSDictionary alloc] init];
    dicForaP30Plus = @{
                        @"BLE_MID" : midForaP30Plus,
                        @"BLE_MSN" : @"3129417330004207",
                        };
    

    NSNumber *midForaW310B = [NSNumber numberWithInt:SM_BLE_CARESENS_EXT_B_FORA_W310B];
    NSDictionary *dicForaW310B = [[NSDictionary alloc] init];
    dicForaW310B = @{
                        @"BLE_MID" : midForaW310B,
                        @"BLE_MSN" : @"2551216020016807",
                        };
    
    //[LibDelegateFunc sharedInstance].qrStringCode = @"2551216020016807";
    //[LibDelegateFunc sharedInstance].qrStringCode = @"255121602001586C";
    
    

 /*
case ONETOUCH:
    curMeterId = SM_BLE_BGM_ONE_TOUCH_PLUS_FLEX;
    [LibDelegateFunc sharedInstance].qrStringCode = @"GAJDXR2S";
    break;
   */
    

    /* OMRON */
    NSNumber *midOmronHem7280T = [NSNumber numberWithInt:SM_BLE_OMRON_HEM_7280T];
    NSDictionary *dicOmronHem7280T = [[NSDictionary alloc] init];
    dicOmronHem7280T = @{
                        @"BLE_MID" : midOmronHem7280T,
                        @"BLE_MSN" : @"BLEsmart_0000041310051547F600",
                        };
    
    NSNumber *midOmronHem6320T = [NSNumber numberWithInt:SM_BLE_OMRON_HEM_6320T];
    NSDictionary *dicOmronHem6320T = [[NSDictionary alloc] init];
    dicOmronHem6320T = @{
                         @"BLE_MID" : midOmronHem6320T,
                         @"BLE_MSN" : @"BLEsmart_000001190F061681D701",
                         };
    
    NSNumber *midOmronHem6324T = [NSNumber numberWithInt:SM_BLE_OMRON_HEM_6324T];
    NSDictionary *dicOmronHem6324T = [[NSDictionary alloc] init];
    dicOmronHem6324T = @{
                         @"BLE_MID" : midOmronHem6324T,
                         @"BLE_MSN" : @"BLEsmart_0000002D11030791E000",
                         };
    
    NSNumber *midOmronHem7600T = [NSNumber numberWithInt:SM_BLE_OMRON_HEM_7600T];
    NSDictionary *dicOmronHem7600T = [[NSDictionary alloc] init];
    dicOmronHem7600T = @{
                         @"BLE_MID" : midOmronHem7600T,
                         @"BLE_MSN" : @"BLEsmart_0000001FEC21E590E056",
                         };

    

    
    
    
    NSNumber *midOmronHbf254C = [NSNumber numberWithInt:SM_BLE_OMRON_HBF_254C];
    NSDictionary *dicOmronHbf254C = [[NSDictionary alloc] init];
    dicOmronHbf254C = @{
                         @"BLE_MID" : midOmronHbf254C,
                         @"BLE_MSN" : @"BLEsmart_0001050410010E5E3F01",
                         };
    
    NSNumber *midOmronHbf256T = [NSNumber numberWithInt:SM_BLE_OMRON_HBF_256T];
    NSDictionary *dicOmronHbf256T = [[NSDictionary alloc] init];
    dicOmronHbf256T = @{
                         @"BLE_MID" : midOmronHbf256T,
                         @"BLE_MSN" : @"BLEsmart_0001000711051631F900",
                         };
    
    
    NSNumber *midOmronHem9200T = [NSNumber numberWithInt:SM_BLE_OMRON_HEM_9200T];
    NSDictionary *dicOmronHem9200T = [[NSDictionary alloc] init];
    dicOmronHem9200T = @{
                         @"BLE_MID" : midOmronHem9200T,
                         @"BLE_MSN" : @"20170200002A",
                         };
    
    
    /* ARKRAY */
    NSNumber *midArkrayGBlack = [NSNumber numberWithInt:SM_BLE_ARKRAY_G_BLACK];
    NSDictionary *dicArkrayGBlack = [[NSDictionary alloc] init];
    dicArkrayGBlack = @{
                         @"BLE_MID" : midArkrayGBlack,
                         @"BLE_MSN" : @"5527495",
                         };
    
    
    
    NSNumber *midArkrayNeoAlpha = [NSNumber numberWithInt:SM_BLE_ARKRAY_NEO_ALPHA];
    NSDictionary *dicArkrayNeoAlpha = [[NSDictionary alloc] init];
    dicArkrayNeoAlpha = @{
                        @"BLE_MID" : midArkrayNeoAlpha,
                        @"BLE_MSN" : @"6740185",
                        };
    
    
    
    

    

    /* */
  /*
    NSNumber *midRocheConnect = [NSNumber numberWithInt:SM_BLE_ACCUCHEK_AVIVA_CONNECT];
    NSDictionary *dicRocheConnect = [[NSDictionary alloc] init];
    dicRocheConnect = @{
                        @"BLE_MID" : midRocheConnect,
                        @"BLE_MSN" : @"00594317",
                        };
    
    */
    

    /* ELSE */
    NSNumber *midSoloBtm = [NSNumber numberWithInt:SM_BLE_CARESENS_EXT_C_BTM];
    NSDictionary *dicSoloBtm = [[NSDictionary alloc] init];
    dicSoloBtm = @{
                   @"BLE_MID" : midSoloBtm,
                   @"BLE_MSN" : @"USV2T5000100",
                   };
    
    

    

    

    /* MI */
    /*
    NSNumber *midMiScale = [NSNumber numberWithInt:SM_BLE_MI_SCALE];
    NSDictionary *dicMiScale = [[NSDictionary alloc] init];
    dicMiScale = @{
                        @"BLE_MID" : midMiScale,
                        @"BLE_MSN" : @"0c80b67476",
                        };
    
    NSNumber *midMiBrand2 = [NSNumber numberWithInt:SM_BLE_MI_BAND_2];
    NSDictionary *dicMiBrand2 = [[NSDictionary alloc] init];
    dicMiBrand2 = @{
                   @"BLE_MID" : midMiBrand2,
                   @"BLE_MSN" : @"f3fd97892ec3",
                   };
     */
}
    
    
    
    
    


- (void) bgmBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{ [[NSNotificationCenter defaultCenter] postNotificationName:@"MID_SN_NOTIFICATION" object:self];}];
}



+ (BleGateViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"BLE GATE instance value @%@", _sharedObject);
    return _sharedObject;
}


@end
