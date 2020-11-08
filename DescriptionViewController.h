//
//  DescriptionNavigationViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 30.09.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionViewController : UIViewController

@property (nonatomic,strong) NSString * descriptionText;

@property (nonatomic,strong) IBOutlet UILabel * emptyView;

@property (nonatomic,strong) IBOutlet UITextView * descriptionTextView;

@end
