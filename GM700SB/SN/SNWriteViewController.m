//
//  syFirstViewController.m
//  tabH2
//
//  Created by JasonChuang on 13/10/19.
//  Copyright (c) 2013年 JasonChuang. All rights reserved.
//

#define STARTBYTE_PC            0xAA
#define OP_INIT                 0x00
#define OP_BARCODE              0x0F
#define OP_READ_DATETIME        0x07
#define OP_READ_ONE_RECORD      0x0B

#define OMNIS_D0                2
#define OMNIS_D1                3
#define OMNIS_D2                4
#define OMNIS_D3                5

#define OMNIS_D4                6
#define OMNIS_D5                7
#define OMNIS_D6                8
#define OMNIS_D7                9

#define OMNIS_CHKSUM            10
#define OMNIS_MAXLEN            11

#define SN_LEN                  10

/*
#define SN_MODEL_AT_0                   0
#define SN_TYPE_AT_1                    1

#define SN_YEAR_AT_2                    2
#define SN_MONTH_AT_3                   3

#define SN_CUSTOMER_AT_4                4
#define SN_CUSTOMEREX_AT_5              5

#define SN_NUMBER_AT_6                  6

#define SN_CRC_AT_9                     9

*/

#import "SNSeedViewController.h"

#import "SNWriteViewController.h"
#import <Foundation/NSDateFormatter.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>
#import <MediaPlayer/MPVolumeSettings.h>

#import <MessageUI/MessageUI.h>

#import "LibDelegateFunc.h"

//#import "NSDate+RFC2822.h"
#import "h2MeterRecordInfo.h"

#import "sn_qrcode.h"

#import "H2AudioHelper.h"


#import <CoreTelephony/CTCall.h>



@interface SNWriteViewController () {
    
    UILabel *readStatus;
    
    UIAlertController *cableStatusAlertView;
    UIAlertController *wantToSyncAlertView;
    UInt32 snNumber;
    
    UIButton *btnWriteBLE;
    UIButton *btnReadBLE;
    
    UIButton *btnWriteAUDIO;
    UIButton *btnReadAUDIO;
    
    UIButton *btnSNSetting;
    
    UIButton *btnCreateQR;
    
    UILabel *serialNumber;
}
@end

