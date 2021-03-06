//
//  QBUserStore.h
//  PhotoApp
//
//  Created by Duncan Riefler on 7/10/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUserContacts : NSObject

+ (QBUserContacts *) sharedInstance;
- (NSArray *) contacts;
- (NSArray *) fakeContacts;
- (void) addContact:(id) contact;
- (void) addContacts: (NSArray *) cntcts;
@end
