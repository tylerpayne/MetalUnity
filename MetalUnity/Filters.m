//
//  Filters.m
//  MetalUnity
//
//  Created by Tyler Payne on 7/29/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#import "Filters.h"
#import "MUComputeContext.h"
#import "MUTexture.h"
#import <math.h>

#define IDX2C(i,j,ld) (((j)*(ld))+(i))

@implementation Filters

+(id<MTLTexture>)GaussianFilterStd:(float)sigma Width:(int)w Context:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* txdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:w height:w mipmapped:FALSE];
	id<MTLTexture> gaussian = [ctx.device newTextureWithDescriptor:txdesc];
	
	float *weights = (float*)malloc(sizeof(float) * w * w);
	float variance = sigma*sigma;
	int radius = floorf(w/2.0f);
	float normfactor = 0.0f;
	for (int y = 0; y<w; ++y) {
		for (int x =0; x<w; ++x) {
			float xsqrd = (x-radius)*(x-radius);
			float ysqrd = (y-radius)*(y-radius);
			float val = (exp(-1.0*((xsqrd+ysqrd)/(2.0*variance))));
			weights[IDX2C(y, x, w)] = val;
			normfactor += val;
			//(1.0/(2.0*M_PI*variance))*
		}
	}
	for (int i = 0; i<(w*w); i++)
	{
		weights[i] = weights[i]/normfactor;
		NSLog(@"Gaussian Weight: %f",weights[i]);
	}
	
	MTLRegion reg = MTLRegionMake2D(0, 0, w, w);
	[gaussian replaceRegion:reg mipmapLevel:0 withBytes:weights bytesPerRow:sizeof(float)*w];
	free(weights);
	return gaussian;
}

+(id<MTLTexture>)DifferenceOfGaussian:(float)sigma Width:(int)w Context:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* txdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:w height:w mipmapped:FALSE];
	id<MTLTexture> gaussian = [ctx.device newTextureWithDescriptor:txdesc];
	
	float *weights = (float*)malloc(sizeof(float) * w * w);
	
	float sigma1 = sigma/sqrtf(2.0f);
	float sigma2 = sqrtf(2.0f)*sigma;
	
	float variance1 = sigma1*sigma1;
	float variance2 = sigma2*sigma2;
	int radius = floorf(w/2.0f);
	float normfactor = 0.0f;
	float coeffecient = 1.0f/sqrtf(2.0f*M_PI);
	for (int y = 0; y<w; ++y) {
		for (int x =0; x<w; ++x) {
			float xsqrd = (x-radius)*(x-radius);
			float ysqrd = (y-radius)*(y-radius);
			float val1 = (1.0f/sigma1)*(exp(-1.0*((xsqrd+ysqrd)/(2.0*variance1))));
			float val2 = (1.0f/sigma2)*(exp(-1.0*((xsqrd+ysqrd)/(2.0*variance2))));
			float val = coeffecient*(val1-val2);
			weights[IDX2C(y, x, w)] = val;
			normfactor += val;
			//(1.0/(2.0*M_PI*variance))*
		}
	}
	for (int i = 0; i<(w*w); i++)
	{
		NSLog(@"DoG Weight (BEFORE NORM): %f",weights[i]);
		weights[i] = weights[i]/normfactor;
		NSLog(@"DoG Weight: %f",weights[i]);
	}
	
	MTLRegion reg = MTLRegionMake2D(0, 0, w, w);
	[gaussian replaceRegion:reg mipmapLevel:0 withBytes:weights bytesPerRow:sizeof(float)*w];
	free(weights);
	return gaussian;
}



+(id<MTLTexture>)LaplacianOfGaussian:(float)sigma Width:(int)w Context:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* txdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:w height:w mipmapped:FALSE];
	id<MTLTexture> LoG = [ctx.device newTextureWithDescriptor:txdesc];
	
	float *weights = (float*)malloc(sizeof(float) * w * w);
	float variance = sigma*sigma;
	int radius = floorf(w/2.0f);
	float normfactor = 0.0f;
	for (int y = 0; y<w; ++y) {
		for (int x =0; x<w; ++x) {
			float xsqrd = (x-radius)*(x-radius);
			float ysqrd = (y-radius)*(y-radius);
			float val = ((xsqrd+ysqrd)/(2.0*variance));
			val = (-1.0/(pow(sigma,4)*M_PI))*(1.0-val)*(exp(-1.0*val));
			weights[IDX2C(y, x, w)] = val;
			normfactor += val;
			//(1.0/(2.0*M_PI*variance))*
		}
	}
	for (int i = 0; i<(w*w); i++)
	{
		weights[i] = weights[i]/normfactor;
		NSLog(@"LoG Weight: %f",weights[i]);
	}
	
	MTLRegion reg = MTLRegionMake2D(0, 0, w, w);
	[LoG replaceRegion:reg mipmapLevel:0 withBytes:weights bytesPerRow:sizeof(float)*w];
	free(weights);
	return LoG;
}

+(id<MTLTexture>)LaplacianOperator3x3:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* laplacianTexDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:3 height:3 mipmapped:FALSE];
	id<MTLTexture> laplacian = [ctx.device newTextureWithDescriptor:laplacianTexDesc];
	
	const int size = 3;
	
	float *laplacianWeights = (float*)malloc(sizeof(float) * size * size);
	
	laplacianWeights[0] = 0.0;
	laplacianWeights[1] = 1.0;
	laplacianWeights[2] = 0.0;
	laplacianWeights[3] = 1.0;
	laplacianWeights[4] = -4.0;
	laplacianWeights[5] = 1.0;
	laplacianWeights[6] = 0.0;
	laplacianWeights[7] = 1.0;
	laplacianWeights[8] = 0.0;
	
	float sum = 0.0;
	
	for (int i = 0; i < size*size; i++)
	{
		sum += laplacianWeights[i];
	}
	
	for (int i = 0; i < size*size; i++)
	{
		laplacianWeights[i] = laplacianWeights[i]/sum;
	}
	
	MTLRegion reg = MTLRegionMake2D(0, 0, 3, 3);
	[laplacian replaceRegion:reg mipmapLevel:0 withBytes:laplacianWeights bytesPerRow:sizeof(float)*size];
	free(laplacianWeights);
	return laplacian;
}

