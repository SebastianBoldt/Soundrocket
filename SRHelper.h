//
//  SRHelper.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 06.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSMutableArray* SRCreateNonRetainingArray();

@interface SRHelper : NSObject
+(void)showNotStreamableNotification;
+(void)showGeneralError;
+(void)showError:(NSString*)message;
@end
