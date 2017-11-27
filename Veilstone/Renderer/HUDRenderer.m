//
//  HUDRenderer.m
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import "HUDRenderer.h"
#import "HUDSprite.h"
#import "MainRenderer.h"

@interface HUDRenderer (/*private*/){
    NSMutableArray<HUDSprite*>* sprites;
}
    
@end

@implementation HUDRenderer

-(void) onLoad {
    
    [super onLoad];
    [self loadShadersNamed:@"hud"];
    [self loadTextureNamed:@"texture"];
    
    CGSize size = [[MainRenderer shared] windowSize];
    CGFloat ww  = size.width;
    CGFloat wh  = size.height;
    
    float water = [[MainRenderer shared] currentWaterSupply];
    float energy = [[MainRenderer shared] currentEnergySupply];
    
    sprites = [NSMutableArray arrayWithArray:@[
     // FUNDOS
     [[HUDSprite alloc] initWithFrame:CGRectMake(ww - 240, wh - 100,  240, 100)
                              texture:CGRectMake(0, 0, 240, 100)],
     [[HUDSprite alloc] initWithFrame:CGRectMake(ww - 240, wh - 180,  240, 100)
                              texture:CGRectMake(0, 100, 240, 100)],
     
     // BARRAS
     [[HUDSprite alloc] initWithFrame:CGRectMake(ww-145, wh-69, 20 + 120 * water , 30)
                              texture:CGRectMake(370, 0, 20 + 120 * water , 30)],
     
     [[HUDSprite alloc] initWithFrame:CGRectMake(ww-145, wh-67-80, 20 + 120 * energy, 30)
                              texture:CGRectMake(370, 30, 20 + 120 * energy, 30)],
     
     // ICONES
     [[HUDSprite alloc] initWithFrame:CGRectMake(ww - 240, wh - 100,  120, 100)
                              texture:CGRectMake(250, 0, 120, 100)],
     [[HUDSprite alloc] initWithFrame:CGRectMake(ww - 240, wh - 180,  120, 100)
                              texture:CGRectMake(250, 100, 120, 100)],
     
     
     
    ]];

    for(HUDSprite* sprite in sprites) {
        for(glm::vec3 v : sprite.vertices) vertices.push_back(v);
        for(glm::vec2 uv : sprite.uvs) uvs.push_back(uv);
    }
    
}

-(int) glTextureIndex{
    return 1;
}

-(int) glTextureName{
    return GL_TEXTURE1;
}

-(void) onFrameNum:(int)frameCount{
    
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glDisable(GL_ALPHA_TEST);
    
    [super onFrameNum:frameCount];
    
}


@end



