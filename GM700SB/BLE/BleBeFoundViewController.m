//
//  bleDEVViewController.m
//  SQX
//
//  Created by h2Sync on 2016/1/26.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "BleBgmPaired.h"
#import "ScannedPeripheral.h"
#import "BleBeFoundViewController.h"
#import "SQXViewController.h"

#import "LibDelegateFunc.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface BleBeFoundViewController ()
{
    NSMutableArray *peripherals;
}

@end

@implementation BleBeFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init:(NSMutableArray *)bleDevices
{
    self = [super init];
    if (self) {
        
        [BleBgmPaired sharedInstance];
        // Custom initialization
        
        peripherals = [[NSMutableArray alloc]init];
        [peripherals addObjectsFromArray:bleDevices];

        
        UINavigationBar *navDevBar = [[UINavigationBar alloc]
                                   initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navDevBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Back"
                                       style:UIBarButtonItemStylePlain
                                       target:self action:@selector(devBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"BLE Device List"];
        
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
    return [peripherals count] * 4;
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
    
    ScannedPeripheral *sensor = (ScannedPeripheral *)[peripherals objectAtIndex:row/4];
    
    switch (row%4) {
        case 0:
            rowString = @"NAME : ";
            rowStringTail = sensor.name;
            break;
            
        case 1:
            rowString = @"SN : ";
            rowStringTail = sensor.bleScanSerialNumber;
            break;
            
        case 2:
            rowString = @"ID : ";
            rowStringTail = sensor.bleScanIdentifier;
            break;
            
        case 3:
            rowString = @"MODEL : ";
            rowStringTail = sensor.bleScanModel;
            break;
            
        default:
            rowStringTail = sensor.name;
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
    NSLog(title,nil);
    NSString *snTmp = [[NSString alloc] init];
    NSUInteger row = indexPath.row;
    
    NSLog(@"BLE Select Device ...");
    row /= 4;
    if (row < [peripherals count]) {
        [BleBgmPaired sharedInstance].testNumber++;
        NSLog(@"TEST VALUE IS %d", [BleBgmPaired sharedInstance].testNumber);
        ScannedPeripheral *sensor = (ScannedPeripheral *)[peripherals objectAtIndex:row];
        NSLog(@"START SCAN HERE ...");
        NSLog(@"SYNC ADDR : %@", sensor.bleScanIdentifier);
        NSLog(@"SYNC SN : %@", sensor.bleScanSerialNumber);
        NSLog(@"SYNC MODEL : %@", sensor.bleScanModel);
        
        // For Sync after BLE Pairing
        [LibDelegateFunc sharedInstance].qrStringCode = sensor.bleScanSerialNumber;
        snTmp = [NSString stringWithFormat:@"%@", sensor.bleScanSerialNumber];
        
        UInt32  mId = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
        if (mId & 0x8000) {
            [[NSUserDefaults standardUserDefaults] setObject:snTmp forKey:@"UDEF_METER_SN"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:snTmp forKey:@"UDEF_QR_CODE"];
        }
        
        // NEW BLE INFO
        NSDictionary *bleInfoNew =
        @{
          @"BLE_IDENTIFIER":sensor.bleScanIdentifier,
          @"BLE_SERIALNUMBER":sensor.bleScanSerialNumber
          };
            // ADD info to SERVER
        UInt8 bleIndex = 0;
        BOOL bleNew = YES;
        NSArray *peripheralsFixed = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_BLE_IDENTIFIER_SN"];
        
        NSMutableArray *peripheralsInfo = [[NSMutableArray alloc] init];
        if ([peripheralsFixed count] > 0) {
            for (NSDictionary *bleInfo in peripheralsFixed){
                [peripheralsInfo addObject:bleInfo];
            }
        }
        
        if ([peripheralsInfo count] > 0) {
            NSLog(@"TOTAL : %@", peripheralsInfo);
            for (NSDictionary *bleInfo in peripheralsInfo){
                NSLog(@"BLE_ID CHK : %d ==> %@", bleIndex, bleInfo);
                NSLog(@"NEW SN : %@", sensor.bleScanSerialNumber);
                NSLog(@"SVR SN : %@", [bleInfo objectForKey: @"BLE_SERIALNUMBER"]);
                
                if ([sensor.bleScanSerialNumber isEqualToString:[bleInfo objectForKey: @"BLE_SERIALNUMBER"]]) {
                    NSLog(@"OLD");
                    [peripheralsInfo replaceObjectAtIndex:bleIndex withObject:bleInfoNew];
                    bleNew = NO;
                    break;
                }
                
                bleIndex++;
            }
        }else{
            
        }
        
        if (bleNew) {
            NSLog(@"NEW");
            [peripheralsInfo addObject:bleInfoNew];
        }
        
        NSLog(@"BLE_ID CHK : %d ==> %@ AFTER ", bleIndex, peripheralsInfo);
            [[NSUserDefaults standardUserDefaults] setObject:peripheralsInfo forKey:@"UDEF_BLE_IDENTIFIER_SN"];


        if ([peripheralsInfo count] > 0) {
            [peripheralsInfo removeAllObjects];
        }
        bleIndex = 0;
        NSArray *tmpArrary = [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_BLE_IDENTIFIER_SN"];
        for (NSDictionary *bleInfo in tmpArrary){
            NSLog(@"BLE_ID CHK : %d ==> %@ AFTER FROM USER_DEFAULT", bleIndex, bleInfo);
        }
        
        
        // DO Sync ...
        //[[MeterTaskViewController sharedInstance] syncFromDeviceHaveFound:nil];
    }
    [self devBack:nil];
}


- (void) devBack:(id)sender
{
    NSLog(@"BACK FORM SHOW BLE **** ");
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

+ (BleBeFoundViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"EM - BLE FOUND the instance value @%@", _sharedObject);
    return _sharedObject;
}

@end
