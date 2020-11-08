//
//  HistoryTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 02.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "SRHistoryViewController.h"
#import "SRUserController.h"
#import "SRStore.h"
#import <SVProgressHUD.h>
#import "SRPlayer.h"
#import <FAKIonIcons.h>
#import "SRHelper.h"
#import "PlayerViewController.h"

@implementation SRHistoryViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.requestModel = [[SRRequestModel alloc]init];
    self.requestModel.localStore = YES;
    __weak typeof(self)weakSelf = self;
    [SRStore loadHistoryWithCompletion:^(NSMutableArray*loadedTracks){
        weakSelf.requestModel.results = loadedTracks;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf requestModelDidFinishLoading:nil];
        });
    }];
    
    self.navigationItem.title = @"History";
    
    FAKIonIcons *cogIcon = [FAKIonIcons iosTrashOutlineIconWithSize:25];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    cogIcon.iconFontSize = 25;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(25, 25)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clearHistory:)];
    
}

- (IBAction)refresh {
    __weak __block __typeof(self) weakSelf = self;
    [SRStore loadHistoryWithCompletion:^(NSMutableArray*loadedTracks){
        weakSelf.requestModel.results = loadedTracks;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf requestModelDidFinishLoading:nil];
        });
    }];
}

-(void)clearHistory:(id)sender {
    [SRStore clearHistory];
    __weak typeof(self)weakSelf = self;
    [SRStore loadHistoryWithCompletion:^(NSMutableArray*loadedTracks){
        weakSelf.requestModel.results = loadedTracks;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [weakSelf requestModelDidFinishLoading:nil];
        });
    }];
}

-(void)requestModelDidFinishLoading:(SRRequestModel *)requestModel {
    
    [self.collectionView reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    [self.loadingFooter.loadingIndicator stopAnimating];
}

-(void)requestModelDidStartLoading:(SRRequestModel *)requestModel {
    
}

-(void)requestModelDidFailWithLoading:(SRRequestModel *)requestModel withError:(NSError *)error {
    
    [self.collectionView reloadData];
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    [self.loadingFooter.loadingIndicator stopAnimating];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

@end
