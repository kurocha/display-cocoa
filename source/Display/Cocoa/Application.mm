//
//  Application.mm
//  This file is part of the "Dream" project, and is released under the MIT license.
//
//  Created by Samuel Williams on 14/09/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#include "Application.hpp"

#import <AppKit/AppKit.h>
#import "ApplicationDelegate.hpp"

#include <Logger/Console.hpp>

namespace Display
{
	namespace Cocoa
	{
		using namespace Logger;
		
		Application::Application()
		{
			_pool = [NSAutoreleasePool new];
		}
		
		Application::~Application ()
		{
			[(NSAutoreleasePool*)_pool release];
			_pool = nullptr;
		}
		
		void Application::setup()
		{
			[NSApplication sharedApplication];
			
			// Setup the application delegate wrapper:
			DCApplicationDelegate * delegate = [[DCApplicationDelegate alloc] init];
			[delegate setApplication:this];
			
			[NSApp setDelegate:delegate];
		}
		
		void Application::run()
		{
			if (NSApp == nil) {
				setup();
			}
			
			[NSApp run];
		}
		
		void Application::stop()
		{
			[NSApp stop:nil];
		}
	}
}
