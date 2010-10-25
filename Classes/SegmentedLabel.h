//
//  SegmentedLabel.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 18.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SegmentedLabel : UIView 
{
    NSArray *labels;
    NSArray *texts;
}
@property (nonatomic, retain, setter=setLabels:) NSArray * labels;
@property (nonatomic, retain, setter=setTexts:)  NSArray * texts;
@end