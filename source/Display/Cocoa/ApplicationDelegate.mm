//
//  ApplicationDelegate.mm
//  This file is part of the "Display Cocoa" project, and is released under the MIT license.
//
//  Created by Samuel Williams on 15/09/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#import "ApplicationDelegate.hpp"

@implementation DCApplicationDelegate

@synthesize application = _application;

-(NSString *)applicationName
{
	NSDictionary * bundleInfo = [[NSBundle mainBundle] infoDictionary];
	
	NSString * nameKeys[] = {
		@"CFBundleDisplayName",
		@"CFBundleName",
	};
	
	NSInteger count = sizeof(nameKeys) / sizeof(nameKeys[0]);
	
	for (NSInteger index = 0; index < count; index++) {
		id value = bundleInfo[nameKeys[index]];
		
		if ([value isKindOfClass:[NSString class]]) {
			NSString * name = value;
			
			if ([name length] != 0) {
				return name;
			}
		}
	}
	
	NSString * processName = [[NSProcessInfo processInfo] processName];
	
	if ([processName length] != 0) {
		return processName;
	}
	
	return @"Vizor Application";
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	// If we are running from a raw binary, turn us into a real application:
	[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
	
	/* Create the main menu bar */
	[NSApp setMainMenu:[[NSMenu alloc] init]];

	/* Create the application menu */
	NSString * name = [self applicationName];
	NSMenu * apple_menu = [[NSMenu alloc] initWithTitle:@""];
	
	NSString * title;
	NSMenuItem * menu_item;
	
	/* Add menu items */
	title = [@"About " stringByAppendingString:name];
	[apple_menu addItemWithTitle:title action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];

	[apple_menu addItem:[NSMenuItem separatorItem]];

	title = [@"Hide " stringByAppendingString:name];
	[apple_menu addItemWithTitle:title action:@selector(hide:) keyEquivalent:@"h"];

	menu_item = (NSMenuItem *)[apple_menu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
	[menu_item setKeyEquivalentModifierMask:(NSEventModifierFlagOption|NSEventModifierFlagCommand)];

	[apple_menu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];

	[apple_menu addItem:[NSMenuItem separatorItem]];

	title = [@"Quit " stringByAppendingString:name];
	[apple_menu addItemWithTitle:title action:@selector(terminate:) keyEquivalent:@"q"];
	
	/* Put menu into the menubar */
	menu_item = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
	[menu_item setSubmenu:apple_menu];
	[[NSApp mainMenu] addItem:menu_item];
	[menu_item release];

	/* Tell the application object that this is now the application menu */
	[NSApp performSelector:@selector(setAppleMenu:) withObject:apple_menu];
	// [NSApp setAppleMenu:apple_menu];
	[apple_menu release];

	/* Create the window menu */
	NSMenu * window_menu = [[NSMenu alloc] initWithTitle:@"Window"];
	
	// FullScreen item
	menu_item = [[NSMenuItem alloc] initWithTitle:@"Full Screen" action:@selector(toggleFullScreen:) keyEquivalent:@"f"];
	[window_menu addItem:menu_item];
	[menu_item release];
	
	/* "Minimize" item */
	menu_item = [[NSMenuItem alloc] initWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
	[window_menu addItem:menu_item];
	[menu_item release];
	
	/* Put menu into the menubar */
	menu_item = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
	[menu_item setSubmenu:window_menu];
	[[NSApp mainMenu] addItem:menu_item];
	[menu_item release];
	
	/* Tell the application object that this is now the window menu */
	[NSApp setWindowsMenu:window_menu];
	[window_menu release];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_application->did_finish_launching();
	
	// Bring the application to the foreground.
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	_application->will_terminate();
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	_application->did_enter_foreground();
}

- (void)applicationWillResignActive:(NSNotification *)aNotification
{
	_application->will_enter_background();
}

@end
