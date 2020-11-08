//
//  SoundrocketTests.m
//  SoundrocketTests
//
//  Created by Sebastian Boldt on 23.09.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SoundCloudAPI.h"   

@interface SoundrocketTests : XCTestCase

@end

@implementation SoundrocketTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testSoundcloudApiLogin {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Soundcloud Tests"];
    
    [[SoundCloudAPI sharedApi]loginWithUsername:@"iamtherealhare@googlemail.com" andPassword:@"nlights" whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
     {
         [expectation fulfill];
     }
     
    whenError:^(NSURLSessionDataTask *task, NSError *error)
     {
         XCTFail(@"Soundcloud API did no login");
     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        NSLog(@"Soundcloud should login %@",error.localizedDescription);
    }];
}

- (void)testSoundcloudReturnsAccessToken {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"token provided by soundcloud api"];

    [[SoundCloudAPI sharedApi]loginWithUsername:@"iamtherealhare@googlemail.com" andPassword:@"nlights" whenSuccess:^(NSURLSessionDataTask *task, id responseObject)
     {
         if (responseObject) {
             NSString * authToken = [responseObject objectForKey:@"access_token"];
             if (!authToken) {
                 XCTFail(@"No token provided by soundcloud API");
             } else {
                 [expectation fulfill];
             }
         }
     }
     
     whenError:^(NSURLSessionDataTask *task, NSError *error)
     {
         XCTFail(@"Soundcloud API does not return token");
     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        NSLog(@"Soundcloud API should return token %@",error.localizedDescription);
    }];
    
}
@end
