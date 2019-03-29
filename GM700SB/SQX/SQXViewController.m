//
//  ViewController.m
//  SQX
//
//  Created by h2Sync on 2016/1/21.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "BGMBrandsViewController.h"
#import "SNWriteViewController.h"
#import "QRCodeViewController.h"
#import "BleBeFoundViewController.h"
#import "SQXViewController.h"

#import "LibDelegateFunc.h"
#import "STBViewController.h"

#import "OAuth2ViewController.h"


#import "TMShowUserId.h"
#import "OmronShowUserId.h"

#import "OMUserPfGender.h"
#import "OMUserPfBirthday.h"
#import "OMUserPfBodyHeight.h"

#import <MediaPlayer/MPVolumeView.h>

#import "MeterTaskViewController.h"
#import "OmronRecordViewController.h"

#import "UserProfileFromApp.h"
#import "uIDCheckBoxViewController.h"

#import "BleEquipViewController.h"

#import "PagesViewController.h"
#import "DACollection.h"

#import "MySecurities.h"
#import "ALCommonHMAC.h"

@interface SQXViewController ()
{
    BGMBrandsViewController *modelsController;
}


@end

@implementation SQXViewController
static NSMutableArray *_gPeripherals;
static NSMutableArray *_tmpRecords;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navSqxBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navSqxBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(sqxPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"WAITING ..."];
        
        navItem.leftBarButtonItem = btnBack;
        [navSqxBar pushNavigationItem:navItem animated:NO];
        
        self.view.backgroundColor = [UIColor whiteColor];
        self.view.alpha = 0.5f;
        
        _gPeripherals = [[NSMutableArray alloc] init];
        _tmpRecords = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [LibDelegateFunc sharedInstance];
    [H2Sync sharedInstance];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(midQrNotification:) name:@"MID_SN_NOTIFICATION" object:nil];
    
    
    [self showIdAndSerialNumber];
    NSLog(@"DID SQX VIEW LOAD ...");
    
    NSString *dateTimeString = [NSString stringWithFormat:@"1975-12-31 23:59:00 +0000"];
    
    NSString *yearString = [dateTimeString substringWithRange:NSMakeRange(0,4)];
    NSString *monthString = [dateTimeString substringWithRange:NSMakeRange(5,2)];
    NSString *dayString = [dateTimeString substringWithRange:NSMakeRange(8,2)];
    
    NSString *hourString = [dateTimeString substringWithRange:NSMakeRange(11,2)];
    NSString *minString = [dateTimeString substringWithRange:NSMakeRange(14,2)];
    
    unsigned long yearValue = [yearString intValue];
    unsigned long monthValue = [monthString intValue];
    unsigned long dayValue = [dayString intValue];
    
    unsigned long hourValue = [hourString intValue];
    unsigned long minValue = [minString intValue];
    
    NSLog(@"STRING TO NUMBER TEST TOTAL - %lu", yearValue * 100000000+ monthValue * 1000000+ dayValue * 10000+ hourValue * 100 + minValue);
//    NSLog(@"STRING TO NUMBER TEST TOTAL - %08X", yearValue * 000000000+ monthValue * 1000000+ dayValue * 10000+ hourValue * 100 + minValue);
    
    NSLog(@"STRING TO NUMBER TEST TOTAL - %lu", yearValue * 1000000+ monthValue * 31 * 24 * 60 + dayValue * 24 * 60 + hourValue * 60 + minValue);
    NSLog(@"STRING TO NUMBER TEST YEAR - %lu", yearValue * 1000000);
    NSLog(@"STRING TO NUMBER TEST MONTH - %lu", monthValue);
    NSLog(@"STRING TO NUMBER TEST DAY - %lu", dayValue);
    
    NSLog(@"STRING TO NUMBER TEST MIN - %lu", hourValue);
    NSLog(@"STRING TO NUMBER TEST SEC - %lu", minValue);
    
    
    //int myValue = 100;
    NSNumber *eNumber = [NSNumber numberWithInt:100];
    //NSInteger myValue = 1;
    //NSNumber *number = [NSNumber numberWithInteger: myValue];
    
    NSLog(@"NS-NUMBER TEST = %02X", [eNumber intValue]);
    // 跑馬燈
#if 1
    // Continuous Type
    self.demoLabelX.tag = 101;
    self.demoLabelX.marqueeType = MLContinuous;
    self.demoLabelX.scrollDuration = 15.0;
    self.demoLabelX.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    self.demoLabelX.fadeLength = 10.0f;
    self.demoLabelX.leadingBuffer = 30.0f;
    self.demoLabelX.trailingBuffer = 20.0f;
    // Text string for this label is set via Interface Builder!
//#else
    
     // Reverse Continuous Type, with attributed string
     self.demoLabelX.tag = 201;
     //self.demoLabelX.marqueeType = MLContinuousReverse;
    self.demoLabelX.marqueeType = MLContinuous;
     self.demoLabelX.scrollDuration = 8.0;
     self.demoLabelX.fadeLength = 15.0f;
     self.demoLabelX.leadingBuffer = 40.0f;
    [self arkrayDecode];
    
    [self calcDymicaCmd];
#endif
 
#if 0
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"This is a long string, that's also an attributed string, which works just as well!"];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f] range:NSMakeRange(0, 21)];
    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(10,11)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.234 green:0.234 blue:0.234 alpha:1.000] range:NSMakeRange(0,attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] range:NSMakeRange(21, attributedString.length - 21)];
    self.demoLabelX.attributedText = attributedString;
#else
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Auto Mode!! Auto Mode!!Auto Mode!! Auto Mode!!Auto Mode!! Auto Mode!!Auto Mode!! Auto Mode!!"];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f] range:NSMakeRange(0, 10)];
    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(11,10)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.234 green:0.234 blue:0.234 alpha:1.000] range:NSMakeRange(0,attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] range:NSMakeRange(11, attributedString.length - 11)];
    self.demoLabelX.attributedText = attributedString;
#endif
    NSLog(@"%@ =====  跑  馬  燈 ====== %@ and %@", self.demoLabelX, self.demoLabelX.attributedText, attributedString);
    /*
    NSString *signatureBaseString = @"POST&https%3A%2F%2Fconnectapi.garmin.com%2Foauth-service%2Foauth%2Frequest_token&oauth_consumer_key%3D2446e117-da8b-40ac-a5ea-803e1ac53c82%26oauth_nonce%3D8793316948%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1537505474%26oauth_version%3D1.0";
    NSString *consumerSecretKey = @"YcyQKZ7b7vlnHkwzJTa3kTEACX6pFHTyJhk&";
     
     // mmbx3odJuYZvrKO5FdhrIDBeTRM=
    */
    
    NSString *signatureBaseString = @"POST&https%3A%2F%2Fconnectapi.garmin.com%2Foauth-service%2Foauth%2Faccess_token&oauth_consumer_key%3D2446e117-da8b-40ac-a5ea-803e1ac53c82%26oauth_nonce%3D1999391741%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1537506329%26oauth_token%3D6dc822a5-46e3-4d66-8934-864600aa5327%26oauth_verifier%3DZhtRrimtp5%26oauth_version%3D1.0";
    
    NSString *consumerSecretKey = @"YcyQKZ7b7vlnHkwzJTa3kTEACX6pFHTyJhk&5OFX46OttskOWErFHhu3Q5isOrm6g4SJklG";
    
  /*
    
    NSString *signatureBaseString = @"POST&https%3A%2F%2Fconnectapi.garmin.com%2Foauth-service%2Foauth%2Frequest_token&oauth_consumer_key%3Dcb60d7f5-4173-7bcd-ae02-e5a52a6940ac%26oauth_nonce%3Dkbki9sCGRwU%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1484837456%26oauth_version%3D1.0";
    
    NSString *consumerSecretKey = @"3LFNjTLbGk5QqWVoypl8S2wAYcSL586E285&";
    */
    
    NSString *tokenKey = [ALCommonHMAC hmacSHA1:signatureBaseString withKey:consumerSecretKey];
    NSLog(@"SHA1 &&&&= %@ =&&&&", tokenKey);
    
    //%2BHlCpVX8Qgdw5Djfw0W30s7pfrY %3D
    // zSAEERG2NNoQaVjVthJ5xP4XcCM
    //+ (NSString *)hmacSHA1:(NSString *)data withKey:(NSString *)key;
    
    for (int k=0; k<10; k++) {
        int num = arc4random();//%1000000000;
        int numMode = (num & 0x7FFFFFFF)%1000000000;
        NSLog(@"==== RRR ==== H2 == RANDOM %010d, %09d, %04X", num, numMode, num);
        NSString *nrString = [NSString stringWithFormat:@"%09d", numMode];
        
        NSLog(@"=== RANDOM == %@, %d", nrString, nrString.length);
    }
    
    Byte *tBuffer;
    tBuffer = [[DACollection sharedInstance] systemCurrentTime];
    for (int i=0; i<7; i++) {
        NSLog(@"T%d, TIME = %02X", i, tBuffer[i]);
    }
    
    //BOOL aflag = YES;
    //UInt8 aValue = 0;
    //aValue = aflag ? 3 : 2;
    //NSLog(@"THE VLUE is %d", aValue);
