//
//  WaveFormView.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 26.05.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "WaveFormView.h"
#import "SRStylesheet.h"
#import "SRAuthenticator.h"
#import "SoundCloudAPI.h"   

@interface WaveFormView()

@property (nonatomic,strong) NSMutableArray * bars;

@end

@implementation WaveFormView

-(void)awakeFromNib {
    [super awakeFromNib];
    self.bars = [[NSMutableArray alloc]init];
    self.backgroundColor = [UIColor clearColor];
}

-(void)setupWithTrack:(Track*)track {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.bars makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [[SoundCloudAPI sharedApi]getSamplesFromTrack:track whenSuccess:^(NSURLSessionTask * task, id responseObject){
        NSMutableArray * samples = [responseObject objectForKey:@"samples"];
        CGFloat steps = 200.0f;
        CGFloat stepInterval = (int)samples.count/steps;
        CGFloat width = (self.frame.size.width/steps);
        int currentItemCount = 0;
        
        // height stuff
        CGFloat scale = self.frame.size.height/150;
        for (int i = 0 ; i <= samples.count-1; i+=stepInterval) {
            CGFloat height = [[samples objectAtIndex:i] floatValue]*scale;
            CGFloat topPadding = (self.frame.size.height - height)/2;
            UIView * view = [[UIView alloc]initWithFrame:CGRectMake(width*currentItemCount,topPadding,1, height)];
            
            view.backgroundColor = [SRStylesheet whiteColor];
            [self.bars addObject:view];
            [self addSubview:view];
            
            currentItemCount++;
        }
    } whenError:^(NSURLSessionTask * task, NSError * error){
        // Show error or refresh View
    }];
}
@end
