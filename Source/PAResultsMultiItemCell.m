// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PAResultsMultiItemCell.h"


@implementation PAResultsMultiItemCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	if (self)
	{
		// nothing
	}	
	return self;
}

- (void)dealloc
{
	if(items) [items release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	NSEnumerator *enumerator = [[controlView subviews] objectEnumerator];
	id anObject;
	
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAResultsMultiItemMatrix class]])
		{			
			NSArray *theseItems = [(PAResultsMultiItemMatrix *)anObject items];			
			
			if([items isEqualTo:theseItems])			
				matrix = anObject;
		}
	}
	
	// Ensure matrix isn't hidden
	[matrix setHidden:NO];
	
	CGFloat offsetToRightBorder = 20;
	NSRect rect = NSMakeRect(cellFrame.origin.x + 15,
							 cellFrame.origin.y,
							 cellFrame.size.width - offsetToRightBorder,
							 cellFrame.size.height);
							 
	if([matrix superview] != controlView)
	{	
		matrix = [[PAResultsMultiItemMatrix alloc] initWithFrame:rect];
		
		Class cellClass = [PAResultsMultiItemThumbnailCell class];
		[matrix setCellClass:cellClass];
		[matrix setDelegate:[controlView delegate]];
		
		[matrix setItems:items];	
		[matrix setSelectedItems:[controlView selectedItems]];
		[controlView addSubview:matrix];
	}
	else
	{
		[matrix setFrame:rect];
	}
	
	if(![self isHighlighted])
	{
		// Buggy...
		//[matrix deselectAllCells];
		//[matrix deselectSelectedCell];
	} else {
		
		// Also buggy...
		/*if(![matrix selectedCell])
		{
			// Select one item on highlighting
			if([controlView lastUpDownArrowFunctionKey] == NSDownArrowFunctionKey ||
			   [controlView lastUpDownArrowFunctionKey] == NSUpArrowFunctionKey)
			{
				int row = 0;
				int column = 0;

				if([controlView lastUpDownArrowFunctionKey] == NSUpArrowFunctionKey)
					row = [matrix numberOfRows] - 1;
			
				// Select upper left item
				[matrix selectCellAtRow:row column:column];
				[matrix highlightCell:YES atRow:row column:column];
			}
		}
		[controlView setLastUpDownArrowFunctionKey:0];
		
		// Make matrix the first responder
		[controlView setResponder:matrix];*/
	}
	[controlView setResponder:matrix];
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


#pragma mark Accessors
- (id)objectValue
{
	return items;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	if(items) [items release];
	items = [object retain];
}

@end
