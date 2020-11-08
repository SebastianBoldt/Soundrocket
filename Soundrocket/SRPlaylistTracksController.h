//
//  PlaylistTracksListTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "SRBaseCollectionViewController.h"
@interface SRPlaylistTracksController : SRBaseCollectionViewController
@property (nonatomic,strong) Playlist * currentPlaylist;
@end
