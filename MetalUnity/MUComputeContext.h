//
//  MUComputeContext.h
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
@class MUResourceManager;
@class MUComputeManager;

@interface MUComputeContext : NSObject

@property (strong) id<MTLDevice> device;
@property (strong) id<MTLLibrary> library;
@property (strong) id<MTLCommandQueue> queue;
@property (strong) id<MTLCommandBuffer> commandBuffer;
@property (strong) MUResourceManager* resourceManager;
@property (strong) MUComputeManager* computeManager;

+(instancetype)newComputeContext;
-(instancetype)initWithDefaultDevice;
-(MUResourceManager*) newResourceManager;
-(MUComputeManager*) newComputeManagerForFunction:(NSString*)fnc;

@end