//
//  TMSwitch.h
//  APX
//
//  Created by h2Sync on 2016/4/20.
//  Copyright © 2016年 h2Sync. All rights reserved.
//


#define TEST_MODE           1
#define IRDA_MODE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface H2TMSwitch : NSObject

{
    
}


@property (nonatomic, unsafe_unretained) BOOL switchTestMode;

@property (nonatomic, unsafe_unretained) UInt8 uartBaudRate;
@property (nonatomic, unsafe_unretained) UInt8 uartParity;
@property (nonatomic, unsafe_unretained) UInt8 uartStop;
@property (nonatomic, unsafe_unretained) UInt8 uartBits;

@property (nonatomic, unsafe_unretained) UInt8 uartInverter;
@property (nonatomic, unsafe_unretained) UInt8 uartSwitch;

@property (nonatomic, unsafe_unretained) UInt8 uartIrDA;


@property (nonatomic, unsafe_unretained) UInt8 uartBaudRateNext;
@property (nonatomic, unsafe_unretained) UInt8 uartParityNext;
@property (nonatomic, unsafe_unretained) UInt8 uartStopNext;
@property (nonatomic, unsafe_unretained) UInt8 uartBitsNext;

@property (nonatomic, unsafe_unretained) UInt8 uartInverterNext;
@property (nonatomic, unsafe_unretained) UInt8 uartSwitchNext;

@property (nonatomic, unsafe_unretained) UInt8 uartIrDANext;


@property (nonatomic, unsafe_unretained) BOOL scanMode;

- (BOOL)testModeSwitchStart;
- (BOOL)testModeSwitchChecking;
- (void)testModeUartCmdConfigFirst;
- (void)testModeUartCmdConfigSecond;

- (BOOL)testModeSwitchReset;

+ (H2TMSwitch *)sharedInstance;
@end

// [H2TMSwitch sharedInstance] scanMode


@interface TMSwitchViewController : UIViewController
{
    
}

@end
