//
//  RomoClient.h
//  RomoApp
//
//  Created by Sebastian Boldt on 29.04.14.
//  Copyright (c) 2014 Sebastian Boldt. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface SoundrocketClient : AFHTTPSessionManager
+ (instancetype)sharedClient;
@end
