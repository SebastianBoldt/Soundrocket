//
//  SRPlayer.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 01.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

// Libarys
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <SVProgressHUD.h>

// Own classes
#import "SRPlayer.h"
#import "Track.h"
#import "SRStore.h"
#import "SRAuthenticator.h"
#import "SRHelper.h"
#import "SRRequestModel.h"

#import "Soundrocket-SWIFT.h"

@interface SRPlayer()

@property   (nonatomic,strong)  AVAsset          * currentAsset;
@property   (nonatomic,strong)  AVPlayerItem * streamingItem;

@property   (nonatomic)         BOOL             loopCurrentTrack;
@property   (nonatomic)         BOOL             playNextTrackAfterLoad;
@property   (nonatomic)         NSUInteger       lastTrackIndex;

@property   (nonatomic,strong)  NSMutableArray   * delegates;
@property   (nonatomic,strong)  AVPlayer     * soundPlayer;
@end

@interface SRPlayer() <SRRequestModelDelegate>
@end
#pragma mark - Implementation

@implementation SRPlayer

+ (instancetype)sharedPlayer {
    static SRPlayer *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Init Stuff
        _sharedPlayer = [[SRPlayer alloc]init];
        _sharedPlayer.soundPlayer = [[AVPlayer alloc]init];
        [_sharedPlayer.soundPlayer addObserver:_sharedPlayer forKeyPath:@"rate" options:0 context:nil];
        _sharedPlayer.delegates = [[NSMutableArray alloc]init];
        _sharedPlayer.upNext = [[NSMutableArray alloc]init];
        _sharedPlayer.history = [[NSMutableArray alloc]init];
        _sharedPlayer.playingIndex = 0;
    });
    return _sharedPlayer;
}

-(void)addDelegate:(id<SRPlayerDelegate>)delegate{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}
-(void)removeDelegate:(id)delegate{
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

-(void)setModel:(SRRequestModel *)model {
    [_model removeDelegate:self];
    _model = model;
    [model addDelegate:self];
}

-(void)setCurrentTrack:(Track *)currentTrack {
    // Remove ourself as an Observer
    @try {
        [self.streamingItem removeObserver:self forKeyPath:@"playbackBufferEmpty" ];
        [self.streamingItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.streamingItem];
    }
    @catch (NSException *exception) {
        
    }
    
    _currentTrack = currentTrack;
     // Inform all delegates
    for (id<SRPlayerDelegate> delegate in self.delegates) {
        [delegate player:self willStartWithTrack:currentTrack fromIndexPath:self.playingIndex];
    }

    // Do setup stuff
    NSString *streamURL = nil;
    NSString *urlString = nil;
    NSString *client_ID = nil;
    
    if ([self loadStreamingID]) {
        client_ID = [self loadStreamingID];
    } else {
        client_ID = @"3ceea65b3d83ab630bc818ce1d179a82";
    }
    
    NSURL *url = nil;
    if(currentTrack.local_path){
        streamURL =currentTrack.local_path;
        url = [[NSURL alloc]initFileURLWithPath:currentTrack.local_path];
        for (id<SRPlayerDelegate> delegate in self.delegates) {
            [delegate player:self willStartWithOfflineTrack:self.currentTrack];
        }
        
    } else {
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString * token = @"";
        if ([SRAuthenticator sharedAuthenticator].authToken) {
            token =[SRAuthenticator sharedAuthenticator].authToken;
            
        } else {
            token = [defaults objectForKey:@"access_token"];
        }
        
        streamURL = currentTrack.stream_url;
        urlString = [NSString stringWithFormat:@"%@?client_id=%@&oauth_token=%@", streamURL, client_ID,token];
        url = [NSURL URLWithString:urlString];
    }

    
    self.currentAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    self.streamingItem = [AVPlayerItem playerItemWithAsset:self.currentAsset];
    [self.streamingItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.streamingItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.streamingItem];
    
    [self.soundPlayer replaceCurrentItemWithPlayerItem:self.streamingItem];

    if (true) {
        [SRStore storeStrackToHistory:currentTrack];
    }
    
    [self.soundPlayer play];
}

-(void)itemDidFinishPlaying:(id)sender {
    NSLog(@"Called");
    for (id<SRPlayerDelegate> delegate in self.delegates) {
        [delegate player:self didFinishWithTrack:self.currentTrack];
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"repeatStatus"]) {
        BOOL isActive = [[defaults objectForKey:@"repeatStatus"]boolValue];
        if (isActive) {
            [self seekToTime:CMTimeMake(0,1) completionHandler:nil];
            [self play];
        } else {
            [self playNextTrack];
        }
    } else {
        [self playNextTrack];
    }
}

-(void)play {
    [self.soundPlayer play];
}
-(void)pause {
    [self.soundPlayer pause];
}

-(void)stop {
    self.streamingItem = nil;
}

-(float)rate {
    return self.soundPlayer.rate;
}

-(CMTime)currentTime{
    return self.soundPlayer.currentItem.currentTime;
}