@implementation SNWriteViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navSNWBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navSNWBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(snwPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"SNW FUNCTION"];
        
        navItem.leftBarButtonItem = btnBack;
        [navSNWBar pushNavigationItem:navItem animated:NO];
        
        
        readStatus = [[UILabel alloc] init];
        readStatus.frame = CGRectMake(20, 50, 280, 40);
        
        [readStatus setFont:[UIFont fontWithName:@"System" size:20]];
        
        [readStatus setBackgroundColor:[UIColor whiteColor]];
        [readStatus setTextColor:[UIColor redColor]];
        
        [readStatus.layer setMasksToBounds:YES];
        [readStatus.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [readStatus.layer setBorderWidth:1.0]; //边框宽度
        
        readStatus.text = @"sn ...";
        [self.view addSubview:readStatus];
        
        // BUTTON
        btnWriteBLE = [[UIButton alloc] init];
        btnReadBLE = [[UIButton alloc] init];
        btnWriteAUDIO = [[UIButton alloc] init];
        btnReadAUDIO = [[UIButton alloc] init];
        btnSNSetting = [[UIButton alloc] init];
        
        btnCreateQR = [[UIButton alloc] init];
        
        
        
        
        //        btnBleUpdateOAD_A = [[UIButton alloc] init];
        
        
        
        btnWriteBLE = [UIButton buttonWithType:UIButtonTypeCustom];
        btnReadBLE = [UIButton buttonWithType:UIButtonTypeCustom];
        btnWriteAUDIO = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnReadAUDIO = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSNSetting = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnCreateQR = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnWriteBLE];
        [bottunArray addObject:btnReadBLE];
        [bottunArray addObject:btnWriteAUDIO];
        [bottunArray addObject:btnReadAUDIO];
        [bottunArray addObject:btnSNSetting];
        
        [bottunArray addObject:btnCreateQR];
        
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"SN WRITE BLE"];
        [btnString addObject:@"SN READ BLE"];
        [btnString addObject:@"SN WRITE AUDIO"];
        
        [btnString addObject:@"SN READ AUDIO"];
        [btnString addObject:@"SN SEED SEETING"];
        
        [btnString addObject:@"SN TO QRCODE"];
        
        
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
                    [btnBleMethod addTarget:self action:@selector(snWriteBle:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(snReadBle:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(snWriteAudio:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 3:
                    [btnBleMethod addTarget:self action:@selector(snReadAudio:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 4:
                    [btnBleMethod addTarget:self action:@selector(snSeedSetting:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 5:
                    [btnBleMethod addTarget:self action:@selector(snCreateQRCode:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                    
                default:
                    break;
            }
            
            
            [self.view addSubview:btnBleMethod];
            btnIndex++;
        }
        
        
        
        
        
        
        serialNumber = [[UILabel alloc] init];
        serialNumber.frame = CGRectMake(20, 60 + 40 + btnIndex * 60, 280, 40);
        
        [serialNumber setFont:[UIFont fontWithName:@"System" size:20]];
        
        [serialNumber setBackgroundColor:[UIColor whiteColor]];
        [serialNumber setTextColor:[UIColor redColor]];
        
        [serialNumber.layer setMasksToBounds:YES];
        [serialNumber.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [serialNumber.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        
        //        serialNumber.text = (NSString *)lableString[lableIndex];
        [self.view addSubview:serialNumber];
        
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Call this Function...");
    
    
    [H2SerialNumber sharedInstance];
    [H2SerialNumber sharedInstance].serialNumberDelegate = (id<H2SerialNumberDelegate >)self;
    
    // BAR
    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 10, 320, 44)];
    [self.view addSubview:navBar];
    
    UIBarButtonItem *clearButtor = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Clear"
                                   style:UIBarButtonItemStylePlain
                                   target:self action:@selector(clearConsole:)];
//    UINavigationItem *navItem = [[UINavigationItem alloc]
//                                 initWithTitle:@""];
    
    NSString *verBundle = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *reliabilityApp = [NSString stringWithFormat:@"SN BLE Tool %@",verBundle];
    // NSString
    UINavigationItem *navItem = [[UINavigationItem alloc]
                                 initWithTitle:reliabilityApp];
    
    navItem.rightBarButtonItem = clearButtor;
    [navBar pushNavigationItem:navItem animated:NO];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"MeterChangedNotification"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"SNReadWriteNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"SerialNumberSeed"
                                               object:nil];
    
    
    self.consoleView.backgroundColor = [UIColor yellowColor];
    self.consoleView.editable = NO;
    
    //    cableStatusAlertView = [[UIAlertView alloc] initWithTitle:@"Cable Status" message:@"has cable or not" delegate:nil cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
//    cableStatusAlertView = [[UIAlertController alloc] initWithTitle:@"No h2Sync cable" message:nil delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    
//    wantToSyncAlertView = [[UIAlertController alloc] initWithTitle:@"Want To Sync" message:@"Please check h2 cable ready?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];

    
    
    cableStatusAlertView = [UIAlertController alertControllerWithTitle:@"No h2Sync cable"
                                                                   message:@"This is an action sheet."
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
                                                            //preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"one"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              NSLog(@"You pressed button one");
                                                          }]; // 2
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"two"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button two");
                                                           }]; // 3
    
    [cableStatusAlertView addAction:firstAction]; // 4
    [cableStatusAlertView addAction:secondAction]; // 5
    
    wantToSyncAlertView = [UIAlertController alertControllerWithTitle:@"Want To Sync"
                                                               message:@"This is an action sheet."
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    UIAlertAction *aAction = [UIAlertAction actionWithTitle:@"A BUTTON"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              NSLog(@"You pressed button one");
                                                          }]; // 2
    UIAlertAction *bAction = [UIAlertAction actionWithTitle:@"B BUTTON"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed button two");
                                                           }]; // 3
    
    [wantToSyncAlertView addAction:aAction]; // 4
    [wantToSyncAlertView addAction:bAction]; // 5
    
//    [self presentViewController:cableStatusAlertView animated:YES completion:nil]; // 6
//    [self presentViewController:wantToSyncAlertView animated:YES completion:nil]; // 6
    
    // system speaker icon hidden
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:
                                 CGRectMake(-30, -30, 1, 1)];
    
//    [volumeView setHidden:NO]; // 新加
//    [volumeView setUserInteractionEnabled:NO]; // 新加
    
    [self.view addSubview:volumeView];
    [self.view sendSubviewToBack:volumeView];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"SNReadWriteNotification"])
    {
        NSLog (@"APP Successfully received the READ OR WRITE notification!");
        
        readStatus.text = [LibDelegateFunc sharedInstance].cableSerialnumber;
    }else if ([[notification name] isEqualToString:@"SerialNumberSeed"]){
        
        NSLog(@"notication come back here ...");
        snNumber = [H2SerialNumber sharedInstance].snNumber;
        
        serialNumber.text = [NSString stringWithFormat:@"SN : %C%C %02d %02d %C%C %06d", [H2SerialNumber sharedInstance].snModel, [H2SerialNumber sharedInstance].snType, [H2SerialNumber sharedInstance].snYear, [H2SerialNumber sharedInstance].snMonth, [H2SerialNumber sharedInstance].snCustomer, [H2SerialNumber sharedInstance].snCustomerEx, (unsigned int)[H2SerialNumber sharedInstance].snNumber];
        
    }
}

