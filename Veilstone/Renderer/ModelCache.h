//
//  ModelCache.h
//  Veilstone
//
//  Created by Nilo on 22/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdio.h>
#include <stdlib.h>
#include <glm/glm.hpp>
#include <vector>

@interface ModelCacheItem : NSObject

@property(nonatomic) std::vector<glm::vec3> riVs;
@property(nonatomic) std::vector<glm::vec2> riUVs;
@property(nonatomic) std::vector<glm::vec3> riNs;
@property(nonatomic) std::vector<unsigned short> rIx;

@end

@interface ModelCache : NSObject {
    NSMutableDictionary<NSString*, ModelCacheItem*> *cache;
}

+(id) shared;
-(ModelCacheItem*) itemForFileNamed:(const char*) name;

@end
