//
//  MUComputeContext.m
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUComputeContext.h"

@implementation MUComputeContext

+(instancetype)newComputeContext
{
	return [[self alloc] initWithDefaultDevice];
}

-(instancetype)initWithDefaultDevice
{
	if ((self = [super init])) {
		_device = MTLCreateSystemDefaultDevice();
		_library = [_device newDefaultLibrary];
		_queue = [_device newCommandQueue];
	}
	return self;
}



@end