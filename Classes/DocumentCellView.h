@class Document;

@interface DocumentCellView : UIView {
	Document *document;
	NSDateFormatter *dateFormatter;
	BOOL highlighted;
}

@property (nonatomic, retain) Document *document;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end
