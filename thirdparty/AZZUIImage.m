//
//  AZZUIImage.m
//  iPapka
//
//  Created by Vladimir Solomenchuk on 21.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AZZUIImage.h"


@implementation UIImage (Scale)

-(UIImage*)scaleToSize:(CGSize)size
{
    // Create a bitmap graphics context
    // This will also set it as the current context
    UIGraphicsBeginImageContext(size);
    
    // Draw the scaled image in the current context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    
    // Return our new scaled image
    return scaledImage;
}

@end
