//
//  DownloadsTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 09.04.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "DownloadsTableViewController.h"
#import "BasicTrackTableViewCell.h"
#import "SRDownloadManager.h"
#import "SRUserController.h" 
#import "Soundrocket-SWIFT.h"
#import <SVProgressHUD.h>
#import "SRPlayer.h"

@interface DownloadsTableViewController()<UITableViewDataSource,UITabBarControllerDelegate>
@property(nonatomic,strong) NSMutableArray * tracks;
@end

@implementation DownloadsTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Downloads",nil)];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    self.tracks = [[SRDownloadManager sharedManager]downloadedTracks];
    [self.tableView reloadData];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 55, 0);
}

#pragma mark tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[SRDownloadManager sharedManager]downloadedTracks]count]; // Encoded
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasicTrackTableViewCell *cell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
    Track * track = [self.tracks objectAtIndex:indexPath.row];
    cell.data = track;
    cell.delegate = self;
    return  cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

-(void)userButtonPressedWithUserID:(NSNumber *)user_id {
    SRUserController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"user"];
    controller.user_id = user_id;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row < [self.tracks count]) {
        Track * track = [self.tracks objectAtIndex:indexPath.row];
        [SRPlayer sharedPlayer].upNext = [self.tracks mutableCopy];
        [SRPlayer sharedPlayer].model = nil;
        [[SRPlayer sharedPlayer] setCurrentTrack:track];
        [[SRPlayer sharedPlayer] setPlayingIndex:indexPath];
        
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

// Deletion Stuff



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// Deleting Playlists stuff
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Track * track = [self.tracks objectAtIndex:indexPath.row];
        BOOL success = [[SRDownloadManager sharedManager]removeTrack:track];
        if (success) {
            [self.tableView reloadData];

        }        
    
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)setUpRefreshControl {
}

@end
