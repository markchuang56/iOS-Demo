//
//  OMRON_HBF-254C.m
//  h2LibAPX
//
//  Created by h2Sync on 2016/8/16.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#import "H2BleService.h"
#import "H2BleCentralManager.h"

#import "h2DebugHeader.h"
#import "h2CmdInfo.h"

#import "H2AudioFacade.h"

#import "H2Config.h"

#import "H2BleOad.h"
#import "H2BgmCable.h"

#import "OMRON_HEM-7280T.h"
#import "OMRON_HBF-254C.h"

#import "H2AudioHelper.h"
#import "H2Records.h"
#import "H2LastDateTime.h"

#import "H2BleTimer.h"

@implementation OMRON_HBF_254C



- (id)init
{
    if (self = [super init]) {
        _hbfRecordDataArray = [[NSMutableData alloc] init];
    }
    return self;
}





/**************************************************************************************************
 ///////////////////////////
 // A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 Task ...
 //
 ///////////////////////////
 **************************************************************************************************/
const UInt8 hbfCmd6_GetUserProfile[] = {
    // Report user Profile
    0x08, 0x01, 0x00, 0x01, 0xD0, 0x30, 0x00, 0xE8
};

UInt8 hbfCmd7_SetTimer[OMRRON_COMMAND_SIZE] = {0};


unsigned char hbfCmdE_IndexTimer[] = {
    0x18, 0x01, 0xC0, 0x02,
    0x00, 0x10, 0x00, 0x00, // One User only
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    
    0x11, // year
    0x02, // month
    
    0x07, // day
    0x0F, // hour
    0x25, // minute
    0x01, // second
    //0x6C, 0x7D, 0x00,
    0x4F, 0xAC, 0x00,
    0x14, // crc
    //0xFF, 0xFF, 0xFF, 0xFF,     0xFF, 0xFF, 0xFF, 0xFF
    0x00, 0x00, 0x00, 0x00,     0x00, 0x00,  0x00,  0x00
};

UInt8 hbfCmd8_UserPorfile[OMRRON_COMMAND_SIZE] = {0};

const UInt8 userPorfileTrail[] = {
    0x81, 0x82, 0x83, 0x85
    , 0x86, 0x84
};



#pragma mark - REPORT PROCESS
- (void)h2OmronHbf254CDataProcess
{
#ifdef DEBUG_LIB
    DLog(@"HBF-254C RECEIVED %@", [H2Omron sharedInstance].omronDataBuffer);
#endif
    // 0 : Hardware Info
    if ([H2Omron sharedInstance].parserHardwareInfo) {
        [[H2Omron sharedInstance] omronHardwareInfoParser];
    }
    
    // 1 : Get Current Time
    if ([H2Omron sharedInstance].parserCurrentTime) {
        [self hbf254CCurrentTimeParser];
    }
    
    // 2 : Get User Profile
    if ([H2Omron sharedInstance].parserUserProfile) {
        [self hbf254CUserProfileParser];
        // Go to SET TAG or Report Meter Info
        return;
    }
    /*
     // Pairing Stage
     if (![H2Omron sharedInstance].parserUserProfile && [H2Omron sharedInstance].setUserIdMode) {
     #ifdef DEBUG_BW
     DLog(@"254C - SHOW SET USER ID DIALOG");
     #endif
     return;
     }
     return;
     }
     */
    // 3 : Set Current Time
    if ([H2Omron sharedInstance].parserSetCurrentTime) {
        [self hbf254CSetCurrentTimeParser];
    }
    
    // 4 : Set User Profile
    if ([H2Omron sharedInstance].parserSetTagProfile) {
        [self hbf254CSetUserProfileParser];
    }
    
    // 5 : Record(s) Stage
    if ([H2Omron sharedInstance].parserOrCollectRecord) {
        [self hbfRecordParser];
    }
    
    // 6 : Clear Index
    if ([H2Omron sharedInstance].parserClearIndex) {
        [H2Omron sharedInstance].parserClearIndex = NO;
        [H2Omron sharedInstance].parserFinished = YES;
    }
    
    // 7 : Finish
    if ([H2Omron sharedInstance].parserFinished) {
        [H2Omron sharedInstance].parserFinished = NO;
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:OMRON_CMD_INTERVAL taskSel:BLE_TIMER_OMRON_HBF_CMD_FLOW];
        //[self h2OmronHbf254CA1CmdFlow];
    }
}


///////////////////////////////////////////////////////
// With User ID
// GET Record command Flow
//
///////////////////////////////////////////////////////
#pragma mark - A1 COMMAND FLOW
- (void)OMRON_Hbf254C_GetRecordInit
{
    for(int i=0; i<4; i++){
        if([H2Omron sharedInstance].userIdFilter & (1 << i)){
            [H2SyncReport sharedInstance].serverBwLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime:RECORD_TYPE_BW withUserId:(1<< i)];
            break;
        }
    }
    [self h2OmronHbf254CA1CmdFlow];
}

