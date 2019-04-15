//
//  Fora.m
//  h2SyncLib
//
//  Created by h2Sync on 2015/12/9.
//  Copyright © 2015年 h2Sync. All rights reserved.
//


#define WG_YEAR_AT              4
#define WG_MONTH_AT             5
#define WG_DAY_AT               6

#define WG_HOUR_AT              7
#define WG_MIN_AT               8

#define WG_USER_ID_AT           9
#define WG_GENDER_AT            10

#define WG_CM_AT                11
#define WG_INCH_AT              12

#define WG_AGE_AT               14
#define WG_UNIT_AT              15

#define WG_KG_AT                16
#define WG_LB_AT                18


#define WG_BMI_AT              20

#import "H2BleEquipId.h"
#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "Fora.h"
#import "ForaW310.h"


#import "H2AudioFacade.h"
#import "H2Sync.h"
#import "H2DataFlow.h"
#import "H2Records.h"

#import "H2AudioHelper.h"
#import "H2Report.h"


#import "H2Config.h"
#import "H2Omron.h"
#import "H2LastDateTime.h"

@interface ForaW310()
{
    UInt16 foraW310RecordIndex;
}

@end


@implementation ForaW310




- (id)init
{
    if (self = [super init]) {

    }
    return self;
}



+ (ForaW310 *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}




/*
 // 61.6 22.0 F
 Y   M   D   H
 51  71  1D  15    10  0B  12  12
 min ID  F   cm     inch   age unit
 21  04  00  A7    02 91   1D  00
 Kg     lb     BMI
 02 68  05 4E  00 DC  00 00
 
 00 00 00 00  00 00 00 00
 
 A5
 ED
 */




/*
 // W310B Record Example:
 // 61.6 22.0 F
 Y   M   D   H
 51  71  1D  15    10  0B  12  12
 min ID  F   cm     inch   age unit
 21  04  00  A7    02 91   1D  00
 Kg     lb     BMI
 02 68  05 4E  00 DC  00 00
 
 00 00 00 00  00 00 00 00
 
 A5
 ED
 
 
 @property (nonatomic, unsafe_unretained) UInt8 bwUserId;
 @property (nonatomic, unsafe_unretained) NSString *bwGender; //Gender. Female = 0, Male =1
 @property (nonatomic, unsafe_unretained) float bwHeightInCm;
 @property (nonatomic, unsafe_unretained) float bwHeightInInch;
 @property (nonatomic, unsafe_unretained) UInt8 bwAge;
 @property (nonatomic, unsafe_unretained) UInt8 bwUnit; // Kg=0, lb=1, st=2
 
 @property (nonatomic, unsafe_unretained) float bwKg;
 @property (nonatomic, unsafe_unretained) float bwLb;
 @property (nonatomic, unsafe_unretained) float bwBmi;
 
 */

