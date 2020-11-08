//
//  CustomModalPresentationController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 08.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "CustomModalPresentationController.h"

@implementation CustomModalPresentationController

-(instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        self.dimmingView = [[UIView alloc]init];
        self.dimmingView.backgroundColor = [UIColor blackColor];
    }

    return self;
}

-(void)presentationTransitionWillBegin {
    self.presentedViewController.view.clipsToBounds = YES;
    self.presentedViewController.view.layer.cornerRadius = 10.0f;
    
    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0.0f;
    [self.containerView insertSubview:self.dimmingView atIndex:0];
    
    [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /* Reorganize views, or move child view controllers */
        self.dimmingView.alpha = 0.7f;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
    
}


-(void)dismissalTransitionWillBegin {
    [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /* Reorganize views, or move child view controllers */
        self.dimmingView.alpha = 0.0f;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.dimmingView removeFromSuperview];
    }];
}

-(CGRect)frameOfPresentedViewInContainerView {
    return CGRectInset(self.containerView.frame, 30, 100);
}

@end
