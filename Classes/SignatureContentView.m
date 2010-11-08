//
//  SignatureContentView.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 06.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "SignatureContentView.h"

#define MIN_COMMENT_TEXT_HEIGHT 345.0f

@implementation SignatureContentView

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
    
    //logo
    UIView *logo = [self viewWithTag:SignatureContentViewLogo];
    CGSize logoSize = logo.frame.size;
    CGRect logoFrame = CGRectMake(round((viewSize.width - logoSize.width) / 2), 0.f, logoSize.width, logoSize.height);
    logo.frame = logoFrame;
    
    //signature text
    UITextView *commentText = (UITextView *)[self viewWithTag:SignatureContentViewCommentText];
    
    CGRect commentTextFrame = CGRectMake(0, 
                                            logoFrame.origin.y + logoFrame.size.height + 18, 
                                            viewSize.width,
                                            MIN_COMMENT_TEXT_HEIGHT);
    
    commentText.frame = commentTextFrame;
    
    commentTextFrame.size.height = MAX(commentText.contentSize.height + 10.f, MIN_COMMENT_TEXT_HEIGHT);
    
    commentText.frame = commentTextFrame;
    
    //remove right-left margins
    commentText.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
    
    //author
    UIView *authorLabel = [self viewWithTag:SignatureContentViewAuthorLabel];
    
    CGSize authorSize = authorLabel.frame.size;
    
    CGRect authorFrame = CGRectMake(0, commentTextFrame.origin.y + commentTextFrame.size.height + 15, viewSize.width, authorSize.height);
    authorLabel.frame = authorFrame;
    
    //date
    UIView *dateLabel = [self viewWithTag:SignatureContentViewDateLabel];
    
    CGSize dateSize = dateLabel.frame.size;
    
    CGRect dateFrame = CGRectMake(0, authorFrame.origin.y + authorFrame.size.height + 15, viewSize.width, dateSize.height);
    dateLabel.frame = dateFrame;
    
    self.contentSize = CGSizeMake(viewSize.width, dateFrame.origin.y + dateFrame.size.height);
}

-(void) addSubview:(UIView *) view withTag:(SignatureContentViewView) tag;
{
    view.tag = tag;
    [self addSubview:view];
}
@end