// 6e 44df22
    // 1e 42df22
    UInt32 flexTimeInSecond = 0x22df41c4;//3bd6;
    
    NSString *ohDateTimeString = @"";
    ohDateTimeString = [[DACollection sharedInstance] dateTimeParser:flexTimeInSecond];
    NSLog(@"OH FLEX TIME PARSER = %@", ohDateTimeString);
    unsigned char flexCmdInit[] =
    {
        //0x01,
        /*
        0x02, 0x0A, 0x00,
        0x04, 0x09, 0x02, 0x02,
        0x03, 0xC6, 0x0F
        0x01,
        */
        /*
        0x02, 0x0A, 0x00,
        0x04, 0xE6, 0x02, 0x08,
        0x03, 0x09, 0xB0
        */
    /*
        0x02,
        0x02, 0x18, 0x00,  0x04, 0x11, 0xEE, 0x9A,
        0x58, 0x08, 0x88, 0x13,  0x3A, 0xD9, 0x38, 0x89,
        0xEF, 0x2A, 0xE6, 0x66,
        
        0x41, 0xD2, 0x48, 0x03,  0xBA, 0xF5
       */
        /*
        //0x03,
        0x02, 0x2a, 0x00 , 0x04, 0x06, 0x43, 0x00 ,
        0x45, 0x00, 0x41, 0x00 , 0x43, 0x00, 0x45, 0x00 ,
        0x34, 0x00, 0x37, 0x00 ,
        0x41, 0x36, 0x00, 0x44 , 0x00, 0x39, 0x00, 0x34 ,
        0x00, 0x37, 0x00, 0x39 , 0x00, 0x44, 0x00, 0x37 ,
        0x00, 0x43, 0x00, 0x00 ,
        0x42, 0x00, 0x03, 0x64 , 0x69
        */
        0x03, 0x02, 0x2a, 0x00 , 0x04, 0x06, 0x30, 0x00 ,
        0x43, 0x00, 0x42, 0x00 , 0x45, 0x00, 0x31, 0x00 ,
        0x37, 0x00, 0x30, 0x00 ,
        // value = <
        0x41, 0x35, 0x00, 0x44 , 0x00, 0x39, 0x00, 0x37 ,
        0x00, 0x30, 0x00, 0x41 , 0x00, 0x46, 0x00, 0x39 ,
        0x00, 0x37, 0x00, 0x00 ,
        // value = <
        0x42, 0x00, 0x03, 0xe9 ,0x6b
    };
    
    UInt16 crcTmp = [[DACollection sharedInstance] crc_calculate_crc:0xFFFF inSrc:flexCmdInit inLength:sizeof(flexCmdInit) - 2];
    NSLog(@"ONE TOUCH = %04X", crcTmp);
    //memcpy(&cmdBuffer[cmdLength - 2], &crcTmp, 2);
    
    unsigned char roche_seed[] = {
        //0x83, 0x01,
        //0x00, 0x01,
        //0x00, 0x06,
        //0x00, 0x03, 0x00, 0x02,  0x00, 0x03, 0x6C, 0x41
  /*
        0x00, 0x02
        //0x83, 0x02
        //0x00, 0x03
        , 0x01, 0x07, 0x00, 0x12 , 0x00, 0x00, 0x0c, 0x17
        , 0x00, 0x0c, 0x20, 0x19 , 0x01, 0x08, 0x13, 0x43
        , 0x09, 0x00, 0x00, 0x00 , 0x00, 0x00
        , 0x00, 0x00
        */
         //0xf0, 0x00,
        //0x00, 0x36 ,
        /*
        0x00, 0x32, 0x00, 0x04
        , 0x01, 0x06, 0x00, 0x2c , 0x00, 0x00, 0xf0, 0x02
        , 0x00, 0x26
        ,
         */
        
        //f0 00 00 1c
        /*
        //0x00, 0x18, 0x00, 0x03
        //, 0x01, 0x06, 0x00, 0x12 , 0x00, 0x00, 0xf0, 0x02
        //, 0x00, 0x0c,
        0x88, 0x91 , 0x00, 0x01, 0x00, 0x06
        , 0x00, 0x01, 0x00, 0x02 , 0x00, 0x00, 0x86, 0xa8
        */
        
        // 0x00, 0x1a, 0x00, 0x02 , 0x01, 0x01, 0x00, 0x14
        //, 0x00, 0x00, 0xff, 0xff
        //, 0xff, 0xff,
    /*
        0xf0, 0x04 , 0x00, //0x0a,
        0x00, 0x01
        , 0x00, 0x06, 0x00, 0x03 , 0x00, 0x02, 0x00, 0x00
        , 0x35, 0x7f
       */
        /*
          0x88, 0x92 , 0x00, 0x04, 0x00, 0x20
        , 0x09, 0x90, 0x00, 0x08 , 0x20, 0x19, 0x02, 0x18
        , 0x17, 0x09, 0x49, 0x97 , 0x00, 0x1c, 0x00, 0x04
        , 0x00, 0x00, 0x00, 0x00 , 0x00, 0x10, 0x00, 0x02
        , 0x00, 0x00, 0x00, 0x03 , 0x00, 0x02, 0x00, 0x05
        , 0x9e, 0xd5
         */
        
        /*
        0xf0, 0x03 , 0x00, 0x01, 0x00, 0x24
        , 0x00, 0x11, 0x00, 0x20 , 0xea, 0x0f, 0xb3, 0xc8
        , 0x73, 0xb9, 0x87, 0x62
        
        , 0x48, 0xf3 , 0x10, 0x0f, 0x50, 0xee
        , 0x4f, 0xf5, 0x51, 0x0d , 0xd2, 0x20, 0xdc, 0x00
        , 0xf6, 0x50, 0xcb, 0x65
        
        , 0x8f, 0x90 , 0x74, 0xb1, 0x9c, 0x09
        , 0xAA, 0xAA
         */
#if 0
        0xF0, 0x03, 0x00, 0x01, 0x00, 0x24
        , 0x00, 0x11, 0x00, 0x20, 0x25, 0xFF, 0x4F, 0x39
        , 0x74, 0x9F, 0x89, 0xAA
        // ======= 2 =======
        //, 0x02, 0x03
        ,
        0x82, 0xFF, 0xB7, 0x2D, 0x11, 0x30
        , 0x45, 0x56, 0x6E, 0xDD, 0xB1, 0x56, 0x7E, 0x3F
        , 0x12, 0xBA, 0x64, 0xF8
        // ======= 3 =======
        //, 0x03, 0x03
        , 0xAB, 0x83, 0x7D, 0xA7, 0x68, 0xC3
        , 0x97, 0x79
#endif
        //  0xf0, 0x00, 0x00, 0x1c ,
        //0x00, 0x18, 0x00, 0x03
        //, 0x01, 0x06, 0x00, 0x12 , 0x00, 0x00, 0xf0, 0x02
#if 0
        //, 0x00, 0x0c,
        0x1d, 0x00 , 0x00, 0x01, 0x00, 0x06
        , 0x00, 0x01, 0x00, 0x02 , 0x00, 0x00, 0x0b, 0x5c
        
#endif
        
#if 0
        //0x01, 0x02,
        0x88, 0x92 , 0x00, 0x04, 0x00, 0x0C
        ,
        //, 0xe7, 0x00, 0x00, 0x1a , 0x00, 0x18, 0x00, 0x03
        //, 0x01, 0x07, 0x00, 0x12 , 0x00, 0x00,
        0x0c, 0x17
        //, 0x00, 0x0c, 0x20, 0x15 , 0x03, 0x08, 0x12, 0x13
        , 0x00, 0x08, 0x20, 0x15 , 0x03, 0x08, 0x12, 0x13
        
        //0x02, 0x02
        , 0x12, 0x00//, 0x00, 0x00 , 0x00, 0x00
        , 0x22, 0x08
//#endif
        0x20, 0x19, 0x01, 0x10
        , 0x04, 0x00, 0x24, 0x78
        , 0xFF, 0xFF
#endif
        //0x20, 0x19, 0x02, 0x18
        //, 0x17, 0x09, 0x49, 0x97
        
        //0x01, 0x02,
        0xF0, 0x03 , 0x00, 0x03, 0x00, 0x1A
        , 0x09, 0x90, 0x00, 0x08 , 0x20, 0x17, 0x03, 0x11
        , 0x18, 0x22, 0x05, 0x00
        
        //, 0x02, 0x02
        , 0x00, 0x1C , 0x00, 0x04, 0xFF, 0xFF
        , 0xFF, 0xFC, 0x00, 0x10 , 0x00, 0x02, 0x00, 0x01
        , 0x91, 0xA6
        
    };
    
    //UInt16 crcRocheTmp = [[DACollection sharedInstance] crc_calculate_crc:0xFFFF inSrc:roche_seed inLength:sizeof(roche_seed) - 2];
    uint16_t crc_init = 0xFFFF;
    uint16_t crcRocheTmp = crc16_mcrf4xx(crc_init, roche_seed, sizeof(roche_seed) - 2);
    //printf("=== CRC %04X ===\n", crcRocheTmp);
    NSLog(@" === ROCHE CRC === = %04X, %02X, %02X", crcRocheTmp, (crcRocheTmp & 0xFF00)>>8, crcRocheTmp & 0xFF);
    
    
    
    NSString *ct;
    ct = [[DACollection sharedInstance] howToGetCurrentDateTime];
    //[[DACollection sharedInstance] howToGetCurrentTime];
    [[DACollection sharedInstance] howToWriteFile:ct];
    [self timeW310bProcess];
    
    [self deltaNumber];
