//
//  SRTrackCollectionViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 23.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRTrackCollectionViewCell.h"
#import "Track.h"
#import "Playlist.h"
#import <NSDate+DateTools.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FAKFontAwesome.h>
#import <FAKIonIcons.h>
#import "SRStylesheet.h"    

@implementation SRTrackCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    FAKIonIcons *playIcon = [FAKIonIcons iosAlbumsIconWithSize:17];
    self.playlistIndicatorLabel.attributedText = [playIcon attributedString];
    
    [self setupUI];
    [self setupData];
    self.userNameLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.userNameLabel addTarget:self action:@selector(userButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(showMoreButtonPressed:)];
    
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc]
     initWithTarget:self action:@selector(showMoreButtonPressed:)];
    
    [self.moreImageWrapperView addGestureRecognizer:tapGesture];
    self.moreImage.image = [[UIImage imageNamed:@"more"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.moreImage.tintColor = [SRStylesheet mainColor];
    self.moreImage.userInteractionEnabled = YES;
    
    [self.contentView addGestureRecognizer:longPress];
}

-(void)showMoreButtonPressed:(UITapGestureRecognizer*)recognizer {
    [self.delegate optionsButtonPressedForObject:self.data inView:recognizer.view];
}

-(void)userButtonPressed:(id)sender {
    if([self.data  respondsToSelector:@selector(user)]){
        User * user = (User*)[self.data performSelector:@selector(user) withObject:nil];
        [self.delegate userButtonPressedWithUser:user];
    }
}

-(void)setData:(id)data {
    _data = data;
    [self setupData];
}


-(void)setupData {
    if ([self.data isKindOfClass:[Track class]]) {
        [self setupCellWithTrack:(Track*)self.data];
        self.playlistIndicatorView.hidden = YES;
    } else if([self.data isKindOfClass:[TrackRepost class]]) {
        [self setupCellWithRepost:(TrackRepost*)self.data];
        self.playlistIndicatorView.hidden = YES;
    } else if([self.data isKindOfClass:[Playlist class]]){
        [self setupCellWithPlaylist:(Playlist*)self.data];
        self.playlistIndicatorView.hidden = NO;
    } else if([self.data isKindOfClass:[PlaylistRepost class]]){
        [self setupCellWithPlaylistRepost:(PlaylistRepost*)self.data];
        self.playlistIndicatorView.hidden = NO;
    }
}

#pragma mark - Setup Functions
-(void)setupCellWithTrack:(Track*)track {
    
    [self.userNameLabel setTitle:track.user.username forState:UIControlStateNormal];
    self.trackNameLabel.text = track.title;
    
    NSDate *timeAgoDate = [self convertUTCStringToDate:track.created_at];
    self.dateLabel.text =   timeAgoDate.timeAgoSinceNow;
    
    if (self.showBigImage) {
        if (track.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[track.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[track.user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        }
    } else {
        if (track.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:nil];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
        }
    }

    
    FAKIonIcons *playIcon = [FAKIonIcons playIconWithSize:10];
    NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.playback_count integerValue]]];
    [playbackcount appendAttributedString:[playIcon attributedString]];
    
    FAKIonIcons *likeIcon = [FAKIonIcons heartIconWithSize:10];
    NSMutableAttributedString * likecount = nil;
    if (track.likes_count) {
        likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.likes_count integerValue]]];
    } else {
        likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.favoritings_count integerValue]]];
    }
    [likecount appendAttributedString:[likeIcon attributedString]];
    
    FAKIonIcons *commentIcon = [FAKIonIcons chatboxIconWithSize:10];
    NSMutableAttributedString * commentCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.comment_count integerValue]]];
    [commentCount  appendAttributedString:[commentIcon attributedString]];
    
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:likecount];
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:commentCount];
    
    if (track.reposts_count) {
        FAKFontAwesome *repostIcon = [FAKFontAwesome retweetIconWithSize:10];
        NSMutableAttributedString * repostCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.reposts_count integerValue]]];
        [repostCount appendAttributedString:[repostIcon attributedString]];
        [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
        [playbackcount appendAttributedString:repostCount];
    }
    
    self.playbackCountLabel.attributedText = playbackcount;
    
}

-(void)setupCellWithRepost:(TrackRepost*)trackRepost {
    FAKFontAwesome *retweetIcon = [FAKFontAwesome retweetIconWithSize:10];
    [self.respostedLabel setAttributedText:[retweetIcon attributedString]];
    self.respostedLabel.clipsToBounds = YES;
    self.respostedLabel.layer.cornerRadius = 10;
    self.respostedLabel.backgroundColor = [UIColor lightGrayColor];
    
    TrackRepost * track = (TrackRepost*)trackRepost;
    [self.userNameLabel setTitle:track.user.username forState:UIControlStateNormal];
    self.trackNameLabel.text = track.title;
    NSDate *timeAgoDate = [self convertUTCStringToDate:track.created_at];
    self.dateLabel.text =   timeAgoDate.timeAgoSinceNow;
    
    if (self.showBigImage) {
        if (track.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[track.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[track.user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        }
    } else {
        if (track.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:nil];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
        }
    }
    
    FAKIonIcons *starIcon = [FAKIonIcons playIconWithSize:10];
    NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.playback_count integerValue]]];
    [playbackcount appendAttributedString:[starIcon attributedString]];
    
    
    FAKIonIcons *likeIcon = [FAKIonIcons heartIconWithSize:10];
    NSMutableAttributedString * likecount = nil;
    if (track.likes_count) {
        likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.likes_count integerValue]]];
    } else {
        likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.favoritings_count integerValue]]];
    }
    [likecount appendAttributedString:[likeIcon attributedString]];
    
    FAKIonIcons *commentIcon = [FAKIonIcons chatboxIconWithSize:10];
    NSMutableAttributedString * commentCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld ",(long)[track.comment_count integerValue]]];
    [commentCount  appendAttributedString:[commentIcon attributedString]];
    
    
    
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:likecount];
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:commentCount];
    
    if (track.reposts_count) {
        FAKFontAwesome *repostIcon = [FAKFontAwesome retweetIconWithSize:10];
        NSMutableAttributedString * repostCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.reposts_count]];
        [repostCount appendAttributedString:[repostIcon attributedString]];
        [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
        [playbackcount appendAttributedString:repostCount];
    }
    /*
     if (track.downloadable) {
     FAKIonIcons *downloadIcon = [FAKIonIcons ios7DownloadIconWithSize:12];
     [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
     NSMutableAttributedString * string = [[downloadIcon attributedString]mutableCopy];
     [string addAttribute:NSForegroundColorAttributeName value:[SRStylesheet mainColor] range:NSMakeRange(0,1)];
     [playbackcount appendAttributedString:string];
     }*/
    
    self.playbackCountLabel.attributedText = playbackcount;
    
    
}

