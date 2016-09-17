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

		computeStack = new ComputeStack ();

		ResourceManager dI = MetalUnity.NewResourceManager ();
		dI.AttachTextureAtIndex (videoTexture, "0");
		dI.Generate5x5SobelXOperator ("2");
		dI.Generate5x5SobelYOperator ("3");

		computeStack.Push (ComputeFunction.MagnitudeTwoFilters, dI);

		ResourceManager blurdI = MetalUnity.NewResourceManager ();
		blurdI.AttachTextureAtIndex (dI.GetOutputTexture(0), "0");
		blurdI.GenerateGaussianFilter ("2", 3f, 3);

		System.IntPtr blurdIOutput = blurdI.GetOutputTexture (0);

		computeStack.Push (ComputeFunction.Convolve, blurdI);

		ResourceManager d2I = MetalUnity.NewResourceManager ();
		d2I.AttachTextureAtIndex (blurdIOutput, "0");
		d2I.Generate5x5SobelXOperator ("2");
		d2I.Generate5x5SobelYOperator ("3");

		computeStack.Push (ComputeFunction.MagnitudeTwoFilters, d2I);

		ResourceManager blurd2I = MetalUnity.NewResourceManager ();
		blurd2I.AttachTextureAtIndex (d2I.GetOutputTexture(0), "0");
		blurd2I.GenerateGaussianFilter ("2", 3f, 3);

		System.IntPtr blurd2IOutput = blurd2I.GetOutputTexture (0);

		computeStack.Push (ComputeFunction.Convolve, blurd2I);

		ResourceManager subtract = MetalUnity.NewResourceManager ();
		subtract.AttachTextureAtIndex (blurd2IOutput, "0");
		subtract.AttachTextureAtIndex (blurdIOutput, "2");

		nativeOutputTexturePtr = subtract.GetOutputTexture (0);

		computeStack.Push (ComputeFunction.Subtract, subtract);


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
