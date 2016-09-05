//
//  MUVideoTexture.m
//  MetalUnity
//
//  Created by Tyler Payne on 9/1/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import "MUVideoTexture.h"

@implementation MUVideoTexture

+(instancetype)NewEmptyTexture:(MUComputeContext*)context Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d
{
	return [[self alloc] initWithContext:context Width:w Height:h Depth:d];
}

-(instancetype)initWithContext:(MUComputeContext*)context Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d
{
	MTLTextureDescriptor *txdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:w height:h mipmapped:FALSE];
	self.tex = [context.device newTextureWithDescriptor:txdesc];
	self.size = MTLSizeMake(w, h, d);
	return self;
}

-(void)CopyDataFromBuffer:(CMSampleBufferRef)buffer
{
	self.isDirty = true;
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
	
	CVPixelBufferLockBaseAddress(imageBuffer,0);
	
	void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
	
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
	[self.tex replaceRegion:MTLRegionMake2D(0, 0, self.tex.width, self.tex.height) mipmapLevel:0 withBytes:baseAddress bytesPerRow:bytesPerRow];
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	self.isDirty = false;
	
}

@end