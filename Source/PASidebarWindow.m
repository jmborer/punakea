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

#import "PASidebarWindow.h"

NSString * const SIDEBAR_SHOW_DELAY_KEYPATH = @"values.General.Sidebar.Delay";
NSString * const SIDEBAR_POSITION_KEYPATH = @"values.General.Sidebar.Position";

@interface PASidebarWindow (PrivateAPI)

- (void)show;
- (void)show:(BOOL)animate;
- (void)recede;
- (void)recede:(BOOL)animate;
- (void)setSticky:(BOOL)flag;
- (BOOL)mouseInWindow;

@end

@implementation PASidebarWindow

#pragma mark init and dealloc
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    /* Enforce borderless window; allows us to handle dragging ourselves */
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:bufferingType defer:flag];
	
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    [self setLevel: NSStatusWindowLevel];
    //Let's start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [self setOpaque:NO];	
	
	// This makes the window semi-transparent, but not its subviews
	[self setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.85]];
	
	[self setAcceptsMouseMovedEvents:YES];
		
	defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	nc = [NSNotificationCenter defaultCenter];
	
    return self;
}

- (void)awakeFromNib
{
	[self setDelegate:self];
	
	// add tracking reckt for mouse enter and exit events
	NSView *contentView = [self contentView];
	[contentView addTrackingRect:[contentView bounds] owner:self userData:NULL assumeInside:NO];
	
	sidebarPosition = [[defaultsController valueForKeyPath:SIDEBAR_POSITION_KEYPATH] integerValue];
	
	[defaultsController addObserver:self 
						 forKeyPath:SIDEBAR_POSITION_KEYPATH 
							options:0 
							context:NULL];

	[nc addObserver:self
		   selector:@selector(windowDidHide:)
			   name:NSApplicationDidHideNotification
			 object:nil];
	
	sidebarShowDelay = [[defaultsController valueForKeyPath:SIDEBAR_SHOW_DELAY_KEYPATH] doubleValue];
	
	// move to screen edge - according to prefs
	[self reset];
	
	[self setSticky:YES];
}

- (void)dealloc
{
	[nc removeObserver:self];
	[defaultsController removeObserver:self forKeyPath:SIDEBAR_POSITION_KEYPATH];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((object == defaultsController) && [keyPath isEqualToString:SIDEBAR_POSITION_KEYPATH])
	{
		sidebarPosition = [[defaultsController valueForKeyPath:SIDEBAR_POSITION_KEYPATH] integerValue];
		[self reset];
	}
}			

#pragma mark events
- (void)mouseEvent
{
	if (![self mouseInWindow])
	{
		[self recede];
	}
	else
	{
		[self performSelector:@selector(show) withObject:nil afterDelay:sidebarShowDelay];
	}
}

- (BOOL)mouseInWindow
{
	NSPoint mouseLocation = [self mouseLocationOutsideOfEventStream];
	NSPoint mouseLocationRelativeToWindow = [self convertBaseToScreen:mouseLocation];
	
	/* DEBUG
	 NSLog(@"mouse: (%f,%f)",mouseLocationRelativeToWindow.x,mouseLocationRelativeToWindow.y);
	 NSLog(@"frame: (%f,%f,%f,%f)",[self frame].origin.x,[self frame].origin.y,[self frame].size.width,[self frame].size.height);
	 */
	
	return (NSPointInRect(mouseLocationRelativeToWindow,[self frame]) || (mouseLocationRelativeToWindow.x == 0));
}

- (void)mouseEntered:(NSEvent *)theEvent 
{
	[self mouseEvent];
}

- (void)mouseExited:(NSEvent *)theEvent 
{
	[self mouseEvent];
}


#pragma mark functionality
- (void)reset
{	
	[self setExpanded:YES];
	[self recede:NO];
}

- (void)show
{
	[self show:YES];
}

- (void)recede
{
	[self recede:YES];
}

- (void)show:(BOOL)animate
{
	if (![self isExpanded] && [self mouseInWindow])
	{
		ProcessSerialNumber serialNumber;
		GetFrontProcess(&serialNumber);
		[self setLastActiveApp:serialNumber];
		[self setActivatesLastActiveApp:YES];
		
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		
		NSRect newRect = [self frame];
		
		switch (sidebarPosition)
		{
			case PASidebarPositionLeft:	
				newRect.origin.x = 0;
				break;
			case PASidebarPositionRight:
				newRect.origin.x = newRect.origin.x - newRect.size.width + 1;
				break;
		}

		[self setAlphaValue:1.0];

		[self setFrame:newRect display:YES animate:animate];
		[self setExpanded:YES];
	}	
}

- (void)recede:(BOOL)animate
{
	if ([self isExpanded])
	{
		NSRect newRect = [self frame];
		NSRect screenRect = [[NSScreen mainScreen] frame];

		switch (sidebarPosition)
		{
			case PASidebarPositionLeft:	
				newRect.origin.x = 0 - newRect.size.width + 1;
				break;
			case PASidebarPositionRight: 
				newRect.origin.x = screenRect.size.width - 1;
				break;
		}
		
		newRect.origin.y = screenRect.size.height/2 - newRect.size.height/2;
				
		[self setFrame:newRect display:YES animate:animate];
		[self setExpanded:NO];
		
		// multiplied with backgroundcolor this has to be > 0.05, or else there
		// won't be drop notifications
		[self setAlphaValue:0.06];
		
		if(animate && [self activatesLastActiveApp])
		{
			[self activateLastActiveApp];
		}
	}
}

#pragma mark accessors
- (BOOL)isExpanded 
{
	return expanded;
}

- (void)setExpanded:(BOOL)flag 
{
	expanded = flag;
}

#pragma mark event
// unhide on hiding ;)
- (void)windowDidHide:(NSNotification*)notification
{
	NSApplication *app = [NSApplication sharedApplication];
	NSArray *windows = [app windows];
	
	NSEnumerator *e = [windows objectEnumerator];
	NSWindow *window;
	
	while (window = [e nextObject])
	{
		// hide all other windows
		if ([[window title] isEqualTo:@"Punakea : Tagger"] || 
			[[window title] isEqualTo:@"Punakea : Browser"] ||
			[[window title] hasPrefix:@"Preferences :"])
			[window orderOut:self];
	}
	
	[app unhideWithoutActivation];
}

#pragma mark expose
- (void) setSticky:(BOOL)flag {
	CGSConnectionID cid;
	CGSWindowID wid;
	
	wid = [self windowNumber];
	cid = _CGSDefaultConnection();
	NSInteger tags[2] = { 0, 0 };
	
	if (!CGSGetWindowTags(cid, wid, tags, 32)) {
		if (flag) {
			tags[0] = tags[0] | 0x00000800;
		} else {
			tags[0] = tags[0] & ~0x00000800;
		}
		CGSSetWindowTags(cid, wid, tags, 32);
	}
}

@end
