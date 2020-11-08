//
//  CommentsTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 15.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRBaseCollectionViewController.h"
#import "Track.h"

// Todo
// Deleting Comments should be possible

@protocol SRCommentsViewControllerDelegate <NSObject>

-(void)commentsViewControllerDidDismissWithUser:(User*)user;

@end

@interface SRCommentsViewController : SRBaseCollectionViewController


@property (nonatomic,strong) id <SRCommentsViewControllerDelegate> delegate;

@property (nonatomic,strong) Track * currentTrack;

@end