- (void)h2OmronHbf254CA1CmdFlow
{
#ifdef DEBUG_BW
    DLog(@"HBF-XXX HBF-254C A1 COMMAND FLOW - %02X", [H2Omron sharedInstance].omronCmdSel);
#endif
    if ([H2Omron sharedInstance].omronCmdSel > HBF_CMD_C) {
        [H2Omron sharedInstance].setUserIdMode = NO;
#ifdef DEBUG_BW
        DLog(@"HBF-254C COMMAND END  == %d", [H2Omron sharedInstance].omronCmdSel);
#endif
        return;
    }
    
    // Clear Command Buffer (BUFFER INIT)
    [[H2Omron sharedInstance]omronBufferInit];
    
    switch ([H2Omron sharedInstance].omronCmdSel) {
        case HBF_CMD_5: // Get Current Time and Records Status
            [H2Records sharedInstance].currentDataType = RECORD_TYPE_BW;
            [[H2Omron sharedInstance] omronGetIndexCurrentTime];
#ifdef DEBUG_BW
            DLog(@"HBF-COMAND-5 GET CURRENT TIME");
#endif
            break;
            
        case HBF_CMD_6: // Get User Profile
            [H2Omron sharedInstance].parserUserProfile = YES;
            memcpy([H2Omron sharedInstance].omronHemCmd, hbfCmd6_GetUserProfile, OM_NORMAL_CMDBUF_LEN);
            [_hbfRecordDataArray setLength:0];
            
            // Always Set Current Time
            [H2Omron sharedInstance].reportIndex = 0;
#if 0
            if (![H2Omron sharedInstance].setUserIdMode) {
                // Go TO Send Records Command
                [H2Omron sharedInstance].reportIndex = 0;
                [H2Omron sharedInstance].omronCmdSel += 2;
            }
#endif
            break;
            
        case HBF_CMD_7: // Set Current Time
            [H2Omron sharedInstance].cmdLength = OM_MAX_CMDBUF_LEN;
            [H2Omron sharedInstance].parserSetCurrentTime = YES;
            
#ifdef SKIP_INDEX
            [self hbfA1SetCurrentTime];
            // SKIP Set User Profile
            [H2Omron sharedInstance].omronCmdSel++;
#else
            [self OmronHbf254CA1SetIndexCurrentTime];
#endif
            
            // And ...
            if ([H2Omron sharedInstance].setUserIdMode) {
                [H2Omron sharedInstance].omronCmdSel += 2;
            }
            break;
            
        case HBF_CMD_8: // Set User Profile
            [H2Omron sharedInstance].cmdLength = OM_MAX_CMDBUF_LEN;
            [H2Omron sharedInstance].parserSetTagProfile = YES;
            memcpy([H2Omron sharedInstance].omronHemCmd, hbfCmd8_UserPorfile, OMRRON_COMMAND_SIZE);
            // A2 command
            [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(hbfA2CmdTask) userInfo:nil repeats:NO];
#ifdef DEBUG_BW
            DLog(@"DO NOT THING ... CMD 8");
#endif
            if ([H2Omron sharedInstance].setUserIdMode) {
                [H2Omron sharedInstance].omronCmdSel += 2;
            }
            break;
            
            
        case HBF_CMD_9:
#ifdef DEBUG_BW
            DLog(@"254C BW A1 CMD FLOW - RECORD ... %02X", [H2Omron sharedInstance].userIdFilter);
#endif
            [H2Omron sharedInstance].normalCmdFlow = NO;
            [H2Omron sharedInstance].parserOrCollectRecord = YES;
            if ([self omronHbfRecordCmdProcess]) {
                // GO TO NEXT FLOW
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:OMRON_CMD_INTERVAL taskSel:BLE_TIMER_OMRON_HBF_CMD_FLOW];
                //[NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(h2OmronHbf254CA1CmdFlow) userInfo:nil repeats:NO];
                return;
            }
            break;
            
        case HBF_CMD_A:
            [[H2Omron sharedInstance] omronIndexCmdProcess];
            break;
            
        case HBF_CMD_B:
            [[H2Omron sharedInstance] cmdDone];
            break;
            
        default:
            break;
    }
#ifdef DEBUG_BW
    DLog(@"DEBUG_LIB OMRON HBF-254C CMD INDEX %02X", [H2Omron sharedInstance].omronCmdSel);
#endif
    
    [[H2Omron sharedInstance] omronWriteA1Task];
}


//////////////////////////////////////////////////////
// HBF-254C PARSER AREA
#pragma mark - PARSER TASK
- (void)hbf254CSetCurrentTimeParser
{
    [H2Omron sharedInstance].parserSetCurrentTime = NO;
    [H2Omron sharedInstance].parserFinished = YES;
}
- (void)hbf254CSetUserProfileParser
{
    [H2Omron sharedInstance].parserSetTagProfile = NO;
    [H2Omron sharedInstance].parserFinished = YES;
}

