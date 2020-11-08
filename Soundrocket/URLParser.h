//
//  URLParser.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 22.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject 
@property (nonatomic, retain) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end
