//
//  ViewController.m
//  demo-pod
//
//  Created by Jason Chuang on 3/18/19.
//  Copyright © 2019 Jason Chuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>



@interface ViewController () {
    NSString *strUserid;
    NSString *strRreshToken;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fitbitTokenTask:) name:@"TOKEN_BACK" object:nil];
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


- (IBAction)authorizeTask:(id)sender {
    _tokenTextView.text = [NSString stringWithFormat:@"..."];
    DLog(@"Authorize ...");
    NSMutableDictionary *dictService = [NSMutableDictionary dictionary];
    [dictService setObject:@"https://www.fitbit.com/oauth2/authorize" forKey:kOAuth_AuthorizeURL];
    [dictService setObject:@"https://api.fitbit.com/oauth2/token" forKey:kOAuth_TokenURL];
    
    // health2sync Cleint ID, Secret, Call back Address
    [dictService setObject:@"22DCQD" forKey:kOAuth_ClientId];
    [dictService setObject:@"581a9e35b556660236ec84d13acebe31" forKey:kOAuth_Secret];
    [dictService setObject:@"https://www.health2sync.com/fitbit_cb" forKey:kOAuth_Callback];
    /*
     // demo use
    [dictService setObject:@"22DD2F" forKey:kOAuth_ClientId];
    [dictService setObject:@"a62ee79d8e9ab5b3f6e99c6a775a16b5" forKey:kOAuth_Secret];
    [dictService setObject:@"https://fathomless-shore-18884.herokuapp.com/callback" forKey:kOAuth_Callback];
    */
    
    [dictService setObject:@"activity heartrate location nutrition profile" forKey:kOAuth_Scope];
    
    
    
    OAuthRequestController *oauthController = [[OAuthRequestController alloc] initWithDict:dictService];
    
    oauthController.view.frame = self.view.frame;
    oauthController.delegate = self;
    [self presentViewController:oauthController animated:YES completion:^{
        //NSLog(@"go to fitbit web ...");
    }];
}

- (IBAction)getUserProfileTask:(id)sender {
    DLog(@"Get User Profile ...");
}


- (void)fitbitTokenTask:(id)sender {
    _labelUserId.text = strUserid;
    _labelExpiry.text = strRreshToken;
    DLog(@"FITBIT TOKEN BACK!!");
}
#pragma mark - Delegate

- (void)didAuthorized:(NSDictionary *)dictResponse {
    DLog(@"AUTHORIZED ... DID ...");
}

- (void)didGetUserProfile:(NSDictionary *)dictResponse {
    // Store the dictionary(access token) to server
    DLog(@"Profile come back ...");
    DLog(@"%@", dictResponse);
    //DLog(@"%@", [dictResponse objectForKey:@"kOAuth_AccessToken"]);
    
    NSString *tmpToken = [dictResponse objectForKey:@"kOAuth_AccessToken"];
    long len = tmpToken.length;
    DLog(@"THE LEN is = %ld", len);
    NSString *strTmp = [dictResponse objectForKey: @"kOAuth_UID"];
    strUserid = [NSString stringWithFormat:@"%@", strTmp];
    strRreshToken = [dictResponse objectForKey: @"kOAuth_RefreshToken"];
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"TOKEN_BACK" object:self];
}


@end