- (void)hbf254CCurrentTimeParser
{
    UInt16 dataSum = 0;
    UInt8 dataCrc = 0;
    
    UInt8 profile[16] = {0};
    [H2Omron sharedInstance].parserCurrentTime = NO;
    [H2Omron sharedInstance].parserFinished = YES;
    
    // Parser Current Time 1
#ifdef DEBUG_BW
    DLog(@"DECODE START -- CURRENT TIME");
#endif
    for (int i=0; i<24; i++) {
        dataSum ^= [H2Omron sharedInstance].omronA0Buffer[i];
#ifdef DEBUG_BW
        DLog(@"254C == CRC = %d  %04X, %02X", i, dataSum, [H2Omron sharedInstance].omronA0Buffer[i]);
#endif
    }
    dataSum = 0;
    for (int i=0; i<6; i++) {
        dataSum += [H2Omron sharedInstance].omronA0Buffer[14+i];
#ifdef DEBUG_BW
        DLog(@"254C == SUM = %d  %04X, %02X", i, dataSum, [H2Omron sharedInstance].omronA0Buffer[14+i]);
#endif
    }
    dataCrc = 0;
    dataCrc = ((dataSum + 8)  & 0x0F) + ((dataSum & 0xF0) ^ 0xF0);
#ifdef DEBUG_BW
    DLog(@"254C == OTHER %02X", dataCrc);
    DLog(@"\n\n");
#endif
    
    UInt16 hbfYear = 0;
    
    UInt8 hbfMonth = 0;
    UInt8 hbfDay = 0;
    
    UInt8 hbfHour = 0;
    UInt8 hbfMinute = 0;
    UInt8 hbfSecond = 0;
    
    
    hbfYear = [H2Omron sharedInstance].omronA0Buffer[14] + 2000;
    
    hbfMonth = [H2Omron sharedInstance].omronA0Buffer[15];
    hbfDay = [H2Omron sharedInstance].omronA0Buffer[16];
    
    hbfHour = [H2Omron sharedInstance].omronA0Buffer[17];
    hbfMinute = [H2Omron sharedInstance].omronA0Buffer[18];
    hbfSecond = [H2Omron sharedInstance].omronA0Buffer[19];
#ifdef DEBUG_BW
    DLog(@"254C == 年 : %d, 月 : %d, 日 : %d", hbfYear, hbfMonth, hbfDay);
    DLog(@"254C == 時 : %d, 分 : %d, 秒 : %d", hbfHour, hbfMinute, hbfSecond);
#endif
    [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", hbfYear, hbfMonth, hbfDay, hbfHour, hbfMinute, hbfSecond];
    dataSum = 0;
    memcpy(profile, &[H2Omron sharedInstance].omronA0Buffer[6+16*2], 16);
    for (int k=0; k<12; k++) {
        dataSum += profile[k];
#ifdef DEBUG_BW
        DLog(@"254C == PROFILE SUM = %d  %04X, %02X", k, dataSum, profile[k]);
#endif
    }
    dataCrc = 0;
    dataCrc = ((dataSum + 8)  & 0x0F) + ((dataSum & 0xF0) ^ 0xF0);
#ifdef DEBUG_BW
    DLog(@"254C PRO FILE  CRC %02X", dataCrc);
    DLog(@"\n");
#endif
    // User 1 Profile Parser
    if (!(profile[0] == 0xFF && profile[1] == 0xFF)) {
        [H2Omron sharedInstance].userIdStatus |= USER_TAG1_MASK;
    }
    
    memcpy([H2Omron sharedInstance].tmpIndexBuffer, &[H2Omron sharedInstance].omronA0Buffer[6], 8);
    
    [H2Omron sharedInstance].addrForTag_1 = [H2Omron sharedInstance].omronA0Buffer[6] & HBF_INDEX_MASK;
    [H2Omron sharedInstance].addrForTag_2 = [H2Omron sharedInstance].omronA0Buffer[7] & HBF_INDEX_MASK;
    [H2Omron sharedInstance].addrForTag_3 = [H2Omron sharedInstance].omronA0Buffer[8] & HBF_INDEX_MASK;
    [H2Omron sharedInstance].addrForTag_4 = [H2Omron sharedInstance].omronA0Buffer[9] & HBF_INDEX_MASK;
    
    [H2Omron sharedInstance].qtsForTag_1 = [H2Omron sharedInstance].omronA0Buffer[10] & HBF_INDEX_MASK;
    [H2Omron sharedInstance].qtsForTag_2 = [H2Omron sharedInstance].omronA0Buffer[11] & HBF_INDEX_MASK;
    [H2Omron sharedInstance].qtsForTag_3 = [H2Omron sharedInstance].omronA0Buffer[12] & HBF_INDEX_MASK;
    [H2Omron sharedInstance].qtsForTag_4 = [H2Omron sharedInstance].omronA0Buffer[13] & HBF_INDEX_MASK;
    
#ifdef DEBUG_BW
    DLog(@"HBF-254C NUMBER OF RECORD");
    DLog(@"U1 %02X = %02X", [H2Omron sharedInstance].qtsForTag_1, [H2Omron sharedInstance].omronA0Buffer[6]);
    DLog(@"U2 %02X = %02X", [H2Omron sharedInstance].qtsForTag_2, [H2Omron sharedInstance].omronA0Buffer[7]);
    DLog(@"U3 %02X = %02X", [H2Omron sharedInstance].qtsForTag_3, [H2Omron sharedInstance].omronA0Buffer[8]);
    DLog(@"U4 %02X = %02X", [H2Omron sharedInstance].qtsForTag_4, [H2Omron sharedInstance].omronA0Buffer[9]);
#endif
 
    // FOR TEST
#if 0
    [H2Omron sharedInstance].addrForTag_1 = 30;
    [H2Omron sharedInstance].addrForTag_2 = 30;
    [H2Omron sharedInstance].addrForTag_3 = 30;
    [H2Omron sharedInstance].addrForTag_4 = 30;
    
    [H2Omron sharedInstance].qtsForTag_1 = 30;
    [H2Omron sharedInstance].qtsForTag_2 = 30;
    [H2Omron sharedInstance].qtsForTag_3 = 30;
    [H2Omron sharedInstance].qtsForTag_4 = 30;
#endif
    
    if ([H2Omron sharedInstance].userIdFilter & USER_TAG1_MASK) {
        if ([H2Omron sharedInstance].qtsForTag_1>0) {
            [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_1 withIdx:[H2Omron sharedInstance].addrForTag_1 omronTypeHem:NO];
        }
    }else if([H2Omron sharedInstance].userIdFilter & USER_TAG2_MASK){
        if ([H2Omron sharedInstance].qtsForTag_2>0) {
            [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_2 withIdx:[H2Omron sharedInstance].addrForTag_2 omronTypeHem:NO];
        }
    }else if([H2Omron sharedInstance].userIdFilter & USER_TAG3_MASK){
        if ([H2Omron sharedInstance].qtsForTag_3>0) {
            [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_3 withIdx:[H2Omron sharedInstance].addrForTag_3 omronTypeHem:NO];
        }
    }else if([H2Omron sharedInstance].userIdFilter & USER_TAG4_MASK){
        if ([H2Omron sharedInstance].qtsForTag_4>0) {
            [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_4 withIdx:[H2Omron sharedInstance].addrForTag_4 omronTypeHem:NO];
        }
    }
    /*
    if ([H2Omron sharedInstance].qtsForTag_1>0) {
        [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_1 withIdx:[H2Omron sharedInstance].addrForTag_1 omronTypeHem:NO];
    }
    */
    
    
        // PROFILE OR DATE TIME CRC FROM SUM
        // HIGH NIBBLE LOW NIBBLE
        //  0   F       0   8
        //  1   E       1   9
        //  2   D       2   A
        //  3   C       3   B
        //  4   B       4   C
        //  5   A       5   D
        //  6   9       6   E
        //  7   8       7   F
        
        
        
        
        /*
         38810001 a0300000 00000000 00001102
         160e132b 758d0007 ffffffff 03fb1001
         0e0e1632 758d4e09 0900072b 81828385
         86840000 a75f004c 00000000 00000000
         
         38810001 d030
         410b 07010618 81828385
         86840000 877f4f0c 180106f4 81828385
         86840000 837b3102 1c0105cd 81828385
         86840000 37cf00bb 00000000 00000000
         */
//    }
    dataCrc = 0;
    for (int i=0; i<0x38; i++) {
        dataCrc ^= [H2Omron sharedInstance].omronA0Buffer[i];
#ifdef DEBUG_BW
        DLog(@"254C == CRC = %d  %04X, %02X", i, dataCrc, [H2Omron sharedInstance].omronA0Buffer[i]);
#endif
    }
    //j[H2Omron sharedInstance].parserFinished = YES;
}


- (void)hbf254CUserProfileParser
{
/*
    38810001 d030410b 07010618 81828385
    86840000 877f4f0c 180106f4 81828385
    86840000 837b3102 1c0105cd 81828385
    86840000 37cf00bb 00000000 00000000
 
    410b 07010618 81828385 86840000 877f
    4f0c 180106f4 81828385 86840000 837b
    3102 1c0105cd 81828385 86840000 37cf
    00bb
*/
    
    UInt16 dataSum = 0;
    UInt8 dataCrc = 0;
    
    UInt8 profile[16] = {0};
    
    [H2Omron sharedInstance].parserUserProfile = NO;
    
    for (int i=0; i<3; i++) {
#ifdef DEBUG_BW
        DLog(@"PROFILE ID = %d", i + 1);
#endif
        dataSum = 0;
        memcpy(profile, &[H2Omron sharedInstance].omronA0Buffer[6+16*i], 16);
        switch (i) {
            case 0:
                // User 2 Profile Parser
                if (!(profile[0] == 0xFF && profile[1] == 0xFF)) {
                    [H2Omron sharedInstance].userIdStatus |= USER_TAG2_MASK;
#ifdef DEBUG_BW
                    DLog(@"USER 2 HAS SET");
#endif
                }
                break;
                
            case 1:
                // User 3 Profile Parser
                if (!(profile[0] == 0xFF && profile[1] == 0xFF)) {
                    [H2Omron sharedInstance].userIdStatus |= USER_TAG3_MASK;
#ifdef DEBUG_BW
                    DLog(@"USER 3 HAS SET");
#endif
                }
                break;
                
            case 2:
                // User 4 Profile Parser
                if (!(profile[0] == 0xFF && profile[1] == 0xFF)) {
                    [H2Omron sharedInstance].userIdStatus |= USER_TAG4_MASK;
#ifdef DEBUG_BW
                    DLog(@"USER 4 HAS SET");
#endif
                }
                break;
                
            default:
                break;
        }
        
        
        
        for (int k=0; k<12; k++) {
            dataSum += profile[k];
#ifdef DEBUG_BW
            DLog(@"254C == PROFILE SUM = %d  %04X, %02X", k, dataSum, profile[k]);
#endif
        }
        //DLog(@"\n");
        dataCrc = 0;
        dataCrc = ((dataSum + 8)  & 0x0F) + ((dataSum & 0xF0) ^ 0xF0);
#ifdef DEBUG_BW
        DLog(@"254C PRO FILE  CRC %02X", dataCrc);
        DLog(@"\n");
#endif
    }
    
    for (int i=0; i<0x38; i++) {
        dataCrc ^= [H2Omron sharedInstance].omronA0Buffer[i];
#ifdef DEBUG_BW
        DLog(@"254C == CRC = %d  %04X, %02X", i, dataCrc, [H2Omron sharedInstance].omronA0Buffer[i]);
#endif
    }
    [[H2Omron sharedInstance] omronCheckSerialNumber:[H2Omron sharedInstance].userIdStatus];
    // Get Records Command Process or Show Set User Id Dialog

    // PROFILE OR DATE TIME CRC FROM SUM
    // HIGH NIBBLE LOW NIBBLE
    //  0   F       0   8
    //  1   E       1   9
    //  2   D       2   A
    //  3   C       3   B
    //  4   B       4   C
    //  5   A       5   D
    //  6   9       6   E
    //  7   8       7   F
}




#pragma mark - PARSER RECORD
- (void)hbfRecordParser
{
    [H2Omron sharedInstance].parserFinished = YES;
    
#ifdef DEBUG_BW
    DLog(@"CURRENT USER == %d", [H2Records sharedInstance].currentUser);
#endif
    [H2Records sharedInstance].bwTmpRecord = [self hbf254CRecord:&[H2Omron sharedInstance].omronA0Buffer[BP_RECORD_OFFSET] withUser:(1 << [H2Records sharedInstance].currentUser)];
    
    if ([H2Omron sharedInstance].bwFlag == 'C' || [[H2SyncReport sharedInstance] didGreateMoreThanSystemTime:[H2Records sharedInstance].bwTmpRecord.bwDateTime]) {
        [self hbf254CNextUserCheck];
    }else{
        if ([[H2SyncReport sharedInstance] h2SyncBwDidGreateThanLastDateTime]) {
            [H2SyncReport sharedInstance].hasSMSingleRecord = YES;
            [H2Omron sharedInstance].reportIndex++;
#ifdef DEBUG_BW
            DLog(@"HBF INDEX = %d, CURRENT USER %d", [H2Omron sharedInstance].reportIndex, [H2Records sharedInstance].currentUser);
#endif
            [H2Records sharedInstance].bwTmpRecord.bwIndex = [H2Omron sharedInstance].reportIndex;
            
            
            [H2Records sharedInstance].bwTmpRecord.meterUserId = (1 << [H2Records sharedInstance].currentUser);
            [H2Records sharedInstance].currentDataType = RECORD_TYPE_BW;
            [[H2Records sharedInstance] buildRecordsArray:(id)[H2Records sharedInstance].bwTmpRecord];
            [self hbf254CNextUserCheck];
#ifdef DEBUG_BW
            DLog(@"BW CUR USER %02X, and UID %02X", [H2Records sharedInstance].currentUser, [H2Records sharedInstance].bwTmpRecord.meterUserId);
            DLog(@"RESULT %@", [H2Records sharedInstance].bwTmpRecord.bwDateTime);
            DLog(@"RESULT %@", [H2Records sharedInstance].bwTmpRecord.bwWeight);
            DLog(@"RESULT %@", [H2Records sharedInstance].bwTmpRecord.bwBmi);
            DLog(@"BW GREAT THAN ... (OLD)");
#endif
            
        }else{
#ifdef DEBUG_BW
            DLog(@"BW - TIME LESS, WILL GET NEW LDT");
#endif
            [self hbfGoToNextUser:[H2Records sharedInstance].currentUser];
        }
    }
    
    
    
    if ([H2Omron sharedInstance].omronDataLength <= OM_MAX_CMDBUF_LEN) {
#ifdef DEBUG_BW
        DLog(@"RECORD ENDING --  ...");
#endif
        [H2Omron sharedInstance].parserFinished = YES;
        return;
    }
    
    [H2Omron sharedInstance].parserFinished = YES;
}

- (H2BwRecord *)hbf254CRecord:(Byte *) record withUser:(UInt8)user
{
    H2BwRecord *bwRecordInfo = [[H2BwRecord alloc] init];
    
    NSString *dateTime = [[NSString alloc] init];
    UInt16 bWeight = 0;
    
    UInt8 bWeightInteger = 0;
    UInt8 bWeightDecimal = 0;
    UInt8 bWeightDecimalX = 0;
    
    UInt16 bFat = 0;
    UInt16 skeletalMuscle = 0;
    UInt16 restingMetabolism = 0;
    
    UInt8 bLevel = 0;
    UInt8 body_age = 0;
    UInt16 bmi = 0;
    
    UInt16 Year = 0;
    UInt8 Month = 0;
    UInt8 Day = 0;
    
    UInt8 Hour = 0;
    UInt8 Minute = 0;
    UInt8 Second = 0;
    
#ifdef DEBUG_BW
    UInt8 dataCrc = 0;
    
    dataCrc = 0;
    DLog(@"254C RECORD DATA_A =   %02X, %02X, %02X, %02X", record[0], record[1], record[2], record[3]);
    DLog(@"254C RECORD DATA_B =   %02X, %02X, %02X, %02X", record[4], record[5], record[6], record[7]);
    for (int k=0; k<32; k++) {
        dataCrc += record[k];
        DLog(@"254C RECORD SUM = %d  %04X, %02X", k, dataCrc, record[k]);
    }
#endif
    
    [H2Omron sharedInstance].bwFlag = 'N';
    if (record[0] == 0xE3) {
        [H2Omron sharedInstance].bwFlag = 'C';
        return bwRecordInfo;
    }
    
    if (record[0] == 0xFF &&  record[1] == 0xFF && record[2] == 0xFF && record[3] == 0xFF) {
        [H2Omron sharedInstance].bwFlag = 'C';
        return bwRecordInfo;
    }
    ///////////////////////////////////////////////
    //////// PARSER
    bWeight = (record[0]<<8) + record[1];
    bWeightInteger = (bWeight >> 5)/10;
    
    //bWeightDecimal =  bWeight%320;
    bWeightDecimal =  (bWeight>>5)%10;
    if (record[1] & 0x10) {
        bWeightDecimalX = 5;
    }else{
        bWeightDecimalX = 0;
    }
    
    
    //bWeightDecimal >>= 4;
    //bWeightDecimal *= 5;
    
    bFat = (record[2]<<8) + record[3];
    bFat >>= 6;
    
    bLevel =  record[3] & 0x3F;
    
    restingMetabolism = (record[4]<<8) + record[5];
    restingMetabolism >>= 4;
    
    skeletalMuscle = (record[6]<<8) + record[7];
    skeletalMuscle >>= 6;
    
    bmi = (record[8]<<8) + record[9];
    bmi >>= 6;

    
    body_age = record[10];
    // Date and Time
    
    Year =  record[7] & 0x3F;
    Year += 2000;
    
    Month = record[11] & 0x0F;
    
    Day = record[12] & 0xF8;
    Day >>= 3;
    
    Hour = record[12] & 0x07;
    Hour <<= 2;
    Hour += ((record[13] & 0xC0) >> 6);
    
    Minute =  record[9] & 0x3F;
    Second = record[13] & 0x3F;
    
    if (Minute >= 60) {
        [H2Omron sharedInstance].bwFlag = 'C';
    }
    if (Second >= 60) {
        [H2Omron sharedInstance].bwFlag = 'C';
    }
    
    dateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", Year, Month, Day, Hour, Minute, Second];
    
#ifdef DEBUG_BW
    DLog(@"DATE-TIME %04d-%02d-%02d %02d:%02d:%02d +0000", Year, Month, Day, Hour, Minute, Second);
    //DLog(@"體重 =  %04X, %d.%d Kg", bWeight, bWeight/320, (bWeight%320)/16*5);
    //DLog(@"體重 2 =  %d . %d Kg, %d, %d, %d", (bWeight>>5)/10, (bWeight>>5)%10, (bWeight>>4), (bWeight>>3), (bWeight>>2));
#endif
    
    //NSLog(@"==== BFT %d, %02X ====", bFat, bFat);
    
    /*
    DLog(@"肥胖 =  %d.%d \%", (UInt8)(bFat/10), bFat%10);
    DLog(@"肌肉 =  %d . %d  \% ", skeletalMuscle/10, skeletalMuscle%10);
    DLog(@"熱量 =  %d KCal", restingMetabolism);
    
    DLog(@"LEVEL = %d", bLevel);
    DLog(@"BODY AGE = %d 才", body_age);
    DLog(@"BMI =  %d . %d  \% ", bmi/10, bmi%10);
*/    
    
    bwRecordInfo.recordType = RECORD_TYPE_BW;
    bwRecordInfo.bwDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", Year, Month, Day, Hour, Minute, Second];
    
    bwRecordInfo.bwWeight =  [NSString stringWithFormat:@"%d.%d%d", bWeightInteger, bWeightDecimal, bWeightDecimalX];
    
    DLog(@"體重 WWW %@ %02X, %02X", bwRecordInfo.bwWeight, record[0], record[1]);
    
    bwRecordInfo.bwFat = [NSString stringWithFormat:@"%d.%d", bFat/10, bFat%10];
/*
    NSLog(@"==== BFT %d, %02X ====", bFat, bFat);
    NSLog(@"==== BFT %d.%d ====", bFat/10, bFat%10);
    NSLog(@"==== BFT %@ ====", bwRecordInfo.bwFat);
  */
    bwRecordInfo.bwSkeletalMuscle = [NSString stringWithFormat:@"%d.%d", skeletalMuscle/10, skeletalMuscle%10];
    
    //NSLog(@"==== MUSCLE %@ ====", bwRecordInfo.bwSkeletalMuscle);
    
    bwRecordInfo.bwRestingMetabolism = [NSString stringWithFormat:@"%d", restingMetabolism];
    
    bwRecordInfo.bwLevel = [NSString stringWithFormat:@"%d", bLevel];
    
    bwRecordInfo.bwAge = body_age;
    
    bwRecordInfo.bwBmi = [NSString stringWithFormat:@"%d.%d", bmi/10, bmi%10];
    
    return bwRecordInfo;
}

- (void)hbf254CNextUserCheck
{
    BOOL didAnyTagEnding = NO;
    
    switch ([H2Records sharedInstance].currentUser) {
        case NX_TAG_1:
            if ([H2Omron sharedInstance].qtsForTag_1 == 0) {
                didAnyTagEnding = YES;
            }
            break;
            
        case NX_TAG_2:
            if ([H2Omron sharedInstance].qtsForTag_2 == 0) {
                didAnyTagEnding = YES;
            }
            break;
            
        case NX_TAG_3:
            if ([H2Omron sharedInstance].qtsForTag_3 == 0) {
                didAnyTagEnding = YES;
            }
            break;
            
        case NX_TAG_4:
            if ([H2Omron sharedInstance].qtsForTag_4 == 0) {
                didAnyTagEnding = YES;
            }
            break;
            
        default:
            break;
    }
    if (didAnyTagEnding) {
        [self hbfGoToNextUser:[H2Records sharedInstance].currentUser];
    }
}

- (void)hbfGoToNextUser:(UInt8)currentTag
{
    [H2Omron sharedInstance].reportIndex = 0;
    [[H2Omron sharedInstance] clearHbfTagIndex:currentTag];
    
    // Remove Current User Flag
    [H2Omron sharedInstance].userIdFilter ^= (1 << currentTag);
    
    // Go To Next User
    [H2Records sharedInstance].currentUser++;
    switch ([H2Records sharedInstance].currentUser) {
        case NX_TAG_2:
            if ([H2Omron sharedInstance].qtsForTag_2 > 0) {
                [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_2 withIdx:[H2Omron sharedInstance].addrForTag_2 omronTypeHem:NO];
            }
            break;
            
        case NX_TAG_3:
            if ([H2Omron sharedInstance].qtsForTag_3 > 0) {
                [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_3 withIdx:[H2Omron sharedInstance].addrForTag_3 omronTypeHem:NO];
            }
            break;
            
        case NX_TAG_4:
            if ([H2Omron sharedInstance].qtsForTag_4 > 0) {
                [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_4 withIdx:[H2Omron sharedInstance].addrForTag_4 omronTypeHem:NO];
            }
            break;
            
        default:
            break;
    }
    if ([H2Records sharedInstance].currentUser <= HBF_MAX_TAG) {
        if([H2Omron sharedInstance].userIdFilter & (1 << [H2Records sharedInstance].currentUser)){
            [H2SyncReport sharedInstance].serverBwLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime:RECORD_TYPE_BW withUserId:(1 << ([H2Records sharedInstance].currentUser))];
        }
    }
}

