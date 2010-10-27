//
//  DocumentInfoDetailsView.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 26.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZSegmentedLabel;
@interface DocumentInfoDetailsView : UIView 
{
    UILabel *textLabel;
    AZZSegmentedLabel *detailTextLabel1;
    UILabel *detailTextLabel2;
}

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) AZZSegmentedLabel *detailTextLabel1;
@property (nonatomic, readonly) UILabel *detailTextLabel2;

@end
