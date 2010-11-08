//
//  RootBackgroundView.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 19.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RootBackgroundView.h"

#define kPaper 1001
#define kPaintingTools 1002
#define kContent 1003
#define kInfoButton 1004
#define kResolutionButton 1005
#define kBackButton 1006
#define kSignatureCommentButton 1007

@interface RootBackgroundView(Private)
-(void) setView:(UIView *) view withTag:(int) tag;
@end

@implementation RootBackgroundView
@dynamic paper, paintingTools, content, infoButton, resolutionButton, backButton, signatureCommentButton;

-(void) setPaper:(UIView *) view
{
    [self setView:view withTag: kPaper];
}

-(UIView *) paper
{
    return [self viewWithTag: kPaper];
}

-(void) setPaintingTools:(UIView *) view
{
    [self setView:view withTag: kPaintingTools];
}

-(UIView *) paintingTools
{
    return [self viewWithTag: kPaintingTools];
}

-(void) setContent:(UIView *) view
{
    [self setView:view withTag: kContent];
}

-(UIView *) content
{
    return [self viewWithTag: kContent];
}

-(void) setInfoButton:(UIView *) view
{
    [self setView:view withTag: kInfoButton];
}

-(UIView *) infoButton
{
    return [self viewWithTag: kInfoButton];
}

-(void) setResolutionButton:(UIView *) view
{
    [self setView:view withTag: kResolutionButton];
}

-(UIView *) resolutionButton
{
    return [self viewWithTag: kResolutionButton];
}

-(void) setBackButton:(UIView *) view
{
    [self setView:view withTag: kBackButton];
}

-(UIView *) backButton
{
    return [self viewWithTag: kBackButton];
}

-(void) setSignatureCommentButton:(UIView *) view
{
    [self setView:view withTag: kSignatureCommentButton];
}

-(UIView *) signatureCommentButton
{
    return [self viewWithTag: kSignatureCommentButton];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    CGSize size = self.bounds.size;

    //content
    UIView *content = self.content;
    
    [content layoutSubviews];
    
    CGRect contentFrame = content.frame;
    contentFrame.origin.x = round((size.width-contentFrame.size.width) / 2);
    contentFrame.origin.y = 43;
    content.frame = contentFrame;

    //paper
    UIView *paper = self.paper;
    
    [paper layoutSubviews];
    
    CGRect paperFrame = paper.frame;
    paperFrame.origin.x = round((size.width-paperFrame.size.width) / 2);
    paperFrame.origin.y = 43;
    paper.frame = paperFrame;
    
    //paintingTools
    UIView *paintingTools = self.paintingTools;
    
    CGRect paintingToolsFrame = paintingTools.frame;
    paintingToolsFrame.origin.x = contentFrame.origin.x - paintingToolsFrame.size.width + 8.0f;
    paintingToolsFrame.origin.y = 60.0f;
    paintingTools.frame = paintingToolsFrame;

    //resolutionButton
    UIView *resolutionButton = self.resolutionButton;

    CGRect resolutionButtonFrame = resolutionButton.frame;
    resolutionButtonFrame.origin.x = contentFrame.origin.x + 6.f;
    resolutionButtonFrame.origin.y = 12.0f;
    resolutionButton.frame = resolutionButtonFrame;

    resolutionButton.frame = resolutionButtonFrame;

    //signatureCommentButton
    UIView *signatureCommentButton = self.signatureCommentButton;
    CGRect signatureCommentButtonFrame = signatureCommentButton.frame;
    
    signatureCommentButtonFrame.origin.x = resolutionButtonFrame.origin.x;
    signatureCommentButtonFrame.origin.y = resolutionButtonFrame.origin.y;
    
    signatureCommentButton.frame = signatureCommentButtonFrame;

    
    //backButton
    UIView *backButton = self.backButton;
    CGRect backButtonFrame = backButton.frame;
    backButtonFrame.origin.x = resolutionButtonFrame.origin.x;
    backButtonFrame.origin.y = resolutionButtonFrame.origin.y;
    backButton.frame = backButtonFrame;

    
    //infoButton
    UIView *infoButton = self.infoButton;
    CGRect infoButtonFrame = infoButton.frame;
    infoButtonFrame.origin.x = contentFrame.origin.x + contentFrame.size.width - infoButtonFrame.size.width - 6.f;
    infoButtonFrame.origin.y = 12.0f;
    infoButton.frame = infoButtonFrame;
}

- (void)dealloc 
{
    [super dealloc];
}

#pragma Private

-(void) setView:(UIView *) view withTag:(int) tag
{
    view.autoresizingMask = UIViewAutoresizingNone;
    
    view.tag = tag;
    
    if (view)
        [self addSubview: view];
    else
    {
        UIView *v  = [self viewWithTag: tag];
        [v removeFromSuperview];
    }
        
}
@end
