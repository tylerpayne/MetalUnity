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
#import "Filters.h"
#import "MUVideoInput.h"
#import "MUVideoTexture.h"

@implementation MetalUnity

+(instancetype)_setupMetalUnity
{
	return [[self alloc] init];
}

-(instancetype)init
{
	if ((self = [super init])) {
		self.context = [MUComputeContext newComputeContext];
		self.cms = [[NSMutableArray alloc] init];
		self.rms = [[NSMutableArray alloc] init];
		self.hasContext = true;
		NSLog(@"Hello From MetalUnity!");
	}
	return self;
}


-(int)_newComputeManagerForFnc:(NSString*)fnc
{
	[self.cms addObject:[self.context newComputeManagerForFunction:fnc]];
	return (int)[self.cms count]-1;
}

-(int)_newResourceManager
{
	[self.rms addObject:[self.context newResourceManager]];
	return (int)[self.rms count]-1;
}

-(void)_dispatchAndCompute:(int)cm ResourceManager:(int)rm
{
		((MUComputeManager*)[self.cms objectAtIndex:cm]).resourceManager = [self.rms objectAtIndex:rm];
		[[self.cms objectAtIndex:cm] dispatch];
}

-(id<MTLTexture>)_generate3x3SobelXOperator:(int)rm AtIndex:(char*)idx
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters SobelFilter3x3_X:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generate3x3SobelYOperator:(int)rm AtIndex:(char*)idx
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters SobelFilter3x3_Y:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generate5x5SobelXOperator:(int)rm AtIndex:(char*)idx
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters SobelFilter5x5_X:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generate5x5SobelYOperator:(int)rm AtIndex:(char*)idx
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters SobelFilter5x5_Y:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generateGaussianFilter:(int)rm  AtIndex:(char*)idx Std:(Float32)sigma Radius:(int)width
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters GaussianFilterStd:sigma Width:width Context:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generateLoGFilter:(int)rm  AtIndex:(char*)idx Std:(Float32)sigma Radius:(int)width
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters LaplacianOfGaussian:sigma Width:width Context:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generate3x3LaplacianOperator:(int)rm AtIndex:(char*)idx
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters LaplacianOperator3x3:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generateDoGFilter:(int)rm  AtIndex:(char*)idx Std:(Float32)sigma Radius:(int)width
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	id<MTLTexture> newTexture = [Filters DifferenceOfGaussian:sigma Width:width Context:self.context];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(id<MTLTexture>)_generateEmptyTexture:(int)rm AtIndex:(char*)idx Width:(int)w Height:(int)h
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	MTLTextureDescriptor *txdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR32Float width:w height:h mipmapped:FALSE];
	id<MTLTexture> newTexture = [self.context.device newTextureWithDescriptor:txdesc];
	[resourceManager attachTexture:newTexture AtIndex:[NSString stringWithUTF8String:idx]];
	return newTexture;
}

-(void)_fillTextureWithFloat:(id<MTLTexture>)tex Region:(int*)replaceRegion Bytes:(Float32*)data BytesPerRow:(int)bpr
{
	[tex replaceRegion:MTLRegionMake2D(replaceRegion[0], replaceRegion[1], replaceRegion[2], replaceRegion[3]) mipmapLevel:0 withBytes:data bytesPerRow:bpr];
}

-(void)_attachFloatAtIndex:(int)rm Val:(Float32)f AtIndex:(char*)idx
{
	MUResourceManager* resourceManager = ((MUResourceManager*)[self.rms objectAtIndex:rm]);
	[resourceManager.resources setObject:[NSNumber numberWithFloat:f] forKey:[NSString stringWithUTF8String:idx]];
}

-(void)_attachTextureAtIndex:(int)rm Tex:(id<MTLTexture>)intx Idx:(char*)idx
{
	NSLog(@"Attaching: %@, %@", intx, [NSString stringWithUTF8String:idx]);
	[(MUResourceManager*)[self.rms objectAtIndex:rm] attachTexture:(id<MTLTexture>)intx AtIndex:[NSString stringWithUTF8String:idx]];
}

-(id<MTLTexture>)_getOutputTexture:(int)rm MipMapLevelCount:(int)mipmaplevel
{
	NSLog(@"GetOutputTextures");
	MUResourceManager *resourceManager = [self.rms objectAtIndex:rm];
	resourceManager.mipmaplevel = mipmaplevel;
	[resourceManager attachOutputTexture];
	return ((MUTexture*)[[resourceManager resources] objectForKey:@"1"]).tex;
}

