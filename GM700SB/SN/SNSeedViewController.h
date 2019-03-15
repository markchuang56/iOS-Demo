//
//  syViewController.h
//  SNWTool
//
//  Created by h2Sync on 2014/4/25.
//  Copyright (c) 2014年 JasonChuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSeedViewController : UIViewController <UITextFieldDelegate>
{
    
}
//@property (strong, nonatomic) IBOutlet UITextField *model;
//@property (strong, nonatomic) IBOutlet UITextField *customer;
//@property (strong, nonatomic) IBOutlet UITextField *seed;

- (IBAction)snSeedDone:(id)sender;
- (void) skipSetting:(id)sender;
@end



/*
@protocol H2SerialNumberDelegate <NSObject>

@required

@optional

@end




 

@interface H2SerialNumber : NSObject{
}

@property(nonatomic, unsafe_unretained) NSObject <H2SerialNumberDelegate> *serialNumberDelegate;

@property(nonatomic, unsafe_unretained) UniChar snModel;
@property(nonatomic, unsafe_unretained) UniChar snType;
@property(nonatomic, unsafe_unretained) UInt8 snYear;
@property(nonatomic, unsafe_unretained) UInt8 snMonth;
@property(nonatomic, unsafe_unretained) UniChar snCustomer;
@property(nonatomic, unsafe_unretained) UniChar snCustomerEx;

@property(nonatomic, unsafe_unretained) UInt32 snNumber;


+ (H2SerialNumber *)sharedInstance;
- (void)haha;

@end
*/
