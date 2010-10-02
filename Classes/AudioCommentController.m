//
//  AudioCommentController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 02.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "AudioCommentController.h"
#import "UIButton+Additions.h"
#import "AZZAudioRecorder.h"
#import "AZZAudioPlayer.h"

static NSString *AudioContext = @"AudioContext";

@interface AudioCommentController(Private)
-(BOOL) fileExists;
-(void) updateContent;
@end

@implementation AudioCommentController
@synthesize path;

-(void) setPath:(NSString *) aPath
{
    if (path == aPath)
        return;
    
    [path release];
    path = [aPath retain];
    
    [self updateContent];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    CGRect viewFrame = self.view.frame;
    
    //label comment
    UILabel *labelComment = [[UILabel alloc] initWithFrame: CGRectZero];
    
    labelComment.text = NSLocalizedString(@"Comment", "Comment");
    labelComment.textColor = [UIColor blackColor];
    labelComment.font = [UIFont boldSystemFontOfSize: 17];
    labelComment.backgroundColor = [UIColor clearColor];
    
    [labelComment sizeToFit];
    
    CGRect labelCommentFrame = labelComment.frame;
    
    labelCommentFrame.origin.x = 10.0f;
    
    labelCommentFrame.origin.y = (viewFrame.size.height - labelCommentFrame.size.height)/2;
    
    labelComment.frame = labelCommentFrame;
    
    labelComment.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | 
                                     UIViewAutoresizingFlexibleTopMargin | 
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    [self.view addSubview: labelComment];
    
    [labelComment release];
    
    //button record
    UIImage *imageRecord = [UIImage imageNamed:@"ButtonRecord.png"];
    
    recordButton = [UIButton imageButtonWithTitle:@"Recording -- 99:99"
                                           target:self
                                         selector:@selector(record:)
                                            image:imageRecord
                                    imageSelected:[UIImage imageNamed:@"ButtonRecordStop.png"]];
    
    recordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [recordButton sizeToFit];
    
    CGSize imageRecordSize = imageRecord.size;
    CGSize titleRecordSize = recordButton.titleLabel.bounds.size;
    
    recordButton.imageEdgeInsets = UIEdgeInsetsMake(0, titleRecordSize.width, 0, 0);
    recordButton.titleEdgeInsets = UIEdgeInsetsMake(0,imageRecordSize.width, 0, imageRecordSize.width + 5.0f);
    
    
    [recordButton setTitleColor:[UIColor colorWithRed:0.431 green:0.510 blue:0.655 alpha:1.0] forState:UIControlStateNormal];
    
    [recordButton setTitle:NSLocalizedString(@"Record", @"Record") forState:UIControlStateNormal];
    
    [recordButton setTitle:NSLocalizedString(@"Recording", @"Recording") forState:UIControlStateSelected];
    
    [recordButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    recordButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
    
    CGRect recordButtonFrame = recordButton.frame;
    
    recordButtonFrame.origin.x = viewFrame.size.width - recordButtonFrame.size.width - 10.0f;
    
    recordButtonFrame.origin.y = (viewFrame.size.height - recordButtonFrame.size.height)/2;
    
    recordButton.frame = recordButtonFrame;
    
    recordButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | 
                                     UIViewAutoresizingFlexibleTopMargin | 
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    [self.view addSubview: recordButton];
    
    //play button
    playButton = [UIButton imageButton:self
                              selector:@selector(play:)
                                 image:[UIImage imageNamed:@"ButtonPlay.png"]
                         imageSelected:[UIImage imageNamed:@"ButtonStop.png"]];
    
    [playButton retain];
    
    CGRect playButtonFrame = playButton.frame;
    
    playButtonFrame.origin.x = 200.0f;
    
    playButtonFrame.origin.y = (viewFrame.size.height - playButtonFrame.size.height)/2;
    
    playButton.frame = playButtonFrame;
    
    playButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | 
                                   UIViewAutoresizingFlexibleTopMargin | 
                                   UIViewAutoresizingFlexibleBottomMargin);
    
    [self.view addSubview: playButton];
    
    [self updateContent];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Memory Management
- (void)viewDidUnload 
{
    [super viewDidUnload];
    [recorder removeObserver:self forKeyPath:@"recording"];
    [recorder release]; recorder = nil;
    
    [player removeObserver:self forKeyPath:@"playing"];
    [player release]; player = nil;
    
    [playButton release]; playButton = nil;
    [recordButton release]; recordButton = nil;
}


- (void)dealloc 
{
    [recorder release]; recorder = nil;
    [player release]; player = nil;
    [playButton release]; playButton = nil;
    [recordButton release]; recordButton = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark actions

-(void)record:(id) sender
{
    if (!recorder)
    {
        recorder = [[AZZAudioRecorder alloc] init];
        [recorder addObserver:self
                   forKeyPath:@"recording"
                      options:0
                      context:&AudioContext];
    }
    
    if (recorder.recording)
        [recorder stop];
    else
    {
        recorder.path = self.path;
        if (![recorder start])
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", "Error")
                                                            message: NSLocalizedString(@"Unable to record audio", "Unable to record audio")
                                                           delegate: nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", "OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];            
        }
        [self updateContent];
    }
}

-(void)play:(id) sender
{
    if (!player)
    {
        player = [[AZZAudioPlayer alloc] init];
        [player addObserver:self
                 forKeyPath:@"playing"
                    options:0
                    context:&AudioContext];
    }
    
    if (player.playing)
        [player stop];
    else
    {
        player.path = self.path;
        if (![player start])
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", "Error")
                                                            message: NSLocalizedString(@"Unable to record audio", "Unable to record audio")
                                                           delegate: nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", "OK")
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];            
        }
        [self updateContent];
    }
}

#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &AudioContext)
    {
        [self updateContent];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark Private

-(void) updateContent
{
    NSFileManager *df = [NSFileManager defaultManager];
    BOOL exists = [df fileExistsAtPath: self.path];
    
    if (recorder.recording)
        playButton.hidden = YES;
    else
        playButton.hidden = !exists;
    
    recordButton.selected = recorder.recording;
    playButton.selected = player.playing;
}
@end
