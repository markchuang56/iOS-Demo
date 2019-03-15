//
//  STBViewController.m
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#define SPACE_IDX           40
#define SPACE_AREA           (SPACE_IDX - 5)

#import "STBViewController.h"

#import "LibDelegateFunc.h"

#import "CableInfoViewController.h"
#import "EquipInfoViewController.h"
#import "EquipRecordsViewController.h"
#import "SyncMessageViewController.h"

#import "SyncResultViewController.h"
#import "BleBeFoundViewController.h"



@interface STBViewController ()
{

    UIButton *btnShowCableInfo;
    UIButton *btnShowMeterInfo;
    UIButton *btnShowRecords;
    UIButton *btnShowSyncMessage;
    UIButton *btnShowHaveFound;
    UIButton *btnCanncelAudioBle;

    UILabel *labelIndex;
    UILabel *labelCableStatus;
    UILabel *labelSigleRecord;
    
    UIAlertView *bleLongRunAlertView;

}

@end

@implementation STBViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBlePeripheralAfterPairing) name:@"SHOW_HAVE_FOUND" object:nil];
        
        _statusTemp = @" ";
        UINavigationBar *navBleBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(stbPageBack:)];
//        UINavigationItem *navItem = [[UINavigationItem alloc]
//                                     initWithTitle:@"BLE FUNCTION"];
        UIBarButtonItem *clearButtor = [[UIBarButtonItem alloc]
                                        initWithTitle:@"ClearLDT"
                                        style:UIBarButtonItemStylePlain
                                        target:self action:@selector(clearLastDateTime:)];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:[LibDelegateFunc sharedInstance].stbTitle];
        
        
        navItem.leftBarButtonItem = btnBack;
        navItem.rightBarButtonItem = clearButtor;
        [navBleBar pushNavigationItem:navItem animated:NO];

        // BUTTON
        btnShowCableInfo = [[UIButton alloc] init];
        btnShowMeterInfo = [[UIButton alloc] init];
        btnShowRecords = [[UIButton alloc] init];
        btnShowSyncMessage = [[UIButton alloc] init];
        btnShowHaveFound = [[UIButton alloc] init];
        btnCanncelAudioBle = [[UIButton alloc] init];
        
        btnShowCableInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowMeterInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowRecords = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowSyncMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowHaveFound = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCanncelAudioBle = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnShowCableInfo];
        [bottunArray addObject:btnShowMeterInfo];
        [bottunArray addObject:btnShowRecords];
        [bottunArray addObject:btnShowSyncMessage];
        [bottunArray addObject:btnShowHaveFound];
        [bottunArray addObject:btnCanncelAudioBle];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"SHOW CABLE INFO"];
        [btnString addObject:@"SHOW METER INFO"];
        [btnString addObject:@"SHOW RECORD"];
        [btnString addObject:@"SHOW SYNC MESSAGE"];
        [btnString addObject:@"SHOW BLE FOUND"];
        [btnString addObject:@"STOP SYNC"];
        
        // 跑馬燈
        
        _demoLabel1 =  [[MarqueeLabel alloc] initWithFrame:CGRectMake(20, 60 + 9 * SPACE_IDX, 280, SPACE_AREA)];
#if 0
        // Continuous Type
        self.demoLabel1.tag = 101;
        self.demoLabel1.marqueeType = MLContinuous;
        self.demoLabel1.scrollDuration = 15.0;
        self.demoLabel1.animationCurve = UIViewAnimationOptionCurveEaseInOut;
        self.demoLabel1.fadeLength = 10.0f;
        self.demoLabel1.leadingBuffer = 30.0f;
        self.demoLabel1.trailingBuffer = 20.0f;
        // Text string for this label is set via Interface Builder!
        
#else
        // Reverse Continuous Type, with attributed string
        self.demoLabel1.tag = 201;
        self.demoLabel1.marqueeType = MLContinuousReverse;
        self.demoLabel1.scrollDuration = 8.0;
        self.demoLabel1.fadeLength = 15.0f;
        self.demoLabel1.leadingBuffer = 40.0f;
