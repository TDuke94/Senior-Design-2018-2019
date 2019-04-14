using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class stopScript : MonoBehaviour {

public GameObject otherobj;
public Button backButton;
		
// your secound script name
public string scr;
	
	// Use this for initialization
	void Start ()
	{
		backButton.onClick.AddListener(Done);    
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void Done ()
	{
		//otherobj.GetComponent<testing>().enabled = false;
		otherobj.GetComponent<testing>().enabled = false;
		print("disabled");
	}
}
