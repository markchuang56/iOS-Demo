//
//  QRCodeViewController.h
//  SNWTool_BT
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 JasonChuang. All rights reserved.
//

#define NORMAL_YEAR
#define NORMAL_MONTH

#import <UIKit/UIKit.h>

@interface QRCodeViewController : UIViewController



- (IBAction)qrCodeScan:(id)sender;
//- (IBAction)qrCodeGen:(id)sender;


- (void)toolCableUpdate:(NSDictionary *)toolCable;
+ (QRCodeViewController *)sharedInstance;

@end


// [QRCodeViewController sharedInstance] lableQRString
