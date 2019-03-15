//
//  ALCommonHMAC.h
//
//  As discussed in http://stackoverflow.com/questions/756492/objective-c-sample-code-for-hmac-sha1
//
//  Created by James Laurenstin on 2015-15-09.
//  Copyright (c) 2015 Aldo Group Inc. All rights reserved.
//
//

#import <CommonCrypto/CommonHMAC.h>
#import <Foundation/Foundation.h>

@interface ALCommonHMAC : NSObject

+ (NSString *)hmacSHA1:(NSString *)data withKey:(NSString *)key;
+ (NSString *)hmacSHA256:(NSString *)data withKey:(NSString *)key;
+ (NSString *)base64forData:(NSData *)theData;

@end

