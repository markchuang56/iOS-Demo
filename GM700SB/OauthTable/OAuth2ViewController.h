//
//  OAuth2ViewController.h
//  GMSB
//
//  Created by Jason Chuang on 3/25/19.
//  Copyright © 2019 h2Sync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthRequestController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OAuth2ViewController : UIViewController <OAuthRequestControllerDelegate>

- (IBAction)authorizeTask:(id)sender;
- (IBAction)getUserProfileTask:(id)sender;

@end

NS_ASSUME_NONNULL_END
