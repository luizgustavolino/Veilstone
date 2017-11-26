//
//  MainRenderer.c
//  Veilstone
//
//  Created by Nilo on 14/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <vector>

// GLEW & GLFW & GLM
#include <GL/glew.h>
#include <glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include "common/shader.hpp"
#include "common/texture.hpp"
#include "common/controls.hpp"
#include "common/objloader.hpp"

// ObjC 
#import "MainRenderer.h"
#import "ModelCache.h"

GLFWwindow* window;
using namespace glm;


@interface MainRenderer (){
    
    GLuint FramebufferName;
    GLuint depthProgramID;
    GLuint cardsProgramID;
    GLuint programID;
    
    GLuint depthMatrixID;
    GLuint VertexArrayID;
    
    GLuint MatrixID;
    GLuint ViewMatrixID;
    GLuint ModelMatrixID;
    GLuint DepthBiasID;
    GLuint ShadowMapID;
    GLuint LightInvDirID;
    
    GLuint Texture;
    GLuint CardsTexture;
    GLuint TextureID;
    GLuint CardsTextureID;
    
    GLuint depthTexture;
    
    GLuint vertexbuffer;
    GLuint uvbuffer;
    GLuint normalbuffer;
    GLuint elementbuffer;
    
    GLuint shadowMapSize;
    
    std::vector<unsigned int> indices;
    std::vector<glm::lowp_ivec3> vertices;
    std::vector<glm::vec2> uvs;
    std::vector<glm::lowp_ivec2> normals;
    
    int windowWidth, windowHeight;
    
    double lastTime, currentTime;
    int nbFrames;
}
@end

@implementation MainRenderer

-(int) runInFullscreen:(bool) full w:(int) dw h:(int) dh{
    
    // Load
    fprintf(stderr, "[Renderer] Will take control\n");
    if(![self loadInFullscreen:full w:dw h:dh]) return -1;
    
    // Render
    do [self render];
    while (![self shoudExit]);
    
    // Exit
    return [self exit];
}

-(BOOL) shoudExit{
    return !(glfwGetKey(window, GLFW_KEY_ESCAPE) != GLFW_PRESS
            && glfwWindowShouldClose(window) == 0);
}

-(BOOL) loadInFullscreen:(bool) full w:(int) dw h:(int) dh{
    
    // Inicializa GLFW
    if (!glfwInit()){
        printf("[Renderer] Fail to load GLFW\n");
        return NO;
    }
    
    // Configurando o GLFW
    glfwWindowHint(GLFW_SAMPLES, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    // Abre uma janela e cria seu contexto OpenGL
    if (full == true) {
        window = glfwCreateWindow( dw, dh, "Veilstone",
                                  glfwGetPrimaryMonitor(), NULL);
    } else{
        window = glfwCreateWindow( dw, dh, "Veilstone",
                                  NULL, NULL);
    }
    
    if (window == NULL) {
        printf("[Renderer] Fail to open GLFW window!\n");
        glfwTerminate();
        return NO;
    }
    
    glfwMakeContextCurrent(window);
    
    windowWidth     = dw;
    windowHeight    = dh;
    glfwGetFramebufferSize(window, &windowWidth, &windowHeight);
    
    // Inicializa o GLEW
    
    glewExperimental = true;
    if (glewInit() != GLEW_OK) {
        printf("[Renderer] Fail do load GLEW!\n");
        glfwTerminate();
        return NO;
    }
    
    // Certifica que conseguiremos capturar o ESC
    glfwSetInputMode(window, GLFW_STICKY_KEYS, GL_TRUE);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
    
    // Set the mouse at the center of the screen
    glfwPollEvents();
    glfwSetCursorPos(window, 1024/2, 768/2);
    
    // Fundo azul escuro
    glClearColor(0.2f, 0.2f, 0.65f, 0.0f);
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    
    // GLSL from shaders
    depthProgramID = LoadShaders( "res/DepthRTT.vertexshader",
                                  "res/DepthRTT.fragmentshader");
    depthMatrixID  = glGetUniformLocation(depthProgramID, "depthMVP");
    
    Texture        = loadDDS("res/magika.dds");
    CardsTexture   = loadDDS("res/cards.dds");
    
    [self buildVBO];

    // Render to texture
    
    shadowMapSize = 1024*1;

    FramebufferName = 0;
    glGenFramebuffers(1, &FramebufferName);
    glBindFramebuffer(GL_FRAMEBUFFER, FramebufferName);
    
    glGenTextures(1, &depthTexture);
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    glTexImage2D( GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT16,
                  shadowMapSize, shadowMapSize, 0,
                  GL_DEPTH_COMPONENT, GL_FLOAT, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_R_TO_TEXTURE);
    
    glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, depthTexture, 0);
    glDrawBuffer(GL_NONE);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        return false;
    
    static const GLfloat g_quad_vertex_buffer_data[] = {
        -1.0f, -1.0f, 0.0f,
         1.0f, -1.0f, 0.0f,
        -1.0f,  1.0f, 0.0f,
        -1.0f,  1.0f, 0.0f,
         1.0f, -1.0f, 0.0f,
         1.0f,  1.0f, 0.0f,
    };
    
    GLuint quad_vertexbuffer;
    glGenBuffers(1, &quad_vertexbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, quad_vertexbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(g_quad_vertex_buffer_data), g_quad_vertex_buffer_data, GL_STATIC_DRAW);

    GLuint quad_programID = LoadShaders( "res/Passthrough.vertexshader",
                                         "res/SimpleTexture.fragmentshader"  );
    GLuint texID  = glGetUniformLocation(quad_programID, "textureID");
    
    programID     = LoadShaders( "res/ShadowMapping.vertexshader",
                                 "res/ShadowMapping.fragmentshader" );
    TextureID     = glGetUniformLocation(programID, "myTextureSampler");
    
    cardsProgramID = LoadShaders( "res/hud.vertexshader",
                                   "res/hud.fragmentshader");
    CardsTextureID = glGetUniformLocation(cardsProgramID, "cardsSampler");
    
    // Projection
    MatrixID      = glGetUniformLocation(programID, "MVP");
    ViewMatrixID  = glGetUniformLocation(programID, "V");
    ModelMatrixID = glGetUniformLocation(programID, "M");
    DepthBiasID   = glGetUniformLocation(programID, "DepthBiasMVP");
    ShadowMapID   = glGetUniformLocation(programID, "shadowMap");
    LightInvDirID = glGetUniformLocation(programID, "LightInvDirection_worldspace");

    // Setups
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    return YES;
}

