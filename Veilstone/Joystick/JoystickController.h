//
//  JoystickController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

@class Joystick;

@protocol JoystickControllerDelegate

-(void) controllerDidInput:(int) code;
-(void) analogDidChange:(int) code value:(double) value;

@end

@interface JoystickController : NSObject {
	NSMutableArray *joysticks;
    NSMutableArray *runningTargets;
	IOHIDManagerRef hidManager;
}

-(void) setup;
-(Joystick*) findJoystickByRef: (IOHIDDeviceRef) device;

@property(readonly) NSMutableArray *joysticks;
@property(readonly) NSMutableArray *runningTargets;
@property (strong) id activity;

@property (nonatomic, assign) id<JoystickControllerDelegate> delegate;

@end