#if 0
#define BP_RECORD_IDX_MAX       100
#define BW_RECORD_IDX_MAX       30
    UInt8 qty = 10;
    
    UInt8 addrIdx = 23;
    Byte *omronIndexArray = (Byte *)malloc(BP_RECORD_IDX_MAX);
    for (int i=0; i<BP_RECORD_IDX_MAX; i++) {
        omronIndexArray[i] = 0;
    }
    /*
    for (int i=qty; i>0; i--) {
        omronIndexArray[i-1] = (--addrIdx);
    }
    
    for (int i=0; i<32; i++) {
        NSLog(@"WXX %02d, = %02X GOOD", i, omronIndexArray[i]);
        omronIndexArray[i] = 0;
    }
    */
    NSLog(@"");
    NSLog(@"");
    
    qty = 20;
    addrIdx = 10;
    
    
    BOOL typeHem = YES;
    
    UInt8 diffIdx = 0;
    UInt8 cmdLen = qty;
    
    if (qty>addrIdx) {
        diffIdx = qty-addrIdx;
        if (typeHem) {
            NSLog(@"HEM");
            for (int i=diffIdx; i>0; i--) {
                omronIndexArray[diffIdx-i] = BP_RECORD_IDX_MAX-i;
            }
        }else{
            NSLog(@"HBF");
            for (int i=diffIdx; i>0; i--) {
                NSLog(@"HBF %d", i);
                omronIndexArray[diffIdx-i] = BW_RECORD_IDX_MAX-i;
            }
        }
        if (addrIdx > 0) {
            NSLog(@"ELSE ...");
            for (int i=0; i<addrIdx; i++) {
                NSLog(@"ELSE ... %d", i);
                omronIndexArray[diffIdx+i] = i;
            }
        }
    }else{
        NSLog(@"OTHER");
        for (int i=qty; i>0; i--) {
            omronIndexArray[i-1] = (--addrIdx);
        }
    }
    
    for (int i=0; i<cmdLen; i++) {
        NSLog(@"SND %02d, = %02X GOOD", i, omronIndexArray[i]);
    }
#endif
    
#if 0
    RFC3339DateFormatter = [[NSDateFormatter alloc] init];
    RFC3339DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    RFC3339DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    RFC3339DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    /* 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time) */
    NSString *string = @"1996-12-19T16:39:57-08:00";
    NSDate *date = [RFC3339DateFormatter dateFromString:string];
#endif
    NSDate *now = [[NSDate alloc] init];

    NSLog(@"ISO 8601 - CT IS --> %@", now);

    [self ultraYearMonthDay];
 /*
    attributedString = [[NSMutableAttributedString alloc] initWithString:@"This is a long, attributed string, that's set up to loop in a continuous fashion!"];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.123 green:0.331 blue:0.657 alpha:1.000] range:NSMakeRange(0,34)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.657 green:0.096 blue:0.088 alpha:1.000] range:NSMakeRange(34, attributedString.length - 34)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] range:NSMakeRange(0, 16)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] range:NSMakeRange(33, attributedString.length - 33)];
//    self.demoLabel6.attributedText = attributedString;
*/
    //void (^simpleBlock)(UInt32 xVal);
    UInt32 userDef = 0;
    UInt32 userDefXXX = 0;
    UInt32 userDefYYY = 0;
    
    [[NSUserDefaults standardUserDefaults] setInteger:0x12345678 forKey:@"user_DEF"];
    userDef = (UInt32)[[NSUserDefaults standardUserDefaults] integerForKey:@"user_DEF"];
    
    UInt32 (^multiplyTowValues)(UInt32, UInt32) = ^(UInt32 first, UInt32 second)  {
        second = (UInt32)[[NSUserDefaults standardUserDefaults] integerForKey:@"user_DEF"];
        return first * second; };
    NSLog(@"USER DEF %08X", (unsigned int)userDef);
    userDefYYY = multiplyTowValues(1,6);
    //simpleBlock(userDefYYY);
    NSLog(@"USER OTHER %08X", (unsigned int)userDefXXX);
    NSLog(@"USER WHAT %08X", (unsigned int)userDefYYY);
    
    UInt16 addr = 0x1234;
    UInt8 xxBuffer[8] = {0};
    memcpy(&xxBuffer[2], &addr, 2);
    
    xxBuffer[5] = addr & 0xFF;
    xxBuffer[6] = (addr & 0xFF00) >> 8;
    for (int i=0; i<8; i++) {
        NSLog(@"IDX = %d, VAL = %02X", i, xxBuffer[i]);
    }
    
