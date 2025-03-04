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
        //planeMat.SetFloat("_GameStage", 0);
        //planeMat.SetFloat("_SmoothDist", 4.5f);
        //planeMat.SetVector("_GoosePos", Vector3.zero);
        for(int i = 0; i < 4; i++) planeMat.SetVector("_P" + (i + 1), Vector2.zero);
        //phoneInputData.OnStartTouch += Tapped;
    }
    void OnDisable(){
        planeMat.SetFloat("_MaskRadius", 0);
        //planeMat.SetFloat("_GameStage", 0);
        //planeMat.SetFloat("_SmoothDist", 4.5f);
        //planeMat.SetVector("_GoosePos", Vector3.zero);
        for(int i = 0; i < 4; i++) planeMat.SetVector("_P" + (i + 1), Vector2.zero);
        //phoneInputData.OnStartTouch -= Tapped;
    }

    public void SetGameGround(List<Vector2> points){
        List<Vector2> sortedPoints = Funcs.SortPointsCounterClockwiseXZ(points);
        for(int i = 0; i < 4; i++){
            planeMat.SetVector("_P" + (i + 1), sortedPoints[i]);
        }
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
        if (tMask <=1) //planeMat.SetFloat("_SmoothDist", math.lerp(4.5f, 0.2f, tMask));
            planeMat.SetFloat("_MaskRadius", math.lerp(0, 5, tMask));
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
            //planeMat.SetFloat("_SmoothDist", 4.5f);
            //planeMat.SetFloat("_MaskRadius", 0.05f);
            break;
        }
    }

    public GameObject GetGoose(){
        return spawnedGoose;
    }

    public ARPlane GetARPlane(){
        return currentPlane;
    }

    public void SetActive(){
        isActive = true;
    }

    public void RemoveARPlanes(){
        isActive = false;
        MeshFilter meshFilter = currentPlane.GetComponent<MeshFilter>();
        foreach (ARPlane plane in arPlaneManager.trackables)
        {
            if (plane == currentPlane) continue;
            Destroy(plane.gameObject);
        }
        currentPlane.GetComponent<LineRenderer>().positionCount = 0;
    }

    public void SetupGame(){
        
        //planeMat.SetFloat("_GameStage", 1);
        PlayerController playerController = spawnedGoose.GetComponent<PlayerController>();
        playerController.ResetPlayer();
        playerController.ActivateGoose(currentPlane.transform.position.y);

    }
}
