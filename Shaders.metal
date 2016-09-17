//
//  Shaders.metal
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#include <metal_stdlib>
#include <metal_common>
#include <metal_geometric>

using namespace metal;


kernel void SobelGradient_Magnitude(texture2d<float, access::read> inTexture [[texture(0)]],
					 texture2d<float, access::read> x_weights [[texture(2)]],
					 texture2d<float, access::read> y_weights [[texture(3)]],
                             texture2d<float, access::write> outTexture [[texture(1)]],
                             uint2 gid [[thread_position_in_grid]])
{
	float size = x_weights.get_width();
	int radius = size / 2;
	
	float xaccumColor;
	float yaccumColor;
	float outpix;
	for (int i = 0; i < size; ++i)
	{
		for (int j = 0; j < size; ++j)
		{
			uint2 kernelIndex(i, j);
			uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
			float color = length_squared(inTexture.read(textureIndex));
			float xweight = x_weights.read(kernelIndex).r;
			xaccumColor += xweight * color;
			float yweight = y_weights.read(kernelIndex).r;
			yaccumColor += yweight * color;
			
		}
	}
	outpix = sqrt((xaccumColor*xaccumColor)+(yaccumColor*yaccumColor));
	outTexture.write(outpix,gid);
}

kernel void SobelGradient_Sum(texture2d<float, access::read> inTexture [[texture(0)]],
									texture2d<float, access::read> x_weights [[texture(2)]],
									texture2d<float, access::read> y_weights [[texture(3)]],
									texture2d<float, access::write> outTexture [[texture(1)]],
									uint2 gid [[thread_position_in_grid]])
{
	float size = x_weights.get_width();
	int radius = size / 2;
	
	float xaccumColor;
	float yaccumColor;
	float outpix;
	for (int i = 0; i < size; ++i)
	{
		for (int j = 0; j < size; ++j)
		{
			uint2 kernelIndex(i, j);
			uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
			float color = length_squared(inTexture.read(textureIndex));
			float xweight = x_weights.read(kernelIndex).r;
			xaccumColor += xweight * color;
			float yweight = y_weights.read(kernelIndex).r;
			yaccumColor += yweight * color;
			
		}
	}
	outpix = xaccumColor + yaccumColor;
	outTexture.write(outpix,gid);
}

kernel void Convolve(texture2d<float, access::read> inTexture [[texture(0)]],
									texture2d<float, access::read> weights [[texture(2)]],
									texture2d<float, access::write> outTexture [[texture(1)]],
									uint2 gid [[thread_position_in_grid]])
{
	float size = weights.get_width();
	int radius = size / 2;
	
	float accumColor;
	float outpix;
	for (int i = 0; i < size; ++i)
	{
		for (int j = 0; j < size; ++j)
		{
			uint2 kernelIndex(i, j);
			uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
			float color = length_squared(inTexture.read(textureIndex));
			float weight = weights.read(kernelIndex).r;
			accumColor += weight * color;
			
		}
	}
	outpix = accumColor;
	outTexture.write(outpix,gid);
}

kernel void LocalMax_Constant(texture2d<float,access::read> inTexture [[texture(0)]],
					 texture2d<float,access::write> outTexture [[texture(1)]],
					 constant float* windowSize [[buffer(2)]] ,
					 uint2 gid [[thread_position_in_grid]])
{
	float4 maxVal = float4(0,0,0,0);
	uint2 maxIdx = uint2(0,0);
	int size = int(windowSize[0]);
	int radius = size/2;
	outTexture.write(float4(0,0,0,1),gid);
	for (int i = 0; i < size; ++i)
	{
		for (int j = 0; j < size; ++j)
		{
			uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
			float4 color = inTexture.read(textureIndex);
			if (length_squared(color) > length_squared(maxVal))
			{
				maxVal = color;
				maxIdx = textureIndex;
			}
		}
	}
	
	outTexture.write(maxVal,maxIdx);
	
}

kernel void Add(texture2d<float, access::read> inTexture [[texture(0)]],
					 texture2d<float, access::read> weights [[texture(2)]],
					 texture2d<float, access::write> outTexture [[texture(1)]],
					 uint2 gid [[thread_position_in_grid]])
{
	outTexture.write(float4(inTexture.read(gid).rgb+weights.read(gid).rgb,1),gid);
}

kernel void Subtract(texture2d<float, access::read> inTexture [[texture(0)]],
				texture2d<float, access::read> weights [[texture(2)]],
				texture2d<float, access::write> outTexture [[texture(1)]],
				uint2 gid [[thread_position_in_grid]])
{
	outTexture.write(float4(inTexture.read(gid).rgb-weights.read(gid).rgb,1),gid);
}

kernel void Multiply(texture2d<float, access::read> inTexture [[texture(0)]],
					 texture2d<float, access::read> weights [[texture(2)]],
					 texture2d<float, access::write> outTexture [[texture(1)]],
					 uint2 gid [[thread_position_in_grid]])
{
	outTexture.write(float4(inTexture.read(gid).rgb*weights.read(gid).rgb,1),gid);
}

kernel void Multiply_Constant(texture2d<float, access::read> inTexture [[texture(0)]],
					 constant float *coefficient [[buffer(2)]],
					 texture2d<float, access::write> outTexture [[texture(1)]],
					 uint2 gid [[thread_position_in_grid]])
{
	outTexture.write(float4(inTexture.read(gid).rgb*coefficient[0],1),gid);
}

kernel void Clip_Greater_Constant(texture2d<float, access::read> inTexture [[texture(0)]],
							  constant float *clipValue [[buffer(2)]],
							  texture2d<float, access::write> outTexture [[texture(1)]],
							  uint2 gid [[thread_position_in_grid]])
{
	float4 outpix(0,0,0,0);
	if (inTexture.read(gid).r < clipValue[0] || inTexture.read(gid).g < clipValue[0] || inTexture.read(gid).b < clipValue[0])
	{
		outpix = float4(inTexture.read(gid).rgb,1);
	}
	outTexture.write(float4(outpix.rgb,1),gid);
}

kernel void Clip_Less_Constant(texture2d<float, access::read> inTexture [[texture(0)]],
								  constant float *clipValue [[buffer(2)]],
								  texture2d<float, access::write> outTexture [[texture(1)]],
								  uint2 gid [[thread_position_in_grid]])
{
	float4 outpix(0,0,0,0);
	if (inTexture.read(gid).r > clipValue[0] || inTexture.read(gid).g > clipValue[0] || inTexture.read(gid).b > clipValue[0])
	{
		outpix = float4(inTexture.read(gid).rgb,1);
	}
	outTexture.write(float4(outpix.rgb,1),gid);
}


kernel void Grayscale(texture2d<float, access::read> inTexture [[texture(0)]],
						  texture2d<float, access::write> outTexture [[texture(1)]],
						  uint2 gid [[thread_position_in_grid]])
{
	float4 in_pixel(inTexture.read(gid).rgb,1);
	float4 out_pixel(1,1,1,(in_pixel[0]*0.21) + (in_pixel[1]*0.72) + (in_pixel[2]*0.07));
	outTexture.write(out_pixel,gid);
	
}