//
//  QBContactsViewController.h
//  PhotoApp
//
//  Created by Duncan Riefler on 6/27/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "QBPhoto.h"

@interface QBContactsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property id delegate;
- (void) setPhoto:(QBPhoto *) photo;

@end

@protocol QBContactsViewControllerDelegate

- (void) userWillSendPhotoToRecipients:(NSMutableArray *) recipients;
- (void) userCancelledSendingPhoto;

@end