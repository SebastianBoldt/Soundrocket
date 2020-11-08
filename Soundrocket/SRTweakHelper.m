//
//  SRTweakHelper.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 01.02.16.
//  Copyright © 2016 sebastianboldt. All rights reserved.
//

#import "SRTweakHelper.h"
#import "SRAuthenticator.h"
#import <FBTweakInline.h>

@implementation SRTweakHelper
-(void)setupTweaks {
    FBTweakAction(@"Authenticator", @"Tests", @"Invalidate Authtoken", ^{
        [[SRAuthenticator sharedAuthenticator] storeAuthTokenToDefaults:@"fdsafdasf"];
        [[SRAuthenticator sharedAuthenticator] setAuthToken:@"fdsafdasf"];
    });
    
    FBTweakAction(@"Authenticator", @"Tests", @"Clear Authtoken", ^{
        [[SRAuthenticator sharedAuthenticator] storeAuthTokenToDefaults:nil];
        [[SRAuthenticator sharedAuthenticator] setAuthToken:nil];
    });
    
    FBTweakAction(@"Soundrocket Pro", @"Tests", @"Enable Soundrocket Pro", ^{
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"SoundrocketPro"];
        [defaults synchronize];
    });
    
    FBTweakAction(@"Soundrocket Pro", @"Tests", @"Disable Soundrocket Pro", ^{
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:@"SoundrocketPro"];
        [defaults synchronize];
    });
}
@end
