//
//  ArkrayDialogViewController.m
//  Omron
//
//  Created by h2Sync on 2017/3/30.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2Sync.h"
#import "ArkrayDialogViewController.h"

@interface ArkrayDialogViewController ()
{
    UIButton *btnPasswordInput;
    UIButton *btnNumber0;
    UIButton *btnNumberBack;
    
    UIButton *btnNumber1;
    UIButton *btnNumber2;
    UIButton *btnNumber3;
    UIButton *btnNumber4;
    UIButton *btnNumber5;
    UIButton *btnNumber6;
    UIButton *btnNumber7;
    UIButton *btnNumber8;
    UIButton *btnNumber9;
    
    UILabel *passwordLabel;
    Byte *password;
}

@end

@implementation ArkrayDialogViewController


#if 0
- (id)init
{
    //UInt16 vendorMeterId = 0;
    //UInt16 spacing = 70;
    //self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self = [super init];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(dialogPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"ARKRAY PASSWORD"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return  self;
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (id)init
{
    self = [super init];
    if (self) {
        password = (Byte *)malloc(6);
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(dialogPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"ARKRAY PASSWORD"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        
        self.view.backgroundColor = [UIColor whiteColor];
    
        
        // LABEL FOR SHOW PASSWORD
        passwordLabel = [[UILabel alloc] init];
        
        passwordLabel.frame = CGRectMake(20 , AK_PW_VERTICAL, 280, 60);
        passwordLabel.contentMode = UIViewContentModeCenter;
        
        passwordLabel.textAlignment = NSTextAlignmentCenter;
        passwordLabel.layer.borderWidth = 5.0;
        passwordLabel.layer.borderColor = UIColor.blueColor.CGColor;//UIColor.blue.cgColor; blueColor
        
        [passwordLabel setFont:[UIFont systemFontOfSize:26]];
        
        
        passwordLabel.text = @"";
        [self.view addSubview:passwordLabel];
        //[passwordLabel setHidden:YES];
        
        // BUTTON FOR INPUT OR GET PASSWORD
        btnPasswordInput = [[UIButton alloc] init];
        btnPasswordInput = [UIButton buttonWithType:UIButtonTypeCustom];
        btnPasswordInput.frame = CGRectMake(20, AK_PW_VERTICAL+65, 280, 40);
        
        [btnPasswordInput.titleLabel setFont:[UIFont systemFontOfSize:26]];
        [btnPasswordInput setTitle:@"PASSWORD INPUT" forState:UIControlStateNormal];
        [btnPasswordInput setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        
        [btnPasswordInput.layer setMasksToBounds:YES];
        [btnPasswordInput.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnPasswordInput.layer setBorderWidth:1.0]; //边框宽度
        [btnPasswordInput addTarget:self action:@selector(btPasswordDone:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnPasswordInput];
        //[btnPasswordInput setHidden:YES];
        // BUTTON BACK FOR KEYBOARD
        
        // 0
        btnNumber0 = [[UIButton alloc] init];
        btnNumber0 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumber0.frame = CGRectMake(20, AK_KEYBOARD_VERTICAL + 180, 100, 50);
        
        [btnNumber0.titleLabel setFont:[UIFont systemFontOfSize:26]];
        [btnNumber0 setTitle:@"0" forState:UIControlStateNormal];
        [btnNumber0 setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        
        [btnNumber0.layer setMasksToBounds:YES];
        [btnNumber0.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnNumber0.layer setBorderWidth:1.0]; //边框宽度
        [btnNumber0 addTarget:self action:@selector(setNumber0:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnNumber0];
        
        
        // BACK
        btnNumberBack = [[UIButton alloc] init];
        btnNumberBack = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumberBack.frame = CGRectMake(140, AK_KEYBOARD_VERTICAL + 180, 140, 50);
        
        [btnNumberBack.titleLabel setFont:[UIFont systemFontOfSize:26]];
        [btnNumberBack setTitle:@"NUMBER BACK" forState:UIControlStateNormal];
        [btnNumberBack setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
        
        [btnNumberBack.layer setMasksToBounds:YES];
        [btnNumberBack.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnNumberBack.layer setBorderWidth:1.0]; //边框宽度
        [btnNumberBack addTarget:self action:@selector(setNumberBack:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnNumberBack];
        //[btnNumberBack setHidden:YES];
        
        
        
        
        
        // BUTTON FOR KEYBOARD
        btnNumber1 = [[UIButton alloc] init];
        btnNumber2 = [[UIButton alloc] init];
        btnNumber3 = [[UIButton alloc] init];
        
        btnNumber4 = [[UIButton alloc] init];
        btnNumber5 = [[UIButton alloc] init];
        btnNumber6 = [[UIButton alloc] init];
        
        btnNumber7 = [[UIButton alloc] init];
        btnNumber8 = [[UIButton alloc] init];
        btnNumber9 = [[UIButton alloc] init];
        
        
        
        
        
        btnNumber1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumber2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumber3 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnNumber4 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumber5 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumber6 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnNumber7 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumber8 = [UIButton buttonWithType:UIButtonTypeCustom];
        btnNumber9 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btnNumber1 showsTouchWhenHighlighted];
        [btnNumber2 showsTouchWhenHighlighted];
        [btnNumber3 showsTouchWhenHighlighted];
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        [bottunArray addObject:btnNumber1];
        [bottunArray addObject:btnNumber2];
        [bottunArray addObject:btnNumber3];
        
        [bottunArray addObject:btnNumber4];
        [bottunArray addObject:btnNumber5];
        [bottunArray addObject:btnNumber6];
        
        [bottunArray addObject:btnNumber7];
        [bottunArray addObject:btnNumber8];
        [bottunArray addObject:btnNumber9];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"1"];
        [btnString addObject:@"2"];
        [btnString addObject:@"3"];
        
        [btnString addObject:@"4"];
        [btnString addObject:@"5"];
        [btnString addObject:@"6"];
        
        [btnString addObject:@"7"];
        [btnString addObject:@"8"];
        [btnString addObject:@"9"];
        
        
        
        
        UInt16   spacingH = 0;
        UInt16   spacingV = 0;
        
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnBleMethod in bottunArray) {
            
            switch (btnIndex%3) {
                case 0:
                    spacingH = 0;
                    break;
                    
                case 1:
                    spacingH = 100;
                    break;
                    
                case 2:
                default:
                    spacingH = 200;
                    break;
            }
            
            switch (btnIndex/3) {
                case 0:
                    spacingV = 0;
                    break;
                    
                case 1:
                    spacingV = 60;
                    break;
                    
                case 2:
                default:
                    spacingV = 120;
                    break;
            }
            
            btnBleMethod.frame = CGRectMake(20 + spacingH, AK_KEYBOARD_VERTICAL + spacingV, 90, 50);
            
            [btnBleMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnBleMethod.layer setMasksToBounds:YES];
            [btnBleMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnBleMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnBleMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            [btnBleMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnBleMethod addTarget:self action:@selector(setNumber1:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnBleMethod addTarget:self action:@selector(setNumber2:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnBleMethod addTarget:self action:@selector(setNumber3:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 3:
                    [btnBleMethod addTarget:self action:@selector(setNumber4:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 4:
                    [btnBleMethod addTarget:self action:@selector(setNumber5:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 5:
                    [btnBleMethod addTarget:self action:@selector(setNumber6:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 6:
                    [btnBleMethod addTarget:self action:@selector(setNumber7:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 7:
                    [btnBleMethod addTarget:self action:@selector(setNumber8:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 8:
                    [btnBleMethod addTarget:self action:@selector(setNumber9:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
            [self.view addSubview:btnBleMethod];
            //[btnBleMethod setHidden:YES];
            btnIndex++;
        }
        NSLog(@"ARKRAY DIALOG'");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arkrayStatusTask:) name:@"BLE_CABLE_STATUS" object:nil];
        
    }
    return  self;
}

#pragma mark - GET RECORDS
- (IBAction)ArkrayGetRecords:(id)sender
{
    
}

#pragma mark - PASSWORD DONE
- (IBAction)btPasswordDone:(id)sender
{
    NSString *stringToNumber;
    NSLog(@"PASSWORD IS %@", passwordLabel.text);
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        NSLog(@"PASSWORD TO SHORT");
    }else{
        for (int i=0; i<[passwordLabel.text length]; i++) {
            stringToNumber = [passwordLabel.text substringWithRange:NSMakeRange(i, 1)];
            // int x = [TramNumber.text intValue];
            NSLog(@"PW INDEX %d, %@, %02X",i, stringToNumber,  [stringToNumber intValue]);
            password[i] = [stringToNumber intValue];
        }
        //[btnPasswordInput setHidden:YES];
        //
        [[H2Sync sharedInstance] appArkrayRegister:password];
        [self dialogPageBack:nil];
    }
}

#pragma mark - SET NUMBER
- (IBAction)setNumber1:(id)sender
{
    NSLog(@"SET NUMBER 1 =  %@", passwordLabel.text);
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"1"];
    }
    NSLog(@"SET NUMBER 1 =  %@", passwordLabel.text);
}
- (IBAction)setNumber2:(id)sender
{
    NSLog(@"SET NUMBER 2");
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"2"];
    }
    NSLog(@"SET NUMBER 2 =  %@", passwordLabel.text);
}
- (IBAction)setNumber3:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"3"];
    }
    NSLog(@"SET NUMBER 3 =  %@", passwordLabel.text);
}

- (IBAction)setNumber4:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"4"];
    }
}

- (IBAction)setNumber5:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"5"];
    }
}

- (IBAction)setNumber6:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"6"];
    }
}

- (IBAction)setNumber7:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"7"];
    }
}

- (IBAction)setNumber8:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"8"];
    }
}

- (IBAction)setNumber9:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"9"];
    }
}

- (IBAction)setNumber0:(id)sender
{
    if ([passwordLabel.text length] < ARKRAY_PASSWORD_LENGTH) {
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@"0"];
    }
}

- (IBAction)setNumberBack:(id)sender
{
    if ([passwordLabel.text length] > 0) {
        passwordLabel.text = [passwordLabel.text substringWithRange:NSMakeRange(0, [passwordLabel.text length] - 1)];
    }else{
        passwordLabel.text = [passwordLabel.text stringByAppendingString:@""];
    }
}



- (void)arkrayStatusTask:(NSNotification *)notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"BLE_CABLE_STATUS"]) {
        NSLog(@"ARKRAY BLE GOT SYNC STATUS ...");
        
        [self dismissViewControllerAnimated:YES completion:nil];
        //labelCableStatus.text = [labelCableStatus.text stringByAppendingString:@" "];
        //labelCableStatus.text = [labelCableStatus.text stringByAppendingString:[LibDelegateFunc sharedInstance].syncStatusString];
    }
}





- (void)dialogPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
