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
    labelComment.textColor = [UIColor lightGrayColor];
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
    
    [recordButton retain];
    
    recordButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    recordButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
    
    [recordButton sizeToFit];
    
    CGRect recordButtonFrame = recordButton.frame;
    
    recordButtonFrame.size.width = viewFrame.size.width/3;
    
    recordButtonFrame.origin.x = viewFrame.size.width - recordButtonFrame.size.width - 10.0f;
    
    recordButtonFrame.origin.y = (viewFrame.size.height - recordButtonFrame.size.height)/2;
    
    recordButton.frame = recordButtonFrame;

    
    CGSize imageRecordSize = imageRecord.size;
    
    recordButton.imageEdgeInsets = UIEdgeInsetsMake(0, recordButtonFrame.size.width - imageRecordSize.width, 0, 0);
    recordButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageRecordSize.width + 5.0f), 0, imageRecordSize.width + 5.0f);
    
    
    [recordButton setTitleColor:[UIColor colorWithRed:0.431 green:0.510 blue:0.655 alpha:1.0] forState:UIControlStateNormal];
    
    [recordButton setTitle:NSLocalizedString(@"Record", @"Record") forState:UIControlStateNormal];
    
    [recordButton setTitle:NSLocalizedString(@"Recording", @"Recording") forState:UIControlStateSelected];
    
    [recordButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    
    recordButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | 
                                     UIViewAutoresizingFlexibleTopMargin | 
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    [self.view addSubview: recordButton];
    
    //button remove
    UIImage *imageRemove = [UIImage imageNamed:@"ButtonRecordRemove.png"];
    
    removeButton = [UIButton imageButtonWithTitle:NSLocalizedString(@"Remove", "Remove")
                                           target:self
                                         selector:@selector(remove:)
                                            image:imageRemove
                                    imageSelected:imageRemove];
    [removeButton retain];
    
    removeButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];

    removeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [removeButton sizeToFit];
    
    removeButton.frame = recordButtonFrame;

    CGSize imageRemoveSize = imageRemove.size;
    
    removeButton.imageEdgeInsets = UIEdgeInsetsMake(0, recordButtonFrame.size.width - imageRemoveSize.width, 0, 0);
    removeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageRemoveSize.width + 0.5f), 0, imageRemoveSize.width + 5.0f);

    [removeButton setTitleColor:[UIColor colorWithRed:0.431 green:0.510 blue:0.655 alpha:1.0] forState:UIControlStateNormal];
    
    
    removeButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | 
                                     UIViewAutoresizingFlexibleTopMargin | 
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    [self.view addSubview: removeButton];
    
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
    
    [removeButton release]; removeButton = nil;
}


- (void)dealloc 
{
    [recorder release]; recorder = nil;

    [player release]; player = nil;

    [playButton release]; playButton = nil;

    [recordButton release]; recordButton = nil;

    [removeButton release]; removeButton = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark actions

-(void)remove:(id) sender
{
    [recorder stop];
    [player stop];
    
    NSFileManager *df = [NSFileManager defaultManager];

    [df removeItemAtPath:self.path error:NULL];
    
    [self updateContent];
}

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
    {
        playButton.hidden = YES;
        removeButton.hidden = YES;
    }
    else
    {
        playButton.hidden = !exists;
        removeButton.hidden = !exists;
        recordButton.hidden = exists;
    }
    
    recordButton.selected = recorder.recording;
    playButton.selected = player.playing;
}
@end
