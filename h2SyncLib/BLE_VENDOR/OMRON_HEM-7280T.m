//
//  OMRON_HEM-7280T.m
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
#import "H2Sync.h"
#import "H2AudioHelper.h"

#import "H2BleOad.h"
#import "H2BgmCable.h"

#import "OMRON_HEM-7280T.h"
#import "H2Records.h"

#import "H2LastDateTime.h"
#import "H2BleTimer.h"

#import "H2DataFlow.h"
#import "H2BleEquipId.h"


@interface OMRON_HEM_7280T()
{
}

@end



@implementation OMRON_HEM_7280T

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}



#pragma mark - COMMAND REFERENCE
/**************************************************************************************************
///////////////////////////
// A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 A1 Task ...
//
///////////////////////////
**************************************************************************************************/
//unsigned char hem7280tCmd4_GetHardwareInfo[] = {
//    0x08, 0x00, 0x00, 0x00,    0x00, 0x10, 0x00, 0x18
//};

#pragma mark - DEFAULT VALUE(TAG and TIME)
const UInt8 userTag[] =
{
    0x01, 0x00, 0xFF, 0x01,
    0xCA, 0x01,
    0x08, 0x48
};



#pragma mark - DATA COME BACK
- (void)h2OmronHem7280TDataProcess
{
    // 0 : Hardware Info
    if ([H2Omron sharedInstance].parserHardwareInfo) {
        [[H2Omron sharedInstance] omronHardwareInfoParser];
    }
    
    // 1 : Current Time
    if ([H2Omron sharedInstance].parserCurrentTime) {
        [self hem7280TCurrentTimeParser];
        // Go to SET TAG or Report Meter Info
        return;
    }
/*
        // Pairing Stage
        if ( ![H2Omron sharedInstance].parserCurrentTime && [H2Omron sharedInstance].setUserIdMode) {
#ifdef DEBUG_BP
            DLog(@"7280T - SHOW SET USER ID DIALOG");
#endif
            return;
        }
        
        // HYNC Stage
        //[H2SyncReport sharedInstance].didSendEquipInformation = YES;
        return;
    }
*/
    // 2 : Set User ID, SKIP
    if ([H2Omron sharedInstance].parserSetTagProfile) {
        [self hem7280TSetUserIdParser];
    }
    
    // 3 : Set Current Time
    if ([H2Omron sharedInstance].parserSetCurrentTime) {
        [self hem7280TSetCurrentTimeParser];
    }
    
    
    // 4 : Record(s) Stage
    if ([H2Omron sharedInstance].parserOrCollectRecord) {
        //[self hem7280TRecordsParser];
        [[H2Omron sharedInstance] omronHemRecordsParser];
    }
    
    // 5 : Clear Index
    if ([H2Omron sharedInstance].parserClearIndex) {
        [H2Omron sharedInstance].parserClearIndex = NO;
        [H2Omron sharedInstance].parserFinished = YES;
    }
    
    // 6 : Finish
    if ([H2Omron sharedInstance].parserFinished) {
        [H2Omron sharedInstance].parserFinished = NO;
        [[H2BleTimer sharedInstance] h2SetBleTimerTask:OMRON_CMD_INTERVAL taskSel:BLE_TIMER_OMRON_HEM_CMD_FLOW];
        //[self h2OmronHem7280TA1CmdFlow];
    }
}



///////////////////////////////////////////////////////
// HEM-7280T COMMAND FLOW
//
//
///////////////////////////////////////////////////////


#pragma mark - COMAND A1 FLOW
- (void)OMRON_Hem7280T_GetRecordInit
{
     for(int i=0; i<2; i++){
         if([H2Omron sharedInstance].userIdFilter & (1 << i)){
#ifdef DEBUG_BP
             DLog(@"OMRON CURRENT USER %02X", (1 << i));
#endif
             [H2SyncReport sharedInstance].serverBpLastDateTime = [[H2SvrLastDateTime sharedInstance] h2GetCurrentSvrLastTime:RECORD_TYPE_BP withUserId:(1<< i)];
             break;
         }
     }
    [self h2OmronHem7280TA1CmdFlow];
}


