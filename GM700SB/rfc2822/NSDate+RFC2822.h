//
//  NSDate+RFC2822.h
//  Attend
//
//  Created by OOBE on 13/1/2.
//  Copyright (c) 2013年 OOBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RFC2822)

+ (NSDateFormatter*)rfc2822Formatter;
+ (NSDate *)dateFromRFC2822:(NSString *)rfc2822;

@end
