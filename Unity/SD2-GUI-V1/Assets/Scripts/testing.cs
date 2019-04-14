using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Globalization;
using System.IO.Ports;
using System;
using System.IO;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class testing : MonoBehaviour 
{
	SerialPort sp = new SerialPort("\\\\.\\COM14", 115200);

	// this is used internally to reference the joint objects more efficiently
	private GameObject[,] fingerJoints = new GameObject[4,3];
	
	//public GameObject wrist - these are set in the editor
	public GameObject indexFingerJoint1;
	public GameObject indexFingerJoint2;
	public GameObject indexFingerJoint3;
	public GameObject middleFingerJoint1;
	public GameObject middleFingerJoint2;
	public GameObject middleFingerJoint3;
	public GameObject ringFingerJoint1;
	public GameObject ringFingerJoint2;
	public GameObject ringFingerJoint3;
	public GameObject pinkyFingerJoint1;
	public GameObject pinkyFingerJoint2;
	public GameObject pinkyFingerJoint3;
	public GameObject thumbJoint1;
	public GameObject thumbJoint2;
	//public Dropdown fTest;
	public Button passFailButton;
	public Button feedBackButton;
	//public Text enterText;
	//public Button saveFileButton;
	//public GameObject wrist;
	//public Text enterText;
	public Button back;
	public Dropdown solDropdown;
	public GameObject solObject;

	// constants: do not treat like varaibles please :D
	private static int rollingAvg = 20;
	private static int fingerCount = 4;
	private static int IMUCount = 5;
	private static int gravityCount = 60;

	// internally used flags
	private bool firstFlag;

	// externally accessible boolean for calibration
	public bool calibrationFlag;

	// internal analysis and manipulation variables
	private short[] t = new short[15];
	private float[,] arr = new float[3, rollingAvg];
	private static float[] sum = new float[3];
	private float[,] velocityAverage = new float[3, rollingAvg];
	private static int accelAvgCount;
	// we need a timeout here
	private int timeoutCounter;
	private int kinematicCounter;
	// calibration gravity reference values
	private float[] gravityCal = new float[IMUCount];
	private float[,] gravityAverage = new float[IMUCount, gravityCount];
	private int calibrationCounter;

	// primary analysis variables
	private Vector3 palmVelocity;
	private float[,] accelRaw = new float[IMUCount,3];
	private Vector3[] accelVectors = new Vector3[IMUCount];
	private float[] magnitude = new float[IMUCount];
	private float[] fingerCurl = new float[fingerCount]; // UPDATE THIS NUMBER TO FINGER COUNT
	private float aPitch, aRoll;

	// kinematic filter storage
	private float[,] accelRawPrev = new float[IMUCount,3];
	private float[] magnitudePrev = new float[IMUCount];

	// evaluation results
	private bool[] solfege = new bool[7];
	private bool keyboard;
	private static int debounce = 3;
	private int dbCounter;
	private bool lastState;
	private bool[] dbArray = new bool[debounce];
	
	// test variables - remove
	private int test;
	private int testDirection;
	


	// Use this for initialization
	void Start ()
	{
		// pass on the sp com and this will handle connection
		
		// just for testing
		sp.Open();
		sp.ReadTimeout = 200;
		
		// having references to the joints and putting them in a 2D array
		configHinges();

		firstFlag = true;
		
		// setup for rolling average
		for(int i =0; i < 3; i++)
		{
			for(int j = 0; j < rollingAvg; j++)
			{
				arr[i,j] = 0.0f;
			}

			sum[i] = 0.0f;
		}
		
		// initialze this count
		accelAvgCount = 0;

		// set the calibration counter to 0 to start
		calibrationCounter = 0;

		timeoutCounter = 0;

		calibrationFlag = true;

		kinematicCounter = 0;

		//keyboard posture was done correctly
		
		// initialze the pass fail button to nothing
		//passFailButton.GetComponentInChildren<Text>().text = "";
		
		dbCounter = 0;

		lastState = false;

		// consider initialzing the buttons and GUI to a standard.
		ColorBlock cb = passFailButton.colors;
		cb.normalColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);
		cb.highlightedColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);
		passFailButton.colors = cb;

		feedBackButton.GetComponentInChildren<Text>().text = "Calibrating...";

		// LOOK BACK HERE soon
		

	//	string  solfegeMotion = PlayerPrefs.GetString("dropdown", "No Name");

		if (PlayerPrefs.GetString("keyboard") == "k")
		{
			solObject.SetActive(false);
		//	solDropdown.Hide();
		}


	//	solDropdown.options[solDropdown.value].text = solfegeMotion;

		back.onClick.AddListener(TaskOnClick);
		
	//	print(solfegeMotion);
	}

	// Update is called once per frame
	void Update () 
	{
		//string updatedSolMotion = solDropdown.options[solDropdown.value].text;
		int solfegeIndex = solDropdown.value;
		print (solfegeIndex);
		//print(updatedSolMotion);
		// try openning the comm port we established in our start function
		if(!sp.IsOpen) return;
		
		// simple try catch logic to throw an exception for when Bluetooth connection is lost
		try
		{
			//sp.Write("heya");
			if(!parseAccel()) return;

			int accelIndex = 0; // should be 0, but for testing

			updateAccelRaw();

			calcMagnitude();
			
			// getting rid of sudden (kinematically impossible) jumps in accelRaw data
			kinematicFilter();

			// if the flag was set by a button press, set the counter to perform calibration
			if (calibrationFlag)
			{
				calibrationCounter = gravityCount;
				//print(calibrationFlag);
				calibrationFlag = false;
			}

			if (calibrationCounter > 0)
			{
				calibrationCounter--;
				calibrate();
				return;
			}
			
			accelRawToVector();

			// calculating Pitch and Roll based on Raw Acceleration Data
			aPitch = - Mathf.Atan2(-(float)accelRaw[accelIndex,1], (float)accelRaw[accelIndex,2]) * 180 / Mathf.PI;
			aRoll = - Mathf.Atan2((float)accelRaw[accelIndex,0], (float)accelRaw[accelIndex,2]) * 180 / Mathf.PI;

			// Rotation based on Roll and Pitch
			float smooth = 0.0f; 
			
			calcFingerCurl();

			Vector3 baselineG = new Vector3(accelRaw[1,0], accelRaw[1,1], accelRaw[1,2]);

			baselineG.Normalize();

			baselineG *= gravityCal[1];

			accelVectors[1] = accelVectors[1] - baselineG;

			// this should be accelVectors[0]
			calcVelocity(accelVectors[1]);

			// perform evaluation functions
			for (int i = 0; i < 7; i++)
				solfege[i] = Solfege.Evaluate(i, aRoll, aPitch, fingerCurl);

			keyboard = Keyboard.Evaluate(aRoll, aPitch, fingerCurl);

			testDirection = findDirection();

			string selectedMotion = PlayerPrefs.GetString("keyboard");

			if (selectedMotion == "k")
			{
				bool kbDisplay = booleanDebounce(keyboard);
				booleanDisplay(kbDisplay);
			}
			else if (selectedMotion == "s")
			{
				bool solDisplay = booleanDebounce(solfege[solfegeIndex]);
				booleanDisplay(solDisplay);
			}

			print(selectedMotion);
			
			// data logging, very helpful :D
			logData();
		}
		catch (System.Exception)
		{
			throw;
		}
	}

	private bool booleanDebounce(bool kb)
	{
		bool retval;

		dbArray[dbCounter++ % debounce] = kb;

		if(lastState)
		{
			retval = false; 
			foreach(bool b in dbArray)
				retval |= b;
		}
		else
		{
			retval = true;
			foreach(bool b in dbArray)
				retval &= b;
		}

		return retval;
	}

	private void booleanDisplay(bool bb)
	{
		if (bb)
		{
			lastState = true;
			//keyboard posture was done correctly
			ColorBlock cb1 = passFailButton.colors;
			cb1.normalColor = new Color(0.0f, 1.0f, 0.0f, 1.0f);
			cb1.highlightedColor = new Color(0.0f, 1.0f, 0.0f, 1.0f);
			passFailButton.colors = cb1;
			passFailButton.GetComponentInChildren<Text>().text = "PASS";

			feedBackButton.GetComponentInChildren<Text>().text = "You have executed the motion correctly!!!";
		}
		else 
		{
			lastState = false;
			//keyboard posture was done correctly
			ColorBlock cb1 = passFailButton.colors;
			cb1.normalColor = new Color(1.0f, 0.0f, 0.0f, 1.0f);
			cb1.highlightedColor = new Color(1.0f, 0.0f, 0.0f, 1.0f);
			passFailButton.colors = cb1;
			passFailButton.GetComponentInChildren<Text>().text = "FAIL";

			feedBackButton.GetComponentInChildren<Text>().text = "You are not within the boundaries.";

		}
			
	}

	void FixedUpdate()
	{
		Quaternion rotation = Quaternion.Euler(aRoll, aPitch, 0.0f);		
		//GetComponent<Rigidbody>().MoveRotation(rotation);
		GetComponent<Rigidbody>().MoveRotation(rotation);

		for(int i = 0; i < 4; i++)
			applyCurl(fingerCurl[i], i);
	}

	 private bool parseAccel()
	{
		bool retval = false;

		byte temp;
		byte[] bytes = new byte[2];

		do
		{
			temp = (byte)sp.ReadByte();
		} while (temp != 65);
		
		// gets rid of the second A character
		//temp = (byte)sp.ReadByte();

		if (temp != 65)
			return false;

		int frameSize = IMUCount * 4;
		int frameBreakCount = 0;
		for(int i = 0; i < frameSize ; i++)
		{
			
			if (i % 4 == 0)
			{
				// remove the midpoint flags
				
				temp = (byte)sp.ReadByte();
				if (temp != 65)
					break;
				frameBreakCount++;
				continue;
			}
			

			retval = false;
			bytes[1] = (byte)sp.ReadByte();
			bytes[0] = (byte)sp.ReadByte();

			if((bytes[0] == 0) && (bytes[1] == 0))
				break;

			if(i == (frameSize - 1))
				retval = true;
	
			t[i - frameBreakCount] =  System.BitConverter.ToInt16(bytes, 0);
		}

		sp.DiscardInBuffer();

		return retval;
	}

	private void calcMagnitude()
	{
	
		for (int i = 0; i < IMUCount; i++)
		{
			float localSum = 0;
			for (int j = 0; j < 3; j++)
				localSum += accelRaw[i,j] * accelRaw[i,j];
			magnitude[i] = Mathf.Sqrt(localSum);
		}
	}

	void TaskOnClick ()
	{

        SceneManager.LoadScene(0);
	}

	private void kinematicFilter()
	{
		bool kinematicFlag = true;

		if(firstFlag)
		{
			for(int i = 0;  i < IMUCount; i++)
			{		
				magnitudePrev[i] = magnitude[i];

				for(int j = 0; j < 3; j++)
				{
					accelRawPrev[i,j] = accelRaw[i,j];
				}
			}

			firstFlag = false;

			return;
		}

		float deltaFilter = 11000.0f;

		for(int i =0; i < IMUCount; i++)
			for (int j = 0; j < 3; j++)
				if(Mathf.Abs(accelRawPrev[i,j] - accelRaw[i,j]) > deltaFilter)
					kinematicFlag = false;

		if (kinematicFlag) // update the last known good slot
		{
			for(int i = 0;  i < IMUCount; i++)
			{		
				magnitudePrev[i] = magnitude[i];

				for(int j = 0; j < 3; j++)
				{
					accelRawPrev[i,j] = accelRaw[i,j];
				}
			}

			kinematicCounter = 0;
		}
		else // replace the junk with the last known good
		{
			for(int i = 0;  i < IMUCount; i++)
			{		
				magnitude[i] = magnitudePrev[i];

				for(int j = 0; j < 3; j++)
				{
					accelRaw[i,j] = accelRawPrev[i,j];
				}
			}

			kinematicCounter++;

			if(kinematicCounter == 2)
			{
				kinematicCounter = 0;
				firstFlag = true;
			}
		}
	}

	private void calibrate()
	{
		for (int i = 0; i < IMUCount; i++)
		{
			gravityAverage[i, calibrationCounter] = magnitude[i];
		}

		// if we are at the end of the calibration routine
		if (calibrationCounter == 0)
		{
			for (int i = 0; i < IMUCount; i++)
			{
				float sum = 0.0f;
				for (int j = 0; j < gravityCount; j++)
				{
					sum += gravityAverage[i, j];
				}

				gravityCal[i] = sum / gravityCount;
			}
		}
	}

	private void calcVelocity(Vector3 aV)
	{
		accelAvgCount++;

		if(accelAvgCount == rollingAvg)
			accelAvgCount = 0;

		for (int i = 0; i < 3; i++)
		{
			sum[i] -= arr[i, accelAvgCount];

			if(i == 0)
				arr[i,accelAvgCount] = aV.x;
			else if(i == 1)
				arr[i,accelAvgCount] = aV.y;
			else if(i == 2)
				arr[i,accelAvgCount] = aV.z;
			
			sum[i] += arr[i, accelAvgCount];
		}

		// integration is sum * dt
		palmVelocity = new Vector3(sum[0], sum[1], sum[2]);

		// apply dt
		palmVelocity *= 0.01f;
	}

	private void updateAccelRaw()
	{
		for (int i = 0; i < IMUCount; i++)
			for (int j = 0; j < 3; j++)
				accelRaw[i,j] = t[i * 3 + j];
	}

	private void accelRawToVector()
	{
		for (int i = 0; i < IMUCount; i++)
			accelVectors[i].Set(accelRaw[i,0], accelRaw[i,1], accelRaw[i,2]);
	}

	private void configHinges()
	{

		fingerJoints[0,0] = indexFingerJoint1;
		fingerJoints[0,1] = indexFingerJoint2;
		fingerJoints[0,2] = indexFingerJoint3;
		fingerJoints[1,0] = middleFingerJoint1;
		fingerJoints[1,1] = middleFingerJoint2;
		fingerJoints[1,2] = middleFingerJoint3;
		fingerJoints[2,0] = ringFingerJoint1;
		fingerJoints[2,1] = ringFingerJoint2;
		fingerJoints[2,2] = ringFingerJoint3;
		fingerJoints[3,0] = pinkyFingerJoint1;
		fingerJoints[3,1] = pinkyFingerJoint2;
		fingerJoints[3,2] = pinkyFingerJoint3;
	}
	
	private void setJoint(GameObject joint, float targetPosition)//JointLimits fingerLimit, JointSpring fingerSpring, )
	{
		HingeJoint hingeSpring = joint.gameObject.GetComponent<HingeJoint>();
		JointSpring localSpring = hingeSpring.spring;
		localSpring.targetPosition = targetPosition;

		hingeSpring.spring = localSpring;
	}

	private void applyCurl(float curl, int index)
	{
		setJoint(fingerJoints[index,0], curl * 90.0f);
		setJoint(fingerJoints[index,1], curl * 75.0f);
		setJoint(fingerJoints[index,2], curl * 30.0f);
	}
	
	private void OnApplicationQuit()
     {
         sp.Close();
     }

	private void calcFingerCurl()
	{
		Vector2 reference = new Vector2 (accelVectors[0].y, accelVectors[0].z);
		reference.Normalize();

		for (int i = 0; i < fingerCount; i++)
		{
			Vector2 fingerVector = new Vector2 (accelVectors[i+1].y, accelVectors[i+1].z);
			fingerVector.Normalize();

			float fDot = Vector2.Dot(fingerVector, reference);
			fDot = Mathf.Clamp(fDot, -1.0f, 1.0f);
			
			float fAngle = Mathf.Acos(fDot);

			fingerCurl[i] = fAngle / Mathf.PI;
		}
	}

	/*
	 * Returns an encoded  Integer type if a motion is detected, otherwise nothing
	 *
	 * implements a timeout to ensure multiple rapid motions are not counted
	 *
	 * Encoding:
	 *		0:No motion event
	 *		1:down
	 *		2:right
	 *		3:left
	 *		4:up
	 */
	private int findDirection()
	{
		// index should be 0
		int index = 1;
		int timeoutValue = 13;

		if (timeoutCounter > 0)
		{
			timeoutCounter--;
			return 0;
		}

		// pull these local - not technically necessary, but nice
		float x = accelRaw[index,0];
		float localMagnitude = accelRaw[index,2];
		float localGravity =  gravityCal[index];

		// Down
		// This is least likely to be wrong
		// False positive rate is low beyond 3k
		if ((localMagnitude - localGravity) < -5000.0f)
		{
			timeoutCounter = timeoutValue;
			return 1;
		}

		// Right
		// by observation, this was reliable, but likely to couple
		// therefore, use a very high threshold
		if (x > 4000.0f)
		{
			timeoutCounter = timeoutValue;
			return 2;
		}

		// Left
		// This can couple onto down
		if (x < -4000.0f)
		{
			timeoutCounter = timeoutValue;
			return 3;
		}

		// Up
		// this is reliable, but not necesarily clear
		// select last
		if ((localMagnitude - localGravity) > 3000.0f)
		{
			timeoutCounter = timeoutValue;
			return 4;
		}

		return 0;
	}


	private void logData()
	{
		string  filename = PlayerPrefs.GetString("filename", "No Name");
		//StreamWriter writer = new StreamWriter("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\" + filename + ".csv", true);
		//writer.WriteLine("this is a test,i,think,this,will,work");
		//actually log stuff here
		//writer.Close();
		//Write some text to the csv file
		//StreamWriter writer = new StreamWriter("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\TestData.csv", true);
		StreamWriter writer = new StreamWriter("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\" + filename + ".csv", true);
		//   writer.WriteLine(gyro[0].ToString() + ","  +  gyro[1].ToString() + "," + gyro[2].ToString());
		writer.WriteLine (
			accelRaw[0,0].ToString() + "," + accelRaw[0,1].ToString()+ "," + accelRaw[0,2].ToString()
			+
			"," + ","+
			accelRaw[1,0].ToString() + "," + accelRaw[1,1].ToString()+ "," + accelRaw[1,2].ToString()
			+
			"," + ","+
			accelRaw[2,0].ToString() + "," + accelRaw[2,1].ToString()+ "," + accelRaw[2,2].ToString()
			+
			"," + ","+
			accelRaw[3,0].ToString() + "," + accelRaw[3,1].ToString()+ "," + accelRaw[3,2].ToString()
			+
			"," + ","+
			accelRaw[4,0].ToString() + "," + accelRaw[4,1].ToString()+ "," + accelRaw[4,2].ToString()
			+
			"," + ","+
			fingerCurl[0].ToString() + ","  + fingerCurl[1].ToString() + "," +  fingerCurl[2].ToString() + "," + fingerCurl[3].ToString()
			+
			"," + ","+
			keyboard.ToString()
			);
		writer.Close();
	}	

}

