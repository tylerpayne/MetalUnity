using UnityEngine;
using System.Collections;

public class MUExample : MonoBehaviour {

	public System.IntPtr nativeOutputTexturePtr; //Access this and load into a Texture via the UpdateExternalTexture() function

	private ComputeStack computeStack;

	void Start () {
		//##################################
		//# STEP 0: SETUP METAL UNITY      #
		//##################################
		MetalUnity.SetupMetalUnity (); //Must Call First!

		//Setup Video
		MetalUnity.SetupNativeVideoInput (MetalUnity.VideoResolution.w352h288); //Grab iOS's camera at supported resolutions
		MetalUnity.StartRecordingNativeVideo (); //Begin Recording at the resolution specified above

		System.IntPtr videoTexture = MetalUnity.GetVideoTexturePointer (); //Get a reference to the camera's output image

		computeStack = new ComputeStack (videoTexture); // The argument to the constructor specifies the input for this ComputeStack

		//########################################
		//# FIRST STEP: CREATE RESOURCE MANAGERS #
		//#######################################

		//Ix (The image derivative w.r.t X)
		ResourceManager dIdX = MetalUnity.NewResourceManager ();
		dIdX.Generate3x3SobelXOperator ();

		ResourceManager blurdIdX = MetalUnity.NewResourceManager ();
		blurdIdX.GenerateGaussianFilter (3f, 3);

		//Iy (The image derivative w.r.t Y)
		ResourceManager dIdY = MetalUnity.NewResourceManager ();
		dIdY.Generate3x3SobelYOperator ();

		ResourceManager blurdIdY = MetalUnity.NewResourceManager ();
		blurdIdY.GenerateGaussianFilter (3f, 3);

		//dI
		ResourceManager dI = MetalUnity.NewResourceManager ();

		ResourceManager blurdI = MetalUnity.NewResourceManager ();
		blurdI.GenerateGaussianFilter (3f, 3);


		//#######################################
		//# SECOND STEP: PUSH RESOURCE MANAGERS #
		//# TO THE COMPUTE STACK                #
		//#######################################

		//Ix
		computeStack.Push(ComputeFunction.Convolve,dIdX); // This convolves the output of the previous element on the stack (the input) with dIdX
		computeStack.Push (ComputeFunction.Convolve, blurdIdX); //Blur the X-derivative by convolving with gaussian

		//Iy
		computeStack.Push(ComputeFunction.Convolve,dIdY);
		dIdY.AttachTextureAtIndex (computeStack.inputTexture, ResourceManager.InputIndex); //Non linear branching! Changing the input of dIdY to the computeStack's Input makes this operation parallel to the X-derivative operation above

		computeStack.Push (ComputeFunction.Convolve, blurdIdY); //The most recent output on the stack is still dIdY's output

		//dI
		computeStack.Push(ComputeFunction.Add,dI); // L1 Norm dIdY and dIdX
		dI.AttachTextureAtIndex (blurdIdX.GetTexturePointerAtIndex (ResourceManager.OutputIndex), ResourceManager.Filter1Index);

		computeStack.Push (ComputeFunction.Convolve, blurdI);

		//##############
		//# GET OUTPUT #
		//##############
		nativeOutputTexturePtr = computeStack.GetOutputTexture ();
	}
	
	// Update is called once per frame
	void Update () {
		computeStack.Dispatch (); //Dispatch the computation on the GPU
	}
}
