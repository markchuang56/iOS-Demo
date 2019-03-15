//
//  TMSwitch.m
//  APX
//
//  Created by h2Sync on 2016/4/20.
//  Copyright © 2016年 h2Sync. All rights reserved.
//

#import "TMSwitch.h"
#import "LibDelegateFunc.h"

#import "STBViewController.h"

#import "H2TestMode.h"


#define REPORT_DATA_LEN_UART                        11
#define REPORT_DATA_LEN_IRDA                        13
#define REPORT_COMPARE_OFFSET_UART                  4
#define REPORT_COMPARE_OFFSET_IRDA                  6

#define AUDIO_MAXIMUM_VOLUME                        1.0f


#define SM_TEST_MODE_UART                           0x20


#import <Foundation/NSDateFormatter.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>


#import "h2MeterRecordInfo.h"
#import "ToolCableViewController.h"
#import "QRCodeViewController.h"


#import <CoreTelephony/CTCall.h>


#define BAUDRATE_MAX                        3
#define INVERTER_MAX                        1
#define SWITCH_MAX                          5


#define BAUDRATE_INIT                       3
#define INVERTER_INIT                       0
#define SWITCH_INIT                         0

#define SW_MODE_AT                          0
#define NOR_INV_AT                          1
#define BAUD_RATE_AT                        2

#define SWITCH_LEN                          5


#define COIF_BAUDRATE                       0x01
#define COIF_PARITY                         0x10
#define COIF_STOP                           0x40
#define COIF_BIT                            0x80

#define COIF_SWITCH                         0x01
#define COIF_NORINV                         0x10
#define COIF_IR                             0x80

#ifdef IRDA_MODE
static unsigned char cmdHeader[] = {0x32, 0x01, 0x00, 0x00, 0x00, 0x00};    // Performa, Record command
#else
static unsigned char cmdHeader[] = {0x01, 0x06, 0x00, 0x00, 0x00, 0x00};
#endif



// {0x01, 0x06, 0x03, 0x04, 0x05, 0x07};
unsigned char swModeBuffer[5] = {0};



@interface H2TMSwitch () {
    
    
    UIAlertView *cableStatusAlertView;
    UIAlertView *wantToSyncAlertView;
    
    
    UInt32 snNumber;
    UInt16 swTestCycle;
    UInt16 swTotalCycle;
    
    NSTimer *swTimer;
    NSTimer *swCycleTimer;
    
    //
    NSArray *switchArray;
    NSArray *invNorArray;
    NSArray *baudRateArray;
    
    UIAlertView *cyclePassAlertView;
    UIAlertView *cycleFailAlertView;
    
    BOOL    switch_mode;
    BOOL    sn_reading_mode;
    BOOL    UartIrDATestStatus;
    
}



@end

@implementation H2TMSwitch




- (id)init
{
    if (self = [super init]) {
        _scanMode = NO;
    }
    return self;
}



- (void) receiveTestNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"BLE_SW_Notification"])
    {
        NSLog (@"Successfully received BLE SW notification!");
        //        currentMeter.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentMeter"];
    }else if ([[notification name] isEqualToString:@"syncIncNotification"]){
        NSLog(@"notification test ");
    }
}

#pragma mark -
#pragma mark H2 AudioDelegate implementation



- (BOOL)btSwitchSerialNumber
{
    return YES;
}


#pragma mark - TM TOOL METHOD
// 掃描 TOOL
- (UInt8)toolModeScanTool
{
    if (_switchTestMode) {
        // 若在測試過程中按下測試鈕，無動作
        return TEST_MODE;
    }
    return 0;
}

// 加入 TOOL
- (UInt8)toolModeAdTool
{
    if (_switchTestMode) {
        // 若在測試過程中按下測試鈕，無動作
        return TEST_MODE;
    }
    
    return 0;
}
// 設定(刪除)或顯示TOOL列表
- (UInt8)toolModeShowOrDeleteTools
{
    if (_switchTestMode) {
        // 若在測試過程中按下測試鈕，無動作
        return TEST_MODE;
    }
    return 0;
}

#pragma mark - TM SWITCH TEST START ...

