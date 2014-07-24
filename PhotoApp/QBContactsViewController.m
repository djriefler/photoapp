//
//  QBContactsViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 6/27/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import "QBUserStore.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
                                                                    action:@selector(sendPhoto)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        if (granted) {
            ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
            NSArray *myContacts = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName));
            [[QBUserStore sharedInstance] addContacts:myContacts];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            [[self tableView] reloadData];
        }
        else {
            NSLog(@"%@", error);
        }
    });
}

- (void) returnToCameraView
{
    [self.delegate dismissContactsViewController];
}

- (void) sendPhoto
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [[[QBUserStore sharedInstance] contacts] count]-1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"ContactCell"];
    }
    ABRecordRef person = (__bridge ABRecordRef)([[[QBUserStore sharedInstance] contacts] objectAtIndex:[indexPath row]]);
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
        ABRecordRef person = (__bridge ABRecordRef)([[[QBUserStore sharedInstance] contacts] objectAtIndex:[indexPath row]]);
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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