- (void)h2OmronHem7280TA1CmdFlow
{
#ifdef DEBUG_BP
    NSLog(@"HEM-XXX CMD A1 FLOW = %d", [H2Omron sharedInstance].omronCmdSel);
#endif
    if ([H2Omron sharedInstance].omronCmdSel > HBF_CMD_B) {
        [H2Omron sharedInstance].setUserIdMode = NO;
#ifdef DEBUG_BP
        DLog(@"HEM-7280T COMMAND END  == %d", [H2Omron sharedInstance].omronCmdSel);
#endif
        return;
    }
    
    // Clear Command Buffer (BUFFER INIT)
    [[H2Omron sharedInstance]omronBufferInit];
    
    switch ([H2Omron sharedInstance].omronCmdSel) {
        case HBF_CMD_5:
            [H2Records sharedInstance].currentDataType = RECORD_TYPE_BP;
            [[H2Omron sharedInstance] omronGetIndexCurrentTime];
            
            // Skip Set User Tag And Always Set Current Time
            [H2Omron sharedInstance].omronCmdSel++;
            [H2Omron sharedInstance].reportIndex = 0;
            // Get Set Current Time Address
            switch ([H2DataFlow sharedDataFlowInstance].equipId) {
                case SM_BLE_OMRON_HEM_7280T:
                case SM_BLE_OMRON_HEM_7600T:
                    [H2Omron sharedInstance].hemTimeAddr = HEM_7280T_TIME_ADDR;
                    break;
                    
                case SM_BLE_OMRON_HEM_6320T:
                case SM_BLE_OMRON_HEM_6324T:
                    [H2Omron sharedInstance].hemTimeAddr = HEM_6320T_STIMER_ADDR;
                    break;
                    
                default:
                    break;
            }
            
            /*
             if ([H2Omron sharedInstance].setUserIdMode) {
             #ifdef SKIP_INDEX
             [H2Omron sharedInstance].omronCmdSel++;// Skip Set User Tag
             #endif
             }else{
             [H2Omron sharedInstance].reportIndex = 0;
             [H2Omron sharedInstance].omronCmdSel += 2;
             }
             */
#ifdef DEBUG_BP
            DLog(@"HEM-COMAND-5 GET CURRENT TIME, LEN = %02X", [H2Omron sharedInstance].cmdLength);
#endif
            break;
            
        case HBF_CMD_6: // Set User Id
            [H2Omron sharedInstance].cmdLength = OM_MAX_CMDBUF_LEN;
            [H2Omron sharedInstance].parserSetTagProfile = YES;
            
            [self hemSetUserTag];
            break;
            
        case HBF_CMD_7: // // Set Current Time
            [H2Omron sharedInstance].cmdLength = OM_MAX_CMDBUF_LEN;
            [H2Omron sharedInstance].parserSetCurrentTime = YES;
            [self hemSetCurrentTime];
            
            if ([H2Omron sharedInstance].setUserIdMode) {
                [H2Omron sharedInstance].omronCmdSel += 2;
            }
            
            break;
            
        case HBF_CMD_8:
            [H2Omron sharedInstance].normalCmdFlow = NO;
            [H2Omron sharedInstance].parserOrCollectRecord = YES;
            if ([[H2Omron sharedInstance] omronHemRecordCmdProcess]) {
                [[H2BleTimer sharedInstance] h2SetBleTimerTask:OMRON_CMD_INTERVAL taskSel:BLE_TIMER_OMRON_HEM_CMD_FLOW];
                //[NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(h2OmronHem7280TA1CmdFlow) userInfo:nil repeats:NO];
                return;
            }
            break;
            
        case HBF_CMD_9:
#ifdef DEBUG_LIB
            NSLog(@"CMD-9 ERROR");
#endif
            [[H2Omron sharedInstance] omronIndexCmdProcess];
            break;
            
        case HBF_CMD_A:
            [[H2Omron sharedInstance] cmdDone];
            break;
            
        default:
            break;
    }
    [[H2Omron sharedInstance] omronWriteA1Task];
}



