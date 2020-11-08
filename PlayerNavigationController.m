//
//  PlayerNavigationController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 09.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "PlayerNavigationController.h"

@implementation PlayerNavigationController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
