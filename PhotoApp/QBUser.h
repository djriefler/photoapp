//
//  QBUser.h
//  PhotoApp
//
//  Created by Duncan Riefler on 6/29/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <Parse/Parse.h>
#import "QBUserContacts.h"
#import "QBUserMessages.h"
#import <Parse/PFObject+Subclass.h>

@interface QBUser : PFUser <PFSubclassing>

@property NSString * firstName;
@property NSString * lastName;
@property NSString * phoneNumber;
@property QBUserContacts * contacts;
@property QBUserMessages * messages;

@end
