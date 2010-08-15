#import "DocumentCellView.h"
#import "Document.h"
#import "Resolution.h"

@implementation DocumentCellView

@synthesize document;
@synthesize dateFormatter;
@synthesize highlighted;


- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		/*
		 Cache the formatter. Normally you would use one of the date formatter styles (such as NSDateFormatterShortStyle), but here we want a specific format that excludes seconds.
		 */
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd MMM yyyy"];
		self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}


- (void)Document:(Document *)newDocument {
	
	// If the time zone wrapper changes, update the date formatter and abbreviation string.
	if (document != newDocument) {
		[document release];
		document = [newDocument retain];
	}
	// May be the same wrapper, but the date may have changed, so mark for redisplay.
	[self setNeedsDisplay];
}


- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (highlighted != lit) {
		highlighted = lit;	
		[self setNeedsDisplay];
	}
}


- (void)drawRect:(CGRect)rect {
	
#define LEFT_OFFSET 26
#define RIGHT_OFFSET 17

#define MAIN_FONT_SIZE 20
#define MIN_MAIN_FONT_SIZE 17
#define SECONDARY_FONT_SIZE 14
#define MIN_SECONDARY_FONT_SIZE 14
    
#define TITLE_ROW_TOP 5
#define AUTHOR_ROW_TOP 28
#define DATE_ROW_TOP 46
#define PERFORMERS_ROW_TOP 63
	

	// Color and font for the main text items (time zone name, time)
	UIColor *mainTextColor = nil;
	UIFont *mainFont = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];

	// Color and font for the secondary text items (GMT offset, day)
	UIColor *secondaryTextColor = nil;
	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];

    UIColor *thirdTextColor = nil;
	UIFont *thirdFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];

	// Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
		secondaryTextColor = [UIColor whiteColor];
        thirdTextColor = [UIColor whiteColor];
	}
	else {
		mainTextColor = [UIColor blackColor];
		secondaryTextColor = [UIColor blackColor];
        thirdTextColor = [UIColor darkGrayColor];
		self.backgroundColor = [UIColor whiteColor];
	}
    
    CGRect contentRect = self.bounds;
	
    CGFloat boundsX = contentRect.origin.x;
	CGPoint point;
    CGFloat cellWith = self.frame.size.width-LEFT_OFFSET-RIGHT_OFFSET;
		
        // Set the color for the main text items.
    [mainTextColor set];
		
		/*
		 Draw the title top left; use the NSString UIKit method to scale the font size down if the text does not fit in the given area
         */
    point = CGPointMake(boundsX + LEFT_OFFSET, TITLE_ROW_TOP);
    [document.title drawAtPoint:point forWidth:cellWith withFont:mainFont minFontSize:MIN_MAIN_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        
        // Set the color for the secondary text items.
    [secondaryTextColor set];

        /*
         Draw the author left; use the NSString UIKit method to scale the font size down if the text does not fit in the given area.
         */
    point = CGPointMake(boundsX + LEFT_OFFSET, AUTHOR_ROW_TOP);
    [document.author drawAtPoint:point forWidth:cellWith withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    
		/*
		 Draw the document date, right-aligned in the middle column.
		 To ensure it is right-aligned, first find its width with the given font and minimum allowed font size. Then draw the string at the appropriate offset.
		 */
	NSString *dateString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Date approval", "Date approval"), [dateFormatter stringFromDate:document.date]];
    
	point = CGPointMake(boundsX + LEFT_OFFSET, DATE_ROW_TOP);
	[dateString drawAtPoint:point forWidth:cellWith withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
		
        /*
        Draw the document date, right-aligned in the middle column.
        To ensure it is right-aligned, first find its width with the given font and minimum allowed font size. Then draw the string at the appropriate offset.
        */
    if ([self.document isKindOfClass:[Resolution class]] && [((Resolution *)document).performers count]) 
    {
        [thirdTextColor set];
        
        NSString *performersString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Performers", "Performers"), [[((Resolution *)document).performers allValues] componentsJoinedByString: @", "]];
        
        point = CGPointMake(boundsX + LEFT_OFFSET, PERFORMERS_ROW_TOP);
        [performersString drawAtPoint:point forWidth:cellWith withFont:thirdFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    }
}


- (void)dealloc {
	[document release];
	[dateFormatter release];
    [super dealloc];
}


@end