- (IBAction)snWriteBle:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE WRITE SN";
    
    [NSTimer scheduledTimerWithTimeInterval:1.2
                                     target:self
                                   selector:@selector(writeSerialNumberEX)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)snReadBle:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE READ SN";
    
    [NSTimer scheduledTimerWithTimeInterval:1.2f
                                     target:self
                                   selector:@selector(readSerialNumberEx)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)snWriteAudio:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"AUDIO WR SN";
    
    if([H2Sync sharedInstance].isAudioCable){
        NSLog(@"HAS CABLE ...");
        NSError *error;
        
        [[H2AudioHelper sharedInstance] start:&error];
        // Set YES, don't send cable existing test,
//j        [[H2Sync sharedInstance] h2SetAudioMaxVolume];
        
        
    }else{
        NSLog(@"NO CABLE ...");
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(writeSerialNumberEX)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)snReadAudio:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"AUDIO RD SN";
    
    if([H2Sync sharedInstance].isAudioCable){
        NSLog(@"HAS CABLE ...");
        NSError *error;
        
        [[H2AudioHelper sharedInstance] start:&error];
        // Set YES, don't send cable existing test,
//j        [[H2Sync sharedInstance] h2SetAudioMaxVolume];
        
        
    }else{
        NSLog(@"NO CABLE ...");
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(readSerialNumberEx)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (IBAction)snSeedSetting:(id)sender {
    SNSeedViewController *snSettingController =[[SNSeedViewController alloc] init];
    [self presentViewController:snSettingController animated:YES completion:^{NSLog(@"done");}];
}


#pragma mark - H2 AUDIODELEGATE METHOD




/***************************************************************
 * @fn : WRITE SERIAL NUMBER
 *
 ****************************************************************/
- (void)writeSerialNumberEX{
    
    unsigned char tmp[12] = {0};
    
    tmp[SN_MODEL_AT_0] = [H2SerialNumber sharedInstance].snModel;//'G';
    tmp[SN_TYPE_AT_1] = [H2SerialNumber sharedInstance].snType;//'A';
    
    tmp[SN_YEAR_AT_2] = [H2SerialNumber sharedInstance].snYear;
    tmp[SN_MONTH_AT_3] = [H2SerialNumber sharedInstance].snMonth;
    
    tmp[SN_CUSTOMER_AT_4] = [H2SerialNumber sharedInstance].snCustomer;
    tmp[SN_CUSTOMEREX_AT_5] = [H2SerialNumber sharedInstance].snCustomerEx;
    
    memcpy(&tmp[SN_NUMBER_AT_6], &snNumber, sizeof(snNumber));
    
    tmp[SN_CRC_AT_9] = tmp[0];
    for(int i = 1; i < SN_CRC_AT_9; i++){
        tmp[SN_CRC_AT_9] ^= tmp[i];
    }// Command checking
    
    serialNumber.text = [NSString stringWithFormat:@"SN : %C%C %02d %02d %C%C %06d", [H2SerialNumber sharedInstance].snModel, [H2SerialNumber sharedInstance].snType, [H2SerialNumber sharedInstance].snYear, [H2SerialNumber sharedInstance].snMonth, [H2SerialNumber sharedInstance].snCustomer, [H2SerialNumber sharedInstance].snCustomerEx, (unsigned int)[H2SerialNumber sharedInstance].snNumber];
    
    [H2SerialNumber sharedInstance].snNumber++;
    snNumber++;

    [[H2AudioHelper sharedInstance] tmReadWriteH2SerialNumber: tmp withLength:SN_LEN reading:NO];
}




- (void)readSerialNumberEx{
    [[H2AudioHelper sharedInstance] tmReadWriteH2SerialNumber: nil withLength:0 reading:YES];
}





- (void)clearConsole:(id)sender
{
    self.consoleView.text = @"";
}

#pragma mark - UIAlertViewDelegate

#if 0
- (void)alertView:(UIAlertController *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alert veiew");
    if ([alertView.title isEqualToString:@"Cable Status"]) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                
                break;
                
            default:
                break;
        }
    }else if ([alertView.title isEqualToString:@"Want To Sync"]){
        switch (buttonIndex) {
            case 0:
                // no thing to do
                NSLog(@"here is 0");
                break;
            case 1:
                NSLog(@"here is 1");
                [[H2Sync sharedInstance] h2CablePreSync:nil];
                break;
                
            default:
                break;
        }
    }
}

#endif

- (void)snCreateQRCode:(id)sender
{
    
    [[SN_QRCode sharedInstance] snToQRCode];
    if ([H2SerialNumber sharedInstance].qrCycle > 0) {
        [H2SerialNumber sharedInstance].qrCycle--;
        [self snCreateQRCode:nil];
    }
}
- (void)snwPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MID_SN_NOTIFICATION" object:self];
    }];
}

+ (SNWriteViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_APEXBIO
    NSLog(@"SN WRITE INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}



@end
