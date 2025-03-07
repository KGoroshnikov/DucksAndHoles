using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class LvlPathGenerator : Room
{
    private Transform goose;
    
    [SerializeField] private int amountLvls;
    [SerializeField] private int lvlsPerRow = 5;
    [SerializeField] private GameObject holePref;
    [SerializeField] private Vector2 randDist;
    [SerializeField] private Vector2 randY;
    [SerializeField] private float rowInterval;

    [SerializeField] private LineRenderer lineRenderer;

    [SerializeField] private Material yellowHoleMat;
    [SerializeField] private Color yellowColor;

    public class HoleLvl{
        public GameObject obj;
        public LvlHole lvlHole;
        public GameObject lockObj;
        public Renderer renderer;
        public TMP_Text tMP_Text;
        public bool unlocked;
        public bool passed;
    }
    private List<HoleLvl> spawnedHoles = new List<HoleLvl>();

    private MazeGenerator mazeGenerator;
    private MoveObjects moveObjects;
    private List<Vector3> pathPoints;
    private List<Vector3> holePoses = new List<Vector3>();
    private Vector3 startPoint;
    private Vector3 endPoint;

    public override void SetupRoom(List<MazeGenerator.RoomDoorInfo> roomDoorInfos, MazeGenerator _mazeGenerator, List<Vector2Int> roomCells = null)
    {
        mazeGenerator = _mazeGenerator;
        moveObjects = GameObject.Find("MoveObjects").GetComponent<MoveObjects>();
        GeneratePath(mazeGenerator.getGoose());
    }

    private bool GeneratePath(Transform _goose) {
        goose = _goose;

        pathPoints = mazeGenerator.GetPosForLvlPath();
        float firstDist = Vector3.Distance(goose.position, pathPoints[0]);
        float secondDist = Vector3.Distance(goose.position, pathPoints[1]);
        startPoint = (firstDist <= secondDist) ? pathPoints[0] : pathPoints[1];
        endPoint = (startPoint == pathPoints[0]) ? pathPoints[1] : pathPoints[0];

        //moveObjects.AddObjToMove(goose, 0.2f, startPoint, goose.rotation);

        Vector3 mainDir = (new Vector3(endPoint.x, endPoint.y, startPoint.z) - startPoint).normalized;
        Vector3 rightDir = Vector3.Cross(mainDir, Vector3.up);

        int rowCount = Mathf.CeilToInt((float)amountLvls / lvlsPerRow);
        int levelIndex = 0;
        Vector3 currentStart = startPoint;

        for (int row = 0; row < rowCount; row++) {
            Vector3 rowDir = (row % 2 == 0) ? mainDir : -mainDir;
    
            Vector3 currentPos = currentStart;
            for (int col = 0; col < lvlsPerRow && levelIndex < amountLvls; col++) {
                if (col > 0) {
                    float distanceStep = Random.Range(randDist.x, randDist.y);
                    currentPos += rowDir * distanceStep;
                }
                Vector3 pos = currentPos;
                pos.y = goose.position.y + Funcs.yOffset;
                pos += rightDir * Random.Range(randY.x, randY.y);
                holePoses.Add(pos);
                pos.y += Funcs.yOffset / 2;

                GameObject newHole = Instantiate(holePref, pos, Quaternion.Euler(90, 0, 0));
                newHole.transform.SetParent(transform);
    
                HoleLvl holeLvl = new HoleLvl();
                holeLvl.obj = newHole;
                holeLvl.lvlHole = newHole.GetComponent<LvlHole>();
                holeLvl.lvlHole.SetID(levelIndex);
                holeLvl.lockObj = newHole.transform.Find("LockedObj").gameObject;
                holeLvl.renderer = newHole.GetComponent<Renderer>();
                holeLvl.tMP_Text = newHole.transform.Find("Text").GetComponent<TMP_Text>();
                spawnedHoles.Add(holeLvl);
    
                levelIndex++;
            }
            currentStart = currentPos - rightDir * rowInterval;
        }
        lineRenderer.positionCount = holePoses.Count;
        lineRenderer.SetPositions(holePoses.ToArray());

        int holeId = PlayerPrefs.GetInt("LvlsCompleted", 0) == 0 ? 0 : PlayerPrefs.GetInt("LvlsCompleted", 0) - 1;
        moveObjects.AddObjToMove(goose, 0.2f, spawnedHoles[holeId].obj.transform.position, goose.rotation);

        LoadProgress();
        FinishHoles();

        return true;
    }

    void LoadProgress(){
        int progress = PlayerPrefs.GetInt("LvlsCompleted", 0);

        for(int i = 0; i < progress; i++){
            spawnedHoles[i].unlocked = true;
            spawnedHoles[i].passed = true;
        }
        if (progress >= spawnedHoles.Count) return;
        spawnedHoles[progress].unlocked = true;
    }

    void Update()
    {
        if (spawnedHoles.Count <= 0) return;

        for(int i = 0; i < spawnedHoles.Count; i++){
            spawnedHoles[i].tMP_Text.transform.forward = -Camera.main.transform.position + spawnedHoles[i].tMP_Text.transform.position;
            spawnedHoles[i].lockObj.transform.GetChild(0).forward = Camera.main.transform.position - spawnedHoles[i].lockObj.transform.position;
        }
    }

    void FinishHoles(){
        for(int i = 0; i < spawnedHoles.Count; i++){
            spawnedHoles[i].tMP_Text.text = "" + (i + 1);
            if (spawnedHoles[i].unlocked){
                spawnedHoles[i].tMP_Text.gameObject.SetActive(true);
                spawnedHoles[i].lockObj.SetActive(false);
            }
            if (spawnedHoles[i].passed){
                spawnedHoles[i].tMP_Text.color = yellowColor;
                spawnedHoles[i].renderer.material = yellowHoleMat;
            }
        }
    }

}