+(id<MTLTexture>)SobelFilter3x3_X:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* sobeltxdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:3 height:3 mipmapped:FALSE];
	id<MTLTexture> x_sobel = [ctx.device newTextureWithDescriptor:sobeltxdesc];
	
	const int size = 3;
	
	float *xweights = (float*)malloc(sizeof(float) * size * size);
	
	xweights[0] = -1.0;
	xweights[1] = 0.0;
	xweights[2] = 1.0;
	xweights[3] = -2.0;
	xweights[4] = 0.0;
	xweights[5] = 2.0;
	xweights[6] = -1.0;
	xweights[7] = 0.0;
	xweights[8] = 1.0;
	
	MTLRegion reg = MTLRegionMake2D(0, 0, 3, 3);
	[x_sobel replaceRegion:reg mipmapLevel:0 withBytes:xweights bytesPerRow:sizeof(float)*size];
	free(xweights);
	return x_sobel;
}

+(id<MTLTexture>)SobelFilter3x3_Y:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* sobeltxdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:3 height:3 mipmapped:FALSE];
	id<MTLTexture> y_sobel = [ctx.device newTextureWithDescriptor:sobeltxdesc];
	
	const int size = 3;
	
	float *yweights = (float*)malloc(sizeof(float) * size * size);
	
	yweights[0] = -1.0;
	yweights[1] = -2.0;
	yweights[2] = -1.0;
	yweights[3] = 0.0;
	yweights[4] = 0.0;
	yweights[5] = 0.0;
	yweights[6] = 1.0;
	yweights[7] = 2.0;
	yweights[8] = 1.0;
	
	
	MTLRegion reg = MTLRegionMake2D(0, 0, 3, 3);
	[y_sobel replaceRegion:reg mipmapLevel:0 withBytes:yweights bytesPerRow:sizeof(float)*size];
	free(yweights);
	return y_sobel;
}

+(id<MTLTexture>)SobelFilter5x5_X:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* sobeltxdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:5 height:5 mipmapped:FALSE];
	id<MTLTexture> x_sobel = [ctx.device newTextureWithDescriptor:sobeltxdesc];
	
	const int size = 5;
	
	float *xweights = (float*)malloc(sizeof(float) * size * size);
	
	xweights[0] = -1.0;
	xweights[1] = -2.0;
	xweights[2] = 0.0;
	xweights[3] = 2.0;
	xweights[4] = 1.0;
	xweights[5] = -4.0;
	xweights[6] = -8.0;
	xweights[7] = 0.0;
	xweights[8] = 8.0;
	xweights[9] = 4.0;
	xweights[10] = -6.0;
	xweights[11] = -12.0;
	xweights[12] = 0.0;
	xweights[13] = 12.0;
	xweights[14] = 6.0;
	xweights[15] = -4.0;
	xweights[16] = -8.0;
	xweights[17] = 0.0;
	xweights[18] = 8.0;
	xweights[19] = 4.0;
	xweights[20] = -1.0;
	xweights[21] = -2.0;
	xweights[22] = 0.0;
	xweights[23] = 2.0;
	xweights[24] = 1.0;
	
	MTLRegion reg = MTLRegionMake2D(0, 0, 5, 5);
	[x_sobel replaceRegion:reg mipmapLevel:0 withBytes:xweights bytesPerRow:sizeof(float)*size];
	free(xweights);
	return x_sobel;
}


+(id<MTLTexture>)SobelFilter5x5_Y:(MUComputeContext*)ctx
{
	MTLTextureDescriptor* sobeltxdesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Snorm width:5 height:5 mipmapped:FALSE];
	id<MTLTexture> y_sobel = [ctx.device newTextureWithDescriptor:sobeltxdesc];
	
	const int size = 5;
	
	float *yweights = (float*)malloc(sizeof(float) * size * size);
	
	yweights[0] = -1.0;
	yweights[1] = -4.0;
	yweights[2] = -6.0;
	yweights[3] = -4.0;
	yweights[4] = -1.0;
	yweights[5] = -2.0;
	yweights[6] = -8.0;
	yweights[7] = -12.0;
	yweights[8] = -8.0;
	yweights[9] = -2.0;
	yweights[10] = 0.0;
	yweights[11] = 0.0;
	yweights[12] = 0.0;
	yweights[13] = 0.0;
	yweights[14] = 0.0;
	yweights[15] = 2.0;
	yweights[16] = 8.0;
	yweights[17] = 12.0;
	yweights[18] = 8.0;
	yweights[19] = 2.0;
	yweights[20] = 1.0;
	yweights[21] = 4.0;
	yweights[22] = 6.0;
	yweights[23] = 4.0;
	yweights[24] = 1.0;
	
	float sum = 0.0;
	
	for (int i = 0; i < size*size; i++)
	{
		sum += yweights[i];
	}
	
	for (int i = 0; i < size*size; i++)
	{
		yweights[i] = yweights[i]/sum;
	}
	
	MTLRegion reg = MTLRegionMake2D(0, 0, 5, 5);
	[y_sobel replaceRegion:reg mipmapLevel:0 withBytes:yweights bytesPerRow:sizeof(float)*size];
	free(yweights);
	return y_sobel;
}

@end