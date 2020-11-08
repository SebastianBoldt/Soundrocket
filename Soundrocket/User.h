//
//  User.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "JSONModel.h"

@interface User : JSONModel

@property (nonatomic,strong) NSString<Optional> * avatar_url;

@property (nonatomic,strong) NSString<Optional> * country;

@property (nonatomic,strong) NSString<Optional> * city;

@property (nonatomic,strong) NSString<Optional> * descriptionText;

@property (nonatomic,strong) NSNumber<Optional> *id;

@property (nonatomic,strong) NSString<Optional> * username;

@property (nonatomic,strong) NSNumber<Optional> * public_favorites_count;

@property (nonatomic,strong) NSNumber<Optional> * track_count;

@property (nonatomic,strong) NSNumber<Optional> * playlist_count;

@property (nonatomic,strong) NSNumber<Optional> * followers_count;

@property (nonatomic,strong) NSNumber<Optional> * followings_count;

@end

