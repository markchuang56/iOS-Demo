//
//  version.h
//  H2 LIB
//
//  Created by JasonChuang on 13/1/16.
//  Copyright (c) 2013年 JasonChuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myVersion : NSObject
- (NSString *)libVersion;

@end


/*
 // Debug
 #ifdef DEBUG
 #define DLog(...) NSLog(@"%s (%d) %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
 #else
 #define DLog(...)
 #endif
 
 */
