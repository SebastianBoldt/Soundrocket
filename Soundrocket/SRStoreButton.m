
#import "SRStoreButton.h"
#import "SRStylesheet.h"
@implementation SRStoreButton


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

-(void)setup {
    [self setTitleColor:[SRStylesheet mainColor] forState:UIControlStateNormal];
    [self setTitleColor:[SRStylesheet mainColor] forState:UIControlStateSelected];
    [self setTitleColor:[SRStylesheet lightGrayColor] forState:UIControlStateDisabled];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [SRStylesheet mainColor].CGColor;
    self.layer.cornerRadius = 3.0f;

    [self addTarget:self action:@selector(touchedUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
}
- (void) setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled) {
        self.layer.borderColor = [SRStylesheet mainColor].CGColor;
    } else {
        [self setSelected:self.selected];
    }
}

- (IBAction) touchedUpOutside:(id)sender {
	if (self.selected) {
		[self setSelected:NO];
	}
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.layer.borderColor = [SRStylesheet mainColor].CGColor;
    } else {
        self.layer.borderColor = [SRStylesheet mainColor].CGColor;
    }
}
@end