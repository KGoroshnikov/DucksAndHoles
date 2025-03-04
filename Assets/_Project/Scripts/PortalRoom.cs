using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PortalRoom : Room
{
    [SerializeField] private GameObject exitPref;
    [SerializeField] private GameObject portalPrefab;
    [SerializeField] private GameObject batteryPrefab;

    [SerializeField] private int amountPasses;
    private int currentPasses;

    [SerializeField] private Animator animatorDoor;
    [SerializeField] private Material batteryMat;
    [SerializeField] private Transform arrow;
    private bool doorOpened;

    private MazeGenerator mazeGenerator;

    public override void SetupRoom(List<MazeGenerator.RoomDoorInfo> roomDoorInfos, MazeGenerator _mazeGenerator = null, List<Vector2Int> roomCells = null)
    {
        mazeGenerator = _mazeGenerator;

        Vector3 posEnter = Vector3.zero;
        Vector3 posExit = Vector3.zero;
        List<GameObject> avaliableWalls = walls.ToList();
        for(int i = 0; i < roomDoorInfos.Count; i++){
            Vector3 mid = (roomDoorInfos[i].worldInside + roomDoorInfos[i].worldOutside) / 2;

            if (i == 0) posEnter = mid;
            else posExit = mid;

            float closestDist = float.MaxValue;
            int closestID = 0;
            for(int j = 0; j < walls.Length; j++){
                if (Vector3.Distance(walls[j].transform.position, mid) < closestDist){
                    closestDist = Vector3.Distance(walls[j].transform.position, mid);
                    closestID = j;
                }
            }
            if (i == 1){
                exitPref.SetActive(true);
                exitPref.transform.position = walls[closestID].transform.position;
                exitPref.transform.rotation = walls[closestID].transform.rotation;
            }

            walls[closestID].SetActive(false);
            avaliableWalls.RemoveAt(closestID);
        }

        GameObject portalWall1 = null;
        GameObject portalWall2 = null;
        for (int i = 0; i < avaliableWalls.Count; i++)
        {
            for (int j = 0; j < avaliableWalls.Count; j++)
            {
                if (i == j) continue;

                Vector3 d = avaliableWalls[j].transform.position - avaliableWalls[i].transform.position;

                Vector3 n1 = avaliableWalls[i].transform.forward;
                Vector3 n2 = avaliableWalls[j].transform.forward;

                bool horPair = d.x != 0 && d.z == 0 && Mathf.Abs(n1.x) >= 0.5f && Mathf.Abs(n2.x) >= 0.5f;
                bool verPair = d.x == 0 && d.z != 0 && Mathf.Abs(n1.z) >= 0.5f && Mathf.Abs(n2.z) >= 0.5f;

                Debug.Log("n1: " + n1 + " n2: " + n2 + " d:" + d + " " + horPair + " " + verPair);

                if (horPair || verPair)
                {
                    portalWall1 = avaliableWalls[i];
                    portalWall2 = avaliableWalls[j];
                    break;
                }
            }
            if (portalWall1 != null) break;
        }
        if (portalWall1 != null && portalWall1 != null)
        {
            GameObject portal1 = Instantiate(portalPrefab, portalWall1.transform.position, portalWall1.transform.rotation, transform);
            GameObject portal2 = Instantiate(portalPrefab, portalWall2.transform.position, portalWall2.transform.rotation, transform);
            portal1.transform.forward = -(portal2.transform.position - portal1.transform.position);
            portal2.transform.forward = -(portal1.transform.position - portal2.transform.position);
            PortalHole portalHole1 = portal1.GetComponent<PortalHole>();
            PortalHole portalHole2 = portal2.GetComponent<PortalHole>();
            portalHole1.SetLinkedPos(portalHole2.GetPos(), this);
            portalHole2.SetLinkedPos(portalHole1.GetPos(), this);
        }
        else{
            Debug.LogError("ERROR: cant generate portals :( Please Restart The Lvl");
            return;
        }

        List<Vector2Int> availableCells = new List<Vector2Int>();
        foreach (Vector2Int cell in roomCells)
        {
            Vector3 worldPos = mazeGenerator.GridToWorldPosition(cell);
            if (Vector3.Distance(worldPos, roomDoorInfos[0].worldInside) < 0.05f ||
                Vector3.Distance(worldPos, roomDoorInfos[1].worldInside) < 0.05f)
                continue;
            float distToLine = DistancePointToLine(worldPos, portalWall1.transform.position, portalWall2.transform.position);
            if (distToLine < 0.05f)
                continue;
            availableCells.Add(cell);
        }
        if (availableCells.Count > 0)
        {
            Vector2Int batteryCell = availableCells[Random.Range(0, availableCells.Count)];
            Vector3 batteryPos = mazeGenerator.GridToWorldPosition(batteryCell);
            //GameObject battery = Instantiate(batteryPrefab, batteryPos, Quaternion.identity, transform);
            batteryPrefab.SetActive(true);
            batteryPrefab.transform.position = batteryPos;
            batteryPrefab.transform.right = exitPref.transform.position - batteryPrefab.transform.position;
        }
        else
        {
            Debug.LogError("ERROR: cant generate battery :( Please Restart The Lvl");
        }
    }

    public void AddPass(){
        if (doorOpened) return;
        currentPasses++;

        float t = (float)currentPasses / amountPasses;
        if (t >= 1){
            t = 1;
            animatorDoor.enabled = true;
            animatorDoor.Play("Open", 0, 0);
        }
        arrow.transform.localEulerAngles = new Vector3(Mathf.Lerp(-90, 270, t), 0, 0);
        batteryMat.SetFloat( "_Arc1", Mathf.Lerp(360, 0, t));
    }

    void OnDisable()
    {
        batteryMat.SetFloat( "_Arc1", 360f);
    }

    float DistancePointToLine(Vector3 point, Vector3 lineStart, Vector3 lineEnd)
    {
        Vector3 lineDir = lineEnd - lineStart;
        float t = Vector3.Dot(point - lineStart, lineDir) / lineDir.sqrMagnitude;
        Vector3 projection = lineStart + t * lineDir;
        return Vector3.Distance(point, projection);
    }
}
