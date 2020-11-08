//
//  WaveFormView.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 26.05.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Track.h"
@interface WaveFormView : UIView
-(void)setupWithTrack:(Track*)track;
@end
