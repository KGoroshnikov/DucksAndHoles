using System.Collections.Generic;
using UnityEngine;

public class ButtonsRoom : Room
{
    [SerializeField] private GameObject exitPref;
    [SerializeField] private GameObject[] buttons;
    [SerializeField] private GameObject[] boxes;

    [SerializeField] private Animator animatorDoor;
    [SerializeField] private AudioSource doorAudio;

    private MazeGenerator mazeGenerator;

    private bool doorOpened;

    private int needActived = 2;
    private int currentActived;

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

        List<Vector2Int> availableCells = new List<Vector2Int>();
        foreach (Vector2Int cell in roomCells)
        {
            Vector3 worldPos = mazeGenerator.GridToWorldPosition(cell);
            if (Vector3.Distance(worldPos, roomDoorInfos[0].worldInside) < 0.05f ||
                Vector3.Distance(worldPos, roomDoorInfos[1].worldInside) < 0.05f)
                continue;
            availableCells.Add(cell);
        }
        if (availableCells.Count >= 2)
        {
            for(int i = 0; i < buttons.Length; i++){
                Vector2Int chosenTile = availableCells[Random.Range(0, availableCells.Count)];
                availableCells.Remove(chosenTile);
                _mazeGenerator.UpdateTile(chosenTile, false);
                Vector3 pos = mazeGenerator.GridToWorldPosition(chosenTile);
                buttons[i].transform.position = new Vector3(pos.x, buttons[i].transform.position.y, pos.z);
            }
        }
        else
        {
            Debug.LogError("ERROR: cant generate buttons :( Please Restart The Lvl");
        }

        availableCells = _mazeGenerator.GetTilesBeforeRoom(roomDoorInfos[1].insideCell);
        Debug.Log("Tiles before room: " + availableCells.Count + " roomDoorInfos[1].insideCell: " + roomDoorInfos[1].insideCell);
        for(int i = 0; i < boxes.Length; i++){
            Vector2Int tile = availableCells[Random.Range(0, availableCells.Count)];
            availableCells.Remove(tile);
            boxes[i].transform.position = mazeGenerator.GridToWorldPosition(tile);
        }

    }

    public void ButtonPressed(){
        if (doorOpened) return;
        currentActived++;
        if (currentActived >= needActived){
            animatorDoor.enabled = true;
            doorOpened = true;
            doorAudio.Play();
            animatorDoor.SetTrigger("Open");
        }
    }

    public void ButtonReleased(){
        currentActived--;
        if (currentActived < 0) currentActived = 0;
        if (currentActived < needActived && doorOpened){
            doorOpened = false;
            animatorDoor.SetTrigger("Close");
        }
    }
}
