//
//  NSURL+QueryInspector.m
//  demo-pod
//
//  Created by Jason Chuang on 3/18/19.
//  Copyright © 2019 Jason Chuang. All rights reserved.
//

#import "NSURL+QueryInspector.h"
#import "NSDictionary+QueryString.h"

@implementation NSURL (QueryInspector)

- (NSDictionary *)queryDictionary;
{
    return [NSDictionary dictionaryWithFormEncodedString:self.query];
}

@end
