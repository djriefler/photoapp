//
//  QBPhoto.h
//  PhotoApp
//
//  Created by Duncan Riefler on 8/14/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface QBPhoto : NSObject

@property PFUser * sender;
@property NSMutableArray * recipients;
@property UIImage * image;
@property NSData * imageData;
@property NSTimeInterval timeDelay;

@end
