//
//  MUResourceManager.h
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
@class MUComputeContext;
@class MUComputeManager;
@class Filters;

@interface MUResourceManager : NSObject

@property (strong) MUComputeContext* context;
@property (strong) NSMutableDictionary* resources;
@property (assign) unsigned long int mipmaplevel;

+(instancetype)newResourceManagerWithContext:(MUComputeContext*)context;
-(instancetype)initWithContext:(MUComputeContext*)context;
-(void)attachTexture:(id<MTLTexture>)texture AtIndex:(NSString*)idx;
-(void)attachOutputTexture;
//-(void)newTextureFromFile:(NSString*)file AtIndex:(NSString*)idx;

@end