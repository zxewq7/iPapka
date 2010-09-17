//
//  PageControlWithMenu.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 17.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PageControlWithMenu.h"

@implementation PageControlWithMenu
@synthesize bubbleView, backgroundView;
@dynamic currentPageBypass;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        backgroundView = [[UIImageView alloc] initWithFrame: frame];
//        backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
//                        UIViewAutoresizingFlexibleWidth);
        [self addSubview: backgroundView];
    }
    return self;
}

-(void) showBubble
{
    bubbleView.hidden = NO;
}

- (void)setCurrentPageBypass:(NSInteger)aPage {
	[self setCurrentPage:aPage];
	[self setNeedsDisplay];
    [self showBubble];
}

- (NSInteger)currentPageBypass {
	return self.currentPage;
}

- (void)dealloc 
{
    [backgroundView release];
    [bubbleView release];
    [super dealloc];
}
@end
