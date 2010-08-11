//
//  DocumentCell.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 10.08.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"

@class Attachment;

@interface AttachmentCell : AQGridViewCell
{
    Attachment    *_attachment;
    UIImageView *_imageView;
    UILabel     *_title;
}

@property (nonatomic, retain) Attachment * attachment;

@end
