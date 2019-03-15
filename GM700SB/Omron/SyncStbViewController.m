//
//  STBViewController.m
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#import "LibDelegateFunc.h"
#import "CableInfoViewController.h"
#import "EquipRecordsViewController.h"
#import "BleBeFoundViewController.h"
#import "TMShowUserId.h"

#import "ArkrayDialogViewController.h"
#import "SyncStbViewController.h"
#import "SyncResultViewController.h"
#import "OmronRecordViewController.h"

#import "H2AudioHelper.h"
#import "H2BleEquipId.h"

#import "LibDelegateFunc.h"
#define INIT_LOC_V        60

@interface SyncStbViewController ()
{

    UIButton *btnShowResults;
    UIButton *btnTerminalFlow;
    UIButton *btnAppGetLastDateTime;
    
    UILabel *labelIndex;
    //UILabel *labelCableStatus;
    
    UILabel *labelSigleRecord;
    UILabel *labelDateTime;
    
    UILabel *labelBatteryLevel;
    UILabel *labelBleId;
    
    
    UILabel *labelEquipId;
}

@end

@implementation SyncStbViewController



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
                                    target:self action:@selector(stbPageBack:)];
//        UINavigationItem *navItem = [[UINavigationItem alloc]
//                                     initWithTitle:@"BLE FUNCTION"];
        
        //UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:[LibDelegateFunc sharedInstance].stbTitle];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"STATUS & STAND_BY"];
        
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        // BUTTON
        btnShowResults = [[UIButton alloc] init];
        btnTerminalFlow = [[UIButton alloc] init];
        btnAppGetLastDateTime = [[UIButton alloc] init];
        
        btnShowResults = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTerminalFlow = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAppGetLastDateTime = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnShowResults];
        [bottunArray addObject:btnTerminalFlow];
        //[bottunArray addObject:btnAppGetLastDateTime];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"SHOW RESULTS"];
        
        [btnString addObject:@"TERMINAL FLOW"];
        [btnString addObject:@"NOTHING"];
        
        //[btnString addObject:@"APP GET RECORDS"];
        //[btnString addObject:@"APP GET LDT"];
        
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            //            btnBleMethod = [UIButton buttonWithType:UIButtonTypeCustom];
            
            btnBleMethod.frame = CGRectMake(20, INIT_LOC_V + btnIndex * 45, 280, 40);
            [btnBleMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnBleMethod.layer setMasksToBounds:YES];
            [btnBleMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnBleMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnBleMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            [btnBleMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnBleMethod addTarget:self action:@selector(showSyncResult:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(terminalFlowTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(appGetLastDateTimeTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                
                default:
                    break;
            }
            
            
            [self.view addSubview:btnBleMethod];
            btnIndex++;
        }
        self.view.backgroundColor = [UIColor whiteColor];
        
        // INDEX, STATUS, SINGLE RECORD
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"INDEX_OAD_RECORD" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"BLE_CABLE_STATUS" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"SINGLE_RECORD_NOTIFICATION" object:nil];
        
        
        // FOR Battery, DYNAMIC
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelNotificationTask:) name:@"BATTERY_NOTIFICATION" object:nil];
        
        // BLE PAIRING MODE
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBlePeripheralAfterPairingForArkray) name:@"SHOW_HAVE_FOUND" object:nil];
        
        // ARKRAY NOTIFICATION
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arkrayNotificationTask:) name:@"ARKRAY_NOTIFICATION" object:nil];
        
        // POP UP SET USER ID PAGE
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(omronSetUserIdNotificationTask:) name:@"OMRON_USER_ID_NOTIFICATION" object:nil];

        
        
        ///////////////////////////////////////////////////////////////////////////
        // LABEL 2
        
        labelIndex = [[UILabel alloc] init];
        _labelCableStatus = [[UILabel alloc] init];
        labelSigleRecord = [[UILabel alloc] init];
        labelDateTime = [[UILabel alloc] init];
        labelBatteryLevel = [[UILabel alloc] init];
        labelBleId = [[UILabel alloc] init];
        labelEquipId = [[UILabel alloc] init];
        

        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        [labelArray addObject:labelIndex];
        [labelArray addObject:_labelCableStatus];
        [labelArray addObject:labelSigleRecord];
        [labelArray addObject:labelDateTime];
        [labelArray addObject:labelBatteryLevel];
        [labelArray addObject:labelBleId];
        [labelArray addObject:labelEquipId];
        
        NSMutableArray *labelString = [[NSMutableArray alloc] init];
        [labelString addObject:@"INDEX"];
        [labelString addObject:@"STATUS"];
        [labelString addObject:@"VALUE"];
        [labelString addObject:@"DATE TIME"];
        [labelString addObject:@"BATTERY"];
        [labelString addObject:@"BLE IDENTIFIER"];
        
        [labelString addObject:@"EQ - ID"];
        labelEquipId.text = [NSString stringWithFormat:@"EQ-ID : "];
        labelEquipId.text = [labelEquipId.text stringByAppendingString:[LibDelegateFunc sharedInstance].equipIdString];

        
        for (UILabel *labelInfo in labelArray) {
            
            labelInfo.frame = CGRectMake(20, INIT_LOC_V + btnIndex * 45, 280, 40);
            
            [labelInfo setFont:[UIFont fontWithName:@"System" size:26]];
            
            [labelInfo setBackgroundColor:[UIColor whiteColor]];
            [labelInfo setTextColor:[UIColor redColor]];
            
            [labelInfo.layer setMasksToBounds:YES];
            [labelInfo.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [labelInfo.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            labelInfo.text =[labelString objectAtIndex:btnIndex-[bottunArray count]];
            [self.view addSubview:labelInfo];
            btnIndex++;
        }
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

#pragma mark - VIEW CONTROLLER TASK
- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"STB H2-VEIW did become active notification");
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    NSLog(@"STB H2-VEIW will enter foreground notification");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"STB H2-VEIW view will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[[H2Sync sharedInstance] appAudioHideVolumeIcon:self.view];
    NSLog(@"STB VEIW view did appear");
    if ([LibDelegateFunc sharedInstance].stbSync) {
        [LibDelegateFunc sharedInstance].stbSync = NO;
    }
}



