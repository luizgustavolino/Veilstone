//
//  JSActionButton.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>
#import "JSAction.h"

@interface JSActionButton : JSAction {
	int max;
	BOOL active;
}

-(id)initWithIndex: (int)newIndex andName: (NSString*)newName;
@property(readwrite) int max;

@end
