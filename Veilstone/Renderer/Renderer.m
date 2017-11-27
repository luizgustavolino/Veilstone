//
//  Renderer.m
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import "Renderer.h"

#include "common/shader.hpp"
#include "common/texture.hpp"

@implementation Renderer

-(void) onLoad{
    
}

-(void) onChargeBuffers{
    
    // load vertexbuffer
    if(!vertices.empty()){
        glGenBuffers(1, &vertexbuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     vertices.size() * sizeof(glm::vec3),
                     &vertices[0], GL_STATIC_DRAW);
    }else{
        return;
    }
    
    // load uvbuffer
    if(!uvs.empty()){
        glGenBuffers(1, &uvbuffer);
        glBindBuffer(GL_ARRAY_BUFFER, uvbuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     uvs.size() * sizeof(glm::vec2),
                     &uvs[0], GL_STATIC_DRAW);
    }
    
    // load normals
    if(!normals.empty() && NO){
        glGenBuffers(1, &normalbuffer);
        glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     normals.size() * sizeof(glm::vec3),
                     &normals[0], GL_STATIC_DRAW);
    }
    
    // load indices
    if(!indices.empty() && NO){
        glGenBuffers(1, &elementbuffer);
        glBindBuffer(GL_ARRAY_BUFFER, elementbuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     indices.size() * sizeof(unsigned int),
                     &indices[0], GL_STATIC_DRAW);
    }
    
}

-(void) onFrameNum:(int) frameCount{
    
    if(shaderProgramID) {
        glUseProgram(shaderProgramID);
    }

    // MVP & stuff
    [self beforeBinds];
    
    // // Buffers call is like this:
    // // layout ix, size, type, isNormalized, isStride, array buffer offset
    
    // Bind vertex buffer
    if(!vertices.empty()) {
        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0 );
    }
    
    // Bind uv buffer
    if(!uvs.empty()) {
        glEnableVertexAttribArray(1);
        glBindBuffer(GL_ARRAY_BUFFER, uvbuffer);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, (void*)0 );
    }
    
    // Bind normals buffer
    if(!normals.empty() && NO) {
        glEnableVertexAttribArray(2);
        glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
        glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, (void*)0 );
    }
    
    // Bind element buffer
    if(!indices.empty() && NO) {
        glEnableVertexAttribArray(3);
        glBindBuffer(GL_ARRAY_BUFFER, elementbuffer);
        glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, 0, (void*)0 );
    }
    
    if(textureID != -1) {
        glActiveTexture([self glTextureName]);
        glBindTexture(GL_TEXTURE_2D, texture);
        glUniform1i(textureID, [self glTextureIndex]);
    }
    
    // // Draw calls
    if(indices.empty() || YES) {
        glDrawArrays(GL_TRIANGLES, 0, (int) vertices.size());
    }else{
        glDrawElements(GL_TRIANGLES, (int) indices.size(),
                       GL_UNSIGNED_INT,(void*)0);
    }
    
    // TURN off buffers
    if(vertexbuffer) glDisableVertexAttribArray(0);
    if(uvbuffer) glDisableVertexAttribArray(1);
    if(normalbuffer) glDisableVertexAttribArray(2);
    if(elementbuffer) glDisableVertexAttribArray(3);
    
}

-(void) beforeBinds {

}

-(void) onExit{
    if(shaderProgramID) glDeleteProgram(shaderProgramID);
    if(vertexbuffer) glDeleteBuffers(1, &vertexbuffer);
    if(uvbuffer) glDeleteBuffers(1, &uvbuffer);
    if(normalbuffer) glDeleteBuffers(1, &normalbuffer);
    if(elementbuffer) glDeleteBuffers(1, &elementbuffer);
}

-(int) glTextureIndex{
    return 0;
}

-(int) glTextureName{
    return GL_TEXTURE0;
}

-(void) loadTextureNamed:(NSString*) name{
    
    NSString *path = [NSString stringWithFormat:@"res/%@.png", name];
    const char * file = [path cStringUsingEncoding:NSUTF8StringEncoding];
    
    texture     = loadPNG(file);
    textureID   = glGetUniformLocation(shaderProgramID, "sampler");
    
}

-(void) loadShadersNamed:(NSString*) name{
    
    if (shaderProgramID != 0) {
        NSLog(@"[erro] Já tem um shader!");
        exit(-1);
    }
    
    NSString *vertex = [NSString stringWithFormat:@"res/%@.vertexshader", name];
    NSString *frag = [NSString stringWithFormat:@"res/%@.fragmentshader", name];
    
    shaderProgramID = LoadShaders(
                [vertex cStringUsingEncoding:NSUTF8StringEncoding],
                [frag   cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
