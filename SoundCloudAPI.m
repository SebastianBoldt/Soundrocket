//
//  SoundCloudAPI.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 13.09.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import "SoundCloudAPI.h"
#import "SoundrocketClient.h"
#import "SRAuthenticator.h"

typedef void (^SuccessBlockType)(NSURLSessionTask*,id);
typedef void (^FailureBlockType)(NSURLSessionTask*, NSError*);
typedef void (^ReauthenticationBlockType)(SuccessBlockType,FailureBlockType);

@interface SoundCloudAPI()
@property (nonatomic, copy) ReauthenticationBlockType reauthBlock;
@end

@implementation SoundCloudAPI

// Singleton method that returns unique instance
+ (instancetype)sharedApi{
    static SoundCloudAPI *_sharedApi = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Init Stuff
        _sharedApi = [[SoundCloudAPI alloc]init];
    });
    return _sharedApi;
}

#pragma mark - Tracks 

-(void)addComment:(NSString*)comment
          toTrack:(Track*)track
fromUserWithAuthToken:(NSString*)authToken
           atTime:(NSNumber*)positionTimeStamp
      whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
               whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock;
{
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
    NSMutableDictionary * subparams = [[NSMutableDictionary alloc]init];
    [subparams setObject:comment forKey:@"body"];
    [subparams setObject:positionTimeStamp.stringValue forKey:@"timestamp"];
    [parameters setObject:subparams forKey:@"comment"];
    
    [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
    [[SoundrocketClient sharedClient] POST:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/comments",track.id] parameters:parameters
                                   success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
        failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself addComment:comment toTrack:track fromUserWithAuthToken:authToken atTime:positionTimeStamp whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

-(void)getCommentsOfTrack:(Track*)track
              whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([SRAuthenticator sharedAuthenticator].authToken) {
        [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
        
    } else {
        [parameters setObject:[defaults objectForKey:@"access_token"] forKey:@"oauth_token"];
    }
    [[SoundrocketClient sharedClient] GET:[NSString stringWithFormat:SCEndpointCommentOfTracks,track.id] parameters:parameters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself getCommentsOfTrack:track whenSuccess:successBlock whenError:errorBlock] ;
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

#pragma mark - Playlist

-(void)deletePlaylist:(Playlist*)playlist withAccessToken:(NSString*)accessToken
          whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
            whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:accessToken forKey:@"oauth_token"];
    
    [[SoundrocketClient sharedClient] DELETE:[NSString stringWithFormat:SCEndPointPlaylistsShow,playlist.id] parameters:paramters
     
     
                                     success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
                                     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself deletePlaylist:playlist withAccessToken:accessToken whenSuccess:successBlock whenError:errorBlock] ;
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}
// udpate Playlist
-(void)updatePlaylist:(Playlist*)playlist withName:(NSString*)name public:(BOOL)shouldBePublic
          whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
            whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
    
    NSMutableDictionary * newPlaylistParameters = [[NSMutableDictionary alloc]init];
    [newPlaylistParameters setObject:name forKey:@"title"];
    
    if (shouldBePublic) {
        [newPlaylistParameters setObject:@"public" forKey:@"sharing"];
    } else {
        [newPlaylistParameters setObject:@"private" forKey:@"sharing"];
        
    }
    
    [paramters setObject:newPlaylistParameters forKey:@"playlist"];
    [[SoundrocketClient sharedClient] PUT:[NSString stringWithFormat:SCEndPointPlaylistsShow,playlist.id] parameters:paramters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself updatePlaylist:playlist withName:name public:shouldBePublic whenSuccess:successBlock whenError:errorBlock] ;
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

// Create Playlist
-(void)createPlaylistWithName:(NSString*)name public:(BOOL)shouldBePublic
                  whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
                    whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
    
    NSMutableDictionary * playlist = [[NSMutableDictionary alloc]init];
    [playlist setObject:name forKey:@"title"];
    
    if (shouldBePublic) {
        [playlist setObject:@"public" forKey:@"sharing"];
    } else {
        [playlist setObject:@"private" forKey:@"sharing"];
        
    }
    
    [paramters setObject:playlist forKey:@"playlist"];
    
    [[SoundrocketClient sharedClient] POST:SCEndPointPlaylistsIndex parameters:paramters
     
     
    success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
                                   failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself createPlaylistWithName:name public:shouldBePublic whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

-(void)getTracksOfPlaylist:(Playlist *)playlist forUserWithAccessToken:(NSString*)access_token
               whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
                 whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:access_token forKey:@"oauth_token"];
    
    [[SoundrocketClient sharedClient] GET:[NSString stringWithFormat:SCEndPointPlaylistsShow,playlist.id] parameters:parameters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself getTracksOfPlaylist:playlist forUserWithAccessToken:access_token whenSuccess:successBlock whenError:errorBlock] ;
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

-(void)update:(Playlist*)playlist withTrackIDs:(NSMutableArray*)trackIDs
  whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
    whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
    [paramters setObject:@{@"tracks":trackIDs} forKey:@"playlist"];
    
    
    [[SoundrocketClient sharedClient] PUT:[NSString stringWithFormat:SCEndPointPlaylistsShow,playlist.id] parameters:paramters
     
     
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself update:playlist withTrackIDs:trackIDs whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

#pragma mark - User

-(void)getUserForID:(NSInteger)identifier
        whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
          whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
    
    // Request all Activities
    [[SoundrocketClient sharedClient] GET:[NSString stringWithFormat:SCEndpointUser,identifier] parameters:parameters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
         
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself getUserForID:identifier whenSuccess:successBlock whenError:errorBlock] ;
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
    
}

-(void)userWithAccessToken:(NSString *)accessToken followUser:(User *)user whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:accessToken forKey:@"oauth_token"];
    [parameters setObject:self.clientID forKey:@"client_id"];
    
    // Request all Activities
    [[SoundrocketClient sharedClient] PUT:[NSString stringWithFormat:SCEndPointMeUserOfFollowing,user.id] parameters:parameters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
         
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself userWithAccessToken:accessToken followUser:user whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
    
}
-(void)userWithAccessToken:(NSString *)accessToken unfollowUser:(User *)user whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:accessToken forKey:@"oauth_token"];
    // Request all Activities
    [[SoundrocketClient sharedClient] DELETE:[NSString stringWithFormat:SCEndPointMeUserOfFollowing,user.id] parameters:parameters
                                     success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
         
     }
     
                                     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself userWithAccessToken:accessToken unfollowUser:user whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}
