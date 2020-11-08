//
//  SRUserHeaderView.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRUserHeaderView.h"
#import "SRStylesheet.h"
#import <FAKIonIcons.h>
#import "SRAuthenticator.h" 
#import <SVProgressHUD.h>
#import "SRHelper.h"

@interface SRUserHeaderView()
@end

@implementation SRUserHeaderView

#pragma mark - UIViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.followButton.layer.borderWidth = 1.0f;
    self.followButton.layer.borderColor = [[SRStylesheet mainColor]CGColor];
    self.followButton.layer.cornerRadius = 5.0f;
    self.followButton.hidden = YES;
    [self.showMoreButton setAttributedTitle:[[FAKIonIcons iosMoreIconWithSize:40]attributedString] forState:UIControlStateNormal];
    
    [self.userLoadingIndicator setHidden:NO];
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 40;
    self.userImageView.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.userImageView.layer.borderWidth = 1.0;

    
    [self.segmentedSearchControl setSelectedSegmentIndex:0];
    [self.segmentedSearchControl setTintColor:[SRStylesheet whiteColor]];
    [self setupUserImageView];
    [self setupFollowButton];
    [self.showMoreButton addTarget:self action:@selector(showMoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showMoreButtonTapped:(id)sender {
    [self.delegate userHeaderInfoButtonPressed];
}

#pragma mark - Setter and Getter

-(void)setUser:(User *)user {
    _user = user;
    [self setupUserInfoWithUser:user];
    NSMutableArray *  segments = [[NSMutableArray alloc]init];
    [segments addObject:[NSString stringWithFormat:NSLocalizedString(@"PROFILE_TABBAR_TRACKS_TITLE", nil),self.user.track_count]];
    [segments addObject:[NSString stringWithFormat:NSLocalizedString(@"PROFILE_TABBAR_PLAYLISTS_TITLE", nil),self.user.playlist_count]];
    [segments addObject:[NSString stringWithFormat:NSLocalizedString(@"PROFILE_TABBAR_LIKES_TITLE", nil),self.user.public_favorites_count]];
    [segments addObject:[NSString stringWithFormat:NSLocalizedString(@"PROFILE_TABBAR_FOLLOWERS_TITLE", nil),self.user.followers_count]];
    [segments addObject:[NSString stringWithFormat:NSLocalizedString(@"PROFILE_TABBAR_FOLLOWINGS_TITLE", nil),self.user.followings_count]];
    [self.segmentedSearchControl setSegments:segments];
}

#pragma mark - Setup functions

-(void)setupUserInfoWithUser:(User*)user {

    if ([self.user.id integerValue] == [[SRAuthenticator sharedAuthenticator].currentUser.id integerValue]) {
        self.followButton.hidden = YES;
    } else {
        self.followButton.hidden = NO;
    }
    
    __weak __block __typeof(self) weakself = self;

    if (user.country) {
        self.UsernameAndCountryLabel.text = [NSString stringWithFormat:@"%@,%@",user.username,user.country];
    } else {
        self.UsernameAndCountryLabel.text = [NSString stringWithFormat:@"%@",user.username];
    }
    
    FAKIonIcons *soundsIcon = [FAKIonIcons podiumIconWithSize:10];
    NSMutableAttributedString * soundsCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",user.track_count]];
    [soundsCount appendAttributedString:[soundsIcon attributedString]];
    // Number of Followers label
    FAKIonIcons *followersIcon = [FAKIonIcons personStalkerIconWithSize:10];
    NSMutableAttributedString * followersCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",user.followers_count]];
    [followersCount appendAttributedString:[followersIcon attributedString]];
    NSAttributedString * spacer = [[NSMutableAttributedString alloc]initWithString:@"    " attributes:nil];
    [followersCount appendAttributedString:spacer];
    [followersCount appendAttributedString:soundsCount];
    self.numberOfSoundsLabel.attributedText = followersCount;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        
        
        NSString*largeUrl = [user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
        
        
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:largeUrl]];
        UIImage * image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.userImageView setImage:image];
            [weakself.imageView_backgroundBlurred setImage:image];
            [weakself.userLoadingIndicator setHidden:YES];
        });
        
    });
}

#pragma mark - Image View

-(void)setupUserImageView {
    self.userImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * rec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userImageViewTapped)];
    [self.userImageView addGestureRecognizer:rec];
}

-(void)userImageViewTapped {
    [self.delegate userHeaderImageTapped];
}

#pragma mark - Follow & Unfollow

-(void)setupFollowButton {
    [self.followButton setTitle:[@"Follow" uppercaseString] forState:UIControlStateNormal];
    [self.followButton removeTarget:self action:@selector(unfollowAction) forControlEvents:UIControlEventTouchUpInside];
    [self.followButton addTarget:self action:@selector(followAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupUnfollowButton {
    [self.followButton setTitle:[@"Unfollow" uppercaseString] forState:UIControlStateNormal];
    [self.followButton removeTarget:self action:@selector(followAction) forControlEvents:UIControlEventTouchUpInside];
    [self.followButton addTarget:self action:@selector(unfollowAction) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)followAction {
    [self.delegate userHeaderFollowButtonPressed];
}

-(void)unfollowAction {
    [self.delegate userHeaderUnFollowButtonPressed];
}

@end
