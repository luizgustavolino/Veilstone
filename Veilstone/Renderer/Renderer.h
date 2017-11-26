//
//  Renderer.h
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GL/glew.h>
#import <vector>
#import <glm/glm.hpp>

@interface Renderer : NSObject{
    GLuint vertexbuffer;
    GLuint uvbuffer;
    GLuint normalbuffer;
    GLuint elementbuffer;
    
    std::vector<glm::vec3> vertices;
    std::vector<glm::vec2> uvs;
    std::vector<glm::vec3> normals;
    std::vector<unsigned int> indices;
    
    GLuint shaderProgramID;
}

// Gameloop

-(void) onLoad;
-(void) onFrameNum:(int) frameCount;
-(void) onExit;

// Helpers
-(void) chargeBuffers;
-(void) loadShadersNamed:(NSString*) name;

@end
