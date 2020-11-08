//
//  SRAuthenticator.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 13.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//
#import <Mixpanel/Mixpanel.h>
#import <FBTweakInline.h>

#import "SRAuthenticator.h"
#import "SoundrocketClient.h"
#import "SRHelper.h"    
#import "SRPlayer.h"
#import "SoundCloudAPI.h"
#import "PlayerViewController.h"

// Constants
#define SERVICE_NAME @"Soundcloud"
#define AUTH_TOKEN_KEY @"auth_token"
#define REFRESH_TOKEN_KEY @"refresh_token"

NSString * const cNonExpiringKey = @"non-expiring";

@interface SRAuthenticator()
@property   (nonatomic,strong)  NSMutableArray   * delegates;
@property   (nonatomic,assign)  NSInteger numberOfRetries;
@end

@implementation SRAuthenticator

// Singleton method that returns unique instance
+ (instancetype)sharedAuthenticator {
    static SRAuthenticator *_sharedAuthenticator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Init Stuff
        _sharedAuthenticator = [[SRAuthenticator alloc]init];
        _sharedAuthenticator.delegates = SRCreateNonRetainingArray();
        _sharedAuthenticator.numberOfRetries = 0;
    });
    return _sharedAuthenticator;
}

#pragma mark - Authentication 

// Tries to authenticate with username and password
// If things are successful the authenticator fetches for the actual user data and informs the delegates if he finishes

-(void)authenticateUserForEmailOrUsername:(NSString *)usernameOrEmail andPassword:(NSString *)password {
    __block __weak SRAuthenticator * weakSelf = self;
    
    [[SoundCloudAPI sharedApi]loginWithUsername:usernameOrEmail andPassword:password whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSString * authToken = [responseObject objectForKey:@"access_token"];
        [weakSelf storeAuthTokenToDefaults:authToken];
        [weakSelf storeRefreshTokenToDefaults:cNonExpiringKey];
        [weakSelf getUserData];
    }
     
    whenError:^(NSURLSessionDataTask *task, NSError *error)
    {
        for (id<SRAuthenticatorDelegate> delegate in weakSelf.delegates) {
            if ([delegate respondsToSelector:@selector(authenticator:didNotAuthenticateWithError:)]) {
                [delegate authenticator:weakSelf didNotAuthenticateWithError:error];
            }
        }
    }];

}

-(void)authenticateUsingCode:(NSString *)code {
    
    __weak __block __typeof(self) weakself = self;
    
    [[SoundCloudAPI sharedApi]loginWithCode:code whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSString * authToken = [responseObject objectForKey:@"access_token"];
        NSString * refreshToken = [responseObject objectForKey:@"refresh_token"];
        
        [weakself storeAuthTokenToDefaults:authToken];
        [weakself storeRefreshTokenToDefaults:refreshToken];
        
        [weakself getUserData];
    }
    
    whenError:^(NSURLSessionDataTask *task, NSError *error)
    {
        for (id<SRAuthenticatorDelegate> delegate in weakself.delegates) {
            if ([delegate respondsToSelector:@selector(authenticator:didNotAuthenticateWithError:)]) {
                [delegate authenticator:weakself didNotAuthenticateWithError:error];
            }
        }
    }];
}