/************
 / kg/32
 /fat/64			/KCal/16				/muscle/64					/BMI /64
 
 ************/
#pragma mark - SET CURRENT TIME TASK (ONLY)
- (void)hbfA1SetCurrentTime
{
    Byte  *timeBuffer;
    timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
    
    UInt8 year = timeBuffer[0]; //[components year];
    UInt8 month = timeBuffer[1]; //[components month];
    UInt8 day = timeBuffer[2]; //[components day];
    
    UInt8 hour = timeBuffer[3]; //[components hour];
    UInt8 minute = timeBuffer[4]; //[components minute];
    UInt8 second = timeBuffer[5]; //[components second];
    
#ifdef DEBUG_BW
    DLog(@"DEMO-DEBUG Y:%04X, M:%02X, D:%02X", year, month, day);
    DLog(@"DEMO-DEBUG H:%02X, MIN:%02X, SEC:%02X", hour, minute, second);
    DLog(@"OMRON Y:%04X, M:%02X, D:%02X", year, month, day);
#endif
    //memcpy(&hbfCmdE_IndexTimer[6], &hbfCmdClearIndex[6], 8);
#ifdef DEBUG_BW
    //for (int i=0; i<16; i++) {
    //    DLog(@"SEC - CLR INDEX %02d --> %02X", i, hbfCmdE_IndexTimer[i]);
    //}
#endif
    hbfCmd7_SetTimer[1] = OM_FLASH_AREA;
    hbfCmd7_SetTimer[2] = OM_WRITE_FLASH;
    
    hbfCmd7_SetTimer[3] = (HBF_254C_STIMER_ADDR & 0xFF00)>>8;
    hbfCmd7_SetTimer[4] = HBF_254C_STIMER_ADDR & 0xFF;
    
    
    hbfCmd7_SetTimer[0] = HBF_SCT_CMD_LEN;
    hbfCmd7_SetTimer[5] = HBF_SCT_DATA_LEN;
    
    
    
    
    hbfCmd7_SetTimer[HBF_YEAR-OM_INDEX_DATA_LEN] = year;
    hbfCmd7_SetTimer[HBF_MON-OM_INDEX_DATA_LEN] = month;
    hbfCmd7_SetTimer[HBF_DAY-OM_INDEX_DATA_LEN] = day;
    
    hbfCmd7_SetTimer[HBF_HOUR-OM_INDEX_DATA_LEN] = hour;
    hbfCmd7_SetTimer[HBF_MIN-OM_INDEX_DATA_LEN] = minute;
    hbfCmd7_SetTimer[HBF_SEC-OM_INDEX_DATA_LEN] = second;
    
    UInt8 tmp = 0;
    for (int i = 0; i<6; i++) {
        tmp += hbfCmd7_SetTimer[14+i-OM_INDEX_DATA_LEN];
#ifdef DEBUG_BW
        DLog(@"SUM - HEM %d, %02X, %02X", i, tmp, hbfCmd7_SetTimer[14+i-OM_INDEX_DATA_LEN]);
#endif
    }
    hbfCmd7_SetTimer[20-OM_INDEX_DATA_LEN] = tmp;
    
    tmp = 0;
    for (int i = 0; i<hbfCmd7_SetTimer[0]-1; i++) {
        tmp ^= hbfCmd7_SetTimer[i];
#ifdef DEBUG_BW
        DLog(@"CT EX - CRC-SUM %d, %02X, %02X", i, tmp, hbfCmd7_SetTimer[i]);
#endif
    }
    
    hbfCmd7_SetTimer[hbfCmd7_SetTimer[0]-1] = tmp;
#ifdef DEBUG_BW
    for (int i = 0; i<sizeof(hbfCmd7_SetTimer); i++) {
        DLog(@"OMRON SET CT %d --> %02X", i, hbfCmd7_SetTimer[i]);
    }
#endif
    memcpy([H2Omron sharedInstance].omronHemCmd, hbfCmd7_SetTimer, OMRRON_COMMAND_SIZE);
    
    // A2 command
    [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(hbfA2CmdTask) userInfo:nil repeats:NO];
}


