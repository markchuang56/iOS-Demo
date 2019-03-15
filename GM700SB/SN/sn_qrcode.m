//
//  sn_qrcode.m
//  APX
//
//  Created by h2Sync on 2016/4/25.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "sn_qrcode.h"

#import "UIImage+MDQRCode.h"

@implementation SN_QRCode



/*

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
*/
- (BOOL)snToQRCode
{
    NSString *qr;
    NSString *qrFileName;
    
    UIViewController *viewController = [[UIViewController alloc] init];
    CGFloat imageSize = ceilf(viewController.view.bounds.size.width * 0.6f);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf(viewController.view.bounds.size.width * 0.5f - imageSize * 0.5f), floorf(viewController.view.bounds.size.height * 0.5f - imageSize * 0.5f), imageSize, imageSize)];
    [viewController.view addSubview:imageView];
    NSLog(@"H2 DEBUG string input ...");
    //imageView.image = [UIImage mdQRCodeForString:@"Hello, world!" size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
    qr = [self binToStringQR];
    
    imageView.image = [UIImage mdQRCodeForString:qr size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
    //    self.window.rootViewController = viewController;
    
//    qrFileName = [qr stringByAppendingString:@".png"];
    
    qrFileName = [NSString stringWithFormat:@"Documents/%@.png",qr];
    
    // Added By Jason
    // Create paths to output images
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:qrFileName];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];

/*
    imageView.image = [UIImage mdQRCodeForString:@"TT1510QR000072" size:imageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
//    self.window.rootViewController = viewController;
    
    // Added By Jason
    // Create paths to output images
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/qrTest.png"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
*/
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
    return YES;
}



- (NSString *)binToStringQR
{
    NSString *qrString;
 /*
    unsigned char tmp[12] = {0};
    tmp[SN_MODEL_AT_0] = [H2SerialNumber sharedInstance].snModel;//'G';
    tmp[SN_TYPE_AT_1] = [H2SerialNumber sharedInstance].snType;//'A';
    
    tmp[SN_YEAR_AT_2] = [H2SerialNumber sharedInstance].snYear;
    tmp[SN_MONTH_AT_3] = [H2SerialNumber sharedInstance].snMonth;
    
    tmp[SN_CUSTOMER_AT_4] = [H2SerialNumber sharedInstance].snCustomer;
    tmp[SN_CUSTOMEREX_AT_5] = [H2SerialNumber sharedInstance].snCustomerEx;
    
    memcpy(&tmp[SN_NUMBER_AT_6], &snNumber, sizeof(snNumber));
*/
/*
    tmp[SN_CRC_AT_9] = tmp[0];
    for(int i = 1; i < SN_CRC_AT_9; i++){
        tmp[SN_CRC_AT_9] ^= tmp[i];
    }// Command checking
*/
//    serialNumber.text
    
#if 1
    [H2SerialNumber sharedInstance].snMonth = 5;
    qrString= [NSString stringWithFormat:@"%C%C%02d%02d%C%C%06d", [H2SerialNumber sharedInstance].snModel, [H2SerialNumber sharedInstance].snType, [H2SerialNumber sharedInstance].snYear, [H2SerialNumber sharedInstance].snMonth, [H2SerialNumber sharedInstance].snCustomer, [H2SerialNumber sharedInstance].snCustomerEx, (unsigned int)[H2SerialNumber sharedInstance].snNumber];
#else
    qrString= [NSString stringWithFormat:@"SN : %C%C %02d %02d %C%C %06d", [H2SerialNumber sharedInstance].snModel, [H2SerialNumber sharedInstance].snType, [H2SerialNumber sharedInstance].snYear, [H2SerialNumber sharedInstance].snMonth, [H2SerialNumber sharedInstance].snCustomer, [H2SerialNumber sharedInstance].snCustomerEx, (unsigned int)[H2SerialNumber sharedInstance].snNumber];
#endif
    [H2SerialNumber sharedInstance].snNumber++;
    return qrString;
}




+ (SN_QRCode *)sharedInstance
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
    NSLog(@"SQX INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}


@end


@implementation H2SerialNumber
{
    
}


- (id)init
{
    if (self = [super init]) {
        _snModel = 'X';
        _snType = 'X';
        _snYear = 0;
        _snMonth = 0;
        _snCustomer = 'X';
        _snCustomerEx = 'X';
        _snNumber = 0;
        _qrCycle = 0;
        
        _stringBeScanned = @"";
    }
    return self;
}


+ (H2SerialNumber *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"EM - SN QRCODE the instance value @%@", _sharedObject);
    return _sharedObject;
}

- (void)haha
{
    NSLog(@"show haha ----");
}

@end
