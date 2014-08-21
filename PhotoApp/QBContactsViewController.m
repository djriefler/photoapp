//
//  QBContactsViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 6/27/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBContactsViewController.h"
#import "QBConstants.h"
#import <AddressBook/AddressBook.h>
#import "QBUserContacts.h"
#import "QBUser.h"
#import "QBMessagesViewController.h"

@interface QBContactsViewController ()
{
    NSMutableArray * recipients;
}

@end

@implementation QBContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        recipients = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void) setPhoto:(QBPhoto *) photo
{
    self.photo = photo;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Navbar
    [self setupNavbar];
    
    // load in fake contacts
    [self loadInContacts];
}

- (void) setupNavbar
{
    // Setup navbar
    [self setTitle:@"Send To..."];
    
    // Left Nav Button
    UIImage * backArrow = [UIImage imageNamed:@"arrow2.png"];
    UIImage * backArrow2 = [UIImage imageWithCGImage:backArrow.CGImage scale:backArrow.scale orientation:UIImageOrientationLeft];
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:backArrow2
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(cancelButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    // Right Nav Button
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"send.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(sendPhotoButtonPressed)];
    [self.navigationItem setRightBarButtonItem:rightButton];
}

- (void) loadInContacts
{
    [[QBUserContacts sharedInstance] addContacts:[[QBUserContacts sharedInstance] fakeContacts]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [[self tableView] reloadData];
}

- (void) cancelButtonPressed
{
    [self.delegate userCancelledSendingPhoto];
}

- (void) sendPhotoButtonPressed
{
    [self.delegate userWillSendPhotoToRecipients:recipients];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[QBUserContacts sharedInstance] contacts] count]-1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"ContactCell"];
    }
    NSString * friendName = [[[QBUserContacts sharedInstance] contacts] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:friendName];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        NSString * friendName = [[[QBUserContacts sharedInstance] contacts] objectAtIndex:[indexPath row]];
        [recipients addObject: friendName];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        NSString * friendName = [[[QBUserContacts sharedInstance] contacts] objectAtIndex:[indexPath row]];
        [recipients removeObject:friendName];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Unused Methods

// Old function for loading in contacts from phonebook in iOS 7
//- (void) loadCellInfoFromContacts
//{
//    ABRecordRef person = (__bridge ABRecordRef)([[[QBUserContacts sharedInstance] contacts] objectAtIndex:[indexPath row]]);
//    NSString * firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
//    NSString * lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
//    NSString * space = [NSString stringWithFormat:@" "];
//    if (firstName != nil && lastName != nil) {
//        NSString * fullName = [firstName stringByAppendingString:space];
//        fullName = [fullName stringByAppendingString:lastName];
//        [[cell textLabel] setText:fullName];
//    }
//}

- (void) loadInContactsFromPhone
{
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        if (granted) {
            ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
            NSArray *myContacts = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName));
            [[QBUserContacts sharedInstance] addContacts:myContacts];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            [[self tableView] reloadData];
        }
        else {
            NSLog(@"%@", error);
        }
    });
}

- (NSString *) phoneNumberForPerson: (ABRecordRef) person
{
    ABMultiValueRef phones = (__bridge ABMultiValueRef)((__bridge NSString *) ABRecordCopyValue(person, kABPersonPhoneProperty));
    NSString * mobileLabel;
    NSString * mobileNumber = @"";
    for (CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
        mobileLabel = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phones, i));
        if ([mobileLabel isEqualToString:(NSString *) kABPersonPhoneIPhoneLabel] || [mobileLabel isEqualToString:(NSString *) kABPersonPhoneMobileLabel]) {
            mobileNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phones, i);
            break;
        }
    }
    if ([mobileNumber  isEqualToString: @""]) {
        mobileNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phones, 0);
    }
    return mobileNumber;
}

//- (void) sendPhotoViaText
//{
//    MFMessageComposeViewController * messageComposer = [[MFMessageComposeViewController alloc] init];
//    // Check to see if the user can send texts
//    if ([MFMessageComposeViewController canSendText]) {
//        // Check to see if they can send attachments
//        if ([MFMessageComposeViewController canSendAttachments]) {
//            messageComposer.body = @"You got a message from this user";
//            NSData * pictureData = UIImagePNGRepresentation(self.photo.image);
//            [messageComposer addAttachmentData:pictureData typeIdentifier:@"public.image" filename:@"image.png"];
//            messageComposer.recipients = recipients;
//            messageComposer.messageComposeDelegate = self;
//            [self presentViewController:messageComposer animated:YES completion:nil];
//        }
//        else {
//            
//        }
//    }
//}

//- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//{
//    [controller dismissViewControllerAnimated:YES completion:^{
//        [self.delegate dismissContactsViewController:self AndDismissPicture:YES];
//    }];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
