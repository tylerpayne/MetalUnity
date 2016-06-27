//
//  MUResourceManager.h
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MUComputeContext.h"

@interface MUResourceManager : NSObject

@property (strong) MUComputeContext* context;
@property (strong) NSMutableDictionary* resources;

+(instancetype)newResourceManagerWithContext:(MUComputeContext*)context;
-(instancetype)initWithContext:(MUComputeContext*)context;
-(void)attachTexture:(id<MTLTexture>)texture AtIndex:(NSString*)idx;

@end