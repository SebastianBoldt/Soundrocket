//
//  SRPlayer.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 01.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//



// Libarys
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
// Own classes
#import "Track.h"
#import "SRRequestModel.h"
@class SRPlayer;

// This Protocol defines methods that are called inside all the delegates that subscribe to the Player class
@protocol SRPlayerDelegate <NSObject>
@optional
-(void)player:(SRPlayer*)player willStartWithTrack:(Track*)track fromIndexPath:(NSIndexPath*)path;
-(void)player:(SRPlayer*)player didFinishWithTrack:(Track*)track;
-(void)player:(SRPlayer*)player willStartWithOfflineTrack:(Track*)track;
-(void)player:(SRPlayer *)player willPauseTrack:(Track *)track;
-(void)player:(SRPlayer *)player willPlayTrack:(Track *)track;
-(void)player:(SRPlayer *)player isReadyToPlayTrack:(Track*)track;
@end

/**
 *  This class is responsible for handling Audio Playback
 */
@interface SRPlayer : NSObject

+ (instancetype)sharedPlayer;

@property   (nonatomic,strong)  Track  * currentTrack;
@property   (nonatomic,strong) NSMutableArray * upNext;           // Stores up Next Tracks inside an Array, should just be used for offline tracks
@property   (nonatomic,strong) NSIndexPath* playingIndex;         // Indexpath of currently paying Track
@property   (nonatomic,strong) NSMutableArray * history;          // Array of Tracks played in the past
@property   (nonatomic,strong) SRRequestModel * model;

-(void)addDelegate:(id<SRPlayerDelegate>)delegate;
-(void)removeDelegate:(id)delegate;

-(NSTimeInterval)availableDuration;
-(AVPlayerItemStatus)streamingStatus;
-(CMTime)durationOfCurrentItem;
-(CMTime)currentTime;

-(void)play;
-(void)playNextTrack;
-(void)playLastTrack;
-(void)pause;
-(void)stop;
-(void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL))completionHandler;
-(float)rate;
-(void)togglePlayback;
-(BOOL)isPlaying;

-(void)saveStreamingID:(NSString*)string;
-(NSString*)loadStreamingID;

@end
