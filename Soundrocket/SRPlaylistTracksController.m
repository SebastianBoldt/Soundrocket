//
//  PlaylistTracksListTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//
#import <MBProgressHUD.h>
#import "SRPlaylistTracksController.h"
#import "Soundrocket-SWIFT.h"
#import "SoundrocketClient.h"
#import"UIImageView+AFNetworking.h"
#import <FAKIonIcons.h>
#import <SVProgressHUD.h>
#import "SRCreatePlaylistTableTableViewController.h"
#import "SRUserController.h"
#import "SRStylesheet.h"
#import "SRPlayer.h"
#import "SRHelper.h"
#import "SRAuthenticator.h"
#import "SRRequestModel.h"
#import "PlayerViewController.h"
#import "PlayerNavigationController.h"
#import "UIViewController+ToolbarPlayerAddition.h"  
#import "SRPlaylistsController.h"

@interface SRPlaylistTracksController() <SRRequestModelDelegate>
@end

@implementation SRPlaylistTracksController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:self.currentPlaylist.title];    
    [self setupEditButton];
        
    self.requestModel = [[SRRequestModel alloc]init];
    
    NSURL * url = [NSURL URLWithString:self.currentPlaylist.uri];
    NSString * playlistID =  url.pathComponents.lastObject;
    self.requestModel.inlineURLParameter = @{@"playlist_id":playlistID};
    self.requestModel.endpoint = SC_TRACKS_OF_PLAYLIST;
    [self.requestModel addDelegate:self];
    self.currentRequest = [self.requestModel load];
    [self showToolbarIfIamInsideThePlayerNavigationController];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController isKindOfClass:[PlayerNavigationController class]]) {
        self.navigationController.navigationBar.barTintColor = [SRStylesheet lightGrayColor];
        [self.navigationController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        self.navigationController.navigationBar.translucent = NO;
    }

}
-(void)setupEditButton{
    if ([[SRAuthenticator sharedAuthenticator].currentUser.id integerValue] == [self.currentPlaylist.user.id integerValue]) {
        UIBarButtonItem * editItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonItemPressed:)];
        self.navigationItem.rightBarButtonItem = editItem;
    }
}

-(void)editButtonItemPressed:(id)sender {
    UINavigationController * wrapper = (UINavigationController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"createPlaylist"];
    SRCreatePlaylistTableTableViewController * createController = (SRCreatePlaylistTableTableViewController*)[[wrapper viewControllers]objectAtIndex:0];
    createController.playlist = self.currentPlaylist;
    [self presentViewController:wrapper animated:YES completion:nil];
}


