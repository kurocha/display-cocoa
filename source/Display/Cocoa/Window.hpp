//
//  Window.hpp
//  This file is part of the "Display Cocoa" project and released under the MIT License.
//
//  Created by Samuel Williams on 19/2/2019.
//  Copyright, 2019, by Samuel Williams. All rights reserved.
//

#pragma once

#include <Display/Window.hpp>
#include <Time/Interval.hpp>

#include "Application.hpp"

#ifdef __OBJC__
@class NSWindow;
@class DCView;
#endif

namespace Display
{
	namespace Cocoa
	{
		class Window : public Display::Window
		{
		public:
			Window(const Application & application, const Layout & layout = Layout()) : Display::Window(application, layout) {}
			virtual ~Window();
			
			virtual void show() override;
			
			virtual void hide() override;
			
			virtual void set_title(const std::string & title) override;
			virtual void set_cursor(Cursor cursor) override;
			
			auto view() const noexcept {return _view;}
			
		protected:
			void update_title();
			void update_cursor();
			
#ifdef __OBJC__
			NSWindow * _window = nullptr;
			DCView * _view = nullptr;
#else
			void * _window = nullptr;
			void * _view = nullptr;
#endif
		};
	}
}
