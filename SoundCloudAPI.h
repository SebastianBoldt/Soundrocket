//
//  SoundCloudAPI.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 13.09.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRBaseObjects.h"

/* Me endpoints */
static NSString * SCEndPointMe =                        @"https://api.soundcloud.com/me.json";
static NSString * SCEndPointMeTrackOfFavorites =        @"https://api.soundcloud.com/me/favorites/%@.json";
static NSString * SCEndPointMeUserOfFollowing =         @"https://api.soundcloud.com/me/followings/%@.json";
static NSString * SCEndPointMePlaylist =                @"https://api.soundcloud.com/me/playlists/%@.json";

/* That .json ending should be replaced somehow */
static NSString * SCEndPointOAuth =                     @"https://api.soundcloud.com/oauth2/token";

// Me endpoints

static NSString * SCEndPointRepostTrack =               @"https://api.soundcloud.com/e1/me/track_reposts/%ld.json";

// Comments
static NSString * SCEndpointCommentOfTracks =           @"https://api.soundcloud.com/tracks/%@/comments.json";

// Playlist Endpoints
static NSString * SCEndPointPlaylistsShow   =               @"https://api.soundcloud.com/playlists/%@.json";
static NSString * SCEndPointPlaylistsIndex   =               @"https://api.soundcloud.com/playlists.json";

static NSString * SCEndpointUser        =               @"https://api.soundcloud.com/users/%ld.json";
static NSString * SCEndpointResolve       =             @"https://api.soundcloud.com/resolve.json";

/*
 * This class encapsulates all the SoundCloudAPI methods
 * 
 * You need to include JSON-Model for the mapping
 * and AFNetworking for request handling
 * this class also handles reauthentication init flow if response code is 404 somewhere
 */

@interface SoundCloudAPI : NSObject

// You need to set these two propertys before using the client e.g for example inside the Appdelegates didFinish Launching

@property (nonatomic,strong) NSString * clientID;
@property (nonatomic,strong) NSString * clientSecret;

+ (instancetype)sharedApi;

#pragma mark - User Action 

-(void)getUserForID:(NSInteger)identifier
                whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                  whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)getUserForAccessToke:(NSString*)accessToken
             whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
               whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)removeTrack:(Track*)track fromFavoritesForUserWithAccessToke:(NSString*)token
                whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                  whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)addTrack:(Track*)track toFavoritesForUserWithAccessToke:(NSString*)token
                                         whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                                           whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)checkIfUserWithAccessToken:(NSString*)accessToken hasFavoritedTrack:(Track*)track
                      whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)checkIfUserWithAccessToken:(NSString*)accessToken isFollowingUser:(User*)user
                      whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)userWithAccessToken:(NSString*)accessToken unfollowUser:(User*)user
                      whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                        whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)userWithAccessToken:(NSString*)accessToken followUser:(User*)user
               whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                 whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

#pragma mark Comments on Track

-(void)addComment:(NSString*)comment
          toTrack:(Track*)track
fromUserWithAuthToken:(NSString*)authToken
           atTime:(NSNumber*)positionTimeStamp
      whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
        whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)getCommentsOfTrack:(Track*)track
      whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
        whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)getSamplesFromTrack:(Track*)track
               whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                 whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

#pragma mark - Playlist Handling

// Create Playlist
-(void)deletePlaylist:(Playlist*)playlist withAccessToken:(NSString*)accessToken
                  whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
                    whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock;

// Create Playlist
-(void)createPlaylistWithName:(NSString*)name public:(BOOL)shouldBePublic
               whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
                 whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock;

-(void)updatePlaylist:(Playlist*)playlist withName:(NSString*)name public:(BOOL)shouldBePublic
                  whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
                    whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock;

// Returns Tracks of Playlist for a user with access_token
-(void)getTracksOfPlaylist:(Playlist *)playlist forUserWithAccessToken:(NSString*)access_token
               whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
                 whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock;

// First gets all Tracks using a access_token and then adds track to that playlist
-(void)update:(Playlist*)playlist withTrackIDs:(NSMutableArray*)trackIDs
    whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
      whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

#pragma mark - Authentication stuff

// Access Token should be available through [responseObject objectForKey:@"access_token"]

-(void)loginWithUsername:(NSString*)userName
             andPassword:(NSString*)password
             whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
               whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)loginWithCode:(NSString*)code
         whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
           whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

-(void)getAccessTokenWithRefreshToken:(NSString*)refreshToken
         whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
           whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

#pragma mark - Track Actions

-(void)repostTrack:(Track*)track
       whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
         whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;

#pragma mark - Resolve Actions 

-(void)resolveURL:(NSString*)resolve
       whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
         whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;


#pragma mark - Helper 

-(NSString*)getWaveFormUrlForTrack:(Track*)track;

@end
