//
//  SRBaseCollectionViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 23.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRRequestModel.h"
#import "SRTrackCollectionViewCell.h"
#import "SRLoadingCollectionViewCell.h"


/**
 *  Notes
 *  • Subclasses should always configure requestModel in viewDidLoad and trigger load request inside of them
 */
@interface SRBaseCollectionViewController : UIViewController <SRRequestModelDelegate,UICollectionViewDataSource,UICollectionViewDelegate,SRTrackCollectionViewCellDelegate>

@property(nonatomic,strong) IBOutlet UICollectionView * collectionView;
@property(nonatomic,strong) UIView * loadingScreen;
@property(nonatomic,strong) UIView * activityIndicatorView;
@property(nonatomic,strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) SRLoadingCollectionViewCell * loadingFooter;

@property (nonatomic,strong) UIView * footerView;
@property (nonatomic,strong) SRRequestModel * requestModel;

@property (nonatomic,strong) NSURLSessionDataTask * currentRequest;

- (void)refresh; // Resets all paramters and refreshes model

#pragma mark - Change 

@property (nonatomic,assign) BOOL gridStyle;

@property (nonatomic,strong) UIBarButtonItem * listButton;
@property (nonatomic,strong) UIBarButtonItem * gridButton;

@end
