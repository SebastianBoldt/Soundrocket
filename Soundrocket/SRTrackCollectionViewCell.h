//
//  SRTrackCollectionViewCell.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 23.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRBaseObjects.h"

@protocol SRTrackCollectionViewCellDelegate <NSObject>

-(void)userButtonPressedWithUser:(User*)user;

-(void)optionsButtonPressedForObject:(id)object inView:(UIView*)view;

@end

@interface SRTrackCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) IBOutlet UIButton * userNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * trackNameLabel;
@property (nonatomic,strong) IBOutlet UIImageView * artworkImage;
@property (nonatomic,strong) IBOutlet UILabel * playbackCountLabel;
@property (weak, nonatomic) IBOutlet UIView *firstLayerViewPlaylist;
@property (weak, nonatomic) IBOutlet UIView *secondLayerViewPlaylist;
@property (weak,nonatomic) id<SRTrackCollectionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *respostedLabel;
@property (weak,nonatomic) IBOutlet UILabel * dateLabel;
@property (nonatomic,assign) BOOL showBigImage;
@property (nonatomic,strong) IBOutlet UIImageView * moreImage;
@property (nonatomic,strong) IBOutlet UIView * moreImageWrapperView;

@property (nonatomic,strong) IBOutlet UIView * playlistIndicatorView;
@property (nonatomic,strong) IBOutlet UILabel * playlistIndicatorLabel;


//
@property (nonatomic,strong) id data;

@end
