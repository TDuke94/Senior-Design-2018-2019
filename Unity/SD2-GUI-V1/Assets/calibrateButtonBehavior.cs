using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class calibrateButtonBehavior : MonoBehaviour {

	public testing testingScript;
	public Button cal;
	// Use this for initialization

	void Start () 
	{
		cal.onClick.AddListener(TaskOnClick);
	}
	
	// Update is called once per frame
	void Update ()
	{

	}

	void TaskOnClick()
    {
        testingScript.calibrationFlag = true;
    }
	
}
