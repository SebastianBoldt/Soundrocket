//
//  FFXScrollableSegmentedControl.h
//  Fashionfreax
//
//  Created by Sebastian Boldt on 19.11.15.
//  Copyright © 2015 Fashionfreax GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFXScrollableSegmentedControl;

@protocol FFXScrollableSegmentedControlDelegate <NSObject>

-(void)scrollableSegmentedControl:(FFXScrollableSegmentedControl*)control didSelectIndex:(NSInteger)integer;

@end

IB_DESIGNABLE

@interface FFXScrollableSegmentedControl : UIView

@property (nonatomic,strong) IBInspectable NSArray * segments;

@property (nonatomic,weak) id <FFXScrollableSegmentedControlDelegate> delegate;

@property (nonatomic,assign) NSUInteger selectedSegmentIndex;

@end
