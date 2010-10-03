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
#import "NSString+Additions.h"

static NSString *AudioContext = @"AudioContext";

@interface AudioCommentController(Private)
-(BOOL) fileExists;
-(void) updateContent;
-(AZZAudioPlayer*) player;
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
    labelComment = [[UILabel alloc] initWithFrame: CGRectZero];
    
    labelComment.text = NSLocalizedString(@"Comment", "Comment");
    labelComment.textColor = [UIColor blackColor];
    labelComment.font = [UIFont boldSystemFontOfSize: 17];
    labelComment.backgroundColor = [UIColor clearColor];
    labelComment.enabled = NO;
    
    [labelComment sizeToFit];
    
    CGRect labelCommentFrame = labelComment.frame;
    
    labelCommentFrame.origin.x = 10.0f;
    
    labelCommentFrame.origin.y = (viewFrame.size.height - labelCommentFrame.size.height)/2;
    
    labelComment.frame = labelCommentFrame;
    
    labelComment.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | 
                                     UIViewAutoresizingFlexibleTopMargin | 
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    [self.view addSubview: labelComment];
    
    //play button
    
    UIImage *imagePlay = [UIImage imageNamed:@"ButtonPlay.png"];
    
    playButton = [UIButton imageButtonWithTitle:NSLocalizedString(@"Listen comment", @"Listen comment")
                                           target:self
                                         selector:@selector(play:)
                                            image:imagePlay
                                    imageSelected:[UIImage imageNamed:@"ButtonStop.png"]];
    
    [playButton retain];
    
    playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    playButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
    
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    
    [playButton sizeToFit];
    
    CGRect playButtonFrame = playButton.frame;
    
    playButtonFrame.size.width = 2*(viewFrame.size.width/3);
    
    playButtonFrame.origin.x = 10.0f;
    
    playButtonFrame.origin.y = (viewFrame.size.height - playButtonFrame.size.height)/2;
    
    playButton.frame = playButtonFrame;
    
    CGSize imagePlaySize = imagePlay.size;
    CGSize labelPlaySize = playButton.titleLabel.frame.size;
    
    playButton.imageEdgeInsets = UIEdgeInsetsMake(0, labelPlaySize.width + 0.5f, 0, 0);
    playButton.titleEdgeInsets = UIEdgeInsetsMake(0, -(imagePlaySize.width + 5.0f), 0, imagePlaySize.width + 5.0f);
    
    playButton.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | 
                                     UIViewAutoresizingFlexibleTopMargin | 
                                     UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    [self.view addSubview: playButton];
    
    //button record
    UIImage *imageRecord = [UIImage imageNamed:@"ButtonRecord.png"];
    
    recordButton = [UIButton imageButtonWithTitle:NSLocalizedString(@"Record", @"Record")
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
    
    [recordButton setTitle:NSLocalizedString(@"Recording", @"Recording") forState:UIControlStateSelected];
    
    [recordButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    
    recordButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | 
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleWidth |
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
    
    [labelComment release]; labelComment = nil;
}


- (void)dealloc 
{
    [recorder removeObserver:self forKeyPath:@"recording"];
    [recorder release]; recorder = nil;

    [player removeObserver:self forKeyPath:@"playing"];
    [player release]; player = nil;

    [playButton release]; playButton = nil;

    [recordButton release]; recordButton = nil;

    [removeButton release]; removeButton = nil;
    
    [labelComment release]; labelComment = nil;
    
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
    if (self.player.playing)
        [self.player stop];
    else
    {
        self.player.path = self.path;
        if (![self.player start])
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
    labelComment.hidden = exists;

    if (!playButton.hidden)
    {
        self.player.path = self.path;
        NSString *label = [NSString stringWithFormat:@"%@      %@", NSLocalizedString(@"Listen comment", @"Listen comment"), [NSString timeString:self.player.duration showSeconds:YES]];
        
        [playButton setTitle:label forState:UIControlStateNormal];
    }
}
-(AZZAudioPlayer*) player
{
    if (!player)
    {
        player = [[AZZAudioPlayer alloc] init];
        [player addObserver:self
                 forKeyPath:@"playing"
                    options:0
                    context:&AudioContext];
    }
    return player;
}
@end
