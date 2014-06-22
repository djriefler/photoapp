//lsdkfjasldf
//  ViewController.h
//  CameraApp
//
//  Created by Christopher Daniels on 6/21/14.
//  Copyright (c) 2014 QuickBrownFox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImagePickerController *picker1;
    UIImagePickerController *picker2;
    UIImage *image;
    IBOutlet UIImageView *imageView;
}

- (IBAction)TakePhoto;
- (IBAction)ChooseExisting;

@end
