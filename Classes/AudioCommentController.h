//
//  AudioCommentController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 02.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AZZAudioRecorder, AZZAudioPlayer;

@interface AudioCommentController : UIViewController 
{
    NSString *path;
    
    AZZAudioRecorder    *recorder;
    AZZAudioPlayer      *player;
    UIButton            *playButton;
    UIButton            *recordButton;
}
    
@property (nonatomic, retain) NSString* path;
@end
