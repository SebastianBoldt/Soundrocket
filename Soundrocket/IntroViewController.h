//
//  IntroViewController.h
//  StumbleSound
//
//  Created by Sebastian Boldt on 30.05.14.
//  Copyright (c) 2014 Sebastian Boldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController <UIPageViewControllerDataSource>

- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
- (IBAction)refreshButtonPressed:(id)sender;

@end
