//
//  MUVideoInput.m
//  MetalUnity
//
//  Created by Tyler Payne on 9/1/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//
#import "MUVideoInput.h"

@implementation MUVideoInput

+(instancetype)NewVideoInputWithContext:(MUComputeContext *)context
{
	return [[self alloc] initWithContext:context];
}

-(instancetype)initWithContext:(MUComputeContext*)context
{
	self.context = context;
		
	self.videoTexture = [MUVideoTexture NewEmptyTexture:context Width:640 Height:480 Depth:1];
	NSLog(@"InitVideoTexture: %@",self.videoTexture.tex);
		
	self.session = [[AVCaptureSession alloc] init];
	self.session.sessionPreset = AVCaptureSessionPreset640x480;
		
	NSError* error =nil;
		
	self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
		
	[self.session addInput:self.deviceInput];
		
	self.outputData = [[AVCaptureVideoDataOutput alloc] init];
	self.outputData.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
		
	[self.session addOutput:self.outputData];
		
	dispatch_queue_t queue = dispatch_queue_create("VideoQueue", NULL);
	[self.outputData setSampleBufferDelegate:self queue:queue];

	return self;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	
	[self.videoTexture CopyDataFromBuffer:sampleBuffer];
	
}



@end
