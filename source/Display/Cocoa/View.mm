//
//  View.cpp
//  This file is part of the "Display Cocoa" project and released under the MIT License.
//
//  Created by Samuel Williams on 19/2/2019.
//  Copyright, 2019, by Samuel Williams. All rights reserved.
//

#include "View.hpp"

#import <QuartzCore/CAMetalLayer.h>

#include <Input/MotionEvent.hpp>
#include <Input/ButtonEvent.hpp>
#include <Input/RenderEvent.hpp>
#include <Input/ResizeEvent.hpp>
#include <Input/FocusEvent.hpp>

static CVReturn displayLinkCallback(
	CVDisplayLinkRef displayLink,
	const CVTimeStamp* now,
	const CVTimeStamp* outputTime,
	CVOptionFlags flagsIn,
	CVOptionFlags* flagsOut,
	void* target
) {
	if (target) {
		Input::Handler * handler = static_cast<Input::Handler *>(target);
		
		auto frequency = CVGetHostClockFrequency();
		auto at = outputTime->hostTime / frequency;
		
		Input::RenderEvent render_event({}, at);
		
		render_event.apply(*handler);
	}
	
	return kCVReturnSuccess;
}

@implementation DCView {
	CVDisplayLinkRef _displayLink;
	BOOL _warped;
}

@synthesize handler = _handler;

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	if (self.handler) {
		Input::FocusEvent focus_event({}, Input::FocusEvent::GAINED);
		
		focus_event.apply(*self.handler);
	}
	
	return YES;
}

- (BOOL)resignFirstResponder
{
	if (self.handler) {
		Input::FocusEvent focus_event({}, Input::FocusEvent::LOST);
		
		focus_event.apply(*self.handler);
	}
	
	return YES;
}

- (void) warpCursorToCenter
{
	// Warp the mouse cursor to the center of the view.
	NSRect bounds = self.bounds;
	NSPoint viewCenter = NSMakePoint(bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0);
	NSPoint windowCenter = [self convertPoint:viewCenter toView:nil];
	
	NSRect windowCenterRect = {windowCenter, {0, 0}};
	NSPoint screenOffset = [self.window convertRectToScreen:windowCenterRect].origin;
	//NSLog(@"Screen offset: %@", NSStringFromPoint(screenOffset));
	
	NSScreen * screen = self.window.screen;
	//NSLog(@"Screen frame: %@", NSStringFromRect(screen.frame));
	
	CGFloat top = screen.frame.origin.y + screen.frame.size.height;
	CGPoint nextCursorPosition = CGPointMake(screenOffset.x, top - screenOffset.y);
	//NSLog(@"Cursor position: %@", NSStringFromPoint((NSPoint){nextCursorPosition.x, nextCursorPosition.y}));
	
	// This is a horrible hack because CGWarpMouseCursorPosition causes a spurious motion event delta:
	//_warped = YES;
	
	CGWarpMouseCursorPosition(nextCursorPosition);
}

- (void)dealloc
{
	if (_displayLink) {
		CVDisplayLinkRelease(_displayLink);
	}
	
	[super dealloc];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
	[super resizeWithOldSuperviewSize:oldSize];
	
	if (_handler) {
		NSRect bounds = [self bounds];
		
		Input::ResizeEvent resize_event({bounds.size.width, bounds.size.height});
		
		resize_event.apply(*_handler);
	}
}

- (void)viewDidMoveToSuperview
{
	if (_displayLink) {
		CVDisplayLinkRelease(_displayLink);
		_displayLink = nil;
	}
	
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	CVDisplayLinkSetOutputCallback(_displayLink, &displayLinkCallback, static_cast<void *>(_handler));
	CVDisplayLinkStart(_displayLink);
}

- (BOOL)wantsUpdateLayer
{
	return YES;
}

+ (Class)layerClass
{
	return [CAMetalLayer class];
}

