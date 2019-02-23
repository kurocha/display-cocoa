//
//  Application.hpp
//  This file is part of the "Display Cocoa" project, and is released under the MIT license.
//
//  Created by Samuel Williams on 14/09/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#pragma once

#include <Display/Application.hpp>

#ifdef __OBJC__
@class NSAutoreleasePool;
#endif

namespace Display
{
	namespace Cocoa
	{
		class Application : public Display::Application
		{
		public:
			Application();
			virtual ~Application ();
			
			virtual void run();
			virtual void stop();
			
		protected:
			virtual void setup();
			
#ifdef __OBJC__
			NSAutoreleasePool * _pool;
#else
			void * _pool;
#endif
		};
	}
}
