//
//  ModelCache.m
//  Veilstone
//
//  Created by Nilo on 22/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

#import "ModelCache.h"

#include "common/objloader.hpp"

@implementation ModelCacheItem


@end

@implementation ModelCache

+ (id)shared {
    static ModelCache *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}



-(ModelCacheItem*) itemForFileNamed:(const char*) name{
    
    NSString *oname = [[NSString alloc] initWithCString:name
                                               encoding:NSASCIIStringEncoding];
    
    ModelCacheItem *response = [cache objectForKey:oname];
    
    if (response == nil) {
        response = [[ModelCacheItem alloc] init];

        std::vector<glm::vec3> riVs;
        std::vector<glm::vec2> riUVs;
        std::vector<glm::vec3> riNs;
        std::vector<unsigned short> rIx;
        
        loadAssImp(name, rIx, riVs, riUVs, riNs);
        
        response.rIx    = rIx;
        response.riVs   = riVs;
        response.riUVs  = riUVs;
        response.riNs   = riNs;
        
        [cache setObject:response forKey:oname];
    }
    
    return response;
}

- (void)dealloc{
    [cache release];
    [super dealloc];
}

@end
