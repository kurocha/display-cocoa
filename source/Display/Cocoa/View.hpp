//
//  View.hpp
//  This file is part of the "Display Cocoa" project and released under the MIT License.
//
//  Created by Samuel Williams on 19/2/2019.
//  Copyright, 2019, by Samuel Williams. All rights reserved.
//

#pragma once

#import <AppKit/AppKit.h>

#include <Input/Handler.hpp>

@interface DCView : NSView

@property(nonatomic, assign) Input::Handler * handler;

- (void)warpCursorToCenter;

@end
