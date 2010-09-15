//
//  PaintingToolsViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PaintingToolsViewController.h"
#import "UIButton+Additions.h"

@interface PaintingToolsViewController(Private)
-(void) alignButtons:(NSArray *) buttons
           topOffset:(CGFloat) topOffset
             barSize:(CGSize) barSize 
 spaceBetweenButtons:(CGFloat) spaceBetweenButtons;
@end

@implementation PaintingToolsViewController

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
                                 selector:nil
                                    image:[UIImage imageNamed:@"ButtonComment.png"]
                            imageSelected:[UIImage imageNamed:@"ButtonCommentSelected.png"]];
    [commentButton retain];
    
    penButton = [UIButton imageButton:self
                                 selector:nil
                                    image:[UIImage imageNamed:@"ButtonPen.png"]
                            imageSelected:[UIImage imageNamed:@"ButtonPenSelected.png"]];
    [penButton retain];

    penButton = [UIButton imageButton:self
                             selector:nil
                                image:[UIImage imageNamed:@"ButtonPen.png"]
                        imageSelected:[UIImage imageNamed:@"ButtonPenSelected.png"]];
    [penButton retain];

    markerButton = [UIButton imageButton:self
                             selector:nil
                                image:[UIImage imageNamed:@"ButtonMarker.png"]
                        imageSelected:[UIImage imageNamed:@"ButtonMarkerSelected.png"]];
    [markerButton retain];

    eraserButton = [UIButton imageButton:self
                                selector:nil
                                   image:[UIImage imageNamed:@"ButtonErase.png"]
                           imageSelected:[UIImage imageNamed:@"ButtonEraseSelected.png"]];
    [eraserButton retain];

    [self alignButtons:[NSArray arrayWithObjects:commentButton, penButton, markerButton, eraserButton, nil] 
             topOffset:0
               barSize:CGSizeMake(contentSize.width, FIRST_BAR_HEIGHT)
   spaceBetweenButtons:SPACE_BETWEEN_BUTTONS];

    paletteButton = [UIButton imageButton:self
                                selector:nil
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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