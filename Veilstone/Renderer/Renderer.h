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
    
    GLuint texture;
    GLuint textureID;
}

// Gameloop
-(void) onLoad;
-(void) onChargeBuffers;
-(void) onFrameNum:(int) frameCount;
-(void) onExit;
-(void) beforeBinds;

-(int) glTextureIndex;
-(int) glTextureName;

// Helpers
-(void) loadShadersNamed:(NSString*) name;
-(void) loadTextureNamed:(NSString*) name;

@end


@interface RendererCache : NSObject{
    NSMutableDictionary* shadersStorage;
    NSMutableDictionary* texturesStorage;
    NSMutableDictionary* pngStorage;
}

+(RendererCache*) shared;
-(GLuint) loadShadersNamed:(NSString*) name;
-(GLuint) loadPNG:(NSString*) name;
-(GLuint) loadTextureNamed:(NSString*) name program:(GLuint) shaderProgramID;

@end