#pragma mark - SET INDEX AND CURRENT TIME TASK
- (void)OmronHbf254CA1SetIndexCurrentTime
{
    Byte  *timeBuffer;
    timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
    
    UInt8 year = timeBuffer[0]; //[components year];
    UInt8 month = timeBuffer[1]; //[components month];
    UInt8 day = timeBuffer[2]; //[components day];
    
    UInt8 hour = timeBuffer[3]; //[components hour];
    UInt8 minute = timeBuffer[4]; //[components minute];
    UInt8 second = timeBuffer[5]; //[components second];
    
#ifdef DEBUG_BW
    DLog(@"DEMO-DEBUG Y:%04X, M:%02X, D:%02X", year, month, day);
    DLog(@"DEMO-DEBUG H:%02X, MIN:%02X, SEC:%02X", hour, minute, second);
    DLog(@"OMRON Y:%04X, M:%02X, D:%02X", year, month, day);
    
    //for (int i=0; i<16; i++) {
    //    DLog(@"CLR INDEX %02d --> %02X", i, hbfCmdClearIndex[i]);
    //}
#endif
    //memcpy(&hbfCmdE_IndexTimer[6], &hbfCmdClearIndex[6], 8);
#ifdef DEBUG_BW
    for (int i=0; i<16; i++) {
        DLog(@"SEC - CLR INDEX %02d --> %02X", i, hbfCmdE_IndexTimer[i]);
    }
#endif
    hbfCmdE_IndexTimer[HBF_YEAR] = year;
    hbfCmdE_IndexTimer[HBF_MON] = month;
    hbfCmdE_IndexTimer[HBF_DAY] = day;
    
    hbfCmdE_IndexTimer[HBF_HOUR] = hour;
    hbfCmdE_IndexTimer[HBF_MIN] = minute;
    hbfCmdE_IndexTimer[HBF_SEC] = second;
    
    UInt8 tmp = 0;
    for (int i = 0; i<6; i++) {
        tmp += hbfCmdE_IndexTimer[14+i];
#ifdef DEBUG_BW
        DLog(@"SUM - HEM %d, %02X, %02X", i, tmp, hbfCmdE_IndexTimer[14+i]);
#endif
    }
    hbfCmdE_IndexTimer[20] = tmp;
    
    tmp = 0;
    for (int i = 0; i<hbfCmdE_IndexTimer[0]-1; i++) {
        tmp ^= hbfCmdE_IndexTimer[i];
#ifdef DEBUG_BW
        DLog(@"CT EX - CRC-SUM %d, %02X, %02X", i, tmp, hbfCmdE_IndexTimer[i]);
#endif
    }
    
    hbfCmdE_IndexTimer[hbfCmdE_IndexTimer[0]-1] = tmp;
#ifdef DEBUG_BW
    for (int i = 0; i<sizeof(hbfCmdE_IndexTimer); i++) {
        DLog(@"OMRON SET CT %d --> %02X", i, hbfCmdE_IndexTimer[i]);
    }
#endif
    //[H2Omron sharedInstance].cmdLength = OM_MAX_CMDBUF_LEN;
    memcpy([H2Omron sharedInstance].omronHemCmd, hbfCmdE_IndexTimer, OMRRON_COMMAND_SIZE);
    
    // A2 command
    [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(hbfA2CmdTask) userInfo:nil repeats:NO];
}


