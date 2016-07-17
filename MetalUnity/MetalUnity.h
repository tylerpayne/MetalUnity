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

@interface MetalUnity : NSObject

@property (strong) MUComputeContext* context;
@property (strong) MUResourceManager* resourceManager;
@property (strong) MUComputeManager* computeManager;

@property (assign) bool hasContext;
@property (assign) bool hasResourceManager;
@property (assign) bool hasComputeManager;

+(instancetype)_setupMetalUnity;
-(instancetype)init;
-(void)_generate3x3SobelOperators;
-(void)_newComputeManagerForFnc:(NSString*)fnc;
-(void)_newResourceManager;
-(void)_dispatchAndCompute;

@end
