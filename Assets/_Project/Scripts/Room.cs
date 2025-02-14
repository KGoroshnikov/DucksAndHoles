using System.Collections.Generic;
using UnityEngine;

public class Room : MonoBehaviour
{
    [SerializeField] private GameObject[] walls;
    public virtual void SetupRoom(List<MazeGenerator.RoomDoorInfo> roomDoorInfos){
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
            Debug.Log("i: " + i + " closest dist: " + closestDist + " mid: " + mid);
            Destroy(walls[closestID]);
        }
    }
}
