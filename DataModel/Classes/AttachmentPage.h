//
//  AttachmentPage.h
//  DataModel
//
//  Created by Vladimir Solomenchuk on 29.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AttachmentPage : NSObject<NSCoding> 
{
    NSString *name;
    NSString *path;
    UIImage  *drawings;
    BOOL     hasError;
    BOOL     isLoaded;
    BOOL     removeDrawings;
    CGFloat  rotationAngle;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain, getter=drawings, setter=getDrawings:) UIImage  *drawings;
@property (nonatomic, assign) BOOL    hasError;
@property (nonatomic, assign) BOOL    isLoaded;
@property (nonatomic, retain, readonly, getter=image) UIImage  *image;
@property (nonatomic, assign) CGFloat  rotationAngle;
@end
