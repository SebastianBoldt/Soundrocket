//
//  AboutTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AboutTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *webSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *libariesLabel;
@property (weak, nonatomic) IBOutlet UILabel *soundrocketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateThisAppLabel;
@property (weak, nonatomic) IBOutlet UILabel *poweredByLabel;
@property (weak, nonatomic) IBOutlet UILabel *mySoundCloudProfileLabel;

@end
