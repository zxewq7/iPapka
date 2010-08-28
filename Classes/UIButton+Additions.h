//
//  UIButton+Additions.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 28.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIButton (Button_Additions)
+ (UIButton *) imageButton:(id)target
                  selector:(SEL)selector
                 imageName:(NSString *)anImageName
         imageNameSelected:(NSString *)anImageNameSelected;

+(UIButton *) imageButtonWithTitle:(NSString *) title
                            target:(id)target
                          selector:(SEL)selector
                         imageName:(NSString *)anImageName
                 imageNameSelected:(NSString *)anImageNameSelected;

@end
