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

@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskID;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString * timeDelay;

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

- (void) setImage:(UIImage *)img timeDelay:(NSString *)delay
{
    self.image = img;
    self.timeDelay = delay;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start uploading the photo
    [self shouldUploadImage:self.image];
    
    // Setup navbar
    [self setTitle:@"Send To..."];
    
    // Left Nav Button
    UIImage * backArrow = [UIImage imageNamed:@"arrow2.png"];
    UIImage * backArrow2 = [UIImage imageWithCGImage:backArrow.CGImage scale:backArrow.scale orientation:UIImageOrientationLeft];
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:backArrow2 style:UIBarButtonItemStylePlain target:self action:@selector(returnToCameraView)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    // Right Nav Button
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"send.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(sendPhotoToOtherUser)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
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

- (BOOL) shouldUploadImage: (UIImage *) img
{
    // Compress the image
    NSData *imgData = UIImageJPEGRepresentation(img, 0.8f);
    if (!imgData) {
        return NO;
    }
    
    self.imageFile = [PFFile fileWithData:imgData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskID];
    }];
    
    [self.imageFile saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskID];
    }];
    
    return YES;
}

- (void) returnToCameraView
{
    [self.delegate dismissContactsViewController:self AndDismissPicture:NO];
}

- (void) sendPhotoViaText
{
    MFMessageComposeViewController * messageComposer = [[MFMessageComposeViewController alloc] init];
    // Check to see if the user can send texts
    if ([MFMessageComposeViewController canSendText]) {
        // Check to see if they can send attachments
        if ([MFMessageComposeViewController canSendAttachments]) {
            messageComposer.body = @"You got a message from this user";
            NSData * pictureData = UIImagePNGRepresentation(self.image);
            [messageComposer addAttachmentData:pictureData typeIdentifier:@"public.image" filename:@"image.png"];
            messageComposer.recipients = recipients;
            messageComposer.messageComposeDelegate = self;
            [self presentViewController:messageComposer animated:YES completion:nil];
        }
        else {
            
        }
    }
}

- (void) sendPhotoToOtherUser
{
    // Make sure there were no errors creating the image file
    if (!self.imageFile) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Couldn't send photo"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    // Create photo PFObject
    PFObject *photo = [PFObject objectWithClassName:kQBPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kQBPhotoSenderKey];
    [photo setObject:self.imageFile forKey:kQBPhotoPictureKey];
    
    // Mark the photo to be sent to multiple recipients (Do we create multiple photo objects?)
//    for (PFUser *user in recipients) {
//        
//    }
    
    // Set photo permissions (Who can see the photo, who can edit it)
    PFACL * photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading
    // the photo even if the app is sent to the background
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Save the photo PFObject
    [photo saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        if (success) {
            // TODO: Notify user that photo was sent (In snapchat they change the icon on the messageDisplay controller)
            // Maybe have a local cache of the messages sent and received with a state (pending, sent, received, opened, etc)
            // Update the cache, then send an NSNotification which will be received by the messages view controller
        }
        else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Couldn't send your photo"
                                                             message:nil
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"dismiss", nil];
            [alert show];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Dismiss this screen (Uncomment this and fix view controller hierarchy
//    [self.delegate dismissContactsViewController:self AndDismissPicture:YES];
    
    // Create a messages view controller
    QBMessagesViewController * qbmvc = [[QBMessagesViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:qbmvc animated:YES];
}

#pragma mark - MFMessageComposer Methods

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [self.delegate dismissContactsViewController:self AndDismissPicture:YES];
    }];
}

#pragma mark - Table view data source

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
    ABRecordRef person = (__bridge ABRecordRef)([[[QBUserContacts sharedInstance] contacts] objectAtIndex:[indexPath row]]);
    NSString * firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString * lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    NSString * space = [NSString stringWithFormat:@" "];
    if (firstName != nil && lastName != nil) {
        NSString * fullName = [firstName stringByAppendingString:space];
        fullName = [fullName stringByAppendingString:lastName];
        [[cell textLabel] setText:fullName];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        ABRecordRef person = (__bridge ABRecordRef)([[[QBUserContacts sharedInstance] contacts] objectAtIndex:[indexPath row]]);
        NSString * number = [self phoneNumberForPerson:person];
        [recipients addObject: number];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
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