- (CALayer*)makeBackingLayer
{
	CALayer * layer = [self.class.layerClass layer];
	
	CGSize viewScale = [self convertSizeToBacking:CGSizeMake(1.0, 1.0)];
	layer.contentsScale = MIN(viewScale.width, viewScale.height);
	
	return layer;
}

#pragma mark -

- (Input::Button) buttonForEvent:(NSEvent *)event
{
	NSEventType type = event.type;
	
	if (type == NSEventTypeLeftMouseDown || type == NSEventTypeLeftMouseUp || type == NSEventTypeLeftMouseDragged) {
		if ([event modifierFlags] & NSEventModifierFlagControl)
			return Input::MouseRightButton;
		
		return Input::MouseLeftButton;
	}
	
	if (type == NSEventTypeRightMouseDown || type == NSEventTypeRightMouseUp || type == NSEventTypeRightMouseDragged)
		return Input::MouseRightButton;
	
	return event.buttonNumber;
}

- (BOOL) handleMouseEvent:(NSEvent *)event
{
	return [self handleMouseEvent:event withButton:[self buttonForEvent:event]];
}

- (BOOL) handleMouseEvent:(NSEvent *)event withButton:(Input::Button)button
{
	if (!self.handler) return NO;
	
	// Convert the point from window base coordinates to view coordinates
	NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
	Input::Position position = {point.x, point.y};
	
	// This is due to a bug in CGWarpMouseCursorPosition - what a horrible hack.
	const NSEventMask mask = NSEventMaskMouseMoved | NSEventMaskLeftMouseDragged | NSEventMaskRightMouseDragged | NSEventMaskOtherMouseDragged;
	if (_warped && (NSEventMaskFromType(event.type) & mask))
	{
		_warped = NO;
		return YES;
	}
	
	// Strictly speaking, this isn't completely correct. A change in position in the view's coordinates would be more accurate, but this isn't so easy to implement with a disassociated cursor. So, we assume that the mouse coordinates and view coordinates have inverse-y and reverse the delta appropriately.
	Input::Delta delta = {event.deltaX, -event.deltaY}; // ignore event.deltaZ
	
	if (button == Input::MouseScroll && event.hasPreciseScrollingDeltas) {
		delta[0] = event.scrollingDeltaX;
		delta[1] = event.scrollingDeltaY;
	}
	
	Input::State state;
	NSEventType type = [event type];
	
	if (button == Input::MouseScroll) {
		// http://developer.apple.com/library/mac/#releasenotes/Cocoa/AppKit.html
		switch (event.momentumPhase) {
			case NSEventPhaseNone:
			case NSEventPhaseChanged:
				state = Input::Pressed;
				break;
				
			default:
				state = Input::Released;
				break;
		}
	} else {
		if (type == NSEventTypeLeftMouseDown || type == NSEventTypeRightMouseDown || type == NSEventTypeOtherMouseDown)
			state = Input::Pressed;
		else if (type == NSEventTypeLeftMouseDragged || type == NSEventTypeRightMouseDragged || type == NSEventTypeOtherMouseDragged)
			state = Input::Dragged;
		else
			state = Input::Released;
	}
	
	// The mouse point is relative to the frame of the view:
	Input::Bounds bounds;
	NSRect frame = self.frame;
	bounds.set_origin({frame.origin.x, frame.origin.y});
	bounds.set_size_from_origin({frame.size.width, frame.size.height});
	
	Input::Key key(Input::DefaultMouse, button);
	Input::MotionEvent motion_event({}, key, state, position, delta, bounds);
	
	return motion_event.apply(*self.handler);
}

- (BOOL) handleButtonEvent:(NSEvent *)event state:(Input::State)state
{
	if (!self.handler) return NO;
	
	Input::Key key(Input::DefaultKeyboard, event.keyCode);
	Input::ButtonEvent button_event({}, key, state);
	
	return button_event.apply(*self.handler);
}

- (void) scrollWheel:(NSEvent *)event
{
	[self handleMouseEvent:event withButton:Input::MouseScroll];
}

