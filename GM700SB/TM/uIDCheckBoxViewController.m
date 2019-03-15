//
//  uIDCheckBoxViewController.m
//  OM6320T
//
//  Created by h2Sync on 2017/5/17.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "uIDCheckBoxViewController.h"
#import "H2Records.h"

@interface uIDCheckBoxViewController ()

@end

@implementation uIDCheckBoxViewController


- (id)init
{
    NSLog(@"CHECK BOX INIT");
    if (self = [super init]) {
        
        [OmronUserIdAndRdType sharedInstance].bgTypeChecked = NO;
        [OmronUserIdAndRdType sharedInstance].bpTypeChecked = YES;
        [OmronUserIdAndRdType sharedInstance].bwTypeChecked = YES;
        
        uId1Checked = NO;
        uId2Checked = YES;
        uId3Checked = YES;
        uId4Checked = YES;
        uId5Checked = YES;
 
        

        [_doneAndBack setTitle:@"DONE & BACK" forState:UIControlStateNormal];
        
        NSLog(@"THE VALUE is %02X AT INIT", [OmronUserIdAndRdType sharedInstance].omronUserIdSel);
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"CHECK BOX LOAD");
    // Do any additional setup after loading the view from its nib.
    [self cbBgType:nil];
    [self cbBpType:nil];
    [self cbBwType:nil];
    
    [self cbUser1Id:nil];
    [self cbUser2Id:nil];
    [self cbUser3Id:nil];
    [self cbUser4Id:nil];
    [self cbUser5Id:nil];
    
    NSLog(@"THE VALUE is %02X AT LOAD", [OmronUserIdAndRdType sharedInstance].omronUserIdSel);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - RECORD TYPE TASK
- (IBAction)cbBgType:(id)sender {
    if ([OmronUserIdAndRdType sharedInstance].bgTypeChecked) {
        [OmronUserIdAndRdType sharedInstance].bgTypeChecked = NO;
        [OmronUserIdAndRdType sharedInstance].omronRecordType &= (~RECORD_TYPE_BG);
        [_cbBgRecordButton setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else if (![OmronUserIdAndRdType sharedInstance].bgTypeChecked){
        [OmronUserIdAndRdType sharedInstance].bgTypeChecked = YES;
        [OmronUserIdAndRdType sharedInstance].omronRecordType |= RECORD_TYPE_BG;
        [_cbBgRecordButton setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)cbBpType:(id)sender {
    if ([OmronUserIdAndRdType sharedInstance].bpTypeChecked) {
        [OmronUserIdAndRdType sharedInstance].bpTypeChecked = NO;
        [OmronUserIdAndRdType sharedInstance].omronRecordType &= (~RECORD_TYPE_BP);
        [_cbBpRecordButton setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else if (![OmronUserIdAndRdType sharedInstance].bpTypeChecked){
        [OmronUserIdAndRdType sharedInstance].bpTypeChecked = YES;
        [OmronUserIdAndRdType sharedInstance].omronRecordType |= RECORD_TYPE_BP;
        [_cbBpRecordButton setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)cbBwType:(id)sender {
    if ([OmronUserIdAndRdType sharedInstance].bwTypeChecked) {
        [OmronUserIdAndRdType sharedInstance].bwTypeChecked = NO;
        [OmronUserIdAndRdType sharedInstance].omronRecordType &= (~RECORD_TYPE_BW);
        [_cbBwRecordButton setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else if (![OmronUserIdAndRdType sharedInstance].bwTypeChecked){
        [OmronUserIdAndRdType sharedInstance].bwTypeChecked = YES;
        [OmronUserIdAndRdType sharedInstance].omronRecordType |= RECORD_TYPE_BW;
        [_cbBwRecordButton setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
}






#pragma mark - USER ID TASK
- (IBAction)cbUser1Id:(id)sender {
    if (uId1Checked) {
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel &= (~USER_TAG1_MASK);
        [_cbUser1Button setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else{
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel |= USER_TAG1_MASK;
        [_cbUser1Button setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
    uId1Checked ^= YES;
}

- (IBAction)cbUser2Id:(id)sender {
    if (uId2Checked) {
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel &= (~USER_TAG2_MASK);
        [_cbUser2Button setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else{
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel |= USER_TAG2_MASK;
        [_cbUser2Button setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
    uId2Checked ^= YES;
    NSLog(@"THE USER ID IS = %02X AT TWO", [OmronUserIdAndRdType sharedInstance].omronUserIdSel);
}


- (IBAction)cbUser3Id:(id)sender {
    if (uId3Checked) {
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel &= (~USER_TAG3_MASK);
        [_cbUser3Button setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else{
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel |= USER_TAG3_MASK;
        [_cbUser3Button setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
    uId3Checked ^= YES;
}
- (IBAction)cbUser4Id:(id)sender {
    if (uId4Checked) {
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel &= (~USER_TAG4_MASK);
        [_cbUser4Button setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else{
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel |= USER_TAG4_MASK;
        [_cbUser4Button setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
    uId4Checked ^= YES;
}

- (IBAction)cbUser5Id:(id)sender {
    NSLog(@"SET USER ID - AT 5");
    if (uId5Checked) {
        NSLog(@"SET USER ID - AT 5 YES");
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel &= (~USER_TAG5_MASK);
        [_cbUser5Button setImage:[UIImage imageNamed:@"checkbox_empty.png"] forState:UIControlStateNormal];
    }else{
        NSLog(@"SET USER ID - AT 5 NO");
        [OmronUserIdAndRdType sharedInstance].omronUserIdSel |= USER_TAG5_MASK;
        [_cbUser5Button setImage:[UIImage imageNamed:@"checkbox_tick.png"] forState:UIControlStateNormal];
    }
    uId5Checked ^= YES;
    NSLog(@"CHK BOX RECORD TYPE %04X", [OmronUserIdAndRdType sharedInstance].omronRecordType);
    NSLog(@"CHK BOX USER ID %04X", [OmronUserIdAndRdType sharedInstance].omronUserIdSel);
}

- (IBAction)uidDoneBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end


@implementation OmronUserIdAndRdType

- (id)init
{
    if (self = [super init]) {
        _bgTypeChecked = YES;
        _bpTypeChecked = NO;
        _bwTypeChecked = NO;
        
        _omronRecordType = RECORD_TYPE_BG;
        _omronUserIdSel = USER_TAG1_MASK;
    }
    return self;
}




+ (OmronUserIdAndRdType *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred = 0;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}


@end