- (BOOL)testModeSwitchStart
{
    // 測試按下測試按鈕，就會呼叫此程序，
    // 進入測試...
    if (_switchTestMode) {
        // 若在測試過程中按下測試鈕，無動作
 //j       return TEST_MODE;
    }
    
    // 重置測試模式
    [self testModeSwitchReset];
    
    // 將測試模式的旗標設為 是
    _switchTestMode = YES;

    
    // 將5個bytes 的測試訊息，傳到SDK
    // SDK 將會按此訊息，開始設定Cable 的uart
    // 介面的模式，(傳送meter command header, 將會在掃描TOOL時傳入)
    [self testModeUartCmdConfigFirst];
    [self testModeUartCmdConfigSecond];


    return YES;
}

#pragma mark - TM SWITCH CHECKING FOR CYCLE RUN
- (BOOL)testModeSwitchChecking
{
    // 每次測試完，收到已關閉Switch訊息後，
    // 即進入檢查是否測試結束

    if (swTestCycle) {
        if (_uartSwitch < SWITCH_MAX) {
            _uartSwitch++;
        }else{
            if (_uartInverter < INVERTER_MAX) {
                _uartSwitch = 0;
                _uartInverter++;
            }else{
                _uartSwitch = 0;
                _uartInverter = 0;
                if (_uartBaudRate < BAUDRATE_MAX) {
                    _uartBaudRate++;
                }else{
                    _uartBaudRate = 0;
                }
            }
        }
        
        [self testModeUartCmdConfigFirst];
        
        _uartSwitchNext = _uartSwitch;
        _uartInverterNext = _uartInverter;
        _uartBaudRateNext = _uartBaudRate;
        
        if (_uartSwitchNext < SWITCH_MAX) {
            _uartSwitchNext++;
        }else{
            if (_uartInverterNext < INVERTER_MAX) {
                _uartSwitchNext = 0;
                _uartInverterNext++;
            }else{
                _uartSwitchNext = SWITCH_INIT;
                _uartInverterNext = 0;
                if (_uartBaudRateNext < BAUDRATE_MAX) {
                    _uartBaudRateNext++;
                }else{
                    _uartBaudRateNext = BAUDRATE_INIT;
                }
            }
        }
        
        [self testModeUartCmdConfigSecond];
        

    }else{
        // 測試結束
        // 顯示測試結果
    }
    return YES;
}

#pragma mark - TM SWITCH SET COMMAND BUFFER

- (void)testModeUartCmdConfigFirst
{
    // 設定 UART 模式
    swModeBuffer[0] = (_uartIrDA * COIF_IR) | (_uartInverter * COIF_NORINV) | _uartSwitch;
    swModeBuffer[1] = (_uartBits * COIF_BIT) | (_uartStop * COIF_STOP) | (_uartParity * COIF_PARITY) | _uartBaudRate;
    swModeBuffer[2] = swTotalCycle - swTestCycle;
}

- (void)testModeUartCmdConfigSecond
{
    // 設定 UART 下一個模式
    swModeBuffer[3] = (_uartIrDANext * COIF_IR) | (_uartInverterNext * COIF_NORINV) | _uartSwitchNext;
    swModeBuffer[4] = (_uartBitsNext * COIF_BIT) | (_uartStopNext * COIF_STOP) | (_uartParityNext * COIF_PARITY) | _uartBaudRateNext;
    
//#ifdef IRDA_MODE
    swModeBuffer[0] |= 0x80;
//#endif
    
    for (int i = 0; i<SWITCH_LEN; i++) {
        NSLog(@"UART NEXT the buffer %d is %02X", i, swModeBuffer[i]);
    }
    
    // 傳送 UART 模式資料給 SDK
    [[H2TestMode sharedInstance] TMSWDevModeStart:swModeBuffer withDevSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode];
//    [[LibDelegateFunc sharedInstance] h2LibSwitchInit:swModeBuffer withUartLength:SWITCH_LEN andMeterCmdHeader:cmdHeader];
    swTestCycle--;
    
    // Test
    /*
     self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%02d, %02d, %02d, %02d,\n", swTotalCycle-swTestCycle,_uartSwitch, _uartInverter, _uartBaudRate];
     
     self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@  ",[switchArray objectAtIndex:_uartSwitch]];
     self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@  ",[invNorArray objectAtIndex:_uartInverter]];
     self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@\n\n",[baudRateArray objectAtIndex:_uartBaudRate]];
     */

}


