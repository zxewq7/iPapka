//
//  AZZUIImage.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 21.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
// http://iphonedevelopertips.com/graphics/how-to-scale-an-image-using-an-objective-c-category.html
//

#import <Foundation/Foundation.h>


@interface UIImage (Scale)
-(UIImage*)scaleToSize:(CGSize)size;
@end