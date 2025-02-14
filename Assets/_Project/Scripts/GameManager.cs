using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class GameManager : MonoBehaviour
{
    [Header("Base")]
    [SerializeField] private States gameStates;

    [Header("Init")]
    [SerializeField] private GameObject uiChoose;
    [SerializeField] private ARPlaneManager arPlaneManager;
    [SerializeField] private ChooseGameArea chooseGameArea;
    [SerializeField] private MapGenerator mapGenerator;

    public enum States{
        scanning, playing
    }
    
    public void RoomIsScanned(){
        uiChoose.SetActive(false);
        arPlaneManager.requestedDetectionMode = UnityEngine.XR.ARSubsystems.PlaneDetectionMode.None;
        mapGenerator.GenerateMap(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose());
    }
}
