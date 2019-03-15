//
//  BLEViewController.h
//  SQX
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDAViewController : UIViewController



@property(readwrite) BOOL *scanAndPair;



+ (BDAViewController *)sharedInstance;
@end

#pragma mark - BLE VENDOR OBJECT
@interface BleVendor : NSObject



@property(readwrite) UInt16 vendorMeterId;
@property(nonatomic, strong) NSString *vdTitleString;


+ (BleVendor *)sharedInstance;
@end


