//
//  DocumentCellView.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 23.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DocumentCellView : UIView 
{
    UILabel *textLabel;
    UILabel *detailTextLabel;
    UIImageView *attachmentImageView;
    UIImageView *imageView;
}

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UILabel *detailTextLabel;
@property (nonatomic, readonly) UIImageView *attachmentImageView;
@property (nonatomic, readonly) UIImageView *imageView;
@end
