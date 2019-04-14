using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class BackToStart : MonoBehaviour
{

    public GameObject backButton;

    // Use this for initialization
    void Start()
    {
		SceneManager.LoadScene(0);
		backButton.GetComponent<Button>().onClick.AddListener(GoBack);

    }

    // Update is called once per frame
    void Update()
    {

    }

    void GoBack()
    {
        SceneManager.LoadScene(0);
		print("wut");
    }


}