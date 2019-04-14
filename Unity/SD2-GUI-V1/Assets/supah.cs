using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.IO;


public class supah : MonoBehaviour {

	//public Dropdown fTest;
	public Text enterText;
	//public Text transferText;
	//public Button saveFileButton;
	//public Button incorrectTest;
	//public Button feedBackButton;
	// Use this for initialization
	void Start () 
	{
		//saveFileButton.onClick.AddListener(Save);
		//transferText.text = "";
	}
	
	// Update is called once per frame
	void Update () 
	{
		// this gets the text of the option currently selected in the dropdown button
		//print(fTest.options[fTest.value].text);
		//print(enterText.text);
		//incorrectTest.colors.normalColor = incorrectColor;
		//ColorBlock cb = incorrectTest.colors;
	//	cb.normalColor = new Color(1.0f, 0.0f, 0.0f, 1.0f);
		//cb.highlightedColor = new Color(1.0f, 0.0f, 0.0f, 1.0f);
	//	cb.highlightedColor = new Color(0.0f, 1.0f, 0.0f, 1.0f);
	//	incorrectTest.colors = cb;
	//print(enterText.text);
	//transferText.text = enterText.text;

	PlayerPrefs.SetString("filename",enterText.text);

	//print(transferText.text);

	}

	void Save ()
	{
	/*
		StreamWriter writer = new StreamWriter("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\" + enterText.text + ".csv", true);
		writer.WriteLine("this is a test,i,think,this,will,work");
		writer.Close();

		// changes the text of the button we pass in 
		saveFileButton.GetComponentInChildren<Text>().text = "PASS";
		
		feedBackButton.GetComponentInChildren<Text>().text = "You have executed the motion correctly!!!";
		*/
		//print(enterText.text);
	}

}
