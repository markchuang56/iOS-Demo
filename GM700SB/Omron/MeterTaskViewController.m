//
//  BLEViewController.m
//  SQX
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "SQXViewController.h"
#import "BleBeFoundViewController.h"


#import "LibDelegateFunc.h"

#import "SyncStbViewController.h"
#import "MeterTaskViewController.h"
#import "BleEquipViewController.h"

#import "OmronSetUserTagViewController.h"
#import "OMUserPfGender.h"
#import "OMUserPfBirthday.h"
#import "OMUserPfBodyHeight.h"

#import "OmronPageViewController.h"
#import "uIDCheckBoxViewController.h"

#import "UserProfileFromApp.h"
#import "SyncStbViewController.h"


#define IMG_BLOCK_SIZE              16
#define IMG_BUFFER_SIZE             0x4FFFF // 128 KB

@interface MeterTaskViewController ()
{
    UIButton *btnAudioSync;
    
    UIButton *btnBlePairing;
    UIButton *btnBleSync;
    
    UIButton *btnOmronSetProfile;
    UIButton *btnBleDeviceSelect;

    UIButton *btnUserIdAndRecordType;
    
    UIButton *btnMeterDelRecords;
    
    UIAlertController *audioAlertView;
    
    NSString *oadSrcPath;
    SyncStbViewController *omStbController;
}

@end