//////////////////////////////////////////////
// Data Process and Parser
#pragma mark - HEM-7280T PARSER PARSER
- (void)hem7280TSetUserIdParser
{
    [H2Omron sharedInstance].parserSetTagProfile = NO;
    [H2Omron sharedInstance].parserFinished = YES;
}
- (void)hem7280TSetCurrentTimeParser
{
    [H2Omron sharedInstance].parserSetCurrentTime = NO;
    [H2Omron sharedInstance].parserFinished = YES;
}



- (void)hem7280TCurrentTimeParser
{
    UInt16 dataSum = 0;
    UInt8 dataCrc = 0;
    
    UInt16 hemYear = 0;
    
    UInt8 hemMonth = 0;
    UInt8 hemDay = 0;
    
    UInt8 hemHour = 0;
    UInt8 hemMinute = 0;
    UInt8 hemSecond = 0;
    
    //Byte *buffer = (Byte *)malloc(8);
    
    
    if ([H2Omron sharedInstance].omronDataLength == HEM_7280T_UID_DATA_LEN) {
        [H2Omron sharedInstance].parserCurrentTime = NO;
#ifdef DEBUG_BP
        DLog(@"DECODE START -- ");
#endif
        for (int i=0; i<36; i++) {
            dataSum ^= [H2Omron sharedInstance].omronA0Buffer[i];
#ifdef DEBUG_BP
            DLog(@"CRC = %d  %04X, %02X", i, dataSum, [H2Omron sharedInstance].omronA0Buffer[i]);
#endif
        }
#ifdef DEBUG_BP
        DLog(@"\n\n");
#endif
        dataSum = 0;
        for (int i=0; i<6; i++) {
            dataSum += [H2Omron sharedInstance].omronA0Buffer[28+i];
#ifdef DEBUG_BP
            DLog(@"SUM = %d  %04X, %02X", i, dataSum, [H2Omron sharedInstance].omronA0Buffer[28+i]);
#endif
        }
        
        dataCrc = 0;
        
        dataSum -= 0x30;
        switch (dataSum & 0xF0) { // HIGH Nibble
            case 0xC0:case 0xD0:case 0xE0:case 0xF0:
                dataCrc = ((dataSum & 0xF0) >> 4) - 0x0C;
                break;
            case 0x80:case 0x90:case 0xA0:case 0xB0:
                dataCrc = ((dataSum & 0xF0) >> 4) - 4;
                break;
                
            case 0x40:case 0x50:case 0x60:case 0x70:
                dataCrc = ((dataSum & 0xF0) >> 4) + 4;
                break;
                
            default:
                dataCrc = ((dataSum & 0xF0) >> 4) + 0x0C;
                break;
        }
        
        dataCrc <<= 4;
#ifdef DEBUG_BP
        DLog(@"HI NIBBLE = %02X", dataCrc);
#endif
        switch (dataSum & 0x0F) { // LOW NIBBLE
            case 0xC:case 0xD:case 0xE:case 0xF:
            case 0x4:case 0x5:case 0x6:case 0x7:
                dataCrc += (0x13 - (dataSum & 0x0F)) ;
                break;
                
            default:
                dataCrc += (0x0B - (dataSum & 0x0F)) ;
                break;
        }
        
#ifdef DEBUG_BP
        DLog(@"OTHER %02X", dataCrc);
        DLog(@"\n\n");
#endif
        
        dataSum = 0;
        for (int i=0; i<6; i++) {
            dataSum += (![H2Omron sharedInstance].omronA0Buffer[14+i]);
        }
        
        
        hemYear = [H2Omron sharedInstance].omronA0Buffer[28+1] + 2000;
        hemMonth = [H2Omron sharedInstance].omronA0Buffer[28];
        hemDay = [H2Omron sharedInstance].omronA0Buffer[30+1];
        
        
        hemHour =  [H2Omron sharedInstance].omronA0Buffer[30];
        hemMinute = [H2Omron sharedInstance].omronA0Buffer[32+1];
        hemSecond = [H2Omron sharedInstance].omronA0Buffer[32];
        
        [H2SyncReport sharedInstance].reportMeterInfo.smCurrentDateTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d +0000", hemYear, hemMonth, hemDay, hemHour, hemMinute, hemSecond];
#ifdef DEBUG_BP
        DLog(@"OMRON CURREN TIME IS :");
        DLog(@"%04d-%02d-%02d %02d:%02d:%02d +0000", hemYear, hemMonth, hemDay, hemHour, hemMinute, hemSecond);
        
        
        DLog(@"年 : %d, 月 : %d, 日 : %d", [H2Omron sharedInstance].omronA0Buffer[28+1] + 2000, [H2Omron sharedInstance].omronA0Buffer[28], [H2Omron sharedInstance].omronA0Buffer[30+1]);
        DLog(@"時 : %d, 分 : %d, 秒 : %d", [H2Omron sharedInstance].omronA0Buffer[30], [H2Omron sharedInstance].omronA0Buffer[32+1], [H2Omron sharedInstance].omronA0Buffer[32]);
#endif
        
        dataCrc = 0;
        for (int i=0; i<[H2Omron sharedInstance].omronDataLength; i++) {
            dataCrc ^= [H2Omron sharedInstance].omronA0Buffer[i];
#ifdef DEBUG_BP
            DLog(@"CRC = %d  %04X, %02X", i, dataCrc, [H2Omron sharedInstance].omronA0Buffer[i]);
#endif
        }
        // Store Record Index
        memcpy([H2Omron sharedInstance].tmpIndexBuffer, &[H2Omron sharedInstance].omronA0Buffer[6], 8);
        
#ifdef DEBUG_BP
        if ([H2Omron sharedInstance].omronA0Buffer[14] == 0xFF && [H2Omron sharedInstance].omronA0Buffer[15] == 0xFF) {
            DLog(@"UID 1 NOT SET");
        }
        if ([H2Omron sharedInstance].omronA0Buffer[20] == 0xFF && [H2Omron sharedInstance].omronA0Buffer[21] == 0xFF) {
            DLog(@"UID 2 NOT SET");
        }
#endif
        
        if ([H2Records sharedInstance].multiUsers) {
            if ([H2Omron sharedInstance].omronA0Buffer[14] == 0x01 && [H2Omron sharedInstance].omronA0Buffer[15] == 0x00) {
                [H2Omron sharedInstance].userIdStatus |= USER_TAG1_MASK;
#ifdef DEBUG_BP
                DLog(@"UID 1 HAS SET and Records #####");
#endif
            }
            
            if ([H2Omron sharedInstance].omronA0Buffer[20] == 0x01 && [H2Omron sharedInstance].omronA0Buffer[21] == 0x00) {
                [H2Omron sharedInstance].userIdStatus |= USER_TAG2_MASK;
#ifdef DEBUG_BP
                DLog(@"UID 2 HAS SET and Records ******");
#endif
            }
        }else{
            [H2Omron sharedInstance].userIdStatus |= USER_TAG1_MASK;
            [H2Omron sharedInstance].userIdStatus ^= USER_TAG2_MASK;
        }
        // NEW
        
        [H2Omron sharedInstance].addrForTag_1 = [H2Omron sharedInstance].omronA0Buffer[7] & HEM_INDEX_MASK;
        [H2Omron sharedInstance].addrForTag_2 = [H2Omron sharedInstance].omronA0Buffer[9] & HEM_INDEX_MASK;
        
        [H2Omron sharedInstance].qtsForTag_1 = [H2Omron sharedInstance].omronA0Buffer[11] & HEM_INDEX_MASK;
        [H2Omron sharedInstance].qtsForTag_2 = [H2Omron sharedInstance].omronA0Buffer[13] & HEM_INDEX_MASK;
        
        // for TEST
#if 0
        [H2Omron sharedInstance].qtsForTag_1 = 10;//BP_RECORDS_MAX;
        [H2Omron sharedInstance].qtsForTag_2 = 10;//BP_RECORDS_MAX;
#endif
        
        if ([H2Omron sharedInstance].qtsForTag_1 > BP_RECORDS_MAX) {
            [H2Omron sharedInstance].qtsForTag_1 = BP_RECORDS_MAX;
        }
        if ([H2Omron sharedInstance].qtsForTag_2 > BP_RECORDS_MAX) {
            [H2Omron sharedInstance].qtsForTag_2 = BP_RECORDS_MAX;
        }
        
        if ([H2Omron sharedInstance].userIdFilter & USER_TAG1_MASK) {
            if ([H2Omron sharedInstance].qtsForTag_1>0) {
                [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_1 withIdx:[H2Omron sharedInstance].addrForTag_1 omronTypeHem:YES];
            }
        }else if([H2Omron sharedInstance].userIdFilter & USER_TAG2_MASK){
            if ([H2Omron sharedInstance].qtsForTag_2>0) {
                [[H2Omron sharedInstance] addrQtyProcess:[H2Omron sharedInstance].qtsForTag_2 withIdx:[H2Omron sharedInstance].addrForTag_2 omronTypeHem:YES];
            }
        }
        
        [[H2Omron sharedInstance] omronCheckSerialNumber:[H2Omron sharedInstance].userIdStatus];
        // Get Records Command Process or Show Set User Id Dialog
    }
}


