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
    [SerializeField] private GameObject arrowPrefab;
    private GameObject spawnedGoose;
    private GameObject spawnedArrow;
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
        for(int i = 0; i < 4; i++) planeMat.SetVector("_P" + (i + 1), Vector2.zero);
    }
    void OnDisable(){
        planeMat.SetFloat("_MaskRadius", 0);
        for(int i = 0; i < 4; i++) planeMat.SetVector("_P" + (i + 1), Vector2.zero);
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
            spawnedArrow.transform.position = newPosition + new Vector3(0, 0.05f, 0);
            planeMat.SetVector("_GoosePos", newPosition);
        }
    }

    void Update(){
        if (isActive) return;
        tMask += Time.deltaTime / timeMask;
        if (tMask <=1)
            planeMat.SetFloat("_MaskRadius", math.lerp(0, 5, tMask));
    }

    void OnPlanesChanged(ARTrackablesChangedEventArgs<ARPlane> changes)
    {
        if (spawnedGoose != null || arPlaneManager.trackables.count <= 0) return;
        foreach (var plane in changes.added)
        {
            currentPlane = plane;
            Vector3 spawnPosition = plane.transform.position;
            spawnedGoose = Instantiate(goosePrefab, spawnPosition, Quaternion.identity);
            spawnedArrow = Instantiate(arrowPrefab, spawnPosition + new Vector3(0, 0.05f, 0), Quaternion.identity);
            planeMat.SetVector("_GoosePos", spawnPosition);
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
        Destroy(spawnedArrow);
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
        PlayerController playerController = spawnedGoose.GetComponent<PlayerController>();
        playerController.ResetPlayer();
        playerController.ActivateGoose(currentPlane.transform.position.y);

    }
}
