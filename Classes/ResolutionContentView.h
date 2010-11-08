//
//  ResolutionContentView.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 01.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _ResolutionContentViewView 
{
	ResolutionContentViewSwitcher = 990,
    ResolutionContentViewLogo = 991,
    ResolutionContentViewPerformers = 992,
    ResolutionContentViewDeadlinePhrase = 993,
    ResolutionContentViewDeadlineButton = 994,
    ResolutionContentViewDeadlineLabel = 995,
    ResolutionContentViewResolutionText = 996,
    ResolutionContentViewAuthorLabel = 997,
    ResolutionContentViewDateLabel = 998
} ResolutionContentViewView;

@interface ResolutionContentView : UIScrollView 

-(void) addSubview:(UIView *) view withTag:(ResolutionContentViewView) tag;

@end
