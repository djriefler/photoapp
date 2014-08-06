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


@interface QBCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBContactsViewControllerDelegate, QBLogInDelegate>
{

}


@end
