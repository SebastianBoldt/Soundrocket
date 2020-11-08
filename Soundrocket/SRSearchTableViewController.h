//
//  SearchTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRBaseCollectionViewController.h"

@interface SRSearchTableViewController : SRBaseCollectionViewController

@property (nonatomic,strong) IBOutlet UIView * searchHintView;

@property (nonatomic,strong) IBOutlet UILabel * searchIconImageView;

@property (nonatomic,strong) IBOutlet UILabel * searchHintText;

@end
