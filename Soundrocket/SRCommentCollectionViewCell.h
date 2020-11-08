//
//  SRCommentCollectionViewCell.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 27.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STTweetLabel.h>
#import "Comment.h"

@interface SRCommentCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) Comment * comment;

@property (nonatomic,strong) IBOutlet  STTweetLabel * commentBodyLabel;
@property (nonatomic,strong) IBOutlet UIImageView * avatarImageView;
@property (nonatomic,strong) IBOutlet UILabel * userNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * timestampLabel;

@end
