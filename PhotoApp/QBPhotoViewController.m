//
//  QBPhotoViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 8/17/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBPhotoViewController.h"

@interface QBPhotoViewController ()
@property UIImage * photo;
@property UIImageView * imageView;
@property NSTimeInterval viewTime;
@end

@implementation QBPhotoViewController

- (id)initWithPhoto:(UIImage *)photo
{
    self = [super init];
    if (self) {
        self.photo = photo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.photo) {
        self.viewTime = 5.0;
        self.imageView = [[UIImageView alloc] initWithImage:self.photo];
        self.imageView.frame = self.view.frame;
        self.view = self.imageView;
        [self performSelector:@selector(dismissPhotoViewController) withObject:nil afterDelay:5.0];
    }
}

- (void) dismissPhotoViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
