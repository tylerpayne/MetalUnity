using UnityEngine;
using System.Collections;

public class CornerDetector {

	public System.IntPtr nativeOutputTexturePtr;
	public float threshold;

	private ComputeStack computeStack;

	public CornerDetector(float thresholdValue)
	{
		this.threshold = thresholdValue;
		this.Activate ();
	}


	public void Activate () 
	{
		MetalUnity.SetupMetalUnity ();

		//Setup Video
		MetalUnity.SetupNativeVideoInput (MetalUnity.VideoResolution.w352h288);
		MetalUnity.StartRecordingNativeVideo ();

		System.IntPtr videoTexture = MetalUnity.GetVideoTexturePointer ();

		computeStack = new ComputeStack (videoTexture);

		ResourceManager preBlur = MetalUnity.NewResourceManager ();
		preBlur.GenerateGaussianFilter ("2", 9f, 9);

		ResourceManager dI = MetalUnity.NewResourceManager ();
		dI.Generate3x3SobelXOperator ("2");
		dI.Generate3x3SobelYOperator ("3");

		ResourceManager blur = MetalUnity.NewResourceManager ();
		blur.GenerateGaussianFilter ("2", 5f, 3);

		ResourceManager dI2 = MetalUnity.NewResourceManager ();

		ResourceManager d2I = MetalUnity.NewResourceManager ();
		d2I.Generate3x3SobelXOperator ("2");
		d2I.Generate3x3SobelYOperator ("3");

		ResourceManager blur2 = MetalUnity.NewResourceManager ();
		blur2.GenerateGaussianFilter ("2", 5f, 3);

		ResourceManager d2I2 = MetalUnity.NewResourceManager ();

		ResourceManager subtract = MetalUnity.NewResourceManager ();

		computeStack.Push (ComputeFunction.Convolve, preBlur);
		computeStack.Push (ComputeFunction.MagnitudeTwoFilters, dI);
		computeStack.Push (ComputeFunction.Convolve, blur);
		computeStack.Push (ComputeFunction.Multiply, dI2);
		dI2.AttachTextureAtIndex (blur.GetTexturePointerAtIndex (@"1"), @"2");
		//computeStack.Push (ComputeFunction.MultiplyConstant, multSupress);
		computeStack.Push (ComputeFunction.SumTwoFilters, d2I);
		computeStack.Push (ComputeFunction.Convolve, blur2);
		computeStack.Push (ComputeFunction.Multiply, d2I2);
		computeStack.Push (ComputeFunction.Subtract, subtract);
		subtract.AttachTextureAtIndex (dI2.GetTexturePointerAtIndex (@"1"), @"2");
		d2I2.AttachTextureAtIndex (blur2.GetTexturePointerAtIndex (@"1"), @"2");

		nativeOutputTexturePtr = computeStack.GetOutputTexture ();

		//MUDebugger.instance.AddAdditionalDebugInfo("Pixel Values (x,y)",GetPixelValuesFromTexture);*/
	}

	public void ComputeCorners () 
	{
		computeStack.Dispatch ();
	}

	public string GetPixelValuesFromTexture()
	{
		float[] retval = MetalUnity.GetPixelValue (nativeOutputTexturePtr, 100, 100, sizeof(float) * 352);
		return "" + retval [0] + ", " + retval [1] + "";
	}
}
