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
        
        UIImage * redCircle = [UIImage imageNamed:@"red-circle-icon-64.png"];
        UIImage * whiteCircle = [UIImage imageNamed:@"white-circle-icon-64.png"];
        UIImage * blackCircle = [UIImage imageNamed:@"black-circle-icon-64.png"];
        UIImage * blackOutlineCircle = [UIImage imageNamed:@"black-circle-outline-icon-64.png"];
        UIImage * blackDashedOutlineCircle = [UIImage imageNamed:@"circle-dashed-8-icon-64.png"];

        //set up capture image button
        self.captureImagebutton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - CAPTURE_IMAGE_BUTTON_WIDTH/2, self.bounds.size.height - (CAPTURE_IMAGE_BUTTON_HEIGHT + 20), CAPTURE_IMAGE_BUTTON_WIDTH, CAPTURE_IMAGE_BUTTON_HEIGHT)];
        [self.captureImagebutton setBackgroundColor:[UIColor clearColor]];
        [self.captureImagebutton setBackgroundImage:whiteCircle forState:UIControlStateNormal];
        [self.captureImagebutton setBackgroundImage:redCircle forState:UIControlStateHighlighted];
        self.captureImagebutton.alpha = 0.7;
        self.captureImagebutton.layer.cornerRadius = 50.0;
        [self.captureImagebutton setUserInteractionEnabled:YES];
        [self addSubview:self.captureImagebutton];
        
        self.captureImagebutton.transform = CGAffineTransformMakeScale(1.2, 1.2);
        
        
        UIButton * subCameraButton = [[UIButton alloc] initWithFrame:self.captureImagebutton.bounds];
        [subCameraButton setUserInteractionEnabled:NO];
        [subCameraButton setBackgroundColor:[UIColor clearColor]];
        [subCameraButton setBackgroundImage:blackOutlineCircle forState:UIControlStateNormal];
        subCameraButton.transform = CGAffineTransformMakeScale(1.05, 1.05);
        subCameraButton.alpha = 1.0;

        [self.captureImagebutton addSubview:subCameraButton];
                
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
