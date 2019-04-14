using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class Start2 : MonoBehaviour {

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
		PlayerPrefs.SetString("keyboard","s");
		SceneManager.LoadScene(1);
	}

}
