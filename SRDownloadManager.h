//
//  SRDownloadManager.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 30.05.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

/**
 *  This class is responsible for downloading tracks
 */
@interface SRDownloadManager : NSObject
/*
-(void)downloadFileForURL:(NSString*)string
        withProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) progressBlock
andCompletionBlockForSuccess:(void(^)(AFHTTPRequestOperation *operation, id responseObject)) successBlockBlock andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock directory:(NSString*)directory;


// Returns a shared Singleton Class Instance
+(SRDownloadManager *)sharedManager;

// Array of downloaded tracks
-(NSMutableArray*)downloadedTracks;

// Saves a Track to NSUserDefaults
-(void)saveTrack:(Track *)track key:(NSString *)key;

// Pause current Download Operation
-(void)pauseOperation;

// Resume current Download Operation
-(void)resumeOperation;

// Cancel Current Download Operation
-(void)cancelOperation;

// Removes Track from NSUserDefaults and Harddrive
-(BOOL)removeTrack:(Track*)trackToDelete;*/
@end
