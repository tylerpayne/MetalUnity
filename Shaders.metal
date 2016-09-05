//
//  Shaders.metal
//  MetalUnity
//
//  Created by Tyler Payne on 6/20/16.
//  Copyright © 2016 Tyler Payne. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;


kernel void SobelGradient_Magnitude(texture2d<float, access::read> inTexture [[texture(0)]],
					 texture2d<float, access::read> x_weights [[texture(2)]],
					 texture2d<float, access::read> y_weights [[texture(3)]],
                             texture2d<float, access::write> outTexture [[texture(1)]],
                             uint2 gid [[thread_position_in_grid]])
{
    float size = x_weights.get_width();
    int radius = size / 2;
    
    float4 xaccumColor(0,0,0,0);
	float4 yaccumColor(0,0,0,0);
	float4 outpix(0,0,0,0);
    for (int i = 0; i < size; ++i)
    {
        for (int j = 0; j < size; ++j)
        {
            uint2 kernelIndex(i, j);
            uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
            float4 color = inTexture.read(textureIndex).rgba;
            float xweight = x_weights.read(kernelIndex).r;
            xaccumColor += xweight * color;
			float yweight = y_weights.read(kernelIndex).r;
			yaccumColor += yweight * color;
		
        }
    }
	outpix = sqrt((xaccumColor*xaccumColor)+(yaccumColor*yaccumColor));
	outTexture.write(float4(outpix.rgb,1),gid);
}

kernel void SobelGradient_Sum(texture2d<float, access::read> inTexture [[texture(0)]],
									texture2d<float, access::read> x_weights [[texture(2)]],
									texture2d<float, access::read> y_weights [[texture(3)]],
									texture2d<float, access::write> outTexture [[texture(1)]],
									uint2 gid [[thread_position_in_grid]])
{
	float size = x_weights.get_width();
	int radius = size / 2;
	
	float4 xaccumColor(0,0,0,0);
	float4 yaccumColor(0,0,0,0);
	float4 outpix(0,0,0,0);
	for (int i = 0; i < size; ++i)
	{
		for (int j = 0; j < size; ++j)
		{
			uint2 kernelIndex(i, j);
			uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
			float4 color = inTexture.read(textureIndex).rgba;
			float xweight = x_weights.read(kernelIndex).r;
			xaccumColor += xweight * color;
			float yweight = y_weights.read(kernelIndex).r;
			yaccumColor += yweight * color;
			
		}
	}
	outpix = xaccumColor + yaccumColor;
	outTexture.write(float4(outpix.rgb,1),gid);
}

kernel void Convolve(texture2d<float, access::read> inTexture [[texture(0)]],
									texture2d<float, access::read> weights [[texture(2)]],
									texture2d<float, access::write> outTexture [[texture(1)]],
									uint2 gid [[thread_position_in_grid]])
{
	float size = weights.get_width();
	int radius = size / 2;
	
	float4 accumColor(0, 0, 0, 0);
	float4 outpix(0,0,0,0);
	for (int i = 0; i < size; ++i)
	{
		for (int j = 0; j < size; ++j)
		{
			uint2 kernelIndex(i, j);
			uint2 textureIndex(gid.x + (i - radius), gid.y + (j - radius));
			float4 color = inTexture.read(textureIndex);
			float weight = weights.read(kernelIndex).r;
			accumColor += weight * color;
			
		}
	}
	outpix = accumColor;
	outTexture.write(float4(outpix.rgb,1),gid);
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


kernel void Grayscale(texture2d<float, access::read> inTexture [[texture(0)]],
						  texture2d<float, access::write> outTexture [[texture(1)]],
						  uint2 gid [[thread_position_in_grid]])
{
	float4 in_pixel(inTexture.read(gid).rgb,1);
	float4 out_pixel(1,1,1,(in_pixel[0]*0.21) + (in_pixel[1]*0.72) + (in_pixel[2]*0.07));
	outTexture.write(out_pixel,gid);
	
}