#pragma mark - SET USER ID AND PROFILE (EXTERNAL)
- (void)hbfA1SetUserProfile:(UInt8)userId
{
    UInt8 uTag = 0;
    if (userId > 0) {
        uTag = userId-1;
    }
    
    if (uTag > 3) {
        uTag = 3;
    }
    // userId from : 1
    [[H2Omron sharedInstance] clearHbfTagIndex:uTag];
    UInt16 address = HBF_254C_SPF_ADDR + (HBF_SPF_DATA_LEN * uTag);
    
    UInt8 pfBuffer[OMRRON_COMMAND_SIZE] = {0};
    
    pfBuffer[1] = OM_FLASH_AREA;
    pfBuffer[2] = OM_WRITE_FLASH;
    
    pfBuffer[0] = HBF_SPF_CMD_LEN;
    pfBuffer[5] = HBF_SPF_DATA_LEN;
    
    pfBuffer[3] = (address & 0xFF00)>>8;
    pfBuffer[4] = address & 0xFF;
    
    pfBuffer[6] = (UInt8)([H2Omron sharedInstance].tmpUserProfile.uBirthYear -1900);
    pfBuffer[7] = [H2Omron sharedInstance].tmpUserProfile.uBirthMonth;
    pfBuffer[8] = [H2Omron sharedInstance].tmpUserProfile.uBirthDay;
    
    pfBuffer[9] = [H2Omron sharedInstance].tmpUserProfile.uGender;
    
    
    pfBuffer[11] = (UInt8)([H2Omron sharedInstance].tmpUserProfile.uBodyHeight & 0x00FF);
    pfBuffer[10] = (UInt8)(([H2Omron sharedInstance].tmpUserProfile.uBodyHeight>>8) & 0x00FF);
    
    
    memcpy(&pfBuffer[12], userPorfileTrail, HBF_SPF_TRAIL_LEN);
    
    UInt8 crcTmp = 0;
    for (int i = 0; i<12; i++) {
        crcTmp += pfBuffer[6+i];
#ifdef DEBUG_BW
        DLog(@"EX - USER PROFILE SUM %d, %02X, %02X", i, crcTmp, pfBuffer[i]);
#endif
    }
    
    pfBuffer[20] = crcTmp;
    
    crcTmp = 0;
    for (int i = 0; i<pfBuffer[0]-1; i++) {
        crcTmp ^= pfBuffer[i];
#ifdef DEBUG_BW
        DLog(@"PROFILE EX - CRC-SUM %d, %02X, %02X", i, crcTmp, pfBuffer[i]);
#endif
    }
    pfBuffer[pfBuffer[0]-1] = crcTmp;
    
    memcpy(hbfCmd8_UserPorfile, pfBuffer, OMRRON_COMMAND_SIZE);
    
#ifdef DEBUG_BW
    for (int i = 0; i<sizeof(pfBuffer); i++) {
        DLog(@"OMRON SET CT %d --> %02X", i, pfBuffer[i]);
    }
#endif
    [self h2OmronHbf254CA1CmdFlow];
}


