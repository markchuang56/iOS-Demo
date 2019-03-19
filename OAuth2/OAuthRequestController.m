//
//  OAuthRequestController.m
//  LROAuth2Demo
//
//  Created by Luke Redpath on 01/06/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//
// Edited by Trong Dinh

#import "OAuthRequestController.h"
#import "LROAuth2Client.h"
#import "LROAuth2AccessToken.h"
#import "Validations.h"

/*
 * you will need to create this from OAuthCredentials-Example.h
 *
 */

@implementation OAuthRequestController

@synthesize webView;

#pragma mark - init

- (id)initWithDict:(NSDictionary *)dict {
    DLog(@"init with dict ...");
    if (self = [super initWithNibName:@"OAuthRequestController" bundle:[NSBundle bundleForClass:[OAuthRequestController class]]]) {
        oauthClient = [[LROAuth2Client alloc] initWithClientID:[dict objectForKey:kOAuth_ClientId]
                                                        secret:[dict objectForKey:kOAuth_Secret]
                                                   redirectURL:[NSURL URLWithString:[dict objectForKey:kOAuth_Callback]]];
        
        oauthClient.userURL  = [NSURL URLWithString:[dict objectForKey:kOAuth_AuthorizeURL]];
        oauthClient.tokenURL = [NSURL URLWithString:[dict objectForKey:kOAuth_TokenURL]];
        oauthClient.scope = [dict objectForKey:kOAuth_Scope];
        
        [self initObj];
        _dictValues = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    
    return self;
}

- (void)initObj {
    DLog(@"web INIT OBJ (lib)");
    oauthClient.debug = YES;
    oauthClient.delegate = self;
    
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    self.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
}

#pragma mark - view life cycle


- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"show fitbit register dialog");
    [super viewDidAppear:animated];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"touch" forKey:@"display"];
    [oauthClient authorizeUsingWebView:self.webView additionalParameters:params];
}

- (void)dealloc
{
    DLog(@"web did DEALLOC");
    oauthClient.delegate = nil;
    webView.delegate = nil;
}

- (void)refreshAccessToken:(LROAuth2AccessToken *)accessToken
{
    [oauthClient refreshAccessToken:accessToken];
}

- (void)getDefaultUserProfile:(LROAuth2AccessToken *)accessToken
{
    [oauthClient getDefaultUserProfile:accessToken];
}



#pragma mark - === SEND BACK OAuth2 DATA ===
- (void)sendBackOAuth2Data:(LROAuth2AccessToken *)client {
    if ([_delegate respondsToSelector:@selector(didAuthorized:)]) {
        [_dictValues setObject:VALID(client.accessToken, NSString)?client.accessToken:@"" forKey:kOAuth_AccessToken];
        [_dictValues setObject:VALID(client.refreshToken, NSString)?client.refreshToken:@"" forKey:kOAuth_RefreshToken];
        [_dictValues setObject:VALID(client.expiresAt, NSDate)?client.expiresAt:@"" forKey:kOAuth_ExpiredDate];
        
        [_delegate didAuthorized:_dictValues];
    }
}

- (void)sendBackUserProfileData:(NSString *)uid {
    
    
    NSDictionary *userData = [[NSDictionary alloc] init];
    userData = @{
        //@"kOAuth_UID": uid,
        @"kOAuth_AccessToken": [_dictValues objectForKey:@"kOAuth_AccessToken"],
        //@"kOAuth_UID": uid,
        @"kOAuth_RefreshToken": [_dictValues objectForKey:@"kOAuth_RefreshToken"],
        @"kOAuth_ExpiredDate": [_dictValues objectForKey:@"kOAuth_ExpiredDate"],
        @"kOAuth_UID": uid,
    };
    
    
    if ([_delegate respondsToSelector:@selector(didGetUserProfile:)]) {
        [_delegate didGetUserProfile:userData];
    }
}

#pragma mark - IBAction methods

- (IBAction)btnCancelTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(didCancel)]) {
        DLog(@"button Cancel Touched");
        [_delegate didCancel];
        
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            DLog(@"dismiss view controller");
        }];
    }
}

#pragma mark -
#pragma mark LROAuth2ClientDelegate methods

- (void)oauthClientDidReceiveAccessToken:(LROAuth2Client *)client
{
    DLog(@"--- Did Receive Access Token ---");
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthReceivedAccessTokenNotification" object:client.accessToken];
    [self sendBackOAuth2Data:client.accessToken];
    
    // H2-DEBUG
    //[self btnCancelTouched:nil];
    
    [self getDefaultUserProfile:client.accessToken];
}

- (void)oauthClientDidRefreshAccessToken:(LROAuth2Client *)client
{
    DLog(@"--- Did Refresh Access Token ---");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OAuthRefreshedAccessTokenNotification" object:client.accessToken];
    [self sendBackOAuth2Data:client.accessToken];
    
    [self btnCancelTouched:nil];
}

- (void)oauthClientDidReceiveUserProfile:(NSString *)uid
{
    [self sendBackUserProfileData:uid];
    [self btnCancelTouched:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [indicator stopAnimating];
    return YES;
}

@end
