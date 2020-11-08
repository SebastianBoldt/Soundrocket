//
//  SettingsTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 12.05.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//
#import <FAKIonIcons.h>
#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import "SettingsTableViewController.h"
#import "SRStylesheet.h"

@implementation SettingsTableViewController
-(void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Settings",nil)];
    [self setupLabels];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupLabels];
}

-(void)setupLabels {
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [SRStylesheet darkGrayColor]};
    self.colorSettingsTextLabel.attributedText = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"Set your Client ID",nil) attributes:attributes];
    self.colorSettingsIconLabel.attributedText = [[FAKIonIcons iosCloudOutlineIconWithSize:20]attributedString];
    self.colorSettingsIconLabel.textColor = [SRStylesheet mainColor];
}


-(void)refresh {
    NSAssert(NO, @"Subclasses need to overwrite this method");
}
@end