#endif
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Auto Mode!! Auto Mode!!"];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f] range:NSMakeRange(0, 10)];
        [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(11,10)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.234 green:0.234 blue:0.234 alpha:1.000] range:NSMakeRange(0,attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] range:NSMakeRange(21, attributedString.length - 21)];
        self.demoLabel1.attributedText = attributedString;
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            //            btnBleMethod = [UIButton buttonWithType:UIButtonTypeCustom];
            
            btnBleMethod.frame = CGRectMake(20, 60 + btnIndex * SPACE_IDX, 280, SPACE_AREA);
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
                    [btnBleMethod addTarget:self action:@selector(showCableInfo:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(showMeterInfo:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(showRecords:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 3:
                    [btnBleMethod addTarget:self action:@selector(showSyncMessage:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 4:
                    [btnBleMethod addTarget:self action:@selector(showBleHaveFoundDevice:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 5:
                    [btnBleMethod addTarget:self action:@selector(audioBleSyncStop:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                    
                default:
                    break;
            }
            
            
            [self.view addSubview:btnBleMethod];
            btnIndex++;
        }
        self.view.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"INDEX_OAD_RECORD" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"BLE_SYNC_INIT" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"SINGLE_RECORD_NOTIFICATION" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"BLE_CABLE_STATUS" object:nil];
        

        ///////////////////////////////////////////////////////////////////////////
        // LABEL 2
        
        labelIndex = [[UILabel alloc] init];
        labelCableStatus = [[UILabel alloc] init];
        labelSigleRecord = [[UILabel alloc] init];

//        btnShowCableInfo = [UIButton buttonWithType:UIButtonTypeCustom];

        NSMutableArray *labelArray = [[NSMutableArray alloc] init];
        [labelArray addObject:labelIndex];
        [labelArray addObject:labelCableStatus];
        [labelArray addObject:labelSigleRecord];
        
        NSMutableArray *labelString = [[NSMutableArray alloc] init];
        [labelString addObject:@"INDEX"];
        [labelString addObject:@"STATUS"];
        [labelString addObject:@"SINGLE"];
        
        
        for (UILabel *labelInfo in labelArray) {
            
            labelInfo.frame = CGRectMake(20, 60 + btnIndex * SPACE_IDX, 280, SPACE_AREA);
            
            [labelInfo setFont:[UIFont fontWithName:@"System" size:26]];
            
            [labelInfo setBackgroundColor:[UIColor whiteColor]];
            [labelInfo setTextColor:[UIColor redColor]];
            
            [labelInfo.layer setMasksToBounds:YES];
            [labelInfo.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [labelInfo.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            labelInfo.text =[labelString objectAtIndex:btnIndex-6];
            [self.view addSubview:labelInfo];
            btnIndex++;
        }
        
        
        
//        _demoLabel1 = [[UILabel alloc] init];
/*
        - (id)initWithFrame:(CGRect)frame {
            return [self initWithFrame:frame duration:7.0 andFadeLength:0.0];
        }
*/
        //_demoLabel1.frame = CGRectMake(20, 60 + btnIndex * 50, 280, 40);
        
 //       _demoLabel1. = (CGRect)[[MarqueeLabel alloc] initWithFrame:CGRectMake(20, 60 + btnIndex * 50, 280, 40)];
        
        NSLog(@"%@ =====  跑  馬  燈 ====== %@ and %@", _demoLabel1, _demoLabel1.attributedText, attributedString);
        [self.view addSubview:_demoLabel1];
        
    }
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(indexAndRecordNotification:) name:@"SINGLE_RECORD_NOTIFICATION" object:nil];
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
    NSLog(@"STB-VEIW  did appear");
}


- (IBAction)showCableInfo:(id)sender
{
    CableInfoViewController *cableInfoController;
    cableInfoController = [[CableInfoViewController alloc] init:nil];
    cableInfoController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cableInfoController animated:YES completion:^{NSLog(@"DONE FOR show BLE CABLE INFO");}];
}

- (IBAction)showMeterInfo:(id)sender
{
    EquipInfoViewController *bgmInfoController;
    bgmInfoController = [[EquipInfoViewController alloc] init:nil];
    bgmInfoController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bgmInfoController animated:YES completion:^{NSLog(@"DONE FOR show BLE BGM INFO");}];
}

- (IBAction)showRecords:(id)sender
{
    NSLog(@"SHOW RESULT .... APP NEW");
    SyncResultViewController *recordsController;
    recordsController = [[SyncResultViewController alloc] init];
    recordsController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:recordsController animated:YES completion:^{NSLog(@"DONE FOR show RECORDS");}];

}

- (IBAction)showSyncMessage:(id)sender
{
    SyncMessageViewController *msgController;
    msgController = [[SyncMessageViewController alloc] init:nil];
    msgController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:msgController animated:YES completion:^{NSLog(@"DONE FOR show BLE SYNC MESSAGE");}];
}

- (IBAction)showBleHaveFoundDevice:(id)sender
{
    BleBeFoundViewController *bleDevController;
    bleDevController = [[BleBeFoundViewController alloc] init:[LibDelegateFunc sharedInstance].haveFoundBlePeripherals];
    bleDevController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bleDevController animated:YES completion:^{NSLog(@"DONE FOR show BLE DEVICE");}];
}

- (void)showBlePeripheralAfterPairing
{
    BleBeFoundViewController *bleDevController;
    bleDevController = [[BleBeFoundViewController alloc] init:[LibDelegateFunc sharedInstance].haveFoundBlePeripherals];
    bleDevController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bleDevController animated:YES completion:^{NSLog(@"(OLD)DONE FOR === SHOW HAVE FOUND");}];
}
- (void)autoShowBlePairing
{
    BleBeFoundViewController *bleDevController;
    bleDevController = [[BleBeFoundViewController alloc] init:[LibDelegateFunc sharedInstance].haveFoundBlePeripherals];
    bleDevController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:bleDevController animated:YES completion:^{NSLog(@"DONE FOR show BLE DEVICE");}];
}