#pragma mark - TM SWITCH RESET (INIT)
- (BOOL)testModeSwitchReset
{
    // 重設(或初始化)
    _uartBaudRate = BAUDRATE_INIT;
    _uartInverter = INVERTER_INIT;
    _uartSwitch = SWITCH_INIT;
    
    _uartBaudRateNext = BAUDRATE_INIT;
    
    _uartParityNext = 0;
    _uartStopNext = 0;
    _uartBitsNext = 0;
    
    _uartInverterNext = 0;
    _uartSwitchNext = SWITCH_INIT + 1;
    
    
    // 測試次數
    swTestCycle = (SWITCH_MAX+1) * (INVERTER_MAX+1) * (BAUDRATE_MAX+1-BAUDRATE_INIT);
    swTotalCycle = swTestCycle;
    [[NSUserDefaults standardUserDefaults] setInteger:SM_TEST_MODE_UART forKey:@"meter_sel"];
    
    
    _uartIrDA = 0;
    _uartIrDANext = 0;
    
    // 非 IrDA
    UartIrDATestStatus = NO;
    
/*
    cyclePassAlertView = [[UIAlertView alloc] initWithTitle:@"PASS" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    cycleFailAlertView = [[UIAlertView alloc] initWithTitle:@"FAIL" message:nil delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:nil, nil];
*/    
    
    // TEST 內容
    switchArray = [[NSArray alloc] initWithObjects:@"GRT",@"GTR",@"RTG",@"TRG",@"RGT",@"TGR",nil];
    invNorArray = [[NSArray alloc] initWithObjects:@"norTnorR",@"invTinvR",@"invTnorR",@"norTinvR",nil];
    baudRateArray = [[NSArray alloc] initWithObjects:@"b 1200",@"b 2400",@"b 4800",@"b 9600",@"b 19200",@"b 38400",@"b 56000",@"b 115200",@"b 128000",nil];
    
    NSLog(@"BLE SW TEST -- RESET TASK ...");
    
    return YES;
}

#pragma mark -
#pragma mark Uart Switching Test



#if 0


- (IBAction)switchTestButton:(id)sender { // SW 1
    
    if (_switchTestMode) {
        return;
    }
/*
    _testStatus.text = @"...";
    _testStatus.textColor = [UIColor blueColor];
    self.consoleView.text = @"";
    
    _serialNumber.text = [NSString stringWithFormat:@"SN : ..."];
*/
    _switchTestMode = YES;
    switch_mode = NO;
    swTestCycle = 0;
    
    // AUDIO OR BLE CABLE
    
/*
    [[NSUserDefaults standardUserDefaults] setInteger:SM_TEST_MODE_UART forKey:@"meter_sel"];
    
    BOOL hasCable = [[NSUserDefaults standardUserDefaults] boolForKey:@"cableExist"];
    NSError *error;
    if (hasCable) {
        [[H2Sync sharedInstance] start:&error];
        [self H2SetAudioVolumeMax];
        [NSTimer scheduledTimerWithTimeInterval:1.2
                                         target:self
                                       selector:@selector(switchTestInit)
                                       userInfo:nil
                                        repeats:NO];
        
        NSLog(@"set audio volume.+++++++++ start +++++++++");
    }
*/
}

- (void)switchTestInit{ // SW 2
    
    if (_switchTestMode) {
        sn_reading_mode = YES;
//J        [[H2Sync sharedInstance] h2CableSerialNumber: nil withLength:0 reading:YES];
    }else{
        _uartBaudRate = BAUDRATE_INIT;
        
        _uartInverter = INVERTER_INIT;
        _uartSwitch = SWITCH_INIT;
        
        swModeBuffer[0] = (_uartIrDA * COIF_IR) | (_uartInverter * COIF_NORINV) | _uartSwitch;
        swModeBuffer[1] = (_uartBits * COIF_BIT) | (_uartStop * COIF_STOP) | (_uartParity * COIF_PARITY) | _uartBaudRate;
        swModeBuffer[2] = swTotalCycle - swTestCycle;
        
// J        [[H2Sync sharedInstance]h2SwitchTest:swModeBuffer withLength:SWITCH_LEN withFlag:NO];
    }
}

