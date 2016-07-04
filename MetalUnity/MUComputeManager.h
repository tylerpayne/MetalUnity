//
//  MUComputeManager.h
//  MetalUnity
//
//  Created by Tyler Payne on 7/3/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
@class MUComputeContext;
@class MUResourceManager;

@interface MUComputeManager : NSObject

@property (strong) MUComputeContext* context;
@property (strong) MUResourceManager* resourceManager;
@property (strong) id<MTLComputeCommandEncoder> encoder;
@property (strong) id<MTLComputePipelineState> pipeline;

+(instancetype)newComputeManagerWithContext:(MUComputeContext*)context Function:(NSString*)fnc;
-(instancetype)initWithContext:(MUComputeContext*)context Function:(id<MTLFunction>)fnc;
-(void)setResourcesFromManager:(MUResourceManager*)manager;
-(void)setCompletionHandler:(void(^)(id<MTLCommandBuffer> cmdBuff))completionBlock;
-(void)dispatch;
-(void)dispatchAndDestroy;
-(void)destroy;

@end