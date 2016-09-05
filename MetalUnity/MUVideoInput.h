//
//  MUVideoInput.h
//  MetalUnity
//
//  Created by Tyler Payne on 9/1/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Metal/Metal.h>
#import "MUVideoTexture.h"
#import "MUComputeContext.h"

@interface MUVideoInput : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong)MUComputeContext* context;

@property (strong) AVCaptureSession* session;
@property (strong) AVCaptureDevice* device;
@property (strong) AVCaptureDeviceInput* deviceInput;
@property (strong) AVCaptureVideoDataOutput *outputData;

@property (strong) MUVideoTexture *videoTexture;

+(instancetype)NewVideoInputWithContext:(MUComputeContext*)context;

@end