- (void)SwitchTestStart // SW 3
{
    _uartBaudRate = BAUDRATE_INIT;
    
    _uartInverter = INVERTER_INIT;
    _uartSwitch = SWITCH_INIT;
    
    
    _uartBaudRateNext = BAUDRATE_INIT;
    
    _uartParityNext = 0;
    _uartStopNext = 0;
    _uartBitsNext = 0;
    
    _uartInverterNext = 0;
    _uartSwitchNext = SWITCH_INIT + 1;
    
    _uartIrDANext = 0;
    
    
    
    swTestCycle = (SWITCH_MAX+1) * (INVERTER_MAX+1) * (BAUDRATE_MAX+1-BAUDRATE_INIT);
    swTotalCycle = swTestCycle;
    
    
    swModeBuffer[0] = (_uartIrDA * COIF_IR) | (_uartInverter * COIF_NORINV) | _uartSwitch;

    swModeBuffer[1] = (_uartBits * COIF_BIT) | (_uartStop * COIF_STOP) | (_uartParity * COIF_PARITY) | _uartBaudRate;
    swModeBuffer[2] = swTotalCycle - swTestCycle;
    
    swModeBuffer[3] = (_uartIrDANext * COIF_IR) | (_uartInverterNext * COIF_NORINV) | _uartSwitchNext;
    swModeBuffer[4] = (_uartBitsNext * COIF_BIT) | (_uartStopNext * COIF_STOP) | (_uartParityNext * COIF_PARITY) | _uartBaudRateNext;
    
    for (int i = 0; i<SWITCH_LEN; i++) {
        NSLog(@"the buffer APP Start %d is %02X", i, swModeBuffer[i]);
    }
    
    [[H2TestMode sharedInstance] TMSWDevModeStart:swModeBuffer withDevSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode];
//    [[LibDelegateFunc sharedInstance] h2LibSwitchInit:uartModeSel withUartLength:uartLength andMeterCmdHeader:cmdHeader];

    // Test
/*
    self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%02d, %02d, %02d, %02d,\n", swTotalCycle-swTestCycle,_uartSwitch, _uartInverter, _uartBaudRate];
    
    self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@  ",[switchArray objectAtIndex:_uartSwitch]];
    self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@  ",[invNorArray objectAtIndex:_uartInverter]];
    self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@\n\n",[baudRateArray objectAtIndex:_uartBaudRate]];
*/
    swTestCycle--;
}




-(void)swCycleRun   // SW 4
{
    if (swTestCycle) {
        if (_uartSwitch < SWITCH_MAX) {
            _uartSwitch++;
        }else{
            if (_uartInverter < INVERTER_MAX) {
                _uartSwitch = 0;
                _uartInverter++;
            }else{
                _uartSwitch = 0;
                _uartInverter = 0;
                if (_uartBaudRate < BAUDRATE_MAX) {
                    _uartBaudRate++;
                }else{
                    _uartBaudRate = 0;
                }
            }
        }
        
        swModeBuffer[0] = (_uartIrDA * COIF_IR) | (_uartInverter * COIF_NORINV) | _uartSwitch;
        swModeBuffer[1] = (_uartBits * COIF_BIT) | (_uartStop * COIF_STOP) | (_uartParity * COIF_PARITY) | _uartBaudRate;
        swModeBuffer[2] = swTotalCycle - swTestCycle;
        
        _uartSwitchNext = _uartSwitch;
        _uartInverterNext = _uartInverter;
        _uartBaudRateNext = _uartBaudRate;
        
        if (_uartSwitchNext < SWITCH_MAX) {
            _uartSwitchNext++;
        }else{
            if (_uartInverterNext < INVERTER_MAX) {
                _uartSwitchNext = 0;
                _uartInverterNext++;
            }else{
                _uartSwitchNext = SWITCH_INIT;
                _uartInverterNext = 0;
                if (_uartBaudRateNext < BAUDRATE_MAX) {
                    _uartBaudRateNext++;
                }else{
                    _uartBaudRateNext = BAUDRATE_INIT;
                }
            }
        }
        swModeBuffer[3] = (_uartIrDANext * COIF_IR) | (_uartInverterNext * COIF_NORINV) | _uartSwitchNext;
        swModeBuffer[4] = (_uartBitsNext * COIF_BIT) | (_uartStopNext * COIF_STOP) | (_uartParityNext * COIF_PARITY) | _uartBaudRateNext;
        
        [[H2TestMode sharedInstance] TMSWDevModeStart:swModeBuffer withDevSerialNumber:[LibDelegateFunc sharedInstance].qrStringCode];
//        [[LibDelegateFunc sharedInstance] h2LibSwitchInit:swModeBuffer withUartLength:SWITCH_LEN andMeterCmdHeader:cmdHeader];
//        [[H2Sync sharedInstance]h2SwitchTest:swModeBuffer withLength:SWITCH_LEN withFlag:YES];
        
/*
        self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%02d, %02d, %02d, %02d,\n", swTotalCycle-swTestCycle,_uartSwitch, _uartInverter, _uartBaudRate];
        
        self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@  ",[switchArray objectAtIndex:_uartSwitch]];
        self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@  ",[invNorArray objectAtIndex:_uartInverter]];
        self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%@\n\n",[baudRateArray objectAtIndex:_uartBaudRate]];
*/
        swTestCycle--;
    }
}




