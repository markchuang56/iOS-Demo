//
//  NSString+QueryString.h
//  demo-pod
//
//  Created by Jason Chuang on 3/18/19.
//  Copyright © 2019 Jason Chuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (QueryString)

- (NSString *)stringByEscapingForURLQuery;
- (NSString *)stringByUnescapingFromURLQuery;

@end

NS_ASSUME_NONNULL_END
