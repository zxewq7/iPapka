//
//  RootContentView.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RootContentView.h"

#define kDocumentInfo 1011
#define kAttachments 1012
#define kResolution 1013


#define kMargin 6.0f

#define kMarginLandscape 5.0f

#define kTopMargin 5.0f

#define kTopMarginLandscape 6.0f

@interface RootContentView(Private)
-(void) setView:(UIView *) view withTag:(int) tag;
@end

@implementation RootContentView
@dynamic documentInfo, attachments, resolution;


-(void) setDocumentInfo:(UIView *) view
{
    [self setView:view withTag: kDocumentInfo];
}

-(UIView *) documentInfo
{
    return [self viewWithTag: kDocumentInfo];
}


-(void) setAttachments:(UIView *) view
{
    [self setView:view withTag: kAttachments];
}

-(UIView *) attachments
{
    return [self viewWithTag: kAttachments];
}

-(void) setResolution:(UIView *) view
{
    [self setView:view withTag: kResolution];
}

-(UIView *) resolution
{
    return [self viewWithTag: kResolution];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    CGFloat margin;
    
    CGFloat topMargin;
    
    CGSize size = self.bounds.size;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) //portrait
    {
        margin = kMargin;
        topMargin = kTopMargin;
        
    }
    else
    {
        margin = kMarginLandscape;
        topMargin = kTopMarginLandscape;
    }
    
    //documentInfo
    
    UIView *documentInfo = self.documentInfo;
    CGRect documentInfoFrame = documentInfo.frame;
    documentInfoFrame.origin.x = kMargin;
    documentInfoFrame.origin.y = kTopMargin;
    documentInfoFrame.size.width = size.width - 2 * kMargin;
    documentInfoFrame.size.height += kTopMargin;
    
    documentInfo.frame = documentInfoFrame;
    
    //resolution
    UIView *resolution = self.resolution;
    
    CGRect resolutionFrame = resolution.frame;
    resolutionFrame.origin.x = (size.width-resolutionFrame.size.width)/2;
    resolutionFrame.origin.y = 0;
    resolution.frame = resolutionFrame;
    
    //attachments
    UIView *attachments = self.attachments;
    
    CGRect attachmentsFrame = CGRectMake(margin, topMargin, size.width - 2 * margin, size.height - 2 * topMargin);
    
    attachments.frame = attachmentsFrame;
}

#pragma Private

-(void) setView:(UIView *) view withTag:(int) tag
{
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
