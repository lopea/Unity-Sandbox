using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PointMovement : MonoBehaviour
{
    [SerializeField]
    GameObject obj;
    // Update is called once per frame
    void Update()
    {
        transform.LookAt(obj.transform);
        transform.Translate((transform.up * Mathf.Sin(Time.time) + transform.right * Mathf.Cos(Time.time)) * Time.deltaTime,Space.World);
    }
}
