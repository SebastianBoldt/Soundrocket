//
//  SRBaseCollectionViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 23.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRHelper.h"
#import "SRBaseObjects.h"
#import "SoundCloudAPI.h"
#import "SRStylesheet.h"
#import "SRBaseCollectionViewController.h"
#import "SRLoadingCollectionViewCell.h"
#import "SRUserCollectionViewCell.h"
#import "SRCommentCollectionViewCell.h"
#import "UIView+Animations.h"
#import "PlayerViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>
#import <TLYShyNavBar/TLYShyNavBarManager.h>
#import "SRPlaylistTracksController.h"
#import "SRUserController.h"
#import "SRUserHeaderView.h"
#import "SRAuthenticator.h" 
#import "SRPlaylistsController.h"
#import "UIViewController+ToolbarPlayerAddition.h"
#import "GetSoundRocketProCollectionReusableView.h"

@interface SRBaseCollectionViewController ()
@property (nonatomic,strong) SRRequestModel * loadedPlaylistModel;
@end

@implementation SRBaseCollectionViewController

#pragma mark - UIViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    
    // setup refreshcontrol
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SRTrackCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([SRTrackCollectionViewCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SRCommentCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([SRCommentCollectionViewCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SRUserCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([SRUserCollectionViewCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SRTrackCollectionViewCellImage" bundle:nil] forCellWithReuseIdentifier:@"SRTrackCollectionViewCellImage"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SRLoadingCollectionViewCell" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([SRLoadingCollectionViewCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SRUserHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([SRUserHeaderView class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GetSoundRocketProCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([GetSoundRocketProCollectionReusableView class])];
    
    [self showToolbarIfIamInsideThePlayerNavigationController];

}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

#pragma mark - UICollectionViewController

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Check if we need to load new items from the server
    if (indexPath.row == self.requestModel.results.count-2) {
        if (!self.requestModel.localStore) {
            self.currentRequest = [self.requestModel load];
        }
    }
    
    NSString * identifier = NSStringFromClass([SRTrackCollectionViewCell class]);;
    
    id currentObject = [self.requestModel.results  objectAtIndex:indexPath.row];
    if ([currentObject isKindOfClass:[User class]]) {
        SRUserCollectionViewCell *cell = (SRUserCollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SRUserCollectionViewCell class]) forIndexPath:indexPath];
        cell.user = currentObject;
        return  cell;

    }
    else if ([currentObject isKindOfClass:[Comment class]]){
        SRCommentCollectionViewCell * commentCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SRCommentCollectionViewCell class]) forIndexPath:indexPath];
        commentCell.backgroundColor = [UIColor whiteColor];
        commentCell.comment = currentObject;
        return commentCell;
    }
    else {
        SRTrackCollectionViewCell *cell = (SRTrackCollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.data = currentObject;
        cell.delegate = self;
        return  cell;
    }

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [cell pulseView];
    if (indexPath.row < [self.requestModel.results count]) {
        
        id objectAtIndexPath = [self.requestModel.results objectAtIndex:indexPath.row]; // Holen dir das Objekt aus dem Indexpath
        Track * track = nil;
        // Wenn es ein Track ist dann schiebe den Track oder Repost in den Player
        
        if ([objectAtIndexPath class] == [Track class]) {
            track = objectAtIndexPath;
            [SRPlayer sharedPlayer].model = self.requestModel; // Wenn der Track selected wurde kann auch das aktuelle Model in den Player geladen werden
            [PlayerViewController sharedPlayerViewController].requestModel = self.requestModel;
            
            Track * track = [self.requestModel.results objectAtIndex:indexPath.row];
            if (track.streamable) {
                [[SRPlayer sharedPlayer] setPlayingIndex:indexPath];
                [[SRPlayer sharedPlayer]setCurrentTrack:[self.requestModel.results objectAtIndex:indexPath.row]];
            } else {
                [SRHelper showNotStreamableNotification];
            }
        }
        
        else if ([objectAtIndexPath class] == [TrackRepost class]) {
            track = [[Track alloc]initWithTrackRespost:objectAtIndexPath];
            [SRPlayer sharedPlayer].model = self.requestModel; // Wenn der Track selected wurde kann auch das aktuelle Model in den Player geladen werden
            [PlayerViewController sharedPlayerViewController].requestModel = self.requestModel;
            
            Track * track = [self.requestModel.results objectAtIndex:indexPath.row];
            if (track.streamable) {
                [[SRPlayer sharedPlayer] setPlayingIndex:indexPath];
                [[SRPlayer sharedPlayer]setCurrentTrack:[self.requestModel.results objectAtIndex:indexPath.row]];
            } else {
                [SRHelper showNotStreamableNotification];
            }
        
        } else if ([objectAtIndexPath class] == [User class]) {
            SRUserController * userC = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
            User * user = [self.requestModel.results objectAtIndex:[[self.collectionView indexPathsForSelectedItems]firstObject].row];
            userC.user_ID = user.id;
            [self.navigationController pushViewController:userC animated:YES];
        
        } else if ([objectAtIndexPath class] == [Comment class]) {
            SRUserController * userC = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
            Comment * comment = [self.requestModel.results objectAtIndex:[[self.collectionView indexPathsForSelectedItems]firstObject].row];
            userC.user_ID = comment.user.id;
            [self.navigationController pushViewController:userC animated:YES];
        }
        
        
        // Wenn es sich um eine Playlist handelt dann öffne den Playlist Tableview
        else if ([objectAtIndexPath class] == [Playlist class]){
            [self performSegueWithIdentifier:@"showTracksOfPlaylist" sender:self];
        }
        
        else if ([objectAtIndexPath class] == [PlaylistRepost class]){
            [self performSegueWithIdentifier:@"showTracksOfPlaylist" sender:self];
        }
        
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.requestModel.results.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.gridStyle) {
            return CGSizeMake((self.collectionView.frame.size.width/3) -1.5, (self.collectionView.frame.size.width/3) -1.5);
        } else {
            return CGSizeMake((self.collectionView.frame.size.width/3)-1.5, 80);
        }
    } else {
        if (self.gridStyle) {
            return CGSizeMake((self.collectionView.frame.size.width/3) -1.5, (self.collectionView.frame.size.width/3) -1.5);
        } else {
            return CGSizeMake(self.collectionView.frame.size.width-4, 80);
        }
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    self.loadingFooter = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([SRLoadingCollectionViewCell class]) forIndexPath:indexPath];
    
    return self.loadingFooter;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width, 100);
}

#pragma mark - Private

-(void)optionsButtonPressedForObject:(id)object inView:(UIView *)view {
    
    UIAlertController * alertController = [[UIAlertController alloc]init];
    alertController.popoverPresentationController.sourceView = view;
    alertController.title = NSLocalizedString(@"ACTION_SHEET_TITLE", nil);
    UIAlertAction * cancelAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){}];
    UIAlertAction * playnowAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACTION_SHEET_PLAY_NOW", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        if ([object isKindOfClass:[Track class]] || [object isKindOfClass:[TrackRepost class]]) {
            [SRPlayer sharedPlayer].model = self.requestModel; // Wenn der Track selected wurde kann auch das aktuelle Model in den Player geladen werden
            [PlayerViewController sharedPlayerViewController].requestModel = self.requestModel;
            
            Track * track = (Track*)object;
            if (track.streamable) {
                NSInteger index = [self.requestModel.results indexOfObject:track];
                NSIndexPath * path = [NSIndexPath indexPathForItem:index inSection:0];
                [[SRPlayer sharedPlayer] setPlayingIndex:path];
                [[SRPlayer sharedPlayer]setCurrentTrack:[self.requestModel.results objectAtIndex:path.row]];
            } else {
                [SRHelper showNotStreamableNotification];
            }
        } else if ([object isKindOfClass:[Playlist class]] || [object isKindOfClass:[PlaylistRepost class]]){
            // Setting up the model
            Playlist * playlist = nil;
            if ([object isKindOfClass:[Playlist class]]) {
                playlist = object;
            } else {
                playlist = [[Playlist alloc]initWithPlayListRepost:object];
            }
            
            SRRequestModel * requestModel = [[SRRequestModel alloc]init];
            NSURL * url = [NSURL URLWithString:playlist.uri];
            NSString * playlistID =  url.pathComponents.lastObject;
            requestModel.inlineURLParameter = @{@"playlist_id":playlistID};

            self.loadedPlaylistModel = requestModel;
            [requestModel addDelegate:self];
            requestModel.endpoint = SC_TRACKS_OF_PLAYLIST;
            [requestModel load];
        }
        
        
    }];
    
    UIAlertAction * showUserAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACTION_SHEET_SHOW_USER", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        Track * track = (Track*)object;
        SRUserController * userC = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
        userC.user_ID = track.user.id;
        [self.navigationController pushViewController:userC animated:YES];
        
    }];
    
    UIAlertAction * shareAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACTION_SHEET_SHARE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        Track * track = (Track*)object;
        NSString *string = [NSString stringWithFormat:@"%@ by %@ on #SoundCloud via #Soundrocket",track.title,track.user.username];
        NSURL *URL = [NSURL URLWithString:track.permalink_url];
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[string,URL]
                                          applicationActivities:nil];
        activityViewController.popoverPresentationController.sourceView = view;
        [self presentViewController:activityViewController
                           animated:YES
                         completion:^{
                             // ...
                         }];
    }];
    UIAlertAction * addToPlaylistAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACTION_SHEET_ADD_TO_PLAYLIST", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        Track * track = (Track*)object;
        SRPlaylistsController * playlistController = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlist"];
        playlistController.track = track;
        [self.navigationController pushViewController:playlistController animated:YES];

    }];
    
    UIAlertAction * repostAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACTION_SHEET_REPOST_TRACK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self repostTrack:object];
    }];
    
    UIAlertAction * deleteObjectAction  = [UIAlertAction actionWithTitle:NSLocalizedString(@"ACTION_SHEET_DELETE_PLAYLIST", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting playlist",nil)];
        
        [[SoundCloudAPI sharedApi]deletePlaylist:object withAccessToken:[SRAuthenticator sharedAuthenticator].authToken whenSuccess:^(NSURLSessionTask * task, id responseObject){
            [self.collectionView performBatchUpdates:^{
                NSInteger index = [self.requestModel.results indexOfObject:object];
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [self.requestModel.results removeObjectAtIndex:index];
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Playlist removed",nil)];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            } completion:nil];
        } whenError:^(NSURLSessionTask * task, NSError * error){
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again",nil)];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
        
    }];
    
    
    
    
    [alertController addAction:playnowAction];
    [alertController addAction:showUserAction];
    [alertController addAction:shareAction];
    
    if ([object isKindOfClass:[Playlist class]]) {
        Playlist * playlist = (Playlist*)object;
        if ([playlist.user.id integerValue] == [[SRAuthenticator sharedAuthenticator].currentUser.id integerValue]) {
            [alertController addAction:deleteObjectAction];
        }
    }
    if ([object isKindOfClass:[Track class]] || [object isKindOfClass:[TrackRepost class]]) {
        [alertController addAction:repostAction];
        [alertController addAction:addToPlaylistAction];
    }
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)dealloc {
    [self.requestModel removeDelegate:self];
    [self.loadedPlaylistModel removeDelegate:self];
}

-(void)repostTrack:(Track*)object {
    [[SoundCloudAPI sharedApi]repostTrack:object whenSuccess:^(NSURLSessionTask * task, id responseObject){
        [SVProgressHUD showSuccessWithStatus:@"Reposted Track"];
    } whenError:^(NSURLSessionTask*task,id responseObject) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again",nil)];
    }];
}

#pragma mark Loading

/**
 *  Reinits every Pagination Parameter and then fetches Tracks
 */

- (IBAction)refresh {
    
    if (self.requestModel.localStore) {
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        [self.collectionView reloadData];
    } else {
        if (!self.requestModel.isLoading) {
            [self.requestModel refreshModel];
            [self.currentRequest cancel];
            self.requestModel.isRefreshing = YES;
            self.currentRequest = [self.requestModel load];
        }
    }
}

#pragma mark - RequestModel Delegate

-(void)requestModelDidStartLoading:(SRRequestModel *)requestModel {
    [self.loadingFooter.loadingIndicator startAnimating];
}

-(void)requestModelDidFinishLoading:(SRRequestModel *)requestModel {
        
    if (requestModel == self.loadedPlaylistModel) {
        [SRPlayer sharedPlayer].model = requestModel; // Wenn der Track selected wurde kann auch das aktuelle Model in den Player geladen werden
        [PlayerViewController sharedPlayerViewController].requestModel = requestModel;
        Track * track = requestModel.results.firstObject;
        if (track.streamable) {
            NSInteger index = [self.loadedPlaylistModel.results indexOfObject:track];
            NSIndexPath * path = [NSIndexPath indexPathForItem:index inSection:0];
            [[SRPlayer sharedPlayer] setPlayingIndex:path];
            [[SRPlayer sharedPlayer]setCurrentTrack:[self.loadedPlaylistModel.results objectAtIndex:path.row]];
        } else {
            [SRHelper showNotStreamableNotification];
        }
        
        [self.loadedPlaylistModel removeDelegate:self];
    }
    
    [self.collectionView reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    [self.loadingFooter.loadingIndicator stopAnimating];
}

-(void)requestModelDidFailWithLoading:(SRRequestModel *)requestModel withError:(NSError *)error {
    
    self.view.userInteractionEnabled = YES;
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    [self.loadingFooter.loadingIndicator stopAnimating];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTracksOfPlaylist"]) {
        SRPlaylistTracksController * dc = (SRPlaylistTracksController*)segue.destinationViewController;
        id playListOrRepostedPlaylist = [self.requestModel.results objectAtIndex:[[[self.collectionView indexPathsForSelectedItems]firstObject]row]];
        if ([playListOrRepostedPlaylist class] == [Playlist class]) {
            dc.currentPlaylist = playListOrRepostedPlaylist;
        } else if ([playListOrRepostedPlaylist class] == [PlaylistRepost class]) {
            dc.currentPlaylist = [[Playlist alloc]initWithPlayListRepost:playListOrRepostedPlaylist];
        }
    }
}

#pragma mark - BasictracktableViewCellDelegate
-(void)userButtonPressedWithUser:(User*)user{
    SRUserController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"user"];
    controller.user_ID = user.id;
    [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
