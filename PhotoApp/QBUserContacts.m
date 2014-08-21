//
//  QBUserStore.m
//  PhotoApp
//
//  Created by Duncan Riefler on 7/10/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//
// This is a singleton that stores all of the user data

#import "QBUserContacts.h"
#import "QBUser.h"

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

- (NSArray *) fakeContacts
{
    NSMutableArray * fakeContacts = [[NSMutableArray alloc] init];
    NSString * name1 = @"James";
    NSString * name2 = @"Jill";
    NSString * name3 = @"Bob";
    NSString * name4 = @"Tom";
    NSString * name5 = @"Sarah";
    NSString * name6 = @"Brandy";
    NSString * name7 = @"Jennifer";
    NSString * name8 = @"Rex";
    NSString * name9 = @"James";
    NSString * name10 = @"Jill";
    NSString * name11 = @"Bob";
    NSString * name12 = @"Tom";
    [fakeContacts addObject:name1];
    [fakeContacts addObject:name2];
    [fakeContacts addObject:name3];
    [fakeContacts addObject:name4];
    [fakeContacts addObject:name5];
    [fakeContacts addObject:name6];
    [fakeContacts addObject:name7];
    [fakeContacts addObject:name8];
    [fakeContacts addObject:name9];
    [fakeContacts addObject:name10];
    [fakeContacts addObject:name11];
    [fakeContacts addObject:name12];

    return fakeContacts;
}

- (void) cleanContacts
{
    
}

- (NSArray *) contacts
{
    return contacts;
}

@end
