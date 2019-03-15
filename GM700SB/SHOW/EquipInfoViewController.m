//
//  EquipInfoViewController.m
//  SQX
//
//  Created by h2Sync on 2016/2/17.
//  Copyright © 2016年 h2Sync. All rights reserved.
//
#define BGM_INFO_ROW_NUMBER             7


#import "EquipInfoViewController.h"
#import "EquipRecordsViewController.h"

#import "LastDateTimeViewController.h"

#import "LibDelegateFunc.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";




@interface EquipInfoViewController ()
{
    NSMutableArray *bgmInfo;
}


@end



@implementation EquipInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init:(NSMutableArray *)info
{
    self = [super init];
    if (self) {
        // Custom initialization
        //        self.tableView = [self makeTableView];
        //        [self.view registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newFriendCell"];
        //        [self.view addSubview:self.tableView];
        
        bgmInfo = [[NSMutableArray alloc]init];
        [bgmInfo addObjectsFromArray:info];
        
        
        UINavigationBar *navDevBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navDevBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(bgmInfoBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"BGM INFO"];
        
        navItem.leftBarButtonItem = btnBack;
        [navDevBar pushNavigationItem:navItem animated:NO];
        
        UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460)];
        aTableView.dataSource = self; aTableView.delegate = self;
        [self.view addSubview:aTableView];
        
    }
    return self;
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    //        self.tableView = [self makeTableView];
    //        [self.view registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newFriendCell"];
    //        [self.view addSubview:self.tableView];
    tableView.contentSize = CGSizeMake(320, 960);
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BGMItemCell"];
    tableView.clipsToBounds = NO;
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
//    return [bgmInfo count];
    return BGM_INFO_ROW_NUMBER;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DisclosureButtonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier: DisclosureButtonCellIdentifier];
    }

    NSUInteger row = [indexPath row];

//    NSString *rowString =[[NSString alloc] init];

    NSLog(@"row %lu cel %p", (unsigned long)row, cell);

    switch (row) {
        case 0:
            cell.textLabel.text =[NSString stringWithFormat:@"BRAND : %@", [LibDelegateFunc sharedInstance].bgmInfo.smBrandName];
            break;
        case 1:
            cell.textLabel.text =[NSString stringWithFormat:@"MODEL : %@", [LibDelegateFunc sharedInstance].bgmInfo.smModelName];
            break;
        case 2:
            cell.textLabel.text =[NSString stringWithFormat:@"SN : %@", [LibDelegateFunc sharedInstance].bgmInfo.smSerialNumber];
            break;
        case 3:
            cell.textLabel.text =[NSString stringWithFormat:@"DT : %@", [LibDelegateFunc sharedInstance].bgmInfo.smCurrentDateTime];
            break;
        case 4:
            cell.textLabel.text =[NSString stringWithFormat:@"UNIT : %@", [LibDelegateFunc sharedInstance].bgmInfo.smCurrentUnit];
            break;
            
        default:
            cell.textLabel.text =[NSString stringWithFormat:@"NOTHING"];
            break;
    }


    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"select this section %ld row %ld", (long)indexPath.section, (long)indexPath.row];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(title,nil);
    
    //    NSUInteger row = indexPath.row;
    
}


- (void) bgmInfoBack:(id)sender
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

+ (EquipInfoViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"EM - BG INFO the instance value @%@", _sharedObject);
    return _sharedObject;
}


@end










