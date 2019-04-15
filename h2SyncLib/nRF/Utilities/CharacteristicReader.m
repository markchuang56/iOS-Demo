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

#import "CharacteristicReader.h"
#import "H2DebugHeader.h"

@implementation CharacteristicReader

+ (UInt8)readUInt8Value:(uint8_t **)p_encoded_data
{
    return *(*p_encoded_data)++;
}

+ (SInt8)readSInt8Value:(uint8_t **)p_encoded_data
{
    return *(*p_encoded_data)++;
}

+ (UInt16)readUInt16Value:(uint8_t **)p_encoded_data
{
    UInt16 value = (UInt16) CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    *p_encoded_data += 2;
    return value;
}

+ (SInt16)readSInt16Value:(uint8_t **)p_encoded_data
{
    SInt16 value = (SInt16) CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    *p_encoded_data += 2;
    return value;
}

+ (UInt32)readUInt32Value:(uint8_t **)p_encoded_data
{
    UInt32 value = (UInt16) CFSwapInt32LittleToHost(*(uint32_t*)*p_encoded_data);
    *p_encoded_data += 4;
    return value;
}

+ (SInt32)readSInt32Value:(uint8_t **)p_encoded_data
{
    SInt32 value = (SInt32) CFSwapInt32LittleToHost(*(uint32_t*)*p_encoded_data);
    *p_encoded_data += 4;
    return value;
}

+ (UInt16)readSFloatValueUA651Ble:(uint8_t **)p_encoded_data
{
    UInt16 tempData = (UInt16) CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    return tempData;
}

+ (UInt16)readSFloatValueApex:(uint8_t **)p_encoded_data
{
    UInt16 tempData = (UInt16) CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    UInt16 mantissa = (UInt16)(tempData & 0xFFFF);
        *p_encoded_data += 2;
    return mantissa;
}

+ (Float32)readSFloatValue:(uint8_t **)p_encoded_data
{
    SInt16 tempData = (SInt16) CFSwapInt16LittleToHost(*(uint16_t*)*p_encoded_data);
    SInt8 exponent = (SInt8)(tempData >> 12);
    if (exponent > 8) {
        exponent = -((0x0F + 1) - exponent);
    }
    SInt16 mantissa = (SInt16)(tempData & 0x0FFF);
    *p_encoded_data += 2;
    return (Float32)(mantissa * pow(10, exponent));
}



+(Float32)readFloatValue:(uint8_t **)p_encoded_data
{
    SInt32 tempData = (SInt32) CFSwapInt32LittleToHost(*(uint32_t*)*p_encoded_data);
    SInt8 exponent = (SInt8)(tempData >> 24);
    SInt32 mantissa = (SInt32)(tempData & 0x00FFFFFF);
    *p_encoded_data += 4;
    return (Float32)(mantissa * pow(10, exponent));
}

