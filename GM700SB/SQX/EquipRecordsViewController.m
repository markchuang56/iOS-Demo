//
//  EquipRecordsViewController.m
//  SQX
//
//  Created by h2Sync on 2016/1/26.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "BGMItemCell.h"

#import "EquipRecordsViewController.h"
#import "h2MeterRecordInfo.h"
#import "H2Records.h"
#import "H2Sync.h"
#import "LibDelegateFunc.h"


static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface BGMRecordsViewController ()
{

}

@end

@implementation BGMRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init//:(NSMutableArray *)records //withIdBrand:(NSInteger)idBrand
{
    NSString *showTitle  = @"BG_ RECORDS";
        //[LibDelegateFunc sharedInstance].h2RecordsDataType
    
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
    NSLog(@"RETURN - BG,  SECTION - %d", (int)[[LibDelegateFunc sharedInstance].bgRecordsResult count]);
    return [[LibDelegateFunc sharedInstance].bgRecordsResult count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return (BG_ROW_NUMBER);
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
    H2BgRecord *bgResult = (H2BgRecord *)[[LibDelegateFunc sharedInstance].bgRecordsResult objectAtIndex:section];
    
    
    switch (row) {
        case 0:
            rowString = [rowString stringByAppendingFormat:@"%03d %@", bgResult.bgIndex, bgResult.bgDateTime];
            break;
            
        case 1:
            rowString = [rowString stringByAppendingFormat:@"USER ID : %02X", bgResult.meterUserId];//meterUserId
            break;
            
        case 2:
            
            rowString = [rowString stringByAppendingFormat:@"BG : %@ %@", bgResult.bgValue, bgResult.bgUnit];
    /*
            if ([bgResult.bgUnit isEqualToString:@"N"]) {
                rowString = [rowString stringByAppendingFormat:@"BG : %03d %@", bgResult.bgValue_mg, bgResult.bgUnit];
                
            }else if ([bgResult.bgUnit isEqualToString:@"mg/dL"]){
                rowString = [rowString stringByAppendingFormat:@"BG : %03d %@", bgResult.bgValue_mg, bgResult.bgUnit];
                
            }else{ // equal to mmol/L
                rowString = [rowString stringByAppendingFormat:@"BG : %02.2f %@", bgResult.bgValue_mmol, bgResult.bgUnit];
            }
            */
            break;
            
        case 3:
            rowString = [rowString stringByAppendingFormat:@"MEAL : %@", bgResult.bgMealFlag];
            break;
            
        default:
            break;
    }
    
    
    NSLog(@"SHOW - BG");
    

    NSLog(@"THE RECORD IS %@", rowString,nil);
    
    
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

+ (BGMRecordsViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"EM - BG - RECORD the instance value @%@", _sharedObject);
    return _sharedObject;
}
@end


@implementation BPMRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init//:(NSMutableArray *)records //withIdBrand:(NSInteger)idBrand
{
    NSString *showTitle = @"BP RECORDS";
    
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
    return [[LibDelegateFunc sharedInstance].bpRecordsResult count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"RETURN - BP,  ROW - %d", [[LibDelegateFunc sharedInstance].bpRecordsResult count] * BP_ROW_NUMBER);
    return (BP_ROW_NUMBER);
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
    H2BpRecord *bp = (H2BpRecord *)[[LibDelegateFunc sharedInstance].bpRecordsResult objectAtIndex:section];
    
    NSLog(@"BP -- %d IDX", bp.bpIndex);
    NSLog(@"BP -- %@ DATE-TIME", bp.bpDateTime);
/*
    H2BpRecord *bp = (H2BpRecord *)[[LibDelegateFunc sharedInstance].bpRecordsResult objectAtIndex:row/BP_ROW_NUMBER];
    row %= BP_ROW_NUMBER;
    NSLog(@"SHOW - BP,  ROW - %d", row);
*/
    switch (row) {
        case 0:
            rowString = [rowString stringByAppendingFormat:@"%03d, %@", bp.bpIndex, bp.bpDateTime];
            break;
            
        case 1:
            rowString = [rowString stringByAppendingFormat:@"USER ID : %02d", bp.meterUserId];
            break;
            
        case 2:
            rowString = [rowString stringByAppendingFormat:@"SYS : %@ %@", bp.bpSystolic, bp.bpUnit];
            break;
            
        case 3:
            rowString = [rowString stringByAppendingFormat:@"DIA : %@ %@", bp.bpDiastolic, bp.bpUnit];
            break;
            
        case 4:
            rowString = [rowString stringByAppendingFormat:@"HR : %@ times/min", bp.bpHeartRate_pulmin];
            break;
            
        case 5:
            rowString = [rowString stringByAppendingFormat:@"Arrhythmia : %@", bp.bpIsArrhythmia ? @"YES" : @"NO"];
            break;
            
        case 6:
            rowString = [rowString stringByAppendingFormat:@"MAM Arrhythmia : %@", bp.mamArrhythmia ? @"YES" : @"NO"];
            break;
            
            
        default:
            break;
    }

    NSLog(@"THE RECORD IS %@", rowString,nil);
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
#pragma mark - SECTION AREA - BP
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
#pragma mark - Table view delegate - BP
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

+ (BPMRecordsViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"EM - BG - RECORD the instance value @%@", _sharedObject);
    return _sharedObject;
}
@end




@implementation BWMRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init//:(NSMutableArray *)records //withIdBrand:(NSInteger)idBrand
{
    NSString *showTitle = @"BW RECORDS";
    
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




#pragma mark - Table view data source - BW

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
    return [[LibDelegateFunc sharedInstance].bwRecordsResult count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSLog(@"RETURN - BW,  ROW - %d", [[LibDelegateFunc sharedInstance].bwRecordsResult count] * BW_ROW_NUMBER);
    return (BW_ROW_NUMBER);
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

    

//    H2BwRecord *bw = (H2BwRecord *)[[LibDelegateFunc sharedInstance].bwRecordsResult objectAtIndex:row/BW_ROW_NUMBER];
//    row %= BW_ROW_NUMBER;
 /*
    NSLog(@"SHOW - BW,  ROW - %d", row);
    
    NSLog(@"BW -- %d IDX", bw.bwIndex);
    NSLog(@"BW -- %@ DATE-TIME", bw.bwDateTime);
*/
    NSUInteger section = [indexPath section];
    H2BwRecord *bw = (H2BwRecord *)[[LibDelegateFunc sharedInstance].bwRecordsResult objectAtIndex:section];
    
    NSLog(@"BW -- %d IDX", bw.bwIndex);
    NSLog(@"BW -- %@ DATE-TIME", bw.bwDateTime);
    
/*
    NSString *genderString;
    if (bw.bwGender > 0) {
        genderString = @"Male";
    }else{
        genderString = @"Female";
    }
    
    NSString *unitString;
    //            record.bwUnit = wUnit; // Kg=0, lb=1, st=2
    if (bw.bwUnit > 0) {
        unitString = @"LB";
    }else{
        unitString = @"KG";
    }
*/
    
    
    switch (row) {
        case 0:
            rowString = [rowString stringByAppendingFormat:@"%03d, %@", bw.bwIndex, bw.bwDateTime];
            break;
            
        case 1:
            rowString = [rowString stringByAppendingFormat:@"USER ID : %02X, GENDER : %@", bw.meterUserId, bw.bwGender];
            break;
            
        case 2:
            //rowString = [rowString stringByAppendingFormat:@"身高 : %.2f CM,  %.2f INCH", bw.bwHeightInCm, bw.bwHeightInInch];
            rowString = [rowString stringByAppendingFormat:@"身高 : %@ CM,  %@ INCH", bw.bwHeightCm, bw.bwHeightInch];
            break;
            
        case 3:
            //rowString = [rowString stringByAppendingFormat:@"%f KG, %f LB", bw.bwKg, bw.bwLb];
            rowString = [rowString stringByAppendingFormat:@"WEIGHT : %@ %@", bw.bwWeight, bw.bwUnit];
            
            break;
            
        case 4:
            rowString = [rowString stringByAppendingFormat:@"BMI : %@ ", bw.bwBmi];
            break;
            
        case 5:
            rowString = [rowString stringByAppendingFormat:@"UNIT : %@, Age : %d", bw.bwUnit, bw.bwAge];
            break;
            
        case 6:
            rowString = [rowString stringByAppendingFormat:@"BFT : %@", bw.bwFat];
            break;
            
        case 7:
            rowString = [rowString stringByAppendingFormat:@"MUS : %@", bw.bwSkeletalMuscle];
            break;
            
        default:
            break;
    }

    NSLog(@"THE RECORD IS %@", rowString,nil);


    cell.textLabel.text = rowString;

    return cell;
}

#pragma mark - Table view delegate BW

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"select this section %ld row %ld", (long)indexPath.section, (long)indexPath.row];
    //    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - SECTION AREA - BW
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
#pragma mark - Table view delegate
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

+ (BWMRecordsViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"EM - BG - RECORD the instance value @%@", _sharedObject);
    return _sharedObject;
}
@end