- (H2BwRecord *)recordBwParser
{
    UInt16 length = [H2AudioAndBleSync sharedInstance].dataLength;
    Byte *srcData;
    srcData = (Byte *)malloc(W310B_DATA_LEN);
    if (length <= W310B_DATA_LEN) {
        memcpy(srcData, [H2AudioAndBleSync sharedInstance].dataBuffer, length);
    }
    
#ifdef DEBUG_FORA
    for (int i=0; i<length; i++) {
//        DLog(@"DEBUG_FORA VAL index:%02d and Data:%02X", i, srcData[i]);
    }
#endif
    
    UInt16 wYear = srcData[WG_YEAR_AT];
    wYear +=2000;
    
    UInt8 wMon = srcData[WG_MONTH_AT];
    UInt8 wDay = srcData[WG_DAY_AT];
    
    UInt8 wHour = srcData[WG_HOUR_AT];
    UInt8 wMinute = srcData[WG_MIN_AT];
    
    H2BwRecord *bwRecord;
    bwRecord = [[H2BwRecord alloc] init];
    
    [H2Omron sharedInstance].bwFlag = 'N';
    
    if (srcData[WG_YEAR_AT] == 255) {
        [H2Omron sharedInstance].bwFlag = 'C';
        DLog(@"ERROR ==== YEAR");
    }
    
    // Because Shift, 2,3,4,5,6
    UInt8 wUserId = srcData[WG_USER_ID_AT];
    
    if (wUserId >= 2 && wUserId <= 6) {
        wUserId--;
    }else{
        //bwRecord.bwIsSomeThing = NO;
        [H2Omron sharedInstance].bwFlag = 'C';
        DLog(@"BW IS NOTHING");
    }
    
    UInt8 crcTmp = 0;
    for (int i=0; i<W310B_DATA_LEN-1; i++) {
        crcTmp += srcData[i];
    }
    
    if (crcTmp != srcData[W310B_DATA_LEN-1]) {
        [H2Omron sharedInstance].bwFlag = 'C';
    }
    
    DLog(@"BW IS HOW HOW %02X, %02X CRC ====", srcData[W310B_DATA_LEN-1], crcTmp);
    
    NSString *measureTime = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:00 +0000",wYear, wMon, wDay, wHour, wMinute];
    
    
    UInt8 wCm = srcData[WG_CM_AT];
    NSString *bHeightCm = [NSString stringWithFormat:@"%d.00",wCm];
    //float wInch = (float)((srcData[WG_INCH_AT] << 8) + srcData[WG_INCH_AT+1]);
    UInt16 wInch = (srcData[WG_INCH_AT] << 8) + srcData[WG_INCH_AT+1];
    NSString *bHeightInch = [NSString stringWithFormat:@"%d.%d",wInch/10, wInch%10];
    
    UInt8 wAge= srcData[WG_AGE_AT];
    UInt8 wUnit = srcData[WG_UNIT_AT];
#if 1
     UInt16 wKg = (srcData[WG_KG_AT] << 8) + srcData[WG_KG_AT + 1];
     UInt16 wLb = (srcData[WG_LB_AT] << 8) + srcData[WG_LB_AT + 1];
     
     UInt16 wBmi = (srcData[WG_BMI_AT] << 8)+ srcData[WG_BMI_AT + 1];
#else
    float wKg = (float)((srcData[WG_KG_AT] << 8) + srcData[WG_KG_AT + 1]);
    float wLb = (float)((srcData[WG_LB_AT] << 8) + srcData[WG_LB_AT + 1]);
    
    float wBmi = (float)((srcData[WG_BMI_AT] << 8)+ srcData[WG_BMI_AT + 1]);
#endif
    
#ifdef DEBUG_FORA
    UInt8 wGender = srcData[WG_GENDER_AT];
    
    DLog(@"WG -- %4d YEAR", wYear);
    DLog(@"WG -- %4d MONTH", wMon);
    DLog(@"WG -- %4d DAY", wDay);
    
    DLog(@"WG -- %4d HOUR", wHour);
    DLog(@"WG -- %4d MINUTE", wMinute);
    
    DLog(@"WG -- %d USER ID", wUserId);
    DLog(@"WG -- %d GENDER", wGender);
    
    
    
    DLog(@"WG -- %@ CM", bHeightCm);
    DLog(@"WG -- %@ INCH", bHeightInch);
    //DLog(@"WG -- %f CM", wCm);
    //DLog(@"WG -- %f INCH", (float)wInch/10);
    DLog(@"WG -- %d AGE", wAge);
    
    DLog(@"WG -- %d UNIT", wUnit);
    DLog(@"WG -- %d.%d KG", wKg/10, wKg%10);
    DLog(@"WG -- %d.%d LB", wLb/10, wLb%10);
    
    DLog(@"WG -- %d.%d BMI", wBmi/10, wBmi%10);
    
    
    DLog(@"WG DATE-TIME IS %4d-%02d-%02d %02d:%02d:00 +0000",wYear, wMon, wDay, wHour, wMinute);
#endif
    
    
    
    bwRecord.meterUserId = wUserId;
#ifdef DEBUG_FORA
    DLog(@"W310 USER ID %02X SRC", bwRecord.meterUserId);
#endif
    bwRecord.recordType = RECORD_TYPE_BW;
    bwRecord.bwDateTime = [[NSString alloc] initWithFormat:@"%@",measureTime];
    if (wUnit > 0) {
        if (wUnit > 1) {
            bwRecord.bwUnit = @"N";//@"st";
        }else{
            bwRecord.bwUnit = BW_UNIT_LB;
            bwRecord.bwWeight  = [[NSString alloc] initWithFormat:@"%d.%d",wLb/10, wLb%10];//@"%.2f",wLb/10];
        }
    }else{
        bwRecord.bwUnit = BW_UNIT;
        bwRecord.bwWeight  = [[NSString alloc] initWithFormat:@"%d.%d",wKg/10, wKg%10];//@"%.2f",wKg/10];
    }
    
    bwRecord.bwAge = wAge;
    
    bwRecord.bwBmi  = [[NSString alloc] initWithFormat:@"%d.%d",wBmi/10, wBmi%10];
    
    bwRecord.bwHeightCm = bHeightCm;
    bwRecord.bwHeightInch = bHeightInch;
    
    return bwRecord;
}