- (IBAction)switchResetButton:(id)sender
{
    NSError *error;
    _switchTestMode = NO;
    switch_mode = NO;
    sn_reading_mode = NO;
    BOOL hasCable = [[NSUserDefaults standardUserDefaults] boolForKey:@"cableExist"];
    
    if (hasCable) {
        [[H2Sync sharedInstance] start:&error];
        //j        [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
        [self H2SetAudioVolumeMax];
        [NSTimer scheduledTimerWithTimeInterval:1.5
                                         target:self
                                       selector:@selector(switchTestInit)
                                       userInfo:nil
                                        repeats:NO];
        
        NSLog(@"set audio volume.++++++++++++++++++");
        NSLog(@"the CR/LR %02X, %02X", '\r', '\n');
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncIncNotification" object:self];
    }
}



- (void)clearConsole:(id)sender
{
    self.consoleView.text = @"";
    _switchTestMode = NO;
    switch_mode = NO;
    sn_reading_mode = NO;
    _serialNumber.text = [NSString stringWithFormat:@"SN : ..."];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alert veiew");
    if ([alertView.title isEqualToString:@"Cable Status"]) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                
                break;
                
            default:
                break;
        }
    }else if ([alertView.title isEqualToString:@"Want To Sync"]){
        switch (buttonIndex) {
            case 0:
                // no thing to do
                NSLog(@"here is 0");
                break;
            case 1:
                NSLog(@"here is 1");
                [[H2Sync sharedInstance] h2CablePreSync:nil];
                break;
                
            default:
                break;
        }
        
    }
}

#endif


