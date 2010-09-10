//
//  AttachmetsViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 11.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "ImageScrollView.h"
#import "Attachment.h"
#import "AttachmentPageViewController.h"
#import "AttachmentPage.h"

@implementation AttachmentsViewController
@synthesize attachment, currentPage, commenting;

-(void) setAttachment:(Attachment*) anAttachment
{
    if (attachment != anAttachment) 
    {
        [attachment release];
        attachment = [anAttachment retain];
    }
    [currentPage saveContent];
    currentPage.attachment = attachment;
    nextPage.attachment = attachment;
    currentPage.pageIndex = 0;
    nextPage.pageIndex = 1;
}

#pragma mark -
#pragma mark View loading and unloading

- (void)loadView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"PaperBack.png"];
    
    CGSize imageSize = backgroundImage.size;
    CGRect frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    UIView *v = [[UIView alloc] initWithFrame:frame];
    
    self.view = v;
    
    [v release];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];

//    self.view.backgroundColor = [UIColor redColor];
    //prevent black corners 
    //http://stackoverflow.com/questions/1557856/black-corners-on-uitableview-group-style/1559534#1559534
    [self.view setOpaque: NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //tap recognizer
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;

    //create pages
    currentPage = [[AttachmentPageViewController alloc] init];
	nextPage = [[AttachmentPageViewController alloc] init];
    
    currentPage.attachment = attachment;
    nextPage.attachment = attachment;

    currentPage.pageIndex = 0;
    nextPage.pageIndex = 1;

    [self.view addSubview:nextPage.view];
	[self.view addSubview:currentPage.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [currentPage release];
    currentPage = nil;
    [nextPage release];
    nextPage = nil;
    [tapRecognizer release];
    tapRecognizer = nil;
}

- (void)dealloc
{
    [attachment release];
    [currentPage release];
    [nextPage release];
    [attachment release];
    [tapRecognizer release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

-(void) handleTapFrom:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.view];
    
    CGSize size = self.view.bounds.size;
    
    BOOL tapBottom = (size.height - location.y)<100.0f;
    
    BOOL tapTop = location.y<100.0f;
    
    if (tapTop || tapBottom)
    {
        NSInteger currentPageIndex = [currentPage pageIndex]+(tapTop?-1:1);

        NSUInteger numberOfPages = [attachment.pages count]-1;
        
        if (currentPageIndex<0 || currentPageIndex>numberOfPages) //out of bounds
            return;
        NSInteger nextPageIndex = currentPageIndex+(tapTop?-1:1);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75f];
        [UIView setAnimationTransition:tapTop?UIViewAnimationTransitionCurlDown:UIViewAnimationTransitionCurlUp
                               forView:self.view cache:YES];
        if (tapTop) //page up
        {
            [currentPage.view removeFromSuperview];
            AttachmentPageViewController *swapController = currentPage;
            currentPage = nextPage;
            nextPage = swapController;
            if (currentPage.pageIndex != currentPageIndex)
                currentPage.pageIndex = currentPageIndex;
            nextPage.pageIndex = nextPageIndex;
            [self.view addSubview: currentPage.view];
        }
        else if (tapBottom) //page down
        {
            [currentPage.view removeFromSuperview];
            AttachmentPageViewController *swapController = currentPage;
            currentPage = nextPage;
            nextPage = swapController;
            if (currentPage.pageIndex != currentPageIndex)
                currentPage.pageIndex = currentPageIndex;
            nextPage.pageIndex = nextPageIndex;
            [self.view addSubview: currentPage.view];
        }
        // Commit the changes
        [UIView commitAnimations];
    }
}
#pragma mark -
#pragma mark View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

#pragma mark -
#pragma mark methods
-(void) setCommenting:(BOOL) state
{
    commenting = state;
//    pagingScrollView.canCancelContentTouches = !commenting;
//    pagingScrollView.delaysContentTouches = !commenting;
    [currentPage setCommenting:commenting];
    if (!commenting) 
        [currentPage saveContent];
}

-(void) rotate:(CGFloat) degreesAngle
{
    [currentPage rotate:degreesAngle];
}
@end