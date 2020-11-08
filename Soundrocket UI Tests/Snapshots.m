//
//  Snapshots.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 30.01.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SnapshotHelper.h"  

@interface Snapshots : XCTestCase

@end

@implementation Snapshots

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    XCUIApplication * application = [[XCUIApplication alloc]init];
    
    //application.launchArguments = @[@"--reset-container",@"enableMockupMode",@"shouldLockout"]; // Use this one with fastlane
    application.launchArguments = @[@"enableMockupMode"];

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [application launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}


-(void)testScreenshots {
    
    /**
     Login the user
     */
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.textFields[@"LoginEmailField"] tap];
    [tablesQuery.textFields[@"LoginEmailField"] typeText:@"self.dealloc@googlemail.com"];
    
    XCUIElement *passwordtextfieldSecureTextField = tablesQuery.secureTextFields[@"LoginPasswordField"];
    [passwordtextfieldSecureTextField tap];
    [tablesQuery.secureTextFields[@"LoginPasswordField"] typeText:@"test1234"];
    
    [tablesQuery.buttons[@"SignInButton"] tap];
    sleep(2);
    
    // Tap on the Player
    [[[[app collectionViews]cells]elementBoundByIndex:1] tap];
    sleep(1);
    [app.otherElements[@"Miniplayer"] tap];
    sleep(1);
    [app.otherElements[@"WaveFormView"] swipeRight];
    
    // Make your first Screenshot
    [[[SnapshotHelper alloc]init]snapshot:@"Player" waitForLoadingIndicator:NO];
    
    // Comments Screenshot
    [app.otherElements[@"CommentsView"] swipeRight];
    [[[SnapshotHelper alloc]init]snapshot:@"Comments" waitForLoadingIndicator:NO];
    
    [app.otherElements[@"VisualeffectView"] swipeDown];

    // Activities Screenshot
    [[[SnapshotHelper alloc]init]snapshot:@"Mainlist" waitForLoadingIndicator:NO];
    
    [[[app.navigationBars[@"Stream"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:0] tap];
    sleep(2);
    // Activites Grid Screenshot
    [[[SnapshotHelper alloc]init]snapshot:@"Gridlist" waitForLoadingIndicator:NO];

    [[[[app tabBars]buttons]elementBoundByIndex:4]tap];
    sleep(5);
    [[[SnapshotHelper alloc]init]snapshot:@"Profil" waitForLoadingIndicator:NO];

    // Open Play
}

-(void)testAppstorePreview {
    
    /**
     Login the user
     */
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    // Tapping more button
    [[[[[[app collectionViews]cells]elementBoundByIndex:1]otherElements]objectForKeyedSubscript:@"moreButton"]tap];
    
    // Tap Play Button
    
    [[app.sheets.buttons elementBoundByIndex:0]tap];

    
    [[[app.navigationBars[@"Stream"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:0] tap];
    
    [[[app.navigationBars[@"Stream"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:0] tap];
    
   
    [app.otherElements[@"Miniplayer"] tap];
    
    // Comments Screenshot
    [app.otherElements[@"CommentsView"] swipeRight];
    
    [[[app buttons]objectForKeyedSubscript:@"showCommentsButton"]tap];
    [app.navigationBars[@"Comments"].buttons[@"Done"] tap];
    [app.otherElements[@"VisualeffectView"] swipeDown];
    // Activities Screenshot
    
    // Playlists
    [[[[app tabBars]buttons]elementBoundByIndex:1]tap];
    
    // History
    [[[[app tabBars]buttons]elementBoundByIndex:3]tap];
    
    // Show Profile
    [[[[app tabBars]buttons]elementBoundByIndex:4]tap];
    sleep(3);
}
@end
