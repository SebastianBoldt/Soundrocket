//
//  ProPlanTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 03.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRStoreButton.h"
#import "EqualizerView.h"
@interface ProPlanTableViewController : UITableViewController

@property (nonatomic,strong) IBOutlet UILabel * soundrocketNameLabel;

- (IBAction)purchaseProPlan:(id)sender;

@property (weak, nonatomic) IBOutlet SRStoreButton *buyButton;
@property (weak,nonatomic)  IBOutlet UIActivityIndicatorView * loadingView;
@property (weak,nonatomic)  IBOutlet UILabel * commentsEnabledLabel;
@property (weak,nonatomic)  IBOutlet UILabel * historyFunctionEnabledLabel;
@property (weak,nonatomic)  IBOutlet UILabel * bannerFunctionEnabledLabel;


@property (weak,nonatomic)  IBOutlet UILabel * commentsDescriptionLabel;
@property (weak,nonatomic)  IBOutlet UILabel * historyDescriptionLabel;
@property (weak,nonatomic)  IBOutlet UILabel * bannerDescriptionLabel;

@property (weak,nonatomic)  IBOutlet EqualizerView * waveFormView;

@end
