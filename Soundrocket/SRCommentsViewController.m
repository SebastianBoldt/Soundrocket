//
//  CommentsTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 15.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <SVProgressHUD.h>

#import "Soundrocket-SWIFT.h"
#import "SRAuthenticator.h"
#import "SRCommentsViewController.h"
#import "Comment.h"
#import "SoundrocketClient.h"
#import "UIImageView+AFNetworking.h"
#import "SoundrocketClient.h"
#import "SRStylesheet.h"
#import "SRUserController.h"
#import "PlayerViewController.h"
#import "UIViewController+ToolbarPlayerAddition.h"

@interface SRCommentsViewController ()
@property (nonatomic,strong) NSString * order;

@end

@implementation SRCommentsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.requestModel = [[SRRequestModel alloc]init];
    [self.requestModel addDelegate:self];
    self.requestModel.inlineURLParameter = @{@"track_id":self.currentTrack.id};
    self.requestModel.endpoint = SC_COMMENTS_OF_TRACK;
    [self.navigationItem setTitle:NSLocalizedString(@"COMMENTS_PAGE_COMMENTS_TITLE", nil)];
    
    self.currentRequest = [self.requestModel load];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [SRStylesheet lightGrayColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.requestModel.results count]) {
        Comment * item = [self.requestModel.results objectAtIndex:indexPath.row];
        CGSize maximumLabelSize = CGSizeMake(self.collectionView.frame.size.width-66-8, CGFLOAT_MAX);
        CGRect textRect = [item.body boundingRectWithSize:maximumLabelSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                                  context:nil];
        return CGSizeMake(collectionView.frame.size.width, MAX(78.0f, ceil(textRect.size.height)+47+15));
    } else {
        return CGSizeMake(collectionView.frame.size.width,78.0f);
    }
}

-(void)userButtonPressedWithUser:(User *)user {
    [self dismissViewControllerAnimated:YES completion:^(){
        [self.delegate commentsViewControllerDidDismissWithUser:user];
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    __weak __block __typeof(self) weakself = self;
    [self dismissViewControllerAnimated:YES completion:^(){
        Comment * item = [self.requestModel.results objectAtIndex:indexPath.row];
        [weakself.delegate commentsViewControllerDidDismissWithUser:item.user];
    }];

}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
        [SVProgressHUD showWithStatus:@"Removing comment from track"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        Comment * comment= [self.comments objectAtIndex:indexPath.row];
        
        // Add Track to Playlist and then remove Viewcontroller from Top
        // Holen uns alle Tracks der Playlis
        NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
        [paramters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
        
        [[SoundrocketClient sharedClient] DELETE:[NSString stringWithFormat:@"tracks/%@/comments/%@.json",self.currentTrack.id,comment.id] parameters:paramters
         
         
        success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             
             // Reinitializing Comments
             [[PlayerViewController sharedPlayerViewController] setUpComments:self.currentTrack];
             
             [self.comments removeObjectAtIndex:indexPath.row];
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [SVProgressHUD showSuccessWithStatus:@"deleted comment"];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             
         }
         
        failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             // Fehlerbehandlung
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Something went wrong, please try again", nil)];

         }];
        
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}*/

@end
