//
//  HUDSprite.m
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import "HUDSprite.h"
#import "MainRenderer.h"

@implementation HUDSprite

-(id) initWithFrame:(CGRect) frame texture:(CGRect) clip{
    self = [super init];
    self.frame = frame;
    self.textureClip = clip;
    
    [self updateFrame:frame];
    
    return self;
}

-(void) updateFrame:(CGRect) f {
    
    self.frame = f;
    
    float tlX = f.origin.x;
    float tlY = f.origin.y + f.size.height;
    
    float trX = f.origin.x + f.size.width;
    float trY = f.origin.y + f.size.height;
    
    float brX = f.origin.x + f.size.width;
    float brY = f.origin.y;
    
    float blX = f.origin.x;
    float blY = f.origin.y;
    
    _vertices.push_back(glm::vec3( brX,brY, 0.0f));
    _vertices.push_back(glm::vec3( trX,trY, 0.0f));
    _vertices.push_back(glm::vec3( tlX,tlY, 0.0f));
    
    _vertices.push_back(glm::vec3( tlX,tlY, 0.0f));
    _vertices.push_back(glm::vec3( blX,blY, 0.0f));
    _vertices.push_back(glm::vec3( brX,brY, 0.0f));
    
    float ts  = 1024; // texture size
    f = self.textureClip;
    
    tlX = f.origin.x;
    tlY = f.origin.y + f.size.height;
    
    trX = f.origin.x + f.size.width;
    trY = f.origin.y + f.size.height;
    
    brX = f.origin.x + f.size.width;
    brY = f.origin.y;
    
    blX = f.origin.x;
    blY = f.origin.y;
    
    _uvs.push_back(glm::vec2(trX/ts, trY/ts));
    _uvs.push_back(glm::vec2(brX/ts, brY/ts));
    _uvs.push_back(glm::vec2(blX/ts, blY/ts));

    _uvs.push_back(glm::vec2(blX/ts, blY/ts));
    _uvs.push_back(glm::vec2(tlX/ts, tlY/ts));
    _uvs.push_back(glm::vec2(trX/ts, trY/ts));
    
}

@end
