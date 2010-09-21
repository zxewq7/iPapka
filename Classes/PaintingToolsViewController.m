//
//  PaintingToolsViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PaintingToolsViewController.h"
#import "UIButton+Additions.h"
#import "ColorPicker.h"

@interface PaintingToolsViewController(Private)
-(void) alignButtons:(NSArray *) buttons
           topOffset:(CGFloat) topOffset
             barSize:(CGSize) barSize 
 spaceBetweenButtons:(CGFloat) spaceBetweenButtons;
@end

@implementation PaintingToolsViewController
@synthesize delegate, color, tool;

- (void)loadView 
{
    UIView *v = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PaintingTools.png"]];
    
    self.view = v;
    
    [v release];
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
#define FIRST_BAR_HEIGHT 211.0f
#define SPACE_BETWEEN_BUTTONS 18.0f
#define SECOND_BAR_OFFSET 205.0f
#define SECOND_BAR_HEIGHT 180.0f
    [super viewDidLoad];
    
    CGSize contentSize = self.view.frame.size;

    commentButton = [UIButton imageButton:self
                                 selector:@selector(selectTool:)
                                    image:[UIImage imageNamed:@"ButtonComment.png"]
                            imageSelected:[UIImage imageNamed:@"ButtonCommentSelected.png"]];
    commentButton.tag = PaintingToolComment;
    
    [commentButton retain];
    
    penButton = [UIButton imageButton:self
                             selector:@selector(selectTool:)
                                image:[UIImage imageNamed:@"ButtonPen.png"]
                        imageSelected:[UIImage imageNamed:@"ButtonPenSelected.png"]];
    
    penButton.tag = PaintingToolPen;
    
    [penButton retain];

    markerButton = [UIButton imageButton:self
                                selector:@selector(selectTool:)
                                   image:[UIImage imageNamed:@"ButtonMarker.png"]
                           imageSelected:[UIImage imageNamed:@"ButtonMarkerSelected.png"]];

    markerButton.tag = PaintingToolMarker;
    
    [markerButton retain];

    eraserButton = [UIButton imageButton:self
                                selector:@selector(selectTool:)
                                   image:[UIImage imageNamed:@"ButtonErase.png"]
                           imageSelected:[UIImage imageNamed:@"ButtonEraseSelected.png"]];

    eraserButton.tag = PaintingToolEraser;
    
    [eraserButton retain];

    [self alignButtons:[NSArray arrayWithObjects:commentButton, penButton, markerButton, eraserButton, nil] 
             topOffset:0
               barSize:CGSizeMake(contentSize.width, FIRST_BAR_HEIGHT)
   spaceBetweenButtons:SPACE_BETWEEN_BUTTONS];

    paletteButton = [UIButton imageButton:self
                                 selector:@selector(pickColor:)
                                    image:[UIImage imageNamed:@"ButtonPalette.png"]
                            imageSelected:[UIImage imageNamed:@"ButtonPaletteSelected.png"]];
    [paletteButton retain];

    rotateCCVButton = [UIButton imageButton:self
                                 selector:nil
                                    image:[UIImage imageNamed:@"ButtonRotateCCV.png"]
                            imageSelected:[UIImage imageNamed:@"ButtonRotateCCV.png"]];

    [rotateCCVButton retain];

    rotateCVButton = [UIButton imageButton:self
                                   selector:nil
                                      image:[UIImage imageNamed:@"ButtonRotateCV.png"]
                              imageSelected:[UIImage imageNamed:@"ButtonRotateCV.png"]];

    [rotateCVButton retain];

    [self alignButtons:[NSArray arrayWithObjects:paletteButton, rotateCCVButton, rotateCVButton, nil] 
             topOffset:SECOND_BAR_OFFSET
               barSize:CGSizeMake(contentSize.width, SECOND_BAR_HEIGHT)
   spaceBetweenButtons:SPACE_BETWEEN_BUTTONS];

    [self.view addSubview: commentButton];
    [self.view addSubview: penButton];
    [self.view addSubview: markerButton];
    [self.view addSubview: eraserButton];
    
    [self.view addSubview: paletteButton];
    [self.view addSubview: rotateCCVButton];
    [self.view addSubview: rotateCVButton];
}

-(void) selectTool:(id) sender
{
    UIButton *toolButton = (UIButton *)sender;
    toolButton.selected = !toolButton.selected;

    //deselect previous button
    if (self.tool != PaintingToolNone)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:self.tool];
        button.selected = NO;
    }
    
    
    if (toolButton.selected)
        self.tool = ((UIButton *)sender).tag;
    else
        self.tool = PaintingToolNone;
    
    if ([delegate respondsToSelector:@selector(paintingView:tool:)])
        [delegate paintingView:self tool:self.tool];
}


-(void) pickColor:(id) sender
{
    paletteButton.selected = YES;
    if (!colorPicker)
    {
        colorPicker = [[ColorPicker alloc] init];
        colorPicker.target = self;
        colorPicker.selector = @selector(selectColor:);
    }
    
    if (!popoverController)
    {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:colorPicker];
        popoverController.delegate = self;
    }
    
    colorPicker.color = self.color;
    UIView *button = (UIView *)sender;
    CGRect targetRect = button.frame;
	[popoverController presentPopoverFromRect: targetRect inView:[button superview] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

-(void) selectColor:(id) sender
{
    self.color = colorPicker.color;
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc
{
    paletteButton.selected = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [commentButton release];
    commentButton = nil;
    [penButton release];
    [markerButton release];
    markerButton = nil;
    [eraserButton release];
    eraserButton = nil;
    [paletteButton release];
    paletteButton = nil;
    [rotateCCVButton release];
    rotateCCVButton = nil;
    [rotateCVButton release];
    rotateCVButton = nil;
    [colorPicker release];
    colorPicker = nil;
    [popoverController release];
    popoverController = nil;
}


- (void)dealloc {
    [super dealloc];
    [commentButton release];
    commentButton = nil;
    [penButton release];
    [markerButton release];
    markerButton = nil;
    [eraserButton release];
    eraserButton = nil;
    [paletteButton release];
    paletteButton = nil;
    [rotateCCVButton release];
    rotateCCVButton = nil;
    [rotateCVButton release];
    rotateCVButton = nil;
    self.delegate = nil;
    self.color = nil;
    [colorPicker release];
    colorPicker = nil;
    [popoverController release];
    popoverController = nil;
}


@end

@implementation PaintingToolsViewController(Private)
-(void) alignButtons:(NSArray *) buttons
           topOffset:(CGFloat) topOffset
             barSize:(CGSize) barSize 
 spaceBetweenButtons:(CGFloat) spaceBetweenButtons;
{
    UIView *firstButton = [buttons objectAtIndex:0];
    CGSize buttonSize = firstButton.bounds.size;
    //first button without space before
    CGFloat y = (barSize.height - (buttonSize.height + spaceBetweenButtons) * [buttons count] + spaceBetweenButtons)/2+topOffset;
    CGFloat x = (barSize.width - buttonSize.width)/2;
    for(UIView *button in buttons)
    {
        CGRect frame = CGRectMake(x, y, buttonSize.width, buttonSize.height);
        button.frame = frame;
        y += buttonSize.height + spaceBetweenButtons;
    }
}
@end