#pragma mark - BUTTON FUNCTION


- (IBAction)showSyncResult:(id)sender
{
    SyncResultViewController *recordsController;
    recordsController = [[SyncResultViewController alloc] init];
    recordsController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:recordsController animated:YES completion:^{NSLog(@"DONE FOR show SYNC RESULT");}];
}

- (IBAction)terminalFlowTask:(id)sender
{
    [[H2Sync sharedInstance] appTerminateSdkFlow];
}



- (IBAction)appGetLastDateTimeTask:(id)sender
{
    //[[H2Sync sharedInstance] appGetLastDateTime];
}

- (void) stbPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stbViewSetIndex:(NSString *)index
{
    labelIndex.text = index;
    NSLog(@"DEMO SET INDEX, %@", labelIndex.text);
}


#pragma mark - NOTIFICATION METHOD
- (void)indexAndRecordNotification:(NSNotification *)notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    //j NSLog(@"APP -INDEX_OAD_RECORD - (NOTIFY) %@", [notification name]);
    
    if ([[notification name] isEqualToString:@"INDEX_OAD_RECORD"])
    {   // UPDATE INDEX
        labelIndex.text = @"BG : ";
        labelIndex.text = [labelIndex.text stringByAppendingString:[LibDelegateFunc sharedInstance].bgIndexString];
        
        labelIndex.text = [labelIndex.text stringByAppendingString:@"  BP : "];
        labelIndex.text = [labelIndex.text stringByAppendingString:[LibDelegateFunc sharedInstance].bpIndexString];
        
        labelIndex.text = [labelIndex.text stringByAppendingString:@"  BW : "];
        labelIndex.text = [labelIndex.text stringByAppendingString:[LibDelegateFunc sharedInstance].bwIndexString];
        //j NSLog (@"APP Successfully received INDEX OR OAD NOTIFY!");
    }

    
    if ([[notification name] isEqualToString:@"BLE_CABLE_STATUS"])
    {   // UPDATE STATUS
        
        _labelCableStatus.text = [NSString stringWithFormat:@"ST : %@", [LibDelegateFunc sharedInstance].syncStatusStringEx];
        NSLog(@"BLE GOT SYNC STATUS ...");
        
        NSString *bioString = [NSString stringWithFormat:@" = %04X", [LibDelegateFunc sharedInstance].bionimeCount];
        _labelCableStatus.text = [_labelCableStatus.text stringByAppendingString:bioString];
        
        
        labelEquipId.text = [NSString stringWithFormat:@"EQ-ID : "];
        labelEquipId.text = [labelEquipId.text stringByAppendingString:[LibDelegateFunc sharedInstance].equipIdString];
    }
    
    if ([[notification name] isEqualToString:@"SINGLE_RECORD_NOTIFICATION"])
    {   // UPDATE SINGLE RECORD
        labelSigleRecord.text = [LibDelegateFunc sharedInstance].singleRecordValue;
        labelDateTime.text = [LibDelegateFunc sharedInstance].singleRecordDateTime;
    }
}

- (void)batteryLevelNotificationTask:(id)sender
{ // UPDATE DYNAMIC INFO
    labelBatteryLevel.text = [LibDelegateFunc sharedInstance].batteryLevelString;
    labelBleId.text = [LibDelegateFunc sharedInstance].bleIdentifierString;
    NSLog(@"RECEIVED BATTERY NOTIFY");
}


#pragma mark - SHOW DEVICE HAVE FOUND
- (void)showBlePeripheralAfterPairingForArkray
{
    BleBeFoundViewController *bleDevController;
    bleDevController = [[BleBeFoundViewController alloc] init:[LibDelegateFunc sharedInstance].haveFoundBlePeripherals];
    bleDevController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bleDevController animated:YES completion:^{NSLog(@"DONE FOR === SHOW HAVE FOUND");}];
}

#pragma mark - ARKRAY NOTIFICATION TASK (PW)
- (void)arkrayNotificationTask:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"ARKRAY_NOTIFICATION"])
    {
        ArkrayDialogViewController *arkrayDialogController = [[ArkrayDialogViewController alloc] init];
        [self presentViewController:arkrayDialogController animated:YES completion:^{NSLog(@"ARKRAY - DIALOG DONE");}];
    }
}


- (void)omronSetUserIdNotificationTask:(NSNotification *)notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"OMRON_USER_ID_NOTIFICATION"])
    {
        NSLog (@"APP Successfully received SET USER ID NOTIFY!");
        // TO DO ...
        // Show Set User ID Page
        
        // FOR USER ID TEST
        TMShowUserIdViewController *userIdController =[[TMShowUserIdViewController alloc] init];
        [self presentViewController:userIdController animated:YES completion:^{NSLog(@"USER ID VIEW - DONE");}];
        
        // FOR USER PROFILE
        /*
         TMSetUserProfileViewController *userProfileController =[[TMSetUserProfileViewController alloc] init];
         [self presentViewController:userProfileController animated:YES completion:^{NSLog(@"USER PROFILE VIEW - DONE");}];
         */
    }
}

+ (SyncStbViewController *)sharedInstance
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
