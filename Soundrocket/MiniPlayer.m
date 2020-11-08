//
//  MiniPlayer.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "MiniPlayer.h"
#import "PlayerViewController.h"
#import "SRStylesheet.h"
#import "Soundrocket-SWIFT.h"

@interface MiniPlayer()<SRPlayerDelegate>
@end

@implementation MiniPlayer

+ (instancetype)sharedMiniPlayer {
    
    AppDelegate * delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return [delegate getRoot].miniPlayer;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self initColors];
    [[SRPlayer sharedPlayer]addDelegate:self];
    
    // Initial setup of play button
    
    [self.playButton setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

    
    self.playButton.tintColor = [SRStylesheet darkGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initColors)
                                                 name:@"appColorChanged" object:nil];
}

-(void)initColors {
    [self.artistNameLabel setTextColor:[SRStylesheet darkGrayColor]];
}
-(void)drawRect:(CGRect)rect {
    //NSLog(@"************************SCROLLBAR CREATED************************");
    if (!self.scrollbarMiniPlayer) {
        self.scrollbarMiniPlayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 2)];
    }
    self.scrollbarMiniPlayer.backgroundColor = [SRStylesheet mainColor];
    [self addSubview:self.scrollbarMiniPlayer];
}


-(IBAction)playButtonPressed:(id)sender {
    
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.playButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.playButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    [[SRPlayer sharedPlayer] togglePlayback];
}

-(void)setupMiniPlayerWithTrack:(Track*)track {
    self.artistNameLabel.text = track.user.username;
    self.titleLabel.text = track.title;
    
    if (track.artwork_url) {
        [self.coverImage setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:nil];
    } else {
        [self.coverImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
    }
    
    
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    //[UIView setAnimationDidStopSelector:@selector(callFunctionAfterAnimation)]; //this would call a method named - (void)callFunctionAfterAnimation; inside this class
    [UIView setAnimationDuration: .5];
    [UIView setAnimationDelegate: self];
    self.isVisible = YES;
    [UIView commitAnimations];
}

#pragma mark - SRPlayerDelegate

-(void)player:(SRPlayer *)player willPlayTrack:(Track *)track {
    [self.playButton setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self setupMiniPlayerWithTrack:track];
    //[self.soundIsPlayingView start];
}

-(void)player:(SRPlayer *)player willPauseTrack:(Track *)track {
    [self.playButton setImage:[[UIImage imageNamed:@"play"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //[self.soundIsPlayingView stop];
}

-(void)player:(SRPlayer *)player willStartWithTrack:(Track *)track fromIndexPath:(NSIndexPath *)path {
    
}

-(void)player:(SRPlayer *)player didFinishWithTrack:(Track *)track {
    
}
-(void)player:(SRPlayer *)player isReadyToPlayTrack:(Track *)track {
    
}

-(void)player:(SRPlayer *)player willStartWithOfflineTrack:(Track *)track {
    
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

-(void)dealloc {
    [[SRPlayer sharedPlayer]removeDelegate:self];
}
@end
