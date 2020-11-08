//
//  PlayerViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

// Librarys
#import <MarqueeLabel.h>
#import <UIKit/UIKit.h>

// Own classes
#import "SRBaseObjects.h"
#import "EqualizerView.h"
#import "WaveFormView.h"
#import "SRPlayer.h"
#import "SRRequestModel.h"

@class PlayerViewController;

@protocol PlayerViewControllerDelegate <NSObject>

-(void)playerViewControllerDidDismissForProPlan:(PlayerViewController*)viewController;
-(void)playerViewControllerDidDismissWithPlaylist:(Playlist*)playlist;
-(void)playerViewControllerDidDismissWithUser:(User*)user;
-(void)playerViewControllerDidDismissWithTrackForFavoriters:(Track*)track;

@end

@interface PlayerViewController : UIViewController
@property (weak, nonatomic) IBOutlet MarqueeLabel *trackIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak,nonatomic) IBOutlet UIImageView * backGroundView;
@property (weak, nonatomic) IBOutlet UIView * commentsView; // View with stripes and comments
@property (weak, nonatomic) IBOutlet UILabel * noCommentsLabel;
@property (weak, nonatomic) IBOutlet WaveFormView * waveformView;
@property (weak, nonatomic) IBOutlet UIButton * likeButton;
@property (weak, nonatomic) IBOutlet UILabel * durationLabel;
@property (weak, nonatomic) IBOutlet UILabel * expiredLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userCommentedImageView;
@property (weak, nonatomic) IBOutlet MarqueeLabel *currentCommentLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *commentIconLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *lastCommentButton;
@property (weak, nonatomic) IBOutlet UIView *commentView;

@property (weak, nonatomic) IBOutlet UIButton *lastTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *nextTrackButton;
@property (weak, nonatomic) IBOutlet MarqueeLabel*userNameLabel;
@property (weak, nonatomic) IBOutlet EqualizerView *eaqualizerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIImageView *mirroredCoverImageView;

@property (strong, nonatomic) SRRequestModel * requestModel;

@property (nonatomic,weak) id<PlayerViewControllerDelegate> delegate;
- (IBAction)lastCommentButtonPressed:(id)sender;
- (IBAction)nextCommentButtonPressed:(id)sender;
- (IBAction)playPauseButtonPressed:(id)sender;
- (void)unsubScribe;
- (IBAction)favButtonPressed:(id)sender;
- (void)setUpComments:(Track*)track;
-(IBAction)closeCommentingView:(id)sender;
+(instancetype)sharedPlayerViewController;
@end
