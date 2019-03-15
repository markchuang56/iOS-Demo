/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "BGMItemCell.h"




@implementation BGMItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.contentView.frame = CGRectMake(0, 0, 218, 54);
//        self.contentView.sizeToFit;
        
//        self.contentSize = (320, 660);
//        contentOffset: {0, 0}; contentSize: {320, 6600
//        type = [[UILabel alloc] init];
        _value = [[UILabel alloc] init];
        _timestamp = [[UILabel alloc] init];
        
        _type = [[UILabel alloc] init];
        
        _timestamp.frame = CGRectMake(8, 8, 148, 21);
        
        [_timestamp setFont:[UIFont fontWithName:@"System" size:17]];
        
        [_timestamp setBackgroundColor:[UIColor whiteColor]];
        [_timestamp setTextColor:[UIColor redColor]];
        
        [_timestamp.layer setMasksToBounds:YES];
        [_timestamp.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [_timestamp.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        
//        timestamp.text = (NSString *)lableString[lableIndex];
        
        [self.contentView addSubview:_timestamp];
        
        _value.frame = CGRectMake(164, 9, 66, 38);
        
        [_value setFont:[UIFont fontWithName:@"System" size:36]];
        
        [_value setBackgroundColor:[UIColor whiteColor]];
        [_value setTextColor:[UIColor redColor]];
        
        [_value.layer setMasksToBounds:YES];
        [_value.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [_value.layer setBorderWidth:1.0]; //边框宽度
        
        [self.contentView addSubview:_value];
        
        _type.frame = CGRectMake(8, 26, 148, 21);
        
        [_type setFont:[UIFont fontWithName:@"System" size:17]];
        
        [_type setBackgroundColor:[UIColor whiteColor]];
        [_type setTextColor:[UIColor redColor]];
        
        [_type.layer setMasksToBounds:YES];
        [_type.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [_type.layer setBorderWidth:1.0]; //边框宽度
        //    [moreButton.backgroundColor = [UIColor clearColor];
        
        
        //        timestamp.text = (NSString *)lableString[lableIndex];
        _type.text = @"haha";
        [self.contentView addSubview:_type];
    }
    return self;
}






- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
