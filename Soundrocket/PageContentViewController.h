//
//  PageContentViewController.h
//  StumbleSound
//
//  Created by Sebastian Boldt on 30.05.14.
//  Copyright (c) 2014 Sebastian Boldt. All rights reserved.
//
#import <MarqueeLabel.h>
#import <UIKit/UIKit.h>
#import <BTLabel.h>
@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet BTLabel * titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@end
