using System.Collections.Generic;
using UnityEngine;

public class SlimeHoleRoom : Room
{
    [SerializeField] private Animator animatorDoor;
    [SerializeField] private AudioSource slimeAudio;
    [SerializeField] private AudioSource doorAudio;
    [SerializeField] private AudioClip[] slimeClips;
    [SerializeField] private ParticleSystem puff;
    [SerializeField] private GameObject exitPref;
    [SerializeField] private Transform slimeTransform;
    [SerializeField] private Transform slimeHoleTransform;
    [SerializeField] private GameObject key;
    [SerializeField] private float wallOffset;
    [SerializeField] private Animator slimeAnim;
    [SerializeField] private Vector2 stayTime;
    [SerializeField] private Vector2 hiddenTime;
    private Transform player;
    private MazeGenerator mazeGenerator;
    private bool canHit;
    private bool keyActive;

    private Vector2 boundsX;
    private Vector2 boundsZ;

    public override void SetupRoom(List<MazeGenerator.RoomDoorInfo> roomDoorInfos, MazeGenerator _mazeGenerator = null, List<Vector2Int> roomCells = null)
    {
        boundsX = new Vector2(float.MaxValue, float.MinValue);
        boundsZ = new Vector2(float.MaxValue, float.MinValue);
        for(int i = 0; i < walls.Length; i++){
            if (walls[i].transform.position.x < boundsX.x) boundsX.x = walls[i].transform.position.x;
            else if (walls[i].transform.position.x > boundsX.y) boundsX.y = walls[i].transform.position.x;

            if (walls[i].transform.position.z < boundsZ.x) boundsZ.x = walls[i].transform.position.z;
            else if (walls[i].transform.position.z > boundsZ.y) boundsZ.y = walls[i].transform.position.z;
        }

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
        boundsX = new Vector2(boundsX.x + wallOffset, boundsX.y - wallOffset);
        boundsZ = new Vector2(boundsZ.x + wallOffset, boundsZ.y - wallOffset);
        player = mazeGenerator.getGoose();
        Invoke("ShowSlime", Random.Range(hiddenTime.x, hiddenTime.y));
    }

    void FixedUpdate()
    {
        if (!keyActive) return;
        if (Vector3.Distance(key.transform.position, player.position) <= 0.03f){
            key.SetActive(false);
            keyActive = false;
            puff.Play();
            doorAudio.Play();
            animatorDoor.enabled = true;
            animatorDoor.Play("Open", 0, 0);
        }
    }

    void ShowSlime(){
        slimeTransform.forward = -slimeTransform.position + 
            new Vector3(Camera.main.transform.position.x, slimeTransform.position.y, Camera.main.transform.position.z);
        slimeHoleTransform.position = new Vector3(Random.Range(boundsX.x, boundsX.y), 
                slimeHoleTransform.position.y, Random.Range(boundsZ.x, boundsZ.y));
        slimeAnim.enabled = true;
        slimeAudio.clip = slimeClips[0];
        slimeAudio.Play();
        slimeAnim.SetTrigger("Appear");
        canHit = true;
        Invoke("HideSlime", Random.Range(stayTime.x, stayTime.y));
    }

    public void SlimeTapped(){
        if (!canHit) return;
        canHit = false;
        slimeAudio.clip = slimeClips[1];
        slimeAudio.Play();
        CancelInvoke();
        slimeAnim.SetTrigger("Hide");
        key.transform.position = slimeHoleTransform.position;
        key.SetActive(true);
        keyActive = true;
    }

    void HideSlime(){
        slimeAnim.SetTrigger("Hide");
        canHit = false;
        Invoke("ShowSlime", Random.Range(hiddenTime.x, hiddenTime.y));
    }
}
