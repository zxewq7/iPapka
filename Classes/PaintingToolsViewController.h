//
//  PaintingToolsViewController.h
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum _PaintingTool {
	PaintingToolNone = 0,
    PaintingToolComment = 1,
	PaintingToolPen = 2,
	PaintingToolMarker = 3,
	PaintingToolEraser = 4
} PaintingTool;

@class PaintingToolsViewController;

@protocol PaintingToolsDelegate <NSObject>
-(void) paintingView: (PaintingToolsViewController *) sender color:(UIColor *) aColor;
-(void) paintingView: (PaintingToolsViewController *) sender tool: (PaintingTool) aTool;
@end
    

@interface PaintingToolsViewController : UIViewController 
{
    UIButton                  *commentButton;
    UIButton                  *penButton;
    UIButton                  *markerButton;
    UIButton                  *eraserButton;
    
    UIButton                  *paletteButton;
    UIButton                  *rotateCCVButton;
    UIButton                  *rotateCVButton;
    
    id<PaintingToolsDelegate> delegate;
    PaintingTool              tool;
    UIColor                   *color;
}
@property (nonatomic, retain) id<PaintingToolsDelegate> delegate;
@property (nonatomic, assign) PaintingTool              tool;
@property (nonatomic, assign) UIColor                   *color;
@end