//////////////////////////////////////////////////////////
// A2 A2 A2 A2 A2 A2 A2   Task
- (void)hbfA2CmdTask
{
    [[H2Omron sharedInstance] omronSencondCommand];
}

#pragma mark - REPORT RECORDS
- (void)omronHbf254CReportRecords
{
    [[H2Sync sharedInstance] sdkProcessRecordsBeforeTransfer];
#ifdef DEBUG_BW
    DLog(@"254C REPORT RESULT");
#endif
}

- (BOOL)omronHbfRecordCmdProcess
{
#ifdef DEBUG_BW
    NSLog(@"HBF-FILTER %02X, Qty's = %d, Qty's = %d, Qty's = %d, Qty's = %d", [H2Omron sharedInstance].userIdFilter, [H2Omron sharedInstance].qtsForTag_1, [H2Omron sharedInstance].qtsForTag_2, [H2Omron sharedInstance].qtsForTag_3, [H2Omron sharedInstance].qtsForTag_4);
#endif
    BOOL goToNextFlow = NO;
    BOOL didAnyRecordEnding = NO;
    
    
    if ([H2Omron sharedInstance].userIdFilter & USER_TAG1_MASK) {
        [H2Records sharedInstance].currentUser = NX_TAG_1;
        if ([H2Omron sharedInstance].qtsForTag_1 > 0) {
            [H2Omron sharedInstance].qtsForTag_1--;
            [[H2Omron sharedInstance] omronHbfBwGetRecord:[H2Omron sharedInstance].omronIndexArray[[H2Omron sharedInstance].qtsForTag_1]];
#ifdef DEBUG_BW
            DLog(@" UID 1 and %02X", [H2Records sharedInstance].currentUser);
#endif
        }else{ // USER 1 Zero data
            didAnyRecordEnding = YES;
#ifdef DEBUG_BW
            DLog(@"USER 1 NO DATA");
#endif
        }
    }else if ([H2Omron sharedInstance].userIdFilter & USER_TAG2_MASK){
        [H2Records sharedInstance].currentUser = NX_TAG_2;
        if ([H2Omron sharedInstance].qtsForTag_2 > 0) {
            [H2Omron sharedInstance].qtsForTag_2--;
            [[H2Omron sharedInstance] omronHbfBwGetRecord:[H2Omron sharedInstance].omronIndexArray[[H2Omron sharedInstance].qtsForTag_2]];
#ifdef DEBUG_BW
            DLog(@" UID 2 and %02X", [H2Records sharedInstance].currentUser);
#endif
        }else{ // USER 2 Zero data
            didAnyRecordEnding = YES;
#ifdef DEBUG_BW
            DLog(@"USER 2 NO DATA");
#endif
        }
        
    }else if ([H2Omron sharedInstance].userIdFilter & USER_TAG3_MASK){
        [H2Records sharedInstance].currentUser = NX_TAG_3;
        if ([H2Omron sharedInstance].qtsForTag_3 > 0) {
            [H2Omron sharedInstance].qtsForTag_3--;
            [[H2Omron sharedInstance] omronHbfBwGetRecord:[H2Omron sharedInstance].omronIndexArray[[H2Omron sharedInstance].qtsForTag_3]];
#ifdef DEBUG_BW
            DLog(@" UID 3 and %02X", [H2Records sharedInstance].currentUser);
#endif
        }else{ // USER 3 Zero data
            didAnyRecordEnding = YES;
#ifdef DEBUG_BW
            DLog(@"USER 3 NO DATA");
#endif
        }
        
    }else if ([H2Omron sharedInstance].userIdFilter & USER_TAG4_MASK){
        [H2Records sharedInstance].currentUser = NX_TAG_4;
        if ([H2Omron sharedInstance].qtsForTag_4 > 0) {
            [H2Omron sharedInstance].qtsForTag_4--;
            [[H2Omron sharedInstance] omronHbfBwGetRecord:[H2Omron sharedInstance].omronIndexArray[[H2Omron sharedInstance].qtsForTag_4]];
#ifdef DEBUG_BW
            DLog(@" UID 4 and %02X", [H2Records sharedInstance].currentUser);
#endif
        }else{ // USER 4 Zero data
            didAnyRecordEnding = YES;
#ifdef DEBUG_BW
            DLog(@"USER 4 NO DATA");
#endif
        }
        
    }else{
        [H2Omron sharedInstance].omronCmdSel++;
        [H2Omron sharedInstance].normalCmdFlow = YES;
        [H2Omron sharedInstance].parserOrCollectRecord = NO;
        [H2Omron sharedInstance].parserClearIndex = YES;
        goToNextFlow = YES;
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
    }
    
    if (didAnyRecordEnding) {
        goToNextFlow = YES;
        [[H2BleTimer sharedInstance] h2ClearBleTimerTask];
        [self hbfGoToNextUser:[H2Records sharedInstance].currentUser];
    }
    return goToNextFlow;
}


+ (OMRON_HBF_254C *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred = 0;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

@end




