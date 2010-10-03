//
//  SignatureCommentViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 03.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DocumentSignature, TextViewWithPlaceholder, AudioCommentController;
@interface SignatureCommentViewController : UIViewController <UITextViewDelegate>
{
    TextViewWithPlaceholder *commentText;
    UILabel                 *authorLabel;
    UILabel                 *dateLabel;
    DocumentSignature       *document;
    NSDateFormatter         *dateFormatter;
    AudioCommentController  *audioCommentController;
}

@property (nonatomic, retain) DocumentSignature    *document;
@end