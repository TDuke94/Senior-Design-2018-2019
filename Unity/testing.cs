using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Globalization;
using System.IO.Ports;
using System;
using System.IO;

public class testing : MonoBehaviour {

	SerialPort sp = new SerialPort("\\\\.\\COM14", 115200);

	// this is used internally to reference the joint objects more efficiently
	private GameObject[,] fingerJoints = new GameObject[4,3];
	
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

	// analysis tool variables
	private static int rollingAvg = 40;
	private static int accelAvgCount;
	private float x;
	private bool goodFlag;
	private short x1, y1, z1, x2, y2, z2, x3, y3, z3, w1;
	private short[] t = new short[8];
	private static float[] sum = new float[3];
	private float[,] arr = new float[3, rollingAvg];
	private float[,] velocityAverage = new float[3, rollingAvg];
	private Vector3 palmVelocity;
	private static int IMUCount = 2;
	private float[,] accelRaw = new float[IMUCount,3];
	private Vector3[] accelVectors = new Vector3[IMUCount];
	private float[] magnitude = new float[IMUCount];
	private float[] fingerCurl = new float[1]; // UPDATE THIS NUMBER TO FINGER COUNT
	private float	aPitch, aRoll;
	private float[,] accelRawPrev = new float[IMUCount,3];
	private bool firstFlag;
	private float[] magnitudePrev = new float[IMUCount];
	
	private int doo;
	private int test;
	// Use this for initialization
	void Start ()
	{

		// pass on the sp com and this will handle connection
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
			parseAccel();

			// return if our data isn't good :'(
			if(!goodFlag) return;

			int accelIndex = 0; // should be 0, but for testing

			updateAccelRaw();
			
			accelRawToVector();

			calcMagnitude();
			
			// getting rid of sudden (kinematically impossible) jumps in accelRaw data
			kinematicFilter();

			// calculating Pitch and Roll based on Raw Acceleration Data
			aPitch = Mathf.Atan2(-(float)accelRaw[accelIndex,1], (float)accelRaw[accelIndex,2]) * 180 / Mathf.PI;
			aRoll = Mathf.Atan2((float)accelRaw[accelIndex,0], (float)accelRaw[accelIndex,2]) * 180 / Mathf.PI;

			// Rotation based on Roll and Pitch
			float smooth = 0.0f; 
			
			//GetComponent<Rigidbody>().rotation = Quaternion.Slerp(GetComponent<Rigidbody>().rotation, rotation, Time.deltaTime * smooth);

			//transform.rotation = Quaternion.Slerp(GetComponent<Rigidbody>().rotation, rotation, Time.deltaTime * smooth);

			calcFingerCurl();

			//Yaw = Mathf.Rad2Deg * (Math.Atan ( magX/magY ));

			//if the accel data differs by 10000 or more between frames of good data

			/*
			Vector3 baselineG = new Vector3(accelRaw[1,0], accelRaw[1,1], accelRaw[1,2]);

			baselineG.Normalize();

			baselineG *= 14500;

			accelVectors[1] = accelVectors[1] - baselineG;

			// this should be accelVectors[0]
			calcVelocity(accelVectors[1]);
			*/
			if(Solfege.Evaluate(2, aRoll, aPitch, fingerCurl))
				doo = 1;
			else 
				doo = 0;

			if(Keyboard.Evaluate(aRoll, aPitch, fingerCurl))
				test = 1;
			else 
				test = 0;

			logData();
		}
		catch (System.Exception)
		{
			throw;
		}
	}

	void FixedUpdate()
	{
		Quaternion rotation = Quaternion.Euler(aRoll, aPitch, 0.0f);		
		GetComponent<Rigidbody>().MoveRotation(rotation);

		for(int i = 0; i < 4; i++)
			applyCurl(fingerCurl[0], i);
	}

	 private void parseAccel()
	{
		byte temp;
		byte[] bytes = new byte[2];

		do
		{
			temp = (byte)sp.ReadByte();
		} while (temp != 65);
		
		// gets rid of the second A character
		temp = (byte)sp.ReadByte();

		int frameSize = 7;
		int frameBreakCount = 0;
		for(int i = 0; i < frameSize ; i++)
		{
			if (i == 3)
			{
				// remove the midpoint flags
				temp = (byte)sp.ReadByte();
				if (temp != 65)
					break;
				frameBreakCount++;
				continue;
			}

			goodFlag = false;
			bytes[1] = (byte)sp.ReadByte();
			bytes[0] = (byte)sp.ReadByte();

			if((bytes[0] == 0) && (bytes[1] == 0))
				break;

			if(i == (frameSize - 1))
				goodFlag = true;
	
			t[i - frameBreakCount] =  System.BitConverter.ToInt16(bytes, 0);
		}
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

		
		float deltaFilter = 5000.0f;

		for(int i =0; i < IMUCount; i++)
			if(Mathf.Abs(magnitudePrev[i] - magnitude[i]) > deltaFilter)
				kinematicFlag = false;

		

		if(kinematicFlag)
		{
			for(int i = 0;  i < IMUCount; i++)
			{		
				magnitudePrev[i] = magnitude[i];

				for(int j = 0; j < 3; j++)
				{
					accelRawPrev[i,j] = accelRaw[i,j];
				}
			}
		}
		else
		{
			for(int i = 0;  i < IMUCount; i++)
			{		
				magnitude[i] = magnitudePrev[i];

				for(int j = 0; j < 3; j++)
				{
					accelRaw[i,j] = accelRawPrev[i,j];
				}
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
		Quaternion rotation = Quaternion.Euler(-aRoll, -aPitch,  0.0f);
		Matrix4x4 m = Matrix4x4.Rotate(rotation);

		Vector2 reference = new Vector2 (accelVectors[0].y, accelVectors[0].z);
		reference.Normalize();


		for (int i = 0; i < fingerCurl.Length; i++)
		{
			Vector3 finger = m.MultiplyVector(accelVectors[i+1]);

			Vector2 fingerVector = new Vector2 (accelVectors[1].y, accelVectors[1].z);
			fingerVector.Normalize();


			float fDot = Vector2.Dot(fingerVector, reference);
			fDot = Mathf.Clamp(fDot, -1.0f, 1.0f);
			
			float fAngle = Mathf.Acos(fDot);

			

			fingerCurl[i] = fAngle / Mathf.PI;
		}

	}

	private void logData()
	{
		//Write some text to the csv file
		StreamWriter writer = new StreamWriter("C:\\Users\\dgdan\\Desktop\\SeniorDesign\\MyWorkspace\\TestData.csv", true);
		//   writer.WriteLine(gyro[0].ToString() + ","  +  gyro[1].ToString() + "," + gyro[2].ToString());
		writer.WriteLine (
			aRoll.ToString() + "," + aPitch.ToString()
			+
			"," + ","+
			fingerCurl[0].ToString()
			+
			"," + ","+
			doo.ToString()
			+
			"," + ","+
			test.ToString()
			);
		writer.Close();
	}
}

class Keyboard
{
	private static float correctPitch  = 0.0f;
	private static float correctRoll   = 0.0f;
	private static float[] correctCurl = {0.5f, 0.5f, 0.5f, 0.5f};

	private static int fingerCount = 1;
	private static float pitchTolerance = 10.0f;
	private static float rollTolerance = 10.0f;
	private static float curlTolerance = 0.25f;

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

	private static int fingerCount = 1;
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
