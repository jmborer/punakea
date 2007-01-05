//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATagger.h"

@interface PATagger (PrivateAPI)

- (void)writeTags:(NSArray*)someTags toFile:(PAFile*)file;
- (void)writeKeywords:(NSArray*)keywords toFile:(PAFile*)file;

@end

@implementation PATagger

//this is where the sharedInstance is held
static PATagger *sharedInstance = nil;

#pragma mark init
//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	self = [super init];
	if (self)
	{
		tags = [PATags sharedTags];
		
		// TODO move to core
		tagSave = [[PATagSave alloc] init];
	}
	return self;
}

#pragma mark tags and files
/*
- (NSArray*)tagsOnFile:(PAFile*)file
{
	return [self tagsOnFiles:[NSArray arrayWithObject:file] includeTempTags:YES];
}

- (NSArray*)tagsOnFiles:(NSArray*)files
{
	return [self tagsOnFiles:files includeTempTags:YES];
}

- (NSArray*)tagsOnFiles:(NSArray*)files includeTempTags:(BOOL)includeTempTags
{
	NSMutableArray *keywords = [NSMutableArray array];
	
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
	{
		[keywords addObjectsFromArray:[self keywordsForFile:file]];
	}
	
	NSArray *resultTags = [self tagsForNames:keywords includeTempTags:includeTempTags];
	
	return resultTags;	
}

- (PATag*)tagForName:(NSString*)tagName
{
	return [self tagForName:tagName includeTempTag:YES];
}

- (PATag*)tagForName:(NSString*)tagName includeTempTag:(BOOL)includeTempTag
{
	PATag *tag = [tags tagForName:tagName];
	
	if (!tag && includeTempTag)
	{
		tag = [[PATempTag alloc] init];
	}
	
	return tag;
}

- (NSArray*)tagsForNames:(NSArray*)tagNames includeTempTags:(BOOL)includeTempTags
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		PATag *tag = [tags tagForName:tagName];
		
		if (!tag && includeTempTags)
		{
			tag = [[PATempTag alloc] initWithName:tagName];
		}
		
		if (tag && ![result containsObject:tag])
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

- (PATag*)createTagForName:(NSString*)tagName
{
	PATag *tag = [self tagForName:tagName includeTempTag:NO];
	
	if (!tag)
	{
		tag = [simpleTagFactory createTagWithName:tagName];
		[tags addTag:tag];
	}
	
	return tag;
}

- (NSArray*)createTagsForNames:(NSArray*)tagNames
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		PATag *tag = [self tagForName:tagName includeTempTag:NO];
		
		if (!tag)
		{
			tag = [simpleTagFactory createTagWithName:tagName];
			[tags addTag:tag];
		}
		
		if (![result containsObject:tag])
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

- (void)addTags:(NSArray*)someTags toFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
   {
	   NSMutableArray *tagsOnFile = [[[self tagsOnFiles:[NSArray arrayWithObject:file] includeTempTags:YES] mutableCopy] autorelease];
	   NSEnumerator *e = [someTags objectEnumerator];
	   PATag *tag;

	   while (tag = [e nextObject])
	   {
		   if (![tagsOnFile containsObject:tag])
		   {
			   [tagsOnFile addObject:tag];
			   [tag incrementUseCount];
		   }
	   }

	   [self writeTags:tagsOnFile toFile:file];
   }
}

- (void)addKeywords:(NSArray*)keywords toFiles:(NSArray*)files createSimpleTags:(BOOL)createSimpleTags
{
	NSArray *tagArray;
	
	if (createSimpleTags)
	{
		tagArray = [self createTagsForNames:keywords];
	}
	else
	{
		tagArray = [self tagsForNames:keywords includeTempTags:NO];
	}
	
	[self addTags:tagArray toFiles:files];
}

- (NSArray*)keywordsForFile:(PAFile*)file 
{
	return [fileCache keywordsForFile:file];
}

*/

#pragma mark working with tags (renaming and deleting)
- (void)removeTag:(PATag*)tag
{
	PAQuery *query = [[PAQuery alloc] init];
	NSArray *files = [query filesForTag:tag];	
	
	[self removeTag:tag fromFiles:files];
	
	[query release];
}

- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName
{
	PAQuery *query = [[PAQuery alloc] init];
	NSArray *files = [query filesForTag:[self tagForName:tagName]];	
	
	[self renameTag:tagName toTag:newTagName onFiles:files];
	
	[query release];
}

- (void)removeTag:(PATag*)tag fromFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
	{
		// get all tags, remove the specified one, write back to file
		NSMutableArray *someTags = [[[self tagsOnFiles:[NSArray arrayWithObject:file]] mutableCopy] autorelease];
		[someTags removeObject:tag];
		
		// decrement use count here, that way the other classes
		// don't have to care
		[tag decrementUseCount];
		[self writeTags:someTags toFile:file];
	}
}

- (void)removeTags:(NSArray*)someTags fromFiles:(NSArray*)files
{
	NSEnumerator *e = [someTags objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[self removeTag:tag fromFiles:files];
	}
}

- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName onFiles:(NSArray*)files
{
	if ([tagName isEqualToString:newTagName])
	{
		// no renaming needed
		return;
	}
	
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
	{
		// get all tags, rename the specified one (delete/add), write back to file
		NSMutableArray *keywords = [[self keywordsForFile:file] mutableCopy];
		[keywords removeObject:tagName];
		[keywords addObject:newTagName];
		[self writeKeywords:keywords toFile:file];
		[keywords release];
	}
}

- (void)removeAllTagsFromFile:(PAFile *)file
{
	[self writeTags:[NSArray array] toFile:file];
}

#pragma mark private
/*
- (void)writeTags:(NSArray*)someTags toFile:(PAFile*)file
{
	NSMutableArray *keywords = [NSMutableArray array];
		
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
		
	while (tag = [e nextObject])
	{
		[keywords addObject:[tag name]];
	}
	
	[fileCache writeKeywords:keywords toFile:file];
}

- (void)writeKeywords:(NSArray*)keywords toFile:(PAFile*)file
{
	[fileCache writeKeywords:keywords toFile:file];
}
*/

#pragma mark accessors
- (PATags*)tags
{
	return tags;
}

- (void)setTags:(PATags*)allTags
{
	[allTags retain];
	[tags release];
	tags = allTags;
}

#pragma mark singleton stuff
- (void)dealloc {
	[super dealloc];
}

+ (PATagger*)sharedInstance {
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end