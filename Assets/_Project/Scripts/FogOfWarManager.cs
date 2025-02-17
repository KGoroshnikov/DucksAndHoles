using UnityEngine;
using UnityEngine.VFX;

public class FogOfWarManager : MonoBehaviour
{
    private Transform goose;
    //[SerializeField] private VisualEffect particles; not working on mobile :(
    [SerializeField] private GameObject mainFog;
    [SerializeField] private Camera particlesCam;
    [SerializeField] private float density;

    private float scaleParticlePlane = 0.045f; // 0.25 / 6
    private float scaleFogPlane = 0.0166f; // 0.1 / 6
    private float sizeCamParticles = 0.0833f; // 0.5f / 6

    private bool working;

    public void SetupFog(Transform _goose, Vector3 center, Vector2 size){
        goose = _goose;
        
        //particles.transform.position = center;
        mainFog.transform.position = center;

        Vector2 sizeParticle = new Vector2(size.x * scaleParticlePlane, size.y * scaleParticlePlane);
        //particles.SetVector2("PlaneSize", sizeParticle);
        //particles.SetInt("SpawnAmount", (int)(density * ((sizeParticle.x + sizeParticle.y)/2)));

        mainFog.transform.localScale = new Vector3(scaleFogPlane * size.x, 1, scaleFogPlane * size.y);
        particlesCam.transform.position = new Vector3(particlesCam.transform.position.x, center.y + 1f, particlesCam.transform.position.z);

        particlesCam.orthographicSize = sizeCamParticles * Mathf.Max(size.x, size.y);

        working = true;
        //particles.Play();
    }

    /*void Update()
    {
        if (!working) return;
        particles.SetVector3("GoosePos", goose.position);
    }*/
}
