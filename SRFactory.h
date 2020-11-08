//
//  SRFactory.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 14.06.15.
//  Copyright © 2015 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRBaseObjects.h"

@interface SRFactory : NSObject
+(id)createObjectFromDictionary:(NSDictionary*)dictionary;

// If we know that just tracks arrive we can use this convenience methods
+(Track*)       createTrackFromDictionary:      (NSDictionary*)dictionary;
+(Playlist*)    createPlaylistFromDictionary:   (NSDictionary*)dictionary;
+(User*)        createUserFromDictionary:       (NSDictionary*)dictionary;
+(Comment*)     createCommentFromDictionary:       (NSDictionary*)dictionary;

@end
