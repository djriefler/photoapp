//
//  QBUserStore.m
//  PhotoApp
//
//  Created by Duncan Riefler on 7/10/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//
// This is a singleton that stores all of the user data

#import "QBUserContacts.h"

@implementation QBUserContacts
{
    NSMutableArray * contacts;
}

- (id) init {
    self = [super init];
    if (self) {
        contacts = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (QBUserContacts *) sharedInstance
{
    static QBUserContacts * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[QBUserContacts alloc] init];
    });
    
    return _sharedInstance;
}

- (void) addContact:(id)contact
{
    [contacts addObject:contacts];
}

- (void) addContacts:(NSArray *)cntcts
{
    [contacts addObjectsFromArray:cntcts];
    [self cleanContacts];
}

- (void) cleanContacts
{
    
}

- (NSArray *) contacts
{
    return contacts;
}

@end