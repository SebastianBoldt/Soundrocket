//
//  PlaylistRespost.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "JSONModel.h"
#import "User.h"

@interface PlaylistRepost : JSONModel

@property (nonatomic,strong) NSString<Optional> * title;
@property (nonatomic,strong) NSString<Optional> * avatar_url;
@property (nonatomic,strong) NSString<Optional> * artwork_url;
@property (nonatomic,strong) User<Optional> * user;
@property (nonatomic,strong) NSString<Optional> * url;
@property (nonatomic,strong) NSString<Optional> * sharing;
@property (nonatomic,strong) NSNumber<Optional> * track_count;
@property (nonatomic,strong) NSString<Optional> * tracks_uri;
@property (nonatomic,strong) NSNumber<Optional> * user_id;
@property (nonatomic,strong) NSString<Optional> * uri;
@property (nonatomic,strong) NSString<Optional> * permalink_url;
@property (nonatomic,strong) NSString<Optional> * created_at;

@end
