/* This Controller manages all Activities(Stream including) - Shares, Reposts,Playlist, Reposts*/

// Librarys
#import <FAKFontAwesome.h>
#import <FAKIonIcons.h>
#import <FAKFoundationIcons.h>
#import <MBProgressHUD.h>

// Custom Headers

#import "SRStreamViewController.h"
#import "SoundrocketClient.h"
#import "UIImageView+AFNetworking.h"
#import "Soundrocket-SWIFT.h"
#import "SRBaseObjects.h"
#import "URLParser.h"
#import "SRUserController.h"
#import "SRStylesheet.h"
#import "SRPlayer.h"    
#import "SRHelper.h"
#import "SRSearchTableViewController.h"
#import "SRAuthenticator.h"
#import "PlayerViewController.h"
#import "SoundCloudAPI.h"
#import "SRTrackCollectionViewCell.h"
#import "UIView+Animations.h"
#import "GetSoundRocketProCollectionReusableView.h"

/**
 *  Private Interface
 */
@interface SRStreamViewController () <SRRequestModelDelegate>

@property (nonatomic,strong) UIImage * leftNavBarGridButton;
@property (nonatomic,strong) UIImage * leftNavBarGridLandscapeButton;
@property (nonatomic,strong) UIImage * leftNavBarListButton;
@property (nonatomic,strong) UIImage * leftNavBarListLandscapeButton;

@end

@implementation SRStreamViewController

/**
 *  Got called if view is loaded
 */

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationbar];

    self.requestModel = [[SRRequestModel alloc]init];
    self.requestModel.endpoint = SC_ACTIVITIES_ENDPOINT;
    [self.requestModel addDelegate:self];
    self.currentRequest = [self.requestModel load];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(proPlanBought:) name:@"ProPurchased" object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ProPurchased" object:nil];
}

-(void)proPlanBought:(id)sender {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

-(void)setupNavigationbar {
    
    self.navigationItem.title = @"Stream";
    FAKIonIcons *cogIcon = [FAKIonIcons iosSearchIconWithSize:25];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage * rightImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    UIImage *rightLandscapeImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    UIBarButtonItem *searchButton =
    [[UIBarButtonItem alloc] initWithImage:rightImage
                       landscapeImagePhone:rightLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(searchButtonTapped:)];
    
    self.navigationItem.rightBarButtonItem = searchButton;
    
    FAKFoundationIcons *gridIcon = [FAKFoundationIcons thumbnailsIconWithSize:25];
    [gridIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.leftNavBarGridButton = [gridIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    self.leftNavBarGridLandscapeButton = [gridIcon imageWithSize:CGSizeMake(25, 25)];
    
    
    FAKFoundationIcons *listIcon = [FAKFoundationIcons listIconWithSize:25];
    [listIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.leftNavBarListButton = [listIcon imageWithSize:CGSizeMake(25, 25)];
    listIcon.iconFontSize = 25;
    self.leftNavBarListLandscapeButton = [listIcon imageWithSize:CGSizeMake(25, 25)];
    
    self.gridButton =
    [[UIBarButtonItem alloc] initWithImage:self.leftNavBarGridButton
                       landscapeImagePhone:self.leftNavBarGridLandscapeButton
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(changeGridStyle)];
    
    self.listButton =
    [[UIBarButtonItem alloc] initWithImage:self.leftNavBarListButton
                       landscapeImagePhone:self.leftNavBarListLandscapeButton
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(changeGridStyle)];
    
    self.navigationItem.leftBarButtonItem = self.gridButton;
    
}

-(void)changeGridStyle {
    self.gridStyle = !self.gridStyle; // toggle
    self.navigationItem.leftBarButtonItem = self.gridStyle ? self.listButton : self.gridButton;
    [self.collectionView reloadData];
}

-(void)searchButtonTapped:(id)sender{
    SRSearchTableViewController * search = [self.storyboard instantiateViewControllerWithIdentifier:@"Search"];
    [self.navigationController pushViewController:search animated:YES];
}

#pragma mark - UICollectionViewDataSource

// Special handling for grid views etc

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Check if we need to load new items from the server
    if (indexPath.row == self.requestModel.results.count-2) {
       self.currentRequest = [self.requestModel load];
    }
    
    NSString * identifier = nil;
    
    if (self.gridStyle) {
        identifier = @"SRTrackCollectionViewCellImage";
    } else {
        identifier = NSStringFromClass([SRTrackCollectionViewCell class]);

    }
    
    id currentObject = [self.requestModel.results  objectAtIndex:indexPath.row];
    SRTrackCollectionViewCell *cell = (SRTrackCollectionViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (self.gridStyle) {
        cell.showBigImage = YES;
    }
    cell.data = currentObject;
    cell.delegate = self;
    return  cell;

}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];

    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && ![isEnabled boolValue]) {
        UICollectionReusableView * header =  [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([GetSoundRocketProCollectionReusableView class]) forIndexPath:indexPath];
        
        UITapGestureRecognizer * tapRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerTapped:)];
        header.userInteractionEnabled = YES;
        header.backgroundColor = [SRStylesheet mainColor];
        [header addGestureRecognizer:tapRec];
        return header;
    }
    
    else return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

-(void)headerTapped:(id)sender {
    UITableViewController * proController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProPlan"];
    [self.navigationController pushViewController:proController animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * isEnabled  =     [defaults objectForKey:@"SoundrocketPro"];
    if ([isEnabled boolValue]) {
        return CGSizeMake(self.collectionView.frame.size.width, 0);
    }
    return CGSizeMake(self.collectionView.frame.size.width, 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}
@end
