//
//  SRRequestModel.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 14.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import "SRRequestModel.h"
#import "SRHelper.h"
#import "SoundrocketClient.h"
#import "SRAuthenticator.h"
#import "Track.h"
#import "SRFactory.h"
#import "URLParser.h"

#import <AFHTTPRequestOperationManager.h>

@interface SRRequestModel()

    // Propertys for limit offset stuff
    @property (nonatomic,strong) NSNumber * limit;
    @property (nonatomic,strong) NSNumber * offset;
    @property (nonatomic,strong) NSMutableArray * delegates;

@end

@implementation SRRequestModel

-(instancetype)init{
    
    if (self = [super init]) {
        // Basic values for RequestModel
        self.nextUrl = nil;
        self.endpoint = nil;
        self.offset = @0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.limit = @100;
        } else {
            self.limit = @30;
        }
        
        self.isLoading = NO;
        self.itemsAvailable = YES;
        self.results = [[NSMutableArray alloc]init];
        self.delegates = SRCreateNonRetainingArray();
    }
    return self;
}

#pragma mark - Deleagte management

-(void)addDelegate:(id<SRRequestModelDelegate>)delegate{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}
-(void)removeDelegate:(id)delegate{
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

-(void)refreshModel {
    if (!self.isLoading) {
        self.itemsAvailable  = YES;
        self.offset = @0;
        self.nextUrl = nil;
    }
}

-(NSURLSessionDataTask*)load {
    __block __weak SRRequestModel * weakSelf = self;
    if (self.itemsAvailable) {
        self.isLoading = YES;
        for (id<SRRequestModelDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(requestModelDidStartLoading:)]) {
                [delegate requestModelDidStartLoading:self];
            }
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        if ([SRAuthenticator sharedAuthenticator].authToken) {
            [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
            
        } else {
            [parameters setObject:[defaults objectForKey:@"access_token"] forKey:@"oauth_token"];
        }
        
        if (self.nextUrl != nil && ([self.nextUrl class] != [NSNull class])) {
            // Setze die URL wenn nicht dann halt nicht
            URLParser *parser = [[URLParser alloc] initWithURLString:self.nextUrl];
            NSString * cursor = [parser valueForVariable:@"cursor"];
            [parameters setObject:cursor forKey:@"cursor"];
        } else {
            [parameters setObject:self.limit forKey:@"limit"];
            [parameters setObject:self.offset forKey:@"offset"];
        }
        NSString * nexturl = nil;
        if (self.nextUrl != nil && ([self.nextUrl class] != [NSNull class])) {
            nexturl = self.nextUrl;
        } else {
            nexturl = self.fetchURL;
        }
        
        if (self.additionalParameters) {
            for (id key in [self.additionalParameters allKeys]) {
                [parameters setObject:[self.additionalParameters objectForKey:key] forKey:key];
            }
        }
        
        return [[SoundrocketClient sharedClient] GET:nexturl parameters:parameters
                                      success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             
             if (weakSelf.isRefreshing) {
                 self.results = [[NSMutableArray alloc]init];
                 weakSelf.isRefreshing = NO;
             }
             
             // Dictionary could be a next_href stuff
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 if ([responseObject objectForKey:@"next_href"]) {
                     self.nextUrl = [responseObject objectForKey:@"next_href"];
                 } else self.nextUrl = nil;
                 id object = nil;
                 if ([self.endpoint isEqualToString:SC_ACTIVITIES_ENDPOINT]) {
                     for (NSDictionary * activity in [responseObject objectForKey:@"collection"]) {
                         object = [SRFactory createObjectFromDictionary:activity];
                         if (object) {
                             [self.results addObject:object];
                         }
                     }
                 } else if([self.endpoint isEqualToString:SC_TRACKS_OF_PLAYLIST]){
                     if ([[responseObject objectForKey:@"tracks"]count] == 0) {
                         self.itemsAvailable = NO;
                     } else {
                         self.itemsAvailable = YES;
                     }
                     for (NSDictionary * trackInfo in [responseObject objectForKey:@"tracks"]) {
                         Track * track = [[Track alloc] initWithDictionary:trackInfo error:nil];
                         if (track) {
                             [self.results addObject:track];
                         }
                     }

                 } else if([self.endpoint isEqualToString:SC_FOLLOWERS_OF_USER] || [self.endpoint isEqualToString:SC_FOLLOWINGS_OF_USER]){
                     if ([[responseObject objectForKey:@"collection"]count] == 0) {
                         self.itemsAvailable = NO;
                     } else {
                         self.itemsAvailable = YES;
                     }
                     for (NSDictionary * userInfo in [responseObject objectForKey:@"collection"]) {
                         User * user = [[User alloc] initWithDictionary:userInfo error:nil];
                         if (user) {
                             [self.results addObject:user];
                         }
                     }
                     
                 }
                 
             // If it is just an array it seems to use limit and offset
             } else if ([responseObject isKindOfClass:[NSArray class]]){
                 if ([responseObject count] == 0) {
                     self.itemsAvailable = NO;
                 } else {
                     self.itemsAvailable = YES;
                 }
                 
                 for (NSDictionary * trackInfo in responseObject) {
                     id object = nil;
                     // We know that likes are available
                     if ([self.endpoint isEqualToString:SC_LIKES_FAVORITES_ENDPOINT] ||[self.endpoint isEqualToString:SC_TRACKS_OF_USER] || [self.endpoint isEqualToString:SC_LIKES_OF_USER] || [self.endpoint isEqualToString:SC_SEARCH_TRACKS]) {
                         object = [SRFactory createTrackFromDictionary:trackInfo];
                         if (object) {
                             [self.results addObject:object];
                         }
                     } else if([self.endpoint isEqualToString:SC_PLAYLISTS_OF_USER] || [self.endpoint isEqualToString:SC_SEARCH_PLAYLISTS]){
                         object = [SRFactory createPlaylistFromDictionary:trackInfo];
                         if (object) {
                             [self.results addObject:object];
                         }
                     } else if([self.endpoint isEqualToString:SC_FOLLOWERS_OF_USER] || [self.endpoint isEqualToString:SC_FOLLOWINGS_OF_USER] || [self.endpoint isEqualToString:SC_SEARCH_USERS] || [self.endpoint isEqualToString:SC_FAVORITERS_OF_TRACK]){
                         object = [SRFactory createUserFromDictionary:trackInfo];
                         if (object) {
                             [self.results addObject:object];
                         }
                     } else if([self.endpoint isEqualToString:SC_COMMENTS_OF_TRACK]){
                         object = [SRFactory createCommentFromDictionary:trackInfo];
                         if (object) {
                             [self.results addObject:object];
                         }
                     }
                     
                 }
             }
             
             
             long offset = [self.offset integerValue] + [self.limit integerValue];
             self.offset = [NSNumber numberWithLong:offset];
             self.isLoading = NO;
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
             // Inform the delegates
             for (id<SRRequestModelDelegate> delegate in self.delegates) {
                 [delegate requestModelDidFinishLoading:weakSelf];
             }
         }
         
         failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             NSInteger statuscode = response.statusCode;
             if (statuscode == 401) {
                 [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                     [self load];
                 } failure:^(){
                     self.isLoading = NO;
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     for (id<SRRequestModelDelegate> delegate in self.delegates) {
                         [delegate requestModelDidFailWithLoading:weakSelf withError:error];
                     }
                 }];
             } else {
                 self.isLoading = NO;
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                 for (id<SRRequestModelDelegate> delegate in self.delegates) {
                     [delegate requestModelDidFailWithLoading:weakSelf withError:error];
                 }
             }
             
         }];
    }
    
    return nil;
}

