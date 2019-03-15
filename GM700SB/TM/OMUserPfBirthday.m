//
//  OMUserProfileBirthdayViewController.m
//  Omron
//
//  Created by h2Sync on 2017/3/2.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "MeterTaskViewController.h"

#import "OMUserPfGender.h"
#import "OMUserPfBirthday.h"
#import "OMUserPfBodyHeight.h"
#import "H2Sync.h"
#import "LibDelegateFunc.h"

#import "H2AudioHelper.h"
//#import "UserProfileFromApp.h"
#import "LibDelegateFunc.h"

@interface OMUserProfileBirthdayViewController ()
{
    
    UIButton *btnNext;
    
    UILabel *birthdayLabel;
    
    UILabel *birthdayYearLabel;
    UILabel *birthdayMonthLabel;
    UILabel *birthdayDayLabel;
    
    UITextField *birthdayYearTextField;
    UITextField *birthdayMonthTextField;
    UITextField *birthdayDayTextField;
}



@end

@implementation OMUserProfileBirthdayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(birthdayPageBack:)];
        
        
        UIBarButtonItem *btnBirthdayDone = [[UIBarButtonItem alloc]
                                    initWithTitle:@"DONE"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(birthdayDone:)];
        
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"USER BIRTHDAY"];
        
        navItem.leftBarButtonItem = btnBack;
        navItem.rightBarButtonItem = btnBirthdayDone;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        
        
        
        // Date Time Format
        _bDateFormatter = [[NSDateFormatter alloc] init];
        //[_bDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
        //_bDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        //_bDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
