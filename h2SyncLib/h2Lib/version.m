#import "version.h"

@implementation myVersion
- (NSString *)libVersion{
    return @"lv 2.4.5";
}

@end

// 0. V2.4.5 // 2019-04-09
// 1. Roche Performa II, id 0x0014

// 0. V2.4.4 // 2019-02-27
// 1. OneTouch Ultra Plus Flex - skip control solution data

// 0. V2.4.3 // 2019-01-18
// 1. Support hbf-254c New model 00010004

// 0. V2.4.2 // 2019-01-03
// 1. Revised discover characteristc flow for UC-352BLE

// 0. V2.4.1 // 2018-12-03
// 1. Add A&D UC-352BLE (Body Weight Scale)

// 0. V2.4.0 // 2018-11-13
// 1. Modify object's Properties.

// 0. V2.3.9 // 2018-10-11
// 1. Add mamArrhythmia flag for MicroLife at MAM mode

// 0. V2.3.8 // 2018-10-08
// 1. Open arrhythmia flag for MF, DS-A, Fora, 9200T
// 2. Revised MicroLife ble terminaltion flow.

// 0. V2.3.7 // 2018-09-29
// 1. Skip A&D UA-651 BLE Error Value

// 0. V2.3.6 // 2018-09-27
// 1. Added A&D UA-651 BLE BP
// 2. Revised substring LocalName for Contour Filter 

// 0. V2.3.5 //
// 1. Add Error Message for Arkray
// 2. Revised Ble flow for Arkray
// 3. Add Terminate BLE flow func for App.

// 0. V2.3.4 // 2010-09-07
// 1. Added Tag for MicroLife A6 BT Serial Number

// 0. V2.3.3 // 2010-09-05
// 1. Added MicroLife A6 BT (bp)
// 2. Added Alliance DS-A   (bg)

// 0. V2.3.2 // 2018-09-03
// 1. Revised meal status for Neo Alpha and G-BLACK

// 0. V2.3.1 // 20-08-31
// 1. Fixed LDT no action for Neo Alpha

// 0. V2.3.0 // 2018-08-29
// 1. Support Neo Alpha V1.04
// 2. Roche accu-chek connect/guide name issue, because command Not Finish.

// 0. V2.2.9 // 2018-08-14
// 1. Roche accu-chek connect/guide name issue
// 2. Roche accu-check connect/guide/instant report meter time
// 3. Arkray G-Black/Neo Alpha record value issue.
// 4. Music interrupt issue.

// 0. V2.2.8 // 2018-07-26
// 1. New meter OneTouch Ultra PlusFlex, 0x010680A1
// 2. Revised G-Black & NEO Alpha command flow

// 0. V2.2.7 // 2018-06-05
// 1. New meter Fora TNG Voice, meter Id : 0x0100833B

// 0. V2.2.6 // 2018-06-01
// 1. New meter ACCU-CHEK Instant meter Id : 0x01078012
// 2. New meter Fora TNG, meter Id : 0x0100823B


// 0. V2.2.5 // 2018-05-17
// 1. Fixed audio volume alert on BT mode issue

// 0. V2.2.4 // 2018-05-09
// 1. Debug function for HEM-6324T
// 2. Revised control flow for HEM-XXXX

// 0. V2.2.3 // 2018-04-26
// 1. G-BLACK new protocol (Characteristic), FLOW

// 0. V2.2.2 // 2018-04-16
// 1. New Meter Arkay GluTest NEO Alpha, meter ID : 0x010A81B2

// 0. V2.2.1 // 2018-04012
// 1. Current Time issue for Contour Next/Plus One

// 0. V2.2.0 // 2018-03-30
// 1. Revised multi data type for Fora D40
// 2. Revised Bayer Contour model name issue


// 0. V2.1.9 // 2018-03-27
// 1. New meter - Contur Plus ONE
// 2. Revised multi scan method
// 3. Revised skip future-data for Fora D40

// 0. V2.1.8 // 2018-03-21
// 1. Scanning multi Device for Fora at Pairing mode
// 2. P or S flow -> Start -> if(Busy) -> terminate sdk flow - wait 3s - restart

// 0. V2.1.7 // 2018-03-15
// 1. Record index doesn't match to last record issue.
// 2. Speed up ble pairing flow.
// 3. Revised Pairing mode no name issue.
// 4. Revised ble pairing flow in multi device(Next Version)


// 0. V2.1.6 // 2018-03-12
// 1. 9200T Dialog interval 27 second
// 2. Revised D40 turn off on response issue (time out and disconnect)
// 3. Revised stop flag for app enter background
// 4. Added flag at get records for non-ble device
// 5. W310 turn off task
// 6. Added debug info for ble device


