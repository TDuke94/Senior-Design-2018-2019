using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Globalization;
using System.IO.Ports;
using System;
using System.IO;
using UnityEngine.UI;
using UnityEngine.SceneManagement;


public class ConductingEval : MonoBehaviour 
{
	SerialPort sp = new SerialPort("\\\\.\\COM14", 115200);

	public Button passFailButton;
	public Button feedBackButton;
	public Button back;
	public GameObject arm;

	// constants: do not treat like varaibles please :D
	private static int rollingAvg = 20;
	private static int fingerCount = 0;
	private static int IMUCount = 1;
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

	// kinematic filter storage
	private float[,] accelRawPrev = new float[IMUCount,3];
	private float[] magnitudePrev = new float[IMUCount];

	// evaluation results
	private static int debounce = 3;
	private int dbCounter;
	private bool lastState;
	private bool[] dbArray = new bool[debounce];
	private static int times = 10;
	private int timeIndex;
	float [] deltaT =  new float[times];
	float beatsPerMinute;
	float lastTime;
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

		firstFlag = true;
		
		for(int i =0; i < times; i++)
			deltaT[i] = 0.0f;

		timeIndex = 0;
		lastTime = Time.time;

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

		dbCounter = 0;

		lastState = false;

		// consider initialzing the buttons and GUI to a standard.
		ColorBlock cb = passFailButton.colors;
		cb.normalColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);
		cb.highlightedColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);
		passFailButton.colors = cb;

		feedBackButton.GetComponentInChildren<Text>().text = "Calibrating...";

		// IN
		//arm.transform.rotation =  Quaternion.Euler(0.0f, 5.0f,  -30.0f);
		
		// OUT
		//arm.transform.rotation =  Quaternion.Euler(0.0f, 5.0f,  30.0f);

		//Down
		//arm.transform.rotation =  Quaternion.Euler(0.0f, 0.0f,  0.0f);

		//up
		arm.transform.rotation =  Quaternion.Euler(0.0f, 17.0f,  0.0f);

		back.onClick.AddListener(TaskOnClick);
	}

	// Update is called once per frame
	void Update () 
	{
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

			// Rotation based on Roll and Pitch
			float smooth = 0.0f; 

			Vector3 baselineG = new Vector3(accelRaw[0,0], accelRaw[0,1], accelRaw[0,2]);

			baselineG.Normalize();

			baselineG *= gravityCal[0];

			accelVectors[0] = accelVectors[0] - baselineG;

			calcVelocity(accelVectors[0]);

			testDirection = findDirection();
			
			float threshold = 3.0f;

			if(testDirection != 0)
			{
				float currentTime = Time.time;
				timeIndex++;
				
				float delta = currentTime - lastTime;

				lastTime = currentTime;

				if(timeIndex == times)
					timeIndex = 0;

				deltaT[timeIndex] = delta;
				if(deltaT[timeIndex] > threshold)
				{
					for(int i = 0; i < times; i++)
						deltaT[i] = 0.0f;
				}

				int count = 0;
				float sum = 0.0f;

				for(int i =0; i < times; i++)
				{
					if(deltaT[i] != 0)
					{
						sum+= deltaT[i];
						count++;
					}
				}

				float average = sum / count;

				float beatsPerSecond = 1.0f / average;

				beatsPerMinute = beatsPerSecond * 60.0f;

			}
			if(!float.IsNaN(beatsPerMinute))
				feedBackButton.GetComponentInChildren<Text>().text = beatsPerMinute.ToString();

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
	
	private void OnApplicationQuit()
     {
         sp.Close();
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
		int index = 0;
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

	// this is a feature :D
	private void logData()
	{
		string  filename = PlayerPrefs.GetString("filename", "No Name");
		//StreamWriter writer = new StreamWriter("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\" + filename + ".csv", true);
		StreamWriter writer = new StreamWriter("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\testData.csv", true);

		writer.WriteLine (
			accelRaw[0,0].ToString() + "," + accelRaw[0,1].ToString()+ "," + accelRaw[0,2].ToString()
			+
			"," + "," 
			+
			testDirection.ToString()
			+
			"," + "," 
			+
			beatsPerMinute.ToString()
			);
		writer.Close();
	}	

}


