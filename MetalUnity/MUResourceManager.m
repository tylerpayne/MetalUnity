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

@implementation MUResourceManager

+(instancetype)newResourceManagerWithContext:(MUComputeContext *)context
{
	return [[self alloc] initWithContext:context];
}

-(instancetype)initWithContext:(MUComputeContext *)context
{
	if ((self = [super init])) {
		self.context = context;
	}
	return self;
}

-(void)attachTexture:(id<MTLTexture>)texture AtIndex:(NSString *)idx
{
	if (![self.resources objectForKey:idx]) {
		MUTexture* tx = [MUTexture newTexture:texture Width:texture.width Height:texture.height Depth:texture.depth];
		[self.resources	setObject:tx forKey:idx];
	}
	
}


@end
