using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class RayMarchCamera : SceneViewFilter
{
    [SerializeField] Shader rayMarchIE;
    [SerializeField] Material rayMarchMat;
    [SerializeField] Camera mainCamera;

    [Header("RayMArching Setings")]
    [SerializeField] float maxDistance = 10;
    [SerializeField] Transform lightDirection;

    private void Start()
    {
        if (mainCamera == null)
        {
            mainCamera = GetComponent<Camera>();
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!rayMarchMat)
        {
            Graphics.Blit(source, destination);
            return;
        }

        rayMarchMat.SetMatrix("_CamFrustum", CamFrustum(mainCamera));
        rayMarchMat.SetMatrix("_CamToWorld", mainCamera.cameraToWorldMatrix);
        rayMarchMat.SetFloat("_maxDistance", maxDistance);
        rayMarchMat.SetVector("_LightDir", lightDirection.forward);

        RenderTexture.active = destination;
        rayMarchMat.SetTexture("_MainTex", source);
        GL.PushMatrix();
        GL.LoadOrtho();
        rayMarchMat.SetPass(0);
        GL.Begin(GL.QUADS);

        //bottom left
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);
        //bottom Right
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);
        //top right
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);
        //top left
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 3.0f);

        GL.End();
        GL.PopMatrix();
    }

    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        
        float fov = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);
        
        Vector3 goUp = Vector3.up * fov;
        Vector3 goRight = Vector3.right * fov * cam.aspect;

        Vector3 topLeft = (-Vector3.forward - goRight + goUp);
        Vector3 topRight = (-Vector3.forward + goRight + goUp);
        Vector3 bottomRight = (-Vector3.forward + goRight - goUp);
        Vector3 bottomLeft = (-Vector3.forward - goRight - goUp);

        frustum.SetRow(0, topLeft);
        frustum.SetRow(1, topRight);
        frustum.SetRow(2, bottomRight);
        frustum.SetRow(3, bottomLeft );

        return frustum;
    }
}
