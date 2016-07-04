//
//  MUTexture.h
//  MetalUnity
//
//  Created by Tyler Payne on 7/3/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface MUTexture : NSObject

@property (strong) id<MTLTexture> tex;
@property (assign) MTLSize size;

+(instancetype)newTexture:(id<MTLTexture>)tx Width:(NSUInteger)w Height:(NSUInteger)h Depth:(NSUInteger)d;

@end