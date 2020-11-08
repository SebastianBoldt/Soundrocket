//
//  URLParser.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 22.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "URLParser.h"

@implementation URLParser

- (id) initWithURLString:(NSString *)url{
    self = [super init];
    if (self != nil) {
        if ((url != nil) && ([url class] != [NSNull class])) {
            NSString *string = url;
            NSScanner *scanner = [NSScanner scannerWithString:string];
            [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
            NSString *tempString;
            NSMutableArray *vars = [NSMutableArray new];
            [scanner scanUpToString:@"?" intoString:nil];       //ignore the beginning of the string and skip to the vars
            while ([scanner scanUpToString:@"&" intoString:&tempString]) {
                [vars addObject:[tempString copy]];
            }
            self.variables = vars;
        }
    }
    return self;
}

- (NSString *)valueForVariable:(NSString *)varName {
    for (NSString *var in self.variables) {
        if ([var length] > [varName length]+1 && [[var substringWithRange:NSMakeRange(0, [varName length]+1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[varName length]+1];
            return varValue;
        }
    }
    return nil;
}

@end