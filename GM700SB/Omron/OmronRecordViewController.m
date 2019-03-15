//
//  BGMRecordViewController.m
//  SQX
//
//  Created by h2Sync on 2016/1/26.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

//#import "BGMItemCell.h"

#import "OmronRecordViewController.h"
#import "h2MeterRecordInfo.h"
#import "H2Sync.h"
#import "LibDelegateFunc.h"
#import "TMShowUserId.h"
#import "H2AudioHelper.h"

static NSString *DisclosureButtonCellIdentifier = @"DisclosureButtonCellIdentifier";

@interface OmronRecordViewController ()
{
    UInt16 omronSections;
    UInt8 omronRows;
}

@end

@implementation OmronRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 int main(int argc, const char * argv[]) {
 @autoreleasepool {
 NSURL *url = [NSURL URLWithString:@"http://benluwebapi.azurewebsites.net/api/values"];
 NSURLRequest *request = [NSURLRequest requestWithURL:url];
 NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
 
 //取得Json資訊
 NSArray* jsonobj = [NSJSONSerialization JSONObjectWithData:data
 options:NSJSONReadingMutableContainers
 error:nil];
 //迭代的列出所有Json資料中的Key與Value
 [jsonobj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
 NSDictionary* array1 = [jsonobj objectAtIndex:idx];
 
 [array1 enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop){
 NSLog(@"key= %@ , Value = %@ ",key,obj);
 }];
 }];
 }
 return 0;
 }
 
*/

- (id)init
{
    NSString *showTitle;
 
    // enumerateKeysAndObjectsUsingBlock：^(id key,id obj,BOOL *stop) 與
 
// enumerateObjectsUsingBlock: ^(id key,id obj,BOOL *stop)
 
    // enumerateKeysAndObjectsUsingBlock
    
    if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BP){
        omronSections = [[LibDelegateFunc sharedInstance].bpRecordsResult count];
        NSLog(@"BP SECTIONS %d", omronSections);
        showTitle = @"BP RECORDS";
    }else if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BW){
        omronSections = [[LibDelegateFunc sharedInstance].bwRecordsResult count];
        NSLog(@"BW SECTIONS %d", omronSections);
        showTitle = @"BW RECORDS";
    }else{
        showTitle = @" RECORDS TYPE ???";
    }
    
    self = [super init];
    if (self) {
        
        UINavigationBar *navDevBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navDevBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"BACK"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(recordBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:showTitle];
        
        navItem.leftBarButtonItem = btnBack;
        [navDevBar pushNavigationItem:navItem animated:NO];
        
        //UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460)];
        
        UITableView *aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 54, 320, 460) style:UITableViewStyleGrouped];
        
        aTableView.dataSource = self; aTableView.delegate = self;
        
        //self = [super initWithStyle:UITableViewStyleGrouped];
        //[aTableView initWithStyle:UITableViewStyleGrouped]
        
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
    NSLog(@"SHOW SECTIONS %d", omronSections);
    return omronSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BP){
        omronRows = ROW_OMRON_BP;
        
    }else if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BW){
        omronRows = ROW_OMRON_BW;
    }else{
        NSLog(@"RETURN - BG BP BW - OTHERS");
    }
    NSLog(@"RETURN - ROW %d", omronRows);
    return omronRows;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 0
    static NSString *CellIdentifier = @"BGMCell";
    BGMItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMCell"];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BGMItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    GlucoseReading* reading = [readings objectAtIndex:indexPath.row];
    NSUInteger row = [indexPath row];
    h2MeterRecordInfo *record = (h2MeterRecordInfo *)[bgmRecords objectAtIndex:row];
//    cell.timestamp.text = [dateFormat stringFromDate:reading.timestamp];
    cell.timestamp.text = record.smRecordDateTime;
    
    if ([record.smRecordUnit isEqualToString:@"N"]) {
        cell.value.text = [cell.value.text stringByAppendingFormat:@"%03d %03d %@\n", record.smRecordIndex, record.smRecordValue_mg, record.smRecordUnit ];
    }else if ([record.smRecordUnit isEqualToString:@"mg/dL"]){
        cell.value.text = [cell.value.text stringByAppendingFormat:@"%03d %03d %@\n", record.smRecordIndex, record.smRecordValue_mg, record.smRecordUnit ];
    }else{ // equal to mmol/L
        cell.value.text = [cell.value.text stringByAppendingFormat:@"%03d %02.2f %@\n", record.smRecordIndex, record.smRecordValue_mmol, record.smRecordUnit ];
    }
/*
    if (reading.glucoseConcentrationTypeAndLocationPresent)
    {
        cell.value.text = [NSString stringWithFormat:@"%.1f", reading.glucoseConcentration];
        cell.type.text = [reading typeAsString];
    }
    else
    {
        cell.value.text = @"-";
        cell.type.text = @"Unavailable";
    }
*/
    return cell;
}
#endif



    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             DisclosureButtonCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier: DisclosureButtonCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    NSLog(@"row %lu cel %p", (unsigned long)row, cell);


    //omronRows = ROW_OMRON_BP;
    



    //cell.textLabel.text = [NSString stringWithFormat:@"ROW %d", (UInt8)row];
