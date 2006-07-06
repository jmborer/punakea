#import "SidebarController.h"

@interface SidebarController (PrivateAPI)

- (void)addTagToFileTags:(PATag*)tag;
- (void)updateTagsOnFile;

@end

@implementation SidebarController

- (void)awakeFromNib 
{
	tagger = [PATagger sharedInstance];
	
	//TODO can be done from IB ... do this!
	//init sorting
	NSSortDescriptor *popularDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO] autorelease];
	NSArray *popularSortDescriptors = [NSArray arrayWithObject:popularDescriptor];
	[popularTags setSortDescriptors:popularSortDescriptors];
	
	//TODO asc or desc?!
	NSSortDescriptor *recentDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"lastUsed" ascending:NO] autorelease];
	NSArray *recentSortDescriptors = [NSArray arrayWithObject:recentDescriptor];
	[recentTags setSortDescriptors:recentSortDescriptors];
	
	//observe files on fileBox
	[fileBox addObserver:self forKeyPath:@"files" options:0 context:NULL];
	
	//drag & drop
	[popularTagsTable registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	popularTagTableController = [[PASidebarTableViewDropController alloc] initWithTags:popularTags];
	[popularTagsTable setDataSource:popularTagTableController];
	
	[recentTagsTable registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	recentTagTableController = [[PASidebarTableViewDropController alloc] initWithTags:recentTags];
	[recentTagsTable setDataSource:recentTagTableController];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"files"]) 
		[self newFilesHaveBeenDropped];
}

#pragma mark tag field delegates
//TODO only on hitting enter!!!
/* deprecated - use taggerController instead
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSString *tmpString = [tagField stringValue];
	
	//only if there is any text in the field
	if (![tmpString isEqualToString:@""])
	{
		PASimpleTag *tag = [[controller tags] simpleTagForName:tmpString];

		[self addTagToFileTags:tag];
		[self updateTagsOnFile];
	}
}

#pragma mark click targets
- (void)addPopularTag 
{
	if ([[popularTags selectedObjects] count] > 0)
	{
		PATag *tag = [[popularTags selectedObjects] objectAtIndex:0];
		[self addTagToFileTags:tag];
		[self updateTagsOnFile];
	}
}
	
- (void)addRecentTag
{
	if ([[recentTags selectedObjects] count] > 0)
	{
		PATag *tag = [[recentTags selectedObjects] objectAtIndex:0];
		[self addTagToFileTags:tag];
		[self updateTagsOnFile];
	}
}

- (void)removeTagFromFile
{
	if ([[fileTags selectedObjects] count] > 0)
	{
		PATag *tag = [[fileTags selectedObjects] objectAtIndex:0];
		[fileTags removeObject:tag];
		[self updateTagsOnFile];
	}
}

- (void)addTagToFileTags:(PATag*)tag
{
	if (![[fileTags arrangedObjects] containsObject:tag])
		[fileTags addObject:tag];
}

- (void)updateTagsOnFile 
{
	NSArray *files = [fileBox files];
	
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *file;
	
	while (file = [fileEnumerator nextObject])
	{
		NSEnumerator *e = [[fileTags arrangedObjects] objectEnumerator];
		PATag *tag;
		
		while (tag = [e nextObject])
			[tag incrementUseCount];
		
		NSLog(@"trying to write %@ to %@",[controller tags],file);
		[tagger writeTagsToFile:[fileTags arrangedObjects] filePath:file];
	}
}
*/

/**
action called on dropping files to FileBox
 */
- (void)newFilesHaveBeenDropped
{
	// if the tagger is already open, add more files
	if (taggerController)
	{
		[taggerController showWindow:nil];
		NSWindow *taggerWindow = [taggerController window];
		[taggerWindow makeKeyAndOrderFront:nil];
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[taggerController addFiles:[fileBox files]];
	}
	// otherwise create new tagger window
	else 
	{
		taggerController = [[TaggerController alloc] initWithWindowNibName:@"Tagger"];
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		NSWindow *taggerWindow = [taggerController window];
		[taggerWindow makeKeyAndOrderFront:nil];
		[taggerController addFiles:[fileBox files]];
	}
}

#pragma mark delegate stuff

// TODO using resultColumn - change this
- (id)tableColumn:(NSTableColumn *)column
	  inTableView:(NSTableView *)tableView
   dataCellForRow:(int)row
{
	if (([[column identifier] isEqualToString:@"recentTags"]) && (row < [[recentTags arrangedObjects] count]))
	{
		PASidebarTagCell *cell = [[PASidebarTagCell alloc] initTextCell:[[[recentTags arrangedObjects] objectAtIndex:row] name]];
		return [cell autorelease];
	}
	else if (([[column identifier] isEqualToString:@"popularTags"]) && (row < [[popularTags arrangedObjects] count]))
	{
		PASidebarTagCell *cell = [[PASidebarTagCell alloc] initTextCell:[[[recentTags arrangedObjects] objectAtIndex:row] name]];
		return [cell autorelease];
	}
	else
	{
		//TODO ok with empty string?
		PASidebarTagCell *cell = [[PASidebarTagCell alloc] initTextCell:@""];
		return [cell autorelease];
	}
}

@end