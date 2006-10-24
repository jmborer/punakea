//
//  PAResultsMultiItemThumbnailCell.m
//  punakea
//
//  Created by Daniel on 17.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemThumbnailCell.h"


@implementation PAResultsMultiItemThumbnailCell

#pragma mark Init + Dealloc
- (id)initTextCell:(PAQueryItem *)anItem
{
	self = [super initTextCell:anItem];
	if(self)
	{
		// nothing yet
	}	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{		
	// Clear all drawings
	[[NSColor clearColor] set];
	[[NSBezierPath bezierPathWithRect:cellFrame] fill];

	// Attributed string for value
	NSString *value = [item valueForAttribute:(id)kMDItemDisplayName];
	NSMutableAttributedString *valueLabel = [[NSMutableAttributedString alloc] initWithString:value];
	[valueLabel addAttribute:NSFontAttributeName
					   value:[NSFont systemFontOfSize:11]
					   range:NSMakeRange(0, [valueLabel length])];
	
	if([self isHighlighted])
	{
		[valueLabel addAttribute:NSForegroundColorAttributeName
						   value:[NSColor alternateSelectedControlTextColor]
					       range:NSMakeRange(0, [valueLabel length])];
	} else {
		[valueLabel addAttribute:NSForegroundColorAttributeName
						   value:[NSColor textColor]
						   range:NSMakeRange(0, [valueLabel length])];
	}
	
	NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[valueLabel addAttribute:NSParagraphStyleAttributeName
	                   value:paraStyle
				       range:NSMakeRange(0, [valueLabel length])];

	NSSize valueLabelSize = [valueLabel size];
	
	NSRect bezelFrame = cellFrame;
	bezelFrame.origin.y += cellFrame.size.height - 30;
	bezelFrame.size.height = 16;  // Spotlight height

	if([self isHighlighted])
	{	
		[[NSColor alternateSelectedControlColor] set];
		[[NSBezierPath bezierPathWithRoundRectInRect:bezelFrame radius:20] fill];
	}
	
	NSSize padding = NSMakeSize(5,1);
	
	NSRect valueLabelFrame = bezelFrame;
	valueLabelFrame.origin.x = bezelFrame.origin.x + padding.width;
	valueLabelFrame.origin.y += padding.height;
	valueLabelFrame.size.width = bezelFrame.size.width - 2 * padding.width;
	valueLabelFrame.size.height = bezelFrame.size.height - 2 * padding.height;

	[valueLabel drawInRect:valueLabelFrame];
	
	// Draw thumbnail background rect
	bezelFrame = cellFrame;
	bezelFrame.origin.x += 5;
	bezelFrame.origin.y += 1;
	bezelFrame.size.height = 83;
	bezelFrame.size.width = 84;
	
	if([self isHighlighted])
	{	
		[[NSColor gridColor] set];
		[[NSBezierPath bezierPathWithRoundRectInRect:bezelFrame radius:10] fill];
	}	
	
	// Draw thumbnail
	NSImage *thumbImage = [[PAThumbnailManager sharedInstance]
				thumbnailWithContentsOfFile:[item valueForAttribute:(id)kMDItemPath]
				                     inView:controlView
									  frame:cellFrame];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [thumbImage size];
	
	NSPoint targetPoint = NSMakePoint(bezelFrame.origin.x + 4,
									  bezelFrame.origin.y + 4 + (77 - imageRect.size.height) / 2);

	[thumbImage drawAtPoint:targetPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	// Draw last used date
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];		
	NSDate *lastUsedDate = [item valueForAttribute:(id)kMDItemLastUsedDate];
	
	value = [dateFormatter friendlyStringFromDate:lastUsedDate];
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	[fontAttributes setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];		
	[fontAttributes setObject:[NSFont systemFontOfSize:10] forKey:NSFontAttributeName];	
	paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	[paraStyle setAlignment:NSCenterTextAlignment];
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];	
	
	NSRect dateFrame = valueLabelFrame;
	dateFrame.origin.x = cellFrame.origin.x;
	dateFrame.origin.y += 16;
	dateFrame.size.width = cellFrame.size.width;
			
	[value drawInRect:dateFrame withAttributes:fontAttributes];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Renaming Stuff
- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{	
	[self selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:0 length:0];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{	
	NSRect frame = aRect;
	//frame.origin.x -= 2;
	frame.origin.y += frame.size.height - 30;
	//frame.size.width += 4; 
	frame.size.height = 30;
	
	[super selectWithFrame:frame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	
	[textObj setDrawsBackground:YES];
	[textObj setBackgroundColor:[NSColor whiteColor]];
	[textObj setFont:[NSFont systemFontOfSize:11]];
	[textObj setString:[item valueForAttribute:(id)kMDItemDisplayName]];
	
	[textObj selectAll:self];
	
	[[self controlView] setNeedsDisplay:YES];
}


#pragma mark Class methods
+ (NSSize)cellSize
{
	return NSMakeSize(93, 115);
}

+ (NSSize)intercellSpacing
{
	return NSMakeSize(3, 3);
}

@end
