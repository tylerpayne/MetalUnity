//
//  MUVideoTexture.h
//  MetalUnity
//
//  Created by Tyler Payne on 9/1/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Metal/Metal.h>
#import "MUTexture.h"
#import "MUComputeContext.h"

@interface MUVideoTexture : MUTexture

@property (assign) bool isDirty;

-(void)CopyDataFromBuffer:(CMSampleBufferRef)buffer;

@end