/*

- (void)h2EngineerChecking:(NSMutableArray *)mutableArray
{
    unsigned char tmpBuffer[5] = {0};
    UInt8 dataLength = 0;
    
    
    NSLog(@"ENGINEER CHECKING 0---");
    UartIrDATestStatus = YES;
    if (switch_mode) {
        NSLog(@"ENGINEER CHECKING 0");
        
        for (h2MeterSystemInfo *systemInfo in mutableArray) {
            NSLog(@"ENGINEER CHECKING 1, THE LENGTH IS %d", [systemInfo.smEngineerData length]);
            dataLength = [systemInfo.smEngineerData length];
            if ([systemInfo.smEngineerData length] > REPORT_DATA_LEN_UART - 1) {
                NSLog(@"ENGINEER CHECKING 2");
                [systemInfo.smEngineerData getBytes:tmpBuffer range:NSMakeRange(REPORT_COMPARE_OFFSET_UART, SWITCH_LEN)];
                
                for (int i = 0; i < SWITCH_LEN; i++) {
                    NSLog(@"ENGINEER CHECKING 3");
                    
                    NSLog(@"The nsdata is %02X %02X", tmpBuffer[i], swModeBuffer[i]);
                    if (tmpBuffer[i] != swModeBuffer[i]) {
                        UartIrDATestStatus = NO;
                        break;
                    }
                }
            }else{
                UartIrDATestStatus = NO;
            }
        }
        
        
        if (swTestCycle) {
            if (UartIrDATestStatus) {
                self.consoleView.text = @"";
                [NSTimer scheduledTimerWithTimeInterval:0.6
                                                 target:self
                                               selector:@selector(swCycleRun)
                                               userInfo:nil
                                                repeats:NO];
                self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"%02d cycle \n", swTestCycle];
            }else{
                _testStatus.text = @"FAIL";
                _testStatus.textColor = [UIColor redColor];
                _switchTestMode = NO;
                switch_mode = NO;
                swTestCycle = 0;
            }
            
            NSLog(@"error message here");
        }else{
            
            NSLog(@"finish switch test");
            
            if (UartIrDATestStatus) {
                self.consoleView.text = [self.consoleView.text stringByAppendingFormat:@"PASS SWITCH Test.\n"];
                _testStatus.text = @"PASS";
                _testStatus.textColor = [UIColor blueColor];
            }else{
                _testStatus.text = @"FAIL";
                _testStatus.textColor = [UIColor redColor];
            }
            
            _switchTestMode = NO;
            switch_mode = NO;
            swTestCycle = 0;
        }
    }else if (sn_reading_mode){
        unsigned char ch[16] = {0};
        UInt32 sn = 0;
        UInt8  year;
        UInt8  month;
        NSString *customer;
        NSString *model;
        
        NSUInteger len = [((h2MeterSystemInfo*)[mutableArray objectAtIndex:0]).smEngineerData length];
        Byte *byteData = (Byte*)malloc(len);
        memcpy(byteData, [((h2MeterSystemInfo*)[mutableArray objectAtIndex:0]).smEngineerData bytes], len);
        if (len >= 10) {
            memcpy(ch, (byteData+4), 2);
            customer = [NSString stringWithUTF8String:(const char *)ch];
            
            memcpy(ch, byteData, 2);
            model = [NSString stringWithUTF8String:(const char *)ch];
            
            memcpy(&sn, (byteData+6), 3);
            memcpy(&year, (byteData+2), 1);
            memcpy(&month, (byteData+3), 1);
            
            [((h2MeterSystemInfo*)[mutableArray objectAtIndex:0]).smEngineerData getBytes:&sn range:NSMakeRange(6, 3)];
            NSLog(@"the serial number is %06d", (unsigned int)sn);
            
            [((h2MeterSystemInfo*)[mutableArray objectAtIndex:0]).smEngineerData getBytes:ch range:NSMakeRange(0, 10)];
            for (int i = 0; i < 10; i++) {
                NSLog(@"the model is %02d %02X", i, ch[i]);
            }
            _serialNumber.text = [NSString stringWithFormat:@"SN : %@%02d%02d%@%06d", model, year, month, customer, (unsigned int)sn];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.02
                                         target:self
                                       selector:@selector(SwitchTestStart)
                                       userInfo:nil
                                        repeats:NO];
        _switchTestMode = YES;
        switch_mode = YES;
        sn_reading_mode = NO;
    }
}

*/


#pragma mark -
#pragma mark - DISPLAY TEST RESULT

- (void)showPassView
{
    _switchTestMode = NO;
    [cyclePassAlertView show];
    
    UILabel *theTitle = [cyclePassAlertView valueForKey:@"_titleLabel"];
    [theTitle setTextColor:[UIColor greenColor]];
}

- (void)showFailView
{
    _switchTestMode = NO;
    UILabel *theTitle = [cycleFailAlertView valueForKey:@"_titleLabel"];
    [theTitle setTextColor:[UIColor greenColor]];
    [cycleFailAlertView show];
}

-(void)willPresentAlertView:(UIAlertView *)alertView{
    UILabel *theTitle = [alertView valueForKey:@"_titleLabel"];
    theTitle.font = [UIFont fontWithName:@"Copperplate" size:18];
    [theTitle setTextColor:[UIColor greenColor]];
    
    UILabel *theBody = [alertView valueForKey:@"_bodyTextLabel"];
    theBody.font = [UIFont fontWithName:@"Copperplate" size:15];
    [theBody setTextColor:[UIColor redColor]];
}




