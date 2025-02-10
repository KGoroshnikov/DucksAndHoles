using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class ChooseGameArea : MonoBehaviour
{
    [SerializeField] private ARPlaneManager arPlaneManager;
    [SerializeField] private ARRaycastManager arRaycastManager;
    [SerializeField] private GameObject goosePrefab;
    private GameObject spawnedGoose;
    private ARPlane currentPlane;
    private bool isActive = true;

    private List<ARRaycastHit> hits = new List<ARRaycastHit>();

    [SerializeField] private PhoneInputData phoneInputData;

    [SerializeField] private Material planeMat;
    [SerializeField] private float timeMask;
    private float tMask;

    void Awake()
    {
        arPlaneManager.trackablesChanged.AddListener(OnPlanesChanged);
    }

    void OnEnable(){
        planeMat.SetFloat("_MaskRadius", 0);
        planeMat.SetVector("_GoosePos", Vector3.zero);
        //phoneInputData.OnStartTouch += Tapped;
    }
     void OnDisable(){
        planeMat.SetFloat("_MaskRadius", 0);
        planeMat.SetVector("_GoosePos", Vector3.zero);
        //phoneInputData.OnStartTouch -= Tapped;
    }
    public void Tapped()
    {
        if (!isActive || spawnedGoose == null) return;
        if (arRaycastManager.Raycast(phoneInputData.GetTapPos(), hits, TrackableType.PlaneWithinPolygon))
        {
            currentPlane = hits[0].trackable as ARPlane;
            Pose hitPose = hits[0].pose;
            Vector3 newPosition = hitPose.position;
            //newPosition.y += 0.05f;
            spawnedGoose.transform.position = newPosition;
            planeMat.SetVector("_GoosePos", newPosition);
        }
    }

    void Update(){
        if (isActive) return;
        tMask += Time.deltaTime / timeMask;
        if (tMask <=1)
            planeMat.SetFloat("_MaskRadius", math.lerp(0.05f, 10, tMask));
    }

    void OnPlanesChanged(ARTrackablesChangedEventArgs<ARPlane> changes)
    {
        if (spawnedGoose != null || arPlaneManager.trackables.count <= 0) return;
        foreach (var plane in changes.added)
        {
            currentPlane = plane;
            Vector3 spawnPosition = plane.transform.position;
            //spawnPosition.y += 0.05f;
            spawnedGoose = Instantiate(goosePrefab, spawnPosition, Quaternion.identity);
            planeMat.SetVector("_GoosePos", spawnPosition);
            planeMat.SetFloat("_MaskRadius", 0.05f);
            break;
        }
    }

    public ARPlane GetARPlane(){
        isActive = false;

        MeshFilter meshFilter = currentPlane.GetComponent<MeshFilter>();
        Mesh planeMesh = meshFilter.mesh;
        foreach (ARPlane plane in arPlaneManager.trackables)
        {
            if (plane == currentPlane) continue;
            Destroy(plane.gameObject);
        }

        return currentPlane;
    }
}
