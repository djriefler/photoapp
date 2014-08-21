//
//  DJViewController.h
//  PhotoApp
//
//  Created by Duncan Riefler on 6/16/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <stdlib.h>
#import "QBContactsViewController.h"
#import "MBProgressHUD.h"
#import "QBLoginViewController.h"
#import "QBPhoto.h"

@interface QBCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property id delegate;
- (void) cancelTakingPicture;

@end

@protocol QBCameraViewControllerDelegate

- (void) userWantsSendPhoto: (QBPhoto *) photo;

@end