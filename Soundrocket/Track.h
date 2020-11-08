//
//  Track.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <JSONModel.h>
#import "User.h"
#import "TrackRepost.h"

@interface Track : JSONModel

@property (nonatomic,strong) User<Optional> * user;
@property (nonatomic,strong) NSString<Optional> * artwork_url;
@property (nonatomic,strong) NSString<Optional> * created_at;
@property (nonatomic,strong) NSString<Optional> * directory_path; // This path isnt nil if file is available offlien on device
@property (nonatomic,strong) NSString<Optional> * uri;
@property (nonatomic,strong) NSString<Optional> * permalink_url;
@property (nonatomic,strong) NSString<Optional> * descriptionText;
@property (nonatomic,strong) NSString<Optional> * waveform_url;
@property (nonatomic,strong) NSString<Optional> * title;
@property (nonatomic,strong) NSString<Optional> * stream_url;
@property (nonatomic,strong) NSNumber<Optional> * playback_count;
@property (nonatomic,strong) NSNumber<Optional> * comment_count;
@property (nonatomic,strong) NSNumber<Optional> * favoritings_count;
@property (nonatomic,strong) NSNumber<Optional> * likes_count;
@property (nonatomic,strong) NSNumber<Optional> * id;
@property (nonatomic,strong) NSNumber<Optional> * duration;
@property (nonatomic,strong) NSString<Optional> * download_url;
@property (nonatomic,strong) NSString<Optional> * local_path;
@property (nonatomic,strong) NSNumber<Optional> *reposts_count;

@property (nonatomic,assign) BOOL downloadable;
@property (nonatomic,assign) BOOL streamable;

-(instancetype)initWithTrackRespost:(TrackRepost*)respost;

@end
