//
//  LROAuth2AccessToken.m
//  LROAuth2Client
//
//  Created by Luke Redpath on 14/05/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "LROAuth2AccessToken.h"

@interface LROAuth2AccessToken ()
@property (nonatomic, copy) NSDictionary *authResponseData;
- (void)extractExpiresAtFromResponse;
@end

#pragma mark -

@implementation LROAuth2AccessToken

@dynamic accessToken;
@dynamic refreshToken;
@synthesize authResponseData;
@synthesize expiresAt;

//@dynamic expiresIn;
@dynamic tokenType;
//@synthesize unixTimeStamp;
@dynamic unixTimeStamp;


- (id)initWithAuthorizationResponse:(NSDictionary *)data;
{
    if (self = [super init]) {
        authResponseData = [data copy];
        NSLog(@"RESPONSE DATA = %@", authResponseData);
        [self extractExpiresAtFromResponse];
    }
    return self;
}


- (NSString *)description;
{
    return [NSString stringWithFormat:@"<LROAuth2AccessToken token:%@ expiresAt:%@>", self.accessToken, self.expiresAt];
}

- (BOOL)hasExpired;
{
    return ([[NSDate date] earlierDate:expiresAt] == expiresAt);
}

- (void)refreshFromAuthorizationResponse:(NSDictionary *)data;
{
    DLog(@"refresh ...");
    DLog(@"REF = %@", data);
    NSMutableDictionary *tokenData = [self.authResponseData mutableCopy];
    
    [tokenData setObject:[data valueForKey:@"access_token"] forKey:@"access_token"];
    [tokenData setObject:[data objectForKey:@"expires_in"]  forKey:@"expires_in"];
    
    [self setAuthResponseData:tokenData];
    [self extractExpiresAtFromResponse];
}

- (void)extractExpiresAtFromResponse
{
    DLog(@"extract Expires At From Response");
    DLog(@"The EXPIRY = %d", [[self.authResponseData objectForKey:@"expires_in"] intValue]);
    NSTimeInterval expiresIn = (NSTimeInterval)[[self.authResponseData objectForKey:@"expires_in"] intValue];
    expiresAt = [[NSDate alloc] initWithTimeIntervalSinceNow:expiresIn];
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    
    NSString *currentTime = [dateFormatter stringFromDate:today];
    DLog(@"what's the current time = %@",currentTime);
    
    double wz = today.timeIntervalSince1970;
    DLog(@"fmt Unix Time Stamp = %f", wz);
    DLog(@"fmt Unix Time Stamp = %f", wz + [[self.authResponseData objectForKey:@"expires_in"] intValue]);
    wz += [[self.authResponseData objectForKey:@"expires_in"] intValue];
    NSString *myString = [NSString stringWithFormat:@"%f", wz];
    DLog(@"VAL = %@", myString);
    //NSString *subTime = [myString substringWithRange:NSMakeRange(0, 10)];
    //self.expiresIn = [myString substringWithRange:NSMakeRange(0, 10)];
    //DLog(@"SUB TIME is = %@", expiresIn);
    unixTimeStamp = [myString substringWithRange:NSMakeRange(0, 10)];
}

#pragma mark -
#pragma mark Dynamic accessors

- (NSString *)accessToken;
{
    return [authResponseData objectForKey:@"access_token"];
}

- (NSString *)refreshToken;
{
    return [authResponseData objectForKey:@"refresh_token"];
}

/*
- (NSString *)expiresIn
{
    return [authResponseData objectForKey:@"expires_in"];
}
 */

- (NSString *)tokenType
{
    return [authResponseData objectForKey:@"token_type"];
}

- (NSString *)unixTimeStamp
{
    return unixTimeStamp;
}



//kOAuth_UnixTimeStamp

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:authResponseData forKey:@"data"];
    [aCoder encodeObject:expiresAt forKey:@"expiresAt"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        authResponseData = [[aDecoder decodeObjectForKey:@"data"] copy];
        expiresAt = [aDecoder decodeObjectForKey:@"expiresAt"];
    }
    return self;
}

@end
