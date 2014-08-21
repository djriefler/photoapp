//
//  DJViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 6/16/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBCameraViewController.h"
#import "QBCameraOverlayView.h"
#import "QBContactsViewController.h"
#import <Parse/Parse.h>
#import "QBConstants.h"

@interface QBCameraViewController ()
{
    BOOL firstLoad;
}

@property QBCameraOverlayView * cameraOverlay;
@property (nonatomic) UIImagePickerController * imagePicker;
@property (nonatomic)  UIImageView * imageView;
@property (nonatomic) UIButton * cancelButton;
@property (nonatomic) UIButton * sendButton;
@property (nonatomic) UIButton * timeDelayButton;
@property UITableView * timeDelayTable;

@end

@implementation QBCameraViewController

#pragma mark - Init Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        firstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor blackColor]];
    
    // Set up image view where the image that we take will appear
    self.imageView = [[UIImageView alloc] init];
    // This is the wrong frame size. TODO: FIX
    self.imageView.frame = self.view.frame;
    
    // now let's set it as the image on the screen
    [self.view addSubview:self.imageView];
    
    // Set up cancel button
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];
    [self.view addSubview:_cancelButton ];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel-48.png"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelTakingPicture) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton setHidden:YES];
    
    // Set up time delay button
    _timeDelayButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 60, 40, 40)];
    [self.view addSubview:_timeDelayButton];
    [_timeDelayButton setBackgroundImage:[UIImage imageNamed:@"hourglass-64.png"] forState:UIControlStateNormal];
    [_timeDelayButton addTarget:self action:@selector(timeDelayButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_timeDelayTable setHidden:YES];
    
    // Set up send button
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 60, 40, 40)];
    [self.view addSubview:_sendButton];
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"send-64.png"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendPhoto) forControlEvents:UIControlEventTouchUpInside];
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
    [_imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];

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
    
    // Set the flipCameraButton to switch cameras when tapped on
    [_cameraOverlay.flipCameraButton addTarget:self action:@selector(flipCamera) forControlEvents:UIControlEventTouchUpInside];
    
    // Set the flash button to toggle flash when tapped on
    [_cameraOverlay.flashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];

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
    
    // Perform animation to rotate the camera button
    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(360.0);
//    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.2, 1.2);
//    CGAffineTransform transform = CGAffineTransformConcat(rotateTransform, scaleTransform);
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:1.0
                        options:0
                     animations:^{
                         self.cameraOverlay.captureImagebutton.transform = rotateTransform;
                     }
                     completion:nil];
    
    // Transform the image to make it sized properly
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

- (void) toggleFlash
{
    if ([_imagePicker cameraFlashMode] == YES) {
        [self.cameraOverlay setFlashOn:NO];
        [self.imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
    }
    else {
        [self.cameraOverlay setFlashOn:YES];
        [self.imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
    }
}

- (void) timeDelayButtonPressed
{
    if (!_timeDelayTable) {
        _timeDelayTable = [[UITableView alloc] initWithFrame:CGRectMake(5, _timeDelayButton.frame.origin.y - 220, 80, 20) style:UITableViewStylePlain];
        _timeDelayTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _timeDelayTable.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        _timeDelayTable.showsVerticalScrollIndicator = NO;
        _timeDelayTable.bounces = NO;
        [_timeDelayTable setHidden:YES];
        [_timeDelayTable.layer setCornerRadius:5.0f];
        _timeDelayTable.delegate = self;
        _timeDelayTable.dataSource = self;
        [self.view addSubview:_timeDelayTable];
    }
    if ([_timeDelayTable isHidden]) {
        [_timeDelayTable setHidden:NO];
        [_timeDelayTable setFrame:CGRectMake(5, _timeDelayButton.frame.origin.y - 220, 80, 20)];
        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:0.9
              initialSpringVelocity:0.7
                            options:0
                         animations:^{
                             _timeDelayTable.frame = CGRectMake(5, _timeDelayButton.frame.origin.y - 220, 80, 200);
                         }completion:^(BOOL success){
                             
                         }];
    }
}

- (void) sendPhoto
{
    QBPhoto * photo = [[QBPhoto alloc] init];
    photo.timeDelay = 5;
    photo.image = _imageView.image;
    [self.delegate userWantsSendPhoto:photo];
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

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"TimeCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld hr",(long)indexPath.row+1]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    return cell;
}

#pragma mark - UITableViewDelegate


#pragma mark - Touch Methods

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_timeDelayTable) {
        [_timeDelayTable setHidden:YES];
    }
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