-(void) render {
    
    currentTime = glfwGetTime();
    nbFrames++;
    BOOL useShadow = YES;

    if ( currentTime - lastTime >= 1.0 ){
        fprintf(stderr, "%d fps\n", (int) (1000.0 / (1000.0/double(nbFrames))));
        nbFrames = 0;
        lastTime += 1.0;
    }
    
    // -----[ shadow map shader ]-----
    glm::vec3 lightInvDir;
    glm::mat4 depthMVP;
    
    if (useShadow) {
        
        // Render to our framebuffer (not the screen)
        glBindFramebuffer(GL_FRAMEBUFFER, FramebufferName);
    
        // Clear the buffer
        glViewport(0, 0, shadowMapSize, shadowMapSize);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
        glUseProgram(depthProgramID);
    
        lightInvDir = glm::vec3(50, 200, 200);
        glm::mat4 depthProjectionMatrix = glm::ortho<float>(-400, 400,
                                                        -400, 400,
                                                        -400, 400);
    
        glm::mat4 depthViewMatrix       = glm::lookAt(lightInvDir,
                                                  glm::vec3(0,0,0),
                                                  glm::vec3(0,1,0));
        glm::mat4 depthModelMatrix      = glm::mat4(1.0);
        depthMVP = depthProjectionMatrix * depthViewMatrix * depthModelMatrix;
        glUniformMatrix4fv(depthMatrixID, 1, GL_FALSE, &depthMVP[0][0]);
    
        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
        glVertexAttribPointer(0, 3, GL_INT, GL_FALSE, 0, (void*)0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbuffer);
        glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_INT, (void*)0);
        glDisableVertexAttribArray(0);

        // Now to the screen itself
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glViewport(0, 0, windowWidth, windowHeight);
        
        // Turn back to the screen
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glViewport(0, 0, windowWidth, windowHeight);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        
    }
    
    // -----[ texture shader ]-----
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(programID);
    computeMatricesFromInputs();
    
    glm::mat4 ProjectionMatrix = getProjectionMatrix();
    glm::mat4 ViewMatrix = getViewMatrix();
    glm::mat4 ModelMatrix = glm::mat4(1.0);

    glm::mat4 MVP = ProjectionMatrix * ViewMatrix * ModelMatrix;
    glm::mat4 depthBiasMVP;
    
    if (useShadow) {
        glm::mat4 biasMatrix( 0.5, 0.0, 0.0, 0.0,
                              0.0, 0.5, 0.0, 0.0,
                              0.0, 0.0, 0.5, 0.0,
                              0.5, 0.5, 0.5, 1.0 );
        depthBiasMVP = biasMatrix*depthMVP;
    }

    // Send our transformation to the currently bound shader,
    // in the "MVP" uniform
    glUniformMatrix4fv(MatrixID, 1, GL_FALSE, &MVP[0][0]);
    glUniformMatrix4fv(ModelMatrixID, 1, GL_FALSE, &ModelMatrix[0][0]);
    glUniformMatrix4fv(ViewMatrixID, 1, GL_FALSE, &ViewMatrix[0][0]);

    if (useShadow){
        glUniformMatrix4fv(DepthBiasID, 1, GL_FALSE, &depthBiasMVP[0][0]);
        glUniform3f(LightInvDirID, lightInvDir.x,
                    lightInvDir.y, lightInvDir.z);
        
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, depthTexture);
        glUniform1i(ShadowMapID, 1);
    }

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, Texture);
    glUniform1i(TextureID, 0);

    // > Vertices
    // > UVs
    // > Normals
    // attribute, size, type, normalized?, stride, array buffer offset

    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glVertexAttribPointer( 0, 3, GL_INT, GL_FALSE, 0, (void*)0 );

    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, uvbuffer);
    glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, 0, (void*)0 );

    glEnableVertexAttribArray(2);
    glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
    glVertexAttribPointer( 2, 3, GL_INT, GL_FALSE, 0, (void*)0);

    // > Draw elements
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbuffer);
    glDrawElements( GL_TRIANGLES, indices.size(),
                    GL_UNSIGNED_INT, (void*)0);

    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    
    
    // -> DRAW HUD
    
    glUseProgram(cardsProgramID);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, CardsTexture);
    glUniform1i(CardsTextureID, 2);
    
    static const GLfloat g_vertex_buffer_data[] = {
        10.0f,  10.0f, 0.0f,
        100.0f, 10.0f, 0.0f,
        10.0f,  100.0f, 0.0f,
    };
    
    static const GLfloat g_uv_buffer_data[] = {
        0.0f, 0.0f,
        100.0f, 0.0f,
        0.0f, 100.0f
    };
    
    GLuint hudbuffer;
    glGenBuffers(1, &hudbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, hudbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(g_vertex_buffer_data),
                 g_vertex_buffer_data, GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, hudbuffer);
    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0 );
    
    GLuint huduvbuffer;
    glGenBuffers(1, &huduvbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, huduvbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(g_uv_buffer_data),
                 g_uv_buffer_data, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, huduvbuffer);
    glVertexAttribPointer( 0, 2, GL_FLOAT, GL_FALSE, 0, (void*)0 );
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(0);
    
    // Swap buffers
    glfwSwapBuffers(window);
    glfwPollEvents();
    
}


