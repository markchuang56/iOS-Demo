//
//  syFirstViewController.h
//  tabH2
//
//  Created by JasonChuang on 13/10/19.
//  Copyright (c) 2013年 JasonChuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "H2Sync.h"


@interface SNWriteViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

{
    IBOutlet UIBarButtonItem *_toggleButton;
    IBOutlet UIBarButtonItem *_clearButton;
}
//@property (strong, nonatomic) IBOutlet UILabel *serialNumber;

@property (nonatomic, strong) IBOutlet UITextField *counter;

@property (nonatomic, strong) IBOutlet UITextView *consoleView;

@property (nonatomic, strong) IBOutlet UILabel *testStatus;


- (IBAction)snSeedSetting:(id)sender;


+ (SNWriteViewController *)sharedInstance;

@end




