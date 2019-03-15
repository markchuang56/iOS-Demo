//
//  MySecurities.h
//  FR_W310B
//  作者：Joker_King
//  链接：https://www.jianshu.com/p/d1a22447cc2b
//  來源：简书
//  简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
//  Created by Jason Chuang on 2018/6/21.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySecurities : NSObject

- (NSString *)md5String:(NSString *)sourceString;//md5字符串加密
+ (NSString *)md5Data:(NSData *)sourceData;//md5data加密

+ (NSString *)base64EncodingWithData:(NSData *)sourceData;//base64加密
+ (id)base64EncodingWithString:(NSString *)sourceString;//base64解密

//@interface MySecurities : NSObject

+ (MySecurities *)sharedInstance;

@end


