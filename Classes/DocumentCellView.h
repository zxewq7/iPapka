//
//  DocumentCellView.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 23.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZZSegmentedLabel;
@interface DocumentCellView : UIView 
{
    UILabel *textLabel;
    UILabel *detailTextLabel1;
    UILabel *detailTextLabel2;
    AZZSegmentedLabel *detailTextLabel3;
    UIImageView *attachmentImageView;
    UIImageView *imageView;
}

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UILabel *detailTextLabel1;
@property (nonatomic, readonly) UILabel *detailTextLabel2;
@property (nonatomic, readonly) AZZSegmentedLabel *detailTextLabel3;
@property (nonatomic, readonly) UIImageView *attachmentImageView;
@property (nonatomic, readonly) UIImageView *imageView;
@end
