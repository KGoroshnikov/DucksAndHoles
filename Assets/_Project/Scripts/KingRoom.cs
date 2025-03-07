using System.Collections.Generic;
using UnityEngine;

public class KingRoom : Room
{
    [SerializeField] private Transform ring;

    [SerializeField] private Transform king;
    [SerializeField] private float angerRadius;
    [SerializeField] private float hitTimeIdle;


    [SerializeField] private float moveTime;
    [SerializeField] private Animator animator;
    [SerializeField] private float hitRange;
    [SerializeField] private AudioSource slimeAudio;
    [SerializeField] private AudioClip[] jumpHitClips;

    private Transform goose;
    private Vector3 currentPos;
    private Vector3 targetPos;
    private Vector3 defaultKingPos;

    private bool ableToHit;

    private float t;
    private enum state{
        idle, jumping, justHitted
    }
    [SerializeField] private state m_state;

    private HealthManager healthManager;

    public override void SetupRoom(List<MazeGenerator.RoomDoorInfo> roomDoorInfos, MazeGenerator _mazeGenerator = null, List<Vector2Int> roomCells = null){
        base.SetupRoom(roomDoorInfos, _mazeGenerator, roomCells);
        List<Vector2Int> possibleTiles = _mazeGenerator.GetTilesBeforeRoom(roomDoorInfos[1].insideCell);
        Vector2Int randTile = possibleTiles[Random.Range(0, possibleTiles.Count)];
        ring.gameObject.SetActive(true);
        ring.position = _mazeGenerator.GridToWorldPosition(randTile) + Vector3.up * Funcs.yOffset * 3;
        _mazeGenerator.UpdateTile(randTile, false);
        king.position = new Vector3(king.position.x, king.position.y + Funcs.yOffset, king.position.z);
        goose = _mazeGenerator.getGoose();
        defaultKingPos = king.position;
        healthManager = _mazeGenerator.GetHealthManager();
        t = 0;
    }

    public void Ringed(){
        if (m_state == state.idle || m_state == state.justHitted){
            CancelInvoke("CheckPlayer");
            JumpOnRinger();
        }
    }

    void JumpOnRinger(){
        t = 0;
        currentPos = king.position;
        targetPos = new Vector3(ring.position.x, king.position.y, ring.position.z);
        m_state = state.jumping;
        king.forward = targetPos - king.position;
        animator.SetTrigger("Jump");
        slimeAudio.clip = jumpHitClips[0];
        slimeAudio.Play();
    }

    void CheckPlayer(){
        t = 0;
        currentPos = king.position;

        if (Vector3.Distance(king.position, goose.position) <= angerRadius)
            targetPos = new Vector3(goose.position.x, king.position.y, goose.position.z);
        else
            targetPos = defaultKingPos;

        m_state = state.jumping;
        king.forward = targetPos - king.position;
        animator.SetTrigger("Jump");
        slimeAudio.clip = jumpHitClips[0];
        slimeAudio.Play();
    }

    void FixedUpdate()
    {
        if (ableToHit && Vector3.Distance(king.position, goose.position) <= hitRange){
            healthManager.TakeDamage(3);
            ableToHit = false;
        }

        if (m_state == state.idle && Vector3.Distance(king.position, goose.position) <= angerRadius){
            CheckPlayer();
        }

        if (m_state != state.jumping) return;

        t += Time.deltaTime / moveTime;

        king.position = Vector3.Lerp(currentPos, targetPos, t);
        
        if (t >= 1){
            slimeAudio.clip = jumpHitClips[1];
            slimeAudio.Play();
        }

        if (t >= 1 && king.position != defaultKingPos){
            m_state = state.justHitted;
            Invoke("CheckPlayer", hitTimeIdle);
        }
        else if (t >= 1 && king.position == defaultKingPos){
            m_state = state.idle;
        }
    }

    public void CanHit(){ // called from animations
        ableToHit = true;
    }
     public void CantHit(){
        ableToHit = false;
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(king.position, angerRadius);
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(king.position, hitRange);
    }
}
