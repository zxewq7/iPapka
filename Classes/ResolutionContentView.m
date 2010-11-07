//
//  ResolutionContentView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 01.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ResolutionContentView.h"
#import "ViewWithButtons.h"

#define SPACE_BETWEEN_ROWS 15.0f

@implementation ResolutionContentView


- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.bounds.size;
    
    viewSize.width -= self.contentInset.right + self.contentInset.left;
    
    //filter
    UIView *resolutionSwitcher = [self viewWithTag:ResolutionContentViewSwitcher];

    CGRect switcherFrame = resolutionSwitcher.frame;
    switcherFrame.origin.x = round((viewSize.width - switcherFrame.size.width) / 2);
    switcherFrame.origin.y = 0;
    resolutionSwitcher.frame = switcherFrame;
    
    //logo
    UIView *logo = [self viewWithTag:ResolutionContentViewLogo];
    CGSize logoSize = logo.frame.size;
    CGRect logoFrame = CGRectMake(round((viewSize.width - logoSize.width) / 2), switcherFrame.origin.y + switcherFrame.size.height + 10.0f, logoSize.width, logoSize.height);
    logo.frame = logoFrame;
    
    
    //performersViewController
    UIView *performersView = (ViewWithButtons *)[self viewWithTag:ResolutionContentViewPerformers];
    
    CGRect performersFrame = CGRectMake(0, 
                                        logoFrame.origin.y + logoFrame.size.height+18, 
                                        viewSize.width + self.contentInset.right,
                                        performersView.frame.size.height);
    performersView.frame = performersFrame;
    
    //deadline phrase
    UIView *deadlinePhrase = [self viewWithTag:ResolutionContentViewDeadlinePhrase];;

    CGSize deadlineSize = deadlinePhrase.frame.size;
    
    CGRect deadlinePhraseFrame = CGRectMake(0, performersFrame.origin.y + performersFrame.size.height + 26, deadlineSize.width, deadlineSize.height);
    deadlinePhrase.frame = deadlinePhraseFrame;
    
    
    //deadline button
    UIView *deadlineButton = [self viewWithTag:ResolutionContentViewDeadlineButton];
    CGRect deadlineButtonFrame = deadlineButton.frame;
    deadlineButtonFrame.origin.x = deadlinePhraseFrame.origin.x + deadlinePhraseFrame.size.width + 10;
    deadlineButtonFrame.origin.y = deadlinePhraseFrame.origin.y - round((deadlineButtonFrame.size.height - deadlinePhraseFrame.size.height) / 2);
    
    deadlineButton.frame = deadlineButtonFrame;
    
    //deadLine label
    UIView *deadlineLabel = [self viewWithTag:ResolutionContentViewDeadlineLabel];
    
    CGRect deadlineLabelFrame = deadlineLabel.frame;
    
    deadlineLabelFrame.origin.x = deadlinePhraseFrame.origin.x + deadlinePhraseFrame.size.width + 5;
    deadlineLabelFrame.origin.y = deadlinePhraseFrame.origin.y - round((deadlineLabelFrame.size.height - deadlinePhraseFrame.size.height) / 2);
    
    deadlineLabel.frame = deadlineLabelFrame;
    
    //resolution text
    
    UIView *authorLabel = [self viewWithTag:ResolutionContentViewAuthorLabel];
    
    CGSize authorSize = authorLabel.frame.size;

    UIView *dateLabel = [self viewWithTag:ResolutionContentViewDateLabel];
    
    CGSize dateSize = dateLabel.frame.size;

    
    UITextView *resolutionText = (UITextView *)[self viewWithTag:ResolutionContentViewResolutionText];
    
    CGFloat optimalTextHeight = viewSize.height - (deadlinePhraseFrame.origin.y + deadlinePhraseFrame.size.height + SPACE_BETWEEN_ROWS) - (SPACE_BETWEEN_ROWS + authorSize.height) - (SPACE_BETWEEN_ROWS + dateSize.height);

    CGRect resolutionTextFrame = CGRectMake(0, 
                                            deadlinePhraseFrame.origin.y + deadlinePhraseFrame.size.height + SPACE_BETWEEN_ROWS, 
                                            viewSize.width,
                                            20.f);
    
    resolutionText.frame = resolutionTextFrame;
    
    resolutionTextFrame.size.height = MAX(resolutionText.contentSize.height, optimalTextHeight);

    resolutionText.frame = resolutionTextFrame;
    
    //author
    
    CGRect authorFrame = CGRectMake(0, resolutionTextFrame.origin.y + resolutionTextFrame.size.height + SPACE_BETWEEN_ROWS, viewSize.width, authorSize.height);
    authorLabel.frame = authorFrame;
    
    //date
    
    CGRect dateFrame = CGRectMake(0, authorFrame.origin.y + authorFrame.size.height + SPACE_BETWEEN_ROWS, viewSize.width, dateSize.height);
    dateLabel.frame = dateFrame;
    
    self.contentSize = CGSizeMake(self.frame.size.width, dateFrame.origin.y + dateFrame.size.height);
}

-(void) addSubview:(UIView *) view withTag:(ResolutionContentViewView) tag;
{
    view.tag = tag;
    [self addSubview:view];
}

@end
