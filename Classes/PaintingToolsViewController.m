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

static NSString* ColorContext = @"ColorContext";

@interface PaintingToolsViewController(Private)
-(void) alignButtons:(NSArray *) buttons
           topOffset:(CGFloat) topOffset
             barSize:(CGSize) barSize 
 spaceBetweenButtons:(CGFloat) spaceBetweenButtons;
@end

@implementation PaintingToolsViewController
@synthesize delegate, color, tool;

- (id)init 
{
    if ((self = [super init])) 
    {
        self.color = [ColorPicker defaultColor];
    }
    return self;
}

- (void)loadView 
{
    UIView *v = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"PaintingTools.png"]];
    
    self.view = v;
    
    [v release];
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
#define FIRST_BAR_OFFSET 15.0f
#define FIRST_BAR_HEIGHT 193.0f
#define SPACE_BETWEEN_BUTTONS 12.0f
#define SECOND_BAR_OFFSET 216.0f
#define SECOND_BAR_HEIGHT 159.0f
    [super viewDidLoad];
    
    CGSize contentSize = self.view.frame.size;

//    commentButton = [UIButton imageButton:self
//                                 selector:@selector(selectTool:)
//                                    image:[UIImage imageNamed:@"ButtonComment.png"]
//                            imageSelected:[UIImage imageNamed:@"ButtonCommentSelected.png"]];
//    commentButton.tag = PaintingToolComment;
//    
//    [commentButton retain];
    
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

//    [self alignButtons:[NSArray arrayWithObjects:commentButton, penButton, markerButton, eraserButton, nil] 
//             topOffset:FIRST_BAR_OFFSET
//               barSize:CGSizeMake(contentSize.width, FIRST_BAR_HEIGHT)
//   spaceBetweenButtons:SPACE_BETWEEN_BUTTONS];

    paletteButton = [UIButton imageButton:self
                                 selector:@selector(pickColor:)
                                    image:[UIImage imageNamed:@"ButtonPalette.png"]
                            imageSelected:[UIImage imageNamed:@"ButtonPaletteSelected.png"]];
    [paletteButton retain];

    [self alignButtons:[NSArray arrayWithObjects:penButton, markerButton, eraserButton, paletteButton, nil] 
             topOffset:FIRST_BAR_OFFSET
               barSize:CGSizeMake(contentSize.width, FIRST_BAR_HEIGHT)
   spaceBetweenButtons:SPACE_BETWEEN_BUTTONS];

    

//    rotateCCVButton = [UIButton imageButton:self
//                                   selector:@selector(rotate:)
//                                      image:[UIImage imageNamed:@"ButtonRotateCCV.png"]
//                              imageSelected:[UIImage imageNamed:@"ButtonRotateCCV.png"]];
//
//    [rotateCCVButton retain];
//
//    rotateCVButton = [UIButton  imageButton:self
//                                   selector:@selector(rotate:)
//                                      image:[UIImage imageNamed:@"ButtonRotateCV.png"]
//                              imageSelected:[UIImage imageNamed:@"ButtonRotateCV.png"]];
//
//    [rotateCVButton retain];

//    [self alignButtons:[NSArray arrayWithObjects:paletteButton, rotateCCVButton, rotateCVButton, nil] 
//             topOffset:SECOND_BAR_OFFSET
//               barSize:CGSizeMake(contentSize.width, SECOND_BAR_HEIGHT)
//   spaceBetweenButtons:SPACE_BETWEEN_BUTTONS];
}

-(void) cancel
{
    if (self.tool != PaintingToolNone)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag:self.tool];
        button.selected = NO;
    }
    self.tool = PaintingToolNone;
    
    if ([delegate respondsToSelector:@selector(paintingView:tool:)])
        [delegate paintingView:self tool:self.tool];
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

-(void) rotate:(id) sender
{
    UIButton *rotateButton = (UIButton *)sender;
    
    CGFloat angle = 90*(rotateButton == rotateCVButton?1:-1);
    
    if ([delegate respondsToSelector:@selector(paintingView:rotate:)])
        [delegate paintingView:self rotate:angle];
}

-(void) pickColor:(id) sender
{
    if (!colorPicker)
    {
        colorPicker = [[ColorPicker alloc] init];
        [colorPicker addObserver:self
                      forKeyPath:@"color"
                        options:0
                         context:&ColorContext];
        colorPicker.color = self.color;
    }
    if (!popoverController)
    {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:colorPicker];
        popoverController.delegate = self;
    }
    
    UIView *button = (UIView *)sender;
    CGRect targetRect = button.frame;
	[popoverController presentPopoverFromRect: targetRect inView:[button superview] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    paletteButton.selected = YES;
}

#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &ColorContext)
    {
        [popoverController dismissPopoverAnimated:YES];
        [self popoverControllerDidDismissPopover:popoverController];
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


#pragma mark -
#pragma mark UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc
{
    paletteButton.selected = NO;
    
    self.color = colorPicker.color;
    
    if ([delegate respondsToSelector:@selector(paintingView:color:)])
        [delegate paintingView:self color:self.color];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [commentButton release]; commentButton = nil;

    [penButton release]; penButton = nil;

    [markerButton release]; markerButton = nil;

    [eraserButton release]; eraserButton = nil;

    [paletteButton release]; paletteButton = nil;

    [rotateCCVButton release]; rotateCCVButton = nil;

    [rotateCVButton release]; rotateCVButton = nil;
    
    [colorPicker removeObserver:self forKeyPath:@"color"];
    [colorPicker release]; colorPicker = nil;
    
    [popoverController release]; popoverController = nil;
}


- (void)dealloc {
    self.delegate = nil;

    self.color = nil;

    [commentButton release]; commentButton = nil;

    [penButton release]; penButton = nil;

    [markerButton release]; markerButton = nil;

    [eraserButton release]; eraserButton = nil;

    [paletteButton release]; paletteButton = nil;

    [rotateCCVButton release]; rotateCCVButton = nil;

    [rotateCVButton release]; rotateCVButton = nil;
    
    [colorPicker removeObserver:self forKeyPath:@"color"];
    [colorPicker release]; colorPicker = nil;

    [popoverController release]; popoverController = nil;
    
    [super dealloc];

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
    CGFloat y = round((barSize.height - (buttonSize.height + spaceBetweenButtons) * [buttons count] + spaceBetweenButtons) / 2)+topOffset;
    CGFloat x = round((barSize.width - buttonSize.width) / 2);
    for(UIView *button in buttons)
    {
        CGRect frame = CGRectMake(x, y, buttonSize.width, buttonSize.height);
        button.frame = frame;
        y += buttonSize.height + spaceBetweenButtons;
        [self.view addSubview: button];
    }
}
@end