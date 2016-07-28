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
	NSLog(@"Compute Function: %@",fnc);
	id<MTLFunction> mtlfnc = [context.library newFunctionWithName:fnc];
	return [[self alloc] initWithContext:context Function:mtlfnc];
}

-(instancetype)initWithContext:(MUComputeContext *)context Function:(id<MTLFunction>)fnc
{
	if ((self = [super init])) {
		self.context = context;
		[self.context.device newComputePipelineStateWithFunction:fnc completionHandler:^(id<MTLComputePipelineState>  _Nullable computePipelineState, NSError * _Nullable error) {
			self.pipeline = computePipelineState;
			
		}];
	}
	return self;
}

-(void)dispatch
{
	
	id<MTLCommandBuffer> commandBuffer = [self.context.queue commandBuffer];
	
	id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
	[encoder setComputePipelineState:self.pipeline];
	
	if (self.resourceManager != nil) {
		[self.resourceManager.resources enumerateKeysAndObjectsUsingBlock:^(NSString* key, MUTexture* obj, BOOL * _Nonnull stop) {
			if (obj) {
				[encoder setTexture:obj.tex atIndex:((NSUInteger)[key integerValue])];
			}
		}];
	
		MTLSize imsize = ((MUTexture*)[self.resourceManager.resources valueForKey:@"0"]).size;
		MTLSize threadDim = MTLSizeMake(1, 1, 1);
		MUTexture* filter = ((MUTexture*)[self.resourceManager.resources valueForKey:@"2"]);
		if (filter) {
			threadDim = filter.size;
		}
		MTLSize blockDim = MTLSizeMake(imsize.width/threadDim.width, imsize.height/threadDim.height, 1);
		[encoder dispatchThreadgroups:blockDim threadsPerThreadgroup:threadDim];
		[encoder endEncoding];
	
		[commandBuffer commit];
		[commandBuffer waitUntilCompleted];
	}
}



@end