-(void) buildVBO {
    
    glGenVertexArrays(1, &VertexArrayID);
    glBindVertexArray(VertexArrayID);
    
    std::vector<glm::lowp_ivec3> iVs;
    std::vector<glm::vec2> iUVs;
    std::vector<glm::lowp_ivec3> iNs;
    int indexCounter = 0;
    
    int mapSize = [self.delegate mapSize];
    
    for (int i = 0; i < mapSize; i++) {
        for (int j = 0; j < mapSize; j++) {
            for (int d = 0; d < 4; d++) {
                
                int buildingID = [self.delegate buildingForPX:j PY:i];
                const char *filename;
                
                GLfloat dx = 0;
                GLfloat dz = 0;
                GLfloat rz = 0;
                
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
                
                for(glm::vec2 uv : item.riUVs) iUVs.push_back(uv);
                for(glm::vec3 n : item.riNs) iNs.push_back(n);
                
                for(glm::vec3 rv : item.riVs){
                    glm::vec3 nv = glm::vec3(rv.x + (i * 30.0f) + dx, rv.y,
                                             rv.z + (j * 30.0f) + dz);
                    iVs.push_back(nv);
                }
                
                for(unsigned short ri : item.rIx) indices.push_back(ri + indexCounter);
                indexCounter += item.rIx.size();
            }
        }
    }
    
    glGenBuffers(1, &vertexbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexbuffer);
    glBufferData(GL_ARRAY_BUFFER, iVs.size() * sizeof(glm::lowp_ivec3), &iVs[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &uvbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, uvbuffer);
    glBufferData(GL_ARRAY_BUFFER, iUVs.size() * sizeof(glm::vec2), &iUVs[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &normalbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, normalbuffer);
    glBufferData(GL_ARRAY_BUFFER, iNs.size() * sizeof(glm::lowp_ivec3), &iNs[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &elementbuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), &indices[0] , GL_STATIC_DRAW);
    
}

-(int) exit {
    
    glDeleteBuffers(1, &vertexbuffer);
    glDeleteBuffers(1, &uvbuffer);
    glDeleteBuffers(1, &normalbuffer);
    glDeleteBuffers(1, &elementbuffer);
    
    glDeleteProgram(programID);
    glDeleteTextures(1, &Texture);
    
    glDeleteVertexArrays(1, &VertexArrayID);
    glfwTerminate();
    
    return 0;
}

@end
