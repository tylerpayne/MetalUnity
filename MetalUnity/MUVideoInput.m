//
//  MUVideoInput.m
//  MetalUnity
//
//  Created by Tyler Payne on 9/1/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//
#import "MUVideoInput.h"

@implementation MUVideoInput

+(instancetype)NewVideoInputWithContext:(MUComputeContext *)context VideoResolution:(int)vidRes
{
	return [[self alloc] initWithContext:context VideoResolution:vidRes];
}

-(instancetype)initWithContext:(MUComputeContext*)context VideoResolution:(int)vidRes
{
	self.context = context;
	
	int w;
	int h;
	NSString *preset;
	
	switch (vidRes) {
		case 0:
			preset = AVCaptureSessionPreset352x288;
			w = 352;
			h = 288;
			break;
		case 1:
			preset = AVCaptureSessionPreset640x480;
			w = 640;
			h = 480;
			break;
		case 2:
			preset = AVCaptureSessionPreset1280x720;
			w = 1280;
			h = 720;
			break;
		case 3:
			preset = AVCaptureSessionPreset1920x1080;
			w = 1920;
			h = 1080;
			break;
			
		default:
			preset = AVCaptureSessionPreset352x288;
			w = 352;
			h = 288;
			break;
	}
		
	self.videoTexture = [MUVideoTexture NewEmptyTexture:context Width:w Height:h Depth:1];
	NSLog(@"InitVideoTexture: %@",self.videoTexture.tex);
		
	self.session = [[AVCaptureSession alloc] init];
	self.session.sessionPreset = preset;
		
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
