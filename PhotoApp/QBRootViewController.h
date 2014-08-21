//
//  QBRootViewController.h
//  PhotoApp
//
//  Created by Duncan Riefler on 8/18/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBLoginViewController.h"
#import "QBContactsViewController.h"
#import "QBCameraViewController.h"

@interface QBRootViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, QBLogInDelegate, QBCameraViewControllerDelegate, UINavigationControllerDelegate, QBContactsViewControllerDelegate>

@end
