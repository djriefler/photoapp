//
//  QBRootViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 8/4/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBLoginViewController.h"
#import "QBCameraViewController.h"
#import "QBUser.h"

@interface QBLoginViewController ()
{
    QBCameraViewController * cameraViewController;
}
@end

@implementation QBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PFUser *currentUser = [PFUser currentUser];

    if (!currentUser) {
        // Create login controller
        PFLogInViewController * loginViewController = [[PFLogInViewController alloc] init];
        [loginViewController setDelegate:self];
        
        // Create sign up controller
        PFSignUpViewController * signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        [loginViewController setSignUpController:signUpViewController];
        
        [self presentViewController:loginViewController animated:YES completion:nil];

    }
}

- (void) presentCameraViewControllerAnimated:(BOOL) animated
{
    QBCameraViewController * dvc = [[QBCameraViewController alloc] init];
    [self presentViewController:dvc animated:animated completion:nil];
}

#pragma mark - PFLoginController Delegate Methods

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

- (void) logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didLoginUser];
    }];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PFSignUpController Delegate Methods

- (BOOL) signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    
    // Check if the fields have been completed. May want to add more checks for
    for (id key in info) {
        NSString * field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field isnt complete
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Incomplete Information"
                                   message:@"Make sure you fill out all the information correctly"
                                  delegate:self
                         cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
    }
    return informationComplete;
}

- (void) signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    // Create new user
    QBUser * newUser = [QBUser object];
    [newUser setPassword:user.password];
    [newUser setUsername:user.username];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didLoginUser];
    }];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

#pragma mark - ETC

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
