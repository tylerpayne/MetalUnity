//
//  Filters.h
//  MetalUnity
//
//  Created by Tyler Payne on 7/29/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@class MUComputeContext;
@class MUTexture;

@interface Filters : NSObject

////First Order Approximations
+(id<MTLTexture>)SobelFilter3x3_X:(MUComputeContext*)ctx;
+(id<MTLTexture>)SobelFilter3x3_Y:(MUComputeContext*)ctx;
+(id<MTLTexture>)SobelFilter5x5_X:(MUComputeContext*)ctx;
+(id<MTLTexture>)SobelFilter5x5_Y:(MUComputeContext*)ctx;


+(id<MTLTexture>)GaussianFilterStd:(Float32)sigma Width:(int)w Context:(MUComputeContext*)ctx;

//Second Order Approximations
+(id<MTLTexture>)LaplacianOperator3x3:(MUComputeContext*)ctx;
+(id<MTLTexture>)LaplacianOfGaussian:(Float32)sigma Width:(int)w Context:(MUComputeContext*)ctx;
+(id<MTLTexture>)DifferenceOfGaussian:(Float32)sigma Width:(int)w Context:(MUComputeContext*)ctx;

@end
