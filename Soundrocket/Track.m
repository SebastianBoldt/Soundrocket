//
//  Track.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "Track.h"
#import "TrackRepost.h"
@implementation Track
-(instancetype)initWithTrackRespost:(TrackRepost*)respost{
    if (self = [super init]) {
        _artwork_url = respost.artwork_url;
        _user = respost.user;
        _waveform_url = respost.waveform_url;
        _title = respost.title;
        _playback_count = respost.playback_count;
        _stream_url = respost.stream_url;
        _duration = respost.duration;
        _id = respost.id;
        _streamable = respost.streamable;
        _comment_count = respost.comment_count;
        _favoritings_count = respost.favoritings_count;
        _permalink_url = respost.permalink_url;
        _downloadable = respost.downloadable;
        _created_at = respost.created_at;
        _download_url = respost.download_url;
        _reposts_count= respost.reposts_count;
        _descriptionText = respost.descriptionText;
        _likes_count = respost.likes_count;
    }
    return  self;
}

// Storing class to NSUSerDefaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.artwork_url forKey:@"artwork_url"];
    [encoder encodeObject:self.likes_count forKey:@"likes_count"];
    [encoder encodeObject:self.user forKey:@"user"];
    [encoder encodeObject:self.waveform_url forKey:@"waveform_url"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.playback_count forKey:@"playback_count"];
    [encoder encodeObject:self.stream_url forKey:@"stream_url"];
    [encoder encodeObject:self.duration forKey:@"duration"];
    [encoder encodeObject:self.id forKey:@"id"];
    [encoder encodeBool:self.streamable forKey:@"streamable"];
    [encoder encodeObject:self.comment_count forKey:@"comment_count"];
    [encoder encodeObject:self.favoritings_count forKey:@"favoritings_count"];
    [encoder encodeObject:self.permalink_url forKey:@"permalink_url"];
    [encoder encodeBool:self.downloadable forKey:@"downloadable"];
    [encoder encodeObject:self.created_at forKey:@"created_at"];
    [encoder encodeObject:self.download_url forKey:@"download_url"];
    [encoder encodeObject:self.local_path forKey:@"local_path"];
    [encoder encodeObject:self.reposts_count forKey:@"reposts_count"];
    [encoder encodeObject:self.descriptionText forKey:@"description_text"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.artwork_url = [decoder decodeObjectForKey:@"artwork_url"];
        self.likes_count = [decoder decodeObjectForKey:@"likes_count"];
        self.user = [decoder decodeObjectForKey:@"user"];
        self.waveform_url =[decoder decodeObjectForKey:@"waveform_url"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.playback_count = [decoder decodeObjectForKey:@"playback_count"];
        self.stream_url = [decoder decodeObjectForKey:@"stream_url"];
        self.duration = [decoder decodeObjectForKey:@"duration"];
        self.id  = [decoder decodeObjectForKey:@"id"];
        self.streamable = [decoder decodeBoolForKey:@"streamable"];
        self.comment_count = [decoder decodeObjectForKey:@"comment_count"];
        self.favoritings_count = [decoder decodeObjectForKey:@"favoritings_count"];
        self.permalink_url = [decoder decodeObjectForKey:@"permalink_url"];
        self.downloadable = [decoder decodeBoolForKey:@"downloadable"];
        self.created_at = [decoder decodeObjectForKey:@"created_at"];
        self.download_url = [decoder decodeObjectForKey:@"download_url"];
        self.local_path = [decoder decodeObjectForKey:@"local_path"];
        self.reposts_count = [decoder decodeObjectForKey:@"reposts_count"];
        self.descriptionText = [decoder decodeObjectForKey:@"description_text"];

    }
    return self;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    if ([propertyName isEqualToString: @"downloaded"]) return YES;
    return NO;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        self.descriptionText = value;
    } else {
        [super setValue:value forKey:key];
    }
}
@end
