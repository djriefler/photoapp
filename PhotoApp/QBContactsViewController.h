//
//  QBContactsViewController.h
//  PhotoApp
//
//  Created by Duncan Riefler on 6/27/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface QBContactsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate>

@property id delegate;
- (void) setImage:(UIImage *) img timeDelay:(NSString *) delay;

@end

@protocol QBContactsViewControllerDelegate

- (void) dismissContactsViewController: (QBContactsViewController *) cvc AndDismissPicture: (BOOL) dismissPicture;

@end