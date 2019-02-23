//
//  ApplicationDelegate.hpp
//  This file is part of the "Display Cocoa" project, and is released under the MIT license.
//
//  Created by Samuel Williams on 15/09/11.
//  Copyright (c) 2011 Samuel Williams. All rights reserved.
//

#pragma once

#import <AppKit/AppKit.h>

#include "Application.hpp"

@interface DCApplicationDelegate : NSObject<NSApplicationDelegate>

@property(nonatomic, assign) Display::Cocoa::Application * application;

@end
