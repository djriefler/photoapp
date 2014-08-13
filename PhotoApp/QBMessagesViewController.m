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
    // Create one query for getting all the photos that the user has sent
    PFQuery * sentPhotosQuery = [PFQuery queryWithClassName:kQBPhotoClassKey];
    [sentPhotosQuery whereKey:kQBPhotoSenderKey equalTo:[PFUser currentUser]];

    // Create another query for getting all the photos that have been sent to the user
    PFQuery * receivedPhotosQuery = [PFQuery queryWithClassName:kQBPhotoClassKey];
    [receivedPhotosQuery whereKey:kQBPhotoReceiverKey equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:sentPhotosQuery, receivedPhotosQuery, nil]];
    [query includeKey:kQBPhotoReceiverKey];
    [query includeKey:kQBPhotoSenderKey];
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UITableViewDelegate methods
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString * cellID = @"MessageCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSString * cellLabel;
    UIColor * cellColor;
    if (object) {
        NSString * photoSenderUsername = [[object objectForKey:kQBPhotoSenderKey] objectForKey:kQBUserUsername];
        NSString * currentUserUsername = [[PFUser currentUser] objectForKey:kQBUserUsername];
        // If the current user sent this photo, display one type of cell
        if ([photoSenderUsername isEqual:currentUserUsername]) {
            cellColor = [UIColor blueColor];
        }
        // If the current user received this photo display another type of cell
        else {
            cellColor = [UIColor greenColor];
            //        cellLabel = [sender objectForKey:kQBUserUsername];
        }
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
