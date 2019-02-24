//
//  Window.cpp
//  This file is part of the "Display Cocoa" project and released under the MIT License.
//
//  Created by Samuel Williams on 19/2/2019.
//  Copyright, 2019, by Samuel Williams. All rights reserved.
//

#include "Window.hpp"

#include "View.hpp"
#include "WindowDelegate.hpp"

#include <Logger/Console.hpp>

#include <Input/ResizeEvent.hpp>
#include <Input/RenderEvent.hpp>

namespace Display
{
	namespace Cocoa
	{
		using namespace Logger;
		
		Window::~Window()
		{
			if (_window) {
				[_window release];
			}
			
			if (_view) {
				[_view release];
			}
		}
		
		void Window::set_title(const std::string & title)
		{
			Display::Window::set_title(title);
			
			if (_view)
				update_title();
		}
		
		void Window::update_title()
		{
			_view.window.title = [NSString stringWithUTF8String:_title.c_str()];
		}
		
		void Window::set_cursor(Cursor cursor)
		{
			Display::Window::set_cursor(cursor);
			
			if (_view)
				update_cursor();
		}
		
		void Window::update_cursor()
		{
			if (_cursor == Cursor::HIDDEN) {
				CGDisplayHideCursor(kCGNullDirectDisplay);
				CGAssociateMouseAndMouseCursorPosition(false);
				
				_view.allowedTouchTypes = NSTouchTypeMaskDirect;
				[_view warpCursorToCenter];
			} else {
				_view.allowedTouchTypes = 0;
				
				CGAssociateMouseAndMouseCursorPosition(true);
				CGDisplayShowCursor(kCGNullDirectDisplay);
			}
		}
		
		void Window::show()
		{
			if (!_view) {
				const auto & origin = _layout.bounds.origin();
				const auto & size = _layout.bounds.size();
				NSRect rect = NSMakeRect(origin[0], origin[1], size[0], size[1]);
				
				NSWindowStyleMask style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
				
				if (_layout.fullscreen)
					style |= NSWindowStyleMaskFullScreen;
				
				NSWindow * _window = [[NSWindow alloc] initWithContentRect:rect styleMask:style backing:NSBackingStoreBuffered defer:NO];
				
				_window.acceptsMouseMovedEvents = YES;
				_window.releasedWhenClosed = NO;
				
				// Enable full-screen support:
				_window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary | NSWindowCollectionBehaviorManaged;
				
				DCWindowDelegate * delegate = [[DCWindowDelegate new] autorelease];
				delegate.window = this;
				_window.delegate = delegate;
				
				_window.displaysWhenScreenProfileChanges = NO;
				_window.restorable = NO;
				
				_view = [[DCView alloc] initWithFrame:rect];
				_view.handler = this;
				_view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
				
				_window.contentView = _view;
				
				if (_layout.center)
					[_window center];
				
				_window.initialFirstResponder = _view;
				
				update_title();
			}
			
			//[_handle orderFront:NSApp];
			[_view.window makeKeyAndOrderFront:NSApp];
			[_view.window makeFirstResponder:_view];
			
			update_cursor();
		}
		
		void Window::hide()
		{
			if (_view) {
				[_view.window orderOut:nil];
			}
		}
		
		// void Window::prepare(Layers & layers, Extensions & extensions)
		// {
		// 	extensions.push_back(VK_MVK_MACOS_SURFACE_EXTENSION_NAME);
		// }
		// 
		// void Window::setup_surface()
		// {
		// 	auto surface_create_info = vk::MacOSSurfaceCreateInfoMVK()
		// 		.setPView(_view_controller.view);
		// 
		// 	_surface = _instance.createMacOSSurfaceMVKUnique(surface_create_info, _allocation_callbacks);
		// }
	}
}
