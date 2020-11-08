//
//  SRCommentCollectionViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 27.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRCommentCollectionViewCell.h"
#import <STTweetLabel.h>
#import "SRStylesheet.h"
#import "SRAuthenticator.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SoundCloudAPI.h"
#import "SRBaseObjects.h"
#import "SRPlayer.h"
#import "PlayerViewController.h"
#import "SRHelper.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
@implementation SRCommentCollectionViewCell

-(void)setComment:(Comment *)currentComment {
    _comment = currentComment;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:currentComment.user.avatar_url] placeholderImage:nil];
    self.commentBodyLabel.text = currentComment.body;
    self.userNameLabel.text = currentComment.user.username;
    self.timestampLabel.text = [NSString stringWithFormat:@"says at %@",[self getDateFromTimeStamp:[currentComment.timestamp floatValue]/1000]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 25;
    self.avatarImageView.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.avatarImageView.layer.borderWidth = 1.0;
    self.userNameLabel.textColor = [SRStylesheet mainColor];
    [self setupTweetLabel];
}

-(void)prepareForReuse{
    self.commentBodyLabel.text = @"";
    self.avatarImageView.image = nil;
    self.userNameLabel.text = @"";
}

-(void)setupTweetLabel {
    STTweetLabel* label = (STTweetLabel*)self.commentBodyLabel;
    label.userInteractionEnabled = YES;
    NSDictionary* linkAttributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:14.0],
                                     NSForegroundColorAttributeName:[SRStylesheet mainColor]
                                     };
    [label setAttributes:linkAttributes hotWord:STTweetLink];
    [label setAttributes:linkAttributes hotWord:STTweetHashtag];
    [label setAttributes:linkAttributes hotWord:STTweetHandle];
    
    [label setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        switch (hotWord){
            case STTweetLink:
                [self handleURL:string];
                break;
            default: break;
        }
    }];
}

-(void)handleURL:(NSString*)string {
    
    [SVProgressHUD show];
    [[SoundCloudAPI sharedApi]resolveURL:string whenSuccess:^(NSURLSessionTask * task, id responseObject) {
        Track * track = [[Track alloc]initWithDictionary:responseObject error:nil];
        if (track.streamable) {
            [SRPlayer sharedPlayer].upNext = nil;
            [SRPlayer sharedPlayer].model = nil;
            [[SRPlayer sharedPlayer]setCurrentTrack:track];
            [[SRPlayer sharedPlayer] setPlayingIndex:0];
            [PlayerViewController sharedPlayerViewController].requestModel = nil;
        } else {
            [SRHelper showNotStreamableNotification];
        }
        [SVProgressHUD dismiss];
    }whenError:^(NSURLSessionTask * task, NSError* error){
        [SVProgressHUD dismiss];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:string]];
    }];
}

-(NSString*)getDateFromTimeStamp:(float)currentTime{
    // Setze das Zeit label
    
    NSUInteger h_current = (NSUInteger)currentTime / 3600;
    NSUInteger m_current = ((NSUInteger)currentTime / 60) % 60;
    NSUInteger s_current = (NSUInteger)currentTime % 60;
    
    
    NSString *formattedCurrent;
    if (h_current == 0) {
        formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m_current, (unsigned long)s_current];
    } else {
        formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h_current, (unsigned long)m_current, (unsigned long)s_current];
    }
    
    return formattedCurrent;
}

@end
