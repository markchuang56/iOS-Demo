//
//  ViewController.h
//  demo-pod
//
//  Created by Jason Chuang on 3/18/19.
//  Copyright © 2019 Jason Chuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthRequestController.h"

//@interface ViewController : UIViewController
@interface ViewController : UIViewController <OAuthRequestControllerDelegate>

- (IBAction)authorizeTask:(id)sender;
- (IBAction)getUserProfileTask:(id)sender;

@end

