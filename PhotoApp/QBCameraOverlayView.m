//
//  QBCameraOverlayView.m
//  PhotoApp
//
//  Created by Duncan Riefler on 6/25/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBCameraOverlayView.h"

#define CAPTURE_IMAGE_BUTTON_WIDTH 64
#define CAPTURE_IMAGE_BUTTON_HEIGHT 64

#define FLIP_CAMERA_BUTTON_WIDTH 45
#define FLIP_CAMERA_BUTTON_HEIGHT 45


@interface QBCameraOverlayView ()

@end

@implementation QBCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        
        //set up capture image button
        self.captureImagebutton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - CAPTURE_IMAGE_BUTTON_WIDTH/2, self.bounds.size.height - (CAPTURE_IMAGE_BUTTON_HEIGHT + 20), CAPTURE_IMAGE_BUTTON_WIDTH, CAPTURE_IMAGE_BUTTON_HEIGHT)];
        [self.captureImagebutton setBackgroundColor:[UIColor clearColor]];
        UIImage * cameraIcon = [UIImage imageNamed:@"camera-64.png"];
        [self.captureImagebutton setBackgroundImage:cameraIcon forState:UIControlStateNormal];
        self.captureImagebutton.layer.cornerRadius = 50.0;
        
        [self.captureImagebutton setUserInteractionEnabled:YES];
        [self addSubview:self.captureImagebutton];
        
//        UIImage * cameraIcon = [UIImage imageNamed:@"camera-64.png"];
        
        //set up flip camera view button
        self.flipCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - FLIP_CAMERA_BUTTON_WIDTH/2,20, FLIP_CAMERA_BUTTON_WIDTH, FLIP_CAMERA_BUTTON_HEIGHT)];
        [self.flipCameraButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.flipCameraButton setUserInteractionEnabled:YES];
        [self addSubview:self.flipCameraButton];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
}


@end
