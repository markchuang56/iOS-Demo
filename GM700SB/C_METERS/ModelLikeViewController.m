//
//  syMetersViewController.m
//  tabH2
//
//  Created by JasonChuang on 13/10/19.
//  Copyright (c) 2013年 JasonChuang. All rights reserved.
//

#import "ModelLikeViewController.h"

#import <MediaPlayer/MPVolumeView.h>


@interface ModelLikeViewController ()
{
    NSMutableArray *bgmSecond;
    
    NSInteger modelNew;
    NSInteger modelOld;
    
    NSInteger meterNew;
    NSInteger meterOld;
    id viewInstance;
    
}

@end

@implementation ModelLikeViewController

- (id)init:(NSMutableArray *)models withIdBrand:(NSInteger)idBrand
{
    self = [super init];
    if (self) {
        // Custom initialization
        bgmSecond = [[NSMutableArray alloc]init];
        [bgmSecond addObjectsFromArray:models];
        modelNew = idBrand;
        NSLog(@"the insatance of meter view is %@", self);
        viewInstance = nil;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self.view addSubview:navBar];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self action:@selector(modelsBack:)];
    UINavigationItem *navItem = [[UINavigationItem alloc]
                                 initWithTitle:@"MODEL LIKE(PROTOCOL)"];
    
    navItem.leftBarButtonItem = backButton;
    [navBar pushNavigationItem:navItem animated:NO];
    UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460)];
    aTableView.dataSource = self; aTableView.delegate = self;
    [self.view addSubview:aTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [bgmSecond count];
}

static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             DisclosureButtonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: DisclosureButtonCellIdentifier];
    }

    NSUInteger row = [indexPath row];
    
    NSString *rowString =nil;
    
    NSLog(@"row %lu cel %p", (unsigned long)row, cell);
    
    rowString = [bgmSecond objectAtIndex:row];
    
    
    cell.textLabel.text = rowString;
    meterOld = [[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
    NSLog(@"the old meter id is %02lX %02lX", (long)meterOld, (long)(meterOld & 0x0F));
    modelOld = meterOld & 0xF0;
    
    meterOld &= 0x000F;
    if (row == meterOld && modelNew == modelOld) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    
    NSUInteger row = indexPath.row;

    // addExtend ID Number
    meterNew = modelNew + (row<<8);
    [[NSUserDefaults standardUserDefaults] setInteger:meterNew forKey:@"UDEF_METER_ID"];
    
    NSString *rowString =nil;
    
    
    rowString = [bgmSecond objectAtIndex:row];
    [[NSUserDefaults standardUserDefaults] setObject:rowString forKey:@"currentMeter"];
    
    NSLog([[NSUserDefaults standardUserDefaults] objectForKey:@"currentMeter"], nil);
    
    NSLog(@"THE EXTEND METER ID IS  %02lX", (long)meterNew);
    [self modelsBack:nil];
}


- (void)modelsBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}










@end
