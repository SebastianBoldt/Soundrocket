//
//  PlaylistTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRBaseObjects.h"
#import "SRBaseCollectionViewController.h"
#import "SRCreatePlaylistTableTableViewController.h"

@interface SRPlaylistsController : SRBaseCollectionViewController <SRCreatePlaylistControllerDelegateProtocol>

@property (nonatomic,assign) NSNumber * user_id;

@property (nonatomic,strong) Track * track; // if this Track is set, the current controller will add the track to the selected playlist

@end
