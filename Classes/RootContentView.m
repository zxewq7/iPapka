//
//  RootContentView.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 21.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RootContentView.h"

#define kDocumentInfo 1021
#define kAttachments 1022
#define kResolution 1023
#define kSignatureComment 1024


#define kLeftMargin 7.0f
#define kRightMargin 10.0f

#define kTopMargin 7.0f

@interface RootContentView(Private)
-(void) setView:(UIView *) view withTag:(int) tag;
@end

@implementation RootContentView
@dynamic documentInfo, attachments, resolution, signatureComment;


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

-(void) setSignatureComment:(UIView *) view
{
    [self setView:view withTag: kSignatureComment];
}

-(UIView *) signatureComment
{
    return [self viewWithTag: kSignatureComment];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

    CGSize size = self.bounds.size;
    
    //documentInfo
    
    UIView *documentInfo = self.documentInfo;
    CGRect documentInfoFrame = documentInfo.frame;
    documentInfoFrame.origin.x = kLeftMargin;
    documentInfoFrame.origin.y = kTopMargin;
    documentInfoFrame.size.width = size.width - kLeftMargin - kRightMargin;
    
    documentInfo.frame = documentInfoFrame;
    
    //resolution
    UIView *resolution = self.resolution;
    
    CGRect resolutionFrame = resolution.frame;
    resolutionFrame.origin.x = round((size.width-resolutionFrame.size.width) / 2);
    resolutionFrame.origin.y = 0;
    resolution.frame = resolutionFrame;

    //resolution
    UIView *signatureComment = self.signatureComment;

    CGRect signatureCommentFrame = signatureComment.frame;
    signatureCommentFrame.origin.x = round((size.width-signatureCommentFrame.size.width) / 2);
    signatureCommentFrame.origin.y = 0;
    signatureComment.frame = signatureCommentFrame;

    //attachments
    UIView *attachments = self.attachments;
    
    CGRect attachmentsFrame = CGRectMake(kLeftMargin, kTopMargin, size.width - kLeftMargin - kRightMargin, size.height - 2 * kTopMargin);
    
    attachments.frame = attachmentsFrame;
}

#pragma Private

-(void) setView:(UIView *) view withTag:(int) tag
{
    view.tag = tag;
    view.autoresizingMask = UIViewAutoresizingNone;
    
    if (view)
        [self addSubview: view];
    else
    {
        UIView *v  = [self viewWithTag: tag];
        [v removeFromSuperview];
    }
    
}
@end
