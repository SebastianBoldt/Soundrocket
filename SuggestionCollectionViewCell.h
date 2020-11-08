//
//  SuggestionCollectionViewCell.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 14.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRTrackCollectionViewCell.h"
@interface SuggestionCollectionViewCell : UICollectionViewCell
@property (nonatomic,weak) IBOutlet UIImageView * coverView;
@property (nonatomic,weak) IBOutlet UIButton * usernameLabel;
@property (nonatomic,weak) IBOutlet UILabel * trackNameLabel;
@property (nonatomic,weak) IBOutlet UILabel * playbackCountLabel;
@property (nonatomic,weak) IBOutlet UIView * playlistIndicator;
@property (nonatomic,weak) IBOutlet UILabel* playlistLabel;

@property (nonatomic,strong) id<SRTrackCollectionViewCellDelegate> delegate;
@property (nonatomic,strong) id object;
@end
