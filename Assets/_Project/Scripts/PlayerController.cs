using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private AnimationCurve speedXangle;
    [SerializeField] private float speedMul;
    [SerializeField] private float forceDamp;
    [SerializeField] private float maxSpeed;
    [SerializeField] private float deadZone = 2f;
    [SerializeField] private float maxPhoneAngle = 30f;
    [SerializeField] private float speedAnimMul;

    private Vector3 currentForce;
    private Vector3 neutralEuler;
    private float rotAngleAnim;
    
    private enum State { idle, running }
    private State m_state = State.idle;

    [Header("Init")]
    private PhoneInputData phoneInputData;
    [SerializeField] private Animator animator;
    [SerializeField] private Transform duckMesh;

    void OnEnable(){
        phoneInputData = GameObject.Find("PhoneData").GetComponent<PhoneInputData>();
        phoneInputData.OnStartTouch += StartMoving;
        phoneInputData.OnEndTouch += StopMoving;
    }
     void OnDisable(){
        phoneInputData.OnStartTouch -= StartMoving;
        phoneInputData.OnEndTouch -= StopMoving;
    }
    public void StartMoving(Vector2 touchPos)
    {
        if (m_state != State.idle) return;
        m_state = State.running;
        neutralEuler = GyroToUnity(phoneInputData.GetAttitude()).eulerAngles;
        animator.SetTrigger("BallMode");
        rotAngleAnim = duckMesh.transform.localEulerAngles.x;
    }
    Quaternion GyroToUnity(Quaternion quat)
    {
        return new Quaternion(quat.x, quat.z, quat.y, -quat.w);
    }

    public void StopMoving(Vector2 touchPos)
    {
        m_state = State.idle;
        animator.SetTrigger("IdleMode");
        rotAngleAnim = -90;
        duckMesh.transform.localEulerAngles = new Vector3(rotAngleAnim, 0, 90);
    }

    void Update()
    {
        transform.Translate(currentForce, Space.World);

        if (m_state != State.running){
            currentForce *= forceDamp;
            if (currentForce.magnitude <= 0.000001f) currentForce = Vector3.zero; 
            return;
        }

        Vector3 currentEuler = GyroToUnity(phoneInputData.GetAttitude()).eulerAngles;

        float deltaX = Mathf.DeltaAngle(neutralEuler.x, currentEuler.x);
        float deltaY = -Mathf.DeltaAngle(neutralEuler.z, currentEuler.z);

        if (Mathf.Abs(deltaX) < deadZone) deltaX = 0;
        if (Mathf.Abs(deltaY) < deadZone) deltaY = 0;

        float normalizedForward = Mathf.Clamp(deltaX / (maxPhoneAngle - deadZone), -1f, 1f);
        float normalizedSide = Mathf.Clamp(deltaY / (maxPhoneAngle - deadZone), -1f, 1f);

        Vector2 input2D = new Vector2(normalizedSide, normalizedForward);

        Transform camTransform = Camera.main.transform;
        Vector3 camForward = camTransform.forward;
        camForward.y = 0;
        camForward.Normalize();
        Vector3 camRight = Vector3.Cross(Vector3.up, camForward);

        Vector3 worldMovement = (input2D.y * camForward) + (input2D.x * camRight);
        //worldMovement = worldMovement.normalized;

        Vector3 finalSpeed = worldMovement * speedXangle.Evaluate(worldMovement.magnitude) * speedMul * Time.deltaTime;
        currentForce += finalSpeed;
        currentForce = Vector3.ClampMagnitude(currentForce, maxSpeed);
        Debug.Log("currentForce: " + currentForce + " worldMovement: " + worldMovement + " worldMovement.magnitude: " + worldMovement.magnitude + " speed: " + speedXangle.Evaluate(worldMovement.magnitude));

        if (worldMovement != Vector3.zero)
            transform.forward = worldMovement;

        rotAngleAnim += speedAnimMul * currentForce.magnitude;
        duckMesh.transform.localEulerAngles = new Vector3(rotAngleAnim, 0, 90);
    }

    void OnGUI()
    {
        GUIStyle guiStyle = new GUIStyle();
        guiStyle.normal.textColor = Color.red;
        guiStyle.fontSize = 40;
        float yOffset = 50;
        float lvlOffset = 50;
        GUI.Label(new Rect(10, yOffset + lvlOffset * 1, 300, 200), "currentForce: " + currentForce, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 2, 300, 200), "current magnitude: " + currentForce.magnitude, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 3, 300, 200), "max allowed magnitude: " + maxSpeed, guiStyle);
    }
}
