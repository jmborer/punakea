//
//  PTHotKeyCenter.h
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Updated by Joel Levin in August 2009 for Snow Leopard/64-bit
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//
//  Contributers:
//      Quentin D. Carnicelli
//      Finlay Dobbie
//      Vincent Pottier

#import <Cocoa/Cocoa.h>
@class PTHotKey;

@interface PTHotKeyCenter : NSObject
{
	NSMutableDictionary*	mHotKeys; //Keys are NSValue of EventHotKeyRef
	NSMutableDictionary*	mHotKeyIDs;
	BOOL					mEventHandlerInstalled;
}

+ (PTHotKeyCenter *)sharedCenter;

- (BOOL)registerHotKey: (PTHotKey*)hotKey;
- (void)unregisterHotKey: (PTHotKey*)hotKey;

- (NSArray*)allHotKeys;
- (PTHotKey*)hotKeyWithIdentifier: (id)ident;

- (void)sendEvent: (NSEvent*)event;

@end