// Sometimes the fetch url needs to be set manually 
-(void)setEndpoint:(NSString *)endpoint {
    [self refreshModel];
    if (_endpoint != endpoint) {
        _endpoint = endpoint;
        if ([_endpoint isEqualToString:SC_LIKES_FAVORITES_ENDPOINT]) {
            self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/favorites.json",[SRAuthenticator sharedAuthenticator].currentUser.id];
        } else if([_endpoint isEqualToString:SC_ACTIVITIES_ENDPOINT]) {
            self.fetchURL = @"https://api.soundcloud.com/me/activities.json";
        } else if([_endpoint isEqualToString:SC_FAVORITERS_OF_TRACK]) {
            if ([self.inlineURLParameter objectForKey:@"track_id"]) {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/favoriters.json",[self.inlineURLParameter objectForKey:@"track_id"]];
            } else {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/favoriters.json",@0];
            }
        }
        else if([_endpoint isEqualToString:SC_SEARCH_PLAYLISTS]) {
            self.fetchURL = @"https://api.soundcloud.com/playlists.json";
        } else if([_endpoint isEqualToString:SC_SEARCH_TRACKS]) {
            self.fetchURL = @"https://api.soundcloud.com/tracks.json";
        } else if([_endpoint isEqualToString:SC_SEARCH_USERS]) {
            self.fetchURL = @"https://api.soundcloud.com/users.json";
        } else if ([endpoint isEqualToString:SC_COMMENTS_OF_TRACK]){
            self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/comments.json?order=created_at",[self.inlineURLParameter objectForKey:@"track_id"]];
        }
        
        
        // User Profile
        
        else if([_endpoint isEqualToString:SC_PLAYLISTS_OF_USER]) {
            if ([self.inlineURLParameter objectForKey:@"user_id"]) {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/playlists.json",[self.inlineURLParameter objectForKey:@"user_id"]];
            } else {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/playlists.json",[SRAuthenticator sharedAuthenticator].currentUser.id];
            }
        }
        
        else if([_endpoint isEqualToString:SC_LIKES_OF_USER]) {
            if ([self.inlineURLParameter objectForKey:@"user_id"]) {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/favorites.json",[self.inlineURLParameter objectForKey:@"user_id"]];
            } else {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/favorites.json",[SRAuthenticator sharedAuthenticator].currentUser.id];
            }
        }
        
        else if([_endpoint isEqualToString:SC_TRACKS_OF_USER]) {
            if ([self.inlineURLParameter objectForKey:@"user_id"]) {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks.json",[self.inlineURLParameter objectForKey:@"user_id"]];
            } else {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks.json",[SRAuthenticator sharedAuthenticator].currentUser.id];
            }
        }
        
        else if([_endpoint isEqualToString:SC_FOLLOWERS_OF_USER]) {
            if ([self.inlineURLParameter objectForKey:@"user_id"]) {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/followers.json",[self.inlineURLParameter objectForKey:@"user_id"]];
            } else {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/followers.json",[SRAuthenticator sharedAuthenticator].currentUser.id];
            }
        }
        
        else if([_endpoint isEqualToString:SC_FOLLOWINGS_OF_USER]) {
            if ([self.inlineURLParameter objectForKey:@"user_id"]) {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/followings.json",[self.inlineURLParameter objectForKey:@"user_id"]];
            } else {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/followings.json",[SRAuthenticator sharedAuthenticator].currentUser.id];
            }
        }
    
        else if([_endpoint isEqualToString:SC_TRACKS_OF_PLAYLIST]) {
            if ([self.inlineURLParameter objectForKey:@"playlist_id"]) {
                self.fetchURL = [NSString stringWithFormat:@"https://api.soundcloud.com/playlists/%@.json",[self.inlineURLParameter objectForKey:@"playlist_id"]];
            }
        }
    }
}

-(NSMutableArray *)justTracksAndReposts {
    NSMutableArray * tracksAndReposts = [[NSMutableArray alloc]init];
    for (id object in self.results) {
        if ([object isKindOfClass:[Track class]] || [object isKindOfClass:[TrackRepost class]]) {
            [tracksAndReposts addObject:object];
        }
    }
    return tracksAndReposts;
}

-(void)setInlineURLParameter:(NSDictionary *)inlineURLParameter {
    _inlineURLParameter = inlineURLParameter;
}
@end