-(void)optionsButtonPressedForObject:(id)object inView:(UIView *)view {

    __weak __block __typeof(self) weakself = self;

    UIAlertController * alertController = [[UIAlertController alloc]init];
    alertController.title = @"Options";
    alertController.popoverPresentationController.sourceView = view;
    UIAlertAction * cancelAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){}];
    UIAlertAction * playnowAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"Play now", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        if ([object isKindOfClass:[Track class]] || [object isKindOfClass:[TrackRepost class]]) {
            [SRPlayer sharedPlayer].model = weakself.requestModel; // Wenn der Track selected wurde kann auch das aktuelle Model in den Player geladen werden
            [PlayerViewController sharedPlayerViewController].requestModel = weakself.requestModel;
            
            Track * track = (Track*)object;
            if (track.streamable) {
                NSInteger index = [weakself.requestModel.results indexOfObject:track];
                NSIndexPath * path = [NSIndexPath indexPathForItem:index inSection:0];
                [[SRPlayer sharedPlayer] setPlayingIndex:path];
                [[SRPlayer sharedPlayer]setCurrentTrack:[weakself.requestModel.results objectAtIndex:path.row]];
            } else {
                [SRHelper showNotStreamableNotification];
            }
        } else if ([object isKindOfClass:[Playlist class]] || [object isKindOfClass:[PlaylistRepost class]]){
            // Not implemented yet
            NSLog(@"Needs to be implemented");
        }
        
        
    }];
    
    UIAlertAction * showUserAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"Show User", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        Track * track = (Track*)object;
        SRUserController * userC = [weakself.storyboard instantiateViewControllerWithIdentifier:@"user"];
        userC.user_ID = track.user.id;
        [weakself.navigationController pushViewController:userC animated:YES];
    }];
    
    UIAlertAction * shareAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        Track * track = (Track*)object;
        NSString *string = [NSString stringWithFormat:@"%@ by %@ on #SoundCloud via #Soundrocket",track.title,track.user.username];
        NSURL *URL = [NSURL URLWithString:track.permalink_url];
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[string,URL]
                                          applicationActivities:nil];
        
        [self presentViewController:activityViewController
                           animated:YES
                         completion:^{
                             // ...
                         }];
    }];
    UIAlertAction * addToPlaylistAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add to Playlist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        Track * track = (Track*)object;
        SRPlaylistsController * playlistController = [weakself.storyboard instantiateViewControllerWithIdentifier:@"Playlist"];
        playlistController.track = track;
        [weakself.navigationController pushViewController:playlistController animated:YES];
    }];
    
    UIAlertAction * deleteObjectAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Track from Playlist", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

        
        /*************************************/
        
        [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
        Playlist * playlist = self.currentPlaylist;
        Track * trackToRemove = (Track*)object;
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Removing Track %@ from %@",trackToRemove.title,playlist.title]];
        
        [[SoundCloudAPI sharedApi]getTracksOfPlaylist:playlist forUserWithAccessToken:[SRAuthenticator sharedAuthenticator].authToken whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
         {
             // Konfiguration
             NSMutableArray * ids = [[NSMutableArray alloc]init];
             for (id trackDictionary in [responseObject objectForKey:@"tracks"]) {
                 Track * track = [[Track alloc]initWithDictionary:trackDictionary error:nil];
                 if ([trackToRemove.id integerValue] != [track.id integerValue]) {
                     [ids addObject:track.id];
                 }
             }
             
             
             NSMutableArray * idArray = [[NSMutableArray alloc]init];
             for (NSNumber *idNumber in ids) {
                 [idArray addObject:@{@"id":idNumber}];
             }
             
             
             NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
             [paramters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
             [paramters setObject:@{@"tracks":idArray} forKey:@"playlist"];
             
             [[SoundCloudAPI sharedApi]update:playlist withTrackIDs:idArray whenSuccess:^(NSURLSessionTask * task, id responseobject){
                 
                 [self.collectionView performBatchUpdates:^{
                     NSInteger index = [self.requestModel.results indexOfObject:object];
                     NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                     [self.requestModel.results removeObjectAtIndex:index];
                     [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                     [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Track removed",nil)];
                     [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                 } completion:nil];
                 
             } whenError:^(NSURLSessionTask* task,NSError*error){
                 // Fehlerbehandlung
                 [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                 [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             }];
         }
         
                                            whenError:^(NSURLSessionDataTask *task, NSError *error)
         {
             // Fehlerbehandlung
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
         }];
        
        // Array aus den IDs der Playlist
        // Neue ID reinschieben
        // Auf array mappen
        // tracks = [{:id=>22448500}, {:id=>21928809}, {:id=>21778201}]
        // Put :tracks => tracks
        
        /*************************************/
    }];
    
    [alertController addAction:playnowAction];
    [alertController addAction:showUserAction];
    [alertController addAction:shareAction];
    
    if ([self.currentPlaylist isKindOfClass:[Playlist class]]) {
        Playlist * playlist = (Playlist*)self.currentPlaylist;
        if ([playlist.user.id integerValue]== [[SRAuthenticator sharedAuthenticator].currentUser.id integerValue]) {
            [alertController addAction:deleteObjectAction];
        }
    }
    if ([object isKindOfClass:[Track class]] || [object isKindOfClass:[TrackRepost class]]) {
        [alertController addAction:addToPlaylistAction];
    }
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
