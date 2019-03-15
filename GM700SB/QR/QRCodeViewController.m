//
//  QRCodeViewController.m
//  SNWTool_BT
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 JasonChuang. All rights reserved.
//

#import "QRCodeViewController.h"
#import "UIImage+MDQRCode.h"

#import "QRScanViewController.h"
#import "H2ReportViewController.h"

#import "LibDelegateFunc.h"

#import "sn_qrcode.h"
#import "SNSeedViewController.h"

@interface QRCodeViewController ()
{
    QRScanViewController *qrScanController;
    H2ReportViewController *qrCodeString;
    
    UILabel *labelQRString;
    UIButton *btnScan;
}



@end

@implementation QRCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        UINavigationBar *navQRBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navQRBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(qrPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"QR FUNCTION"];
        
        navItem.leftBarButtonItem = btnBack;
        [navQRBar pushNavigationItem:navItem animated:NO];
        
        //
        self.view.backgroundColor = [UIColor blueColor];


        // Custom initialization
        btnScan = [[UIButton alloc] init];
        btnScan = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        btnScan.frame = CGRectMake(20, 60 + 40, 280, 40);
        
        [btnScan.titleLabel setFont:[UIFont systemFontOfSize:26]];
        
        [btnScan.layer setMasksToBounds:YES];
        [btnScan.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnScan.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnScan setTitle:@"QR SCAN" forState:UIControlStateNormal];
        
        [btnScan setBackgroundImage:[UIImage imageNamed:@"blue2.png"]
                            forState:UIControlStateNormal];
        
        [btnScan addTarget:self action:@selector(qrCodeScan:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnScan];
        
        
        labelQRString = [[UILabel alloc] init];
        
        labelQRString.frame = CGRectMake(20, 200, 200, 40);
        
        [labelQRString setFont:[UIFont fontWithName:@"System" size:26]];
        
        [labelQRString setBackgroundColor:[UIColor whiteColor]];
        [labelQRString setTextColor:[UIColor redColor]];
        
        [labelQRString.layer setMasksToBounds:YES];
        [labelQRString.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [labelQRString.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        
        labelQRString.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"];
        
        
        [self.view addSubview:labelQRString];
        
        
// SHOW QR CODE
        
        UIButton *btnQRCodeShow = [[UIButton alloc] init];
        btnQRCodeShow = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnQRCodeShow.frame = CGRectMake(20, 260, 280, 40);
        
        
        [btnQRCodeShow.titleLabel setFont:[UIFont systemFontOfSize:26]];
        
        [btnQRCodeShow.layer setMasksToBounds:YES];
        [btnQRCodeShow.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnQRCodeShow.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnQRCodeShow setTitle:@"QR SHOW" forState:UIControlStateNormal];
        
        [btnQRCodeShow setBackgroundImage:[UIImage imageNamed:@"blue2.png"]
                                     forState:UIControlStateNormal];
        
        [btnQRCodeShow addTarget:self action:@selector(qrCodeShowString:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnQRCodeShow];
        
        // QR CODE GENERATE BUTTON
        
        UIButton *btnQRCodeGenerate = [[UIButton alloc] init];
        btnQRCodeGenerate = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnQRCodeGenerate.frame = CGRectMake(20, 320, 280, 40);
        
        
        [btnQRCodeGenerate.titleLabel setFont:[UIFont systemFontOfSize:26]];
        
        [btnQRCodeGenerate.layer setMasksToBounds:YES];
        [btnQRCodeGenerate.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnQRCodeGenerate.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnQRCodeGenerate setTitle:@"QR GENERATE" forState:UIControlStateNormal];
        
        [btnQRCodeGenerate setBackgroundImage:[UIImage imageNamed:@"blue2.png"]
                                     forState:UIControlStateNormal];
        
        [btnQRCodeGenerate addTarget:self action:@selector(qrCodeBuilder:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnQRCodeGenerate];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveScanQRNotification:) name:@"QRStringNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveScanQRNotification:) name:@"QR_BUILD_NOTIFY" object:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"DID COME TO HERE ... QR CODE DID LOAD");
    
    
    // BAR
    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 10, 320, 44)];
    [self.view addSubview:navBar];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - H2 SCAN QR CODE
- (IBAction)qrCodeScan:(id)sender
{
    // 進入掃描 QR Code 頁面
    qrScanController = [[QRScanViewController alloc] init];
    qrScanController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:qrScanController animated:YES completion:^{NSLog(@"done");}];

}


- (IBAction)qrCodeShowString:(id)sender {
    NSLog(@"THE STRING IS %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"]);
    
    qrCodeString = [[H2ReportViewController alloc] init:nil];
    qrCodeString.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:qrCodeString animated:YES completion:^{NSLog(@"done FOR show QR STRING");}];
}

- (IBAction)qrCodeBuilder:(id)sender {
    SNSeedViewController *snSettingController =[[SNSeedViewController alloc] init];
    [self presentViewController:snSettingController animated:YES completion:^{NSLog(@"done");}];
    //[self doSomething];
}

