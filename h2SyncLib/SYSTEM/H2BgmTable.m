//
//  H2BgmTable.m
//  h2SyncLib
//
//  Created by h2Sync on 2017/5/11.
//  Copyright © 2017年 h2Sync. All rights reserved.
//

#import "H2BgmTable.h"

@implementation H2BgmTable
{
    
}



//static __strong id _sharedObject = nil;
+ (H2BgmTable *)brandSharedInstance
{
    // initialize sharedObject as nil (first call only)
    static __strong id _sharedObject = nil;
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t pred;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
#ifdef DEBUG_LIB
    DLog(@"BGM table @%@", _sharedObject);
#endif
    return _sharedObject;
}

- (id)init
{
    if (self = [super init]) {
        
        _h2BrandList =
        [[NSArray alloc] initWithObjects:
         @"H2_DEMO",
         @"ACCU-CHEK",
         @"Bayer",
         @"CareSens",
         @"FreeStyle",
         @"GLUCOCARD",
         @"OneTouch",
         @"ReliOn",
         
         @"BeneChek",
         @"OMNIS",
         
         @"BRAND_EXT_A",
         @"BRAND_EXT_B",
         @"BRAND_EXT_C",
         @"BRAND_EXT_D",
         @"BRAND_EXT_E",
         @"BRAND_EXT_F",
         nil];
        
        _h2DemoModel = [[NSArray alloc] initWithObjects:@"H2Demo", nil];
        
        
        _h2AccuChekModel = [[NSArray alloc] initWithObjects:
                            @"ACCU-CHEK Aviva",
                            @"ACCU-CHEK Aviva Nano",
                            @"ACCU-CHEK Nano",
                            @"ACCU-CHEK Perfoma",
                            
                            @"ACCU-CHEK EXT_4",
                            @"ACCU-CHEK EXT_5",
                            @"ACCU-CHEK EXT_6",
                            @"ACCU-CHEK EXT_7",
                            
                            @"ACCU-CHEK EXT_8",
                            @"ACCU-CHEK EXT_9",
                            
                            @"ACCU-CHEK Compact Plus",
                            @"ACCU-CHEK Active",
                            
                            @"ACCU-CHEK EXT_C",
                            @"ACCU-CHEK EXT_D",
                            @"ACCU-CHEK EXT_E",
                            @"ACCU-CHEK EXT_F",
                            nil];
        
        _h2BayerModel = [[NSArray alloc] initWithObjects:
                         @"Bayer's BREEZE 2",
                         @"Bayer's CONTOUR",
                         @"Bayer's CONTOUR NEXT EZ",
                         @"Bayer's CONTOUR XT",
                         
                         @"Bayer's CONTOUR TS",
                         @"Bayer's CONTOUR PLUS",
                         @"Bayer's EXT_6",
                         @"Bayer's EXT_7",
                         
                         @"Bayer's EXT_8",
                         @"Bayer's EXT_9",
                         @"Bayer's EXT_A",
                         @"Bayer's EXT_B",
                         
                         @"Bayer's EXT_C",
                         @"Bayer's EXT_D",
                         @"Bayer's EXT_E",
                         @"Bayer's EXT_F",
                         nil];
        
        _h2CareSensModel = [[NSArray alloc] initWithObjects:
                            @"iSENS CareSens N",
                            @"i-SENS CareSens N POP",
                            @"iSENS EXT_2",
                            @"iSENS EXT_3",
                            
                            @"iSENS EXT_4",
                            @"iSENS EXT_5",
                            @"iSENS EXT_6",
                            @"iSENS EXT_7_TYSON_TB200",
                            
                            @"iSENS EXT_8_EMBRACE_PRO",
                            // BIONIME
                            @"iSENS EXT_9 BIONIME",
                            @"iSENS EXT_A HMD_GL",
                            @"iSENS EXT_B_FORA_GD40A",
                            
                            @"iSENS EXT_C_DS_A",
                            @"iSENS EXT_D",
                            @"iSENS EXT_E",
                            @"iSENS EXT_F",
                            
                            nil];
        
        _h2FreeStyleModel = [[NSArray alloc] initWithObjects:
                             @"FreeStyle Freedom Lite",
                             @"FreeStyle Lite",
                             @"FreeStyle EXT_2",
                             @"FreeStyle EXT_3",
                             
                             @"FreeStyle EXT_4",
                             @"FreeStyle EXT_5",
                             @"FreeStyle EXT_6",
                             @"FreeStyle EXT_7",
                             
                             @"FreeStyle EXT_8",
                             @"FreeStyle EXT_9",
                             @"FreeStyle EXT_A",
                             @"FreeStyle EXT_B",
                             
                             @"FreeStyle EXT_C",
                             @"FreeStyle EXT_D",
                             @"FreeStyle EXT_E",
                             @"FreeStyle EXT_F",
                             
                             nil];
        
        _h2GlucoCardModel = [[NSArray alloc] initWithObjects:
                             @"GLUCOCARD 01",
                             @"GLUCOCARD Vital",
                             @"GLUCOCARD EXT_2",
                             @"GLUCOCARD EXT_3",
                             
                             @"GLUCOCARD EXT_4",
                             @"GLUCOCARD EXT_5",
                             @"GLUCOCARD EXT_6",
                             @"GLUCOCARD EXT_7",
                             
                             @"GLUCOCARD EXT_8",
                             @"GLUCOCARD EXT_9",
                             @"GLUCOCARD EXT_A",
                             @"GLUCOCARD EXT_B",
                             
                             @"GLUCOCARD EXT_C",
                             @"GLUCOCARD EXT_D",
                             @"GLUCOCARD EXT_E",
                             @"GLUCOCARD EXT_F",
                             
                             nil];
        
        _h2OneTouchModel = [[NSArray alloc] initWithObjects:
                            @"OneTouch Ultra2",
                            @"OneTouch UltraEasy",
                            @"OneTouch UltraLin",
                            @"OneTouch UltraMini",
                            
                            @"OneTouch EXT_4",
                            @"OneTouch EXT_5",
                            @"OneTouch EXT_6",
                            @"OneTouch EXT_7",
                            
                            @"OneTouch EXT_8",
                            @"OneTouch EXT_9",
                            //@"OneTouch EXT_A",
                            @"OneTouch UltraVUE",
                            @"OneTouch EXT_B",
                            
                            @"OneTouch EXT_C",
                            @"OneTouch EXT_D",
                            @"OneTouch EXT_E",
                            @"OneTouch EXT_F",
                            
                            nil];
        
        _h2ReliOnModel = [[NSArray alloc] initWithObjects:
                          @"ReliOn Confirm",
                          @"ReliOn Prime",
                          @"ReliOn EXT_2",
                          @"ReliOn EXT_3",
                          
                          @"ReliOn EXT_4",
                          @"ReliOn EXT_5",
                          @"ReliOn EXT_6",
                          @"ReliOn EXT_7",
                          
                          @"ReliOn EXT_8",
                          @"ReliOn EXT_9",
                          @"ReliOn EXT_A",
                          @"ReliOn EXT_B",
                          
                          @"ReliOn EXT_C",
                          @"ReliOn EXT_D",
                          @"ReliOn EXT_E",
                          @"ReliOn EXT_F",
                          
                          nil];
        
        _h2BeneChekModel = [[NSArray alloc] initWithObjects:
                            @"BeneChek Plus Jet",
                            @"BeneChek PT MEGA",
                            @"BeneChek EXT_2",
                            @"BeneChek EXT_3",
                            
                            @"BeneChek EXT_4",
                            @"BeneChek EXT_5",
                            @"BeneChek EXT_6",
                            @"BeneChek EXT_7",
                            
                            @"BeneChek EXT_8",
                            @"BeneChek EXT_9",
                            @"BeneChek EXT_A",
                            @"BeneChek EXT_B",
                            
                            @"BeneChek EXT_C",
                            @"BeneChek EXT_D",
                            @"BeneChek EXT_E",
                            @"BeneChek EXT_F",
                            
                            nil];
        
        
        _h2EXT_9_Model = [[NSArray alloc] initWithObjects: @"Embrace",
                          @"Embrace EVO",
                          @"EXT EVENCARE_G2",
                          @"GlucoSure VIVO",
                          @"EXT EVENCARE_G3",
                          @"EXT AUTO CODE",
                          @"EXT OMNIS_6",
                          @"EXT OMNIS_7",
                          //                          @"EXT OMNIS_8",
                          @"APEX BG001_C",
                          @"EXT OMNIS_9",
                          @"EXT OMNIS_A",
                          @"EXT OMNIS_B",
                          @"EXT OMNIS_C",
                          @"EXT OMNIS_D",
                          @"EXT OMNIS_E",
                          @"Embrace TOTAL",
                          nil];
        
        _h2EXT_A_Model = [[NSArray alloc] initWithObjects: @"EXT A_0",
                          @"EXT A_1",
                          @"EXT A_2",
                          nil];
        _h2EXT_B_Model = [[NSArray alloc] initWithObjects: @"EXT B_0",
                          @"EXT B_1",
                          @"EXT B_2",
                          nil];
        _h2EXT_C_Model = [[NSArray alloc] initWithObjects: @"EXT C_0",
                          @"EXT C_1",
                          @"EXT C_2",
                          nil];
        _h2EXT_D_Model = [[NSArray alloc] initWithObjects: @"EXT D_0",
                          @"EXT D_1",
                          @"EXT D_2",
                          nil];
        _h2EXT_E_Model = [[NSArray alloc] initWithObjects: @"EXT E_0",
                          @"EXT E_1",
                          @"EXT E_2",
                          nil];
        _h2EXT_F_Model = [[NSArray alloc] initWithObjects: @"EXT F_0",
                          @"EXT F_1",
                          @"EXT F_2",
                          nil];
        _h2EXT_10_Model = [[NSArray alloc] initWithObjects: @"EXT SIXTEEN_0",
                           @"EXT SIXTEEN_1",
                           @"EXT SIXTEEN_2",
                           nil];
        
        
        // Type definition
        _h2Bionime_Type = [[NSArray alloc] initWithObjects: @"BIONIME_GE100",
                           @"BIONIME_GM550",
                           @"BIONIME_GM700S",
                           nil];
        
        // Ultra Second Model
        _h2OneTouchUltraModel = [[NSArray alloc] initWithObjects:
                                 @"OneTouch Ultra2",
                                 @"OneTouch UltraXXX",
                                 nil];
        
    }
    
    
    return self;
}


@end
