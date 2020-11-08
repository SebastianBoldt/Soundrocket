//
//  Comment.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "JSONModel.h"
#import "User.h"
@interface Comment : JSONModel

@property (nonatomic,strong)NSString<Optional> * type;
@property (nonatomic,strong)NSString<Optional> * body;
@property (nonatomic,strong)NSNumber<Optional> * timestamp;
@property (nonatomic,strong)NSNumber<Optional> * id;
@property (nonatomic,strong)User<Optional> * user;

@end
