//
//  GlucoCardVital.m
//  h2SyncLib
//
//  Created by h2Sync on 2014/6/19.
//  Copyright (c) 2014年 h2Sync. All rights reserved.
//



#import "H2AudioFacade.h"
#import "GlucoCardVital.h"
#import "H2DebugHeader.h"

#import "H2DataFlow.h"

#define CONST0X30           0x30
#define RELION_RESEND_TIME      2

@implementation GlucoCardVital
{
}


- (id)init
{
    if (self = [super init]) {
        _h2SyncIsVitalHighSpeedMode = NO;
        //_h2SyncVitalIsiOSOnly = NO;
    }
    return self;
}

+ (GlucoCardVital *)sharedInstance
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


unsigned char vitalCmdInit[] = {
    0x06
};
unsigned char vitalCmdBrand[] = {
    0x92, 0x05
};

unsigned char vitalCmdModel[] = {
    'R', '|'
    , 'C', '|'
};
unsigned char vitalCmdSerialNumber[] = {
    'R', '|'
    , 'M', '|'
};

unsigned char vitalCmdRecord[] = {
    'R', '|'
    , 'N', '|'
    , '0', '0', '0', '|'
};



#pragma mark -
#pragma mark GLUCOCARD VITAL COMMAND

- (void)GlucoCardVitalCommandGeneral:(UInt16)cmdMethod
{
    UInt16 currentMeter = [H2DataFlow sharedDataFlowInstance].equipUartProtocol;
    UInt16 cmdLength = 0;
    UInt16 cmdTypeId = 0;
    Byte cmdBuffer[48] = {0};
    switch (cmdMethod) {
        case METHOD_INIT:
            cmdLength = sizeof(vitalCmdInit);
            cmdTypeId = (currentMeter<<4) + METHOD_INIT;
            memcpy(cmdBuffer, vitalCmdInit, cmdLength);
            break;
            
        case METHOD_4:
            cmdLength = sizeof(vitalCmdInit);
            cmdTypeId = (currentMeter<<4) + METHOD_4;
            memcpy(cmdBuffer, vitalCmdInit, cmdLength);
            break;
            
        case METHOD_5:
            cmdLength = sizeof(vitalCmdBrand);
            cmdTypeId = (currentMeter<<4) + METHOD_5;
            memcpy(cmdBuffer, vitalCmdBrand, cmdLength);
            break;
            
        case METHOD_BRAND:
            cmdLength = sizeof(vitalCmdBrand);
            cmdTypeId = (currentMeter<<4) + METHOD_BRAND;
            memcpy(cmdBuffer, vitalCmdBrand, cmdLength);
            break;
            
        case METHOD_MODEL:
            cmdLength = sizeof(vitalCmdModel);
            cmdTypeId = (currentMeter<<4) + METHOD_MODEL;
            memcpy(cmdBuffer, vitalCmdModel, cmdLength);
            break;
            
        case METHOD_SN:
            cmdLength = sizeof(vitalCmdSerialNumber);
            cmdTypeId = (currentMeter<<4) + METHOD_SN;
            memcpy(cmdBuffer, vitalCmdSerialNumber, cmdLength);
            break;
            
        default:
            break;
    }
    
    
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:cmdBuffer withCmdLength:cmdLength cmdType: cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}
- (unsigned char)glucoNumericToChar:(unsigned char)num
{
    unsigned char ch;
    switch (num) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
            ch = num + 0x30;
            break;
        case 0x0A: ch = 'A'; break;
        case 0x0B: ch = 'B'; break;
        case 0x0C: ch = 'C'; break;
        case 0x0D: ch = 'D'; break;
        case 0x0E: ch = 'E'; break;
        case 0x0F: ch = 'F'; break;
            
        default:
            ch = '0';
            break;
    }
    return ch;
}

- (void)GlucoCardVitalRecord:(UInt16)nIndex
{
    UInt16 cmdLength = sizeof(vitalCmdRecord);
    UInt16 cmdTypeId = ([H2DataFlow sharedDataFlowInstance].equipUartProtocol<<4) + METHOD_RECORD;
 
    vitalCmdRecord[4] = [self glucoNumericToChar:(unsigned char)(nIndex & 0xF00)>>8];
    vitalCmdRecord[5] = [self glucoNumericToChar:(unsigned char)(nIndex & 0xF0)>>4];
    vitalCmdRecord[6] = [self glucoNumericToChar:(unsigned char)(nIndex & 0xF)];
    
    [[H2AudioFacade sharedInstance] sendCommandDataEx:vitalCmdRecord withCmdLength:cmdLength cmdType:cmdTypeId returnDataLength:0 mcuBufferOffSetAt:0];
}



/////////////////////////////////////////////////////

@end