-(void)checkIfUserWithAccessToken:(NSString *)accessToken isFollowingUser:(User *)user whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:accessToken forKey:@"oauth_token"];
    
    // Request all Activities
    [[SoundrocketClient sharedClient] GET:[NSString stringWithFormat:@"https://api.soundcloud.com/me/followings/%@.json",user.id] parameters:parameters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
         
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         if (errorBlock) {
             errorBlock(task,error);
         }
     }];
}

-(void)removeTrack:(Track*)track fromFavoritesForUserWithAccessToke:(NSString*)token
                                         whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                                           whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock{
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:token forKey:@"oauth_token"];
    [[SoundrocketClient sharedClient] DELETE:[NSString stringWithFormat:SCEndPointMeTrackOfFavorites,track.id] parameters:parameters
                                     success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
         
     }
     
                                     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself removeTrack:track fromFavoritesForUserWithAccessToke:token whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

-(void)addTrack:(Track*)track toFavoritesForUserWithAccessToke:(NSString*)token
                                    whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                                      whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:token forKey:@"oauth_token"];
    [[SoundrocketClient sharedClient] PUT:[NSString stringWithFormat:SCEndPointMeTrackOfFavorites,track.id] parameters:parameters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
         
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself addTrack:track toFavoritesForUserWithAccessToke:token whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

-(void)checkIfUserWithAccessToken:(NSString*)accessToken hasFavoritedTrack:(Track*)track
       whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
         whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {

    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:accessToken forKey:@"oauth_token"];
    
    // Request all Activities
    [[SoundrocketClient sharedClient] GET:[NSString stringWithFormat:SCEndPointMeTrackOfFavorites,track.id] parameters:parameters
        success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
         
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself checkIfUserWithAccessToken:accessToken hasFavoritedTrack:track whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

-(void)getUserForAccessToke:(NSString*)accessToken
                whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                  whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:accessToken forKey:@"oauth_token"];
    [[SoundrocketClient sharedClient] GET:SCEndPointMe parameters:paramters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401 && [SRAuthenticator sharedAuthenticator].refreshToken) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself getUserForAccessToke:[SRAuthenticator sharedAuthenticator].authToken whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

#pragma mark - Authenticatiom

-(void)loginWithUsername:(NSString *)userName
             andPassword:(NSString *)password
             whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock
               whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:@"non-expiring" forKey:@"scope"];
    [parameters setObject:@"password" forKey:@"grant_type"];
    [parameters setObject:userName forKey:@"username"];
    [parameters setObject:password forKey:@"password"];
    [parameters setObject:self.clientID forKey:@"client_id"];
    [parameters setObject:self.clientSecret forKey:@"client_secret"];
    [[SoundrocketClient sharedClient] POST:SCEndPointOAuth parameters:parameters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         if (errorBlock) {
             errorBlock(task,error);
         }
     }];
    
}


