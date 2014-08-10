//
//  QBMessagesViewController.m
//  PhotoApp
//
//  Created by Duncan Riefler on 8/9/14.
//  Copyright (c) 2014 Duncan Riefler. All rights reserved.
//

#import "QBMessagesViewController.h"
#import "QBConstants.h"

@interface QBMessagesViewController ()

@end

@implementation QBMessagesViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = kQBPhotoClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of comments to show per page
        self.objectsPerPage = 30;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Messages";
    
}

- (PFQuery *) queryForTable
{
    PFQuery * query = [PFQuery queryWithClassName:kQBPhotoClassKey];
    [query whereKey:kQBPhotoSenderKey equalTo:[PFUser currentUser]];
    [query whereKeyExists:kQBPhotoSenderKey];
    [query includeKey:kQBPhotoReceiverKey];

    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITable View Delegate methods
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString * cellID = @"MessageCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    PFUser * sender = [object objectForKey:kQBPhotoSenderKey];
    [sender fetchIfNeeded];
//    PFUser * receiver = [object objectForKey:kQBPhotoReceiverKey];
    NSString * cellLabel;
    UIColor * cellColor;
    if ([sender isEqual:[PFUser currentUser]]) {
        cellColor = [UIColor blueColor];
//        cellLabel = receiver.username;
    }
    else {
        cellColor = [UIColor greenColor];
        cellLabel = [sender objectForKey:kQBUserUsername];
    }
    [cell.textLabel setText:cellLabel];
    [cell setBackgroundColor:cellColor];
    
    return cell;
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