/*
 NSDateFormatterNoStyle = kCFDateFormatterNoStyle,
 NSDateFormatterShortStyle = kCFDateFormatterShortStyle,
 NSDateFormatterMediumStyle = kCFDateFormatterMediumStyle,
 NSDateFormatterLongStyle = kCFDateFormatterLongStyle,
 NSDateFormatterFullStyle = kCFDateFormatterFullStyle
 */
 
        [_bDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [_bDateFormatter setDateStyle:NSDateFormatterMediumStyle]; // Set date and time styles
        //[_bDateFormatter setDateStyle:NSDateFormatterShortStyle]; // Set date and time styles
        [_bDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        [_bDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
/*
        //NSDate *date = [NSDate date];
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle]; // Set date and time styles
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        //NSString *dateString = [dateFormatter stringFromDate:date];

        _bDateFormatter = [[NSDateFormatter alloc] init];
        [_bDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
        _bDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        _bDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
*/
        //NSDate *h2CurrentDateTime =  [[NSDate alloc] init];
        //NSString *currentDateTime = [NSString stringWithFormat:@"%@", h2CurrentDateTime];
        
        // Time 2
        NSDate *now = [[NSDate alloc] init];
        NSLog(@"%@", now);
        
 /*
        //NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:nil];
        
        int year = [components year];
        int month = [components month];
        int day = [components day];
        NSLog(@"the year %d, month %d, day %d", year, month, day);
*/
        
        //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] ;
        
        //NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:BIRTH_YEAR];
        [components setMonth:BIRTH_MONTH];
        [components setDay:BIRTH_DAY];
        NSDate *defualtDate = [calendar dateFromComponents:components];
        //pickerView.date = defualtDate;
        
        
        // Date Picker
        //_bDatePicker = [[UIDatePicker alloc] init];
        _bDatePicker = [self bDatePicker];
        _bDatePicker.frame = CGRectMake(BIRTHDAY_PICKER_H, BIRTHDAY_PICKER_V, BIRTHDAY_PICKER_H_SIZE, BIRTHDAY_PICKER_V_SIZE);
        //_bDatePicker.
        
        _bDatePicker.date = defualtDate;
//        _bDatePicker.datePickerMode = UIDatePickerModeDate;
//        _bDatePicker = [ self bDatePicker];
        //_bDatePicker.minuteInterval = ;
        [self.view addSubview:_bDatePicker];

        
        
        // Next Button
        btnNext = [[UIButton alloc] init];
        btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnNext.frame = CGRectMake(20, BIRTHDAY_NEXT_VERTICAL, 280, 40);
        [btnNext.titleLabel setFont:[UIFont systemFontOfSize:26]];
        
        [btnNext.layer setMasksToBounds:YES];
        [btnNext.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnNext.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
       [btnNext setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
        [btnNext addTarget:self action:@selector(birthdayNext:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnNext];
        
        
        
        ////////////////////////////////
        // Birthday Label
        birthdayLabel = [[UILabel alloc] init];
        
        birthdayYearLabel = [[UILabel alloc] init];
        birthdayMonthLabel = [[UILabel alloc] init];
        birthdayDayLabel = [[UILabel alloc] init];
        
        birthdayLabel.frame = CGRectMake(20 , BIRTHDAY_VERTICAL, 60, 40);
        
        /*
        birthdayYearLabel = CGRectMake(BIRTHDAY_HORIZOTAL+50, BIRTHDAY_VERTICAL, 40, 40);
        birthdayMonthLabel.frame = CGRectMake(BIRTHDAY_HORIZOTAL+80+50, BIRTHDAY_VERTICAL, 40, 40);
        birtdayDayLabel.frame = CGRectMake(BIRTHDAY_HORIZOTAL+160+50, BIRTHDAY_VERTICAL, 40, 40);
    */
        birthdayYearLabel.frame = CGRectMake(BIRTHDAY_HORIZOTAL+50, BIRTHDAY_VERTICAL, 20, 40);
        birthdayMonthLabel.frame = CGRectMake(BIRTHDAY_HORIZOTAL+80+50, BIRTHDAY_VERTICAL, 20, 40);
        birthdayDayLabel.frame = CGRectMake(BIRTHDAY_HORIZOTAL+(80*2)+50, BIRTHDAY_VERTICAL, 20, 40);
        
        birthdayLabel.text = @"生  日 : ";
        birthdayYearLabel.text = @"年";
        birthdayMonthLabel.text = @"月";
        birthdayDayLabel.text = @"日";
        
        [self.view addSubview:birthdayLabel];
        [self.view addSubview:birthdayYearLabel];
        [self.view addSubview:birthdayMonthLabel];
        [self.view addSubview:birthdayDayLabel];
        
        /////////////////////////////
        // Birthday Field
        //birtdayTextField = [[UITextField alloc] init];
        //birtdayTextField.frame = CGRectMake(20, 260, 280, 40);
        /*
        birthdayYearTextField = [[UITextField alloc] init];
        birthdayYearTextField.frame = CGRectMake(BIRTHDAY_HORIZOTAL, BIRTHDAY_VERTICAL, 40, 40);
        
        birthdayMonthTextField = [[UITextField alloc] init];
        birthdayMonthTextField.frame = CGRectMake(BIRTHDAY_HORIZOTAL+80, BIRTHDAY_VERTICAL, 40, 40);
        
        birthdayDayTextField = [[UITextField alloc] init];
        birthdayDayTextField.frame = CGRectMake(BIRTHDAY_HORIZOTAL+160, BIRTHDAY_VERTICAL, 40, 40);
      */
        
        birthdayYearTextField = [[UITextField alloc] init];
        birthdayYearTextField.frame = CGRectMake(BIRTHDAY_HORIZOTAL, BIRTHDAY_VERTICAL, 50, 40);
        
        birthdayMonthTextField = [[UITextField alloc] init];
        birthdayMonthTextField.frame = CGRectMake(BIRTHDAY_HORIZOTAL+80, BIRTHDAY_VERTICAL, 50, 40);
        
        birthdayDayTextField = [[UITextField alloc] init];
        birthdayDayTextField.frame = CGRectMake(BIRTHDAY_HORIZOTAL+160, BIRTHDAY_VERTICAL, 50, 40);
        
        
        
        birthdayYearTextField.contentMode = UIViewContentModeRight;
        birthdayDayTextField.contentMode = UIViewContentModeRight;
        birthdayDayTextField.contentMode = UIViewContentModeRight;
        
        
         birthdayYearTextField.text = [NSString stringWithFormat:@"%d", BIRTH_YEAR];
         birthdayMonthTextField.text = [NSString stringWithFormat:@"%d", BIRTH_MONTH];
         birthdayDayTextField.text = [NSString stringWithFormat:@"%d", BIRTH_DAY];
        
        
        
        
        //[self.view addSubview:birtdayTextField];
        [self.view addSubview:birthdayYearTextField];
        [self.view addSubview:birthdayMonthTextField];
        [self.view addSubview:birthdayDayTextField];
       
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        
        
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self.view addSubview:navBar];
    
    UIBarButtonItem *backButtor = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Skip"
                                   style:UIBarButtonItemStylePlain
                                   target:self action:@selector(skipSetting:)];
    UINavigationItem *navItem = [[UINavigationItem alloc]
                                 initWithTitle:@"PROFILE"];
    
    navItem.leftBarButtonItem = backButtor;
    [navBar pushNavigationItem:navItem animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////////
// TEST AREA !! UIDatePicker

//Input view doesn't work so. You may create lazy UIDatePicker:

- (UIDatePicker *)bDatePicker {
    if (!_bDatePicker) {
        _bDatePicker = [UIDatePicker new];
        _bDatePicker.datePickerMode = UIDatePickerModeDate;
        
        //_bDatePicker.maximumDate
        [_bDatePicker addTarget:self action:@selector(datePickerDidChangeDate:) forControlEvents:UIControlEventValueChanged];
    }
    return _bDatePicker;
}
// Then set it like following:

//self.birtdayTextField.inputView = self.bDatePicker;
//And this is the callback:

- (void)datePickerDidChangeDate:(UIDatePicker *)sender {
/*
    birtdayTextField.text = [_bDateFormatter stringFromDate:sender.date];
    NSLog(@"BIRTHDAY : %@,  == %@",  birtdayTextField.text, [_bDateFormatter stringFromDate:sender.date]);
    
    NSLog(@"YEAR : %@", [birtdayTextField.text substringWithRange:NSMakeRange(0, 4)]);
    NSLog(@"MONTH : %@", [birtdayTextField.text substringWithRange:NSMakeRange(5, 2)]);
    NSLog(@"DAY : %@", [birtdayTextField.text substringWithRange:NSMakeRange(8, 2)]);
    NSLog(@"OBCECT : %@",  sender);
*/
    NSString *birthday  = [_bDateFormatter stringFromDate:sender.date];
    NSString *strYear = [birthday substringWithRange:NSMakeRange(0, 4)];
    NSString *strMonth = [birthday substringWithRange:NSMakeRange(5, 2)];
    NSString *strDay = [birthday substringWithRange:NSMakeRange(8, 2)];
    
    UInt16 birthYear = [strYear intValue];
    UInt8 birthMonth = [strMonth intValue];
    UInt8 birthDay = [strDay intValue];
    
    
    
    //[TMSetUserProfile sharedInstance].userPfYear = (birthYear - 1900) & 0x00FF;
    [LibDelegateFunc sharedInstance].userProfile.uBirthYear = birthYear;
    [LibDelegateFunc sharedInstance].userProfile.uBirthMonth = birthMonth;
    [LibDelegateFunc sharedInstance].userProfile.uBirthDay = birthDay;
    
    
    birthdayYearTextField.text = [NSString stringWithFormat:@"%d", birthYear];
    birthdayMonthTextField.text = [NSString stringWithFormat:@"%d", birthMonth];
    birthdayDayTextField.text = [NSString stringWithFormat:@"%d", birthDay];
    
    NSLog(@" %04X 年 %02X 月 %02X 日", [LibDelegateFunc sharedInstance].userProfile.uBirthYear, [LibDelegateFunc sharedInstance].userProfile.uBirthMonth, [LibDelegateFunc sharedInstance].userProfile.uBirthDay);
    NSLog(@"THE YEAR =  %d 年", [LibDelegateFunc sharedInstance].userProfile.uBirthYear);
}
//Possible formatter:

- (NSDateFormatter *)bDateFormatter {
    if (!_bDateFormatter) {
        _bDateFormatter = [NSDateFormatter new];
        _bDateFormatter.dateFormat = @"dd.MM.yyyy";
    }
    return _bDateFormatter;
}
//To prevent pasting wrong data to that text field you may use it's delegate:

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //return textField != birtdayTextField;
    return YES;
}

///////////////////////////////////////////////////////////////////////
//
#pragma mark - UIPICKERVIEW AREA !!

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 1601;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    UInt16 bHight = 800 + row;
    //return [NSString stringWithFormat:@"Choice-%d",row];//Or, your suitable title; like Choice-a, etc.
    return [NSString stringWithFormat:@"%d.%d 公分",bHight/10, bHight%10];//Or, your suitable title; like Choice-a, etc.
}
//4)Next, you need to get the event when someone click on the title(As you want to navigate to other controller/screen):

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
//    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
    UInt16 bHeigth = 800 + row;
    NSLog(@"PICKER VIEW SELECT = %d And BH = %d.%d 公分", row, bHeigth/10, bHeigth%10);
    UInt16 enderSwap = CFSwapInt16(bHeigth);
    NSLog(@"THE BODY HEIGTH , RAW = %04X and SWAP = %04X", bHeigth, enderSwap);
    //Now, if you want to navigate then;
    // Say, OtherViewController is the controller, where you want to navigate:
//    OtherViewController *objOtherViewController = [OtherViewController new];
//    [self.navigationController pushViewController:objOtherViewController animated:YES];
    
    
    [LibDelegateFunc sharedInstance].userProfile.uBodyHeight = bHeigth;
/*
    memcpy(&[TMSetUserProfile sharedInstance].userProfileBuffer[4], &bHeigth, 2);
    
    NSData *tmp = [[NSData alloc] init];
    memcpy(<#void *__dst#>, <#const void *__src#>, <#size_t __n#>)
    
    [[H2Sync sharedInstance] H2OmronHbf254CSetUserProfile:[TMSetUserProfile sharedInstance].userProfileBuffer];
*/
}


- (IBAction)birthdayNext:(id)sender
{
     ///////////////////////
     // GO TO Omron User Profile - Body Height
     OMUserProfileBodyHeightViewController *userBodyHeightController =[[OMUserProfileBodyHeightViewController alloc] init];
     [self presentViewController:userBodyHeightController animated:YES completion:^{NSLog(@"USER PROFILE BODY HEIGHT - DONE");}];
}

- (IBAction)skipSetting:(id)sender
{
    
}

- (void)birthdayPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)userProfileSend:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)birthdayDone:(id)sender
{
    MeterTaskViewController *omronController =[[MeterTaskViewController alloc] init];
    [self presentViewController:omronController animated:YES completion:^{NSLog(@"OMRON VIEW DONE(BirthDay)");}];
}


@end

