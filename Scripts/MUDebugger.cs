using UnityEngine;
using UnityEngine.UI;
using System;
using System.Collections;
using System.Collections.Generic;

public class MUDebugger : MonoBehaviour {

	public static MUDebugger instance;

	public bool isEnabled = true;

	private Canvas debugCanvas;
	private Text debugText;
	private List<string> otherDebugInfo;
	private List<Func<string>> otherDebugValues;

	// Use this for initialization
	void Start () {
		instance = this;
		otherDebugInfo = new List<string> ();
		otherDebugValues = new List<Func<string>> ();
		GameObject canvasObject = new GameObject ();
		canvasObject.transform.SetParent (transform);
		canvasObject.SetActive (isEnabled);
		debugCanvas = canvasObject.AddComponent<Canvas> ();
		debugCanvas.renderMode = RenderMode.ScreenSpaceOverlay;
		GameObject textObject = new GameObject ();
		textObject.transform.SetParent (transform);
		textObject.SetActive (true);
		debugText = textObject.AddComponent<Text> ();
		debugText.fontSize = 35;
	}
	
	// Update is called once per frame
	void Update () {

		if (isEnabled) 
		{
			debugCanvas.gameObject.SetActive (true);
			debugText.gameObject.SetActive (true);
			GetDebugText ();
		}
	
	}

	void GetDebugText()
	{
		for (int i = 0; i < otherDebugInfo.Count; i++) 
		{
			debugText.text += ((string)otherDebugInfo[i]) + ": " + otherDebugValues[i] + "\n";
		}
	}

	public void AddAdditionalDebugInfo(string info, Func<string> getInfoValue)
	{
		otherDebugInfo.Add (info);
		otherDebugValues.Add (getInfoValue);
	}
}
