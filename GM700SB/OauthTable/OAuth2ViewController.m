//
//  OAuth2ViewController.m
//  GMSB
//
//  Created by Jason Chuang on 3/25/19.
//  Copyright © 2019 h2Sync. All rights reserved.
//

#import "OAuth2ViewController.h"

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>

@interface OAuth2ViewController ()

@end

@implementation OAuth2ViewController


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/






- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //checkInterNetStatus();
    //DLog(@"UNIX TIME STAMP = %p", NSDate.date.timeIntervalSince1970);
    double ab = 1.1;
    DLog(@"double = %f", ab);
    DLog(@"double = %d", (int)sizeof(ab));
    NSDate *now = [NSDate date];
    DLog(@"CT = %@", now);
    double xy = now.timeIntervalSince1970;
    DLog(@"Unix Time Stamp = %f", xy);
    /*
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
     dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
     dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
     
     NSDate *meterDateTime =  [[NSDate alloc]init];
     DLog(@"ST = %@", meterDateTime);
     */
    DLog(@"");
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    //[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //[dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    //NSDateFormatterLongStyle
    //NSDateFormatterFullStyle
    
    NSString *currentTime = [dateFormatter stringFromDate:today];
    //[dateFormatter release];
    DLog(@"what's the current time = %@",currentTime);
    
    double wz = today.timeIntervalSince1970;
    DLog(@"Unix Time Stamp = %f", wz);
    
    /*
     NSDate *SB = [[NSDate alloc] init];
     //#ifdef DEBUG_BP
     DLog(@"CT IS --> %@", SB);
     //#endif
     NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:SB];
     DLog(@"WHAT'S = %@", components);
     */
    /*
     NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
     [calendar setTimeZone:[NSTimeZone localTimeZone]];
     NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
     NSDate *d = [calendar dateFromComponents:dateComponents];
     DLog(@"time is = %@", d);
     */
}

/*
 Connectivity testing code pulled from Apple's Reachability Example: https://developer.apple.com/library/content/samplecode/Reachability
 */
- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if (reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // If target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // If target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs.
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

/*
 - (void) checkInterNetStatus {
 Reachability* reachability = [Reachability sharedReachability];
 [reachability setHostName:@"www.example.com"];    // Set your host name here
 NetworkStatus remoteHostStatus = [reachability remoteHostStatus];
 
 if (remoteHostStatus == NotReachable) { }
 else if (remoteHostStatus == ReachableViaWiFiNetwork) { }
 else if (remoteHostStatus == ReachableViaCarrierDataNetwork) { }
 }
 */

- (IBAction)authorizeTask:(id)sender {
    DLog(@"Authorize ...");
    NSMutableDictionary *dictService = [NSMutableDictionary dictionary];
    [dictService setObject:@"https://www.fitbit.com/oauth2/authorize" forKey:kOAuth_AuthorizeURL];
    [dictService setObject:@"https://api.fitbit.com/oauth2/token" forKey:kOAuth_TokenURL];
    
    [dictService setObject:@"22DD2F" forKey:kOAuth_ClientId];
    [dictService setObject:@"a62ee79d8e9ab5b3f6e99c6a775a16b5" forKey:kOAuth_Secret];
    [dictService setObject:@"https://fathomless-shore-18884.herokuapp.com/callback" forKey:kOAuth_Callback];
    
    [dictService setObject:@"activity heartrate location nutrition profile" forKey:kOAuth_Scope];
    
    
    
    OAuthRequestController *oauthController = [[OAuthRequestController alloc] initWithDict:dictService];
    
    oauthController.view.frame = self.view.frame;
    oauthController.delegate = self;
    [self presentViewController:oauthController animated:YES completion:^{
        //NSLog(@"go to fitbit ...");
    }];
}

- (IBAction)getUserProfileTask:(id)sender {
    DLog(@"Get User Profile ...");
}

#pragma mark - Delegate

- (void)didAuthorized:(NSDictionary *)dictResponse {
    DLog(@"AUTHORIZED ... DID ...");
    DLog(@"%@", dictResponse);
}

- (void)didGetUserProfile:(NSDictionary *)dictResponse {
    DLog(@"%@", dictResponse);
}


@end
