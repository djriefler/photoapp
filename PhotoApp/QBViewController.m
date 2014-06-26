//
//  DJViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 6/16/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBViewController.h"
#import "QBCameraOverlayView.h"
#import <Parse/Parse.h>

@interface QBViewController ()
{
    BOOL firstLoad;
}
@property QBCameraOverlayView * cameraOverlay;
@property (nonatomic) UIImagePickerController * imagePicker;
@property (nonatomic)  UIImageView * imageView;

@property (nonatomic) UIButton * cancelButton;

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
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 60, 40, 40)];
    [self.view addSubview:_cancelButton ];
    [_cancelButton setBackgroundColor:[UIColor redColor]];
    [_cancelButton addTarget:self action:@selector(cancelTakingPicture) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setHidden:YES];
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
    [self presentViewController:_imagePicker animated:YES completion:nil];
    
    // Create and display custom overlay
    // Don't show default controls
    _imagePicker.showsCameraControls = NO;
    _cameraOverlay = [[QBCameraOverlayView alloc] initWithFrame:_imagePicker.view.frame];
    _imagePicker.cameraOverlayView = _cameraOverlay;
    
    // Set the imageCaptureButton in the CameraOverlayClass to take a picture when tapped on
    [_cameraOverlay.captureImagebutton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
}

- (void) takePicture
{
    [self.imagePicker takePicture];
}

- (void) cancelTakingPicture
{
    [_cancelButton setHidden:YES];
    [self setupImagePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.imagePicker dismissViewControllerAnimated:YES completion:NULL];
    self.imagePicker = nil;
    self.cameraOverlay = nil;
    
    [_cancelButton setHidden:NO];
    [_cancelButton setUserInteractionEnabled:YES];
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