#if 1
    if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BP){
        NSLog(@"SHOW - BP,  ROW - %d", (UInt8)row);
        cell.textLabel.text = [self omronBpRowProcess:row withCurrentSection:section];
        
    }else if ([LibDelegateFunc sharedInstance].h2OmronDataType & RECORD_TYPE_BW){
        
         NSLog(@"SHOW - BW,  ROW - %d", (UInt8)row);
        cell.textLabel.text = [self omronBwRowProcess:row withCurrentSection:section];
    }

    NSLog(@"THE RECORD IS %@", cell.textLabel.text,nil);
#endif

   return cell;
}

#pragma mark - SECTION AREA
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

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [NSString stringWithFormat:@"select this section %ld row %ld", (long)indexPath.section, (long)indexPath.row];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(title,nil);
    
//    NSUInteger row = indexPath.row;
    
    
    
    
}


- (void) recordBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)omronBpRowProcess:(NSUInteger)row withCurrentSection:(NSUInteger)section
{
//j    OmronRecordInfo *bp = (OmronRecordInfo *)[[LibDelegateFunc sharedInstance].bpRecordsResult objectAtIndex:omronSections - section - 1];
    NSString *rowString = [[NSString alloc] init];
#if 0
    switch (row) {
        case 0:
            rowString = [rowString stringByAppendingFormat:@"%03d, %@", bp.recordIndex, bp.recordDateTime];
            break;
            
        case 1:
            switch (bp.belongToUser) {
                case USER_TAG1_MASK:
                    rowString = [rowString stringByAppendingFormat:@" USER_%d", 1];
                    break;
                    
                case USER_TAG2_MASK:
                    rowString = [rowString stringByAppendingFormat:@" USER_%d", 2];
                    break;
                    
                default:
                    rowString = [rowString stringByAppendingFormat:@" USER_%d", 0];
                    break;
            }
            break;
            
        case 2:
            //rowString = [rowString stringByAppendingFormat:@"%d, - Systolic_mmHg", bp.bpSystolic_mmHg, bp.bpDiastolic_mmHg];
            rowString = [rowString stringByAppendingFormat:@"SYS/DIA : %@/%@ mmHg", bp.systolic_mmHg, bp.diastolic_mmHg];
            break;
            
        case 3:
            //rowString = [rowString stringByAppendingFormat:@"%d, - Diastolic_mmHg", bp.bpDiastolic_mmHg];
            rowString = [rowString stringByAppendingFormat:@"HEART  RATE : %@  次/min", bp.heartRate_pulmin];
            break;
            
          case 4:
        default:
            rowString = [rowString stringByAppendingFormat:@"=============================="];
            break;
    }
#endif
    return rowString;
}

- (NSString *)omronBwRowProcess:(NSUInteger)row withCurrentSection:(NSUInteger)section
{

//j    OmronRecordInfo *bw = (OmronRecordInfo *)[[LibDelegateFunc sharedInstance].bwRecordsResult objectAtIndex:omronSections - section - 1];
    
    NSString *rowString = [[NSString alloc] init];
#if 0
    NSLog(@"BW -- %d IDX", bw.recordIndex);
    NSLog(@"BW -- %@ DATE-TIME", bw.recordDateTime);
    
    //rowString = [NSString stringWithFormat:@"%@", bw.recordDateTime];
   // NSLog(@"BW TOTAL %@", );

    switch (row) {
        case 0:
            rowString = [rowString stringByAppendingFormat:@"%03d, %@", bw.recordIndex, bw.recordDateTime];
            break;
            
        case 1:
            rowString = [rowString stringByAppendingFormat:@"Body Weight : %@ Kg", bw.bWeight];
            break;
            
        case 2:
            rowString = [rowString stringByAppendingFormat:@"Body FAT : %@ %c", bw.bFat, 0x25];
            break;
            
        case 3:
            rowString = [rowString stringByAppendingFormat:@"Muscle : %@ %c", bw.skeletalMuscle, 0x25];
            break;
            
        case 4:
            rowString = [rowString stringByAppendingFormat:@"熱量 %@ KCal", bw.restingMetabolism];
            break;
        case 5:
            switch (bw.belongToUser) {
                case USER_TAG1_MASK:
                    rowString = [rowString stringByAppendingFormat:@"LEVEL : %@ \t\t\t\t USER_%d", bw.bLevel, 1];
                    break;
                    
                case USER_TAG2_MASK:
                    rowString = [rowString stringByAppendingFormat:@"LEVEL : %@ \t\t\t\t USER_%d", bw.bLevel, 2];
                    break;
                    
                case USER_TAG3_MASK:
                    rowString = [rowString stringByAppendingFormat:@"LEVEL : %@ \t\t\t\t USER_%d", bw.bLevel, 3];
                    break;
                    
                case USER_TAG4_MASK:
                    rowString = [rowString stringByAppendingFormat:@"LEVEL : %@ \t\t\t\t USER_%d", bw.bLevel, 4];
                    break;
                default:
                    rowString = [rowString stringByAppendingFormat:@"LEVEL : %@ \t\t\t\t USER_%d", bw.bLevel, 0];
                    break;
            }
            
            break;
        case 6:
            rowString = [rowString stringByAppendingFormat:@"Body Age : %@ 歲", bw.bAge];
            break;
        case 7:
            rowString = [rowString stringByAppendingFormat:@"BMI : %@ %c", bw.bBmi, 0x25];
            break;
        case 8:
            rowString = [rowString stringByAppendingFormat:@"============================"];
            break;
            
        default:
            break;
    }
#endif
    return rowString;
}

+ (OmronRecordViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    NSLog(@"OMRON - RECORD the instance value @%@", _sharedObject);
    return _sharedObject;
}
@end




