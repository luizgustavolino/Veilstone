//
//  HUDSprite.h
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Renderer.h"

@interface HUDSprite : NSObject {
    
}

@property(nonatomic) CGRect frame;
@property(nonatomic) CGRect textureClip;

@property(nonatomic) std::vector<glm::vec3> vertices;
@property(nonatomic) std::vector<glm::vec2> uvs;

-(id) initWithFrame:(CGRect) frame texture:(CGRect) clip;

@end
