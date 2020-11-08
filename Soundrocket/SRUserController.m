//
//  UserTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//


#import "SRAuthenticator.h"
#import "SRRequestModel.h"
#import "PlayerViewController.h"
#import "PlayerNavigationController.h"
#import "DescriptionViewController.h"
#import "SRUserHeaderView.h"
#import "SRStylesheet.h"
#import "GMDCircleLoader.h"
#import "URLParser.h"
#import "SRPlayer.h"
#import "SRHelper.h"
#import "SRUserController.h"
#import "SoundrocketClient.h"
#import "Soundrocket-SWIFT.h"
#import "SRBaseObjects.h"
#import "UIImageView+AFNetworking.h"
#import "SRPlaylistTracksController.h"
#import "SRUserController.h"
#import "UIViewController+ToolbarPlayerAddition.h"
#import "CustomModalTransitionDelegate.h"

#import <JTSImageViewController.h>
#import <FAKFontAwesome.h>
#import <FAKIonIcons.h>
#import <MBProgressHUD.h>
#import <SVProgressHUD.h>



@interface SRUserController () <SRRequestModelDelegate,SRUSerHeaderDelegate,FFXScrollableSegmentedControlDelegate>

// Pagination

@property (nonatomic,strong) NSMutableArray * tasks;

@property (nonatomic,strong)SRRequestModel * tracksModel;
@property (nonatomic,strong)SRRequestModel * playlistsModel;
@property (nonatomic,strong)SRRequestModel * likesModel;
@property (nonatomic,strong)SRRequestModel * followersModel;
@property (nonatomic,strong)SRRequestModel * followingModel;


@property (nonatomic,strong)NSArray * models;
@property (nonatomic,assign) NSInteger selectedIndex;

@property (nonatomic,strong) User * loadedUser;

@property (nonatomic,strong) CustomModalTransitionDelegate * modalInfoDelegate;
@end

@implementation SRUserController