/*
    NSURL *url = [NSURL URLWithString:@"https://www.nsysu.edu.tw/bin/home.php"];
    NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:Nil error:Nil];
    NSLog(@"HOW DO You Turn This On ?? %@", str);
*/
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat =@"dd-MM-yyyy";
    //NSDate *date = [dateFormatter dateFromString:str];
    
    //NSLog(@"Haha is %@", date);
    
    // INIT
    [OmronUserIdAndRdType sharedInstance].omronRecordType = RECORD_TYPE_BG;
    [OmronUserIdAndRdType sharedInstance].omronUserIdSel = USER_TAG1_MASK;
    
    // SB TEST
    UInt8 sbSum = 0;
    //UInt8 sbSrc[] = {0x0b,
    //    0x32, 0x37, 0x38 , 0x32, 0x51, 0x41, 0x4a
    //    , 0x30, 0x35, 0x34, 0x35 , 0x88};
    UInt8 sbSrc[] = {//0x01, 0x01,
        //0x4f, 0xcf, 0xd8, 0xa7 , 0x86, 0x75, 0x74, 0x83,
        //0xa2, 0xd1, 0x10, 0x5f , 0xbe, 0x2d, 0xac, 0x3b,
        //0xda, 0x1d
        /*
        0xB0, 0x31,
        //0x19, 0xEE, 0x83, 0x5F, 0x2D, 0xDA, 0xD1};
        0xAA, 0x3A, 0x44, 0x51, 0xC0, 0x5C, 0x76
        */
        
        //<
        //  0x01, 0x01,
        //0x4f, 0xe7
        //, 0x0b,
        0x32, 0x37, 0x38 , 0x32, 0x51, 0x41, 0x4a
        , 0x30, 0x35, 0x34, 0x35 , 0x7d, 0x3b
        //>
        
    };
    
    for (int i=0; i<sizeof(sbSrc); i++) {
        sbSum += sbSrc[i];
        NSLog(@"SB IDX = %d, SRC = %02X, SUM = %02X", i, sbSrc[i], sbSum);
    }
    //UInt64 phoCode = 972763285;
    //UInt8 phoMode = 0;
    /*
    for (int k=255; k>180; k--) {
        //phoCode = 972763285;
        phoCode = 916230933;
        for (int i=0; i<4; i++) {
            phoMode = (UInt8)(phoCode%k);
            phoMode ^= 0xFF;
            //if (phoMode == 0xBE) {
            if (phoMode == 0x35) {
                NSLog(@"PAIR GOOD GOOD GOOD ====");
            }
            NSLog(@"idx = %d NR = %02X", i, (UInt8)(phoCode%k));
            phoCode >>= 8;
        }
        NSLog(@"====== %d =======/n\n", k);
    }
     */
    NSString *phoString = @"0972763285";
    [MySecurities sharedInstance];
    //[[MySecurities sharedInstance].md5String:phoString];
    [[MySecurities sharedInstance] md5String:phoString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VIEW CONTROLLER TASK
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"H2-VEIW DID Enter Background");
    /*
     Use this method to release shared resources, save user data, invalidate
     timers, and store enough application state information to restore your
     application to its current state in case it is terminated later.
     If your application supports background execution, this method is called
     instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"H2-VEIW WILL Enter Foreground");
    /*
     Called as part of the transition from the background to the active state;
     here you can undo many of the changes made on entering the background.
     */
}
/*
- (void)appDidBecomeActive:(NSNotification *)notification {
    NSLog(@"H2-VEIW did become active notification");
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    NSLog(@"H2-VEIW will enter foreground notification");
}
*/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"SQX-VEIW view will appear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[[H2AudioHelper sharedInstance] audioForSession];
//    [[H2Sync sharedInstance] appAudioHideVolumeIcon:self.view];
    if ([LibDelegateFunc sharedInstance].demoAutoSync) {
        [LibDelegateFunc sharedInstance].demoAutoSync = NO;
        NSLog(@"AUTO HAPPEN!!");
#ifdef AUTO_SYNC
        [NSTimer scheduledTimerWithTimeInterval:0.3f
                                         target:self
                                       selector:@selector(demoAutoSyncStart)
                                       userInfo:nil
                                        repeats:NO];
#endif
    }
    NSLog(@"SQX-VEIW view did appear");
}

- (void)demoAutoSyncStart
{
    [self sqxMeterTask:nil];
    [LibDelegateFunc sharedInstance].meterTaskAutoSync = YES;
}

- (IBAction)sqxMeterTask:(id)sender {
    MeterTaskViewController *omronController =[[MeterTaskViewController alloc] init];
    [self presentViewController:omronController animated:YES completion:^{NSLog(@"OMRON VIEW DONE(Scan)");}];
}

- (IBAction)sqxQRCodeForCable:(id)sender {
    QRCodeViewController *qrxController =[[QRCodeViewController alloc] init];
    [self presentViewController:qrxController animated:YES completion:^{NSLog(@"QRX VIEW done");}];
}

- (IBAction)sqxBleMeters:(id)sender
{
    BleEquipViewController *omEquipShowController =[[BleEquipViewController alloc] init:nil];
    [self presentViewController:omEquipShowController animated:YES completion:^{NSLog(@"BLE SHOW BGM done");}];
}


- (IBAction)sqxCableMeters:(id)sender {
    modelsController = [[BGMBrandsViewController alloc] init];
    modelsController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:modelsController animated:YES completion:^{NSLog(@"BGM BRANDS done");}];
}

- (IBAction)sqxPageTest:(id)sender {
    PagesViewController *omronUserIdController = [[PagesViewController alloc] init];
    [self presentViewController:omronUserIdController animated:YES completion:^{NSLog(@"PAGES ...");}];

#if 0
    // Show Omron User Id Dialog
    OmronShowUserIdViewController *omronUserIdController = [[OmronShowUserIdViewController alloc] init:3];
    [self presentViewController:omronUserIdController animated:YES completion:^{NSLog(@"SHOW OMRON USER TAG");}];

#if 0
    // for test
    if ([[LibDelegateFunc sharedInstance].serverLastDateTimes count] > 0) {
        [[LibDelegateFunc sharedInstance].serverLastDateTimes removeAllObjects];
    }
    // #else
    NSDictionary *temp = nil;
    [LibDelegateFunc sharedInstance].h2RecordsDataType = 0;
    NSLog(@"LDT SVR - %@",[LibDelegateFunc sharedInstance].serverLastDateTimes);
    NSLog(@"LDT MIDDLE - %@", [LibDelegateFunc sharedInstance].middleDateTime);
    if ([[LibDelegateFunc sharedInstance].serverLastDateTimes count] > 0 && [LibDelegateFunc sharedInstance].middleDateTime != nil){
        for (NSDictionary *info in [LibDelegateFunc sharedInstance].serverLastDateTimes){
            temp = @{@"BG_brandLastDateTime" : [LibDelegateFunc sharedInstance].middleDateTime, @"brandModel" : [info objectForKey: @"brandModel"], @"brandSerialNumber" : [info objectForKey: @"brandSerialNumber"], @"SkipRecord" : [info objectForKey: @"SkipRecord"], @"SyncErr" : [info objectForKey: @"SyncErr"]};
        }
    }
#endif
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"M -T Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
#endif
}

- (IBAction)sqxOAuthTable:(id)sender {
    OAuth2ViewController *oauth2Controller = [[OAuth2ViewController alloc] init];
    [self presentViewController:oauth2Controller animated:YES completion:^{NSLog(@"OAUTHORIZE ...");}];
}








- (void) sqxPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)midQrNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"MID_SN_NOTIFICATION"])
    {
        NSLog (@"DEMO APP Successfully received ID OR SN NOTIFY!");
        [self showIdAndSerialNumber];
    }
}

