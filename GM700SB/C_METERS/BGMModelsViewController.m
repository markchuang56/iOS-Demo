//
//  syMetersViewController.m
//  tabH2
//
//  Created by JasonChuang on 13/10/19.
//  Copyright (c) 2013年 JasonChuang. All rights reserved.
//

#import "BGMBrandsViewController.h"
#import "BGMModelsViewController.h"
#import "ModelLikeViewController.h"

#import "H2EquipID.h"


@interface BGMModelsViewController ()
{
    NSMutableArray *bgmModels;
    
    NSInteger brandNew;
    NSInteger brandOld;
    NSInteger meterNew;
    NSInteger meterOld;
    id viewInstance;
    
    BOOL moreModel;
    
    ModelLikeViewController *secondController;
    NSMutableArray *modelsExtend;
    
}

@end

@implementation BGMModelsViewController

- (id)init:(NSMutableArray *)models withIdBrand:(NSInteger)idBrand
{
    self = [super init];
    if (self) {
        // Custom initialization
        bgmModels = [[NSMutableArray alloc]init];
        [bgmModels addObjectsFromArray:models];
        brandNew = idBrand;
        NSLog(@"the insatance of meter view is %@", self);
        viewInstance = nil;
        moreModel = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
//    NSLog(@"meter view delegate 1 is %@", ((H2Sync *)[H2Sync sharedInstance]).libDelegate);
//    viewInstance = ((H2Sync *)[H2Sync sharedInstance]).libDelegate;

    UINavigationBar *navBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 0, 320, 54)];
    [self.view addSubview:navBar];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Back"
                                   style:UIBarButtonItemStylePlain
                                   target:self action:@selector(modelsBack:)];
    UINavigationItem *navItem = [[UINavigationItem alloc]
                                 initWithTitle:@"BGM Models"];
    
    navItem.leftBarButtonItem = backButton;
    [navBar pushNavigationItem:navItem animated:NO];
    UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460)];
    aTableView.dataSource = self; aTableView.delegate = self;
    [self.view addSubview:aTableView];
    
//    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//    [self.view addSubview:volumeView];
//    [self.view sendSubviewToBack:volumeView];
    
//    NSLog(@"meter view delegate is %@", ((H2Sync *)[H2Sync sharedInstance]).libDelegate);
    
    
    
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
    return [bgmModels count];
}

static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
#if 1
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             DisclosureButtonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: DisclosureButtonCellIdentifier];
    }

    NSUInteger row = [indexPath row];
    
    NSString *rowString =nil;
    
    NSLog(@"row %lu cel %p", (unsigned long)row, cell);
    
    rowString = [bgmModels objectAtIndex:row];
    
    
    cell.textLabel.text = rowString;
    meterOld = [[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
    NSLog(@"the old meter id is %02lX %02lX", (long)meterOld, (long)(meterOld & 0x0F));
    brandOld = meterOld & 0xF0;
    
//    meterOld &= 0x0F;
    meterOld &= 0x000F;
    if (row == meterOld && brandNew == brandOld) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

#endif
//    NSLog(@"the main object is @%@");
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

    meterNew = brandNew + row;
    NSLog(@"ULTRA XXX - SEL %02X and BRAND %02X ***", meterNew, brandNew);
    
    switch (meterNew) {
        case SM_ONETOUCH_ULTRA2:
            moreModel = YES;
            modelsExtend = [[[H2BrandAndModel brandSharedInstance] ultra2ExtendModel] mutableCopy];
            break;
            
        case SM_CARESENS_EXT_9_BIONIME:
            moreModel = YES;
            modelsExtend = [[[H2BrandAndModel brandSharedInstance] bionimeExtendModel] mutableCopy];
            break;
            
        case SM_APEX_BG001_C:
            moreModel = YES;
            modelsExtend = [[[H2BrandAndModel brandSharedInstance] apexBioExtendModel] mutableCopy];
            break;
            
        default:
            moreModel = NO;
            break;
    }
    
    
    if (moreModel) {
        secondController = [[ModelLikeViewController alloc] init:modelsExtend withIdBrand:meterNew];
        secondController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:secondController animated:YES completion:^{NSLog(@"MODEL LIKE PAGE DONE");}];
        //[self goToModelLidePage];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:meterNew forKey:@"UDEF_METER_ID"];
    
    NSString *rowString =nil;
    
    
    rowString = [bgmModels objectAtIndex:row];
    [[NSUserDefaults standardUserDefaults] setObject:rowString forKey:@"currentMeter"];
    
    NSLog([[NSUserDefaults standardUserDefaults] objectForKey:@"currentMeter"], nil);
    
    
    
    NSLog(@"the meter id is %02lX", (long)meterNew);
    [self modelsBack:nil];
}


    
    
    

- (void)modelsBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
