//
//  PAFileMatrix.m
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileMatrix.h"


@interface PAFileMatrix (PrivateAPI)

- (void)insertGroupCell:(PAFileMatrixGroupCell *)cell atRow:(int)row;
- (void)insertItemCell:(PAFileMatrixItemCell *)cell atRow:(int)row;

@end

@implementation PAFileMatrix

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[NSTextFieldCell class]];
		[self renewRows:0 columns:1];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	// Update cell size
	[self setCellSize:NSMakeSize(rect.size.width,20)];

	// Draw background
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	
	[super drawRect:rect];
}

- (void)setQuery:(NSMetadataQuery*)aQuery
{
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
}

- (void)updateView
{
	int i, j;
	int row = -1;
	
	NSArray *groupedResults = [query groupedResults];
	for (i = 0; i < [groupedResults count]; i++)
	{
		row++;
		NSMetadataQueryResultGroup *group = [groupedResults objectAtIndex:i];
		
		PAFileMatrixGroupCell* groupCell = [[PAFileMatrixGroupCell alloc] initTextCell:[group value]];
		[self insertGroupCell:groupCell atRow:row];
		[groupCell release];

		for (j = 0; j < [group resultCount]; j++)
		{
			row++;
			NSMetadataItem *item = [group resultAtIndex:j];
			NSString *itemPath = [item valueForAttribute:@"kMDItemPath"];
			PAFileMatrixItemCell* itemCell = [[PAFileMatrixItemCell alloc] initTextCell:itemPath];
			[itemCell setMetadataItem:item];
			[self insertItemCell:itemCell atRow:row];
		}
	}
	
	[self renewRows:(row+1) columns:1];	
}

- (void)insertGroupCell:(PAFileMatrixGroupCell *)cell atRow:(int)row
{
	if ([self numberOfRows] <= row ||
	    ![[cell key] isEqualTo:[[self cellAtRow:row column:0] key]])
	{		
		[self insertRow:row];
		[self putCell:cell atRow:row column:0];
	}
}

- (void)insertItemCell:(PAFileMatrixItemCell *)cell atRow:(int)row
{
	if ([self numberOfRows] <= row ||
	    ![[cell key] isEqualTo:[[self cellAtRow:row column:0] key]])
	{		
		[self insertRow:row];
		[self putCell:cell atRow:row column:0];
	}
}

- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self updateView];
	}
}

- (void)dealloc
{
   [super dealloc];
}
@end