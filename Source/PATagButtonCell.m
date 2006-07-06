#import "PATagButtonCell.h"

@implementation PATagButtonCell

#pragma mark init
- (id)initWithTag:(PATag*)aTag attributes:(NSDictionary*)attributes
{
	if (self = [super init])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setFileTag:aTag];

		//title
		NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:[fileTag name] attributes:attributes];
		[self setAttributedTitle:titleString];
		[titleString release];
		
		//looks
		[self setBordered:NO];
		
		//state
		[self setHovered:NO];
	}
	return self;
}

#pragma mark drawing
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (isHovered)
	{
		[[NSColor lightGrayColor] set];
		NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:cellFrame];
		[path fill];
	}	
	
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

#pragma mark accessors
- (PATag*)fileTag
{
	return fileTag;
}

- (void)setFileTag:(PATag*)aTag
{
	[aTag retain];
	[fileTag release];
	fileTag = aTag;
}

- (BOOL)isHovered
{
	return isHovered;
}

- (void)setHovered:(BOOL)flag
{
	isHovered = flag;
}

#pragma mark highlighting
- (void)mouseEntered:(NSEvent *)event
{
	[self setHovered:YES];
}

- (void)mouseExited:(NSEvent *)event
{
	[self setHovered:NO];
}

@end
