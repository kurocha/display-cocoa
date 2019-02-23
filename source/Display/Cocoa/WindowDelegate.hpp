//
//  DCWindowDelegate.hpp
//  This file is part of the "Display Cocoa" project, and is released under the MIT license.
//
//  Created by Samuel Williams on 1/03/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#pragma once

#include "Window.hpp"

#import <AppKit/AppKit.h>

@interface DCWindowDelegate : NSObject<NSWindowDelegate>

@property(nonatomic, assign) Display::Cocoa::Window * window;

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender;
- (BOOL)windowShouldClose:(id)sender;

@end
