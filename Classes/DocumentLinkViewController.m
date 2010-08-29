    //
//  DocumentLinkViewController.m
//  Meester
//
//  Created by Vladimir Solomenchuk on 28.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DocumentLinkViewController.h"
#import "Document.h"
#import "Attachment.h"
#import "DocumentManaged.h"
#import "AttachmentsViewController.h"

@interface DocumentLinkViewController(Private)
-(void) createToolbar;
@end

@implementation DocumentLinkViewController


#pragma mark -
#pragma mark properties

-(void) setDocument:(DocumentManaged *) aDocument
          linkIndex:(NSUInteger) aLinkIndex 
    attachmentIndex:(NSUInteger) anAttachmentIndex
{
    if (document != aDocument) 
    {
        [document release];
        document = [aDocument retain];
    }
    
    Document *aLink = nil;
    Document *unmanagedDocument = document.document;
    
    if ([unmanagedDocument.links count] < aLinkIndex) 
        aLink = [unmanagedDocument.links objectAtIndex:aLinkIndex];
    else if ([unmanagedDocument.links count])
        aLink = [unmanagedDocument.links objectAtIndex:0];
    
    if (aLink != link) 
    {
        [link release];
        link = [aLink retain];
    }

    Attachment *anAttachment = nil;
    
    if ([link.attachments count] < anAttachmentIndex) 
        anAttachment = [link.attachments objectAtIndex:anAttachmentIndex];
    else if ([link.attachments count])
        anAttachment = [link.attachments objectAtIndex:0];
    
    if (anAttachment != currentAttachment) 
    {
        [currentAttachment release];
        currentAttachment = [anAttachment retain];
    }
    
    self.navigationItem.title  = link.title;
    attachmentsViewController.attachment = currentAttachment;
    
}

#pragma mark -
#pragma mark view lifecycle

- (void)loadView
{
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,180)];
    
    self.view = v;
    
    [v release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"DocumentViewBackground.png"]];
    self.view.backgroundColor = backgroundColor;
    [backgroundColor release];

    CGRect windowFrame = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    CGRect scrollViewRect = CGRectMake(0, 0, windowFrame.size.width, windowFrame.size.height);
    attachmentsViewController = [[AttachmentsViewController alloc] initWithFrame:scrollViewRect];
    
    [self.view addSubview: attachmentsViewController.view];
    attachmentsViewController.attachment = currentAttachment;

        // create back button
    UIButton* backButton = [UIButton buttonWithType:101]; 
        // left-pointing shape!
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:document.title forState:UIControlStateNormal];
        // create button item -- note that UIButton subclasses UIView
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        // add to toolbar, or to a navbar (you should only have one of these!)
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [attachmentsViewController release];
    attachmentsViewController = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

#pragma mark -
#pragma mark Actions
- (void) backAction:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
    [document release];
    [link release];
    [currentAttachment release];
    [attachmentsViewController release];
}


@end
