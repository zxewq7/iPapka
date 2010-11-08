//
//  SignatureContentView.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 06.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _SignatureContentViewView
{
    SignatureContentViewLogo = 991,
    SignatureContentViewCommentText = 996,
    SignatureContentViewAuthorLabel = 997,
    SignatureContentViewDateLabel = 998
} SignatureContentViewView;

@interface SignatureContentView : UIScrollView 

-(void) addSubview:(UIView *) view withTag:(SignatureContentViewView) tag;

@end
