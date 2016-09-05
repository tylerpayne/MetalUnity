//
//  MUTexture.h
//  MetalUnity
//
//  Created by Tyler Payne on 7/3/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MUComputeContext.h"

@interface MUTexture : NSObject

@property (strong) MUComputeContext *context;
@property (strong) id<MTLTexture> tex;
@property (assign) MTLSize size;

+(instancetype)NewEmptyTexture:(MUComputeContext*)context Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d;
+(instancetype)newTexture:(id<MTLTexture>)tx Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d;

@end