//
//  SRTabbarViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 23.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniPlayer.h"

@interface SRTabbarViewController : UITabBarController

@property (nonatomic,strong) IBOutlet MiniPlayer * miniPlayer;

@end
