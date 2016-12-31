using UnityEngine;
using System.Collections;

public class MetalPlane : MonoBehaviour {
	
	public GameObject leftEyeRenderPlane;

	bool isActivated = false;

	Texture2D outputTexture;

	CornerDetector cornerDetector;

	// Use this for initializations

	void Start () 
	{
		cornerDetector = new CornerDetector (5.0f);
		outputTexture = new Texture2D (2,2);
		isActivated = true;
		//MUDebugger.instance.AddAdditionalDebugInfo ("Threshold", GetThresholdValue);
	}

	void Update () 
	{
		if (isActivated) 
		{
			cornerDetector.ComputeCorners ();
			outputTexture.UpdateExternalTexture (cornerDetector.nativeOutputTexturePtr);
			leftEyeRenderPlane.GetComponent<Renderer> ().material.mainTexture = outputTexture;
			//outputTexture.Apply ();
		}
	}

	public string GetThresholdValue()
	{
		return cornerDetector.threshold.ToString ();
	}
}