// 0. V2.1.5 // 2018-03-07(2)
// 1. Roche Connect and Guide mode mapping


// 0. V2.1.4 // 2018-03-07
// 1. Ble connect time out - E3(Not Found)
// 2. HEM-9200T (29s < pin dialog time 30s) E5(Pairing Time out, no pin Dialog)
// 3. Ble BGM reocrd timer per-record, (E1)time out

// 0. V2.1.3 // 2018-03-05
// 1. Fixed bug
// - body fat(numerical issue)
// - omron record index ranking
// - cable fail not report
// 2. Revised W310 multi-user issue ( one user only and speed up)
// 3. Dongle pairing flow scan -> 0x2A -> Dev List
// 4. report fail status while app terminates sync flow

// 0. V2.1.2 // 2018-02-27
// 1. New Device - Fora P30 Plus,
// 2. Terminal Sync Flow method for Ble Equipment.
// 3. Debug delegate only for Develop.
// 4. Omron Sync flow refer to Omron-Connect App.
// 5. Fixed Numerical issue
// 6. Fora W310 User Tag 2 ~ 6 mapping to 1 ~ 5

// 0. V2.1.1 // 2018-02-08
// 1. SDK saves arkray Command
// 2. ble pairing error message
// 3. added mode_error message for ble mode error


// 0. V2.1.0 // 2018-01-29
// 1. Open debug delegate method.


// 0. V2.0.9 // 2018-01-24
// 1. Omron flow(set current time, but don't reset record index)
// 2. Sync Message, and delegate method
// 3. filter iso8601 date time format(v2004) for LDT


// 0. V2.0.8 // 2018-01-10
// 1. Fixed Skip records issue
// 2. Add RecordsSkipped object,
// 3. add - (void)appDelegateRecordsSkip:(RecordsSkipped *)numbers;
// 3. Removed bg,bp,bw skip numbers from LDT object

// 0. V2.0.7 // 2017-12-19
// 1. Dongle pairing 改回舊的模式
// 2. Fora W310B index issue in record stage
// 3. Merge Omron hem-7280T, hem-7600T hem-6320T-Z, hem-6324T into one sync flow.


// 0. V2.0.6XX // 2017-12-06
// 1. Fixed Audio sync issue after BLE cable used
// 2. Fixed BTM transfer Records issue
// 3. OLD Record ???


// 0. V2.0.5 // 2017-12-05
// 1. Removed @required for delegate method

// 0. V2.0.4 // 2017-12-04
// 1. New Meter : Roche aviva Guide
// 2. Records and LDT flow
// 3. Revised battery level and dynamic info
// 4. Revised HEM-9200T ID


// 0. V2.0.3 // 2017-11-22
// 1. Rename method For App team
// 2. For True Metrix, if Great_Than fail, then Get_All
// 3. Ble Meter and Calbe using the same report in BLE Pairing stage
// 4. Sync Flow, sync start -> report Battery level, SN, -> report meter Info
//    -> Get measurement data -> finished
//    -> Then app Get records before get get LDT if has new records.
// 5. Checking data type and User Tag before sync, Report EA if Fail


// 0. V2.0.2 // 2017-11-13
// 1. Delete "meter_sel"
// 2. USE NEW delegete for bg, bp, bw sync result,(old method deleted)
// 3. added "app" prefix for method app used
// 4. modify flag bg(B,A ...), and removed bpFlag, bwFlag
// 5. using NSNumber for recordType, userTag, recordIndex in LDT
// 6. User profile for Omron HBF-254C (tag, gender, birthday, body height)
// 7. set user tag(from user profile) by SDK (HBF-254C, HEM-7280T)

// 0. V2.0.1 // 2017-10-26
// 1. Meter Flag char --> String
// 2. Using H2BgRecord
// 3. Get Records and LDT from App
//      - (BOOL)appGetRecords;
//      - (BOOL)appGetLastDateTime;
// 4. Report BG value - - (void)h2BgDateTimeValueArray:(NSMutableArray *)bgRecords;


// 0. v1.6.7XXX // 2017-10-19
// 1. LDT nil or NULL issue

// 0. v1.6.6XXX // 2017-10-02
// 1. Fixed Tyson Bio HT100 Maximun Index issue
// 2. Add Record's index field in LDT for debug using
// 3. Add received records for HEM-9200T at pairing mode

// 0. v1.6.5 // 2017-09-22
// 1. Added Contournext ONE
// 2. BGM modify(Index, LDT, 0000 ~ FFFF)
// 3.

