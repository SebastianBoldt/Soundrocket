//
//  SRFactory.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 14.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import "SRFactory.h"

@implementation SRFactory
+(id)createObjectFromDictionary:(NSDictionary*)dictionary {
        if ([[dictionary objectForKey:@"type"] isEqualToString:@"track"]) {
            Track * track = [[Track alloc]initWithDictionary:[dictionary objectForKey:@"origin"] error:nil];
            if(track){
                return track;            }
        } else if ([[dictionary objectForKey:@"type"] isEqualToString:@"track-repost"]) {
            TrackRepost * trackRepost = [[TrackRepost alloc]initWithDictionary:[dictionary objectForKey:@"origin"] error:nil];
            if(trackRepost){
                return trackRepost;            }
            
        } else if ([[dictionary objectForKey:@"type"] isEqualToString:@"playlist"]) {
            //Playlist * playlist;
            Playlist  * playlist= [[Playlist alloc]initWithDictionary:[dictionary objectForKey:@"origin"] error:nil];
            if(playlist){
                return playlist;
            }
        } else if ([[dictionary objectForKey:@"type"] isEqualToString:@"playlist-repost"]) {
            PlaylistRepost  * playlistRepost= [[PlaylistRepost alloc]initWithDictionary:[dictionary objectForKey:@"origin"] error:nil];
            if(playlistRepost){
                return playlistRepost;
            }
        }
    return nil;
}

+(Track*)createTrackFromDictionary:(NSDictionary*)dictionary {
    return [[Track alloc] initWithDictionary:dictionary error:nil];
}

+(Playlist*)createPlaylistFromDictionary:(NSDictionary*)dictionary {
    return [[Playlist alloc] initWithDictionary:dictionary error:nil];
}

+(User*)createUserFromDictionary:(NSDictionary*)dictionary {
    return [[User alloc] initWithDictionary:dictionary error:nil];
}

+(Comment*)createCommentFromDictionary:(NSDictionary*)dictionary{
    return [[Comment alloc] initWithDictionary:dictionary error:nil];
}
@end