@implementation MeterTaskViewController

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
                                       target:self action:@selector(blePageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"METER TASK"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
 

        
// BUTTON
        btnAudioSync = [[UIButton alloc] init];
        
        btnBlePairing = [[UIButton alloc] init];
        btnBleSync = [[UIButton alloc] init];
        
        btnOmronSetProfile = [[UIButton alloc] init];
        btnBleDeviceSelect = [[UIButton alloc] init];
        btnUserIdAndRecordType = [[UIButton alloc] init];
        
        btnMeterDelRecords = [[UIButton alloc] init];
        
        // Button Customer
        btnAudioSync = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnBlePairing = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBleSync = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnOmronSetProfile = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBleDeviceSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUserIdAndRecordType = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnMeterDelRecords = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnAudioSync];
        
        [bottunArray addObject:btnBlePairing];
        [bottunArray addObject:btnBleSync];
        
        [bottunArray addObject:btnOmronSetProfile];
        [bottunArray addObject:btnBleDeviceSelect];
        [bottunArray addObject:btnUserIdAndRecordType];

        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
       
        [btnString addObject:@"AUDIO SYNC"];
        [btnString addObject:@"BLE PAIRING"];
        [btnString addObject:@"BLE SYNC"];
        
        
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
                    [btnBleMethod addTarget:self action:@selector(audioSyncTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 1:
                    [btnBleMethod addTarget:self action:@selector(blePairingTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 2:
                    [btnBleMethod addTarget:self action:@selector(bleSyncTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 3:
                    [btnBleMethod addTarget:self action:@selector(OmronSetProfileTask:) forControlEvents:UIControlEventTouchUpInside];
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
        omStbController = [[SyncStbViewController alloc] init];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"SQX-VEIW view will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[[H2Sync sharedInstance] appAudioHideVolumeIcon:self.view];
    NSLog(@"METER TASK VIEW DID APPEAR");
    if ([LibDelegateFunc sharedInstance].meterTaskAutoSync) {
        NSLog(@"AUTO RUN -- He He");
        [LibDelegateFunc sharedInstance].meterTaskAutoSync = NO;
#ifdef AUTO_SYNC
        [NSTimer scheduledTimerWithTimeInterval:1.3f
                                         target:self
                                       selector:@selector(mtAutoRunning)
                                       userInfo:nil
                                        repeats:NO];
#endif
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mtAutoRunning
{
    NSLog(@"auto sync WHAT HAPPEN!!");
    [LibDelegateFunc sharedInstance].qrStringCode = @"USV2T5000100";
    [[MeterTaskViewController sharedInstance] bleSyncTask:nil];
}

#pragma mark - BUTTON TASK (BLE PAIRING OR SYNC)
- (void)audioSyncTask:(id)sender
{
    // 請確認使用 H2 Audio Cable
    NSLog(@"USING AUDIO CABLE");
    
    audioAlertView =
    [UIAlertController alertControllerWithTitle:@"***  AUDIO ＳＹＮＣ  ***" message:nil
    preferredStyle:UIAlertControllerStyleActionSheet];
    
     UIAlertAction* yesButton = [UIAlertAction
     actionWithTitle:@"Yes, please"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action) {
     //Handle your yes please button action here
         NSLog(@"ALERT YES");
         [self audioSyncFromUser];
     }];
     
     UIAlertAction* noButton = [UIAlertAction
     actionWithTitle:@"No, thanks"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action) {
     //Handle no, thanks button
         NSLog(@"ALERT NO");
     }];
     
    [audioAlertView addAction:yesButton];
    [audioAlertView addAction:noButton];
    [self presentViewController:audioAlertView animated:YES completion:nil];
}

- (void)audioSyncFromUser
{
    NSLog(@"AUDIO START FROM DEMO");
    [[H2AudioHelper sharedInstance] audioForSession];
    [[H2Sync sharedInstance] appAudioHideVolumeIcon:self.view];
    
    [LibDelegateFunc sharedInstance].stbTitle = @"AUDIO SYNC";
    [self syncAndPairingTask:[OmronUserIdAndRdType sharedInstance].omronRecordType withUid:[OmronUserIdAndRdType sharedInstance].omronUserIdSel andInterfaceFunc:AUDIO_CABLE_SYNC withString:@"AUDIO SYNC DONE"];
}



- (IBAction)blePairingTask:(id)sender
{
    UInt8 interfaceSelForDemo = 0;
    UInt32 tmpMid = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
    
    if (tmpMid & BLE_EQUIP_MASK) {
        interfaceSelForDemo = BLE_EQUIP_PAIRING;
    }else{
        interfaceSelForDemo = BLE_CABLE_PAIRING;
        [LibDelegateFunc sharedInstance].qrStringCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"];
    }
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE PAIRING";
    [self syncAndPairingTask:[OmronUserIdAndRdType sharedInstance].omronRecordType withUid:[OmronUserIdAndRdType sharedInstance].omronUserIdSel andInterfaceFunc:interfaceSelForDemo withString:@"BLE PAIRING DONE"];
}


- (IBAction)bleSyncTask:(id)sender
{
    NSLog(@"FUNCTION WORKING ...");
    UInt8 interfaceSelForDemo = 0;
    UInt32 tmpMid = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
    
    if (tmpMid & BLE_EQUIP_MASK) {
        interfaceSelForDemo = BLE_EQUIP_SYNC;
    }else{
        interfaceSelForDemo = BLE_CABLE_SYNC;
        [LibDelegateFunc sharedInstance].qrStringCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"];
    }
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE SYNC";
    [self syncAndPairingTask:[OmronUserIdAndRdType sharedInstance].omronRecordType withUid:[OmronUserIdAndRdType sharedInstance].omronUserIdSel andInterfaceFunc:interfaceSelForDemo withString:@"BLE SYNC DONE"];
}


- (IBAction)bleMeterDeleteTask:(id)sender
{
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE DELETE";
    [self syncAndPairingTask:[OmronUserIdAndRdType sharedInstance].omronRecordType withUid:[OmronUserIdAndRdType sharedInstance].omronUserIdSel andInterfaceFunc:BLE_DEL_RECORDS withString:@"METER DEL DONE"];
}


// Sync After Device Have Found
- (void)syncFromDeviceHaveFound:(id)sender
{
    [self bleSyncTask:sender];
}







#pragma mark - FUNCTION START

- (void)syncAndPairingTask:(UInt8)dType withUid:(UInt8)uId andInterfaceFunc:(UInt8)func withString:(NSString *)doneString
{
    [SyncStbViewController sharedInstance].labelCableStatus.text = @"...";
    
    [LibDelegateFunc sharedInstance].syncStatusStringEx = @"";
    NSLog(@"APP - TYPE  %02X, UID %02X, FNC %02X", dType, uId, func);
    [LibDelegateFunc sharedInstance].bgIndexString = @"0";
    [LibDelegateFunc sharedInstance].bpIndexString = @"0";
    [LibDelegateFunc sharedInstance].bwIndexString = @"0";
    
    [LibDelegateFunc sharedInstance].skipNumbers.bgSkip = 0;
    [LibDelegateFunc sharedInstance].skipNumbers.bpSkip = 0;
    [LibDelegateFunc sharedInstance].skipNumbers.bwSkip = 0;
    
    // DEMO LDT TEST
    //j[[LibDelegateFunc sharedInstance] demoDefaultLDT];
    
    BOOL snStatus = NO;
    NSString *uuidString;
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    
    NSMutableArray *pUuidAndSn = [[NSMutableArray alloc] init];
    pUuidAndSn = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_BLE_IDENTIFIER_SN"];
    
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
    
    
    UInt8 syncStatus = 0;
    H2PackageForSync *packageSync = [[H2PackageForSync alloc] init];
    
    [LibDelegateFunc sharedInstance].equipIdString = @"no-id";
    // Interface SEL(AUDIO, BLE, Pairing or Sync, OAD)
    packageSync.equipCode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
    
    [LibDelegateFunc sharedInstance].equipIdString = [NSString stringWithFormat:@"%08X", (int)packageSync.equipCode];
    
    //SM_CARESENS_EXT_9_BIONIME_GM550                 0x0139
    //packageSync.equipCode = SM_CARESENS_EXT_9_BIONIME_GM700S;//                0x0239
    
    packageSync.interfaceTask = func;
    
    // 1 : bg, 2 : bp, 4 : bw
    packageSync.recordTypeInMeter = dType;
    packageSync.userTagInMeter = uId;
    
    
    // BLE Scanning ...
    packageSync.bleScanningKey = [LibDelegateFunc sharedInstance].qrStringCode;
    NSLog(@"BLE SYNC SN = %@", packageSync.bleScanningKey);
    
    // Ble Identifier
    packageSync.bleIdentifier = uuidString;
    
    // LDT Array
    packageSync.serverLastDateTimeArray = [LibDelegateFunc sharedInstance].serverLastDateTimes;
    
    // Debug use
    packageSync.uIDStringFromRegister = [LibDelegateFunc sharedInstance].userID;
    packageSync.uEMailStringFromRegister = [LibDelegateFunc sharedInstance].userEMail;
    
    NSLog(@"NEW SYNC UID = %04X, TYPE = %04X", packageSync.userTagInMeter, packageSync.recordTypeInMeter);
    
    NSLog(@"APP - LDT %@", packageSync.serverLastDateTimeArray);
    
    
    // For Omron HBF-254C Pairing
    packageSync.userProfile = [LibDelegateFunc sharedInstance].userProfile;
    NSLog(@"APP SYNC PACKAGE %@", packageSync);
    NSLog(@"APP G-PROFILE %d TAG", packageSync.userProfile.uTag);
    NSLog(@"APP G-PROFILE %d GENDER", packageSync.userProfile.uGender);
    NSLog(@"APP G-PROFILE %d 年, %d 月, %d 日 BIRTH", packageSync.userProfile.uBirthYear, packageSync.userProfile. uBirthMonth, packageSync.userProfile.uBirthDay);
    NSLog(@"APP G-PROFILE %d BODY HEIGHT", packageSync.userProfile.uBodyHeight);
    
    syncStatus = [[H2Sync sharedInstance] appGlobalPreSync:packageSync];
    NSLog(@"BLE SYNC RESPONSE (AA) %02X", syncStatus);
    
    [LibDelegateFunc sharedInstance].stbSync = YES;
    
    [LibDelegateFunc sharedInstance].packageForSyncTmp = packageSync;
#ifndef AUTO_SYNC
    SyncStbViewController *omStbController =[[SyncStbViewController alloc] init];
    [self presentViewController:omStbController animated:YES completion:^{NSLog(doneString, nil);}];
#endif
    //syncStatus = [[H2Sync sharedInstance] appGlobalPreSync:packageSync];
    //NSLog(@"BLE SYNC RESPONSE (AA) %02X", syncStatus);
    /*
    [NSTimer scheduledTimerWithTimeInterval:1.0f
                                     target:self
                                   selector:@selector(todoSomeThing)
                                   userInfo:nil
                                    repeats:NO];
     */
}

- (void)todoSomeThing
{
    NSString *doneString = @"BLE SYNC AUTO ...";
    SyncStbViewController *omStbController =[[SyncStbViewController alloc] init];
    [self presentViewController:omStbController animated:YES completion:^{NSLog(doneString, nil);}];
    //UInt8 syncStatus = [[H2Sync sharedInstance] appGlobalPreSync:packageSync];
    //NSLog(@"BLE SYNC RESPONSE (AA) %02X", syncStatus);
}



#pragma mark - SET USER PROFILE
- (IBAction)OmronSetProfileTask:(id)sender
{
    ///////////////////////////////
    // SET USER TAG First ...
    OmronSetUserTagViewController *userTagController =[[OmronSetUserTagViewController alloc] init];
    [self presentViewController:userTagController animated:YES completion:^{NSLog(@"USER PROFILE TAG - DONE");}];
    
    ///////////////////////
    // For Omron User Profile
    //OMUserProfileGenderViewController *userGenderController =[[OMUserProfileGenderViewController alloc] init];
    //[self presentViewController:userGenderController animated:YES completion:^{NSLog(@"USER PROFILE GENDER - DONE");}];
}



- (IBAction)bleDeviceShow:(id)sender {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bgmShowNotification:)
                                                 name:@"BGM_SHOW"
                                               object:nil];
    BleEquipViewController *omEquipShowController =[[BleEquipViewController alloc] init:nil];
    [self presentViewController:omEquipShowController animated:YES completion:^{NSLog(@"BLE SHOW BGM done");}];
}


- (void)bgmShowNotification:(id)sender
{
    NSLog(@"Get New Meter ID %04X", [[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"]);
}


- (void) blePageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MID_SN_NOTIFICATION" object:self];
    }];
}


/**************************************************
 * Arkray TASK
 *
 *
**************************************************/
#pragma mark - ARKRAY REGISTER TASK




- (IBAction)btnUidAndRdType:(id)sender
{
    uIDCheckBoxViewController *uIdAndRdTypeSelController =[[uIDCheckBoxViewController alloc] init];
    [self presentViewController:uIdAndRdTypeSelController animated:YES completion:^{NSLog(@"UID - RD TYPE DONE ");}];
}

#pragma mark - BIONIME PAIR ...
- (void)bionimePairAgain
{
    [self blePairingTask:nil];
}

+ (MeterTaskViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"the instance value @%@", _sharedObject);
    return _sharedObject;
}

@end


