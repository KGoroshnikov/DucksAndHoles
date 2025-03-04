using UnityEngine;

public class WrongHole : MonoBehaviour
{
    [SerializeField] private float timeMove;
    [SerializeField] private float distSuck;
    private Transform gooseObj;
    private PlayerController playerController;
    private GameManager gameManager;
    private MoveObjects moveObjects;
    [SerializeField] private state m_state;
    public enum state{
        idle, sucked
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
        if (m_state == state.idle && Vector3.Distance(transform.position, gooseObj.position) <= distSuck){
            SuckTheGoose();
        }
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
    }

}
