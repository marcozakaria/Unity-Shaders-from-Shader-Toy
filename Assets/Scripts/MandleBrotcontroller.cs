using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MandleBrotcontroller : MonoBehaviour
{
    public Material mandleMAt;
    public float moveSpeed = 0.5f;

    public Vector4 mandlePos;
    Vector2 scale;

    private void Start()
    {
        scale.x = mandlePos.z;
        scale.y = mandlePos.w;
    }

    private void Update()
    {
        if (Input.GetKey(KeyCode.LeftArrow))
        {
            mandlePos.x += scale.x * moveSpeed;
            mandleMAt.SetVector("_Area", mandlePos);
        }
        if (Input.GetKey(KeyCode.RightArrow))
        {
            mandlePos.x -= scale.x * moveSpeed;
            mandleMAt.SetVector("_Area", mandlePos);
        }

        if (Input.GetKey(KeyCode.UpArrow))
        {
            mandlePos.y -= scale.x * moveSpeed;
            mandleMAt.SetVector("_Area", mandlePos);
        }
        if (Input.GetKey(KeyCode.DownArrow))
        {
            mandlePos.y += scale.x * moveSpeed;
            mandleMAt.SetVector("_Area", mandlePos);
        }

        if (Input.GetKey(KeyCode.Z))
        {
            scale *= 1.01f;
            mandlePos.z = scale.x;
            mandlePos.w = scale.y;
            mandleMAt.SetVector("_Area", mandlePos);
        }
        if (Input.GetKey(KeyCode.X))
        {
            scale *= 0.99f;
            mandlePos.z = scale.x;
            mandlePos.w = scale.y;
            mandleMAt.SetVector("_Area", mandlePos);
        }
    }
}
