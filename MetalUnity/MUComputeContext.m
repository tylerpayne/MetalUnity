//
//  MUComputeContext.m
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUComputeContext.h"
#import "MUComputeManager.h"
#import "MUResourceManager.h"

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
		NSLog(@"New MTLComputeContext!");
	}
	return self;
}

-(MUResourceManager*)newResourceManager
{

	return [MUResourceManager newResourceManagerWithContext:self];

}

-(MUComputeManager*)newComputeManagerForFunction:(NSString *)fnc
{
	
	return [MUComputeManager newComputeManagerWithContext:self Function:fnc];
	
}


@end