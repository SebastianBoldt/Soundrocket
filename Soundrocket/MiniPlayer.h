//
//  MiniPlayer.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EqualizerView.h"
#import "Track.h"
#import <MarqueeLabel.h>


@protocol MiniplayerDelegate <NSObject>
-(void)miniPlayerDidReceivedSwipeUpEvent;
@end

@interface MiniPlayer : UIView

@property (weak, nonatomic)  IBOutlet MarqueeLabel *titleLabel;
@property (weak, nonatomic)  IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic)  IBOutlet UIButton *playButton;
@property (weak, nonatomic)  IBOutlet UIImageView *coverImage;

@property (nonatomic,weak)   IBOutlet UIView * soundIsPlayingView;
@property (nonatomic,strong) UIView * scrollbarMiniPlayer;
@property (nonatomic,assign) BOOL isVisible;

-(IBAction)playButtonPressed:(id)sender;
-(void)setupMiniPlayerWithTrack:(Track*)track;
+(instancetype)sharedMiniPlayer;

@end
