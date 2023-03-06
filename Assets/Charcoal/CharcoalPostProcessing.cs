using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CharcoalPostProcessing : MonoBehaviour
{
    Camera myCam;
    public Camera charcoalCamera;
    RenderTexture charcoalTex;
    [Range(0,5)]
    public float paperStrength;
    Material blitMat;
    public Texture normalMap;

    public Transform charcoalSphere;
    float lastJitter;
    public float jitterRate;

    //[ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (charcoalTex == null || charcoalTex.width != source.width || charcoalTex.height != source.height)
            charcoalTex = new RenderTexture(source);

        SetProjectionMatrix();

        if (blitMat == null)
            blitMat = new Material(Shader.Find("Hidden/CharcoalImageEffect"));

        if (Time.time > lastJitter + jitterRate && charcoalSphere!=null)
        {
            lastJitter = Time.time;
            charcoalSphere.eulerAngles = new Vector3(Random.Range(-66f, 66f), Random.Range(-90f, 90f), 0);
            blitMat.SetTextureOffset("_PaperTex", new Vector2(Random.Range(0f, 1f), Random.Range(0f, 1f)));
        }

        charcoalCamera.transform.rotation = transform.rotation;
        charcoalCamera.targetTexture = charcoalTex;
        charcoalCamera.Render();

        blitMat.SetTexture("_CharcoalTex", charcoalTex);
        if (normalMap != null)
            blitMat.SetTexture("_PaperTex", normalMap);
        blitMat.SetFloat("_Strength", paperStrength);
        Graphics.Blit(source, destination, blitMat);
    }

    private void SetProjectionMatrix()
    {
        if (myCam == null)
            myCam = GetComponent<Camera>();

        // get GPU projection matrix
        Matrix4x4 projMatrix = GL.GetGPUProjectionMatrix(myCam.projectionMatrix, false);

        // get GPU view projection matrix
        Matrix4x4 viewProjMatrix = projMatrix * myCam.worldToCameraMatrix;
        Shader.SetGlobalMatrix("_ViewProjection", viewProjMatrix);

        // get inverse VP matrix
        Matrix4x4 inverseViewProjMatrix = viewProjMatrix.inverse;

        Shader.SetGlobalMatrix("_InverseViewProjection", inverseViewProjMatrix);
    }
}
