//
//  AudioCommentController.h
//  iPapka
//
//  Created by Vladimir Solomenchuk on 02.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZAudioRecorder, AZZAudioPlayer, FileField;

@interface AudioCommentController : UIViewController
{
    FileField           *file;
    
    AZZAudioRecorder    *recorder;
    AZZAudioPlayer      *player;
    UIButton            *playButton;
    UIButton            *recordButton;
    UIButton            *removeButton;
    UILabel             *labelComment;
    NSTimer             *timer;
}
    
@property (nonatomic, retain) FileField* file;
@end
