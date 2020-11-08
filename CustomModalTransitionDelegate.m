//
//  CustomModalTransitionDelegate.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 08.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "CustomModalTransitionDelegate.h"
#import "CustomModalPresentationController.h"

@implementation CustomModalTransitionDelegate
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[CustomModalPresentationController alloc]initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
