using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class GameManager : MonoBehaviour
{
    [Header("Base")]
    [SerializeField] private States gameStates;

    [Header("Init")]
    [SerializeField] private GameObject uiChoose;
    [SerializeField] private GameObject uiGame;
    [SerializeField] private ARPlaneManager arPlaneManager;
    [SerializeField] private ChooseGameArea chooseGameArea;
    //[SerializeField] private MapGenerator mapGenerator;
    [SerializeField] private MazeGenerator mazeGenerator;

    public enum States{
        scanning, playing
    }
    
    public void RoomIsScanned(){
        //mapGenerator.GenerateMap(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose());
        bool mazeGenerated = mazeGenerator.GenerateMazeLevel(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose().transform);
        if (!mazeGenerated) return;
        chooseGameArea.SetupGame();
        uiChoose.SetActive(false);
        uiGame.SetActive(true);
        arPlaneManager.requestedDetectionMode = UnityEngine.XR.ARSubsystems.PlaneDetectionMode.None;
    }
}
