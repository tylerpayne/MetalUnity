using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class MetalUnity {
	#region DLL Imports
	[DllImport ("__Internal")]
	private static extern void MUSetupMetalUnity();

	[DllImport ("__Internal")]
	private static extern int MURmsLength();

	[DllImport ("__Internal")]
	private static extern int MUNewComputeManagerForFnc (string fnc);

	[DllImport ("__Internal")]
	private static extern int MUNewResourceManager ();

	[DllImport ("__Internal")]
	private static extern void MUCompute (int cm, int rm);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGetPixelValue (System.IntPtr tex, System.IntPtr coord, int bpr);

	//Video
	[DllImport ("__Internal")]
	private static extern void MUSetupNativeVideoInput ();

	[DllImport ("__Internal")]
	private static extern void MUStartRecordingNativeVideo ();

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGetVideoTexturePointer ();
	#endregion

	public static void SetupMetalUnity()
	{
		MUSetupMetalUnity ();
	}

	public static void SetupNativeVideoInput()
	{
		MUSetupNativeVideoInput ();
	}

	public static void StartRecordingNativeVideo()
	{
		MUStartRecordingNativeVideo ();
	}

	public static System.IntPtr GetVideoTexturePointer()
	{
		return MUGetVideoTexturePointer ();
	}

	public static void Compute (ComputeManager cm, ResourceManager rm)
	{
		MUCompute (cm.iD, rm.iD);
	}

	public static ComputeManager NewComputeManagerForFnc(string fnc)
	{
		return new ComputeManager(MUNewComputeManagerForFnc(fnc),fnc);
	}

	public static ResourceManager NewResourceManager()
	{
		return new ResourceManager(MUNewResourceManager());
	}

	public static float[] GetPixelValue(System.IntPtr texture, int x, int y, int bytesPerRow)
	{
		int[] coords = new int[]{ x, y };
		System.IntPtr coordPtr = Marshal.AllocHGlobal (Marshal.SizeOf(typeof(int))*2);
		Marshal.Copy (coords, 0, coordPtr, 2);

		System.IntPtr retval = MUGetPixelValue (texture, coordPtr, bytesPerRow);
		float[] pixelVals = new float[2];

		Marshal.Copy (retval, pixelVals, 0, 2);

		return pixelVals;
	}
}

public class ResourceManager
{
	#region DLL Imports
	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerate3x3SobelXOperator (int rm, string idx);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerate3x3SobelYOperator (int rm, string idx);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerate5x5SobelXOperator (int rm, string idx);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerate5x5SobelYOperator (int rm, string idx);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerateGaussianFilter (int rm, string idx, float sigma, int width);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerate3x3LaplacianOperator(int rm, string idx);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerateLoGFilter (int rm, string idx, float sigma, int width);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerateDoGFilter (int rm, string idx, float sigma, int width);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGenerateEmptyTexture (int rm, string idx, int w, int h);

	[DllImport ("__Internal")]
	private static extern void MUFillTextureWithFloat (System.IntPtr tex, System.IntPtr replaceRegion, System.IntPtr data, int bpr);

	[DllImport ("__Internal")]
	private static extern void MUAttachTextureAtIndex (int rm, System.IntPtr intx, string idx);

	[DllImport ("__Internal")]
	private static extern void MUAttachFloatAtIndex (int rm, System.IntPtr fval, string idx);

	[DllImport ("__Internal")]
	private static extern System.IntPtr MUGetOutputTexture (int rm, int mm);
	#endregion

	public int iD;

	public ResourceManager(int newId)
	{
		this.iD = newId;
	}

	public System.IntPtr Generate3x3SobelXOperator(string idx)
	{
		return MUGenerate3x3SobelXOperator(iD,idx);
	}

	public System.IntPtr Generate3x3SobelYOperator(string idx)
	{
		return MUGenerate3x3SobelYOperator(iD,idx);
	}

	public System.IntPtr Generate5x5SobelXOperator(string idx)
	{
		return MUGenerate5x5SobelXOperator(iD,idx);
	}

	public System.IntPtr Generate5x5SobelYOperator(string idx)
	{
		return MUGenerate5x5SobelXOperator(iD,idx);
	}

	public System.IntPtr GenerateGaussianFilter (string idx, float sigma, int width)
	{
		return MUGenerateGaussianFilter (iD,idx,sigma, width);
	}

