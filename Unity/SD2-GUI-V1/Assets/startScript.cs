using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class startScript : MonoBehaviour {

	public Button done;
	// Use this for initialization
	void Start () 
	{
		done.onClick.AddListener(StartMotion);
	}
	
	// Update is called once per frame
	void Update () {

	}
	
	void StartMotion ()
	{
		PlayerPrefs.SetString("keyboard","k");
		SceneManager.LoadScene(1);
	}

}
