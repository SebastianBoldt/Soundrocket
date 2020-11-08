//
//  SRUserCollectionViewCell.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRBaseObjects.h"

@interface SRUserCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameAndCoutryLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSoundsLabel;

@property(nonatomic,strong)User * user;
@end
