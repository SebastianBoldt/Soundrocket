//
//  SRRequestModel.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 14.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SC_LIKES_FAVORITES_ENDPOINT @"favorites"
#define SC_ACTIVITIES_ENDPOINT @"activities"
#define SC_TRACKS_OF_PLAYLIST @"tracks_of_playlist"

#define SC_SEARCH_USERS @"search_user"
#define SC_SEARCH_TRACKS @"search_tracks"
#define SC_SEARCH_PLAYLISTS @"search_paylists"
#define SC_FAVORITERS_OF_TRACK @"favoriters_of_track"
#define SC_COMMENTS_OF_TRACK @"comments_of_track"

// User Profile

#define SC_TRACKS_OF_USER       @"tracks_of_user"
#define SC_PLAYLISTS_OF_USER    @"playlists_of_user"
#define SC_LIKES_OF_USER        @"likes_of_user"
#define SC_FOLLOWERS_OF_USER    @"followers_of_user"
#define SC_FOLLOWINGS_OF_USER   @"followings_of_user"

@class SRRequestModel;

@protocol SRRequestModelDelegate <NSObject>
@optional
-(void)requestModelDidStartLoading:(SRRequestModel*)requestModel;
-(void)requestModelDidFinishLoading:(SRRequestModel*)requestModel;
-(void)requestModelDidFailWithLoading:(SRRequestModel*)requestModel withError:(NSError*)error;
@end

@interface SRRequestModel : NSObject

@property (nonatomic,strong) NSString * endpoint;
@property (nonatomic,strong) NSMutableArray  * results;
@property (nonatomic,strong) NSMutableArray * justTracksAndReposts;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;
@property (nonatomic,strong) NSString * nextUrl;
@property (nonatomic,strong) NSString * fetchURL;
@property (nonatomic,strong) NSDictionary * additionalParameters;
@property (nonatomic,strong) NSDictionary * inlineURLParameter;
@property (nonatomic,assign) BOOL localStore;
@property (nonatomic,assign) BOOL isRefreshing;

-(instancetype)init;
-(NSURLSessionDataTask*)load;
-(void)refreshModel; // Fetches the inital URL and sets the new items

#pragma mark - Delegate Managment
-(void)addDelegate:(id<SRRequestModelDelegate>)delegate;
-(void)removeDelegate:(id)delegate;
@end