#pragma mark - SET USER ID (EXTERNAL)
- (void)OmronHem7280TSetUserId:(UInt8)userId
{
    UInt8 uMask = 0;
    if (userId > 0) {
        uMask = userId-1;
    }
    
    if (uMask > 1) {
        uMask = 1;
    }
    
    
    [H2Omron sharedInstance].userSetId = userId;
    switch ([H2DataFlow sharedDataFlowInstance].equipId) {
        case SM_BLE_OMRON_HEM_7280T:
        case SM_BLE_OMRON_HEM_7600T:
            [H2Omron sharedInstance].hemTimeAddr = HEM_7280T_TIME_ADDR;
            if (USER_TAG2_MASK == (1 << uMask)) {
                //[H2Omron sharedInstance].hemTimeAddr = HEM_7280T_TIME2_ADDR;
            }
            break;
            
        case SM_BLE_OMRON_HEM_6320T:
        case SM_BLE_OMRON_HEM_6324T:
            [H2Omron sharedInstance].hemTimeAddr = HEM_6320T_STIMER_ADDR;
            if (USER_TAG2_MASK == (1 << uMask)) {
                //[H2Omron sharedInstance].hemTimeAddr = HEM_6320T_TIME2_ADDR;
            }
            break;
            
        default:
            break;
    }
    [self h2OmronHem7280TA1CmdFlow];
}