- (void)foraW310BSetUserProfile:(UInt8)userId
{
    //[[H2Omron sharedInstance] omronClearSerialNumberTimer];
    UInt8 cmdBuffer[12] = {0};
    cmdBuffer[0] = FORA_CMD_HEADER;
    cmdBuffer[1] = FORA_CMD_PROFILE; // Write Profile
    cmdBuffer[2] = FORA_PROFILE_LEN; // Data Length
    
    cmdBuffer[10] = FORA_CMD_STOP;
#ifdef DEBUG_FORA
    DLog(@"FORA-W310 USER SEL = %02X", userId);
#endif
    switch (userId) {
        case USER_TAG1_MASK:
            cmdBuffer[3] = 0x01;
            break;
            
        case USER_TAG2_MASK:
            cmdBuffer[3] = 0x02;
            break;
            
        case USER_TAG3_MASK:
            cmdBuffer[3] = 0x03;
            break;
            
        case USER_TAG4_MASK:
            cmdBuffer[3] = 0x04;
            break;
            
        case USER_TAG5_MASK:
            cmdBuffer[3] = 0x05;
            break;
            
        default:
#ifdef DEBUG_FORA
            DLog(@"Cancel Proceess ....");
#endif
            return;
    }
    
#ifdef DEBUG_FORA
    //DLog(@"FORA W310B 公分          = %02X");
    //DLog(@"FORA W310B INCH        = %02X");
#endif
    
    cmdBuffer[4] = [H2Omron sharedInstance].tmpUserProfile.uGender;
    
    cmdBuffer[5] = 0x05;
    
    cmdBuffer[6] = 0x05;
    cmdBuffer[7] = 0x05;
    
    cmdBuffer[8] = (UInt8)([H2Omron sharedInstance].tmpUserProfile.uBirthYear -1900);
    
    
    for (int i = 0; i<11; i++) {
        cmdBuffer[11]  += cmdBuffer[i];
    }

}


#pragma mark - ### W310 W310 PROCESS

- (BOOL)foraW310BRecordProcess
{
    [H2Records sharedInstance].bwTmpRecord = [[ForaW310 sharedInstance] recordBwParser];
    
    DLog(@"BW DATA %@", [H2Records sharedInstance].bwTmpRecord );
    //k [Fora sharedInstance].foraCmdBuffer[CMD_AT] = FORA_CMD_THERMO; // Command ID
    [Fora sharedInstance].foraCmdNext = FORA_CMD_THERMO;
    [Fora sharedInstance].foraCmdBuffer[2] = W310_CMD_LEN;
    [Fora sharedInstance].cmdIndex++;
    //memcpy(&[Fora sharedInstance].foraCmdBuffer[3], &([Fora sharedInstance].cmdIndex), 2);
    memcpy(&[Fora sharedInstance].foraCmdBuffer[3], [[Fora sharedInstance] addressOfCmdIndex], 2);
    //k[Fora sharedInstance].foraCmdBuffer[STOP-1] = FORA_CMD_STOP;
    
    //k[Fora sharedInstance].lenMinus = 2;
    
    // Check USER Filter
    [H2SyncReport sharedInstance].hasSMSingleRecord = NO;
    
    DLog(@"FORA W310B USER ID %02X, C_USER %02X", [H2Records sharedInstance].equipUserIdFilter, [H2Records sharedInstance].currentUser);
    
    if([H2Records sharedInstance].currentUser == [H2Records sharedInstance].bwTmpRecord.meterUserId-1){
        // GET Sever LDT
        [H2SyncReport sharedInstance].serverBwLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime: RECORD_TYPE_BW withUserId:(1 << [H2Records sharedInstance].currentUser)];
        
        if([H2Omron sharedInstance].bwFlag != 'C'){
            if ([[H2SyncReport sharedInstance] h2SyncBwDidGreateThanLastDateTime]) {
                
                DLog(@"FORA DEBUG -- NOT ending, UID =  %d", [H2Records sharedInstance].bwTmpRecord.meterUserId );
                DLog(@"CUR usr %02X, and type %02X", [H2Records sharedInstance].currentUser , [H2Records sharedInstance].currentDataType );
                
                [H2Records sharedInstance].currentDataType = RECORD_TYPE_BW;
                [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bwTmpRecord];
                
                DLog(@"BW TOTAL NOW = %@", [H2Records sharedInstance].H2RecordsArray);
                [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
            }else{
                [Fora sharedInstance].foraCmdNext = FORA_CMD_TURN_OFF;
                //k [Fora sharedInstance].lenMinus = 1;
                //k [Fora sharedInstance].foraCmdBuffer[CMD_AT] = FORA_CMD_TURN_OFF;
            }
        }
    }
    
    if ([Fora sharedInstance].cmdIndex >= [Fora sharedInstance].recordTotal) {
        DLog(@"FORA DEBUG -- ending 1 - 0 MODE W310");
        [Fora sharedInstance].foraCmdNext = FORA_CMD_TURN_OFF;
        //k [Fora sharedInstance].lenMinus = 1;
        //k [Fora sharedInstance].foraCmdBuffer[CMD_AT] = FORA_CMD_TURN_OFF;
        DLog(@"W310B BW TOTAL %@", [H2Records sharedInstance].H2RecordsArray);
    }
    
    return YES;
}


@end







