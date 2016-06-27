//
//  MUResourceManager.m
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUResourceManager.h"

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

@end