+ (H2TMSwitch *)sharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_APEXBIO
    NSLog(@"H2 TM SWITCH INSTANCE VALUE IS @%@", _sharedObject);
#endif
    return _sharedObject;
}

@end



@interface TMSwitchViewController ()
{
    UIButton *btnSwitchTest;
    UIButton *btnSwitchReset;
    UIButton *btnSerialNumber;
    
    UIButton *btnScanTool;
    UIButton *btnAddToolToList;
    UIButton *btnShowOrDeleteTool;
}



@end

@implementation TMSwitchViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UINavigationBar *navBleBar = [[UINavigationBar alloc]
                                      initWithFrame:CGRectMake(0, 0, 320, 54)];
        [self.view addSubview:navBleBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStylePlain
                                    target:self action:@selector(bleSwitchTestPageBack:)];
        UINavigationItem *navItem = [[UINavigationItem alloc]
                                     initWithTitle:@"BLE SW TEST"];
        
        navItem.leftBarButtonItem = btnBack;
        [navBleBar pushNavigationItem:navItem animated:NO];
        
        
        NSMutableArray *bottunArray = [[NSMutableArray alloc] init];
        // DEV
        btnSwitchTest = [[UIButton alloc] init];
        btnSwitchReset = [[UIButton alloc] init];
        btnSerialNumber = [[UIButton alloc] init];
        
        btnSwitchTest = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSwitchReset = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSerialNumber = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [bottunArray addObject:btnSwitchTest];
        [bottunArray addObject:btnSwitchReset];
        [bottunArray addObject:btnSerialNumber];
        
        // TOOL
        
        btnScanTool = [[UIButton alloc] init];
        btnAddToolToList = [[UIButton alloc] init];
        btnShowOrDeleteTool = [[UIButton alloc] init];
        
        btnScanTool = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAddToolToList = [UIButton buttonWithType:UIButtonTypeCustom];
        btnShowOrDeleteTool = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [bottunArray addObject:btnScanTool];
        [bottunArray addObject:btnAddToolToList];
        [bottunArray addObject:btnShowOrDeleteTool];
        
        
        NSMutableArray *btnString = [[NSMutableArray alloc] init];
        [btnString addObject:@"SW TEST START"];
        [btnString addObject:@"SW RESET"];
        [btnString addObject:@"SW GET SN"];
        
        [btnString addObject:@"TOOL SCAN ..."];
        [btnString addObject:@"TOOL ADD ..."];
        [btnString addObject:@"TOOL SHOW-DEL"];
        
        
        
        
        UInt8 btnIndex = 0;
        for (UIButton *btnSwitchMethod in bottunArray) {
            //            btnBleMethod = [UIButton buttonWithType:UIButtonTypeCustom];
            
            
            btnSwitchMethod.frame = CGRectMake(20, 60 + 40 + btnIndex * 60, 280, 40);
            
            [btnSwitchMethod.titleLabel setFont:[UIFont systemFontOfSize:26]];
            
            [btnSwitchMethod.layer setMasksToBounds:YES];
            [btnSwitchMethod.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
            [btnSwitchMethod.layer setBorderWidth:1.0]; //边框宽度
            //    [moreButton.backgroundColor = [UIColor clearColor];
            
            [btnSwitchMethod setTitle:[btnString objectAtIndex:btnIndex] forState:UIControlStateNormal];
            
            [btnSwitchMethod setBackgroundImage:[UIImage imageNamed:@"blue2.png"] forState:UIControlStateNormal];
            
            switch (btnIndex) {
                case 0:
                    [btnSwitchMethod addTarget:self action:@selector(switchingTest:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 1:
                    [btnSwitchMethod addTarget:self action:@selector(switchingReset:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 2:
                    [btnSwitchMethod addTarget:self action:@selector(tmSerialNumber:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                case 3:
                    [btnSwitchMethod addTarget:self action:@selector(toolScanning:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 4:
                    [btnSwitchMethod addTarget:self action:@selector(toolAdding:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case 5:
                    [btnSwitchMethod addTarget:self action:@selector(toolListingOrDelete:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                    
                default:
                    break;
            }
            
            
            [self.view addSubview:btnSwitchMethod];
            btnIndex++;
        }
        self.view.backgroundColor = [UIColor whiteColor];
    }
    NSLog(@"TM SWITCH PAGE");
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)switchingTest:(id)sender
{
    [LibDelegateFunc sharedInstance].indexStatus = 0;
    [LibDelegateFunc sharedInstance].stbTitle = @"SWITCH TEST";

    
    // START SW TEST ...
    [[H2TMSwitch sharedInstance]testModeSwitchStart];
    
    STBViewController *stbController =[[STBViewController alloc] init];
    [self presentViewController:stbController animated:YES completion:^{NSLog(@"SW TEST_STB done");}];
}



- (IBAction)switchingReset:(id)sender
{

    [[H2TMSwitch sharedInstance] testModeSwitchReset];
    
    NSLog(@"RESET AND INIT SW MODE");
    
//   STBViewController *stbController =[[STBViewController alloc] init];
//    [self presentViewController:stbController animated:YES completion:^{NSLog(@"SW RESET_STB done");}];
}

- (IBAction)tmSerialNumber:(id)sender
{
//    SNWriteViewController *snwController =[[SNWriteViewController alloc] init];
//    [self presentViewController:snwController animated:YES completion:^{NSLog(@"SN_WRITE done");}];
    
}

- (IBAction)toolScanning:(id)sender
{
    [H2TMSwitch sharedInstance].scanMode = YES;
    // 選擇序號後開始掃描，並連結
    // 可能沒有ID,
    // 有 ID 直接連結，不用掃描
    
    Byte *tmpHeader;
    tmpHeader = (Byte *)malloc(6);
//    unsigned char tmp[] = {0x01, 0x06, 0x03, 0x04, 0x05, 0x07};
    memcpy(tmpHeader, cmdHeader, 6);
    
    NSLog(@"TOOL - SCANNING ...");
    
//    2EE9BC5F-F591-FC91-AB9A-41562D657B67
    NSString *toolID = [NSString stringWithFormat:@"2EE9BC5F-F591-FC91-AB9A-41562D657B67"];
    
//    NSString *toolID = [NSString stringWithFormat:@"C69FA63F-4A55-0307-8908-D46E104A6468"];
    
    NSLog(@"TOOL'S SN IS %@", [LibDelegateFunc sharedInstance].qrStringCode);
    [[H2TestMode sharedInstance] TMSWToolModeScanAndAdding:[LibDelegateFunc sharedInstance].qrStringCode withIdentifier:toolID meterHeader:tmpHeader];
    

}

- (IBAction)toolAdding:(id)sender
{
    [H2TMSwitch sharedInstance].scanMode = YES;
    // 掃描序號，顯示掃描結果
    NSDictionary *toolSerialNumberNew = nil;
    toolSerialNumberNew = @{@"TOOL_SerialNumber" : @"", @"TOOL_Identifier" : @""};
//    toolSerialNumberNew = @{@"TOOL_SerialNumber" : toolSerialNumber, @"TOOL_Identifier" : toolIdentifier };
    
//    NSString *stringSerialNumberFromQRCode = [toolCable objectForKey: @"TOOL_SerialNumber"];
    
    // 進入掃描 QR Code 頁面
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"qrString"];
    QRCodeViewController *qrScanController = [[QRCodeViewController alloc] init];
    qrScanController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:qrScanController animated:YES completion:^{NSLog(@"done");}];
    NSLog(@"TOOL - ADDING ...");
}

- (IBAction)toolListingOrDelete:(id)sender
{
    [H2TMSwitch sharedInstance].scanMode = NO;
    // 顯示 目前表單內的 TOOL
    NSLog(@"TOOL - SHOW - TOOL CABLE ...");
    ToolCableTableViewController *toolTableController;
    toolTableController = [[ToolCableTableViewController alloc] init:nil];
    toolTableController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:toolTableController animated:YES completion:^{NSLog(@"DONE FOR show TOOL CABLE TABLE");}];
    
}



- (void)bleSwitchTestPageBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

