//
//  SRStylesheet.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 13.03.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

// red [UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:0.880];
#import "SRStylesheet.h"

@implementation SRStylesheet
+(UIColor*)mainColor{
    return [UIColor colorWithRed:0.100 green:0.771 blue:0.530 alpha:1.000];
}

+(UIColor*)darkGrayColor{
    return [UIColor darkGrayColor];
}

+(UIColor*)lightGrayColor{
    return [UIColor lightGrayColor];
}

+(UIColor*)whiteColor{
    return [UIColor whiteColor];
}

+(UIColor*)redColor{
    return [UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:1.000];
}
@end
