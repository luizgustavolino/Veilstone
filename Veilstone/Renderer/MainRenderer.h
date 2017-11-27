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

-(float) currentEnergySupply;
-(float) currentWaterSupply;

@end

@interface MainRenderer : NSObject {
    
}

@property (nonatomic, assign) id<MainRendererDelegate> delegate;

+(MainRenderer*) shared;
-(int) runInFullscreen:(bool) full w:(int) dw h:(int) dh;
-(void) reload;

-(CGSize) windowSize;
-(float) currentEnergySupply;
-(float) currentWaterSupply;

@end
