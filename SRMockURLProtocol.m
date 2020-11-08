//
//  SRMockURLProtocol.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 01.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRMockURLProtocol.h"

@implementation SRMockURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    
    if ([[request HTTPMethod] isEqualToString:@"GET"] && [request.URL.host isEqualToString:@"api.soundcloud.com"]) {
        NSLog(@"\n*******Mocked Request for %@\n",request.URL.host);
        if ([request.URL.path isEqualToString:@"/me.json"]) {
            return YES;
        } else if ([request.URL.path isEqualToString:@"/me/activities.json"]){
            return YES;
        } else if ([request.URL.path isEqualToString:@"/users/79981.json"]){
            return YES;
        } else if ([request.URL.path isEqualToString:@"/users/79981/tracks.json"]){
            return YES;
        } else if ([request.URL.path isEqualToString:@"/users/79981/playlists.json"]){
            return YES;
        }
    }
    return NO;
}

// Manipulate Request
+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

-(void)startLoading
{
    id <NSURLProtocolClient> client = self.client;
    NSURLRequest *request = self.request;
    
    NSDictionary *headers = @{ @"Content-Type": @"application/json" };
    NSURL * jsonFileURL = [self getURLForRequest:request];

    NSData * jsonData = [NSData dataWithContentsOfURL:jsonFileURL];
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:headers];
    
    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:jsonData];
    [client URLProtocolDidFinishLoading:self];
}

-(void)stopLoading
{
    // We send all the data at once, so there is nothing to do here.
}

-(NSURL*)getURLForRequest:(NSURLRequest*)request {
    if ([request.URL.path isEqualToString:@"/me.json"]) {
        return [[NSBundle mainBundle] URLForResource:@"me" withExtension:@"json"];
    } else if ([request.URL.path isEqualToString:@"/me/activities.json"]){
        return [[NSBundle mainBundle] URLForResource:@"activities" withExtension:@"json"];
    } else if ([request.URL.path isEqualToString:@"/users/79981.json"]){
        return [[NSBundle mainBundle] URLForResource:@"me" withExtension:@"json"];
    } else if ([request.URL.path isEqualToString:@"/users/79981/tracks.json"]){
        return [[NSBundle mainBundle] URLForResource:@"my-tracks" withExtension:@"json"];
    } else if ([request.URL.path isEqualToString:@"/users/79981/playlists.json"]){
        return [[NSBundle mainBundle] URLForResource:@"my-playlists" withExtension:@"json"];
    }
    else return nil;
}
@end
