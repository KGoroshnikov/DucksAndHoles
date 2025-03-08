using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class StaticHole : Room
{
    [SerializeField] private Transform rock;
    [SerializeField] private MovableObject rockMovable;
    [SerializeField] private Transform finalRockPos;

    [SerializeField] private float timeMove;
    [SerializeField] private float distSuck;
    [SerializeField] private float rockSuck;
    private Transform gooseObj;
    private PlayerController playerController;
    private GameManager gameManager;
    private MoveObjects moveObjects;
    [SerializeField] private state m_state;
    public enum state{
        idle, sucked, closed
    }

    [SerializeField] private AudioSource audioDrop;


    public override void SetupRoom(List<MazeGenerator.RoomDoorInfo> roomDoorInfos, MazeGenerator _mazeGenerator = null, List<Vector2Int> roomCells = null){
        base.SetupRoom(roomDoorInfos, _mazeGenerator, roomCells);
        List<Vector2Int> possibleTiles = _mazeGenerator.GetTilesBeforeRoom(roomDoorInfos[1].insideCell);
        Vector2Int randTile = possibleTiles[Random.Range(0, possibleTiles.Count)];
        rock.gameObject.SetActive(true);
        rock.position = _mazeGenerator.GridToWorldPosition(randTile) + Vector3.up * Funcs.yOffset * 3;
        _mazeGenerator.UpdateTile(randTile, false);
        transform.position = new Vector3(transform.position.x, transform.position.y + Funcs.yOffset, transform.position.z);
        _mazeGenerator.GetGameManager().GetTipManager().SetupLvl6(rock, _mazeGenerator.getGoose());
    }

    void Start()
    {
        gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
        gooseObj = GameObject.FindWithTag("Player").transform;
        playerController = gooseObj.GetComponent<PlayerController>();
        moveObjects = GameObject.Find("MoveObjects").GetComponent<MoveObjects>();
    }

    void Update()
    {
        if (m_state != state.idle) return;

        if (m_state == state.idle && Vector3.Distance(transform.position, gooseObj.position) <= distSuck){
            SuckTheGoose();
        }
        if (m_state == state.idle && Vector3.Distance(transform.position, rock.position) <= rockSuck){
            SuckTheRock();
        }
    }

    void SuckTheRock(){
        m_state = state.closed;
        rockMovable.EndDrag();
        rockMovable.SetState(MovableObject.state.noUse);
        rockMovable.GetRigidbody().isKinematic = true;
        rockMovable.GetCollider().enabled = false;
        moveObjects.AddObjToMove(rock, timeMove, 
            new Vector3(transform.position.x, rock.position.y, transform.position.z), rock.rotation, AnimateRock);
    }
    void AnimateRock(){
        moveObjects.AddObjToMove(rock, 1, finalRockPos.position, rock.rotation);
        audioDrop.Play();
    }

    void SuckTheGoose(){
        m_state = state.sucked;
        playerController.DisableGoose();
        moveObjects.AddObjToMove(gooseObj, timeMove, 
            new Vector3(transform.position.x, gooseObj.position.y, transform.position.z), gooseObj.rotation, AnimateGoose);
    }

    void AnimateGoose(){
        moveObjects.AddObjToMove(gooseObj, 1, 
            new Vector3(transform.position.x, gooseObj.position.y - 0.25f, transform.position.z), gooseObj.rotation);
        Invoke("PassTheLvl", 3);
    }

    void PassTheLvl(){
        gameManager.LvlFailed();
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, distSuck);
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, rockSuck);
    }
}
