//
//  SearchTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKIonIcons.h>
#import "SRSearchTableViewController.h"
#import "SoundrocketClient.h"
#import "Track.h"
#import "Playlist.h"
#import "User.h"
#import "SRUserController.h"
#import "SRPlaylistTracksController.h"
#import "Soundrocket-SWIFT.h"
#import"UIImageView+AFNetworking.h"
#import "SRStylesheet.h"
#import "SRPlayer.h"
#import "SRHelper.h"    
#import "SRAuthenticator.h" 
#import "SRRequestModel.h"
#import "PlayerViewController.h"

@interface SRSearchTableViewController () <UISearchBarDelegate,SRRequestModelDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) IBOutlet UISearchBar * searchBar;

@property (nonatomic,strong) NSMutableArray * tasks;

@property (nonatomic,strong) SRRequestModel * tracksModel;
@property (nonatomic,strong) SRRequestModel * userModel;
@property (nonatomic,strong) SRRequestModel * playlistsModel;

@property (nonatomic,strong) NSArray * models;

@end

@implementation SRSearchTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.searchBar.userInteractionEnabled = YES;
    self.tasks = [[NSMutableArray alloc]init];
    self.searchBar.delegate = self;
    [self setupModels];
    
    [self.navigationItem setTitle:NSLocalizedString(@"Search",nil)];
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    // register 3 Cells
    
    self.searchBar.scopeButtonTitles = @[NSLocalizedString(@"Tracks",nil),NSLocalizedString(@"Users", nil),NSLocalizedString(@"Playlists", nil)];
    self.searchBar.delegate = self;

    NSMutableAttributedString * searchIcon = [[[FAKIonIcons iosSearchIconWithSize:180]attributedString]mutableCopy];
    [searchIcon addAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]} range:NSMakeRange(0, 1)];
    self.searchIconImageView.attributedText= searchIcon;
    
    
    self.searchHintText.text = NSLocalizedString(@"SEARCH_HINT", nil);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.currentRequest cancel];
    if (searchText) {
        if ([searchText length] >0) {
            SRRequestModel * activeModel = [self requestModel];
            activeModel.additionalParameters =   @{@"q":self.searchBar.text};
            [self refresh];
            [self.collectionView reloadData];
        } else {
            [self.collectionView reloadData];
        }
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self.refreshControl endRefreshing];
    [self.currentRequest cancel];
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    [self.collectionView reloadData];
}

-(void)setupModels {
    self.models = [[NSMutableArray alloc]init];
    // Tracks Model
    self.tracksModel = [[SRRequestModel alloc]init];
    self.tracksModel.endpoint = SC_SEARCH_TRACKS;
    [self.tracksModel addDelegate:self];
    
    // PlaylistModel
    self.playlistsModel = [[SRRequestModel alloc]init];
    self.playlistsModel.endpoint = SC_SEARCH_PLAYLISTS;
    [self.playlistsModel addDelegate:self];
    
    // LikesModel
    self.userModel = [[SRRequestModel alloc]init];
    self.userModel.endpoint = SC_SEARCH_USERS;
    [self.userModel addDelegate:self];

    self.models = @[self.tracksModel,self.userModel,self.playlistsModel];

}

#pragma mark - SRRequestModel & Request Handling
-(void)requestModelDidStartLoading:(SRRequestModel *)requestModel {
    [super requestModelDidStartLoading:requestModel];
}
-(void)requestModelDidFinishLoading:(SRRequestModel *)requestModel {
    self.searchHintView.hidden = YES;
    [super requestModelDidFinishLoading:requestModel];
    if (requestModel == [self requestModel]) {
        [self.collectionView reloadData];
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    }
}
-(void)requestModelDidFailWithLoading:(SRRequestModel *)requestModel withError:(NSError *)error {
    // Show error screen
}

#pragma mark - Table view data source

-(SRRequestModel *)requestModel {
    return (SRRequestModel*)[self.models objectAtIndex:self.searchBar.selectedScopeButtonIndex];

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

-(void)dealloc {
    [self.userModel removeDelegate:self];
    [self.tracksModel removeDelegate:self];
    [self.playlistsModel removeDelegate:self];
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.gridStyle) {
            return CGSizeMake((self.collectionView.frame.size.width/3) -1.5, (self.collectionView.frame.size.width/3) -1.5);
        } else {
            if ((self.requestModel == self.userModel)){
                return CGSizeMake((self.collectionView.frame.size.width/3)-1.5, (self.collectionView.frame.size.width/3)-1.5);
            }
            return CGSizeMake((self.collectionView.frame.size.width/3)-1.5, 80);
        }
    } else {
        
        if ((self.requestModel == self.userModel)){
            return CGSizeMake((self.collectionView.frame.size.width/3)-1.5, (self.collectionView.frame.size.width/3)-1.5);
        }
        return CGSizeMake(self.collectionView.frame.size.width, 80);
    }
}
@end
