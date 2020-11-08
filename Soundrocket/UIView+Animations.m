//
//  UIView+Animations.m
//  Fashionfreax
//
//  Created by Sebastian Boldt on 06.10.15.
//  Copyright © 2015 Fashionfreax GmbH. All rights reserved.
//

#import "UIView+Animations.h"

@implementation UIView (Animations)

-(void)wiggleView {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.values = @[ @0, @0.02, @-0.02, @0.02, @0 ];
    animation.keyTimes = @[ @0, @0.25, @0.50, @0.75, @1 ];
    animation.calculationMode = @"cubicPaced";
    animation.duration = 0.4;
    animation.additive = YES;
    [self.layer addAnimation:animation forKey:@"wiggle"];
}

-(void)pulseView {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)];
    [animation setDuration:0.15];
    [animation setAutoreverses:YES];
    [self.layer addAnimation:animation forKey:@"pulse"];
}

@end