-(void)reauthenticateWithCompletion:(dispatch_block_t)success failure:(dispatch_block_t)failure{
    
    __weak __block __typeof(self) weakself = self;
    
    NSString * token = nil;
    
    if(self.refreshToken) {
        token = self.refreshToken;
    } else {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        token = [defaults objectForKey:@"refresh_token"];
    }
    
    if (!token) {
        NSError * error = [NSError errorWithDomain:@"Soundrocket" code:2000 userInfo:@{NSLocalizedDescriptionKey:@"Refresh Token invalid"}];
        for (id<SRAuthenticatorDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(authenticator:didNotAuthenticateWithError:)]) {
                [delegate authenticator:weakself didNotAuthenticateWithError:error];
            }
        }
        return;
    }
    
    
    [[SoundCloudAPI sharedApi]getAccessTokenWithRefreshToken:token whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSString * authToken = [responseObject objectForKey:@"access_token"];
        NSString * refreshToken = [responseObject objectForKey:@"refresh_token"];
        
        [self storeAuthTokenToDefaults:authToken];
        [self storeRefreshTokenToDefaults:refreshToken];
        
        for (id<SRAuthenticatorDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(authenticatorDidReauthenticateWithCurrentUser:)]) {
                [delegate authenticatorDidReauthenticateWithCurrentUser:weakself];
            }
        }
        success();
    }
    
    whenError:^(NSURLSessionDataTask *task, NSError *error)
    {
        if (weakself.numberOfRetries < 3) {
            [weakself reauthenticateWithCompletion:success failure:failure];
            weakself.numberOfRetries++;
        } else {
            failure();
            for (id<SRAuthenticatorDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(authenticator:didNotAuthenticateWithError:)]) {
                    [delegate authenticator:weakself didNotAuthenticateWithError:error];
                }
            }
            weakself.numberOfRetries = 0;
        }
    }];
}

-(void)getUserData {
    
    __block __weak SRAuthenticator * weakSelf = self;
    [[SoundCloudAPI sharedApi]getUserForAccessToke:self.authToken whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSError * error = nil;
        User *currentUser = [[User alloc]initWithDictionary:responseObject error:&error];
        self.currentUser = currentUser;
        [[Mixpanel sharedInstance] identify:[currentUser.id stringValue]];
        for (id<SRAuthenticatorDelegate> delegate in self.delegates) {
            [delegate authenticatorDidAuthenticate:weakSelf withUser:weakSelf.currentUser];
        }
    }
    
    whenError:^(NSURLSessionDataTask *task, NSError *error)
    {
        __weak __block __typeof(self) weakself = self;
        for (id<SRAuthenticatorDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(authenticator:didNotAuthenticateWithError:)]) {
                [delegate authenticator:weakself didNotAuthenticateWithError:error];
            }
        }
    }];
}

#pragma mark - Deleagte management 

-(void)addDelegate:(id<SRAuthenticatorDelegate>)delegate{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}
-(void)removeDelegate:(id)delegate{
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

#pragma mark Token Storage

// Stores Token to NSUserDefaults cause this app need to have it if app runs in background

-(void)storeAuthTokenToDefaults:(NSString*)token {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if (token) {
        [defaults setObject:token forKey:@"access_token"];
    } else {
        [defaults removeObjectForKey:@"access_token"];

    }
    
    [defaults synchronize];
}
-(void)setAuthToken:(NSString*)token {
    [self storeAuthTokenToDefaults:token];
}
-(void)storeRefreshTokenToDefaults:(NSString*)token {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"refresh_token"];
    [defaults synchronize];
}

-(void)removeTokenFromDefaults {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"access_token"];
    [defaults synchronize];
}

-(void)removeRefreshTokenFromDefaults {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"refresh_token"];
    [defaults synchronize];
}

// Checks if authtoken is set
- (BOOL)isLoggedIn {
    if (self.authToken) {
        [[NSUserDefaults standardUserDefaults]setObject:self.authToken forKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        return YES;
    } else {
        return NO;
    }
}

// Deletes the current token
- (void)clearSavedCredentials {
    [self removeTokenFromDefaults];
    [self removeRefreshTokenFromDefaults];
}

-(void)logout {
    // Do the Logout Stuff
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [self removeTokenFromDefaults];
    [self removeRefreshTokenFromDefaults];
    
    [defaults synchronize];
    [[PlayerViewController sharedPlayerViewController] unsubScribe]; // Dont forget because iOS8 will Crash
    // Call every delegate that you logged out
    self.currentUser = nil;
    [[SRPlayer sharedPlayer]saveStreamingID:nil];
    [self clearSavedCredentials];
    
    for (id<SRAuthenticatorDelegate> delegate in self.delegates) {
        __weak __block __typeof(self) weakself = self;

        if ([delegate respondsToSelector:@selector(authenticatorDidLogout:)]) {
            [delegate authenticatorDidLogout:weakself];
        }
    }
}

-(NSString *)refreshToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"refresh_token"];
}

-(NSString *)authToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"access_token"];
}

@end
