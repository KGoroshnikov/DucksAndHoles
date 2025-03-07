using UnityEngine;

public class PortalHole : MonoBehaviour
{
    [SerializeField] private float radius;
    [SerializeField] private Transform myExitPos;
    private Transform linkedPortalPos;
    private Transform player;
    private PlayerController playerController;
    private PortalRoom portalRoom;

    void Start(){
        player = GameObject.FindWithTag("Player").transform;
        playerController = player.GetComponent<PlayerController>();
    }

    public Transform GetPos(){
        return myExitPos;
    }
    public void SetLinkedPos(Transform _pos, PortalRoom _portalRoom){
        linkedPortalPos = _pos;
        portalRoom = _portalRoom;
    }

    void FixedUpdate()
    {
        if (Vector3.Distance(transform.position, player.position) <= radius &&
            Vector3.Dot(playerController.GetInputDir(), transform.forward) >= 0.6f){
            player.position = linkedPortalPos.position;
            portalRoom.AddPass();
        }
    }
    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, radius);
    }
}
