using UnityEngine;

public class TouchManager : MonoBehaviour
{
    private float speedMove;

    [SerializeField] private PlayerController playerController;
    [SerializeField] private LayerMask lmMovable;
    [SerializeField] private LayerMask lmDefault;
    private PhoneInputData phoneInputData;
    private bool movingItem;
    private bool justTapped;
    private Vector3 targetPos;
    private Rigidbody rbMoving;
    private MovableObject movableObject;

    void OnEnable(){
        phoneInputData = GameObject.Find("PhoneData").GetComponent<PhoneInputData>();
        phoneInputData.OnStartTouch += StartTouch;
        phoneInputData.OnEndTouch += EndTouch;
    }
     void OnDisable(){
        phoneInputData.OnStartTouch -= StartTouch;
        phoneInputData.OnEndTouch -= EndTouch;
    }

    void FixedUpdate()
    {
        if (!movingItem || rbMoving == null) return;

        if (movableObject.GetState() == MovableObject.state.noUse){
            movingItem = false;
            return;
        }

        RaycastHit hit0;
        Ray ray = Camera.main.ScreenPointToRay(phoneInputData.GetTapPos());
        if (Physics.Raycast(ray, out hit0, 1000, lmDefault)) {
            targetPos = hit0.point;
        }

        Vector3 move = Vector3.Lerp(rbMoving.position, targetPos, speedMove);
        Vector3 delta = move - rbMoving.position;
        rbMoving.AddForce(delta, ForceMode.VelocityChange);
    }

    void StartTouch(Vector2 touchPos){

        movingItem = false;
        RaycastHit hit;
        Ray ray = Camera.main.ScreenPointToRay(touchPos);
        if (Physics.Raycast(ray, out hit, 1000, lmMovable)) {
            movingItem = true;
            movableObject = hit.collider.GetComponent<MovableObject>();
            rbMoving = movableObject.GetRigidbody();
            speedMove = movableObject.GetDragSpeed();

            if (movableObject.GetState() == MovableObject.state.noUse) movingItem = false;
        }

        justTapped = false;
        if (Physics.Raycast(ray, out hit, 1000, lmDefault)) {
            if (hit.collider.CompareTag("ITappable")){
                hit.collider.GetComponent<ITappable>().Tapped();
                justTapped = true;
            }
        }

        Debug.Log("start: " + movingItem + " " + justTapped);
        if (!movingItem && !justTapped){
            playerController.StartMoving(touchPos);
        }
    }
    void EndTouch(Vector2 touchPos){
        Debug.Log("end: " + movingItem + " " + justTapped);
        if (!movingItem && !justTapped){
            playerController.StopMoving(touchPos);
        }

        justTapped = false;
        movingItem = false;
    }
}
