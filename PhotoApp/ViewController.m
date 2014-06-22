//
//  ViewController.m
//  CameraApp
//
//  Created by Christopher Daniels on 6/21/14.
//  Copyright (c) 2014 QuickBrownFox. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view
    }
    return self;
}

- (IBAction)TakePhoto
{
    picker1 = [[UIImagePickerController alloc] init];
    picker1.delegate = self;
    [picker1 setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker1 animated:YES completion:NULL];
}

- (IBAction)ChooseExisting
{
    picker2 = [[UIImagePickerController alloc] init];
    picker2.delegate = self;
    [picker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker2 animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imageView setImage:image];
    [self dismissViewControllerAnimated:YES completion: NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
