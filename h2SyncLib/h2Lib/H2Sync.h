
//
//  Created by JasonChuang on 13/08/08.
//  Copyright (c) 2013年 Health2Sync Inc. All rights reserved.
//


#import <Foundation/Foundation.h>


// Sync
typedef NS_ENUM(NSUInteger, H2SSDKSyncStatus) {
    H2SSDKSyncStatusWithNewRecord = 0x0A, // 有新資料
    H2SSDKSyncStatusNoNewRecord = 0x1A, // 沒有新資料
    H2SSDKSyncStatusSdkFlowBusy = 0x4A, // Sdk Flow Busy
    
    H2SSDKSyncStatusFail = 0xE1, // 同步失敗但不屬於以下情況
    H2SSDKSyncStatusBLEDisabled, // 藍牙未啟用
    H2SSDKSyncStatusBLENotFound, // 偵測不到 BLE meter 或是 BLE dongle
    H2SSDKSyncStatusAuthFailed, // PIN 輸入錯誤，sync 時，若手機沒有該藍牙裝置時，系統會跳出 PIN 碼給使用者輸入，若輸入錯誤，SDK 會以此來告知
    H2SSDKSyncStatusPairTimeout, // Pairing Dialog 未出現，需移除系統的藍芽配對
    H2SSDKSyncStatusModeError, // Meter 的藍牙模式錯誤，meter 選成「配對模式」
    
    H2SSDKSyncStatusCableNotFound, // 找不到傳輸線(audio cable)
    H2SSDKSyncStatusMeterNotFound, // 找不到 meter
    
    H2SSDKSyncStatusAppRemoved, // App 被移除，Arkray 需重新配對
    H2SSDKSyncStatusMeterAbnormal, // Arkray 血糖機不正常
};

//Pair
typedef NS_ENUM(NSUInteger, H2SSDKPairStatus) {
    H2SSDKPairStatusBleCableSucceeded = 0x2A, // Ble Dongle 配對成功
    H2SSDKPairStatusSdkFlowBusy = 0x4A, // Sdk Flow Busy
    
    H2SSDKPairStatusFail = 0xE1, // 配對失敗但不屬於以下情況
    H2SSDKPairStatusBLEDisabled, // 藍牙未啟用
    H2SSDKPairStatusBLENotFound, // 偵測不到 BLE meter 或是 BLE dongle
    H2SSDKPairStatusAuthFailed, // PIN 輸入錯誤, 取消，或逾時
    H2SSDKPairStatusTimeout, // Pairing Dialog 未出現，需移除系統的藍芽配對
    
    H2SSDKPairStatusModeError,// Meter 的藍牙模式錯誤，meter 選成「傳輸模式」
};


//Develop
typedef NS_ENUM(NSUInteger, H2SSDKDevelopStatus) {
    H2SSDKDevlopStatusMeterID = 0x21, // MID = 0,(Dongle 配對時 可接受 meter id=0)
    H2SSDKDevlopStatusMeterFunc, // 選擇的meter和介面功能不匹配，cable vs ble.
    H2SSDKDevlopStatusUserTag, // User Tage 超過此設備所支援的最大數
    H2SSDKDevlopStatusDataType, // 設備無提供此項資料(bg, bp, bw)
    H2SSDKDevlopStatusKey, // NSDictionary key 沒有找到
    H2SSDKDevlopStatusBLECableSN, // Ble Cable 序號長度問題, 或同步資料時未提供藍芽設備序號
};



/************************************************
 * MP TEST STATUS
 *
 ***********************************************/


//#import <Foundation/Foundation.h>
#import "h2MeterRecordInfo.h"
#import "ScannedPeripheral.h"

#import <MediaPlayer/MediaPlayer.h>

@class Brand;

@class H2PackageForSync;
@class H2BgRecord;
@class H2BpRecord;
@class H2BwRecord;
@class BatDynamicInfo;
@class RecordsSkipped;

@protocol H2SyncDelegate <NSObject>

@optional
/*!
 * @method  appDelegateCableSyncStatus:
 * @param   code, Succeed or Fail at Sync stage
 *
 */