// 0. 1.6.4XXX // 2017-09-13 // For Tyson Demo
// 1. Added Tyson HT100, // meter ID 0x010180A5
// 2. Fixed FreeStyle crash issue
// 3. Fixed Fora GD40B, ble mode


// 1.6.3XXX // 2017-08-29
// 1. Added Ble error handling
// E9		Pin Dialog Cancel or Time Out
// E5		Pin or Password Error
// E3		Pin or Password Time Out
// E6		Key Command Not Found
// E7		Omron Mode Error
// F9		Serial Number Time Out

// #E4		Pin Dialog Not Appear


// 1.6.2 // 2017-07-10
// 1 suport old pairing and sync method

// 1.6.1 // 2017-06-19
// 1. added HEM-6320T
// 2. revised omron pairing flow
// 3. replace serial number with ble local name for 254C, 7280T, 6320T
// 4. revised D40B, W310B meter ID,(No Pairing Dialog)

// 1.6.0 // 2017-06-12
// 0.4 bytes meter ID(inclued meter feature)
// 1.Added Global PreSync for (audio Cable, Ble Cable, Ble BG, BP, BW), with Sync Info Package
// 2.Revised multi-function and multi-user Task(app select BG or BP, app select user)
// 3.Add report BP and BW result
// 4.Add meter user id and record type in BG, BP, BW object
// 5.Revised LDT (NSDictionary object to NSDictionary object Array), add user id and data type
// 6.App write BLE pin for Arkray
// 7.App Set user id for Omron HEM-7280T and HBF-254C in pairing stage after LIB report user id status
// 8.Report user id status for Omron HEM-7280T and HBF-254C
// 9.BP,BW Object


// 1.5.3 // 2017-06-03
// 1.Fixed Roche ending issue in BLE cable


// 1.5.2
// 1. Removed additional 0x10 from record data stream

// 1.5.1
// 1. Revised zero record for Fora GD40B

// 1.5.0
// 1. Reviesed Ultra VUE issue on Audio Mode

// 1.4.9// 2017.02.09
// 1. BLE Pairing Error message
// Pairing stage :  89 -> Device not found,
//                  E9 -> Pin error or Canncel
//                  F9 -> Time Out, Because user delete Paired device
// Sync stage : F9 -> Time Out, Paired device has been removed, but other device in the list,
//                    (data transfer show other device)
//               Paired device list is empty --> Roche's meter enter Pairing mode
//               user must remove paired status from cell phone

// 1.4.8
    // 0. To sync ble BG model to empty string at pairing and sync stage
    // 1. BLE Pairing function for Roche accu aviva connect and Ture Metrix, Pairing interval 30 second,
    // 2. Time off set for Roche accu aviva connect
    // 3. Added Ultra Vue, Ultra
    // 4. Revised BLE crash when ble turn off
    // 5. Ultra Mini leap year issue
    
    // V 1.4.7
    // 1. Revised Ultra Mini leap year
    //return @"lv 1.4.6";
/*
 // V1.4.6
    1. Fixed Fora GD40A issue
    2. Fixed FreeStyle issue
    3. Fixed Ble Cable Device Name issue
    4. Revised Roche sync flow for crash issue
        5. Sync flow for Embrace in Ble cable
            6. Modify Stop function to Stop sync flow while
                Current time over head 30 minutes, App call
                Method after user push the cancel button,
                7.Revised BG_brandLastDateTime, BP_brandLastDateTime , BW_brandLastDateTime KeyWord in LDT NSDictionary,
                To separate the LDT for different Heath Data they have one serial number,
                    8.Revised h2MeterRecordInfo  NSObject Revise for different Health Data, like Blood Glucose, Blood Pressure, Body Weight
                        and recordsDataType field to filter data type the user wants.
                        9. Add data type Mask
                        10, NEW health Equipment and ID
                        0x8010   : Accu Aviva Connect
                        0x80A0  : Ture Metrix
                        0xC03C : Fora W310  (WG)

*/
    
    //return @"lv 1.4.5";
    // 1. GlucoreSure 年月日時分相等問題
    // 2. Performa crash issue
    
    //return @"lv 1.4.4";
    // ADD FORAM D40
    
    //return @"lv 1.4.3";
    // 1. Revised BLE centeral Manager
    // 2. Add GD40A
    // 3. Revised GD40B
    // 4. Add URight TD-4286A
    // 5. Revised EmbracePro
    // 6. Accu Check Delay Time adjusting ...
    
//    return @"lv 1.4.2";
    // 1. Fixed h2 cable Lose issue during scan stage











