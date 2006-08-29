//
//  PASidebar.m
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebarWindow.h"

double const SHOW_DELAY = 0.2;

@interface PASidebarWindow (PrivateAPI)

- (void)show;
- (void)show:(BOOL)animate;
- (void)recede;
- (void)recede:(BOOL)animate;

@end

@implementation PASidebarWindow

#pragma mark init and dealloc
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    /* Enforce borderless window; allows us to handle dragging ourselves */
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:bufferingType defer:flag];
	
    //Set the background color to clear so that (along with the setOpaque call below) we can see through the parts
    //of the window that we're not drawing into
    [self setBackgroundColor: [NSColor clearColor]];
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    [self setLevel: NSStatusWindowLevel];
    //Let's start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [self setOpaque:NO];	
	
	[self setAcceptsMouseMovedEvents:YES];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    appearance = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"Appearance"]];
	
    return self;
}

- (void)awakeFromNib
{
	[self setDelegate:self];
	
	// add tracking reckt for mouse enter and exit events
	NSView *contentView = [self contentView];
	[contentView addTrackingRect:[contentView bounds] owner:self userData:NULL assumeInside:NO];
	
	// move to screen edge - according to prefs
	[self setExpanded:YES];
	[self recede:NO];
	
}

- (void)dealloc
{
	[appearance release];
	[super dealloc];
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
		[self performSelector:@selector(show) withObject:nil afterDelay:SHOW_DELAY];
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
		NSRect newRect = [self frame];
		if ([[appearance objectForKey:@"SidebarPosition"] isEqualToString:@"LEFT"])
		{
			newRect.origin.x = 0;
		}
		else
		{
			newRect.origin.x = newRect.origin.x - newRect.size.width + 1;
		}
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

		if ([[appearance objectForKey:@"SidebarPosition"] isEqualToString:@"LEFT"])
		{
			newRect.origin.x = 0 - newRect.size.width + 1;
		}
		else
		{
			newRect.origin.x = screenRect.size.width - 1;
		}
		
		newRect.origin.y = screenRect.size.height/2 - newRect.size.height/2;
		[self setFrame:newRect display:YES animate:animate];
		[self setExpanded:NO];
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

@end
