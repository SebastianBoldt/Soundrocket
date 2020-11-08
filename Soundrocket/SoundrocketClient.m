//
//  RomoClient.m
//  RomoApp
//
//  Created by Sebastian Boldt on 29.04.14.
//  Copyright (c) 2014 Sebastian Boldt. All rights reserved.
//

#import "SoundrocketClient.h"
#import "Soundrocket-SWIFT.h"
#import "SRMockURLProtocol.h"

@interface SoundrocketClient ()
@property (nonatomic, strong) NSString *accessToken;
@end

@implementation SoundrocketClient
+ (instancetype)sharedClient {
	static SoundrocketClient *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AppDelegate * delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                
	    _sharedClient = [[SoundrocketClient alloc] initWithSessionConfiguration:sessionConfiguration];
        _sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
	    _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        
    });
	return _sharedClient;
}

@end