- (void)appDelegateCableSyncStatus:(H2SSDKSyncStatus)code;

/*!
 * @method  appDelegateCablePairingStatus:
 * @param   code, Succeed or Fail at Pair stage
 *
 */
- (void)appDelegateCablePairingStatus:(H2SSDKPairStatus)code;

/*!
 * @method  appDelegateCableDevelop:
 * @param   code, verify and debug at develop stage
 *
 */
- (void)appDelegateCableDevelop:(H2SSDKDevelopStatus)code;

/*!
 * @method  appDelegateBleDevicesHaveFound:
 * @param  blePeripherals         Ble peripherals which founed during pairing mode
 *
 */
- (void)appDelegateBleDevicesHaveFound:(NSMutableArray *)blePeripherals;

/*!
 * @method appDelegateBatteryAndDynamicInfo:
 * @param dynamicInfo               AUDIO CABLE : BATTERY, SN, FW
 *                                                      AUDIO CABLE : BATTERY, SN, FW,  BLE-ID DELEGATE
 *                                                      BLE METER : BATTERY, SN, BLE-ID DELEGATE
 *
 */
- (void)appDelegateBatteryAndDynamicInfo:(BatDynamicInfo *)dynamicInfo;

/*!
 * @method appDelegateMeterInfo
 * @param devInfo                   Meter Information : SN, CT, MODEL ??
 * and data sync status
 */
- (void)appDelegateMeterInfo:(H2MeterSystemInfo *)devInfo;

/*!
 * @method  appDelegateRecordsSkip:
 * @param   records             Record Array, Included BG, BP, BW
 *
 */
- (void)appDelegateRecordsSkip:(RecordsSkipped *)numbers;

/*!
 * @method  appDelegateGetMeterRecordData:
 * @param   records             Record Array, Included BG, BP, BW
 *
 */
//- (void)appDelegateDateTimeValueArray:(NSDictionary *)records;
- (void)appDelegateGetMeterRecordData:(NSDictionary *)recordDdata;

/*!
 * @method  appDelegateLastDateTimeArray
 * @param   ldtArray                LDT Array
 *
 */
- (void)appDelegateLastDateTimeArray:(NSMutableArray *)ldtArray;


/*!
 * @method      appDelegateArkrayPasswordRequest
 *                           Required password in Ble pairing mode for Arkray G-BLACK
 *                           App Create input dialog for user  to type Meter Password
 *                          then Call  - (void)appArkrayRegister:(Byte *)arkrayPassword;
 *
 */
- (void)appDelegateArkrayPasswordRequest;

@optional
/*!
 * @method  demoAppDelegateReportUserTag
 * @param   userTagStatus,          user tag have set in meter device
 *                          Refquired this method in Pairing mode for   Omron HEM-7280T, HBF-254C
 *                          SDK get new u-Tag form user profile
 *                          DON't call // - (void)demoAppOmronSetUserTag:(UInt8)userTag;
 *
 */
- (void)demoAppDelegateReportUserTag:(UInt8)userTagStatus;






/*!
 * @method  appChkBgRecordIndex:
 * @param   bgIndex         Cruuent Bg Index
 *
 * @method  appChkBpRecordIndex:
 * @param   bpIndex         Cruuent Bp Index
 *
 * @method  appChkBwRecordIndex:
 * @param bwIndex         Cruuent Bw Index
 *
 * SDK Toggles
 */
- (void)appChkBgRecordIndex:(UInt16)bgIndex;
- (void)appChkBpRecordIndex:(UInt16)bpIndex;
- (void)appChkBwRecordIndex:(UInt16)bwIndex;




/*!
 * @method  debugMessageForUsers:
 * @param   syncInfoMessage                 Syncing information for Debug
 *
 *
 * //- (void)h2SyncInfoMessageReport:(NSDictionary *)syncInfoMessage;
 */
- (void)debugMessageForUsers:(NSDictionary *)syncInfoMessage;






/*!
 * @
 *
 *
 */
