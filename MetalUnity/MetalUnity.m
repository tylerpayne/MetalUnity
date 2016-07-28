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

-(void)_generate5x5SobelOperators
{
	if (self.hasResourceManager) {
		MTLTextureDescriptor* sobeltxdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:5 height:5 mipmapped:FALSE];
		id<MTLTexture> x_sobel = [self.context.device newTextureWithDescriptor:sobeltxdesc];
		id<MTLTexture> y_sobel = [self.context.device newTextureWithDescriptor:sobeltxdesc];
		
		const int size = 5;
		
		SInt8 *xweights = (SInt8*)malloc(sizeof(SInt8) * size * size);
		SInt8 *yweights = (SInt8*)malloc(sizeof(SInt8) * size * size);
		
		xweights[0] = -1.0;
		xweights[1] = -2.0;
		xweights[2] = 0.0;
		xweights[3] = 2.0;
		xweights[4] = 1.0;
		xweights[5] = -4.0;
		xweights[6] = -8.0;
		xweights[7] = 0.0;
		xweights[8] = 8.0;
		xweights[9] = 4.0;
		xweights[10] = -6.0;
		xweights[11] = -12.0;
		xweights[12] = 0.0;
		xweights[13] = 12.0;
		xweights[14] = 6.0;
		xweights[15] = -4.0;
		xweights[16] = -8.0;
		xweights[17] = 0.0;
		xweights[18] = 8.0;
		xweights[19] = 4.0;
		xweights[20] = -1.0;
		xweights[21] = -2.0;
		xweights[22] = 0.0;
		xweights[23] = 2.0;
		xweights[24] = 1.0;
		
		yweights[0] = -1.0;
		yweights[1] = -4.0;
		yweights[2] = -6.0;
		yweights[3] = -4.0;
		yweights[4] = -1.0;
		yweights[5] = -2.0;
		yweights[6] = -8.0;
		yweights[7] = -12.0;
		yweights[8] = -8.0;
		yweights[9] = -2.0;
		yweights[10] = 0.0;
		yweights[11] = 0.0;
		yweights[12] = 0.0;
		yweights[13] = 0.0;
		yweights[14] = 0.0;
		yweights[15] = 2.0;
		yweights[16] = 8.0;
		yweights[17] = 12.0;
		yweights[18] = 8.0;
		yweights[19] = 2.0;
		yweights[20] = 1.0;
		yweights[21] = 4.0;
		yweights[22] = 6.0;
		yweights[23] = 4.0;
		yweights[24] = 1.0;
		
		
		MTLRegion reg = MTLRegionMake2D(0, 0, 5, 5);
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
	MetalUnity* MU = nil;
	
	void MUSetupMetalUnity()
	{
		MU = [MetalUnity _setupMetalUnity];
	}
	
	void MUNewComputeManagerForFnc(char* f)
	{
		[MU _newComputeManagerForFnc:[NSString stringWithUTF8String:f]];
	}
	
	void MUNewResourceManager()
	{
		[MU _newResourceManager];
	}
	
	void MUGenerate3x3SobelOperators()
	{
		[MU _generate3x3SobelOperators];
	}
	
	void MUGenerate5x5SobelOperators()
	{
		[MU _generate3x3SobelOperators];
	}
	
	void MUCompute()
	{
		[MU _dispatchAndCompute];
	}
	
	void MUAttachTextureAtIndex(id<MTLTexture> intx, char* idx)
	{
		[MU.resourceManager attachTexture:(id<MTLTexture>)intx AtIndex:[NSString stringWithUTF8String:idx]];
	}
	
	id<MTLTexture> MUPrepareIOResources(id<MTLTexture> intx)
	{
		//NSLog(@"Input NativeTxtr: %@", intx);
		[MU.resourceManager attachTexture:intx AtIndex:@"0"];
		[MU.resourceManager attachOutputTexture];
		//NSLog(@"Output NativeTxtr: %@", ((MUTexture*)[MU.resourceManager.resources objectForKey:@"1"]).tex);
		return ((MUTexture*)[MU.resourceManager.resources objectForKey:@"1"]).tex;
	}
	
}