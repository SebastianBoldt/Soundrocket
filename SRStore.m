//
//  SRStore.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 02.06.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "SRStore.h"

@implementation SRStore
+(void)storeStrackToHistory:(Track*)track{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        NSMutableArray * history =[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"history"]];
        NSMutableIndexSet * setOfIndices = [[NSMutableIndexSet alloc]init];
        for (NSData * historytrack in history) {
            Track  * decodedhistoryTrack = [NSKeyedUnarchiver unarchiveObjectWithData:historytrack];
            if ([decodedhistoryTrack.id floatValue] == [track.id floatValue]) {
                [setOfIndices addIndex:[history indexOfObject:historytrack]];
            }
        }
        [history removeObjectsAtIndexes:setOfIndices];
        
        [history insertObject:[NSKeyedArchiver archivedDataWithRootObject:track] atIndex:0];
        
        [[NSUserDefaults standardUserDefaults] setObject:history forKey:@"history"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}
+(void)loadHistoryWithCompletion:(void(^)(NSMutableArray*tracksOfHistory))success{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray * downloadedTracks = [[NSMutableArray alloc]init];
        if ([[defaults objectForKey:@"history"]isKindOfClass:[NSMutableArray class]]){
            NSMutableArray * tracksFromDefaults = [[defaults objectForKey:@"history"]mutableCopy];
            for (NSData * data in tracksFromDefaults) {
                Track *track = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [downloadedTracks addObject:track];
            }
        }
        if (success) {
            success(downloadedTracks);
        }
    });

}

+(void)clearHistory {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"history"];
    [defaults synchronize];
}

@end
