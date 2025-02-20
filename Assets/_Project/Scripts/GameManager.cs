using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class GameManager : MonoBehaviour
{
    [Header("LVLs")]
    [SerializeField] private LvlScriptableObject[] AllLvls;

    [Header("Base")]
    [SerializeField] private States gameStates;

    [Header("Init")]
    [SerializeField] private GameObject uiChoose;
    [SerializeField] private GameObject uiGame;
    [SerializeField] private ARPlaneManager arPlaneManager;
    [SerializeField] private ChooseGameArea chooseGameArea;
    //[SerializeField] private MapGenerator mapGenerator;
    [SerializeField] private MazeGenerator mazeGenerator;
    [SerializeField] private LvlChooser lvlChooser;

    public enum States{
        scanning, playing
    }
    
    public void RoomIsScanned(){
        bool mazeGenerated = mazeGenerator.GenerateMazeLevel(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose().transform);
        lvlChooser.Init(chooseGameArea.GetGoose().transform);
        if (!mazeGenerated) return;
        chooseGameArea.SetupGame();
        uiChoose.SetActive(false);
        uiGame.SetActive(true);
        arPlaneManager.requestedDetectionMode = UnityEngine.XR.ARSubsystems.PlaneDetectionMode.None;
    }

    public void GenerateLvl(int lvl){
        mazeGenerator.DestroyLevel();

        mazeGenerator.SetupLvlData(AllLvls[lvl]);

        bool mazeGenerated = mazeGenerator.GenerateMazeLevel(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose().transform);
    }
}
