//
//  QBRootViewController.h
//  PhotoApp
//
//  Created by Duncan Riefler on 8/4/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//
// Manages signing up users or sending them straight to the camera view

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface QBLoginViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property id delegate;

@end

@protocol QBLogInDelegate

- (void) didLoginUser;

@end
