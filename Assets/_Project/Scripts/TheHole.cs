using UnityEngine;

public class TheHole : MonoBehaviour
{
    [SerializeField] private Transform startPos;
    [SerializeField] private Transform parentObj;
    [SerializeField] private Animator animator;
    [SerializeField] private float timeMove;
    [SerializeField] private float distSuck;
    private Transform gooseObj;
    private PlayerController playerController;
    private MoveObjects moveObjects;
    [SerializeField] private state m_state;
    public enum state{
        idle, sucked
    }

    void Start()
    {
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
        moveObjects.AddObjToMove(gooseObj, timeMove, startPos.position, startPos.rotation, AnimateGoose);
    }

    void AnimateGoose(){
        parentObj.position = gooseObj.position;
        parentObj.rotation = gooseObj.rotation;
        parentObj.SetParent(null);
        parentObj.localScale = gooseObj.localScale;
        parentObj.SetParent(transform);
        gooseObj.SetParent(parentObj);
        if (!animator.enabled) animator.enabled = true;
        else animator.SetTrigger("Jump");
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, distSuck);
    }
}
