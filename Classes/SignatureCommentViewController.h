//
//  SignatureCommentViewController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 03.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DocumentSignature, SSTextView, AudioCommentController, SignatureContentView;
@interface SignatureCommentViewController : UIViewController <UITextViewDelegate>
{
    SSTextView              *commentText;
    UILabel                 *authorLabel;
    UILabel                 *dateLabel;
    DocumentSignature       *document;
    NSDateFormatter         *dateFormatter;
    AudioCommentController  *audioCommentController;
    SignatureContentView    *contentView;
}

@property (nonatomic, retain) DocumentSignature    *document;
@end