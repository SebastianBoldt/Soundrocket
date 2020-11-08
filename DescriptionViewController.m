//
//  DescriptionNavigationViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 30.09.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import "DescriptionViewController.h"

@interface DescriptionViewController ()

@end

@implementation DescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emptyView.text = NSLocalizedString(@"No Description", nil);
    // Do any additional setup after loading the view.
    
    if (_descriptionText.length > 0) {
        self.emptyView.hidden = YES;
    } else {
        self.emptyView.hidden = NO;
    }
    self.descriptionTextView.text = _descriptionText;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSRange r  = {0,0};
    [self.descriptionTextView setSelectedRange:r];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)setDescriptionText:(NSString *)descriptionText {
    _descriptionText = descriptionText;
}
@end
