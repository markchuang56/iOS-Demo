//
//  BLEViewController.m
//  SQX
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "SQXViewController.h"
#import "BDAViewController.h"
#import "BleBeFoundViewController.h"
#import "BleBGMViewController.h"


#import "LibDelegateFunc.h"

#import "STBViewController.h"

#define IMG_BLOCK_SIZE              16
#define IMG_BUFFER_SIZE             0x4FFFF // 128 KB

@interface BDAViewController ()
{
    UIButton *btnOmronRecords;
    UIButton *btnBleScanPair;
    UIButton *btnBleScanSync;

    UIButton *btnBleUpdateOAD_B;
    UIButton *btnBleDeviceSelect;
    
    UILabel *labelBleDevice;
    
    NSString *oadSrcPath;
    //NSString *vdTitleString;
}

- (void)h2OadUpdate;
@end

@implementation BDAViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
/*
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vendorFunctionNotification:) name:@"VENDOR_CHANGED" object:nil];
        [BleVendor sharedInstance].vendorMeterId = [[NSUserDefaults standardUserDefaults] integerForKey:@"meter_sel"];
        NSLog(@"INIT METER ID is %04X, ak = %04X", [BleVendor sharedInstance].vendorMeterId, SM_BLE_ARKRAY_GT_1830);
        
        if ([BleVendor sharedInstance].vendorMeterId == SM_BLE_ARKRAY_GT_1830) {
            [BleVendor sharedInstance].vdTitleString = @"ARKRAY FUNCTION";
            NSLog(@"ARKRAY ...");
        }else{
            [BleVendor sharedInstance].vdTitleString = @"OMRON FUNCTION";
            NSLog(@"OMRON");
        }
*/
        [BleVendor sharedInstance].vdTitleString = @"ARKRAY FUNCTION";
        
        UINavigationBar *navBleBar = [[UINavigationBar alloc]
                                   initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                       initWithTitle:@"BACK"
                                       style:UIBarButtonItemStylePlain
                                       target:self action:@selector(blePageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:[BleVendor sharedInstance].vdTitleString];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
// LABEL
        
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
        
// BUTTON
        btnOmronRecords = [[UIButton alloc] init];
        btnBleScanPair = [[UIButton alloc] init];
        btnBleScanSync = [[UIButton alloc] init];
        btnBleUpdateOAD_B = [[UIButton alloc] init];
        btnBleDeviceSelect = [[UIButton alloc] init];
        
        
        
        
        btnOmronRecords = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBleScanPair = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBleScanSync = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBleUpdateOAD_B = [UIButton buttonWithType:UIButtonTypeCustom];
        btnBleDeviceSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        
         NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnOmronRecords];
        [bottunArray addObject:btnBleScanPair];
        [bottunArray addObject:btnBleScanSync];
        [bottunArray addObject:btnBleUpdateOAD_B];
        [bottunArray addObject:btnBleDeviceSelect];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        if ([BleVendor sharedInstance].vendorMeterId == SM_BLE_ARKRAY_GT_1830) {
            //vdTitleString = @"ARKRAY FUNCTION";
            [btnString addObject:@"ARKRAY RECORDS"];
            [btnString addObject:@"BLE PAIRING"];
            [btnString addObject:@"ARKRAY INIT"];
            [btnString addObject:@"BLE OAD BBB"];
            [btnString addObject:@"BLE DEVICE SEL"];
            NSLog(@"ARKRAY ...");
        }else{
            //vdTitleString = @"OMRON FUNCTION";
            NSLog(@"OMRON");
            [btnString addObject:@"OMRON GET RECORDS"];
            [btnString addObject:@"BLE PAIRING"];
            [btnString addObject:@"OMRON SYNC(I)"];
            [btnString addObject:@"BLE OAD BBB"];
            [btnString addObject:@"BLE DEVICE SEL"];
        }
        
        
        
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
                    [btnBleMethod addTarget:self action:@selector(btnOmronRecordsTask:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(blePairing:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(bleSync:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 3:
                    [btnBleMethod addTarget:self action:@selector(bleOADUpdateImgB:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 4:
                    [btnBleMethod addTarget:self action:@selector(bleDeviceShow:) forControlEvents:UIControlEventTouchUpInside];
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



- (IBAction)btnOmronRecordsTask:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"OMRON RECORDS";
   // [[H2Sync sharedInstance] h2BleDebugScan: YES];
    
    [[H2Sync sharedInstance] h2OmronGetRecords:nil];
    
    STBViewController *stbController =[[STBViewController alloc] init];
    [self presentViewController:stbController animated:YES completion:^{NSLog(@"OMRON RECORDS DONE ");}];
}


- (IBAction)blePairing:(id)sender
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

- (IBAction)bleSync:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE SYNC";
    NSLog(@"BLE METER ID is %04X", [[NSUserDefaults standardUserDefaults] integerForKey:@"meter_sel"]);
    
    BOOL snStatus = NO;
    NSString *uuidString;
/*
    // add for TEST
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"H2_QR_SN"] != nil) {
        NSLog(@"BLE T SN qr String %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"H2_QR_SN"]);
        [LibDelegateFunc sharedInstance].qrStringCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"H2_QR_SN"];
    }
*/
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
        
        // FOR LONG RUN TEST ...
// j        [[LibDelegateFunc sharedInstance].serverLastDateTimes removeAllObjects];
    }

 //   [[H2Sync sharedInstance] h2BlePreSync:[LibDelegateFunc sharedInstance].serverLastDateTimes withSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode];
    BOOL checkQRCode = NO;
    
    UInt8 status = [[H2Sync sharedInstance] h2BlePreSync:uuidString withLastDateTime:[LibDelegateFunc sharedInstance].serverLastDateTimes withSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode withUserID:[LibDelegateFunc sharedInstance].userID andUserEmail:[LibDelegateFunc sharedInstance].userEMail qrCodeChecking:checkQRCode];
    
    
 //   - (UInt8)h2BlePreSync:(NSString *)identifierString withLastDateTime:(NSArray *)serverLastDateTimeArray withSerialNumber:(NSString *)sn;
    
    NSLog(@"RECONNECCT STATUS IS %d AND LDT %@", status, [LibDelegateFunc sharedInstance].serverLastDateTimes);
    
    STBViewController *stbController =[[STBViewController alloc] init];
    [self presentViewController:stbController animated:YES completion:^{NSLog(@"SYNC_STB done");}];
    
    NSLog(@"THE RETURN VALUE IS %d", status);
}





- (IBAction)bleOADUpdateImgB:(id)sender {
    oadSrcPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imgB.bin"];
    [self h2OadUpdate];
    
}

- (IBAction)bleOADUpdateImgaA:(id)sender {
    oadSrcPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imgA.bin"];
    [self h2OadUpdate];
}

- (void)h2OadUpdate
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"BLE OAD";
    NSString *bin = [[NSString alloc] init];
//    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/imgB.bin"];
    
    bin =  [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:oadSrcPath] encoding:NSUTF8StringEncoding];

    unsigned char imgBuffer[IMG_BUFFER_SIZE]; // 128 KB
    
    
    if ([[NSFileManager defaultManager] isReadableFileAtPath:oadSrcPath]) {
        NSMutableData *imgSrc = [NSMutableData dataWithContentsOfFile:oadSrcPath];
        NSLog(@"bin here ...");
        if ([imgSrc length] == 0) {
            NSLog(@"file empty ...");
            return;
        }
        memcpy(imgBuffer, [imgSrc mutableBytes], [imgSrc length]);
        NSLog(@"BIN Did come to here ...%d", [imgSrc length]);
        
#if 0
        unsigned char secondBuffer[IMG_BLOCK_LEN * 2];
        for (int i=0; i<[imgSrc length]; i+=IMG_BLOCK_LEN) {
            memcpy(secondBuffer, &imgBuffer[i], IMG_BLOCK_LEN);
                for (int j=0; j<IMG_BLOCK_LEN; j++) {
                    NSLog(@"BIN DATA IS id %02d and data %02X", j, secondBuffer[j]);
                }
            NSLog(@"BIN DATA IS id %02d and data %02X", i, imgBuffer[i]);
         }
#endif
        

        [[H2Sync sharedInstance] H2OadUpDateFlash:imgBuffer withSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode withUserID:[LibDelegateFunc sharedInstance].userID andUserEmail:[LibDelegateFunc sharedInstance].userEMail];
    }else{
        NSLog(@"update fail : NO SOURCE !!");
    }
    
    STBViewController *stbController =[[STBViewController alloc] init];
    [self presentViewController:stbController animated:YES completion:^{NSLog(@"BLE VIEW done");}];
}

#pragma mark - VENDOR CHANGED NOTIFICATION
- (void)vendorFunctionNotification:(NSNotification *)notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"VENDOR_CHANGED"])
    {
        [BleVendor sharedInstance].vendorMeterId = [[NSUserDefaults standardUserDefaults] integerForKey:@"meter_sel"];
        NSLog(@"INIT METER ID is %04X, ak = %04X", [BleVendor sharedInstance].vendorMeterId, SM_BLE_ARKRAY_GT_1830);
        
        NSLog (@"VENDOR CHANGED ... NOTIFY! ID = %04X" , [BleVendor sharedInstance].vendorMeterId);
        if ([BleVendor sharedInstance].vendorMeterId == SM_BLE_ARKRAY_GT_1830) {
            [BleVendor sharedInstance].vdTitleString = @"ARKRAY FUNCTION";
            NSLog(@"ARKRAY ... %@", [BleVendor sharedInstance].vdTitleString);
        }else{
            [BleVendor sharedInstance].vdTitleString = @"OMRON FUNCTION";
            NSLog(@"OMRON -- %@", [BleVendor sharedInstance].vdTitleString);
        }
    }
}

- (IBAction)bleDeviceShow:(id)sender {
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bgmShowNotification:)
                                                 name:@"BGM_SHOW"
                                               object:nil];
    BleBGMViewController *bleShowController =[[BleBGMViewController alloc] init:nil];
    [self presentViewController:bleShowController animated:YES completion:^{NSLog(@"BLE SHOW BGM done");}];
}




- (void)bgmShowNotification:(id)sender
{
    labelBleDevice.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"H2_QR_SN"];
    NSLog(@"Get New Meter ID %04X", [[NSUserDefaults standardUserDefaults] integerForKey:@"meter_sel"]);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) blePageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


+ (BDAViewController *)sharedInstance
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


@interface BleVendor ()
{
    
}


@end

@implementation BleVendor
- (id)init
{
    self = [super init];
    if (self) {
        _vdTitleString = [[NSString alloc] init];
    }
    return self;
}


+ (BleVendor *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;

    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"BLE VENDOR instance value @%@", _sharedObject);
    return _sharedObject;
}

@end
