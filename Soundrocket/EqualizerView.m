//
//  SoundIsPlayingView.m
//  AnimationView
//
//  Created by Sebastian Boldt on 29.03.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "EqualizerView.h"
#import <UIKit/UIKit.h>
#import "SRStylesheet.h"
#define ARC4RANDOM_MAX      0x100000000
#define numberOfBars 20
#define padding 2
@interface EqualizerView()
@property (nonatomic,strong) NSMutableArray * bars;
@property (nonatomic,assign) CGFloat velocity;
@end
@implementation EqualizerView


-(void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}
-(instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return  self;
}
-(void)removeAllSubViews {
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
}

-(void)layoutSubviews {
    [self setup];
}

-(void)initColors {
    for (UIView * barView in self.bars) {
        barView.backgroundColor = [SRStylesheet mainColor];
    }
}

-(void)setup {
    [self stop];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initColors)
                                                 name:@"appColorChanged" object:nil];
    [self removeAllSubViews];
    self.backgroundColor = [UIColor clearColor];
    self.velocity = self.frame.size.height / 2;
    self.bars = [[NSMutableArray alloc]init];
    for (int i = 0; i <20; i++) {
        UIView * barView = [[UIView alloc]initWithFrame:CGRectMake(padding+(self.frame.size.width/numberOfBars*i), 0, self.frame.size.width/numberOfBars -padding, self.frame.size.height)];
        if (self.color) {
            barView.backgroundColor = self.color;
        } else {
            barView.backgroundColor = [SRStylesheet mainColor];
        }
        [self addSubview:barView];
        [self.bars addObject:barView];
    }
    
    [self startAnimation];
    
}
-(void)startAnimation {
    __weak __block __typeof(self) weakself = self;

    for (int i = 0; i <20; i++) {
        double val = 0.03*i;
         [UIView animateWithDuration:0.5 delay:val options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^(){
            UIView * currenbarView = [self.bars objectAtIndex:i];
            currenbarView.frame = CGRectMake(currenbarView.frame.origin.x,currenbarView.frame.origin.y+weakself.velocity,currenbarView.frame.size.width,currenbarView.frame.size.height-self.velocity);
            
         } completion:nil];
    }
    
}
-(void)start {
    [self stop];
    for (UIView * view in self.subviews) {
            [self resumeLayer:view.layer];
    }
}
-(void)stop {
    for (UIView * view in self.subviews) {
        [self pauseLayer:view.layer];
    }
    
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

-(instancetype)initWithColor:(UIColor*)color {
    if (self = [super init]) {
        if (color) {
            self.color = color;
        } else {
            self.color = [SRStylesheet mainColor];
        }
    }
    
    return  self;
}


@end
