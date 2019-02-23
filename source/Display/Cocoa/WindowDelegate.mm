//
//  DCWindowDelegate.mm
//  This file is part of the "Display Cocoa" project, and is released under the MIT license.
//
//  Created by Samuel Williams on 1/03/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#import "WindowDelegate.hpp"

@implementation DCWindowDelegate

@synthesize window = _window;

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	return NSTerminateNow;
	// NSTerminateCancel - The app should not be terminated.
}

- (BOOL)windowShouldClose:(id)sender
{
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
}

- (void)windowDidResignKey:(NSNotification *)notification
{
}

- (void)windowDidChangeScreen:(NSNotification *)notification
{
}

- (void)windowDidChangeScreenProfile:(NSNotification *)notification
{
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
}

@end
