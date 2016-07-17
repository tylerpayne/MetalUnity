//
//  MetalUnity.m
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import "MetalUnity.h"
#import "MUComputeContext.h"
#import "MUComputeManager.h"
#import "MUResourceManager.h"
#import "MUTexture.h"

@implementation MetalUnity

+(instancetype)_setupMetalUnity
{
	return [[self alloc] init];
}


-(instancetype)init
{
	if ((self = [super init])) {
		self.context = [MUComputeContext newComputeContext];
		self.hasContext = true;
		self.hasComputeManager = false;
		self.hasResourceManager = false;
		NSLog(@"Hello From MetalUnity!");
		
	}
	return self;
}

-(void)_generate3x3SobelOperators
{
	if (self.hasResourceManager) {
		MTLTextureDescriptor* sobeltxdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:3 height:3 mipmapped:FALSE];
		id<MTLTexture> x_sobel = [self.context.device newTextureWithDescriptor:sobeltxdesc];
		id<MTLTexture> y_sobel = [self.context.device newTextureWithDescriptor:sobeltxdesc];
	
		const int size = 3;
	
		SInt8 *xweights = (SInt8*)malloc(sizeof(SInt8) * size * size);
		SInt8 *yweights = (SInt8*)malloc(sizeof(SInt8) * size * size);
	
		xweights[0] = -1.0;
		xweights[1] = 0.0;
		xweights[2] = 1.0;
		xweights[3] = -2.0;
		xweights[4] = 0.0;
		xweights[5] = 2.0;
		xweights[6] = -1.0;
		xweights[7] = 0.0;
		xweights[8] = 1.0;
	
		yweights[0] = -1.0;
		yweights[1] = -2.0;
		yweights[2] = -1.0;
		yweights[3] = 0.0;
		yweights[4] = 0.0;
		yweights[5] = 0.0;
		yweights[6] = 1.0;
		yweights[7] = 2.0;
		yweights[8] = 1.0;
	
	
		MTLRegion reg = MTLRegionMake2D(0, 0, 3, 3);
		[x_sobel replaceRegion:reg mipmapLevel:0 withBytes:xweights bytesPerRow:sizeof(SInt8)*size];
		[y_sobel replaceRegion:reg mipmapLevel:0 withBytes:yweights bytesPerRow:sizeof(SInt8)*size];
		[self.resourceManager attachTexture:x_sobel AtIndex:@"2"];
		[self.resourceManager attachTexture:y_sobel AtIndex:@"3"];
		free(xweights);
		free(yweights);
	} else {
		NSLog(@"Cannot Generate Sobel Operator Textures: MetalUnity Context has no assigned Resource Manager");
	}
}


-(void)_newComputeManagerForFnc:(NSString*)fnc
{
	self.computeManager = [self.context newComputeManagerForFunction:fnc];
	self.hasComputeManager = true;
}

-(void)_newResourceManager
{
	self.resourceManager = [self.context newResourceManager];
	self.hasResourceManager = true;
}

-(void)_dispatchAndCompute
{
	if (self.hasComputeManager && self.hasResourceManager) {
		self.computeManager.resourceManager = self.resourceManager;
		[self.computeManager dispatch];
	}
}

@end

extern "C"
{
	//MetalUnity* MU = nil;
	
	MetalUnity* MUSetupMetalUnity()
	{
		return [MetalUnity _setupMetalUnity];
	}
	
	void MUNewComputeManagerForFnc(MetalUnity* MU, NSString* fnc)
	{
		[MU _newComputeManagerForFnc:(NSString*)fnc];
	}
	
	void MUNewResourceManager(MetalUnity* MU)
	{
		[MU _newResourceManager];
	}
	
	void MUGenerate3x3SobelOperators(MetalUnity* MU) {
		[MU _generate3x3SobelOperators];
	}
	
	void MUCompute(MetalUnity* MU)
	{
		[MU _dispatchAndCompute];
	}
	
	void MUAttachTextureAtIndex(MetalUnity* MU, id<MTLTexture> intx, NSString* idx)
	{
		[MU.resourceManager attachTexture:(id<MTLTexture>)intx AtIndex:(NSString*)idx];
	}
	
	id<MTLTexture> MUPrepareIOResources(MetalUnity* MU, NSString* intx)
	{
		//NSLog(@"Input NativeTxtr: %@", intx);
		[MU.resourceManager attachTexture:(id<MTLTexture>)intx AtIndex:@"0"];
		[MU.resourceManager attachOutputTexture];
		//NSLog(@"Output NativeTxtr: %@", ((MUTexture*)[MU.resourceManager.resources objectForKey:@"1"]).tex);
		return ((MUTexture*)[MU.resourceManager.resources objectForKey:@"1"]).tex;
	}
	
}