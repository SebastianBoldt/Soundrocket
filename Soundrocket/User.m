//
//  User.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "User.h"

@implementation User
// Storing class to NSUSerDefaults
- (void)encodeWithCoder:(NSCoder *)encoder {
    
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.avatar_url forKey:@"avatar_url"];
    [encoder encodeObject:self.country forKey:@"country"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.id forKey:@"id"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.public_favorites_count forKey:@"public_favorites_count"];
    [encoder encodeObject:self.track_count forKey:@"track_count"];
    [encoder encodeObject:self.playlist_count forKey:@"playlist_count"];
    [encoder encodeObject:self.followers_count forKey:@"followers_count"];
    [encoder encodeObject:self.followings_count forKey:@"followings_count"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.avatar_url= [decoder decodeObjectForKey:@"avatar_url"];
        self.country =[decoder decodeObjectForKey:@"country"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.id = [decoder decodeObjectForKey:@"id"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.public_favorites_count = [decoder decodeObjectForKey:@"public_favorites_count"];
        self.track_count = [decoder decodeObjectForKey:@"track_count"];
        self.playlist_count = [decoder decodeObjectForKey:@"playlist_count"];
        self.followers_count = [decoder decodeObjectForKey:@"followers_count"];
        self.followings_count = [decoder decodeObjectForKey:@"followings_count"];
    }
    return self;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"description"]) {
        self.descriptionText = value;
    } else {
        [super setValue:value forKey:key];
    }
}
@end