-(Float32*)_getPixelValue:(id<MTLTexture>)tex Coordinates:(int*)coord BytesPerRow:(int)bpr
{
	Float32* vals = (Float32*)malloc(sizeof(Float32)*2);
	[tex getBytes:vals bytesPerRow:bpr fromRegion:MTLRegionMake2D(coord[0], coord[1], 1, 1) mipmapLevel:0];
	return vals;
}


@end

extern "C"
{
	MetalUnity* MU = nil;
	MUVideoInput *videoInput = nil;
	
	//Compute
	void MUSetupMetalUnity()
	{
		MU = [MetalUnity _setupMetalUnity];
	}
	
	void MUSetupNativeVideoInput()
	{
		if (MU != nil)
		{
			NSLog(@"MUSetupNativeVideoInput");
			videoInput = [MUVideoInput NewVideoInputWithContext:MU.context];
		}
	}
	
	void MUStartRecordingNativeVideo()
	{
		NSLog(@"MUStartRecordingNativeVideo");
		[videoInput.session startRunning];
	}
	
	id<MTLTexture> MUGetVideoTexturePointer()
	{
		if (videoInput != nil)
		{
			return videoInput.videoTexture.tex;
		}
		return NULL;
	}
	
	int MURmsLength()
	{
		return (int)[MU.rms count];
	}
	
	int MUNewComputeManagerForFnc(char* f)
	{
		return [MU _newComputeManagerForFnc:[NSString stringWithUTF8String:f]];
	}
	
	int MUNewResourceManager()
	{
		return [MU _newResourceManager];
	}
	
	id<MTLTexture> MUGenerate3x3SobelXOperator(int rm, char* idx)
	{
		return [MU _generate3x3SobelXOperator:rm AtIndex:idx];
	}
	
	id<MTLTexture> MUGenerate3x3SobelYOperator(int rm, char* idx)
	{
		return [MU _generate3x3SobelYOperator:rm AtIndex:idx];
	}
	
	id<MTLTexture> MUGenerate5x5SobelXOperator(int rm, char* idx)
	{
		return [MU _generate5x5SobelXOperator:rm AtIndex:idx];
	}
	
	id<MTLTexture> MUGenerate5x5SobelYOperator(int rm, char* idx)
	{
		return [MU _generate5x5SobelYOperator:rm AtIndex:idx];
	}
	
	id<MTLTexture> MUGenerateGaussianFilter(int rm, char* idx, Float32 sigma, int width)
	{
		return [MU _generateGaussianFilter:rm AtIndex:idx Std:sigma Radius:width];
	}
	
	id<MTLTexture> MUGenerate3x3LaplacianOperator(int rm, char*idx)
	{
		return [MU _generate3x3LaplacianOperator:rm AtIndex:idx];
	}
	
	id<MTLTexture> MUGenerateLoGFilter(int rm, char* idx, Float32 sigma, int width)
	{
		return [MU _generateLoGFilter:rm AtIndex:idx Std:sigma Radius:width];
	}
	
	id<MTLTexture> MUGenerateDoGFilter(int rm, char* idx, Float32 sigma, int width)
	{
		return [MU _generateDoGFilter:rm AtIndex:idx Std:sigma Radius:width];
	}
	
	id<MTLTexture> MUGenerateEmptyTexture(int rm, char* idx, int w, int h)
	{
		return [MU _generateEmptyTexture:rm AtIndex:idx Width:w Height:h];
	}
	
	void MUFillTextureWithFloat(id<MTLTexture> tex, int* replaceRegion, Float32* data, int bpr)
	{
		[MU _fillTextureWithFloat:tex Region:replaceRegion Bytes:data BytesPerRow:sizeof(Float32)*bpr];
	}
	
	void MUAttachFloatAtIndex(int rm, Float32* f, char* idx)
	{
		[MU _attachFloatAtIndex:rm Val:f[0] AtIndex:idx];
	}
	
	void MUCompute(int cm, int rm)
	{
		[MU _dispatchAndCompute:cm ResourceManager:rm];
	}
	
	void MUAttachTextureAtIndex(int rm,id<MTLTexture> intx, char* idx)
	{
		[MU _attachTextureAtIndex:rm Tex:intx Idx:idx];
	}
	
	id<MTLTexture> MUGetOutputTexture(int rm, int mipmaplevel)
	{
		return [MU _getOutputTexture:rm MipMapLevelCount:mipmaplevel];
	}
	
	Float32* MUGetPixelValue(id<MTLTexture> tex, int* coord, int bpr)
	{
		return [MU _getPixelValue:tex Coordinates:coord BytesPerRow:bpr];
	}
	
	//Filters
	
	//Video
	
}