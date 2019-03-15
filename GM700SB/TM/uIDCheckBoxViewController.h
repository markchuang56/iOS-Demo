//
//  uIDCheckBoxViewController.h
//  OM6320T
//
//  Created by h2Sync on 2017/5/17.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface uIDCheckBoxViewController : UIViewController
{
/*
    BOOL bgTypeChecked;
    BOOL bpTypeChecked;
    BOOL bwTypeChecked;
*/
    BOOL uId1Checked;
    BOOL uId2Checked;
    BOOL uId3Checked;
    BOOL uId4Checked;
    BOOL uId5Checked;
 
}
@property (weak, nonatomic) IBOutlet UIButton *cbBgRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *cbBpRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *cbBwRecordButton;

@property (weak, nonatomic) IBOutlet UIButton *cbUser1Button;
@property (weak, nonatomic) IBOutlet UIButton *cbUser2Button;
@property (weak, nonatomic) IBOutlet UIButton *cbUser3Button;
@property (weak, nonatomic) IBOutlet UIButton *cbUser4Button;
@property (weak, nonatomic) IBOutlet UIButton *cbUser5Button;

- (IBAction)cbBgType:(id)sender;
- (IBAction)cbBpType:(id)sender;
- (IBAction)cbBwType:(id)sender;

- (IBAction)cbUser1Id:(id)sender;
- (IBAction)cbUser2Id:(id)sender;
- (IBAction)cbUser3Id:(id)sender;
- (IBAction)cbUser4Id:(id)sender;
- (IBAction)cbUser5Id:(id)sender;

- (IBAction)uidDoneBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneAndBack;

@end

@interface OmronUserIdAndRdType : NSObject

@property (readwrite) BOOL bgTypeChecked;
@property (readwrite) BOOL bpTypeChecked;
@property (readwrite) BOOL bwTypeChecked;

@property (readwrite) UInt8 omronRecordType;
@property (readwrite) UInt8 omronUserIdSel;



+ (OmronUserIdAndRdType *)sharedInstance;
@end





