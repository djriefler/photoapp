//
//  QBUserStore.m
//  PhotoApp
//
//  Created by Duncan Riefler on 7/10/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBUserStore.h"

@implementation QBUserStore
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

+ (QBUserStore *) sharedInstance
{
    static QBUserStore * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[QBUserStore alloc] init];
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
