//
//  FFXScrollableSegmentedControl.m
//  Fashionfreax
//
//  Created by Sebastian Boldt on 19.11.15.
//  Copyright © 2015 Fashionfreax GmbH. All rights reserved.
//

#import "FFXScrollableSegmentedControl.h"
#import <OAStackView/OAStackView.h>
#import "SRStylesheet.h"
#import "UIView+FFXCategory.h"  

// This UIButton will display a black block under the text
@interface FFXSegmentButton : UIButton

@property (nonatomic,strong) UIView * barView;

@property (nonatomic,strong) NSMutableArray * constraints;

@end

@implementation FFXSegmentButton

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.barView.hidden = !selected;
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup {
    self.barView = [[UIView alloc]init];
    self.barView.translatesAutoresizingMaskIntoConstraints = NO;
    self.barView.backgroundColor = [SRStylesheet whiteColor];
    self.barView.hidden = YES;
    [self addSubview:self.barView];
}

-(void)updateConstraints {
    [super updateConstraints];
    if (!_constraints) {
        self.constraints = [[NSMutableArray alloc]init];
        NSDictionary * views = NSDictionaryOfVariableBindings(_barView);
        NSDictionary * metrics = @{@"padding":@(8)};
        [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(padding)-[_barView]-(padding)-|" options:0 metrics:metrics views:views]];
        
        // We just need a top padding so we can apply different bottom padding on the fly
        [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_barView(==2)]|" options:0 metrics:metrics views:views]];
        
        [self addConstraints:_constraints];
    }
}

@end

@interface FFXScrollableSegmentedControl()

@property (nonatomic,strong) NSMutableArray<UIButton*>* buttons;

@property (nonatomic,strong) IBOutlet UIScrollView * scrollView; // ScrollView will automatically change its size to stackViews size

@property (nonatomic,strong) OAStackView * stackView;

@property (nonatomic,strong) UIButton * lastButton;

@end

@implementation FFXScrollableSegmentedControl

-(void)setSegments:(NSArray *)segments {
    for (UIView * view in self.buttons) {
        [self.stackView removeArrangedSubview:view];
    }
    [self.buttons removeAllObjects];
    _segments = segments;
    [self configureViewWithSegments:segments];
}

-(void)configureViewWithSegments:(NSArray*)segments {
    for (NSString * segment in segments) {
        
        FFXSegmentButton * button = [FFXSegmentButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor clearColor];
        button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 8, 0.0, 8);
        button.titleLabel.font = [UIFont systemFontOfSize:13];

        [button setTitle:segment.uppercaseString forState:UIControlStateNormal];
        [button setTitleColor:[SRStylesheet whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[SRStylesheet whiteColor] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.stackView addArrangedSubview:button];
        
        [self.stackView addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.stackView
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0]];
    }
    
    UIButton * button = [self.buttons objectAtIndex:self.selectedSegmentIndex];
    self.lastButton = button;
    [button setSelected:YES];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.selectedSegmentIndex = 0;
    self.buttons = [[NSMutableArray alloc]init];
    [self setupViews];
}

-(void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor colorWithRed:0.3741 green:0.3741 blue:0.3741 alpha:0.5];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.bounces = NO;
    // Create mainStackView
    self.stackView = [[OAStackView alloc]init];
    self.stackView.translatesAutoresizingMaskIntoConstraints = false;
    self.stackView.axis = UILayoutConstraintAxisHorizontal ;
    self.stackView.backgroundColor = [UIColor clearColor];
    self.stackView.spacing = 0;
    
    // Add stackView to scrollView
    [self.scrollView addSubview:self.stackView];
    
    NSDictionary * views = @{@"stackView":self.stackView};
    NSArray * horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stackView]" options:0 metrics:nil views:views];
    NSArray * verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stackView]" options:0 metrics:nil views:views];
    
    // Constrain width of stackView to width of scrollView
    NSLayoutConstraint *height =[NSLayoutConstraint
                                constraintWithItem:self.stackView
                                attribute:NSLayoutAttributeHeight
                                relatedBy:0
                                toItem:self.scrollView
                                attribute:NSLayoutAttributeHeight
                                multiplier:1.0
                                constant:0];
    
    [self addConstraint:height];
    [self.scrollView addConstraints:horizontalConstraints];
    [self.scrollView addConstraints:verticalConstraints];
}

-(void)buttonTapped:(UIButton*)button {
    NSInteger index = [self.buttons indexOfObject:button];
    [self setSelectedSegmentIndex:index];
    [self.delegate scrollableSegmentedControl:self didSelectIndex:index];
}

-(void)updateConstraints {
    // use this to define the constraints
    [super updateConstraints];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.stackView.frame.size.width, self.stackView.frame.size.height);
}

-(void)setSelectedSegmentIndex:(NSUInteger)index {
    _selectedSegmentIndex = index;
    BOOL isFirst = (index == 0);
    
    CGFloat offset = 0.0;
    if (!isFirst) {
        UIButton* previousButton = self.buttons[index-1];
        offset = previousButton.right - 48.0;
    }
    
    CGFloat difference = (([self.buttons lastObject].right)-self.frame.size.width);
    if(offset > difference) {
        offset = difference;
    }
    
    // Just scroll if stackView is bigger than view
    if (self.stackView.frame.size.width > self.frame.size.width) {
        [self.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    }
    
    [self.lastButton setSelected:NO];
    [self.lastButton setHighlighted:NO];
    // enable new button
    
    [[self.buttons objectAtIndex:index]setSelected:YES];
    self.lastButton = [self.buttons objectAtIndex:index];
}

@end

