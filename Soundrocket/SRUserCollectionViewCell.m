//
//  SRUserCollectionViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRUserCollectionViewCell.h"
#import "SRStylesheet.h"
#import <FAKFontAwesome.h>
#import <FAKIonIcons.h>

#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation SRUserCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userImageView.clipsToBounds = YES;
}


-(void)setUser:(User *)user {
    _user = user;
    [self setupDataWithUser:user];
}

-(void)setupDataWithUser:(User*)user {
    if (user.country) {
        self.userNameAndCoutryLabel.text = [NSString stringWithFormat:@"%@,%@",user.username,user.country];
    } else {
        self.userNameAndCoutryLabel.text = [NSString stringWithFormat:@"%@",user.username];
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
    
    
    if (user.avatar_url) {
        [self.userImageView setImageWithURL:[NSURL URLWithString:[user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]] placeholderImage:[UIImage imageNamed:@"user"]];
    }
}

-(void)prepareForReuse {
    self.userNameAndCoutryLabel.text = @"";
    [self.userImageView setImage:nil];
}
@end
