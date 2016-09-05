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

@interface MUVideoTexture : NSObject

@property (strong) id<MTLTexture> tex;
@property (assign) MTLSize size;

@property (assign) bool isDirty;

+(instancetype)NewEmptyTexture:(MUComputeContext*)context Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d;
-(void)CopyDataFromBuffer:(CMSampleBufferRef)buffer;

@end