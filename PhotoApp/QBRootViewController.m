//
//  QBRootViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 8/18/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBRootViewController.h"
#import "QBMessagesViewController.h"
#import <Parse/Parse.h>
#import "QBConstants.h"

@interface QBRootViewController ()
{
    BOOL firstLoad;
    NSInteger currentPageViewControllerIndex;
}

@property QBPhoto * currentPhoto;
@property PFFile * imageFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskID;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property QBCameraViewController * cameraViewController;
@property QBMessagesViewController * messagesViewController;

@end

@implementation QBRootViewController

- (id)init
{
    self = [super init];
    if (self) {
        firstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (firstLoad == YES) {
        firstLoad = NO;
        PFUser *currentUser = [PFUser currentUser];
        
        if (!currentUser) {
            QBLoginViewController * rvc = [[QBLoginViewController alloc] init];
            rvc.delegate = self;
            [self presentViewController:rvc animated:NO completion:NULL];
        }
        else {
            // Create page view controller
            UIPageViewController * pageViewController = [[UIPageViewController alloc]
                                                         initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                         navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                         options:nil];
            
            // Create camera and message views
            self.cameraViewController = [[QBCameraViewController alloc] init];
            self.cameraViewController.delegate = self;
            self.messagesViewController = [[QBMessagesViewController alloc] init];
            
            // Add controllers to the page view controller
            NSMutableArray * viewControllers = [[NSMutableArray alloc] init];
            [viewControllers addObject:self.cameraViewController];
            [pageViewController setViewControllers:viewControllers
                                         direction:UIPageViewControllerNavigationDirectionForward
                                          animated:YES
                                        completion:nil];
            currentPageViewControllerIndex = 0;
            [viewControllers addObject:self.messagesViewController];
            
            [self addChildViewController:pageViewController];
            [self.view addSubview:pageViewController.view];
        }
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
//    UIViewController * currentVC = [pageViewController.viewControllers objectAtIndex:currentPageViewControllerIndex];
    if ([viewController isKindOfClass:[QBCameraViewController class]]) {
        viewController = _messagesViewController;
    }
    else if ([viewController isKindOfClass:[QBMessagesViewController class]]) {
        return _cameraViewController;
    }
    return nil;
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[QBCameraViewController class]]) {
        viewController = _messagesViewController;
    }
    else if ([viewController isKindOfClass:[QBMessagesViewController class]]) {
        return _cameraViewController;
    }
    return nil;
}

#pragma mark - UIPageViewControllerDelegate


#pragma mark - QBLoginController Delegate Methods
- (void) didLoginUser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QBCameraViewControllerDelegate Methods
- (void) userWantsSendPhoto:(QBPhoto *)photo
{
    self.currentPhoto = photo;

    // Start uploading the image
    [self shouldUploadImage:photo.image];
    
    // Load contacts view controller to choose who the photo is sent to
    QBContactsViewController * cvc = [[QBContactsViewController alloc] initWithStyle:UITableViewStylePlain];
    cvc.delegate = self;
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:navController animated:YES completion:nil];
}

# pragma mark - Contact View Controller Methods

- (void) userCancelledSendingPhoto
{
    // Dismiss the contacts view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) userWillSendPhotoToRecipients:(NSMutableArray *)recipients
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
    [photo setObject:recipients forKey:kQBPhotoReceiverKey];
//    [photo setObject:self.currentPhoto.timeDelay forKey:kQBPhotoTimeDelayKey];
    
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
        // reset properties
        self.currentPhoto = nil;
        self.imageFile = nil;
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Dismiss this screen
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Show the messages view controller
    
}

#pragma mark - Etc

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