	public System.IntPtr Generate3x3LaplacianOperator(string idx)
	{
		return MUGenerate3x3LaplacianOperator (iD, idx);
	}

	public System.IntPtr GenerateLoGFilter (string idx, float sigma, int width)
	{
		return MUGenerateLoGFilter (iD,idx,sigma, width);
	}

	public System.IntPtr GenerateDoGFilter ( string idx, float sigma, int width)
	{
		return MUGenerateDoGFilter (iD,idx,sigma, width);
	}

	public System.IntPtr GenerateEmptyTexture (string idx, int w, int h)
	{
		return MUGenerateEmptyTexture (iD,idx, w, h);
	}

	public void FillTextureWithFloat (System.IntPtr tex, int[] replaceRegion, float[] data, int td)
	{
		System.IntPtr replaceRegionPtr = Marshal.AllocHGlobal (Marshal.SizeOf (typeof(int))*replaceRegion.Length);
		System.IntPtr dataPtr = Marshal.AllocHGlobal (Marshal.SizeOf (typeof(float))*data.Length);

		Marshal.Copy (replaceRegion, 0, replaceRegionPtr, replaceRegion.Length);
		Marshal.Copy (data, 0, dataPtr, data.Length);

		MUFillTextureWithFloat (tex, replaceRegionPtr, dataPtr, td);
	}


	public void AttachTextureAtIndex(System.IntPtr intx, string idx)
	{
		MUAttachTextureAtIndex(iD, intx, idx);
	}

	public void AttachFloatAtIndex(float[] fval, string idx)
	{
		System.IntPtr fvalPtr = Marshal.AllocHGlobal (Marshal.SizeOf (typeof(float)));
		Marshal.Copy (fval, 0, fvalPtr, 1);
		MUAttachFloatAtIndex(iD, fvalPtr, idx);
	}

	public System.IntPtr GetOutputTexture(int mipmaplevel)
	{
		return MUGetOutputTexture(iD,mipmaplevel);
	}

}

public class ComputeFunction
{
	public static string Convolve = "Convolve";
	public static string SumTwoFilters = "SobelGradient_Sum";
	public static string MagnitudeTwoFilters = "SobelGradient_Magnitude";
	public static string Subtract = "Subtract";
	public static string Add = "Add";
	public static string Multiply = "Multiply";
	public static string MultiplyConstant = "Multiply_Constant";
	public static string LocalMax = "LocalMax_Constant";
	public static string ClipGreater = "Clip_Greater_Constant";
	public static string ClipLess = "Clip_Less_Constant";
	public static string Grayscale = "Grayscale";

}

public class ComputeManager
{
	public int iD;

	public string computeFunction;

	public ComputeManager(int newId,string f)
	{
		this.iD = newId;
		this.computeFunction = f;
	}

}

public class ComputeStack
{
	private List<ComputeManager> computeStack;
	private List<ResourceManager> resourceStack;
	private System.IntPtr inputTexture;

	public ComputeStack(System.IntPtr input)
	{
		this.computeStack = new List<ComputeManager> ();
		this.resourceStack = new List<ResourceManager> ();
		this.inputTexture = input;
	}

	public void Push(string computeFunction, ResourceManager resourceManager)
	{

		if (functionCount() == 0) {
			resourceManager.AttachTextureAtIndex (inputTexture, "0");
		} else {
			resourceManager.AttachTextureAtIndex (resourceStack [resourceStack.Count - 1].GetOutputTexture (0), "0");
		}
		resourceStack.Add (resourceManager);
		computeStack.Add (MetalUnity.NewComputeManagerForFnc (computeFunction));
	}

	public void SetInputTexture(System.IntPtr tx)
	{
		inputTexture = tx;
		if (functionCount() > 0) {
			resourceStack [0].AttachTextureAtIndex (inputTexture, "0");
		}
	}

	public System.IntPtr GetOutputTexture()
	{
		return resourceStack [resourceStack.Count - 1].GetOutputTexture (0);
	}

	public int functionCount()
	{
		return computeStack.Count;
	}

	public void Dispatch()
	{
		for (int i = 0; i < computeStack.Count; i++) 
		{
			MetalUnity.Compute (computeStack [i], resourceStack [i]);
		}
	}


}