-(void)loginWithCode:(NSString *)code whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    
    [parameters setObject:@"authorization_code" forKey:@"grant_type"];
    [parameters setObject:@"soundrocket://soundcloud/callback" forKey:@"redirect_uri"];
    [parameters setObject:code forKey:@"code"];
    [parameters setObject:@"non-expiring" forKey:@"scope"];
    [parameters setObject:self.clientID forKey:@"client_id"];
    [parameters setObject:self.clientSecret forKey:@"client_secret"];
    [[SoundrocketClient sharedClient] POST:SCEndPointOAuth parameters:parameters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         if (errorBlock) {
             errorBlock(task,error);
         }
     }];
}


-(void)getAccessTokenWithRefreshToken:(NSString*)refreshToken
                          whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                            whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {

    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    
    [parameters setObject:@"refresh_token" forKey:@"grant_type"];
    [parameters setObject:refreshToken forKey:@"refresh_token"];
    [parameters setObject:@"non-expiring" forKey:@"scope"];
    [parameters setObject:self.clientID forKey:@"client_id"];
    [parameters setObject:self.clientSecret forKey:@"client_secret"];
    
    [[SoundrocketClient sharedClient] POST:SCEndPointOAuth parameters:parameters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         if (errorBlock) {
             errorBlock(task,error);
         }
     }];
    
}

#pragma mark - Reposting

-(void)repostTrack:(Track*)track
       whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
         whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if ([SRAuthenticator sharedAuthenticator].authToken) {
        [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
        
    } else {
        [parameters setObject:[defaults objectForKey:@"access_token"] forKey:@"oauth_token"];
    }

    [parameters setObject:self.clientID forKey:@"client_id"];
    [parameters setObject:self.clientSecret forKey:@"client_secret"];

    NSString * repostURL = [NSString stringWithFormat:SCEndPointRepostTrack,(long)[track.id integerValue]];
    [[SoundrocketClient sharedClient] PUT:repostURL parameters:parameters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself repostTrack:track whenSuccess:successBlock whenError:errorBlock]  ;
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
    
}

#pragma mark - Resolve Actions 

-(void)resolveURL:(NSString *)resolve whenSuccess:(void (^)(NSURLSessionDataTask *, id))successBlock whenError:(void (^)(NSURLSessionDataTask *, NSError *))errorBlock {
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    
    if ([SRAuthenticator sharedAuthenticator].authToken) {
        [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
        
    } else {
        [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"] forKey:@"oauth_token"];
    }
    
    [parameters setObject:self.clientID forKey:@"client_id"];
    [parameters setObject:resolve forKey:@"url"];
    [[SoundrocketClient sharedClient] GET:SCEndpointResolve parameters:parameters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself resolveURL:resolve whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}


#pragma mark - Track Again
-(void)getSamplesFromTrack:(Track*)track
               whenSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))successBlock
                 whenError:(void (^)(NSURLSessionDataTask *task, NSError *error))errorBlock {
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    if ([SRAuthenticator sharedAuthenticator].authToken) {
        [parameters setObject:[SRAuthenticator sharedAuthenticator].authToken forKey:@"oauth_token"];
        
    } else {
        [parameters setObject:[defaults objectForKey:@"access_token"] forKey:@"oauth_token"];
    }
    
    NSString * waveform_url = [self getWaveFormUrlForTrack:(Track*)track];
    [[SoundrocketClient sharedClient] GET:waveform_url parameters:paramters
                                  success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if (successBlock) {
             successBlock(task,responseObject);
         }
     }
     
                                  failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         
         __weak __block __typeof(self) weakself = self;
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         NSInteger statuscode = response.statusCode;
         if (statuscode == 401) {
             [[SRAuthenticator sharedAuthenticator]reauthenticateWithCompletion:^(){
                 [weakself getSamplesFromTrack:track whenSuccess:successBlock whenError:errorBlock];
             } failure:^(){
                 if (errorBlock) {
                     errorBlock(task,error);
                 }
             }];
         } else {
             if (errorBlock) {
                 errorBlock(task,error);
             }
         }
     }];
}

#pragma mark - Helper 

-(NSString*)getWaveFormUrlForTrack:(Track*)track {
    
    NSString *stringURL = track.waveform_url;
    NSURL *url = [NSURL URLWithString:stringURL];
    NSString *path = [url path];
    NSString *extension = [path pathExtension];
    
    if ([extension isEqualToString:@"json"]) {
        return track.waveform_url;
    }
    
    else {
        NSString * lastPath = [path lastPathComponent];
        NSString * lastPathWithOutExtension = [lastPath stringByReplacingOccurrencesOfString:[lastPath pathExtension]withString:@""];
        return [NSString stringWithFormat:@"https://wis.sndcdn.com/%@json",lastPathWithOutExtension];
    }
}

@end