#pragma mark - STOP SYNC ###
- (IBAction)audioBleSyncStop:(id)sender
{
    
    [_demoLabel1 pauseLabel];
 
    [LibDelegateFunc sharedInstance].demoSyncRunning = NO;
    //[[H2Sync sharedInstance] h2SyncStop:YES];

}
- (void) stbPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)clearLastDateTime:(id)sender
{
    if ([[LibDelegateFunc sharedInstance].serverLastDateTimes count] > 0) {
        [[LibDelegateFunc sharedInstance].serverLastDateTimes removeAllObjects];
    }
}

- (void)stbViewSetIndex:(NSString *)indexRecord withIndexLoop:(UInt16)indexLoop;
{
    labelIndex.text = indexRecord;
    NSString *loopString = [NSString stringWithFormat:@"   -- %03d", indexLoop];
    labelIndex.text = [labelIndex.text stringByAppendingString:loopString];
//J     NSLog(@"EM - DEMO SET INDEX, %@", labelIndex.text);
}

- (void)h2ShowLongRunStatus:(BOOL)finished
{
    if (finished) {
        bleLongRunAlertView = [[UIAlertView alloc] initWithTitle:@"BLE LING RUN" message:@"PASS" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    }else{
        bleLongRunAlertView = [[UIAlertView alloc] initWithTitle:@"BLE LING RUN" message:@"FAIL" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    }
    [bleLongRunAlertView show];
}
- (void)indexAndRecordNotification:(NSNotification *)notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"INDEX_OAD_RECORD"])
    {
//j        NSLog (@"Successfully received INDEX OR OAD NOTIFY!");
        labelIndex.text  = @"INDEX : ";
//jj        labelIndex.text = [ labelIndex.text  stringByAppendingString:[LibDelegateFunc sharedInstance].recordIndex];
//j        labelIndex.text = [ labelIndex.text  stringByAppendingString:[LibDelegateFunc sharedInstance].loopIndex];
        
//        labelIndex.text = [LibDelegateFunc sharedInstance].recordIndex;
// j        [LibDelegateFunc sharedInstance].qrStringCode = nil;
    }
    
    
    if ([[notification name] isEqualToString:@"BLE_CABLE_STATUS"]) {
        NSLog(@"BLE GOT SYNC STATUS ...");
        
        labelCableStatus.text = [LibDelegateFunc sharedInstance].syncStatusStringEx;
//j        labelCableStatus.text = [labelCableStatus.text stringByAppendingString:@" "];
//j        labelCableStatus.text = [labelCableStatus.text stringByAppendingString:[LibDelegateFunc sharedInstance].syncStatusString];
    }
    
    if ([[notification name] isEqualToString:@"SINGLE_RECORD_NOTIFICATION"]) {
        
        labelSigleRecord.text = [LibDelegateFunc sharedInstance].singleRecordValue;
    }
    
}

- (void)h2ClearCableStatus
{
    labelCableStatus.text = @" ";
    _statusTemp = @"ST :";
    NSLog(@"CLEAR CABLE STATUS ---  = %@", labelCableStatus.text);
}


+ (STBViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"EM - STB VIEW the instance value @%@", _sharedObject);
    return _sharedObject;
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
