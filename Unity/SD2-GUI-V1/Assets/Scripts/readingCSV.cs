using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.UI;

public class readingCSV : MonoBehaviour {

public TextAsset csvFile;

	char delim = ',';
	char line = '\n';
	// Use this for initialization
	public Text saveSession;
	 public Button sessionButton;
	void Start ()
	{
	
	/*
	 string path = "Assets/testingCSV.csv";

        //Read the text from directly from the test.txt file
        StreamReader reader = new StreamReader(path); 
        Debug.Log(reader.ReadToEnd());
        reader.Close();
	*/


	//string word = File.ReadAllText("C:\\Users\\dgdan\\Desktop\\SD2-GUI-V1\\Assets\\testingCSV.csv");
	//string word = File.ReadAllText("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\TestData.csv");
	//string[] records = word.text.Split (line);
	//foreach (string record in records)
	//{
	//string[] fields = word.Split(delim);
	//print(fields[0]);
	//}
	//foreach(string field in fields)
	//{
		//contentArea.text += field + "\t";
	//}
		//contentArea.text += '\n';
	//}
	

	
	//when we save we can do a playerprefs
	

	//EditorUtility.RevealInFinder(Application.dataPath + "/Rescources/")
/* System.Diagnostics.Process p = new System.Diagnostics.Process();
 p.StartInfo = new System.Diagnostics.ProcessStartInfo("explorer.exe");
 p.Start();
*/
	// Application.OpenURL("file://[C:\\Users\\dgdan\\Desktop\\SD2-GUI-V1\\Assets\\]");

	}
	//string empty = "";
	
	// Update is called once per frame
	//int count =0;
	void Update () 
	{
				//print(COucount);
		//when a specific event happens here i need to count up.. so i guess when the record button is pressed?
	//	sessionButton.onClick.AddListener(() => CountIt(count));
		
	}
	/*
	int c;
	int CountIt(int count)
	{
		count+=1;
		PlayerPrefs.SetInt("setCount", count);
		c = PlayerPrefs.GetInt("setCount");
		c++;
		PlayerPrefs.SetString(c.ToString(),saveSession.text);

		if(PlayerPrefs.GetString("2") != empty)
		{
		print(PlayerPrefs.GetString("1"));
		
		}
		//print(c);
		return c;
	}
	*/
}