- (void) mouseDown: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) mouseDragged: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) mouseUp: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) mouseMoved: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) mouseEntered: (NSEvent*)event
{
	[self handleMouseEvent:event withButton:Input::MouseEntered];
}

- (void) mouseExited: (NSEvent*)event
{
	[self handleMouseEvent:event withButton:Input::MouseExited];
}

- (void) rightMouseDown: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) rightMouseDragged: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) rightMouseUp: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) otherMouseDown: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) otherMouseDragged: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void) otherMouseUp: (NSEvent*)event
{
	[self handleMouseEvent:event];
}

- (void)keyDown:(NSEvent *)event
{
	[self handleButtonEvent:event state:Input::Pressed];
}

- (void)keyUp:(NSEvent *)event
{
	[self handleButtonEvent:event state:Input::Released];
}

#pragma mark -

// - (void)touchesBeganWithEvent:(NSEvent *)event {
// 	NSSet * touches = [event touchesMatchingPhase:NSTouchPhaseBegan inView:self];
// 
// 	for (NSTouch * touch in touches) {
// 		AlignedBox2 bounds = bounds_from_frame(self.frame);
// 		NSPoint point = touch.normalizedPosition;
// 		Vec3 position = bounds.absolute_position_of(vector(point.x, point.y)) << 0.0;
// 
// 		const FingerTracking & ft = _multi_finger_input->begin_motion((FingerID)touch.identity, position);
// 
// 		Key touch_key(DefaultTouchPad, ft.button);
// 
// 		MotionInput motion_input(touch_key, Pressed, ft.position, ft.motion, bounds);
// 		_display_context->process(motion_input);
// 	}
// }
// 
// - (void)touchesMovedWithEvent:(NSEvent *)event {
// 	NSSet * touches = [event touchesMatchingPhase:NSTouchPhaseMoved inView:self];
// 
// 	for (NSTouch * touch in touches) {
// 		AlignedBox2 bounds = bounds_from_frame(self.frame);
// 		NSPoint point = touch.normalizedPosition;
// 		Vec3 position = bounds.absolute_position_of(vector(point.x, point.y)) << 0.0;
// 
// 		const FingerTracking & ft = _multi_finger_input->update_motion((FingerID)touch.identity, position);
// 
// 		Key touch_key(DefaultTouchPad, ft.button);
// 
// 		MotionInput motion_input(touch_key, Dragged, ft.position, ft.motion, bounds);
// 		_display_context->process(motion_input);
// 	}
// }
// 
// - (void)touchesEndedWithEvent:(NSEvent *)event {
// 	NSSet * touches = [event touchesMatchingPhase:NSTouchPhaseEnded inView:self];
// 
// 	for (NSTouch * touch in touches) {
// 		AlignedBox2 bounds = bounds_from_frame(self.frame);
// 		NSPoint point = touch.normalizedPosition;
// 		Vec3 position = bounds.absolute_position_of(vector(point.x, point.y)) << 0.0;
// 
// 		const FingerTracking & ft = _multi_finger_input->finish_motion((FingerID)touch.identity, position);
// 
// 		Key touch_key(DefaultTouchPad, ft.button);
// 
// 		MotionInput motion_input(touch_key, Released, ft.position, ft.motion, bounds);
// 		_display_context->process(motion_input);
// 	}
// }
// 
// - (void)touchesCancelledWithEvent:(NSEvent *)event {
// 	NSSet * touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:self];
// 
// 	for (NSTouch * touch in touches) {
// 		AlignedBox2 bounds = bounds_from_frame(self.frame);
// 		NSPoint point = touch.normalizedPosition;
// 		Vec3 position = bounds.absolute_position_of(vector(point.x, point.y)) << 0.0;
// 
// 		const FingerTracking & ft = _multi_finger_input->finish_motion((FingerID)touch.identity, position);
// 
// 		Key touch_key(DefaultTouchPad, ft.button);
// 
// 		MotionInput motion_input(touch_key, Cancelled, ft.position, ft.motion, bounds);
// 		_display_context->process(motion_input);
// 	}
// }



@end
