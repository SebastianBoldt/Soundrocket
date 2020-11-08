//
//  PlaylistTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "SRUserController.h"

#import "SRPlaylistsController.h"
#import "Playlist.h"
#import "UIImageView+AFNetworking.h"
#import "SRPlaylistTracksController.h"
#import "SRCreatePlaylistTableTableViewController.h"
#import "SRAuthenticator.h"
#import "PlayerViewController.h"
#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import <SVProgressHUD.h>
#import <MBProgressHUD.h>
#import <FAKIonIcons.h>
#import "SRHelper.h"
#import "SoundCloudAPI.h"

@interface SRPlaylistsController ()
@end

@implementation SRPlaylistsController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupNavigationbar];
    
    self.requestModel = [[SRRequestModel alloc]init];
    self.requestModel.endpoint = SC_PLAYLISTS_OF_USER;
    
    NSNumber * userID = self.user_id ? self.user_id : [SRAuthenticator sharedAuthenticator].currentUser.id;
    self.requestModel.inlineURLParameter = @{@"user_id":userID};
    [self.requestModel addDelegate:self];
    self.currentRequest = [self.requestModel load];

}

-(void)setupNavigationbar {
    
    [self.navigationItem setTitle:NSLocalizedString(@"Playlists",nil)];
    FAKIonIcons *cogIcon = [FAKIonIcons iosPlusEmptyIconWithSize:30];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(addPlaylistButtonPressed:)];
}


-(void)addPlaylistButtonPressed:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController * nav = [storyboard instantiateViewControllerWithIdentifier:@"createPlaylist"];
    SRCreatePlaylistTableTableViewController * controller = [[nav viewControllers]objectAtIndex:0];
    controller.delegate = self;
    [self presentViewController:nav animated:YES completion:nil];
}

// Gefrickel 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTracksOfPlaylist"]) {
        SRPlaylistTracksController * dc = (SRPlaylistTracksController*)segue.destinationViewController;
        id playListOrRepostedPlaylist = [self.requestModel.results objectAtIndex:[[[self.collectionView indexPathsForSelectedItems]firstObject]row]];
        if ([playListOrRepostedPlaylist class] == [Playlist class]) {
            Playlist * list = (Playlist*)playListOrRepostedPlaylist;
            list.tracks_uri = [list.uri stringByAppendingString:@"/tracks"];
            dc.currentPlaylist = list;
        }
    }
}

#pragma mark - CreatePlaylistControllerDelegate
-(void)controller:(SRCreatePlaylistTableTableViewController *)controller didCreatePlaylist:(Playlist *)playlist {
    [self refresh];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.track) {
        [self addTrackToPlaylistForIndexPath:indexPath];
    } else {
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}


-(void)addTrackToPlaylistForIndexPath:(NSIndexPath*)indexPath {
    
    [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
    Playlist * playlist = [self.requestModel.results objectAtIndex:indexPath.row];
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Adding Track %@ to %@",self.track.title,playlist.title]];

    [[SoundCloudAPI sharedApi]getTracksOfPlaylist:playlist forUserWithAccessToken:[SRAuthenticator sharedAuthenticator].authToken whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
    {
        // Konfiguration
        NSMutableArray * ids = [[NSMutableArray alloc]init];
        for (id trackDictionary in [responseObject objectForKey:@"tracks"]) {
            Track * track = [[Track alloc]initWithDictionary:trackDictionary error:nil];
            [ids addObject:track.id];
        }
        
        // Füge neue ID hinzu
        
        [ids addObject:self.track.id];
        
        NSMutableArray * idArray = [[NSMutableArray alloc]init];
        for (NSNumber *idNumber in ids) {
            [idArray addObject:@{@"id":idNumber}];
        }
        
        [[SoundCloudAPI sharedApi]update:playlist withTrackIDs:idArray whenSuccess:^(NSURLSessionTask * task, id responseobject){
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [[UIApplication sharedApplication]endIgnoringInteractionEvents];
            
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Added Track %@ to %@",self.track.title,playlist.title]];
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

}
@end
