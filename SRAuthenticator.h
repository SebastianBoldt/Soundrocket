//
//  SRAuthenticator.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 13.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

extern NSString * const cNonExpiringKey;

@class SRAuthenticator;

@protocol SRAuthenticatorDelegate <NSObject>

@optional

- (void) authenticatorDidAuthenticate:(SRAuthenticator*)authenticator withUser:(User*) user;

- (void) authenticator:(SRAuthenticator*) authenticator didNotAuthenticateWithError:(NSError*) error;

- (void) authenticatorDidReauthenticateWithCurrentUser:(SRAuthenticator*) authenticator;

- (void) authenticatorDidLogout:(SRAuthenticator*) authenticator;

@end

/**
 *  This class handles the complete Authentication flow using NSURLSession Objects to connect to the Soundcloud server
 *  if the authentication successful or not, it informs hist delegates 
 */

@interface SRAuthenticator : NSObject

@property (nonatomic,strong) User * currentUser;
@property (nonatomic,assign) BOOL isLoggedIn;
@property (nonatomic,assign) BOOL isAuthenticating;


+ (instancetype)sharedAuthenticator;

- (void)authenticateUserForEmailOrUsername:(NSString*)usernameOrEmail andPassword:(NSString*)password;
- (void)authenticateUsingCode:(NSString*)code;
- (void)reauthenticateWithCompletion:(dispatch_block_t)success failure:(dispatch_block_t)failure; // Call this method if there was an 401 error somewhere inside the app, we will try to reauthenticate the user 2 times then

- (BOOL)isLoggedIn;
- (void)logout;

- (NSString *)authToken;
- (NSString *)refreshToken;

- (void)getUserData;

#pragma mark - Delegation

-(void)addDelegate:(id<SRAuthenticatorDelegate>)delegate;
-(void)removeDelegate:(id)delegate;


-(void)storeAuthTokenToDefaults:(NSString*)token;
-(void)storeRefreshTokenToDefaults:(NSString*)token;
-(void)removeTokenFromDefaults;
-(void)removeRefreshTokenFromDefaults;
-(void)setAuthToken:(NSString*)token;

@end
