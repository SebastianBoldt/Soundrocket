//
//  SRWhatsNextViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 01.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRWhatsNextViewController.h"

@interface SRWhatsNextViewController ()

@end

@implementation SRWhatsNextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)userButtonPressedWithUser:(User *)user {
    // Do nothing if user button is pressed
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [self.requestModel.results objectAtIndex:indexPath.row];
    
    if ([object isKindOfClass:[Playlist class]]) {
        __weak __block __typeof(self) weakself = self;

        [self dismissViewControllerAnimated:YES completion:^(){
            [weakself.delegate nextControllerDidSelectPlaylist:object];
        }];
    } else if ([object isKindOfClass:[PlaylistRepost class]]) {
        __weak __block __typeof(self) weakself = self;
        
        [self dismissViewControllerAnimated:YES completion:^(){
            [weakself.delegate nextControllerDidSelectPlaylist:[[Playlist alloc]initWithPlayListRepost:object]];
        }];
    }
    
    else {
        [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}
@end
