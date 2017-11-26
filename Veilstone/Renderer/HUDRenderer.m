//
//  HUDRenderer.m
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import "HUDRenderer.h"

@interface HUDRenderer (/*private*/)

    

@end

@implementation HUDRenderer

-(void) onLoad {
    
    [super onLoad];
    [self loadShadersNamed:@"hud"];
    
    vertices.push_back(glm::vec3(0.0f,  1.0f, 0.0f));
    vertices.push_back(glm::vec3(1.0f,  1.0f, 0.0f));
    vertices.push_back(glm::vec3(1.0f,  0.0f, 0.0f));
    
    vertices.push_back(glm::vec3(1.0f,  0.0f, 0.0f));
    vertices.push_back(glm::vec3(0.0f,  0.0f, 0.0f));
    vertices.push_back(glm::vec3(0.0f,  1.0f, 0.0f));
    
    
    uvs.push_back(glm::vec3(0.0f,  1.0f, 0.0f));
    uvs.push_back(glm::vec3(1.0f,  1.0f, 0.0f));
    uvs.push_back(glm::vec3(1.0f,  0.0f, 0.0f));
    
    uvs.push_back(glm::vec3(1.0f,  0.0f, 0.0f));
    uvs.push_back(glm::vec3(0.0f,  0.0f, 0.0f));
    uvs.push_back(glm::vec3(0.0f,  1.0f, 0.0f));
    
}

@end