- (void)receiveScanQRNotification:(NSNotification *)notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"QRStringNotification"])
    {
        NSLog (@"APP Successfully received the test notification!");
        labelQRString.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"];
        
        NSDictionary *toolCable;
        toolCable = @{@"TOOL_SerialNumber" : labelQRString.text, @"TOOL_Identifier" : @""};
        
        [self toolCableUpdate:toolCable];
        [labelQRString updateConstraints];
    }
    
    // BU170601000035
    // BU1612H2000027
    if ([[notification name] isEqualToString:@"QR_BUILD_NOTIFY"])
    {
        // CREATE QR CODE
        unsigned char qr[16] = {0};
         UInt32 sNumber = [H2SerialNumber sharedInstance].snNumber;
        NSLog(@"SRC - SN %X", (int)sNumber);
       
        qr[0] = [self lotToUp:[H2SerialNumber sharedInstance].snModel];
        qr[1] = [self lotToUp:[H2SerialNumber sharedInstance].snType];
        
        
        qr[2] = ([H2SerialNumber sharedInstance].snYear /10) | '0';
//#if 0 // 17 年 或當年
#ifdef NORMAL_YEAR
        qr[3] = ([H2SerialNumber sharedInstance].snYear %10) | '0';
#else // 16 年 固定年
        qr[3] = '6';
#endif
  
//#if 0   // 當月
#ifdef NORMAL_MONTH
        qr[4] = ([H2SerialNumber sharedInstance].snMonth /10) | '0';
        qr[5] = ([H2SerialNumber sharedInstance].snMonth %10) | '0';
#else   // 固定月
        qr[4] = '1';//'0';//'1';
        qr[5] = '2';//'6';//'2'; //'2';
#endif
        qr[6] = [self lotToUp:[H2SerialNumber sharedInstance].snCustomer];
        qr[7] = [self lotToUp:[H2SerialNumber sharedInstance].snCustomerEx];
        
        for (int i=0; i<6; i++) {
            qr[13-i] = (sNumber % 10) | '0';
            sNumber /= 10;
        }
        
        [LibDelegateFunc sharedInstance].qrStringCode = [NSString stringWithUTF8String:(const char *)qr];
        for (int i=0; i<16; i++) {
            NSLog(@"QR - SN %d = %02X", i, qr[i]);
        }
        
        labelQRString.text =[NSString stringWithFormat:@"QR : %@", [LibDelegateFunc sharedInstance].qrStringCode];
        [[NSUserDefaults standardUserDefaults] setObject:[LibDelegateFunc sharedInstance].qrStringCode forKey:@"UDEF_QR_CODE"];
    }
    
}



- (void)doSomething
{
    UIViewController *viewController = [[UIViewController alloc] init];
    CGFloat imageSize = ceilf(viewController.view.bounds.size.width * 0.6f);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf(viewController.view.bounds.size.width * 0.5f - imageSize * 0.5f), floorf(viewController.view.bounds.size.height * 0.5f - imageSize * 0.5f), imageSize, imageSize)];
    [viewController.view addSubview:imageView];
    NSLog(@"H2 DEBUG string input ...");
    //imageView.image = [UIImage mdQRCodeForString:@"Hello, world!" size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
    imageView.image = [UIImage mdQRCodeForString:@"TT1510QR000072" size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
//    self.rootViewController = viewController;
//    UIImage *img= [UIImage i]

    // Added By Jason
    // Create paths to output images
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.png"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
    
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
    [UIImageJPEGRepresentation(imageView.image, 1.0) writeToFile:jpgPath atomically:YES];
    
    // Write image to PNG
    [UIImagePNGRepresentation(imageView.image) writeToFile:pngPath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    NSLog(@"DID COME TO PNG ...");
}

- (void)toolCableUpdate:(NSDictionary *)toolCable
{
    
    // 加入 TOOL 的序號 和 Identifier 到表單內
    // 單獨掃描 序號時，有序號，無 Identifier
    // 掃描 TOOL Cable 時，有序號，有 Identifier
    
    
    if (toolCable == nil) {
        // 無任何資料時
        return;
    }
    
    // 傳入 Tool Cable 的 序號 和 ID
    NSString *toolSerialNumber = [toolCable objectForKey: @"TOOL_SerialNumber"];
    NSString *toolIdentifier = [toolCable objectForKey: @"TOOL_Identifier"];
    
    NSLog(@"TOOL SN %@ AND ID %@", toolSerialNumber, toolIdentifier);
    
    if ([toolSerialNumber isEqualToString:@""]) {
        // 無序號時
        return;
    }
    
    /*
     NSDictionary *toolSerialNumberNew = nil;
     toolSerialNumberNew = @{@"TOOL_SerialNumber" : toolSerialNumber, @"TOOL_Identifier" : toolIdentifier };
     
     NSString *stringSerialNumberFromQRCode = [toolCable objectForKey: @"TOOL_SerialNumber"];
     */
    
    int index=0;
    BOOL newCable = YES;
    // 如果不是空字串，加入 序號表單內
    
    if (![toolSerialNumber isEqualToString:@""]) {
        
        if ([[LibDelegateFunc sharedInstance].tmswToolCableListing count] > 0) {
            for (NSDictionary *tool in [LibDelegateFunc sharedInstance].tmswToolCableListing){
                if ([toolSerialNumber isEqualToString:[tool objectForKey: @"TOOL_SerialNumber"]]) { // Old Serial Number
                    if (![toolIdentifier isEqualToString:@""] ) {
                        // 取代舊的 序號 和 ID
                        [[LibDelegateFunc sharedInstance].tmswToolCableListing replaceObjectAtIndex:index withObject:toolCable];
                        
                        newCable = NO;
                        break;
                    }
#ifdef DEBUG_LIB
                    NSLog(@"Old Serial Number ---- \n" );
#endif
                }
                index++;
            }
        }
        if (newCable) {
            // 加入新的 TOOL Cable
            [[LibDelegateFunc sharedInstance].tmswToolCableListing addObject:toolCable];
        }
    }else{
        NSLog(@"NO SN have found");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) qrPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (unsigned char)lotToUp:(unsigned char)src
{
    unsigned char dst = src;
    if (src >= 'a') {
        dst  -= 0x20;
    }
    return dst;
}


+ (QRCodeViewController *)sharedInstance
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
