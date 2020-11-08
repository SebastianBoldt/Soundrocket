//
//  SRDownloadManager.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 30.05.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

// Downloads are stored in an Array of Dictionarys: [@{path: track},@{path,track}]
#import <SVProgressHUD.h>
#import "SRDownloadManager.h"
#import <AFHTTPRequestOperation.h>
#import "SRAuthenticator.h"

@interface SRDownloadManager()
@property(nonatomic,strong)AFHTTPRequestOperation *currentOperation;

@end
@implementation SRDownloadManager

+ (instancetype)sharedManager {
    static SRDownloadManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Init Stuff
        _sharedManager = [[SRDownloadManager alloc]init];
    });
    return _sharedManager;
}


-(void)downloadFileForURL:(NSString*)string
        withProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) progressBlock
andCompletionBlockForSuccess:(void(^)(AFHTTPRequestOperation *operation, id responseObject)) successBlockBlock andFailure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock directory:(NSString *)directory {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@",string,[SRAuthenticator sharedAuthenticator].authToken]];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.currentOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [self.currentOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:directory append:NO]];
    [self.currentOperation setDownloadProgressBlock:progressBlock];
    [self.currentOperation setCompletionBlockWithSuccess:successBlockBlock failure:failureBlock];
    [self.currentOperation start];
}

- (void)saveTrack:(Track *)track key:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * tracks = nil;
    if([[defaults objectForKey:@"downloaded_tracks"]isKindOfClass:[NSMutableArray class]]){
        tracks = [[defaults objectForKey:@"downloaded_tracks"]mutableCopy];
    } else {
        tracks = [[NSMutableArray alloc]init];
    }
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:track];
    [tracks addObject:encodedObject];
    [defaults setObject:tracks forKey:@"downloaded_tracks"];
    [defaults synchronize];
    
}

-(NSMutableArray*)downloadedTracks {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * downloadedTracks = [[NSMutableArray alloc]init];
    if ([[defaults objectForKey:@"downloaded_tracks"]isKindOfClass:[NSMutableArray class]]){
        NSMutableArray * tracksFromDefaults = [[defaults objectForKey:@"downloaded_tracks"]mutableCopy];
        for (NSData * data in tracksFromDefaults) {
            Track *track = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [downloadedTracks addObject:track];
        }
    }
    return downloadedTracks;
}

-(void)pauseOperation {
    [self.currentOperation pause];
}

-(void)resumeOperation {
    [self.currentOperation resume];
}

-(void)cancelOperation {
    [self.currentOperation cancel];
}

-(BOOL)removeTrack:(Track *)trackToDelete {
    NSError * error = nil;
    BOOL success = [[NSFileManager defaultManager]removeItemAtPath:trackToDelete.local_path error:&error];
    
    if (success) {
        NSMutableArray * tracks = [self downloadedTracks];
        NSMutableArray * tracksCopy = [tracks mutableCopy];
        for (Track* track in tracksCopy) {
            if ([trackToDelete.id doubleValue] == [track.id doubleValue]) {
                [tracks removeObject:track];
            }
        }
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray * archivedTracks = [[NSMutableArray alloc]init];
        for (Track * track in tracks) {
            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:track];
            [archivedTracks addObject:encodedObject];
        }
        [defaults setObject:archivedTracks forKey:@"downloaded_tracks"];
        [defaults synchronize];
    } else {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Something went wrong: %@",error.localizedDescription]];
    }
    
    return success;
}
@end
