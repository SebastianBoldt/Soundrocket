//
//  UIViewController+ToolbarPlayerAddition.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 09.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "UIViewController+ToolbarPlayerAddition.h"
#import "PlayerNavigationController.h"
#import "SRStylesheet.h"
@implementation UIViewController (ToolbarPlayerAddition)

-(void)showToolbarIfIamInsideThePlayerNavigationController {
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIButton * backButton = [[UIButton alloc]init];
    backButton.titleLabel.text = @"back";
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back to Player",nil) style:UIBarButtonItemStylePlain target:self action:@selector(popToPlayer:)];
    
    btnCancel.tintColor = [SRStylesheet whiteColor];
    [barItems addObject:btnCancel];
    [barItems addObject:flexSpace];
    
    if ([self.navigationController isKindOfClass:[PlayerNavigationController class]]) {
        [self setToolbarItems:barItems];
        [self.navigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
        [self.navigationController setToolbarHidden:NO animated:NO];
    } else {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
}

-(void)popToPlayer:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