#pragma mark -  UIViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.selectedIndex = 0;
    [self.navigationItem setTitle:NSLocalizedString(@"User", nil)];
    self.tasks = [[NSMutableArray alloc]init];
    
    if (!self.user_ID) {
        self.user_ID = [[[SRAuthenticator sharedAuthenticator]currentUser]id];
    }
    
    if ([[[SRAuthenticator sharedAuthenticator]currentUser].id integerValue] == [self.user_ID integerValue]) {
        FAKIonIcons *cogIcon = [FAKIonIcons iosMoreOutlineIconWithSize:30];
        [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
        cogIcon.iconFontSize = 30;
        UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
        UIBarButtonItem * settingsButton =
        [[UIBarButtonItem alloc] initWithImage:leftImage
                           landscapeImagePhone:leftLandscapeImage
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(showPreferences)];
        
        
        FAKIonIcons *logoutIcon = [FAKIonIcons logOutIconWithSize:25];
        [logoutIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *rightImage = [logoutIcon imageWithSize:CGSizeMake(25, 25)];
        logoutIcon.iconFontSize = 25;
        UIImage *rightLandscpae = [logoutIcon imageWithSize:CGSizeMake(25, 25)];
        UIBarButtonItem * logoutButton =
        [[UIBarButtonItem alloc] initWithImage:rightImage
                           landscapeImagePhone:rightLandscpae
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(logout)];
        
        self.navigationItem.rightBarButtonItems = @[settingsButton,logoutButton];
    }
    
    [self showToolbarIfIamInsideThePlayerNavigationController];
}


-(void)setUser_ID:(NSNumber*)user_ID {
    _user_ID = user_ID;
    [self setupUserInfo];
}

-(void)setupUserInfo {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
    __weak __block __typeof(self) weakself = self;
    [self.headerView.userLoadingIndicator startAnimating];

    NSInteger idOfUser = [self.user_ID integerValue];

    
    [[SoundCloudAPI sharedApi]getUserForID:idOfUser whenSuccess:^(NSURLSessionTask * task, id responseObject){
        User * user = [[User alloc]initWithDictionary:responseObject error:nil];
        _loadedUser = user;
        weakself.headerView.user = user;
        [weakself.navigationItem setTitle:user.username];
        [weakself setupModels];
        [weakself checkFollow];
        [weakself.headerView.segmentedSearchControl setSelectedSegmentIndex:self.selectedIndex];
        [self.headerView.userLoadingIndicator stopAnimating];

    } whenError:^(NSURLSessionTask * task, NSError * error){
        [self.headerView.userLoadingIndicator stopAnimating];
    }];
}


-(SRRequestModel *)requestModel {
    return [self activeModel];
}

-(SRRequestModel*)activeModel {
    return (SRRequestModel*)[self.models objectAtIndex:self.selectedIndex];
}


-(void)logout {
    [[SRAuthenticator sharedAuthenticator]logout];
}
-(void)showPreferences {
    [self performSegueWithIdentifier:@"showPreferences" sender:nil];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [SRStylesheet mainColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)setupModels {
    self.models = [[NSMutableArray alloc]init];
    // Tracks Model
    self.tracksModel =      [[SRRequestModel alloc]init];
    self.playlistsModel =   [[SRRequestModel alloc]init];
    self.likesModel =       [[SRRequestModel alloc]init];
    self.followersModel =   [[SRRequestModel alloc]init];
    self.followingModel =   [[SRRequestModel alloc]init];

    self.models = @[self.tracksModel,self.playlistsModel,self.likesModel,self.followersModel,self.followingModel];


    for (SRRequestModel * model in self.models) {
        model.inlineURLParameter = @{@"user_id":self.user_ID};
    }

    self.tracksModel.endpoint = SC_TRACKS_OF_USER;
    [self.tracksModel addDelegate:self];
    
    // PlaylistModel
    self.playlistsModel.endpoint = SC_PLAYLISTS_OF_USER;
    [self.playlistsModel addDelegate:self];
    
    // LikesModel
    self.likesModel.endpoint = SC_LIKES_OF_USER;
    [self.likesModel addDelegate:self];
    
    // Follower
    self.followersModel.endpoint = SC_FOLLOWERS_OF_USER;
    [self.followersModel addDelegate:self];
    
    //Followings
    self.followingModel.endpoint = SC_FOLLOWINGS_OF_USER;
    [self.followingModel addDelegate:self];
    
    
    // Load Data for all Models
    for (SRRequestModel * model in self.models) {
        [model load];
    }
}

-(void)requestModelDidFinishLoading:(SRRequestModel *)requestModel {
    if (requestModel == [self activeModel]) {
        [self.collectionView reloadData];
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
        [self.loadingFooter.loadingIndicator stopAnimating];
    }
}


-(void)dealloc {
    [self.playlistsModel removeDelegate:self];
    [self.tracksModel removeDelegate:self];
    [self.followersModel removeDelegate:self];
    [self.followingModel removeDelegate:self];
    [self.likesModel removeDelegate:self];
}


#pragma mark - Header 

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    self.headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([SRUserHeaderView class]) forIndexPath:indexPath];
    self.headerView.segmentedSearchControl.delegate = self;
    if (self.loadedUser) {
        self.headerView.user = self.loadedUser;
    }
    self.headerView.delegate = self;
    return self.headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.collectionView.frame.size.width, 219);
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.gridStyle) {
            return CGSizeMake((self.collectionView.frame.size.width/3) -1.5, (self.collectionView.frame.size.width/3) -1.5);
        } else {
            if ((self.requestModel == self.followingModel) || (self.requestModel == self.followersModel)){
                return CGSizeMake((self.collectionView.frame.size.width/3)-1.5, (self.collectionView.frame.size.width/3)-1.5);
            }
            return CGSizeMake((self.collectionView.frame.size.width/3)-1.5, 80);
        }
    } else {
        
        if ((self.requestModel == self.followingModel) || (self.requestModel == self.followersModel)){
            return CGSizeMake((self.collectionView.frame.size.width/3)-1.5, (self.collectionView.frame.size.width/3)-1.5);
        }
        return CGSizeMake(self.collectionView.frame.size.width, 80);
    }
}

