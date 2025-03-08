using System.Collections.Generic;
using UnityEngine;

public class BreadRoom : Room
{
    [SerializeField] private GameObject exitPref;
    [SerializeField] private GameObject bread;
    [SerializeField] private int BreadToCollect;
    [SerializeField] private float distToTake;
    [SerializeField] private Animator animatorDoor;
    private Transform player;
    private int collected;
    private MazeGenerator mazeGenerator;
    private bool active;

    private List<Transform> breads = new List<Transform>();

    [SerializeField] private AudioSource collectBreadAudio;
    [SerializeField] private AudioSource doorOpenAudio;

    public override void SetupRoom(List<MazeGenerator.RoomDoorInfo> roomDoorInfos, MazeGenerator _mazeGenerator = null, List<Vector2Int> roomCells = null)
    {
        mazeGenerator = _mazeGenerator;

        for(int i = 0; i < roomDoorInfos.Count; i++){
            Vector3 mid = (roomDoorInfos[i].worldInside + roomDoorInfos[i].worldOutside) / 2;

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
        }
        active = true;
        player = mazeGenerator.getGoose();

        List<Vector2Int> freeTiles = mazeGenerator.GetTilesBeforeRoom(roomDoorInfos[1].insideCell);
        SpawnBread(freeTiles);

        mazeGenerator.GetGameManager().BreadLvl();
        mazeGenerator.GetGameManager().UpdateBread(collected, BreadToCollect);
    }

    void FixedUpdate()
    {
        if (!active) return;
        for(int i = 0; i < breads.Count; i++){
            if (breads[i].gameObject.activeSelf && Vector3.Distance(breads[i].position, player.position) <= distToTake){
                breads[i].gameObject.SetActive(false);
                collected++;
                collectBreadAudio.Play();
                mazeGenerator.GetGameManager().UpdateBread(collected, BreadToCollect);

                if (collected >= BreadToCollect){
                    animatorDoor.enabled = true;
                    doorOpenAudio.Play();
                    animatorDoor.Play("Open", 0, 0);
                    active = false;
                }
            }
        }
    }

    void SpawnBread(List<Vector2Int> freeTiles){
        for(int i = 0; i < BreadToCollect; i++){
            int rnd = Random.Range(1, freeTiles.Count);
            mazeGenerator.UpdateTile(freeTiles[rnd], false);
            GameObject breadObj = Instantiate(bread, mazeGenerator.GridToWorldPosition(freeTiles[rnd]) + new Vector3(0, Funcs.yOffset, 0), Quaternion.identity);
            freeTiles.RemoveAt(rnd);
            breads.Add(breadObj.transform);
            breadObj.transform.SetParent(transform);
        }
    }
}
