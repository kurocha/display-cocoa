//
//  Window.cpp
//  This file is part of the "Vizor Platform Cocoa" project and released under the .
//
//  Created by Samuel Williams on 23/2/2019.
//  Copyright, 2019, by Samuel Williams. All rights reserved.
//

#include <UnitTest/UnitTest.hpp>

#include <Display/Cocoa/Window.hpp>

namespace Display
{
	namespace Cocoa
	{
		class ShowWindowApplication : public Application
		{
		public:
			using Application::Application;
			virtual ~ShowWindowApplication() {}
			
			std::unique_ptr<Window> _window;
			
			virtual void did_finish_launching()
			{
				_window = std::make_unique<Window>(*this);
				
				_window->set_cursor(Display::Cursor::HIDDEN);
				
				_window->show();
			}
		};
		
		UnitTest::Suite WindowTestSuite {
			"Display::Cocoa::Window",
			
			{"it should show a window",
				[](UnitTest::Examiner & examiner) {
					ShowWindowApplication application;
					
					application.run();
				}
			},
		};
	}
}
