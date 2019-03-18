//
//  ViewController.m
//  demo-pod
//
//  Created by Jason Chuang on 3/18/19.
//  Copyright © 2019 Jason Chuang. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


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

@end
