using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class FogOfWarManager : MonoBehaviour
{
    private Transform goose;
    //[SerializeField] private VisualEffect particles; not working on mobile :(
    [SerializeField] private GameObject mainFog;
    [SerializeField] private Camera particlesCam;
    [SerializeField] private Material fogMat;
    //[SerializeField] private float density;

    private float scaleParticlePlane = 0.045f; // 0.25 / 6
    private float scaleFogPlane = 0.0166f; // 0.1 / 6
    private float sizeCamParticles = 0.0833f; // 0.5f / 6

    private bool working;

    public void HideFog(){
        mainFog.SetActive(false);
    }

    void OnDisable()
    {
        for(int i = 0; i < 4; i++){
            fogMat.SetVector("_P" + (i + 1), Vector2.zero);
        }
    }

    public void SetupFog(Transform _goose, Vector3 center, Vector2 size, List<Vector2> points){
        mainFog.SetActive(true);
        goose = _goose;
        
        mainFog.transform.position = center;

        //mainFog.transform.localScale = new Vector3(scaleFogPlane * size.x, 1, scaleFogPlane * size.y);
        mainFog.transform.localScale = Vector3.one * MathF.Max(size.x, size.y) * scaleFogPlane;
        particlesCam.transform.position = new Vector3(particlesCam.transform.position.x, center.y + 1f, particlesCam.transform.position.z);

        particlesCam.orthographicSize = sizeCamParticles * Mathf.Max(size.x, size.y);

        List<Vector2> sortedPoints = Funcs.SortPointsCounterClockwiseXZ(points);
        for(int i = 0; i < 4; i++){
            fogMat.SetVector("_P" + (i + 1), sortedPoints[i]);
        }

        working = true;
        //particles.Play();
    }

    /*void Update()
    {
        if (!working) return;
        particles.SetVector3("GoosePos", goose.position);
    }*/
}
