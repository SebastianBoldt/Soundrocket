//
//  SRLoadingCollectionViewCell.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 23.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRLoadingCollectionViewCell : UICollectionReusableView
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView * loadingIndicator;
@end
