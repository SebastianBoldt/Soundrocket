//
//  SRStore.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 02.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

@interface SRStore : NSObject
+(void)storeStrackToHistory:(Track*)track;
+(void)loadHistoryWithCompletion:(void(^)(NSMutableArray*tracksOfHistory))success;
+(void)clearHistory;
@end
