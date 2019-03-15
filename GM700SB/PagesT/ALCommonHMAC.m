//
//  ALCommonHMAC.m
//  mFind
//
//  As discussed in http://stackoverflow.com/questions/756492/objective-c-sample-code-for-hmac-sha1
//
//  Created by James Laurenstin on 2015-15-09.
//  Copyright (c) 2015 Aldo Group Inc. All rights reserved.
//

#import "ALCommonHMAC.h"

@implementation ALCommonHMAC

+ (NSString *)hmacSHA1:(NSString *)data withKey:(NSString *)key {
    
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [ALCommonHMAC base64forData:hash];
}

+ (NSString *)hmacSHA256:(NSString*)data withKey:(NSString *)key {
    
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [ALCommonHMAC base64forData:hash];
}

+ (NSString *)base64forData:(NSData *)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {  value |= (0xFF & input[j]);  }  }  NSInteger theIndex = (i / 3) * 4;  output[theIndex + 0] = table[(value >> 18) & 0x3F];
        output[theIndex + 1] = table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    // 3LFNjTLbGk5QqWVoypl8S2wAYcSL586E285
    //2BHlCpVX8Qgdw5Djfw0W30s7pfrY
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
