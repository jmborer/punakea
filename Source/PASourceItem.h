//
//  PASourceItem.h
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PASourceItem : NSObject {

	NSString				*value;
	NSString				*displayName;
	BOOL					selectable;
	BOOL					heading;
	
	NSMutableArray			*children;
	
}

+ (PASourceItem *)itemWithValue:(NSString *)aValue displayName:(NSString *)aDisplayName;

- (NSString *)value;
- (void)setValue:(NSString *)aString;
- (NSString *)displayName;
- (void)setDisplayName:(NSString *)aString;
- (BOOL)isSelectable;
- (void)setSelectable:(BOOL)flag;
- (BOOL)isHeading;
- (void)setHeading:(BOOL)flag;

- (NSArray *)children;
- (void)addChild:(PASourceItem *)anItem;

@end
