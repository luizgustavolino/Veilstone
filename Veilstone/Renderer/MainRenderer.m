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
#import "Renderer.h"
#import "HUDRenderer.h"
#import "CityRenderer.h"

GLFWwindow* window;
using namespace glm;

@interface MainRenderer (){
    
    int windowWidth, windowHeight;
    double lastTime, currentTime;
    int nbFrames;
    GLuint VertexArrayID;
    
    NSMutableArray<Renderer*> *renders;
    NSMutableArray<Renderer*> *nextRenders;
}
@end

@implementation MainRenderer

+ (id)shared {
    static MainRenderer *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(CGSize) windowSize{
    return CGSizeMake(windowWidth, windowHeight);
}

-(float) currentEnergySupply{
    return [[self delegate] currentEnergySupply];
}

-(float) currentWaterSupply{
    return [[self delegate] currentWaterSupply];
}

-(void) shouldChooseNextBuilding{
    //NSArray *options = [[self delegate] options];
    //[[self delegate] didChooseCardWithBuildingID:[options[0] intValue]];
}

-(int) runInFullscreen:(bool) full w:(int) dw h:(int) dh{
    
    fprintf(stderr, "[Renderer] Will take control\n");
    
    // Load, Render, Exit
    
    if(![self loadInFullscreen:full w:dw h:dh]) return -1;
    do {
        [self render];
    }while (![self shoudExit]);
    return [self exit];
}

-(BOOL) shoudExit{
    return !(glfwGetKey(window, GLFW_KEY_ESCAPE) != GLFW_PRESS && glfwWindowShouldClose(window) == 0);
}

-(void) prepareNextRender{
    nextRenders = [@[[CityRenderer new], [HUDRenderer new]] retain];
    for (Renderer* render in nextRenders) [render onLoad];
    for (Renderer* render in nextRenders) [render onChargeBuffers];
}

-(void) swapRenders{
    
    NSMutableArray<Renderer*> *old = renders;
    renders = nextRenders;
    for (Renderer* render in old) {
        [render onExit];
        [render release];
    }
    
    [old release];
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
    window = glfwCreateWindow( dw, dh, "Veilstone",
                              full ? glfwGetPrimaryMonitor():NULL, NULL);
    
    if (window == NULL) {
        printf("[Renderer] Fail to open GLFW window!\n");
        glfwTerminate();
        return NO;
    }
    
    glfwMakeContextCurrent(window);
    
    // Salva o tamanho real da janela
    windowWidth     = dw;
    windowHeight    = dh;
    //glfwGetFramebufferSize(window, &windowWidth, &windowHeight);
    
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
    glGenVertexArrays(1, &VertexArrayID);
    glBindVertexArray(VertexArrayID);
    
    renders = [[NSMutableArray alloc] init];
    
    return YES;
}

-(void) render {
    
    currentTime = glfwGetTime();
    nbFrames++;

    if ( currentTime - lastTime >= 1.0 ) {
        fprintf(stderr, "%d fps\n", (int) (1000.0 / (1000.0/double(nbFrames))));
        nbFrames = 0;
        lastTime += 1.0;
    }
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    for (Renderer* render in renders) {
        [render onFrameNum:nbFrames];
    }
    
    // Swap buffers
    glfwSwapBuffers(window);
    glfwPollEvents();
    
}

-(int) exit {
    
    glDeleteVertexArrays(1, &VertexArrayID);
    
    for (Renderer* render in renders) {
        [render onExit];
    }
    
    glfwTerminate();
    return 0;
}

@end