+(NSString *)readDateTimeApex :(uint8_t **)p_encoded_data withTimeOffset:(BOOL)hasTimeOffset
{
    uint16_t year = [CharacteristicReader readUInt16Value:p_encoded_data];
    uint8_t month = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t day = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t hour = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t min = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t sec = [CharacteristicReader readUInt8Value:p_encoded_data];
    
    // OFFSET PROCESS
    SInt16 timeOffset = 0;
    if (hasTimeOffset) {
        timeOffset = [CharacteristicReader readSInt16Value:p_encoded_data];
    }
    
#ifdef DEBUG_NRF
    DLog(@"BG TIME OFFSET %d", timeOffset);
#endif
    
    SInt16 timeSrc = hour * 60 + min;
    SInt16 totalMin = timeSrc + timeOffset;
    
    UInt8 dayOffset = 0;
    BOOL positive = YES;
    if (totalMin >= 0) {
        while (totalMin > 1440 ) {
            totalMin -= 1440;
            dayOffset++;
        }
    }else{
        positive = NO;
        while (totalMin < 0 ) {
            totalMin += 1440;
            dayOffset++;
        }
    }
    
    
    hour = ((UInt16)totalMin) / 60;
    min = ((UInt16)totalMin) % 60;
    if (positive) {
        

        day += dayOffset;
        if (((month%2) && month < 8) || (!(month%2) && month >= 8)) {  // Jan // 3, 5, 7, 8, 10, 12
            if (day > 31) {
                day -= 31;
                month++;
                if (month > 12) {
                    month = 1;
                    year++;
                }
            }
        }else if (month == 2 ){ // Feb
            if (year%4) {
                if (day > 28) {
                    day -= 28;
                    month++;
                }
            }else{
                if (day > 29) {
                    day -= 29;
                    month++;
                }
            }
            
        }else{ // the others // 4, 6, 9, 11
            if (day > 30) {
                day -= 30;
                month++;
            }
        }
    }else{
        if (day > dayOffset) {
            day -= dayOffset;
        }else{
            if (((month%2) && month < 8) || (!(month%2) && month >= 8)) {  // Jan // 3, 5, 7, 8, 10, 12
                if (month == 1) {
                    month = 12;
                    day = (day + 31 - dayOffset);
                    year--;
                    
                }else if (month == 8){
                    month--;
                    day = (day + 31 - dayOffset);
                }else if (month == 3){
                    month--;
                    if (year%4) {
                        day = (day + 28 - dayOffset);
                    }else{
                        day = (day + 29 - dayOffset);
                    }
                    
                }else{
                    month--;
                    day = (day + 30 - dayOffset);
                    
                }
            }else{ // Feb // the others // 4, 6, 9, 11
                month--;
                day = (day + 31 - dayOffset);
            }
        }
        
    }
/*
    if (totalMin >= 0) {
        if (totalMin > 1440) {
            totalMin -= 1440;
            hour = ((UInt16)totalMin) / 60;
            min = ((UInt16)totalMin) % 60;
            
            day++;
            if ((!(month%2) && month < 8) || ((month%2) && month >= 8)) {  // Jan // 3, 5, 7, 8, 10, 12
                if (day > 31) {
                    day = 1;
                    month++;
                    if (month > 12) {
                        month = 1;
                        year++;
                        
                    }
                }
            }else if (month == 2 ){ // Feb
                if (year%4) {
                    if (day > 28) {
                        day = 1;
                        month++;
                    }
                }else{
                    if (day > 29) {
                        day = 1;
                        month++;
                    }
                }
                
            }else{ // the others // 4, 6, 9, 11
                if (day > 30) {
                    day = 1;
                    month++;
                }
                
            }
        }else{
            hour = ((UInt16)totalMin) / 60;
            min = ((UInt16)totalMin) % 60;
        }
    }else{
        totalMin += 1440; // borrow 1 day
        hour = ((UInt16)totalMin) / 60;
        min = ((UInt16)totalMin) % 60;
        if (day == 1 ) {
            if ((!(month%2) && month < 8) || ((month%2) && month >= 8)) {  // Jan // 3, 5, 7, 8, 10, 12
                if (month == 1) {
                    month = 12;
                    day = 31;
                    year--;
                    
                }else if (month == 3){
                    month--;
                    if (year%4) {
                        day = 28;
                    }else{
                        day = 29;
                    }
                
                }else{
                    month--;
                    day = 30;
                }
            }else{ // Feb // the others // 4, 6, 9, 11
                month--;
                day = 31;
            }
            
        }else{
            day--;
        }
        
    }
*/
    
//    NSString * dateString = [NSString stringWithFormat:@"%d %d %d %d %d %d", year, month, day, hour, min, sec];
    NSString * dateString = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000",year, month, day, hour, min, sec];
    if (hasTimeOffset) {
        *p_encoded_data -= 9;
    }else{
        *p_encoded_data -= 7;
    }
    
    return dateString;
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat: @"yyyy MM dd HH mm ss"];
//    return  [dateFormat dateFromString:dateString];
}
+(NSDate *)readDateTime:(uint8_t **)p_encoded_data
{
    uint16_t year = [CharacteristicReader readUInt16Value:p_encoded_data];
    uint8_t month = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t day = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t hour = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t min = [CharacteristicReader readUInt8Value:p_encoded_data];
    uint8_t sec = [CharacteristicReader readUInt8Value:p_encoded_data];
    
//    _charDateTimeString = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000",year, month, day, hour, min, sec];
    
    NSString * dateString = [NSString stringWithFormat:@"%d %d %d %d %d %d", year, month, day, hour, min, sec];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy MM dd HH mm ss"];
    return  [dateFormat dateFromString:dateString];
}

+(Nibble)readNibble:(uint8_t **)p_encoded_data
{
    Nibble nibble;
    nibble.value = [CharacteristicReader readUInt8Value:p_encoded_data];
    
    return nibble;
}

@end
