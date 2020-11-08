//
//  CreatePlaylistTableTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 03.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
@class  SRCreatePlaylistTableTableViewController;

@protocol SRCreatePlaylistControllerDelegateProtocol

-(void)controller:(SRCreatePlaylistTableTableViewController*)controller didCreatePlaylist:(Playlist*)playlist;

@end

@interface SRCreatePlaylistTableTableViewController : UITableViewController

@property (nonatomic,strong) Playlist * playlist;

@property(nonatomic,strong)id<SRCreatePlaylistControllerDelegateProtocol> delegate;

@property (weak, nonatomic) IBOutlet UIButton *createPlaylistButton;
@property (weak, nonatomic) IBOutlet UISwitch *sharingSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameOfPlaylistTextField;
@property (weak, nonatomic) IBOutlet UILabel *privatelabel;

@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (IBAction)createPlaylistButtonPressed:(id)sender;
@end
