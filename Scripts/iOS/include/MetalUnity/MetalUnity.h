//
//  MetalUnity.h
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
@class MUComputeContext;
@class MUComputeManager;
@class MUResourceManager;
@class MUTexture;
@class Filters;

@interface MetalUnity : NSObject

@property (strong) MUComputeContext* context;
@property (strong) NSMutableArray* rms;
@property (strong) NSMutableArray* cms;

@property (assign) bool hasContext;

+(instancetype)_setupMetalUnity;
-(instancetype)init;
-(int)_newComputeManagerForFnc:(NSString*)fnc;
-(int)_newResourceManager;
-(void)_dispatchAndCompute:(int)cm ResourceManager:(int)rm;

@end
