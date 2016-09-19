using UnityEngine;
using System.Collections;

public class CornerDetector {

	public System.IntPtr nativeOutputTexturePtr;
	public float threshold;

	private ComputeStack computeStack;

	// Use this for initialization
	public CornerDetector(float thresholdValue)
	{
		this.threshold = thresholdValue;
		this.Activate ();
	}


	public void Activate () {
		MetalUnity.SetupMetalUnity ();

		//Setup Video
		MetalUnity.SetupNativeVideoInput ();
		MetalUnity.StartRecordingNativeVideo ();

		System.IntPtr videoTexture = MetalUnity.GetVideoTexturePointer ();

		computeStack = new ComputeStack (videoTexture);

		ResourceManager dI = MetalUnity.NewResourceManager ();
		dI.Generate5x5SobelXOperator ("2");
		dI.Generate5x5SobelYOperator ("3");

		ResourceManager blur = MetalUnity.NewResourceManager ();
		blur.GenerateGaussianFilter ("2", 9f, 3);

		ResourceManager d2I = MetalUnity.NewResourceManager ();
		d2I.Generate5x5SobelXOperator ("2");
		d2I.Generate5x5SobelYOperator ("3");

		ResourceManager blur2 = MetalUnity.NewResourceManager ();
		blur2.GenerateGaussianFilter ("2", 9f, 3);

		computeStack.Push (ComputeFunction.MagnitudeTwoFilters, dI);
		//computeStack.Push (ComputeFunction.Convolve, blur);
		computeStack.Push (ComputeFunction.MagnitudeTwoFilters, d2I);
		//computeStack.Push (ComputeFunction.Convolve, blur2);

		nativeOutputTexturePtr = computeStack.GetOutputTexture ();


		//MUDebugger.instance.AddAdditionalDebugInfo("Pixel Values (x,y)",GetPixelValuesFromTexture);*/
	
	}

	public void ComputeCorners () {
		computeStack.Dispatch ();
	}

	public string GetPixelValuesFromTexture()
	{
		float[] retval = MetalUnity.GetPixelValue (nativeOutputTexturePtr, 100, 100, sizeof(float) * 352);
		return "" + retval [0] + ", " + retval [1] + "";
	}
}