#pragma mark - OMRON (HEM)SET USER TAG
- (void)hemSetUserTag // CMD 6
{
    UInt8 crcTmp = 0;
    UInt8 tagTmpCmd[OMRRON_COMMAND_SIZE] = {0};
    
    tagTmpCmd[1] = OM_FLASH_AREA;
    tagTmpCmd[2] = OM_WRITE_FLASH;
    
    tagTmpCmd[3] = ([H2Omron sharedInstance].hemTagAddr & 0xFF00)>>8;
    tagTmpCmd[4] = [H2Omron sharedInstance].hemTagAddr & 0xFF;
    
    tagTmpCmd[0] = HEM_UID_TOTAL_LEN;
    tagTmpCmd[5] = HEM_UID_TOTAL_DATA_LEN;
    
    memcpy(&tagTmpCmd[6], [H2Omron sharedInstance].tmpIndexBuffer, 8);
    memcpy(&tagTmpCmd[0x0E], userTag, 6);
    memcpy(&tagTmpCmd[0x0E + 0x06], userTag, 6);
    
    for (int i = 0; i<tagTmpCmd[0]-1; i++) {
        crcTmp ^= tagTmpCmd[i];
    }
    tagTmpCmd[tagTmpCmd[0]-1] = crcTmp;
    memcpy([H2Omron sharedInstance].omronHemCmd, tagTmpCmd, OMRRON_COMMAND_SIZE);
    [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(hemA2CmdTask) userInfo:nil repeats:NO];
    
    
}


#pragma mark - OMRON (HEM)SET CURRENT TIME
- (void)hemSetCurrentTime // CMD 7
{
    // Create and Get System Time
    [self hemCreateCurrentTime];
    
    // A2 command
    [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(hemA2CmdTask) userInfo:nil repeats:NO];
}

- (void)hemA2CmdTask
{
    [[H2Omron sharedInstance] omronSencondCommand];
}



