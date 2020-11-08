//
//  ClientIDTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 20.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import "ClientIDTableViewController.h"
#import "SRPlayer.h"
#import <SVProgressHUD.h>
#import "SRStylesheet.h"
#import <SupportKit/SupportKit.h>

@interface ClientIDTableViewController ()

@end

@implementation ClientIDTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.clientTextField setText:[[SRPlayer sharedPlayer]loadStreamingID]];
    [self setupTweetLabel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"help",nil) style:UIBarButtonItemStylePlain target:self action:@selector(showSupport:)];
    [self.descriptionTextView setText:NSLocalizedString(@"CLIENT_ID_DESCRIPTION", nil)];
    [self.pasteLabel setText:NSLocalizedString(@"register your app", nil)];
    [self.yourAppsLabel setText:NSLocalizedString(@"click your apps", nil)];
    [self.saveClientIDButton setTitle:NSLocalizedString(@"Save client ID", nil) forState:UIControlStateNormal];

}

-(void)showSupport:(id)sender {
    [SupportKit show];
}
-(IBAction)saveClientIDPressed:(id)sender {
    [[SRPlayer sharedPlayer]saveStreamingID:self.clientTextField.text];
    [SVProgressHUD showSuccessWithStatus:@"Success"];
}

-(void)setupTweetLabel {
    STTweetLabel* label = (STTweetLabel*)self.linkLabel;
    label.userInteractionEnabled = YES;
    NSDictionary* textAttributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:13.0],
                                     NSForegroundColorAttributeName:[UIColor grayColor]
                                     };
    [self.linkLabel setAttributes:textAttributes];
    NSDictionary* linkAttributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:13.0],
                                     NSForegroundColorAttributeName:[SRStylesheet mainColor]
                                     };
    [label setAttributes:linkAttributes hotWord:STTweetLink];
    [label setAttributes:linkAttributes hotWord:STTweetHashtag];
    [label setAttributes:linkAttributes hotWord:STTweetHandle];
    
    [label setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        
        switch (hotWord){
            case STTweetLink:
                [self handleURL:string];
                break;
            default: break;
        }
    }];
    
    [self.linkLabel setText:@"1. https://developers.soundcloud.com"];
    
}

-(void)handleURL:(NSString*)string {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:string]];
}
@end
