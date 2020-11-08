//
//  SRTabbarViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 23.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "PlayerViewController.h"
#import "SRTabbarViewController.h"
#import "SRStylesheet.h"
#import "SRPlayer.h"
#import "SRAuthenticator.h"
#import "SRPlaylistsController.h"
#import "SRUserController.h"
#import "SRPlaylistTracksController.h"
#import "SRPeopleLikedTrackViewController.h"

@interface SRTabbarViewController () <SRPlayerDelegate, PlayerViewControllerDelegate,UITabBarControllerDelegate>

@property (nonatomic,strong) UINavigationController * playerWrappingController;

@property (nonatomic,strong) UIPopoverController * popoverController;

@property (nonatomic,strong) IBOutlet NSLayoutConstraint * bottomConstraint;


@end

@implementation SRTabbarViewController

#pragma mark - NSObject

-(void)dealloc {
    [[SRPlayer sharedPlayer]removeDelegate:self];
}

#pragma mark - UIViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMiniPlayer];
    [[SRPlayer sharedPlayer]addDelegate:self];
    [self setupPlayer];
    
    self.tabBar.layer.zPosition = 2000;
    
    self.delegate = self;
    
    [[self.viewControllers objectAtIndex:0] setTitle: NSLocalizedString(@"TABBAR_ACTIVITIES_TITLE", nil)];
    [[self.viewControllers objectAtIndex:1] setTitle: NSLocalizedString(@"TABBAR_PLAYLISTS_TITLE", nil)];
    [[self.viewControllers objectAtIndex:2] setTitle: NSLocalizedString(@"TABBAR_SEARCH_TITLE", nil)];
    [[self.viewControllers objectAtIndex:3] setTitle: NSLocalizedString(@"TABBAR_HISTORY_TITLE", nil)];
    [[self.viewControllers objectAtIndex:4] setTitle: NSLocalizedString(@"TABBAR_MY_PROFILE_TITLE", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    __block BOOL isVisible;
    PlayerViewController * viewController = [PlayerViewController sharedPlayerViewController];
    if (viewController.isViewLoaded && viewController.view.window && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        isVisible = YES;
    } else isVisible = NO;
    
    [self.popoverController dismissPopoverAnimated:YES];
    __weak __block SRTabbarViewController * weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if (isVisible ) {
             UIPopoverPresentationController *presentationController =
             [self.playerWrappingController popoverPresentationController];
             presentationController.permittedArrowDirections =
             UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
             presentationController.sourceView = self.miniPlayer;
             presentationController.sourceRect = self.miniPlayer.frame;
             [weakSelf.popoverController presentPopoverFromRect:self.miniPlayer.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
         }

     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


#pragma mark - Private 

-(void)setupMiniPlayer {
    self.miniPlayer = [[[NSBundle mainBundle] loadNibNamed:@"MiniPlayer" owner:self options:nil] objectAtIndex:0];
    self.miniPlayer.frame = CGRectMake(0,self.tabBar.frame.origin.y-50, self.tabBar.frame.size.width, 50);
    self.miniPlayer.translatesAutoresizingMaskIntoConstraints = NO;
    self.miniPlayer.layer.zPosition = 1000;
    self.miniPlayer.userInteractionEnabled = NO;
    
    // Adds Tap gesture to Miniplayer
    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(miniPlayerPressed:)];
    [self.miniPlayer addGestureRecognizer:gestureRecognizer];
    
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.miniPlayer addGestureRecognizer:swipeUpGestureRecognizer];
    [self.miniPlayer addGestureRecognizer:swipeLeftGestureRecognizer];
    [self.miniPlayer addGestureRecognizer:swipeRightGestureRecognizer];

    [self.view addSubview:self.miniPlayer];
    
    
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.miniPlayer
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.tabBar
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:50.0];
    NSDictionary * views = @{@"tabbar":self.tabBar,@"miniplayer":self.miniPlayer};
    NSArray<NSLayoutConstraint*>* hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[miniplayer]|" options:0 metrics:nil views:views];
    
    
    NSArray<NSLayoutConstraint*>* heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[miniplayer(==50)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:views];
    [self.view addConstraint:self.bottomConstraint];
    [self.view addConstraints:hConstraints];
    [self.view addConstraints:heightConstraints];
}

