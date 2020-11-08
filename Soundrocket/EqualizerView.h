//
//  SoundIsPlayingView.h
//  AnimationView
//
//  Created by Sebastian Boldt on 29.03.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EqualizerView : UIView
-(void)start;
-(void)stop;
-(void)setup;
@property (nonatomic,strong) UIColor *color;
@end
