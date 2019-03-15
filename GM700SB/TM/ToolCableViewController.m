//
//  bleDEVViewController.m
//  SQX
//
//  Created by h2Sync on 2016/1/26.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

//#import "BleBgmPaired.h"
//#import "ScannedPeripheral.h"
//#import "BLEViewController.h"
#import "LibDelegateFunc.h"
#import "ToolCableViewController.h"
//#import "BleBGMViewController.h"
//#import "SQXViewController.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface ToolCableTableViewController ()
{
    NSMutableArray *peripherals;
}

@end

@implementation ToolCableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init:(NSMutableArray *)toolCables
{
    self = [super init];
    if (self) {
        
        // Custom initialization
        
//        peripherals = [[NSMutableArray alloc]init];
//        [peripherals addObjectsFromArray:bleDevices];

        
        UINavigationBar *navDevBar = [[UINavigationBar alloc]
                                   initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navDevBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Back"
                                       style:UIBarButtonItemStylePlain
                                       target:self action:@selector(toolCableBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"TOOL CABLE List"];
        
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
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSLog(@"THE TOOL NUMBER IS %d",[[LibDelegateFunc sharedInstance].tmswToolCableListing count] );
    
    return [[LibDelegateFunc sharedInstance].tmswToolCableListing count] * 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DisclosureButtonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: DisclosureButtonCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    
    NSString *rowString = [[NSString alloc] init];
    rowString = @"";
    
    NSString *rowStringTail =nil;
    
    NSLog(@"row %lu cel %p", (unsigned long)row, cell);
    
    
    NSDictionary *toolCable = (NSDictionary *)[[LibDelegateFunc sharedInstance].tmswToolCableListing objectAtIndex:row/2];
    
    switch (row%2) {
        case 0:
            rowString = @"SN : ";
            rowStringTail = [toolCable objectForKey: @"TOOL_SerialNumber"];
            break;
            
        case 1:
            rowString = @"ID : ";
            rowStringTail = [toolCable objectForKey: @"TOOL_Identifier"];
            break;
            
        
            
        default:
            rowStringTail = @"na";
            break;
    }
    
    rowString = [rowString stringByAppendingString:rowStringTail];
    
    cell.textLabel.text = rowString;
    
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"select this section %ld row %ld", (long)indexPath.section, (long)indexPath.row];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(title,nil);

/*
    NSUInteger row = indexPath.row;
    BOOL oldDev = NO;
    
    NSLog(@"BLE Select Device ...");
    row /= 2;
    if (row < [[LibDelegateFunc sharedInstance].tmswToolCableListing count]) {
        
        [BleBgmPaired sharedInstance].testNumber++;
        NSLog(@"TEST VALUE IS %d", [BleBgmPaired sharedInstance].testNumber);
        ScannedPeripheral *sensor = (ScannedPeripheral *)[peripherals objectAtIndex:row];
        NSLog(@"START SCAN HERE ...");
        NSLog(@"SYNC ADDR %@", sensor.bleScanIdentifier);
        NSLog(@"SYNC SN %@", sensor.bleScanSerialNumber);
        NSLog(@"SYNC MODEL %@", sensor.bleScanModel);
//        [sensor. isEqualToString
//
        
        for (ScannedPeripheral *paired in [BleBgmPaired sharedInstance].peripheralsHasPaired) {
            if ([sensor.bleScanSerialNumber isEqualToString:paired.bleScanSerialNumber]) {
                oldDev = YES;
                NSLog(@"SN DEBUG 1");
                break;
            }
            NSLog(@"SN DEBUG 2");
        }
        if (!oldDev) {
            [[BleBgmPaired sharedInstance].peripheralsHasPaired addObject:sensor];
            NSLog(@"SN DEBUG 3");
        }
        
        NSLog(@"SN DEBUG %d ,%@", [[BleBgmPaired sharedInstance].peripheralsHasPaired count], [BleBgmPaired sharedInstance].peripheralsHasPaired);
        
        if (![BLEViewController sharedInstance].scanAndPair) {
//j            [[SQXViewController sharedInstance] libSqxBleSelectedAndSyncOrConnect:(id)(sensor.peripheral) connectToDev:YES];
            
            SQXViewController *sqxController =[[SQXViewController alloc] init];
            [self presentViewController:sqxController animated:YES completion:^{NSLog(@"MULTI BLE done");}];
            return;
        }
    }
*/
 
    [self toolCableBack:nil];
}


- (void) toolCableBack:(id)sender
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

+ (ToolCableTableViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"the instance value @%@", _sharedObject);
    return _sharedObject;
}

@end
