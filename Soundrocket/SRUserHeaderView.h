//
//  SRUserHeaderView.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRBaseObjects.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import "FFXScrollableSegmentedControl.h"

@protocol SRUSerHeaderDelegate <NSObject>

-(void)userHeaderInfoButtonPressed;

-(void)userHeaderFollowButtonPressed;

-(void)userHeaderUnFollowButtonPressed;

-(void)userHeaderImageTapped;

@end

@interface SRUserHeaderView : UICollectionReusableView

@property (nonatomic,strong) User * user;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet MarqueeLabel *UsernameAndCountryLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberOfSoundsLabel;

@property (nonatomic,strong) IBOutlet FFXScrollableSegmentedControl * segmentedSearchControl;

@property (weak, nonatomic) IBOutlet UIImageView *imageView_backgroundBlurred;

@property (nonatomic,weak) IBOutlet UIButton * showMoreButton;

@property (nonatomic,strong) IBOutlet UIButton * followButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *userLoadingIndicator;

@property (nonatomic,weak) id <SRUSerHeaderDelegate> delegate;


-(void)setupFollowButton;

-(void)setupUnfollowButton;

@end