#pragma mark - SRUserHeaderDelegate


-(void)userHeaderImageTapped {
    
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && ([self.navigationController class] == [PlayerNavigationController class])) {
        // Do nothing
    } else {
        __weak __block __typeof(self) weakself = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            self.headerView.userLoadingIndicator.hidden = NO;
            
            // Create image info
            JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
            imageInfo.image = self.headerView.userImageView.image;
            imageInfo.referenceRect = self.headerView.userImageView.frame;
            imageInfo.referenceView = self.headerView.userImageView;
            
            // Setup view controller
            JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                   initWithImageInfo:imageInfo
                                                   mode:JTSImageViewControllerMode_Image
                                                   backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                weakself.headerView.userLoadingIndicator.hidden = YES;
                [imageViewer showFromViewController:weakself transition:JTSImageViewControllerTransition_FromOffscreen];
            });
        });
        
    }

}

-(void)userHeaderFollowButtonPressed {
    
    __weak __block __typeof(self) weakself = self;

    NSString * token = nil;
    if ([SRAuthenticator sharedAuthenticator].authToken) {
        token = [SRAuthenticator sharedAuthenticator].authToken;
        
    } else {
        token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    }
    
    [self.headerView.followButton setEnabled:NO];

    [[SoundCloudAPI sharedApi]userWithAccessToken:token followUser:self.loadedUser whenSuccess:^(NSURLSessionTask * task, id responseObject){
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:NSLocalizedString(@"You are now following %@",nil),self.loadedUser.username]];
        [weakself.headerView setupUnfollowButton];
        [weakself.headerView.followButton setEnabled:YES];
    } whenError:^(NSURLSessionTask * task, NSError * error){
        [SRHelper showGeneralError];
        [self.headerView.followButton setEnabled:YES];
    }];
}

-(void)userHeaderUnFollowButtonPressed {

    __weak __block __typeof(self) weakself = self;
    [self.headerView.followButton setEnabled:NO];

    [[SoundCloudAPI sharedApi]userWithAccessToken:[SRAuthenticator sharedAuthenticator].authToken unfollowUser:self.loadedUser whenSuccess:^(NSURLSessionTask * task, id responseObject){
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"You unfollowed %@",nil),weakself.loadedUser.username]];
        [weakself.headerView setupFollowButton];
        [weakself.headerView.followButton setEnabled:YES];
    } whenError:^(NSURLSessionTask * task, NSError * error){
        [weakself.headerView.followButton setEnabled:YES];
    }];
}

-(void)userHeaderInfoButtonPressed {
    UINavigationController * navController = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoNavViewController"];
    
    if ([[navController viewControllers][0] isKindOfClass:[DescriptionViewController class]]) {
        DescriptionViewController * dvc = (DescriptionViewController*)[navController viewControllers][0];
        dvc.descriptionText = self.loadedUser.descriptionText;;
        if(!self.modalInfoDelegate){
            self.modalInfoDelegate = [[CustomModalTransitionDelegate alloc]init];
        }
        navController.modalPresentationStyle = UIModalPresentationCustom;
        navController.transitioningDelegate = self.modalInfoDelegate;
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}


-(void)checkFollow {

    // Check Follow Status
    __weak __block __typeof(self) weakself = self;

    [[SoundCloudAPI sharedApi]checkIfUserWithAccessToken:[SRAuthenticator sharedAuthenticator].authToken isFollowingUser:self.loadedUser whenSuccess:^(NSURLSessionTask * task, id responseObject){
    
    } whenError:^(NSURLSessionTask* task,NSError * error){
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (response) {
            int statuscode = (int)response.statusCode;
            if (statuscode == 404) {
                [weakself.headerView setupFollowButton];
            } else {
                [weakself.headerView setupUnfollowButton];
            }
        }
    }];
}

-(void)scrollableSegmentedControl:(FFXScrollableSegmentedControl *)control didSelectIndex:(NSInteger)index {
    [self.refreshControl endRefreshing];
    [self.currentRequest cancel];
    self.selectedIndex = index;
    [self.collectionView reloadData];
}

@end
