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

@interface QBCameraOverlayView ()
@property UIImage * flashImage;
@property UIImage * flashOnImage;
@property UIImage * flashOffImage;
@end

@implementation QBCameraOverlayView
@synthesize flashOn;

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
        UIImage * cameraIcon = [UIImage imageNamed:@"camera-icon-64.png"];
        _flashOnImage = [UIImage imageNamed:@"flash-64x64.png"];
        _flashOffImage = [UIImage imageNamed:@"no-flash-64x64.png"];
        _flashImage = _flashOnImage;
        //set up capture image button
        float borderOffset = 10;
        CGPoint captureButtonPosition = CGPointMake(self.bounds.size.width/2 - CAPTURE_IMAGE_BUTTON_WIDTH/2, self.bounds.size.height - (CAPTURE_IMAGE_BUTTON_HEIGHT + borderOffset));
        CGSize captureImageButtonSize = CGSizeMake(64, 64);
        
        self.captureImagebutton = [[UIButton alloc] initWithFrame:CGRectMake(captureButtonPosition.x, captureButtonPosition.y, captureImageButtonSize.width, captureImageButtonSize.height)];
        [self.captureImagebutton setBackgroundColor:[UIColor clearColor]];
        [self.captureImagebutton setBackgroundImage:whiteCircle forState:UIControlStateNormal];
        self.captureImagebutton.alpha = 1.0;
        self.captureImagebutton.layer.cornerRadius = 50.0;
        [self.captureImagebutton setUserInteractionEnabled:YES];
        [self addSubview:self.captureImagebutton];
        self.captureImagebutton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
//        UIButton * subCameraButton1 = [[UIButton alloc] initWithFrame:self.captureImagebutton.bounds];
//        [subCameraButton1 setUserInteractionEnabled:NO];
//        [subCameraButton1 setBackgroundColor:[UIColor clearColor]];
//        [subCameraButton1 setBackgroundImage:whiteCircle forState:UIControlStateNormal];
//        [subCameraButton1 setBackgroundImage:redCircle forState:UIControlStateHighlighted];
//        subCameraButton1.transform = CGAffineTransformMakeScale(1.00, 1.00);
//        subCameraButton1.alpha = 0.3;
//        subCameraButton1.transform = CGAffineTransformMakeScale(0.7, 0.7);
//        [self.captureImagebutton addSubview:subCameraButton1];
        
        UIButton * subCameraButton2 = [[UIButton alloc] initWithFrame:self.captureImagebutton.bounds];
        [subCameraButton2 setUserInteractionEnabled:NO];
        [subCameraButton2 setBackgroundColor:[UIColor clearColor]];
        [subCameraButton2 setBackgroundImage:cameraIcon forState:UIControlStateNormal];
        subCameraButton2.transform = CGAffineTransformMakeScale(1.00, 1.00);
        subCameraButton2.alpha = 1.0;
        subCameraButton2.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [self.captureImagebutton addSubview:subCameraButton2];
        
        // Set up other buttons
        float buttonWidth = 45;
        float buttonHeight = 45;
        
        //Set up flip camera view button
        CGPoint flipCameraButtonPosition = CGPointMake(self.bounds.size.width - buttonWidth - borderOffset, borderOffset);
        self.flipCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(flipCameraButtonPosition.x, flipCameraButtonPosition.y, buttonWidth, buttonHeight)];
        [self.flipCameraButton setBackgroundImage:[UIImage imageNamed:@"switchCamera.png"] forState:UIControlStateNormal];
        [self.flipCameraButton setUserInteractionEnabled:YES];
        [self addSubview:self.flipCameraButton];
        
        // Set up flash button
        CGPoint flashButtonPosition = CGPointMake(borderOffset, borderOffset);
        self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(flashButtonPosition.x, flashButtonPosition.y, buttonWidth, buttonHeight)];
        [self.flashButton setTintColor:[UIColor blackColor]];
        [self.flashButton setBackgroundImage:_flashImage forState:UIControlStateNormal];
        [self.flashButton setUserInteractionEnabled:YES];
        [self addSubview:self.flashButton];
    }
    return self;
}

- (void) setFlashOn:(BOOL)flash
{
    if (flash == YES) {
        [self.flashButton setBackgroundImage:_flashOffImage forState:UIControlStateNormal];
    }
    else {
        [self.flashButton setBackgroundImage:_flashOnImage forState:UIControlStateNormal];
    }
    flashOn = !flashOn;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    
//}


@end
