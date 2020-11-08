//
//  PeopleLikedTrackTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 10.05.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "SRPeopleLikedTrackViewController.h"
#import "SRUserController.h"
#import "User.h"
#import "UIViewController+ToolbarPlayerAddition.h"
#import "SRAuthenticator.h"
#import "Soundrocket-SWIFT.h"
#import "SRUserController.h"
@interface SRPeopleLikedTrackViewController()

@property (nonatomic,strong) NSNumber * limit;

@property (nonatomic,strong) NSNumber * offset;

@property (nonatomic,assign) BOOL isLoading;

@property (nonatomic,assign) BOOL itemsAvailable;

@property(nonatomic,strong) NSMutableArray * users;

@property(nonatomic,strong) NSMutableArray * tasks;

@end

@implementation SRPeopleLikedTrackViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.requestModel = [[SRRequestModel alloc]init];
    self.requestModel.inlineURLParameter = @{@"track_id":[[SRPlayer sharedPlayer]currentTrack].id};
    self.requestModel.endpoint = SC_FAVORITERS_OF_TRACK;
    [self.requestModel addDelegate:self];
    self.currentRequest =  [self.requestModel load];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showUser"]) {
        User * user = [self.users objectAtIndex:[[self.collectionView indexPathsForSelectedItems]firstObject].row];
        SRUserController * dvc = (SRUserController*)segue.destinationViewController;
        dvc.user_ID = user.id;
    }
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
        return CGSizeMake((self.collectionView.frame.size.width/3) -1.5, (self.collectionView.frame.size.width/3) -1.5);
}
@end