- (void)showIdAndSerialNumber
{
    
    UInt32  mId = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"];
    _currentMeterId.text = [NSString stringWithFormat:@"MID : %08X ", (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"UDEF_METER_ID"]];
    
    NSLog(@"METER ID IS %04X", (unsigned int)mId);
    // Update MID and SN
    
    if (mId & 0x8000) {
        _currentQrOrMeterSn.text = [NSString stringWithFormat:@"MSN : %@ ", [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_METER_SN"]];
        
        //[[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_METER_SN"];
    }else{
        _currentQrOrMeterSn.text = [NSString stringWithFormat:@"CQR : %@ ", [[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"]];
        //[[NSUserDefaults standardUserDefaults] objectForKey:@"UDEF_QR_CODE"];
        //_currentMeterId.text = [_currentMeterId.text stringByAppendingString:[LibDelegateFunc sharedInstance].qrStringCode];
    }
    
}


#define DATA_0      2
#define DATA_1      3
#define DATA_2      4
#define DATA_3      5

- (void)timeW310bProcess
{
    Byte *_foraCmdBuffer = (Byte *)malloc(6);
    NSDate *now = [[NSDate alloc] init];

    NSLog(@"CT IS --> %@", now);

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
    
    UInt16 year = [components year];
    UInt8 month = [components month];
    UInt8 day = [components day];
    
    UInt8 hour = [components hour];
    UInt8 minute = [components minute];
    UInt8 second = [components second];
    
    
    
    _foraCmdBuffer[DATA_1] = year-2000;
    _foraCmdBuffer[DATA_1] <<= 1;
    
    if (month & 0x08) {
        _foraCmdBuffer[DATA_1] |= 1;
    }
    _foraCmdBuffer[DATA_0] = month;
    _foraCmdBuffer[DATA_0] <<= 5;
    _foraCmdBuffer[DATA_0] |= day;
    
    _foraCmdBuffer[DATA_2] = minute;
    _foraCmdBuffer[DATA_3] = hour;
    
    for (int i=2; i<6; i++) {
        NSLog(@"HOW %d = %02X", i, _foraCmdBuffer[i]);
    }
//#ifdef DEBUG_BW
    NSLog(@"DEMO-DEBUG Y:%04X, M:%02X, D:%02X", year, month, day);
    NSLog(@"DEMO-DEBUG H:%02X, MIN:%02X, SEC:%02X", hour, minute, second);
    NSLog(@"OMRON Y:%04X, M:%02X, D:%02X", year-2000, month, day);
//#endif
}

+ (SQXViewController *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_APEXBIO
    NSLog(@"SQX INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

- (void)deltaNumber
{
    for (int i=1; i<19; i++) {
        //NSLog(@"%d, %d", i, i%2+1);
    }
}


#if 1
#define STR_YEAR            1970
#define YYY_YEAR            1972
#else
#define STR_YEAR            2000
#define YYY_YEAR            2000
#endif

- (void)ultraYearMonthDay//:(BOOL)mmolUnit
{
    
//    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
//    Byte *recordData;
//    recordData = (Byte *)malloc(256);
//    memcpy(recordData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    
    //UInt32 inSecond = 0x585AC12B;
//    UInt32 inSecond = 0x58590B89; // 2016-12-19 10:44:25 ==> 2016-12-20 10:44:25
    
//    UInt32 inSecond = 0x58586A7E; // 2016-12-19 23:17:18
//    UInt32 inSecond = 0x58582ABE; // 2016-12-19 18:45:18
//    UInt32 value = 0;
    
//            UInt32 inSecond = 0x56D4A13D; // 2016-02-29 19:51:25
    
    UInt32 inSecond = 0x56D6A316; // 2016-03-02 08:23:50
    
//    UInt32 inSecond = 0x1ECF2887;
//    UInt32 inSecond = 0x1ECF01B4;
    //UInt32 inSecond = 0x1ECEDC6F;
    
//    UInt32 inSecond = 0x1ED02697;
    
//    memcpy(&inSecond, &[H2AudioAndBleSync sharedInstance].dataBuffer[11], 4);
 //   memcpy(&value, &[H2AudioAndBleSync sharedInstance].dataBuffer[15], 4);
    
    UInt32 totalMinute;
    UInt32 totalHour;
    UInt32 totalDay;
    
    UInt32 ultraMiniSecond;
    UInt32 ultraMiniMinute;
    UInt32 ultraMiniHour;
    UInt32 ultraMiniDay;
    
    
    UInt32 ultraMiniMonth;
    UInt32 ultraMiniYear;
    UInt32 totalYear;
    
    //UInt16 x=1972,y=0;
    
    UInt16 x=YYY_YEAR,y=0;
    
    
    totalMinute = inSecond / 60;
    ultraMiniSecond = inSecond % 60;// - totalMinute * 60;
    totalHour = totalMinute / 60;
    ultraMiniMinute = totalMinute % 60;// - totalHour*60;
    totalDay = totalHour / 24;
    ultraMiniHour = totalHour % 24;// - totalDay * 24;
    totalYear = totalDay / 365;
    
    NSLog(@"haha MINUTE %ld", ultraMiniMinute);
    NSLog(@"haha HOUR %ld", ultraMiniHour);
    NSLog(@"haha DAY %ld", totalDay);
//    NSLog(@"haha MONTH %ld", totalYear);
    NSLog(@"haha YEAR %ld", totalYear);
#ifdef DEBUG_ONETOUCH
    NSLog(@"DEBUG_ONETOUCH the year is X1 %lu", (long)(STR_YEAR + totalYear));
#endif
    //    currentYear = 1970 + totalYear;
    do{
        x += 4;
        y++;
    }while (x <= STR_YEAR + totalYear) ;
    
     NSLog(@"閏年 %d,  - %ld", y, (STR_YEAR + totalYear)/100 - 19);
    
    // add this
    y -= ((STR_YEAR + totalYear)/100 - 19);
    
    ultraMiniDay = totalDay -(totalYear * 365);
    
    NSLog(@"閏年 ddd %ld", ultraMiniDay);
    
    if (ultraMiniDay <= y) {
        totalYear--;
        ultraMiniDay = totalDay -(totalYear * 365);
    }
    ultraMiniYear = STR_YEAR + totalYear;
    ultraMiniDay -= y;
    
    // add
    //ultraMiniDay++; // 2000 year
    
    y = 0;
    
    for (y =0; y<12; y++) {
        if (y == 0) {  // Jan
            if (ultraMiniDay>=31) {
                ultraMiniDay -=31;
            }else{
                break;
            }
        }else if (y==1){ // Feb
            if (ultraMiniYear%4) {
                NSLog(@"NORMAL YER $$$$");
                if (ultraMiniDay >= 28) {
                    ultraMiniDay -= 28;
                }else{
                    break;
                }
            }else{
                NSLog(@"潤年 Happen $$$$");
                if (ultraMiniDay >= 29) {
                    ultraMiniDay -= 29;
                }else{
                    break;
                }
                
            }
            
        }else{ // the others
            if ((!(y%2) && y<7) || ((y%2) && y>= 7)) { // 3, 5, 7, 8, 10, 12
                if (ultraMiniDay>=31) {
                    ultraMiniDay -= 31;
                }else{
                    break;
                }
            }else{ // 4, 6, 9, 11
                if (ultraMiniDay>=30) {
                    ultraMiniDay -= 30;
                }else{
                    break;
                }
            }
        }
        NSLog(@"MON =  %d and Day = %ld", y+1, ultraMiniDay+1);
    }
    if (y<12) {
        ultraMiniMonth = y+1;
    }else{
        ultraMiniMonth = 1;
        ultraMiniYear++;
    }
    ultraMiniDay++;
}


#pragma mark - ARKRAY DECODE
const UInt8 srcData [] =
{
     0xf5 ,0xfb ,0xa8 ,0xea     ,0x28 ,0xe8 ,0x74 ,0xfb
    ,0x29 ,0x29 ,0xe8 ,0x29     ,0xa9 ,0x28 ,0x28 ,0xfb
    ,0xe8 ,0xfb ,0xfb ,0xe8
    ,0xe8 ,0xe8 ,0x21 ,0xe9     ,0xa9 ,0xfb ,0xa7 ,0x66
    ,0x65
};

#define ARKRAY_BASE_ACK                             0x3E
#define ARKRAY_DYNAMIC_ACK                          0x65

#define AK_KEYCMD_MASK                              0x04
#define AK_AUX1CMD_MASK                             0xC4
#define AK_AUX2CMD_MASK                             0xC0

- (void)arkrayDecode
{
    //f5 fb a8 ea 28 e8 74 fb     29 29 e8 29 a9 28 28 fb     e8 fb fb e8
    //e8 e8 21 e9 a9 fb a7 66 65
    UInt8 arkrayCode = 0;
    UInt8 arkrayReal = 0;
    NSLog(@"IDX , VAL = ");
    for (int i=0; i<sizeof(srcData); i++) {
        arkrayCode = srcData[i] ^ ARKRAY_BASE_ACK ^ ARKRAY_DYNAMIC_ACK;
        arkrayReal = [self numberDeCodeNEW:arkrayCode];
        NSLog(@"IDX %2d, VAL = %02X, %02X, %02X", i, srcData[i], arkrayCode, arkrayReal);
    }
}


- (UInt8) numberNormalize:(UInt8) aCode
{
    UInt8 srcNumber = 0;
    
    //srcNumber = aCode ^ ARKRAY_BASE_ACK ^ _arkrayDynamicAck;
    return srcNumber;
}

// NEW DECODE
- (UInt8) numberDeCodeNEW:(UInt8)akCode
{
    unsigned char number = 0;
    unsigned char hiNibble = 0;
    unsigned char loNibble = 0;
    
    if ((akCode & 0x30) == 0x30) { // Number < 10
        hiNibble = akCode & 0xC0;
        hiNibble >>= 6;
        hiNibble ^= 0x2;
        
        loNibble = 3 - (akCode & 0x03);
        
        number = (loNibble << 2) + hiNibble;
    }else{ // Number >= 10
        switch (akCode) {
            case 0xEF:
                number = 10;
                break;
                
            case 0x2F:
                number = 11;
                break;
                
            case 0x6F:
                number = 12;
                break;
                
            case 0xAE:
                number = 13;
                break;
                
            case 0xEE:
                number = 14;
                break;
                
            case 0x2E:
                number = 15;
                break;
                
            default:
                number = 255;
                break;
        }
    }
    return number;
}

- (void)calcDymicaCmd
{
    UInt16 slaveSrc[12] = {
        /*
        0x00, 0x00,
        14, 0x00,
        0x05, 12,
        
        0x00, 0x08,
        0x04, 0x04,
        10, 15
        */
        0x00, 0x00, 0x0E, 0x00,
        0x05, 0x0C, 0x00, 0x08,
        0x0F, 0x0B, 0x09, 0x04
    };
    
    UInt16 masterSrc[12] = {
        /*
        0x07, 13,
        0x00, 0x00,
        0x04, 0x09,
        
        0x04, 0x06,
        15, 0x00,
        15, 0x02
        */
        0x07, 0x01, 0x08, 0x03,
        0x05, 0x04, 0x06, 0x08,
        0x05, 0x08, 0x0C, 0x0C
    };
    
    
    UInt16 slaveAdd[6] = {0};
    UInt16 masterAdd[6] = {0};
    UInt16 xSum = 0;
    NSLog(@"\n");
    for (int i=0; i<6; i++) {
        slaveAdd[i] = (slaveSrc[2*i] << 4) + slaveSrc[2*i+1];
        masterAdd[i] = (masterSrc[2*i] << 4) + masterSrc[2*i+1];
        xSum = slaveAdd[i] + masterAdd[i];
        NSLog(@"SLAVE MASTER VALUE : %d, %02X, %02X, <> SUM = %04X", i, slaveAdd[i], masterAdd[i], xSum);
    }
    
    UInt16 sumValue = 0;
    for (int i= 0; i<6; i++) {
        sumValue += (slaveAdd[i] + masterAdd[i]);
        NSLog(@"SUM = %04X", sumValue);
    }
    
    int A1 = ((((UInt8) slaveAdd[0]) + slaveAdd[1]) + masterAdd[0]) & 255;
    int A2 = (((UInt8) slaveAdd[2]) + masterAdd[4]) & 255;
    int A3 = ((((UInt8) slaveAdd[3]) + masterAdd[2]) + masterAdd[5]) & 255;
    int A4 = (((UInt8) slaveAdd[4]) + masterAdd[3]) & 255;
    int A5 = (((UInt8) slaveAdd[5]) + masterAdd[1]) & 255;
    UInt8 K1 = ((((((UInt8) A1) + A2) + A3) + A4) + A5) & 255;
    UInt8 K2 = (K1 ^ 170) & 255;
    UInt8 K3 = (((((A2 << 2) ^ A1) ^ A3) ^ (A4 << 3)) ^ (A5 << 2)) & 255;
    UInt8 K4 = (K1 ^ K3) & 255;
    NSLog(@"== %02X, %02X, %02X, %02X, %02X", A1, A2, A3, A4, A5);
    NSLog(@"K1 = %02X, %d", K1, K1);
    NSLog(@"K2 = %02X, %d", K2, K2);
    NSLog(@"K3 = %02X, %d", K3, K3);
    NSLog(@"K4 = %02X, %d", K4, K4);
    
    UInt8 data = 22;
    UInt16 tmpx = 0;
    UInt16 tmpy = 0;
    UInt16 tmpz = 0;
    UInt16 tmpw = 0;
    
    tmpx = [self rotateLeft:(data ^ K1) withKeta:4];
    tmpy = [self rotateLeft:(tmpx ^ K2) withKeta:3];
    tmpz = [self rotateLeft:(tmpy ^ K3) withKeta:5];
    tmpw = [self rotateLeft:(tmpz ^ K4) withKeta:2];
    NSLog(@"RL == %d, %d, %d, %d", tmpx, tmpy, tmpz, tmpw);
    UInt8 dynamicCmd = (UInt8)(tmpw & 0xFF);
    NSLog(@"****** THE CMD = %02X ******", dynamicCmd);
    //RotateLeft(RotateLeft(RotateLeft(RotateLeft(data ^ this._K1, 4) ^ this._K2, 3) ^ this._K3, 5) ^ this._K4, 2) & 255);
    
    
    UInt16 slaveSrcX[12] = {
        0x00, 0x00
        ,14, 0x00
        ,0x05, 12
        ,0x00, 0x08
        ,0x04, 0x04
        ,10, 15
    };
    
    UInt16 masterSrcX[12] = {
        0x07, 0x09
        ,0x00, 0x06
        ,0x06, 14
        ,12, 0x00
        ,11, 0x03
        ,0x01,0x05
    };
    
    NSLog(@"\n");
    for (int i=0; i<6; i++) {
        slaveAdd[i] = (slaveSrcX[2*i] << 4) + slaveSrcX[2*i+1];
        masterAdd[i] = (masterSrcX[2*i] << 4) + masterSrcX[2*i+1];
        NSLog(@"SLAVE MASTER VALUE : %d, %02X, %02X", i, slaveAdd[i], masterAdd[i]);
    }
    
    sumValue = 0;
    for (int i= 0; i<6; i++) {
        sumValue += (slaveAdd[i] + masterAdd[i]);
        NSLog(@"SUM = %04X", sumValue);
    }
    
    A1 = ((((UInt8) slaveAdd[0]) + slaveAdd[1]) + masterAdd[0]) & 255;
    A2 = (((UInt8) slaveAdd[2]) + masterAdd[4]) & 255;
    A3 = ((((UInt8) slaveAdd[3]) + masterAdd[2]) + masterAdd[5]) & 255;
    A4 = (((UInt8) slaveAdd[4]) + masterAdd[3]) & 255;
    A5 = (((UInt8) slaveAdd[5]) + masterAdd[1]) & 255;
    
    K1 = ((((((UInt8) A1) + A2) + A3) + A4) + A5) & 255;
    K2 = (K1 ^ 170) & 255;
    K3 = (((((A2 << 2) ^ A1) ^ A3) ^ (A4 << 3)) ^ (A5 << 2)) & 255;
    K4 = (K1 ^ K3) & 255;
    
    NSLog(@"SND K1 = %02X", K1);
    NSLog(@"SND K2 = %02X", K2);
    NSLog(@"SND K3 = %02X", K3);
    NSLog(@"SND K4 = %02X", K4);
    
    //UInt8 data = 22;
    tmpx = 0;
    tmpy = 0;
    tmpz = 0;
    tmpw = 0;
    
    tmpx = [self rotateLeft:(data ^ K1) withKeta:4];
    tmpy = [self rotateLeft:(tmpx ^ K2) withKeta:3];
    tmpz = [self rotateLeft:(tmpy ^ K3) withKeta:5];
    tmpw = [self rotateLeft:(tmpz ^ K4) withKeta:2];
    dynamicCmd = (UInt8)(tmpw & 0xFF);
    NSLog(@"SND ****** THE CMD = %02X ******", dynamicCmd);
    /*
    00 00 0E 00
    05 0C 00 08
    0F 0B 09 04
    
    
    07 01 08 03
    05 04 06 08
    05 08 0C 0C
     
     SUM 04 07
     */
    /*
    UInt8 secretSrc[24] = {
        0x00, 0x00, 0x0E, 0x00,
        0x05, 0x0C, 0x00, 0x08,
        0x0F, 0x0B, 0x09, 0x04,
        
        0x07, 0x01, 0x08, 0x03,
        0x05, 0x04, 0x06, 0x08,
        0x05, 0x08, 0x0C, 0x0C
    };
    */
    UInt8 secretSrc[24] = {
      0x00, 0x00, 0x0E, 0x00
    , 0x05, 0x0C, 0x00, 0x08
    , 0x0F, 0x0B, 0x09, 0x04
    
    , 0x04, 0x04, 0x08, 0x0E
    , 0x0C, 0x00, 0x01, 0x0A
    , 0x0F, 0x05, 0x00, 0x03
    };
    //=====================================
    //05 02
    UInt8 src[] = {1, 34, 104, 223};
    //Byte *srcDebug = (Byte *)malloc(24);
    unsigned char srcDebug[24] = {0};
    for (int i=0; i < sizeof(src); i++) {
        srcDebug[2*i] = [self deTransfer:(src[i]>>4)&0x0F];
        srcDebug[2*i+1] = [self deTransfer:src[i]&0x0F];
    }
    NSString *stringA = @"ok!!";
    NSString *stringB = @"or fail";
    NSString *stringC = [NSString stringWithUTF8String:(const char *)srcDebug];
    [self calcDynamicCmd:secretSrc];
    NSDictionary *debugDic = [[NSDictionary alloc] init];
    NSMutableArray *debugArray = [[NSMutableArray alloc] init];
    [debugArray addObject:stringA];
    [debugArray addObject:stringB];
    [debugArray addObject:stringC];
    
    debugDic = @{
                    @"APP_DEBUG" : debugArray // Date and Time String
                    //@"LDT_Model" :@"",//@"NewModel",
                        
                };
    NSLog(@"WHAT HAPPEN : %@", debugDic);
    
}

- (void)calcDynamicCmd:(Byte *)secret
{
    UInt8 slaveSrc[12] = {0};
    UInt8 masterSrc[12] = {0};
    memcpy(slaveSrc, secret, 12);
    memcpy(masterSrc, &secret[12], 12);
    /*
    UInt16 slaveSrc[12] = {
    0x00, 0x00, 0x0E, 0x00,
    0x05, 0x0C, 0x00, 0x08,
    0x0F, 0x0B, 0x09, 0x04
    };
    UInt16 masterSrc[12] = {
    0x07, 0x01, 0x08, 0x03,
    0x05, 0x04, 0x06, 0x08,
    0x05, 0x08, 0x0C, 0x0C
    };
     */
    UInt16 slaveAdd[6] = {0};
    UInt16 masterAdd[6] = {0};
    UInt16 sumValue = 0;
    NSLog(@"\n");
    for (int i=0; i<6; i++) {
        slaveAdd[i] = (slaveSrc[2*i] << 4) + slaveSrc[2*i+1];
        masterAdd[i] = (masterSrc[2*i] << 4) + masterSrc[2*i+1];
        //sumValue += (slaveAdd[i] + masterAdd[i]);
        sumValue += (slaveSrc[2*i] + slaveSrc[2*i+1] + masterSrc[2*i] + masterSrc[2*i+1]);
        NSLog(@"SLAVE MASTER VALUE : %d, %02X, %02X ==> SUM = %04X", i, slaveAdd[i], masterAdd[i], sumValue);
    }
    
    int A1 = ((((UInt8) slaveAdd[0]) + slaveAdd[1]) + masterAdd[0]) & 255;
    int A2 = (((UInt8) slaveAdd[2]) + masterAdd[4]) & 255;
    int A3 = ((((UInt8) slaveAdd[3]) + masterAdd[2]) + masterAdd[5]) & 255;
    int A4 = (((UInt8) slaveAdd[4]) + masterAdd[3]) & 255;
    int A5 = (((UInt8) slaveAdd[5]) + masterAdd[1]) & 255;
    UInt8 K1 = ((((((UInt8) A1) + A2) + A3) + A4) + A5) & 255;
    UInt8 K2 = (K1 ^ 170) & 255;
    UInt8 K3 = (((((A2 << 2) ^ A1) ^ A3) ^ (A4 << 3)) ^ (A5 << 2)) & 255;
    UInt8 K4 = (K1 ^ K3) & 255;
    NSLog(@"\n");
    NSLog(@"K1 = %02X, %d", K1, K1);
    NSLog(@"K2 = %02X, %d", K2, K2);
    NSLog(@"K3 = %02X, %d", K3, K3);
    NSLog(@"K4 = %02X, %d", K4, K4);
    
    UInt8 data = 22;
    UInt16 tmpx = 0;
    UInt16 tmpy = 0;
    UInt16 tmpz = 0;
    UInt16 tmpw = 0;
    
    tmpx = [self rotateLeft:(data ^ K1) withKeta:4];
    tmpy = [self rotateLeft:(tmpx ^ K2) withKeta:3];
    tmpz = [self rotateLeft:(tmpy ^ K3) withKeta:5];
    tmpw = [self rotateLeft:(tmpz ^ K4) withKeta:2];
    //UInt8 dynamicCmd = (UInt8)(tmpw & 0xFF);
    
    NSLog(@"****** HAHA CMD = %02X ******", (UInt8)(tmpw & 0xFF));
    //_arkrayDynamicCmd = (UInt8)(tmpw & 0xFF);
    //NSLog(@"****** THE CMD = %02X ******", _arkrayDynamicCmd);
    UInt16 txValue[] = {
    0, //     Sum = 0000
    0, //     Sum = 0000
    14, //   Sum = 0014
    0, //     Sum = 0014
    5, //     Sum = 0019
    12, //     Sum = 0031
    0, //     Sum = 0031
    8, //     Sum = 0039
    
    4, //     Sum = 0043
    4, //     Sum = 0047
    10, //     Sum = 0057
    15, //     Sum = 0072
    
    7, //     Sum = 0079
    13, //     Sum = 0092
    0, //     Sum = 0092
    0, //     Sum = 0092
    4, //     Sum = 0096
    9, //     Sum = 0105
    4, //     Sum = 0109
    6, //     Sum = 0115
    15, //     Sum = 0130
    0, //     Sum = 0130
    15, //     Sum = 0145
    2 //     Sum = 0147
    };
    UInt16 xxSum = 0;
    for (int i=0; i<12; i++) {
        //xxSum += ((txValue[2*i]<<4) + txValue[2*i+1]);
        xxSum += ((txValue[2*i]<<0) + txValue[2*i+1]);
        NSLog(@"LAST SUM = %04X", xxSum);
    }
    
    UInt8 a = 3;
    UInt8 b = 5;
    UInt8 c = 9;
    
    NSLog(@"THE VAL = %02X", a>1?b:c);
    NSLog(@"THE VAL = %02X", a>6?b:c);
    
    UInt8 omCrc = 0;
    UInt8 omSrc[] = {
        // data 4
          0x18, 0x80, 0x00, 0x00 , 0x00, 0x10, 0x00, 0x00
        , 0x00, 0x94, 0x00, 0x2d , 0x11, 0x03, 0x07, 0x91
        , 0xe0, 0x00, 0xff, 0xff , 0x4b, 0xc1, 0x00, 0xdf
        , 0x00, 0x00, 0x00, 0x00 , 0x00, 0x00, 0x00, 0x00
    };
    for (int i=0; i<sizeof(omSrc); i++) {
        omCrc ^= omSrc[i];
        NSLog(@"OM IDX = %d SRC = %02X, CRC = %02X", i, omSrc[i], omCrc);
    }
    
}

/*
public byte Encrypt(int data) {
    return (byte) (RotateLeft(RotateLeft(RotateLeft(RotateLeft(data ^ this._K1, 4) ^ this._K2, 3) ^ this._K3, 5) ^ this._K4, 2) & 255);
}


public byte Decrypt(int data) {
    return (byte) ((RotateRight(RotateRight(RotateRight(RotateRight(data, 2) ^ this._K4, 5) ^ this._K3, 3) ^ this._K2, 4) ^ this._K1) & 255);
}

private int RotateLeft(int data, int Keta) {
    int Buffer = ((data + 255) + 1) & 255;
    return ((Buffer << Keta) & 255) | ((Buffer >>> (8 - Keta)) & 255);
}

private int RotateRight(int data, int Keta) {
    int Buffer = ((data + 255) + 1) & 255;
    return ((Buffer >>> Keta) & 255) | ((Buffer << (8 - Keta)) & 255);
}
*/
/*
- (UInt8) encrypt:(UInt16)data {
    return (byte) (RotateLeft(RotateLeft(RotateLeft(RotateLeft(data ^ this._K1, 4) ^ this._K2, 3) ^ this._K3, 5) ^ this._K4, 2) & 255);
}
*/

- (UInt16)rotateLeft:(UInt16)data withKeta:(UInt16)Keta{
    UInt16 buffer = ((data + 255) + 1) & 255;
    UInt16 tmp = ((buffer >> (8 - Keta)) & 255);
    tmp &= 0x7FFF;
    return ((buffer << Keta) & 255) | tmp;//((buffer >>> (8 - Keta)) & 255);
}

/*
- (UInt32) rotateRight:(UInt16)data withKeta:(UInt16)Keta
{
    UInt32  Buffer = ((data + 255) + 1) & 255;
    return ((Buffer >>> Keta) & 255) | ((Buffer << (8 - Keta)) & 255);
}
 */

- (UInt8)deTransfer:(UInt8)data
{
    UInt8 target = 0;
    if (data >= 10) {
        target = 'A' + data - 10;
    }else{
        target = '0' + data;
    }
    return target;
}

- (void)omronDebug:(UInt8)sel withData:(Byte *)data andLength:(UInt8)len
{
    unsigned char omBuffer[40*2+1] = {0};
    NSDictionary *debugDic = [[NSDictionary alloc] init];
    NSMutableArray *debugArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<len; i++) {
        omBuffer[2*i] = [self deTransfer:(data[i]>>4)&0x0F];
        omBuffer[2*i+1] = [self deTransfer:data[i]&0x0F];
    }
    
    NSString *stringC = [NSString stringWithUTF8String:(const char *)omBuffer];
    
    switch (sel) {
        case 1:
            [debugArray addObject:stringC];
            break;
            
        default:
            [debugArray addObject:stringC];
            break;
    }
    
    debugDic = @{
                 @"APP_OMCMD" : debugArray,
                 @"APP_OMVALUE" : debugArray
                 };
    NSLog(@"WHAT HAPPEN : %@", debugDic);
}

#if 0
- (void)arkrayHardwareInfoParser:(Byte *)akCode
{
    UInt8 akModel[ARK_MODEL_LEN];
    UInt8 akSerialNumber[ARK_SN_LEN];
    UInt8 akLastRecord[ARK_LRDT_LEN];
    UInt8 akNumber[ARK_NUMBER_LEN];
    UInt8 baseA = 0;
    UInt8 value = 0;
    memcpy(akModel, &akCode[ARK_MODEL_OFFSET], ARK_MODEL_LEN);
    memcpy(akSerialNumber, &akCode[ARK_SN_OFFSET], ARK_SN_LEN);
    memcpy(akLastRecord, &akCode[ARK_LRDT_OFFSET], ARK_LRDT_LEN);
    memcpy(akNumber, &akCode[ARK_NUMBER_OFFSET], ARK_NUMBER_LEN);
    
    
    unsigned char srcTmp[12] = {0};
#ifdef DEBUG_BW
    DLog(@"========== MODEL =======\n");
#endif
    for (int i=0; i<ARK_MODEL_LEN; i++) {
        baseA = [self numberNormalize:akModel[i]];
        value = [self numberDeCodeNEW:baseA];
        srcTmp[i] = value;
#ifdef DEBUG_BW
        DLog(@"MODEL : %02d, S = %02X, %02X \t%d\t%02X", i, akModel[i], baseA, value, srcTmp[i]);
#endif
        //[_arkModel stringByAppendingString:[_arkModel stringWithFormat:@"%d",value]];
    }
    //_arkModel = [NSString stringWithUTF8String:(const char *)srcTmp];
#ifdef DEBUG_BW
    DLog(@"ARKRAY - MODEL IS %@\n", _arkModel);
    DLog(@"============= SN ==========\n");
#endif
    for (int i=0; i<ARK_SN_LEN; i++) {
        baseA = [self numberNormalize:akSerialNumber[i]];
        value = [self numberDeCodeNEW:baseA];
        
        srcTmp[i] = value;
#ifdef DEBUG_BW
        DLog(@"SN : %02d, S = %02X %02X \t%d\t%02X", i, akSerialNumber[i], baseA, value, srcTmp[i] );
#endif
    }
    
    [H2SyncReport sharedInstance].reportMeterInfo.smSerialNumber = [NSString stringWithFormat:@"%d%d%d%d%d%d%d",srcTmp[0], srcTmp[1], srcTmp[2], srcTmp[3], srcTmp[4], srcTmp[5], srcTmp[6]];
    [h2MeterModelSerialNumber sharedInstance].smSerialNumber = [NSString stringWithFormat:@"%d%d%d%d%d%d%d",srcTmp[0], srcTmp[1], srcTmp[2], srcTmp[3], srcTmp[4], srcTmp[5], srcTmp[6]];
    
#ifdef DEBUG_BW
    DLog(@"ARKRAY 2 - SERIAL NUMBER IS %@\n", [h2MeterModelSerialNumber sharedInstance].smSerialNumber);
    DLog(@"============= LAST INDEX ==========\n");
#endif
    for (int i=2; i<6; i++) {
        baseA = [self numberNormalize:akLastRecord[i]];
        value = [self numberDeCodeNEW:baseA];
        _arkLrIndex <<= 4;
        _arkLrIndex += value;
#ifdef DEBUG_BW
        DLog(@"LST INDX: %02d, S = %02X %02X \t%d\t INDEX = %04d", i, akLastRecord[i], baseA , value, _arkLrIndex);
#endif
    }
#ifdef DEBUG_BW
    DLog(@"============= LAST RECORD ==========\n");
#endif
    for (int i=0; i<ARK_LRDT_LEN; i++) {
        baseA = [self numberNormalize:akLastRecord[i]];
        value = [self numberDeCodeNEW:baseA];
#ifdef DEBUG_BW
        DLog(@"LST : %02d, S = %02X %02X \t%d", i, akLastRecord[i], baseA , value);
#endif
    }
    
    [self arkrayRecordParser:akLastRecord];
    [H2SyncReport sharedInstance].hasSMSingleRecord = NO;
#ifdef DEBUG_BW
    DLog(@"\n");
    DLog(@"============= TOTAL NUMBER  ==========\n");
#endif
    for (int i=0; i<ARK_NUMBER_LEN; i++) {
        baseA = [self numberNormalize:akNumber[i]];
        value = [self numberDeCodeNEW:baseA];
        _arkLrTotal *= 10;
        _arkLrTotal += value;
#ifdef DEBUG_BW
        DLog(@"INDEX : %02d, S = %02X %02X \t%d \tTOTAL : %04X and %04d", i, akNumber[i], baseA , value, _arkLrTotal, _arkLrTotal);
#endif
    }
    if ([H2BleService sharedInstance].blePairingStage) {
#ifdef DEBUG_BW
        DLog(@"(CMD) UPATE-BEGIN");
#endif
        [self updateDynamicCommand];
#ifdef DEBUG_BW
        DLog(@"(CMD) UPATE-END");
#endif
    }
#ifdef DEBUG_BW
    DLog(@"\n");
#endif
}
#endif


uint16_t crc16_mcrf4xx(uint16_t crc, uint8_t *data, size_t len)
{
    if (!data || len < 0)
        return crc;
    
    while (len--) {
        crc ^= *data++;
        for (int i=0; i<8; i++) {
            if (crc & 1)  crc = (crc >> 1) ^ 0x8408;
            else          crc = (crc >> 1);
        }
    }
    return crc;
}

@end