-(void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler {
    
    [self.soundPlayer seekToTime:time completionHandler:^(BOOL finished){
        if (finished)
        {
            if(completionHandler){
                completionHandler(true);
            }
        }

    }];
}

-(void)playNextTrack {
    NSIndexPath * index = self.playingIndex;
    if (self.model) {
        if ((index.row+1)< [self.model.justTracksAndReposts count]) {
            [self setPlayingIndex:[NSIndexPath indexPathForItem:index.row+1 inSection:1]];
            [self setCurrentTrack:[self.model.justTracksAndReposts objectAtIndex:index.row +1]];
        } else {
            self.playNextTrackAfterLoad = YES;
            [self.model load];
        }
    } else {
        NSMutableArray * currentTracks = self.upNext;
        if ((index.row+1)< [currentTracks count]) {
            [self setPlayingIndex:[NSIndexPath indexPathForItem:index.row+1 inSection:1]];
            [self setCurrentTrack:[currentTracks objectAtIndex:index.row +1]];
        }
    }
}

-(void)playLastTrack {
    NSIndexPath * index = self.playingIndex;
    [self setPlayingIndex:[NSIndexPath indexPathForItem:index.row+-1 inSection:1]];
    if (self.model) {
        NSMutableArray * currentTracks = self.model.justTracksAndReposts;
        if ((index.row-1)>= 0) {
            [self setCurrentTrack:[currentTracks objectAtIndex:index.row -1]];
        }
    } else {
        NSMutableArray * currentTracks = self.upNext;
        if ((index.row-1)>= 0) {
            [self setCurrentTrack:[currentTracks objectAtIndex:index.row -1]];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {    
    // Wenn rate vorhanden ist dann wir dgepsielt wenn nicht ist pause
    if ([keyPath isEqualToString:@"rate"]) {
        if ([self.soundPlayer rate]) {
            for (id<SRPlayerDelegate> delegate in self.delegates) {
                [delegate player:self willPlayTrack:self.currentTrack];
            }
            
        }
        else {
            for (id<SRPlayerDelegate> delegate in self.delegates) {
                [delegate player:self willPauseTrack:self.currentTrack];
            }
            
        }
    }
    
    else if (object == self.streamingItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (self.streamingItem.playbackBufferEmpty) {
            
            [self pause];
        }
    }
    
    else if (object == self.streamingItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (self.streamingItem.playbackLikelyToKeepUp)
        {
            // Buffer ready
        }
    }
    else if (object == self.soundPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.soundPlayer.status == AVPlayerStatusReadyToPlay) {
            for (id<SRPlayerDelegate> delegate in self.delegates) {
                [delegate player:self isReadyToPlayTrack:self.currentTrack];
            }
        } else if (self.soundPlayer.status == AVPlayerStatusFailed) {
        }
    }
}

-(NSTimeInterval)availableDuration {
    NSArray * loadedTimeRanges = [[self.soundPlayer currentItem]loadedTimeRanges];
    if ([loadedTimeRanges count] != 0 ) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0]CMTimeRangeValue];
        Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval result = startSeconds + durationSeconds;
        return  result;
    }
    
    return 0;
    
}

-(AVPlayerItemStatus)streamingStatus {
    return self.soundPlayer.currentItem.status;
}

-(CMTime)durationOfCurrentItem {
    return [[[self.soundPlayer currentItem] asset] duration];
}

-(void)togglePlayback {
    if ([self.soundPlayer rate] != 0.0) {
        [self pause];
    } else [self play];
}

#pragma mark - SRRequestModelDelegate  

-(void)requestModelDidFailWithLoading:(SRRequestModel *)requestModel withError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

-(void)requestModelDidFinishLoading:(SRRequestModel *)requestModel {
    [SVProgressHUD dismiss];
    if (self.playNextTrackAfterLoad) {
        [self playNextTrack];
    }
    self.playNextTrackAfterLoad = NO;
}

-(void)requestModelDidStartLoading:(SRRequestModel *)requestModel {
    
}

-(NSMutableArray *)upNext {
    if ([_upNext count]>0 && (self.model == nil)) {
        return _upNext;
    } else {
        return self.model.results;
    }
}

-(void)saveStreamingID:(NSString*)string {
    NSUserDefaults * sharedDefaults = [NSUserDefaults standardUserDefaults];
    if ([string isEqualToString:@""] || string == nil || string == [NSNull class]) {
        [sharedDefaults removeObjectForKey:@"CLIENT_ID"];
    } else {
        [sharedDefaults setObject:string forKey:@"CLIENT_ID"];
    }
    [sharedDefaults synchronize];
}

-(NSString*)loadStreamingID {
    NSUserDefaults * sharedDefaults = [NSUserDefaults standardUserDefaults];
    return [sharedDefaults objectForKey:@"CLIENT_ID"];
}

-(BOOL)isPlaying {
    if([self rate]  == 0.0){
        return NO;
    } else {
        return YES;
    }
}

@end