- (void)appChkBgSingleRecord:(H2BgRecord *)bgRecord;
- (void)appChkBpSingleRecord:(H2BpRecord *)bpRecord;
- (void)appChkBwSingleRecord:(H2BwRecord *)bwRecord;
// Firmware update progress
/*!
 * @method  appDelegateOadWriteStatus
 * @param   deno
 * @param   fraction
 *
 *
 */
- (void)appDelegateOadWriteStatus:(UInt16)deno withFraction:(UInt16)fraction;


@end

@interface H2Sync : NSObject

@property (nonatomic, strong) NSObject<H2SyncDelegate> *libDelegate;
@property (nonatomic, strong) Brand *brand;
@property (readwrite) BOOL isAudioCable;



+ (H2Sync *)sharedInstance;



/*!
 * @method  appAudioHideVolumeIcon
 *                      app call this method to hide the volume bar
 *
 *
 */
- (void)appAudioHideVolumeIcon:(UIView *)firstView;

/*!
 * @method  demoDidAudioHeadsetPluggedIn
 *                      checking  and report headset status
 *
 *
 */
- (BOOL)demoDidAudioHeadsetPluggedIn;


/*!
 * @method  appTerminateSdkFlow
 * @ This method will terminal Ble Function
 */
//- (void)appTerminalBleSyncFlow;
- (void)appTerminateSdkFlow;

// ????
//- (void)h2SyncStop:(BOOL)stop;




/*!
 * @method  appGlobalPreSync:
 *                      app begings to sync record from meter
 * @param   packageForSync          Initialize sdk to for sync or paring
 *
 */
- (UInt8)appGlobalPreSync:(H2PackageForSync *)packageForSync;

/*!
 * @method  appStartRecordSync:
 *                      call this method After Received Meter Info
 *
 */
- (void)appStartRecordSync:(id)sender;

/*!
 * @method  appTerminateBleFlow
 *                      call this method After Received Meter Info
 *                      while Meter is not correct
 */
- (void)appTerminateBleFlow;

/*!
 * @method appGetLastDateTime
 *                      app call this method to get LDT Array
 *
 */
- (void)appGetLastDateTime;

/*!
 * @method  appArkrayRegister
 *                      app call this method to send PW for arkray G-Black
 * @param arkrayPassword        6 bytes length data
 */
- (void)appArkrayRegister:(Byte *)arkrayPassword;




/*!
 *
 *
 */

- (void)sdkBleDeviceList:(NSMutableArray *)blePeripheral;

///////////////////////////////////////////////////
// Repront FW update Progress
- (void)sdkOadWriteProgress:(UInt16)deno withFraction:(UInt16)fraction;

#pragma mark - FW UPDATE AREA 
//- (UInt8)H2OadUpDateFlash:(unsigned char *)buffer withSerialNumber:(NSString *)sn withUserID:(NSString *)userID andUserEmail:(NSString *)userEmail;
// will removed
- (UInt8)demoAppOadUpDateFlash:(unsigned char *)buffer withSerialNumber:(NSString *)sn withUserID:(NSString *)userID andUserEmail:(NSString *)userEmail;

#pragma mark - INTERNAL (SDK) USE
- (void)sdkReportMeterDateTimeValueSingle:(id)record;
- (void)demoSdkSyncCableStatus:(UInt8)status delegateCode:(UInt8)deleSel;
- (void)sdkSendSerialNumberBatteryLevel:(UInt8)devSel;


- (void)sdkEquipInfoProcess:(UInt8)dataTypeFilter withSvrUserId:(UInt8)userIdFilter;

//////////////////////////////////////////////////////////////
// OMRON
- (void)sdkOmronUserTagStatus:(UInt8)uTagStatus;
- (void)demoAppOmronSetUserTag:(UInt8)userTag;

#pragma mark - RECORDS PROCESS Before Transfer
- (void)sdkProcessRecordsBeforeTransfer;

#pragma mark - ARKRAY METHOD
- (void)sdkArkrayRegisterNotify;


// SDK USE
- (void)sdkSendMeterInfo;

@end




