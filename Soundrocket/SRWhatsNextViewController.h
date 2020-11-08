//
//  SRWhatsNextViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 01.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRBaseCollectionViewController.h"

@protocol SRWhatsNextViewControllerDelegate <NSObject>
-(void)nextControllerDidSelectPlaylist:(Playlist*)playlist;
@end

@interface SRWhatsNextViewController : SRBaseCollectionViewController
@property (nonatomic,strong) id <SRWhatsNextViewControllerDelegate> delegate;
@end
