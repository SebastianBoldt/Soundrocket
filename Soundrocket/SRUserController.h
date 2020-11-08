//
//  UserTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel.h>
#import "SRBaseObjects.h"
#import "SRBaseCollectionViewController.h"
#import "SRUserHeaderView.h"

@interface SRUserController : SRBaseCollectionViewController

@property (nonatomic,strong) NSNumber * user_ID; // Sometimes it is not possible to get an user object so we need the id to fetch

@property (nonatomic,strong) IBOutlet SRUserHeaderView * headerView;

@end
