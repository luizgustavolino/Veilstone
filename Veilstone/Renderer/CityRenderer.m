//
//  CityRenderer.m
//  Veilstone
//
//  Created by Nilo on 26/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import "CityRenderer.h"
#import "MainRenderer.h"
#import "ModelCache.h"

#import <glm/glm.hpp>
#import <glm/gtc/matrix_transform.hpp>

#include "common/controls.hpp"

using namespace glm;

@interface CityRenderer (/*private*/){
    GLuint matrixID;
}

@end

@implementation CityRenderer

-(void) onLoad {
    
    [super onLoad];
    [self loadShadersNamed:@"vox"];
    [self loadTextureNamed:@"magika"];
    
    matrixID = glGetUniformLocation(shaderProgramID, "MVP");
    
    int indexCounter = 0;
    int mapSize = [[MainRenderer shared].delegate mapSize];
    
    for (int i = 0; i < mapSize; i++) {
        for (int j = 0; j < mapSize; j++) {
            for (int d = 0; d < 4; d++) {
                
                int buildingID = [[MainRenderer shared].delegate
                                  buildingForPX:j PY:i];
                
                const char *filename;
                
                GLfloat dx = 0;
                GLfloat dz = 0;
                
                switch(d) {
                    case 0:
                        filename = buildingID > 9 ?
                        "res/25x5xroad.obj" : "res/25x5xgreen.obj";
                        dz = -15.0f; break;
                        
                    case 1:
                        filename = buildingID > 9 ?
                        "res/5x25xroad.obj" : "res/5x25xgreen.obj";
                        dx = -15.0f; break;
                        
                    case 2:
                        filename = buildingID > 9 ?
                        "res/5x5xrggg.obj" : "res/5x5xgggg.obj";
                        dz = -15.0f; dx = -15.0f;
                        break;
                        
                    default:
                        char buildingFileName[128];
                        sprintf(buildingFileName, "res/build%d.obj", buildingID);
                        filename = buildingFileName;
                }
                
                ModelCacheItem *item = [[ModelCache shared]
                                        itemForFileNamed:filename];
                
                for(glm::vec2 uv : item.riUVs) uvs.push_back(uv);
                for(glm::vec3 n : item.riNs) normals.push_back(n);
                
                for(glm::vec3 rv : item.riVs){
                    glm::vec3 nv = glm::vec3(rv.x + (i * 30.0f) + dx, rv.y,
                                             rv.z + (j * 30.0f) + dz);
                    vertices.push_back(nv);
                }
                
                for(unsigned short ri : item.rIx) {
                    indices.push_back(ri + indexCounter);
                }
                
                indexCounter += item.rIx.size();
            }
        }
    }
    

}

-(void) onFrameNum:(int)frameCount{
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    
    [super onFrameNum:frameCount];
}

-(void) beforeBinds {
    
    computeMatricesFromInputs();
    
    glm::mat4 ProjectionMatrix = getProjectionMatrix();
    glm::mat4 ViewMatrix = getViewMatrix();
    glm::mat4 ModelMatrix = glm::mat4(1.0);
    glm::mat4 MVP = ProjectionMatrix * ViewMatrix * ModelMatrix;
    
    glUniformMatrix4fv(matrixID, 1, GL_FALSE, &MVP[0][0]);
}

-(int) glTextureIndex{
    return 2;
}

-(int) glTextureName{
    return GL_TEXTURE2;
}

-(void) onExit{
    [super onExit];
}

@end