-(void)setupCellWithPlaylist:(Playlist*)playlist {
    
    [self.userNameLabel setTitle:playlist.user.username forState:UIControlStateNormal];
    NSDate *timeAgoDate = [self convertUTCStringToDate:playlist.created_at];
    self.dateLabel.text =   timeAgoDate.timeAgoSinceNow;
    self.trackNameLabel.text = playlist.title;
    
    if (self.showBigImage) {
        if (playlist.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[playlist.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[playlist.user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        }
    } else {
        if (playlist.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:playlist.artwork_url] placeholderImage:nil];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:playlist.user.avatar_url] placeholderImage:nil];
        }
    }
    
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
    self.firstLayerViewPlaylist.hidden = NO;
    self.secondLayerViewPlaylist.hidden = NO;
    
}

-(void)setupCellWithPlaylistRepost:(PlaylistRepost*)playlistRepost {
    
    FAKFontAwesome *retweetIcon = [FAKFontAwesome retweetIconWithSize:10];
    [self.respostedLabel setAttributedText:[retweetIcon attributedString]];
    self.respostedLabel.clipsToBounds = YES;
    self.respostedLabel.layer.cornerRadius = 10;
    self.respostedLabel.backgroundColor = [UIColor lightGrayColor];
    [self.userNameLabel setTitle:playlistRepost.user.username forState:UIControlStateNormal];
    NSDate *timeAgoDate = [self convertUTCStringToDate:playlistRepost.created_at];
    self.dateLabel.text =   timeAgoDate.timeAgoSinceNow;
    
    self.trackNameLabel.text = playlistRepost.title;
    
    if (self.showBigImage) {
        if (playlistRepost.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[playlistRepost.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:[playlistRepost.user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]]];
        }
    } else {
        if (playlistRepost.artwork_url) {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:playlistRepost.artwork_url] placeholderImage:nil];
        } else {
            [self.artworkImage setImageWithURL:[NSURL URLWithString:playlistRepost.user.avatar_url] placeholderImage:nil];
        }
    }
    
    // Private not private etc
    FAKFontAwesome * lockIcon = [FAKFontAwesome lockIconWithSize:10];
    NSMutableAttributedString * lockString = [[NSMutableAttributedString alloc]init];
    if ([playlistRepost.sharing isEqualToString:@"private"]) {
        lockString = [[lockIcon attributedString]mutableCopy];
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %ld Tracks",(long)[playlistRepost.track_count integerValue]]]];
        
    } else {
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld Tracks",(long)[playlistRepost.track_count integerValue]]]];
    }
    self.playbackCountLabel.attributedText = lockString;
    
    self.firstLayerViewPlaylist.hidden = NO;
    self.secondLayerViewPlaylist.hidden = NO;
}

-(void)setupUI {
    self.artworkImage.clipsToBounds = YES;
    //self.artworkImage.layer.cornerRadius = 25;
    //self.artworkImage.layer.borderWidth = 1.0;
    
    self.firstLayerViewPlaylist.clipsToBounds = YES;
    //self.firstLayerViewPlaylist.layer.cornerRadius = 25;
    self.firstLayerViewPlaylist.layer.borderColor = [[SRStylesheet lightGrayColor] CGColor];
    self.firstLayerViewPlaylist.layer.borderWidth = 1.0;
    [self.firstLayerViewPlaylist setHidden:YES];
    
    self.secondLayerViewPlaylist.clipsToBounds = YES;
    //self.secondLayerViewPlaylist.layer.cornerRadius = 25;
    self.secondLayerViewPlaylist.layer.borderColor = [[SRStylesheet lightGrayColor] CGColor];
    self.secondLayerViewPlaylist.layer.borderWidth = 1.0;
    [self.secondLayerViewPlaylist setHidden:YES];
    
    [self.userNameLabel setTitleColor:[SRStylesheet lightGrayColor] forState:UIControlStateNormal];
}

-(void)prepareForReuse {
    self.artworkImage.image = nil;
    [self.userNameLabel setTitle:@"" forState:UIControlStateNormal];
    self.firstLayerViewPlaylist.hidden = YES;
    self.secondLayerViewPlaylist.hidden = YES;
    self.backgroundColor = [UIColor whiteColor];
    [self.respostedLabel setText:@""];
    [self.respostedLabel setBackgroundColor:[UIColor clearColor]];
}

- (void) setSelected:(BOOL) selected animated:(BOOL) animated{
    
}

-(NSDate *)convertUTCStringToDate:(NSString *)utcDateString {
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"yyyy/MM/dd HH:mm:ss +0000";
    return [df dateFromString:utcDateString];
}

@end
