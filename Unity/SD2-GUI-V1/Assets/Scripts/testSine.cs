using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
//using System.Data;
//using Mono.Data.Sqlite;
using UnityEngine.SceneManagement;

using Random=UnityEngine.Random;

public class testSine : MonoBehaviour
{
public GameObject hand;
public GameObject arm;
public GameObject indexFinger;
//public GameObject indexMiddleJoint;
public GameObject middle;
public GameObject ring;
public GameObject pinky;
public GameObject thumb;

void Start()
{
	//here i want the initial start buttons pertaining to the 
}
/*
// here i can start seperating the data into segments
float x, y, z, w;
string iD1 = "";
void Update () 
{
	//if(iD1 && iD2&& iD3)
	iD1 = "B";
	// this would correlate tell me that the data is coming from that specific IMU
	if(iD1 == "A")
	{
		// x += Time.deltaTime * 50;
	x = Random.Range(0.0f,100.0f);
	y = Random.Range(0.0f,100.0f);
	z = Random.Range(0.0f,100.0f);
	w = Random.Range(0.0f,1.0f);
    // transform.rotation = Quaternion.Euler(0,x,0);
	hand.transform.rotation = new Quaternion(x,y, z, w);
	}

	//if(iD1 && iD2&& iD3)
	//iD1 = 2;
	// this would correlate tell me that the data is coming from that specific IMU
	if(iD1 == "B")
	{
		// x += Time.deltaTime * 50;
	x = Random.Range(0.0f,100.0f);
	y = Random.Range(0.0f,100.0f);
	z = Random.Range(0.0f,100.0f);
	w = Random.Range(0.0f,1.0f);
    // transform.rotation = Quaternion.Euler(0,x,0);
	arm.transform.rotation = new Quaternion(x,y, z, w);
	}
	/*
	// x += Time.deltaTime * 50;
	x = Random.Range(0.0f,100.0f);
	y = Random.Range(0.0f,100.0f);
	z = Random.Range(0.0f,100.0f);
	w = Random.Range(0.0f,1.0f);
    // transform.rotation = Quaternion.Euler(0,x,0);
	transform.rotation = new Quaternion(x,y, z, w);
	

	if(iD1 == "C")
	{
		// x += Time.deltaTime * 50;
	x = Random.Range(0.0f,100.0f);
	y = Random.Range(0.0f,100.0f);
	z = Random.Range(0.0f,100.0f);
	w = Random.Range(0.0f,1.0f);
    // transform.rotation = Quaternion.Euler(0,x,0);
	arm.transform.rotation = new Quaternion(x,y, z, w);
	}


}
*/

 float amplitudeX = 10.0f;
 float amplitudeY = 5.0f;
 float omegaX = 1.0f;
 float omegaY = 5.0f;
 float index;
 void Update(){
     index += Time.deltaTime;
     float x = amplitudeX*Mathf.Cos (omegaX*index);
     float y = Mathf.Abs (amplitudeY*Mathf.Sin (omegaY*index));
     hand.transform.localPosition= new Vector3(x,y,0);
 }



}



