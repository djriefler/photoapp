//
//  DJViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 6/16/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBViewController.h"
#import "QBCameraOverlayView.h"
#import "QBContactsViewController.h"
#import <Parse/Parse.h>

@interface QBViewController ()
{
    BOOL firstLoad;
}
@property QBCameraOverlayView * cameraOverlay;
@property (nonatomic) UIImagePickerController * imagePicker;
@property (nonatomic)  UIImageView * imageView;

@property (nonatomic) UIButton * cancelButton;
@property (nonatomic) UIButton * sendButton;

@end

@implementation QBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        firstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up image view where the image that we take will appear
    self.imageView = [[UIImageView alloc] init];
    // This is the wrong frame size. TODO: FIX
    self.imageView.frame = self.view.frame;
    
    // now let's set it as the image on the screen
    [self.view addSubview:self.imageView];
    
    // Set up cancel button
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 60, 40, 40)];
    [self.view addSubview:_cancelButton ];
    [_cancelButton setBackgroundColor:[UIColor redColor]];
    [_cancelButton addTarget:self action:@selector(cancelTakingPicture) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setHidden:YES];
    
    // Set up send button (will send photo to the cloud)
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 60, 40, 40)];
    [self.view addSubview:_sendButton];
    [_sendButton setBackgroundColor:[UIColor greenColor]];
    [_sendButton addTarget:self action:@selector(loadContactsPage) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setHidden:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Check to see if device has a camera and the view hasn't been loaded yet
    if (firstLoad == YES && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        firstLoad = NO;
        [self setupImagePicker];
    }
}

- (void) setupImagePicker
{
    // Create the camera view and present it
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // Next few lines of code make it so that the camera is full screen like snapchat versus like the regular camera.
    //Camera is 426 * 320. Screen height is 568.  Multiply by 1.333 in 5 inch to fill vertical
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0); //This slots the preview exactly in the middle of the screen by moving it down 71 points
    self.imagePicker.cameraViewTransform = translate;

    CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
    self.imagePicker.cameraViewTransform = scale;
    
    [_imagePicker setDelegate:self];
    [self presentViewController:_imagePicker animated:NO completion:nil];
    
    // Create and display custom overlay
    // Don't show default controls
    _imagePicker.showsCameraControls = NO;
    _cameraOverlay = [[QBCameraOverlayView alloc] initWithFrame:_imagePicker.view.frame];
    _imagePicker.cameraOverlayView = _cameraOverlay;
    
    // Set the imageCaptureButton in the CameraOverlayClass to take a picture when tapped on
    [_cameraOverlay.captureImagebutton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    
    //Set the flipCameraButton in the CameraOverlayClass to take a picture when tapped on
    [_cameraOverlay.flipCameraButton addTarget:self action:@selector(flipCamera) forControlEvents:UIControlEventTouchUpInside];
}

- (void) flipCamera
{
    if(_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    else {
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

- (void) takePicture
{
    if(_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.imageView.transform = CGAffineTransformMakeScale(1.33, 1.0);
    }
    else {
        self.imageView.transform = CGAffineTransformMakeScale(-1.33, 1.0);
    }
    [self.imagePicker takePicture];
}

- (void) cancelTakingPicture
{
    [_cancelButton setHidden:YES];
    [self setupImagePicker];
}

- (void) loadContactsPage
{
    QBContactsViewController * cvc = [[QBContactsViewController alloc] initWithStyle:UITableViewStylePlain];
    cvc.image = _imageView.image;
    cvc.delegate = self;
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void) dismissContactsViewController:(QBContactsViewController *)cvc AndDismissPicture:(BOOL)dismissPicture
{
    [cvc dismissViewControllerAnimated:YES completion:^{
        if (dismissPicture) {
            [self cancelTakingPicture];
        }
    }];
}

# pragma mark - Image Picker Delegate Methods
// called when a picture has been taken
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // This is the image that was taken
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Set the imageView's image to this image.
    [self.imageView setImage:image];
    
    // Dismiss the imagePicker which will reveal the imageView we have placed behind it
    [self.imagePicker dismissViewControllerAnimated:NO completion:NULL];
    self.imagePicker = nil;
    self.cameraOverlay = nil;
    
    [_cancelButton setHidden:NO];
    [_cancelButton setUserInteractionEnabled:YES];
    [_sendButton setHidden:NO];
    [_sendButton setUserInteractionEnabled:YES];
}


#pragma mark - Parse related methods
- (void) sendPicture
{
    // Resize image
    UIImage * image = _imageView.image;
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect:CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Convert to data to send to the cloud
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.05f);
    [self uploadImage: imageData];
}

- (void) uploadImage:(NSData *) imageData
{
    PFFile * imageFile = [PFFile fileWithName:@"snap.jpg" data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error) {
            PFObject * userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            PFUser * user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"UserPhoto object successfully created!");
                }
                else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else {
            
        }
        
    } progressBlock:^(int percentDone) {
                               // Update your progress spinner here. percentDone will be between 0 and 100.
//                               HUD.progress = (float)percentDone/100;
                           }];
}

#pragma mark - Etc

- (BOOL) prefersStatusBarHidden
{
    return YES;
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
