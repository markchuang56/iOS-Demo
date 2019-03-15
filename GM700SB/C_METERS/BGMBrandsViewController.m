//
//  sySecondViewController.m
//  tabH2
//
//  Created by JasonChuang on 13/10/19.
//  Copyright (c) 2013年 JasonChuang. All rights reserved.
//


#import "BGMBrandsViewController.h"
#import "BGMModelsViewController.h"


@interface BGMBrandsViewController ()
{

    BGMModelsViewController *modelsController;
    NSMutableArray *models;
}

@end

@implementation BGMBrandsViewController


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
/*
        UINavigationBar *navBar = [[UINavigationBar alloc]
                                   initWithFrame:CGRectMake(0, 10, 320, 44)];
        [self.view addSubview:navBar];
        
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"BGM Brands"];
        
        //    navItem.leftBarButtonItem = backButton;
        [navBar pushNavigationItem:navItem animated:NO];
        
        UITableView * aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 460)];
        aTableView.dataSource = self; aTableView.delegate = self;
        
        [self.view addSubview:aTableView];
*/
        UINavigationBar *navBar = [[UINavigationBar alloc]
                                   initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBar];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Back"
                                       style:UIBarButtonItemStylePlain
                                       target:self action:@selector(brandsBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"BGM Brands"];
        
        navItem.leftBarButtonItem = backButton;
        [navBar pushNavigationItem:navItem animated:NO];
        UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460)];
        aTableView.dataSource = self; aTableView.delegate = self;
        [self.view addSubview:aTableView];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
/*
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:
                                CGRectMake(0, 0, 1, 1)];
    [self.view addSubview:volumeView];
    [self.view sendSubviewToBack:volumeView];
*/
    [H2BrandAndModel brandSharedInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
#if 1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}
#endif

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSUInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BRAND_CELL_ID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BRAND_CELL_ID"];
    }
    
    NSLog(@"row %lu cel %p", (unsigned long)row, cell);
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    switch (indexPath.section) {
        case 0:
            switch (row) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                    
                    
                case 9:
                case 0xA:
                case 0xB:
                case 0xC:
                case 0xD:
                case 0xE:
                case 0xF:
                case 0x10:
                    cell.textLabel.text = [[[H2BrandAndModel brandSharedInstance] h2BrandList] objectAtIndex:row];
                    NSLog(@"the brand is %@", [[[H2BrandAndModel brandSharedInstance] h2BrandList] objectAtIndex:row]);
                    break;

                default:
                    break;
            }
            
            break;
            
            
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

    
    switch (indexPath.section) {
        case 0:
            switch (row) { // mutableCopy
                case 0:
                    models = [[[H2BrandAndModel brandSharedInstance] h2DemoModel] mutableCopy];
                    break;
                case 1:
                    models = [[[H2BrandAndModel brandSharedInstance] h2AccuChekModel] mutableCopy];
                    break;
                case 2:
                    models = [[[H2BrandAndModel brandSharedInstance] h2BayerModel] mutableCopy];
                    break;
                case 3:
                    models = [[[H2BrandAndModel brandSharedInstance] h2CareSensModel] mutableCopy];
                    break;
                case 4:
                    models = [[[H2BrandAndModel brandSharedInstance] h2FreeStyleModel] mutableCopy];
                    break;
                case 5:
                    models = [[[H2BrandAndModel brandSharedInstance] h2GlucoCardModel] mutableCopy];
                    break;
                case 6:
                    models = [[[H2BrandAndModel brandSharedInstance] h2OneTouchModel] mutableCopy];
                    break;
                case 7:
                    models = [[[H2BrandAndModel brandSharedInstance] h2ReliOnModel] mutableCopy];
                    break;
                case 8:
                    models = [[[H2BrandAndModel brandSharedInstance] h2BeneChekModel] mutableCopy];
                    break;
                    
                    
                case 9:
                    models = [[[H2BrandAndModel brandSharedInstance] h2EXT_9_Model] mutableCopy];
                    break;
                case 0xA:
                    models = [[[H2BrandAndModel brandSharedInstance] h2EXT_A_Model] mutableCopy];
                    break;
                case 0xB:
                    models = [[[H2BrandAndModel brandSharedInstance] h2EXT_B_Model] mutableCopy];
                    break;
                case 0xC:
                    models = [[[H2BrandAndModel brandSharedInstance] h2EXT_C_Model] mutableCopy];
                    break;
                case 0xD:
                    models = [[[H2BrandAndModel brandSharedInstance] h2EXT_D_Model] mutableCopy];
                    break;
                case 0xE:
                    models = [[[H2BrandAndModel brandSharedInstance] h2EXT_E_Model] mutableCopy];
                    break;
                case 0xF:
                    models = [[[H2BrandAndModel brandSharedInstance] h2EXT_F_Model] mutableCopy];
                    break;
 

                default:
                    break;
            }
            
            break;
            
            
        default:
            break;
    }
    modelsController = [[BGMModelsViewController alloc] init:models withIdBrand:row * MAX_ROW_BRANDS];
    modelsController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:modelsController animated:YES completion:^{NSLog(@"done");}];

}

- (void) brandsBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MID_SN_NOTIFICATION" object:self];
        
    }];
}

@end
