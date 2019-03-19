//
//  ViewController.m
//  demo-pod
//
//  Created by Jason Chuang on 3/18/19.
//  Copyright © 2019 Jason Chuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
//#import "Reachability/Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>

//#import "Reachability.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //checkInterNetStatus();
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
