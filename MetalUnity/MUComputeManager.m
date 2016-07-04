//
//  MUComputeManager.m
//  MetalUnity
//
//  Created by Tyler Payne on 7/3/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUComputeManager.h"
#import "MUComputeContext.h"
#import "MUResourceManager.h"
#import "MUTexture.h"

@implementation MUComputeManager

+(instancetype)newComputeManagerWithContext:(MUComputeContext *)context Function:(NSString*)fnc
{
	id<MTLFunction> mtlfnc = [context.library newFunctionWithName:fnc];
	return [[self alloc] initWithContext:context Function:mtlfnc];
}

-(instancetype)initWithContext:(MUComputeContext *)context Function:(id<MTLFunction>)fnc
{
	if ((self = [super init])) {
		self.context = context;
		self.encoder = [self.context.commandBuffer computeCommandEncoder];
		[self.context.device newComputePipelineStateWithFunction:fnc completionHandler:^(id<MTLComputePipelineState>  _Nullable computePipelineState, NSError * _Nullable error) {
			self.pipeline = computePipelineState;
			[self.encoder setComputePipelineState:self.pipeline];
			
		}];
	}
	return self;
}

-(void)setResourcesFromManager:(MUResourceManager *)manager
{
	self.resourceManager = manager;
	[manager.resources enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MUTexture* obj, BOOL * _Nonnull stop) {
		if (obj) {
			[self.encoder setTexture:obj.tex atIndex:((NSUInteger)[key integerValue])];
		}
	}];
}

-(void)setCompletionHandler:(void (^)(id<MTLCommandBuffer> cmdBuff))completionBlock
{
	[self.context.commandBuffer addCompletedHandler:completionBlock];
}

-(void)dispatch
{
	NSUInteger totalThreads = [self.pipeline maxTotalThreadsPerThreadgroup];
	MTLSize imsize = ((MUTexture*)[self.resourceManager.resources valueForKey:@"0"]).size;
	MTLSize threadDim = MTLSizeMake(totalThreads/(imsize.depth+1),totalThreads/(imsize.depth+1),imsize.depth);
	MTLSize blockDim = MTLSizeMake(imsize.width/threadDim.width, imsize.height/threadDim.height, imsize.depth/threadDim.depth);
	[self.encoder dispatchThreadgroups:threadDim threadsPerThreadgroup:blockDim];
	[self.encoder endEncoding];
	
	[self.context.commandBuffer commit];

}



@end
