using System.Collections.Generic;
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

    [SerializeField] private InputActionReference tapInput, tapStartPos;

    void Awake()
    {
        arPlaneManager.trackablesChanged.AddListener(OnPlanesChanged);
    }

    void OnPlanesChanged(ARTrackablesChangedEventArgs<ARPlane> changes)
    {
        if (spawnedGoose != null || arPlaneManager.trackables.count <= 0) return;
        foreach (var plane in changes.added)
        {
            currentPlane = plane;
            Vector3 spawnPosition = plane.transform.position;
            spawnPosition.y += 0.05f;
            spawnedGoose = Instantiate(goosePrefab, spawnPosition, Quaternion.identity);
            break;
        }
    }

    public ARPlane GetARPlane(){
        isActive = false;
        return currentPlane;
    }

    void Update()
    {
        if (!isActive || spawnedGoose == null || !tapInput.action.triggered) return;
        if (tapInput.action.triggered)
        {
            if (arRaycastManager.Raycast(tapStartPos.action.ReadValue<Vector2>(), hits, TrackableType.PlaneWithinPolygon))
            {
                currentPlane = hits[0].trackable as ARPlane;
                Pose hitPose = hits[0].pose;
                Vector3 newPosition = hitPose.position;
                newPosition.y += 0.05f;
                spawnedGoose.transform.position = newPosition;
            }
        }
    }
}
