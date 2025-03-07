using System.Collections.Generic;
using UnityEngine;

public class Slime : MonoBehaviour
{
    [SerializeField] private Vector2 moveTime;
    [SerializeField] private Vector2 chillTime;
    [SerializeField] private Animator animator;
    [SerializeField] private float randOffset;
    [SerializeField] private float hitRange;
    [SerializeField] private float angerRange;
    private float myTime;

    [SerializeField] private AudioSource audioSource;
    [SerializeField] private AudioClip[] jumpAttackClips;

    private Transform goose;

    private MazeGenerator.MazeCell[,] grid;

    private Vector3 currentPos;
    private Vector2Int currentCell;
    private Vector3 targetPos;

    private MazeGenerator mazeGenerator;

    private bool ableToHit;

    private float t;
    private enum state{
        idle, jumping
    }
    [SerializeField] private state m_state;

    private HealthManager healthManager;

    public void Init(MazeGenerator.MazeCell[,] _grid, Vector2Int _currentCell, MazeGenerator _maze, HealthManager _healthManager){
        healthManager = _healthManager;
        myTime = Random.Range(moveTime.x, moveTime.y);
        grid = _grid;
        t = 0;
        currentCell = _currentCell;
        mazeGenerator = _maze;
        goose = mazeGenerator.getGoose();
        MoveToOtherCell();
    }

    void FixedUpdate()
    {
        if (ableToHit && Vector3.Distance(transform.position, goose.position) <= hitRange){
            healthManager.TakeDamage();
            ableToHit = false;
        }

        if (m_state != state.jumping) return;

        t += Time.deltaTime / myTime;

        transform.position = Vector3.Lerp(currentPos, targetPos, t);

        if (t >= 1){
            PlaySFX(jumpAttackClips[1]);
            m_state = state.idle;
            Invoke("MoveToOtherCell", Random.Range(chillTime.x, chillTime.y));
        }
    }

    void MoveToOtherCell(){
        t = 0;
        currentPos = transform.position;

        List<Vector2Int> avaliableDirections = new List<Vector2Int>();
        if (!grid[currentCell.x, currentCell.y].wallLeft) avaliableDirections.Add(new Vector2Int(-1, 0));
        if (!grid[currentCell.x, currentCell.y].wallTop) avaliableDirections.Add(new Vector2Int(0, 1));
        if (!grid[currentCell.x, currentCell.y].wallRight) avaliableDirections.Add(new Vector2Int(1, 0));
        if (!grid[currentCell.x, currentCell.y].wallBottom) avaliableDirections.Add(new Vector2Int(0, -1));

        if (avaliableDirections.Count == 0) avaliableDirections.Add(new Vector2Int(0, 0));

        Vector2Int chosenDir = avaliableDirections[Random.Range(0, avaliableDirections.Count)];

        currentCell += chosenDir;
        if (Vector3.Distance(transform.position, goose.position) <= angerRange){
            targetPos = new Vector3(goose.position.x, transform.position.y, goose.position.z);
        }
        else
            targetPos = mazeGenerator.GridToWorldPosition(currentCell) + 
                new Vector3(Random.Range(-randOffset, randOffset), 0, Random.Range(-randOffset, randOffset));

        m_state = state.jumping;

        transform.forward = targetPos - transform.position;

        animator.SetTrigger("Jump");
        PlaySFX(jumpAttackClips[0]);
    }

    void PlaySFX(AudioClip clip){
        audioSource.clip = clip;
        audioSource.pitch = Random.Range(0.8f, 1.2f);
        audioSource.Play();
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
        Gizmos.DrawWireSphere(transform.position, hitRange);
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, angerRange);
    }
}
