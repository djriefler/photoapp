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
@property UIImage * image;

@end

@protocol QBContactsViewControllerDelegate

- (void) dismissContactsViewController;

@end