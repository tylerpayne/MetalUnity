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
	return [[self alloc] initWithContext:context Function:fnc];
}

-(instancetype)initWithContext:(MUComputeContext *)context Function:(NSString*)fnc
{
	self.context = context;
	id<MTLFunction> mtlfnc = [context.library newFunctionWithName:fnc];
	self.computeFunction = fnc;
	NSLog(@"New Compute Manager For Function: %@",self.computeFunction);
	[self.context.device newComputePipelineStateWithFunction:mtlfnc completionHandler:^(id<MTLComputePipelineState> computePipelineState, NSError * error) {
		if (!error)
		{
			NSLog(@"Success: New Compute Pipeline State");
			self.pipeline = computePipelineState;
		}
		else
		{
				NSLog(error.localizedDescription,error.localizedFailureReason,error.localizedRecoverySuggestion);
		}
		NSLog(@"RETURNING NEW COMPUTE PIPELINE COMPLETION BLOCK");
	}];
	NSLog(@"RETURNING COMPUTE PIPELINE STATE");
	return self;
}


-(void)dispatch
{
	if (self.pipeline)
	{
		id<MTLCommandBuffer> commandBuffer = [self.context.queue commandBuffer];
		id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
		[encoder setComputePipelineState:self.pipeline];
		
		if (self.resourceManager != nil) {
			MUTexture*	inTex = [self.resourceManager.resources objectForKey:@"0"];
			//MUTexture* outTex = [self.resourceManager.resources objectForKey:@"1"];
			
			[self.resourceManager.resources enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL * _Nonnull stop) {
				if (obj) {
					if ([self.computeFunction containsString:@"Constant"])
					{
						if ([key containsString:@"2"])
						{
							const float val = [(NSNumber*)obj floatValue];
							[encoder setBytes:&val length:(NSUInteger)sizeof(float) atIndex:((NSUInteger)[key integerValue])];
						}
						
					}
					else
					{
						[encoder setTexture:((MUTexture*)obj).tex atIndex:((NSUInteger)[key integerValue])];
					}
					
				}
			}];
			MTLSize imsize = ((MUTexture*)[self.resourceManager.resources valueForKey:@"0"]).size;
			MTLSize threadDim = MTLSizeMake(1, 1, 1);
			if (![self.computeFunction containsString:@"Constant"])
			{
				MUTexture* filter = ((MUTexture*)[self.resourceManager.resources valueForKey:@"2"]);
				if (filter) {
					if (filter.size.width != inTex.size.width || filter.size.height != inTex.size.height )
					{
						threadDim = filter.size;
					}
				}
			}
			MTLSize blockDim = MTLSizeMake(imsize.width/threadDim.width, imsize.height/threadDim.height, 1);
			//NSLog(@"OuttexDim: %lu, %lu, %lu ... Newinttex: %lu %lu %lu",(unsigned long)outTex.size.width,(unsigned long)outTex.size.height,(unsigned long)outTex.size.depth,(unsigned long)inTex.size.width,(unsigned long)inTex.size.height,(unsigned long)inTex.size.depth);
			//NSLog(@"Dispatch: threadDim=%lu Blockdim=%lu",(unsigned long)threadDim.width,(unsigned long)blockDim.width);
			[encoder dispatchThreadgroups:blockDim threadsPerThreadgroup:threadDim];
			[encoder endEncoding];
			[commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull cb) {
				//NSLog(@"Compute Completed");
			}];
			[commandBuffer commit];
			//[commandBuffer waitUntilCompleted];
		}
	}
}


-(void)dispatchMipMap
{
	if (self.pipeline)
	{
		id<MTLCommandBuffer> commandBuffer = [self.context.queue commandBuffer];
		id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
		[encoder setComputePipelineState:self.pipeline];
		
		id<MTLCommandBuffer> blitBuffer = [self.context.queue commandBuffer];
		id<MTLBlitCommandEncoder> blitCommandEncoder = [blitBuffer blitCommandEncoder];
		
		if (self.resourceManager != nil) {
			MUTexture*	inTex = [self.resourceManager.resources objectForKey:@"0"];
			MUTexture* outTex = [self.resourceManager.resources objectForKey:@"1"];
			
			unsigned long int mipmaplevel = self.resourceManager.mipmaplevel;
			
			MTLTextureDescriptor* texdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Snorm width:inTex.size.width height:inTex.size.height mipmapped:TRUE];
			id<MTLTexture> mipmappedInTex = [self.context.device newTextureWithDescriptor:texdesc];
			
			MTLTextureDescriptor* newtexdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Snorm width:outTex.size.width height:outTex.size.height mipmapped:TRUE];
			id<MTLTexture> newInTex = [self.context.device newTextureWithDescriptor:newtexdesc];
			
			[blitCommandEncoder copyFromTexture:inTex.tex sourceSlice:0 sourceLevel:0 sourceOrigin:MTLOriginMake(0, 0, 0) sourceSize:inTex.size toTexture:mipmappedInTex destinationSlice:0 destinationLevel:0 destinationOrigin:MTLOriginMake(0, 0, 0)];
			[blitCommandEncoder generateMipmapsForTexture:mipmappedInTex];
			
			[blitCommandEncoder copyFromTexture:mipmappedInTex sourceSlice:0 sourceLevel:mipmaplevel sourceOrigin:MTLOriginMake(0, 0, 0) sourceSize:MTLSizeMake(mipmappedInTex.width, mipmappedInTex.height, mipmappedInTex.depth) toTexture:newInTex destinationSlice:0 destinationLevel:0 destinationOrigin:MTLOriginMake(0, 0, 0)];
			
			[blitCommandEncoder endEncoding];
			[blitBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull commandBuff) {
				NSLog(@"BlitCompleteHandler: %@",commandBuff);
				MUTexture *mumipmappedTex = [MUTexture newTexture:newInTex Width:outTex.size.width Height:outTex.size.height Depth:outTex.size.depth];
				[self.resourceManager.resources setObject:mumipmappedTex forKey:@"0"];
				
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
				NSLog(@"OuttexDim: %lu, %lu, %lu ... Newinttex: %lu %lu %lu",(unsigned long)outTex.size.width,(unsigned long)outTex.size.height,(unsigned long)outTex.size.depth,(unsigned long)newInTex.width,(unsigned long)newInTex.height,(unsigned long)newInTex.depth);
				NSLog(@"Dispatch: threadDim=%lu Blockdim=%lu",(unsigned long)threadDim.width,(unsigned long)blockDim.width);
				[encoder dispatchThreadgroups:blockDim threadsPerThreadgroup:threadDim];
				[encoder endEncoding];
				[commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull cb) {
					NSLog(@"Compute Completed");
				}];
				[commandBuffer commit];
			}]; 
			[blitBuffer commit];
			
		}
	}
	
}


@end
