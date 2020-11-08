//
//  SuggestionCollectionViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 14.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import "SuggestionCollectionViewCell.h"
#import "Track.h"
#import "TrackRepost.h"
#import "Playlist.h"
#import "PlaylistRepost.h"

#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import <UIImageView+AFNetworking.h>
#import <NSDate+DateTools.h>
#import <FAKFontAwesome.h>


@implementation SuggestionCollectionViewCell

-(void)mySharedSuggestionCell {
    self.usernameLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.usernameLabel addTarget:self action:@selector(userButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    FAKIonIcons *playIcon = [FAKIonIcons iosAlbumsIconWithSize:17];
    self.playlistLabel.attributedText = [playIcon attributedString];
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self mySharedSuggestionCell];
}

-(void)userButtonPressed:(id)sender {
    if([self.object  respondsToSelector:@selector(user)]){
        User * user = (User*)[self.object performSelector:@selector(user) withObject:nil];
        [self.delegate userButtonPressedWithUser:user];
    }
}

-(instancetype)init {
    if (self = [super init]) {
        [self mySharedSuggestionCell];
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.coverView.image = nil;
    self.playlistIndicator.hidden = YES;
}

-(void)setObject:(id)object {
    _object = object;
    if ([object isKindOfClass:[Track class]]) {
        [self setupCellWithTrack:(Track*)object];
    } else if([object isKindOfClass:[TrackRepost class]]) {
        [self setupCellWithTrack:[[Track alloc]initWithTrackRespost:object]];
    } else if([object  isKindOfClass:[Playlist class]]){
        [self setupCellWithPlaylist:(Playlist*)object];
    } else if([object isKindOfClass:[PlaylistRepost class]]){
        [self setupCellWithPlaylist:[[Playlist alloc]initWithPlayListRepost:object]];
    }
}

#pragma mark - Setup Functions
-(void)setupCellWithTrack:(Track*)track {
    self.playlistIndicator.hidden = YES;
    if (track.artwork_url) {
        [self.coverView setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:nil];
    } else {
        [self.coverView setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
    }
    

    [self.usernameLabel setTitle:track.user.username forState:UIControlStateNormal];
    self.trackNameLabel.text = track.title;
        
    FAKIonIcons *playIcon = [FAKIonIcons playIconWithSize:10];
    NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.playback_count integerValue]]];
    [playbackcount appendAttributedString:[playIcon attributedString]];
    
    self.playbackCountLabel.attributedText = playbackcount;
}



-(void)setupCellWithPlaylist:(Playlist*)playlist {
    if (playlist.artwork_url) {
        [self.coverView setImageWithURL:[NSURL URLWithString:playlist.artwork_url] placeholderImage:nil];
    } else {
        [self.coverView setImageWithURL:[NSURL URLWithString:playlist.user.avatar_url] placeholderImage:nil];
    }

    [self.usernameLabel setTitle:playlist.user.username forState:UIControlStateNormal];
    self.trackNameLabel.text = playlist.title;
    
    
    // Private not private etc
    FAKFontAwesome * lockIcon = [FAKFontAwesome lockIconWithSize:10];
    NSMutableAttributedString * lockString = [[NSMutableAttributedString alloc]init];
    if ([playlist.sharing isEqualToString:@"private"]) {
        lockString = [[lockIcon attributedString]mutableCopy];
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %ld Tracks",(long)[playlist.track_count integerValue]]]];
        
    } else {
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld Tracks",(long)[playlist.track_count integerValue]]]];
    }
    self.playbackCountLabel.attributedText = lockString;
    self.playlistIndicator.hidden = NO;
    
}

-(NSDate *)convertUTCStringToDate:(NSString *)utcDateString {
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy/MM/dd HH:mm:ss +0000";
    return [df dateFromString:utcDateString];
}

/*
-(void)userButtonPressed:(id)sender {
    if([self.data  respondsToSelector:@selector(user)]){
        User * user = (User*)[self.data performSelector:@selector(user) withObject:nil];
        [self.delegate userButtonPressedWithUserID:user.id];
    }
}*/
@end