-(void)setupPlayer {
    // Create Navigation Controller and embed Playerviewcontroller inside
    self.playerWrappingController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerNavigationController"];
    self.playerWrappingController.preferredContentSize = CGSizeMake(500,700);
    [self.playerWrappingController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
    self.playerWrappingController.navigationBar.shadowImage = [UIImage new];
    self.playerWrappingController.navigationBar.translucent = YES;
    
    PlayerViewController * player =  [PlayerViewController sharedPlayerViewController];
    player.delegate = self;
    [player view]; // Create the view before being dsiplayed
    [self.playerWrappingController setViewControllers:@[player]];
    
}

#pragma mark - Miniplayer Gesture Recognizer Handling

-(void)handleSwipeUp:(id)sender {
    [self miniPlayerPressed:nil];
}

-(void)handleSwipeRight:(id)sender {
    [[SRPlayer sharedPlayer]playLastTrack];
}

-(void)handleSwipeLeft:(id)sender {
    [[SRPlayer sharedPlayer]playNextTrack];
}


-(void)miniPlayerPressed:(id)sender {
    
    if (!self.playerWrappingController) {
        
        [self setupPlayer];
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UIPopoverController * popoverController = [[UIPopoverController alloc]initWithContentViewController:self.playerWrappingController];
        self.popoverController = popoverController;
        popoverController.backgroundColor = [SRStylesheet lightGrayColor];
        [popoverController presentPopoverFromRect:self.miniPlayer.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        [self presentViewController:self.playerWrappingController animated:YES completion:nil];
    }
}

#pragma mark - SRPlayerDelegate

-(void)player:(SRPlayer *)player willStartWithTrack:(Track *)track fromIndexPath:(NSIndexPath *)path {
    self.bottomConstraint.constant = 0.0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                         self.miniPlayer.userInteractionEnabled = YES;
                     }];
}

-(void)player:(SRPlayer *)player willPlayTrack:(Track *)track {
    
}

-(void)player:(SRPlayer *)player willPauseTrack:(Track *)track {
    
}

-(void)player:(SRPlayer *)player isReadyToPlayTrack:(Track *)track {
    
}

-(void)player:(SRPlayer*)player didFinishWithTrack:(Track*)track {
    
}


#pragma mark - PlayerViewController Delegate

-(void)playerViewControllerDidDismissForProPlan:(PlayerViewController *)viewController {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UITableViewController * proController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProPlan"];
        [((UINavigationController*)self.selectedViewController) pushViewController:proController animated:YES];
    }
}

-(void)playerViewControllerDidDismissWithPlaylist:(Playlist *)playlist {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        SRPlaylistTracksController * playlistController =  [self.storyboard instantiateViewControllerWithIdentifier:@"playlistTracks"];
        playlistController.currentPlaylist = playlist;
        [((UINavigationController*)self.selectedViewController) pushViewController:playlistController animated:YES];
    }
}

-(void)playerViewControllerDidDismissWithTrackForFavoriters:(Track *)track {

    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        SRPeopleLikedTrackViewController * peopleLikedController =  [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleLikedTrackTableViewController"];
        peopleLikedController.trackID = [track.id integerValue];
        [((UINavigationController*)self.selectedViewController) pushViewController:peopleLikedController animated:YES];
    }
}

-(void)playerViewControllerDidDismissWithUser:(User *)user {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        SRUserController * userC = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
        userC.user_ID = user.id;
        [((UINavigationController*)self.selectedViewController) pushViewController:userC animated:YES];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([self.viewControllers indexOfObject:viewController] == 3) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];
        if (isEnabled) {
            return YES;
        } else {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"This Feature is just available for Soundrocket PRO User", nil) message:NSLocalizedString(@"PRO_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * showAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Tell me more", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
                [self playerViewControllerDidDismissForProPlan:nil];
            }];
            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
            }];
            [alertController addAction:showAction];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return NO;
        }

    } else {
        return YES;
    }
}


@end
