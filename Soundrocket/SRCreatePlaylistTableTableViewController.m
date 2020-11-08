//
//  CreatePlaylistTableTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 03.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "SRCreatePlaylistTableTableViewController.h"
#import <MBProgressHUD.h>
#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import <FAKFoundationIcons.h>
#import <SVProgressHUD.h>
#import "SRHelper.h"
#import "SRAuthenticator.h"
#import "SoundCloudAPI.h"

@interface SRCreatePlaylistTableTableViewController ()
@end

@implementation SRCreatePlaylistTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.privatelabel.text = NSLocalizedString(@"public", nil);

    if (self.playlist) {
        self.descriptionLabel.text =  NSLocalizedString(@"Update Playlist", nil);
    } else {
        self.descriptionLabel.text =  NSLocalizedString(@"Create Playlist", nil);
    }
    
    self.iconLabel.attributedText = [[FAKIonIcons iosAlbumsOutlineIconWithSize:100]attributedString];

    if (self.playlist) {
        self.nameOfPlaylistTextField.text = self.playlist.title;
        if ([self.playlist.sharing isEqualToString:@"public"]) {
            [self.sharingSwitch setOn:YES];
        } else {
            [self.sharingSwitch setOn:NO];
        }
        [self.createPlaylistButton setTitle:NSLocalizedString(@"Update Playlist", nil).uppercaseString forState:UIControlStateNormal];
    } else {
        [self.createPlaylistButton setTitle:NSLocalizedString(@"Create Playlist", nil).uppercaseString forState:UIControlStateNormal];
    }
    
    UIBarButtonItem * cancelIcon = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = cancelIcon;
}

-(void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Creates a completly new Playlist
 *
 *  @param name   name of Playlist
 *  @param public public or private ?
 */
-(void)createPlaylistWithName:(NSString*)name  andSharingoption:(BOOL)public{

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.nameOfPlaylistTextField resignFirstResponder];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Creating Playlist", nil)];
    
    __weak __block __typeof(self) weakself = self;
    
    [[SoundCloudAPI sharedApi]createPlaylistWithName:name public:public whenSuccess:^(NSURLSessionTask * task, id responseObject){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [weakself dismissViewControllerAnimated:YES completion:^(){
            [weakself.delegate controller:weakself didCreatePlaylist:responseObject];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Created Playlist", nil)];
            
        }];
    } whenError:^(NSURLSessionTask* task, NSError * error){
        // Fehlerbehandlung
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [SRHelper showGeneralError];
    }];

}
/**
 *  Updates a Playlist
 *
 *  @param name   name of Playlist
 *  @param public public or private
 */
-(void)updatePlaylistWithName:(NSString*)name  andSharingoption:(BOOL)public{
    __weak __block __typeof(self) weakself = self;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [self.nameOfPlaylistTextField resignFirstResponder];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Updating playlist", nil)];
    
    [[SoundCloudAPI sharedApi]updatePlaylist:self.playlist withName:name public:public whenSuccess:^(NSURLSessionTask * task, id responseObject){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [weakself dismissViewControllerAnimated:YES completion:^(){
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Updated Playlist",nil)];
        }];
        
    } whenError:^(NSURLSessionTask* task, NSError * error){
        // Fehlerbehandlung
        [SRHelper showGeneralError];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (IBAction)createPlaylistButtonPressed:(id)sender {
    if (self.playlist) {
        [self updatePlaylistWithName:self.nameOfPlaylistTextField.text andSharingoption:self.sharingSwitch.on];
    } else {
        [self createPlaylistWithName:self.nameOfPlaylistTextField.text andSharingoption:self.sharingSwitch.on];
    }
}
@end
