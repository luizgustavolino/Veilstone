//
//  MainRenderer.h
//  Veilstone
//
//  Created by Nilo on 14/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MainRendererDelegate

-(int) mapSize;
-(int) buildingForPX:(int) px PY:(int)py;
-(void) didChooseCardWithBuildingID:(int) bid;
-(NSArray<NSNumber*>*) options;

@end

@interface MainRenderer : NSObject {
    
}

@property (nonatomic, assign) id<MainRendererDelegate> delegate;

-(int) runInFullscreen:(bool) full w:(int) dw h:(int) dh;

@end
