using TMPro;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class GameManager : MonoBehaviour
{
    [Header("LVLs")]
    [SerializeField] private LvlScriptableObject lvlPath;
    [SerializeField] private LvlScriptableObject[] AllLvls;

    [Header("Base")]
    [SerializeField] private States gameStates;

    [Header("Init")]
    [SerializeField] private GameObject breadUI;
    [SerializeField] private TMP_Text breadText;
    [SerializeField] private GameObject uiChoose;
    [SerializeField] private GameObject uiGame;
    [SerializeField] private ARPlaneManager arPlaneManager;
    [SerializeField] private ChooseGameArea chooseGameArea;
    //[SerializeField] private MapGenerator mapGenerator;
    [SerializeField] private MazeGenerator mazeGenerator;
    [SerializeField] private LvlChooser lvlChooser;
    [SerializeField] private Color redColor;
    [SerializeField] private Color greenColor;
    [SerializeField] private HealthManager healthManager;

    private Vector3 playerStartLvlPos;

    private int currentLvl;

    public enum States{
        scanning, playing
    }
    
    public void RoomIsScanned(){
        mazeGenerator.SetupLvlData(lvlPath);
        bool mazeGenerated = mazeGenerator.GenerateMazeLevel(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose().transform);
        lvlChooser.Init(chooseGameArea.GetGoose().transform);
        if (!mazeGenerated) return;
        //chooseGameArea.SetupGame();
        playerStartLvlPos = chooseGameArea.GetGoose().transform.position;
        chooseGameArea.RemoveARPlanes();
        uiChoose.SetActive(false);
        uiGame.SetActive(true);
        arPlaneManager.requestedDetectionMode = UnityEngine.XR.ARSubsystems.PlaneDetectionMode.None;
        healthManager.Init(chooseGameArea.GetGoose().GetComponent<PlayerController>());
    }

    public void LvlPassed(){
        if (currentLvl > PlayerPrefs.GetInt("LvlsCompleted", 0))
            PlayerPrefs.SetInt("LvlsCompleted", currentLvl);
        Restart();
    }
    void Restart(){
        chooseGameArea.GetGoose().SetActive(true);
        breadUI.SetActive(false);
        mazeGenerator.DestroyLevel();
        mazeGenerator.SetupLvlData(lvlPath);
        chooseGameArea.GetGoose().transform.position = playerStartLvlPos;
        chooseGameArea.GetGoose().transform.rotation = Quaternion.Euler(0, 0, 0);
        bool mazeGenerated = mazeGenerator.GenerateMazeLevel(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose().transform);
        if (!mazeGenerated) AskToScanAgain();
        lvlChooser.Init(chooseGameArea.GetGoose().transform);
        healthManager.Init(chooseGameArea.GetGoose().GetComponent<PlayerController>());
    }
    public void LvlFailed(){
        Restart();
    }

    void AskToScanAgain(){
        uiChoose.SetActive(true);
        uiGame.SetActive(false);
        chooseGameArea.SetActive();
        arPlaneManager.requestedDetectionMode = UnityEngine.XR.ARSubsystems.PlaneDetectionMode.Horizontal;
    }

    public void GenerateLvl(int lvl){
        currentLvl = lvl + 1;
        mazeGenerator.DestroyLevel();

        mazeGenerator.SetupLvlData(AllLvls[lvl]);

        bool mazeGenerated = mazeGenerator.GenerateMazeLevel(chooseGameArea.GetARPlane(), chooseGameArea.GetGoose().transform);

        if (!mazeGenerated) AskToScanAgain();

        chooseGameArea.SetupGame();
    }

    public void BreadLvl(){
        breadUI.SetActive(true);
    }
    public void UpdateBread(int amount, int maxamount){
        breadText.text = amount + " / " + maxamount;
        if (amount >= maxamount) breadText.color = greenColor;
        else breadText.color = redColor;
    }
}
