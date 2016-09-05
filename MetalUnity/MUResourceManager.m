//
//  MUResourceManager.m
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUResourceManager.h"
#import "MUComputeContext.h"
#import "MUComputeManager.h"
#import "MUTexture.h"
#import "Filters.h"

@implementation MUResourceManager

+(instancetype)newResourceManagerWithContext:(MUComputeContext *)context
{
	return [[self alloc] initWithContext:context];
}

-(instancetype)initWithContext:(MUComputeContext *)context
{
	if ((self = [super init])) {
		self.context = context;
		self.resources = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)attachTexture:(id<MTLTexture>)texture AtIndex:(NSString *)idx
{
	if (![self.resources objectForKey:idx]) {
		MUTexture* tx = [MUTexture newTexture:texture Width:texture.width Height:texture.height Depth:1];
		[self.resources	setObject:tx forKey:idx];
	}
}

-(void)attachOutputTexture
{
	MUTexture* inTex = [self.resources objectForKey:@"0"];
	int divisor = pow(2, self.mipmaplevel);
	unsigned long int w = (int)MAX(1,inTex.size.width / divisor);
	unsigned long int h = (int)MAX(1,inTex.size.height / divisor);
	
	if (inTex != NULL) {
		MTLTextureDescriptor *txdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:w height:h mipmapped:FALSE];
		id<MTLTexture> outTex = [self.context.device newTextureWithDescriptor:txdesc];
		[self attachTexture:outTex AtIndex:@"1"];
	}
}

@end
