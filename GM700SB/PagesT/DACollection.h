//
//  DACollection.h
//  FR_W310B
//
//  Created by h2Sync on 2018/3/13.
//  Copyright © 2018年 h2Sync. All rights reserved.
//

#define NORMAL_YEAR_365                     365
#define LEAP_YEAR                       366

#define STR_YEAR_EASY                   (1970 + 30)
//#define YYY_YEAR_EASY                   1972

#import <Foundation/Foundation.h>

@interface DACollection : NSObject

@property(nonatomic, strong) NSMutableArray *arkrayGlobalArray;

- (NSString *)howToGetCurrentDateTime;
- (void)howToGetCurrentTime;

- (Byte *)systemCurrentTime;

- (void)howToWriteFile:(NSString *)headForFile;
- (void)saveDataToFile:(NSArray *)srcData withFileName:(NSString *)fileName;

- (unsigned short)crc_calculate_crc :(unsigned short)initial_crc inSrc : (const unsigned char *)buffer inLength :(unsigned short) length;

- (NSString *)dateTimeParser:(UInt32)inSecond;

+ (DACollection *)sharedInstance;
@end
