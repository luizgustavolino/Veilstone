//
//  JoystickController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "CoreFoundation/CoreFoundation.h"
#import "Joystick.h"
#import "JoystickController.h"

#import "SubAction.h"
#import "JSActionHat.h"
#import "JSActionButton.h"
#import "JSActionAnalog.h"

@implementation JoystickController

@synthesize joysticks, runningTargets;

-(id) init {
	if(self=[super init]) {
		joysticks = [[NSMutableArray alloc]init];
        runningTargets = [[NSMutableArray alloc]init];
	}
	return self;
}

-(void) finalize {
	for(int i=0; i<[joysticks count]; i++) {
		[[joysticks objectAtIndex:i] invalidate];
	}
	IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
	CFRelease(hidManager);
	[super finalize];
}

static NSMutableDictionary* create_criterion( UInt32 inUsagePage, UInt32 inUsage )
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject: [NSNumber numberWithInt: inUsagePage] forKey: (NSString*)CFSTR(kIOHIDDeviceUsagePageKey)];
	[dict setObject: [NSNumber numberWithInt: inUsage] forKey: (NSString*)CFSTR(kIOHIDDeviceUsageKey)];
	return dict;
}

BOOL objInArray(NSMutableArray *array, id object) {
    for (id o in array) {
        if (o == object)
            return true;
    }
    return false;
}

void timer_callback(CFRunLoopTimerRef timer, void *ctx) {
    
}

void input_callback(void* inContext, IOReturn inResult, void* inSender, IOHIDValueRef value) {
	
    JoystickController* self = (JoystickController*)inContext;
	IOHIDDeviceRef device = (IOHIDDeviceRef) inSender;
	Joystick* js = [self findJoystickByRef: device];

    JSAction* mainAction = [js actionForEvent: value];
    if(mainAction == NULL) return;
    
    if([mainAction isKindOfClass:[JSActionAnalog class]]) {
        double value = [(JSActionAnalog*) mainAction discreteThreshold];
        [self.delegate analogDidChange:mainAction.index value:value];
    }else{
        [self.delegate controllerDidInput:mainAction.index];
    }
    
}

int findAvailableIndex(id list, Joystick* js) {
	BOOL available;
	Joystick* js2;
	for(int index=0;;index++) {
		available = YES;
		for(int i=0; i<[list count]; i++) {
			js2 = [list objectAtIndex: i];
			if([js2 vendorId] == [js vendorId] && [js2 productId] == [js productId] && [js index] == index) {
				available = NO;
				break;
			}
		}
		if(available)
			return index;
	}
}

void add_callback(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
	
    JoystickController* self = (JoystickController*)inContext;
	
	IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);
	IOHIDDeviceRegisterInputValueCallback(device, input_callback, (void*) self);
	
	Joystick *js = [[Joystick alloc] initWithDevice: device];
	[js setIndex: findAvailableIndex([self joysticks], js)];
	[js populateActions];

	[[self joysticks] addObject: js];
    fprintf(stderr, "Find a joy\n");
}
	
-(Joystick*) findJoystickByRef: (IOHIDDeviceRef) device {
    for(int i=0; i<[joysticks count]; i++){
        if([[joysticks objectAtIndex:i] device] == device){
			return [joysticks objectAtIndex:i];
        }
    }
	return NULL;
}	

void remove_callback(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
	JoystickController* self = (JoystickController*)inContext;
	Joystick* match = [self findJoystickByRef: device];
	if(!match) return;
	[[self joysticks] removeObject: match];
	[match invalidate];
}

-(void) setup {
    
    self.activity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"Let joystick commands fire in the background"];
    
    hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    
	NSArray *criteria = [NSArray arrayWithObjects: 
		 create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_Joystick),
		 create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_GamePad),
         create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_MultiAxisController),
	nil];
	
	IOHIDManagerSetDeviceMatchingMultiple(hidManager, (CFArrayRef)criteria);
    
	IOHIDManagerScheduleWithRunLoop(
        hidManager,
        CFRunLoopGetCurrent(),
        kCFRunLoopDefaultMode
    );
    
	IOReturn tIOReturn = IOHIDManagerOpen( hidManager, kIOHIDOptionsTypeNone);
	(void)tIOReturn;
	
	IOHIDManagerRegisterDeviceMatchingCallback( hidManager, add_callback, (void*)self);
	IOHIDManagerRegisterDeviceRemovalCallback( hidManager, remove_callback, (void*)self);
    
    // Setup timer for continuous targets
    /*
    CFRunLoopTimerContext ctx = { 0, (void*)self, NULL, NULL, NULL };
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                                                   CFAbsoluteTimeGetCurrent(), 1.0/80.0,
                                                   0, 0, timer_callback, &ctx);
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopDefaultMode);
    */
    NSLog(@"Listening for controllers");
    
}

	
@end
