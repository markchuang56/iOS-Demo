//
//  syViewController.m
//  SNWTool
//
//  Created by h2Sync on 2014/4/25.
//  Copyright (c) 2014年 JasonChuang. All rights reserved.
//

#import "sn_qrcode.h"
#import "SNSeedViewController.h"

@interface SNSeedViewController ()
{

    UILabel *labelModel;
    UILabel *labelCustomer;
    UILabel *labelSeedInit;
    
    UITextField *textMode;
    UITextField *textCustomer;
    UITextField *textSeedValue;
}
@end

@implementation SNSeedViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [H2SerialNumber sharedInstance].qrCycle = 50;
        // Custom initialization
        UIButton *btnClear = [[UIButton alloc] init];
        btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //btnClear.frame = CGRectMake(20, 320, 280, 40);
        btnClear.frame = CGRectMake(20, 60, 280, 40);
        
        [btnClear.titleLabel setFont:[UIFont systemFontOfSize:26]];
        
        [btnClear.layer setMasksToBounds:YES];
        [btnClear.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [btnClear.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        [btnClear setTitle:@"DONE" forState:UIControlStateNormal];
        
        [btnClear setBackgroundImage:[UIImage imageNamed:@"blue2.png"]
                            forState:UIControlStateNormal];
        
        [btnClear addTarget:self action:@selector(snSeedDone:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:btnClear];
        

        self.view.backgroundColor = [UIColor yellowColor];
        
        
        
        [H2SerialNumber sharedInstance];
        [H2SerialNumber sharedInstance].serialNumberDelegate = (id<H2SerialNumberDelegate >)self;
        NSMutableArray *lableString = [[NSMutableArray alloc] init];
        
        [lableString addObject:@"MODEL"];
        [lableString addObject:@"CUSTOMER"];
        [lableString addObject:@"SEED"];
        
        NSMutableArray *labels = [[NSMutableArray alloc] init];
        labelModel = [[UILabel alloc] init];
        labelCustomer = [[UILabel alloc] init];
        labelSeedInit = [[UILabel alloc] init];
        [labels addObject:labelModel];
        [labels addObject:labelCustomer];
        [labels addObject:labelSeedInit];

        int lableIndex = 0;
        for (UILabel *label in labels) {
            label.frame = CGRectMake(20, 100 + lableIndex * 50, 110, 40);
            
            [label setFont:[UIFont fontWithName:@"System" size:20]];
         
            [label setBackgroundColor:[UIColor whiteColor]];
            [label setTextColor:[UIColor redColor]];
            
            [label.layer setMasksToBounds:YES];
            [label.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [label.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            
            label.text = (NSString *)lableString[lableIndex];
            
//            [lable setTitle:@"Seed Setting..." forState:UIControlStateNormal];
            
//            [lable setBackgroundImage:[UIImage imageNamed:@"gray_button.png"]
//                                      forState:UIControlStateNormal];
            
            [self.view addSubview:label];
            lableIndex++;
        }

        // TEXTFIELD ...
        NSMutableArray *textString = [[NSMutableArray alloc] init];
        
        [textString addObject:@"XX"];
        [textString addObject:@"XX"];
        [textString addObject:@"000217"];
        NSMutableArray *seeds = [[NSMutableArray alloc] init];
        textMode = [[UITextField alloc] init];
        textCustomer = [[UITextField alloc] init];
        textSeedValue = [[UITextField alloc] init];
        [seeds addObject:textMode];
        [seeds addObject:textCustomer];
        [seeds addObject:textSeedValue];
        lableIndex = 0;
        for (UITextField *snText in seeds) {
            snText.frame = CGRectMake(160, 100 + lableIndex * 50, 140, 40);
            
            [snText setFont:[UIFont fontWithName:@"System" size:20]];
            
            [snText setBackgroundColor:[UIColor whiteColor]];
            [snText setTextColor:[UIColor blackColor]];
            
            [snText.layer setMasksToBounds:YES];
            [snText.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [snText.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            
            snText.text = (NSString *)textString[lableIndex];
            
            //            [lable setTitle:@"Seed Setting..." forState:UIControlStateNormal];
            
            //            [lable setBackgroundImage:[UIImage imageNamed:@"gray_button.png"]
            //                                      forState:UIControlStateNormal];
            snText.delegate = self;
            [self.view addSubview:snText];
            lableIndex++;
        }
    }
/*
    _model.text = [NSString stringWithFormat:@"XX"];
    _model.delegate = self;
    
    _customer.text = [NSString stringWithFormat:@"XX"];
    _customer.delegate = self;
    
    
    _seed.text = [NSString stringWithFormat:@"000000"];
    _seed.delegate = self;
*/
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self.view addSubview:navBar];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Skip"
                                   style:UIBarButtonItemStylePlain
                                   target:self action:@selector(skipSetting:)];
    UINavigationItem *navItem = [[UINavigationItem alloc]
                                 initWithTitle:@"Serial number seed"];
    
    navItem.leftBarButtonItem = backButton;
    [navBar pushNavigationItem:navItem animated:NO];
    //    UITableView * aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460)];
    //    aTableView.dataSource = self; aTableView.delegate = self;
    //    [self.view addSubview:aTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)snSeedDone:(id)sender {
    
    [textMode resignFirstResponder];
    [textCustomer resignFirstResponder];
    [textSeedValue resignFirstResponder];
    
    NSDate *now = [[NSDate alloc] init];
    NSLog(@"%@", now);
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
    
    int year = (int)[components year];
    int month = (int)[components month];
    int day = (int)[components day];
    NSLog(@"the year %d, month %d, day %d", year, month, day);
    
    [textMode resignFirstResponder];
    [textCustomer resignFirstResponder];
    [textSeedValue resignFirstResponder];
    
    NSLog(@"the value is %06d", [textSeedValue.text intValue]);
    NSLog(textMode.text, nil);
    NSLog(@"the string is %c", [textMode.text characterAtIndex:0]);
    NSLog(@"the string is %c", [textMode.text characterAtIndex:1]);
    
    NSLog(@"the string is %c", [textCustomer.text characterAtIndex:0]);
    
    [H2SerialNumber sharedInstance].snModel = [textMode.text characterAtIndex:0];
    [H2SerialNumber sharedInstance].snType = [textMode.text characterAtIndex:1];
    
    [H2SerialNumber sharedInstance].snYear = year - 2000;
    [H2SerialNumber sharedInstance].snMonth = month;
    
    [H2SerialNumber sharedInstance].snCustomer = [textCustomer.text characterAtIndex:0];
    [H2SerialNumber sharedInstance].snCustomerEx = [textCustomer.text characterAtIndex:1];
    
    [H2SerialNumber sharedInstance].snNumber = [textSeedValue.text intValue];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SerialNumberSeed" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QR_BUILD_NOTIFY" object:self];
    }];
}

- (unsigned char)lotToUp:(unsigned char)src
{
    unsigned char dst = src;
    if (src >= 'a') {
        dst  -= 0x20;
    }
    return dst;
}

- (void) skipSetting:(id)sender
{
    [textMode resignFirstResponder];
    [textCustomer resignFirstResponder];

    [textSeedValue resignFirstResponder];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


