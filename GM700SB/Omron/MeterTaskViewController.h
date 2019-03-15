//
//  BLEViewController.h
//  SQX
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#define USER_ID_MODE                    1
#define GET_RECORD_MODE                 0
#define BLE_EQUIP_MASK                  0x00008000

#import <UIKit/UIKit.h>

@interface MeterTaskViewController : UIViewController


//@property(readwrite) BOOL meterTaskAutoSync;

- (void)syncFromDeviceHaveFound:(id)sender;

- (void)syncAndPairingTask:(UInt8)dType withUid:(UInt8)uId andInterfaceFunc:(UInt8)func withString:(NSString *)doneString;

- (IBAction)bleSyncTask:(id)sender;

- (void)bionimePairAgain;
+ (MeterTaskViewController *)sharedInstance;
@end