class Keyboard
{
	private static float correctPitch  = 0.0f;
	private static float correctRoll   = 0.0f;
	private static float[] correctCurl = {0.5f, 0.5f, 0.5f, 0.5f};

	private static int fingerCount = 4;
	private static float pitchTolerance = 10.0f;
	private static float rollTolerance = 10.0f;
	private static float curlTolerance = 0.20f;

	public static bool Evaluate(float roll, float pitch ,float[] curl)
	{
		if(Mathf.Abs(roll - correctRoll) > rollTolerance)
			return false;
		if(Mathf.Abs(pitch - correctPitch) > pitchTolerance)
			return false;
		
		for (int i = 0; i < fingerCount; i++)
			if(Mathf.Abs(correctCurl[i] - curl[i]) > curlTolerance)
				return false;
		
		return true;
	}

}


class Solfege 
{
	private static float[] correctPitch = {0.0f, 35.0f, 0.0f, 0.0f, 0.0f, 5.0f, 35.0f};
	private static float[] correctRoll =  {0.0f, 0.0f, 0.0f, -25.0f, 90.0f, 0.0f, 0.0f};
	private static float[,] correctCurl	= {
				{1.0f, 1.0f, 1.0f, 1.0f},
				{0.0f, 0.0f, 0.0f, 0.0f},
				{0.0f, 0.0f, 0.0f, 0.0f},
				{0.8f, 0.8f, 0.8f, 0.8f},
				{0.0f, 0.0f, 0.0f, 0.0f},
				{0.45f, 0.45f, 0.45f, 0.45f},
				{0.0f, 1.0f, 1.0f, 1.0f}
				};

	private static int fingerCount = 4;
	private static float pitchTolerance = 10.0f;
	private static float rollTolerance = 10.0f;
	private static float curlTolerance = 0.25f;

	// returns whether you passed or failed the motion
	public static bool Evaluate(int index, float roll, float pitch ,float[] curl)
	{
		if(Mathf.Abs(roll - correctRoll[index]) > rollTolerance)
			return false;
		if(Mathf.Abs(pitch - correctPitch[index]) > pitchTolerance)
			return false;
		
		for (int i = 0; i < fingerCount; i++)
			if(Mathf.Abs(correctCurl[index,i] - curl[i]) > curlTolerance)
				return false;
		
		return true;
	}
}
