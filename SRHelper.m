//
//  SRHelper.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 06.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "SRHelper.h"
#import <CRToast.h>
#import "SRStylesheet.h"
@implementation SRHelper
+(void)showNotStreamableNotification {
    NSDictionary *options = @{
                              kCRToastTextKey : NSLocalizedString(@"This track is not streamable", nil),
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [SRStylesheet redColor],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}

+(void)showGeneralError {
    NSDictionary *options = @{
                              kCRToastTextKey : NSLocalizedString(@"Something went wrong, please try again", nil),
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [SRStylesheet redColor],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}

+(void)showError:(NSString*)message {
    NSDictionary *options = @{
                              kCRToastTextKey : NSLocalizedString(@"Something went wrong, please try again", nil),
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [SRStylesheet redColor],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}


@end

static const void* SRRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void SRReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* SRCreateNonRetainingArray() {
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = SRRetainNoOp;
    callbacks.release = SRReleaseNoOp;
    return (NSMutableArray*)CFBridgingRelease(CFArrayCreateMutable(nil, 0, &callbacks));
}