//
//  LastDateTimeViewController.m
//  FR_W310B
//
//  Created by h2Sync on 2017/10/25.
//  Copyright © 2017年 h2Sync. All rights reserved.
//


#import "BGMItemCell.h"

//#import "EquipRecordsViewController.h"
#import "h2MeterRecordInfo.h"
#import "H2Records.h"
#import "H2Sync.h"
#import "LibDelegateFunc.h"

#import "LastDateTimeViewController.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface LastDateTimeViewController ()
{
    BOOL showNew;
}

@end

@implementation LastDateTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init:(BOOL)isNewLdt;
{
    NSString *showTitle = @"";
    showNew = isNewLdt;
    if (isNewLdt) {
        showTitle  = @"NEW LDT";
    }else{
        showTitle  = @"TOTAL LDT";
    }
    
    
    self = [super init];
    if (self) {
        UINavigationBar *navDevBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navDevBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(recordBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:showTitle];
        
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
    if (showNew) {
        // Show NEW LDT
        NSLog(@"NEW LDT SECTION - %d", (int)[[LibDelegateFunc sharedInstance].ldtNewResult count]);
        return [[LibDelegateFunc sharedInstance].ldtNewResult count];
    }else{
        // Show TOTAL LDT
        NSLog(@"TOTAL LDT SECTION - %d", (int)[[LibDelegateFunc sharedInstance].serverLastDateTimes count]);
        return [[LibDelegateFunc sharedInstance].serverLastDateTimes count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return (LDT_ROW_NUMBER);
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             DisclosureButtonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: DisclosureButtonCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    
    NSString *rowString =[[NSString alloc] init];
    
    NSLog(@"row %lu cel %p", (unsigned long)row, cell);
    
    NSUInteger section = [indexPath section];
    
    NSMutableArray *ltdTypeString = [[NSMutableArray alloc] init];
    [ltdTypeString addObject:@"LDT"];
    [ltdTypeString addObject:@"MODEL"];
    [ltdTypeString addObject:@"SN"];
/*
    [ltdTypeString addObject:@"BG SKIP"];
    [ltdTypeString addObject:@"BP SKIP"];
    [ltdTypeString addObject:@"BW SKIP"];
  */
    
    [ltdTypeString addObject:@"LDT INDEX"];
    [ltdTypeString addObject:@"D-TYPE"];
    [ltdTypeString addObject:@"USER TAG"];
    
    NSMutableArray *ltdKeyString = [[NSMutableArray alloc] init];
    [ltdKeyString addObject:@"LDT_DateTime"];
    [ltdKeyString addObject:@"LDT_Model"];
    [ltdKeyString addObject:@"LDT_SerialNumber"];
/*
    [ltdKeyString addObject:@"LDT_NrSkipBgRecords"];
    [ltdKeyString addObject:@"LDT_NrSkipBpRecords"];
    [ltdKeyString addObject:@"LDT_NrSkipBwRecords"];
*/
    
    [ltdKeyString addObject:@"LDT_NrIndexOfRecord"];
    [ltdKeyString addObject:@"LDT_NrRecordType"];
    [ltdKeyString addObject:@"LDT_NrUserTag"];

    NSDictionary *ldtElement = nil;
    if (showNew) {
        ldtElement = (NSDictionary *)[[LibDelegateFunc sharedInstance].ldtNewResult objectAtIndex:section];
    }else{
        ldtElement = (NSDictionary *)[[LibDelegateFunc sharedInstance].serverLastDateTimes objectAtIndex:section];
    }
    
    
    rowString = [NSString stringWithFormat:@"%@ : ", [ltdTypeString objectAtIndex:row]];
    if (row >= 3) {
        NSNumber *tmpNumber = [ldtElement objectForKey: [ltdKeyString objectAtIndex:row]];
        NSString *tmpString = [NSString stringWithFormat:@"%d", [tmpNumber intValue]];
        rowString = [rowString stringByAppendingFormat:@"%@", tmpString];
    }else{
        rowString = [rowString stringByAppendingFormat:@"%@", [ldtElement objectForKey: [ltdKeyString objectAtIndex:row]]];
    }
    

    cell.textLabel.text = rowString;
    
    return cell;
}

#pragma mark - Table view delegate - BG

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"select this section %ld row %ld", (long)indexPath.section, (long)indexPath.row];
    NSLog(title,nil);
}


- (void) recordBack:(id)sender
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
#pragma mark - SECTION AREA - BG
//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;//section头部高度
}
//section头部视图
/*
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
 view.backgroundColor = [UIColor clearColor];
 return [view autorelease];
 }
 */
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
//section底部视图
/*
 - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
 {
 UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
 view.backgroundColor = [UIColor clearColor];
 return [view autorelease];
 }
 */
// yourTableView.separatorStyle = UITableViewCellSeparatorStyleNone
// UITableViewStyleGrouped
#pragma mark - Table view delegate - BG
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{ // For Section ...
    
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 5.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 10, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        //set the border color
        layer.strokeColor = [UIColor lightGrayColor].CGColor;
        //set the border width
        layer.lineWidth = 1;
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:1.0f].CGColor;
        
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
    }
}

+ (LastDateTimeViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

@end
