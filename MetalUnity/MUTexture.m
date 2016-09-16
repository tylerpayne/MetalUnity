//
//  MUTexture.m
//  MetalUnity
//
//  Created by Tyler Payne on 7/3/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MUTexture.h"

@implementation MUTexture

+(instancetype)newTexture:(id<MTLTexture>)tx Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d
{
	return [[self alloc] initWithTexture:tx Width:w Height:h Depth:d];
}

+(instancetype)NewEmptyTexture:(MUComputeContext*)context Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d
{
	return [[self alloc] initWithContext:context Width:w Height:h Depth:d];
}


-(instancetype)initWithTexture:(id<MTLTexture>)tx Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d
{
	if ((self = [super init])) {
		self.tex = tx;
		self.size = MTLSizeMake(w, h, d);
	}
	return self;
}


-(instancetype)initWithContext:(MUComputeContext*)context Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d
{
	MTLTextureDescriptor *txdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Snorm width:w height:h mipmapped:FALSE];
	self.tex = [self.context.device newTextureWithDescriptor:txdesc];
	self.size = MTLSizeMake(w, h, d);
	return self;
}


@end