#pragma mark - CREATE and GET SYSTEM CURRENT TIME
- (void)hemCreateCurrentTime
{
    Byte  *timeBuffer;
    timeBuffer = [[H2BleTimer sharedInstance] systemCurrentTime];
    
    UInt8 year = timeBuffer[0]; //[components year];
    UInt8 month = timeBuffer[1]; //[components month];
    UInt8 day = timeBuffer[2]; //[components day];
    
    UInt8 hour = timeBuffer[3]; //[components hour];
    UInt8 minute = timeBuffer[4]; //[components minute];
    UInt8 second = timeBuffer[5]; //[components second];
    
#ifdef DEBUG_BP
    DLog(@"DEMO-DEBUG Y:%04X, M:%02X, D:%02X", year, month, day);
    DLog(@"DEMO-DEBUG H:%02X, MIN:%02X, SEC:%02X", hour, minute, second);
    DLog(@"OMRON Y:%04X, M:%02X, D:%02X", year, month, day);
#endif
    UInt8 crcTmp = 0;
    UInt8 tmpTime[6] = {0};
    
    
    UInt8 cmdTmpForTime[32] = {0};
    
    cmdTmpForTime[1] = OM_FLASH_AREA;
    cmdTmpForTime[2] = OM_WRITE_FLASH;
    
    cmdTmpForTime[3] = ([H2Omron sharedInstance].hemTimeAddr & 0xFF00)>>8;
    cmdTmpForTime[4] = [H2Omron sharedInstance].hemTimeAddr & 0xFF;
    
    //
    tmpTime[0] = month;
    tmpTime[1] = year;
    
    tmpTime[2] = hour;
    tmpTime[3] = day;
    
    tmpTime[4] = second;
    tmpTime[5] = minute;
    
    
    for (int i = 0; i<6; i++) {
        crcTmp += tmpTime[i];
#ifdef DEBUG_BP
        DLog(@"SUM - ID1 %d, %02X, %02X", i, crcTmp, tmpTime[i]);
#endif
    }
    
    switch ([H2Omron sharedInstance].userSetId) {
            /*
             case USER_TAG2_MASK:
             
             cmdTmpForTime[0] = 0x18;
             cmdTmpForTime[5] = 0x10;
             
             memcpy(&cmdTmpForTime[6], userTag, 8);
             memcpy(&cmdTmpForTime[8+6], tmpTime, 6);
             
             cmdTmpForTime[14+6] = 0x54;
             cmdTmpForTime[15+6] = crcTmp + (cmdTmpForTime[14+6] & 0xF0);
             
             break;
             
             */
        case USER_TAG1_MASK:
        default:
            cmdTmpForTime[0] = HEM_TIME_TOTAL_LEN;//0x12;
            cmdTmpForTime[5] = HEM_TIME_TOTAL_DATA_LEN; //0x0A;
            
            memcpy(&cmdTmpForTime[6], &userTag[6], 2);
            memcpy(&cmdTmpForTime[8], tmpTime, 6);
            cmdTmpForTime[14] = 0x54;
            cmdTmpForTime[15] = crcTmp + (cmdTmpForTime[14] & 0xF0);
            break;
    }
#ifdef DEBUG_BP
    DLog(@"\n\n");
#endif
    
    crcTmp = 0;
    for (int i = 0; i<cmdTmpForTime[0]-1; i++) {
        crcTmp ^= cmdTmpForTime[i];
#ifdef DEBUG_BP
        DLog(@"CRC - ID2 %d, %02X, %02X", i, crcTmp, cmdTmpForTime[i]);
#endif
    }
    
    cmdTmpForTime[cmdTmpForTime[0]-1] = crcTmp;
    
    memcpy([H2Omron sharedInstance].omronHemCmd, cmdTmpForTime, OMRRON_COMMAND_SIZE);
}



+ (OMRON_HEM_7280T *)sharedInstance
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
    

/*
 0x16, 0x01, 0xC0, 0x02,     0x86, 0x0E, 0x00, 0x00,
 0x00, 0x00, 0x80, 0x00,     0x00, 0x00, 0x01, 0x00,
 
 0x00, 0x01, 0x00, 0x02,     0x00, 0xDF, 0x00, 0x00,
 0x00, 0x94, 0x02, 0x13,     0x10, 0x05, 0x15, 0x7D
 */
