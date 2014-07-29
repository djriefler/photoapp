//
//  QBUser.h
//  PhotoApp
//
//  Created by Duncan Riefler on 6/29/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <Parse/Parse.h>
#import "QBUserContacts.h"

@interface QBUser : PFUser

@property NSString * firstName;
@property NSString * lastName;
@property NSMutableArray * userHistory;
@property QBUserContacts * contacts;
@end
