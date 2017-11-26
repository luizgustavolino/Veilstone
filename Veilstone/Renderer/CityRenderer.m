//
//  CityRenderer.m
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import "CityRenderer.h"


@interface CityRenderer (/*private*/)



@end

@implementation CityRenderer

-(void) onLoad {
    [super onLoad];
    [self loadShadersNamed:@"vox"];
}

-(void) onFrameNum:(int)frameCount{
    [super onFrameNum:frameCount];
}

-(void) onExit{
    [super onExit];
}

@end
