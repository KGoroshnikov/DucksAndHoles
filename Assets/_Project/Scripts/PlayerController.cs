using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private float accelerationForce;
    [SerializeField] private float brakeForce;

    [SerializeField] private float speedMul;
    [SerializeField] private float forceDamp;
    [SerializeField] private float maxSpeed;
    [SerializeField] private float deadZone = 2f;
    [SerializeField] private float maxPhoneAngle = 30f;
    [SerializeField] private float speedAnimMul;

    [Header("Dash settings")]
    [SerializeField] private float jerkThreshold = 1.5f;
    [SerializeField] private float smoothingFactor = 0.2f;
    [SerializeField] private float jerkCooldown = 1f;
    [SerializeField] private float dashDamp;
    [SerializeField] private float dashSpeed;
    private bool isDashAvaliable = true;
    private Vector3 lowPassValue = Vector3.zero;
    private Vector3 jerkVector = Vector3.zero;

    [Header("Collide settings")]
    [SerializeField] private string regularWallTag;
    [SerializeField] private string breakableWallTag;
    [SerializeField] private float minFoceToHitWall;

    private Vector3 currentForce;
    private Vector3 deviceAccelerationRaw;
    private Vector3 deviceJerk;
    private Vector3 dashForce;
    private Vector3 neutralEuler;
    private float rotAngleAnim;
    private Vector3 worldMovement;
    
    private enum State { idle, running, afk }
    [SerializeField] private State m_state = State.idle;

    [Header("Init")]
    [SerializeField] private Animator animator;
    private PhoneInputData phoneInputData;
    [SerializeField] private Transform duckMesh;
    [SerializeField] private ParticleSystem puffVFX, dirtParticles, puffCollisionVFX;
    [SerializeField] private TrailRenderer trail;
    [SerializeField] private Rigidbody rb;
    [SerializeField] private GameObject mainFogTrail;
    [SerializeField] private TrailRenderer fogTrail;
    private float _y;

    void Start()
    {
        m_state = State.afk;
        trail.emitting = false;
        lowPassValue = phoneInputData.GetUserAcceleration();
    }

    public void ActivateGoose(float _gameY){
        m_state = State.idle;
        trail.emitting = true;
        _y = _gameY + 0.01f;

        mainFogTrail.SetActive(true);
    }

    void OnEnable(){
        phoneInputData = GameObject.Find("PhoneData").GetComponent<PhoneInputData>();
        /*phoneInputData.OnStartTouch += StartMoving;
        phoneInputData.OnEndTouch += StopMoving;*/
    }
     void OnDisable(){
        /*phoneInputData.OnStartTouch -= StartMoving;
        phoneInputData.OnEndTouch -= StopMoving;*/
    }
    public void StartMoving(Vector2 touchPos)
    {
        if (m_state != State.idle) return;
        puffVFX.Play();
        dirtParticles.Play();
        m_state = State.running;
        neutralEuler = GyroToUnity(phoneInputData.GetAttitude()).eulerAngles;
        animator.SetTrigger("BallMode");
        rotAngleAnim = duckMesh.transform.localEulerAngles.x;
    }
    Quaternion GyroToUnity(Quaternion quat)
    {
        return new Quaternion(quat.x, quat.z, quat.y, -quat.w);
    }

    public void ResetPlayer(){
        m_state = State.afk;
        mainFogTrail.transform.SetParent(transform);
        mainFogTrail.transform.localPosition = Vector3.zero;
        mainFogTrail.transform.localRotation = Quaternion.Euler(new Vector3(90, 0, 0));
        puffCollisionVFX.transform.SetParent(transform);
        puffCollisionVFX.transform.localPosition = Vector3.zero;
        rb.isKinematic = false;
        trail.emitting = false;
        trail.Clear();
        fogTrail.Clear();
    }

    public void StopMoving(Vector2 touchPos)
    {
        if (m_state == State.afk || m_state == State.idle) return;
        m_state = State.idle;
        animator.SetTrigger("IdleMode");
        dirtParticles.Stop();
        worldMovement = Vector3.zero;
        rotAngleAnim = -90;
        duckMesh.transform.localEulerAngles = new Vector3(rotAngleAnim, 0, 90);
    }

    void ResetDash(){
        isDashAvaliable = true;
    }

    void ProcessDash(){
        if (!isDashAvaliable) return;

        Vector3 currentAccel = phoneInputData.GetUserAcceleration();
        lowPassValue = Vector3.Lerp(lowPassValue, currentAccel, smoothingFactor);
        Vector3 deltaAccel = currentAccel - lowPassValue;
        if (deltaAccel.magnitude > jerkThreshold)
        {
            deviceAccelerationRaw = currentAccel;
            deviceJerk = deltaAccel.normalized;
            deviceJerk = new Vector3(deviceJerk.x, deviceJerk.y, deviceJerk.z);
            
            Vector3 worldJerk = Camera.main.transform.TransformDirection(deviceJerk).normalized;
            isDashAvaliable = false;
            jerkVector = new Vector3(-worldJerk.x, 0, -worldJerk.y);
            dashForce += jerkVector * dashSpeed;
            Invoke("ResetDash", jerkCooldown);
        }
        
    }

    void FixedUpdate()
    {
        if (m_state == State.afk) return;

        //ProcessDash();

        //transform.Translate(currentForce, Space.World);
        rb.linearVelocity = currentForce;

        if (dashForce.magnitude > 0.01f ) dashForce *= dashDamp;
        else dashForce = Vector3.zero; 
        

        if (m_state != State.running){
            currentForce *= forceDamp;
            if (currentForce.magnitude <= 0.0001f) currentForce = Vector3.zero; 
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

        worldMovement = (input2D.y * camForward) + (input2D.x * camRight);
        //worldMovement = worldMovement.normalized;

        Vector3 finalSpeed = worldMovement * speedMul * Time.deltaTime;
        //currentForce += finalSpeed;
        float dot = Vector3.Dot(currentForce.normalized, worldMovement.normalized);
        currentForce += Mathf.Lerp(brakeForce, accelerationForce, dot) * finalSpeed;
        
        currentForce = Vector3.ClampMagnitude(currentForce, maxSpeed);

        if (worldMovement != Vector3.zero)
            transform.forward = currentForce.normalized;

        UpdateRotationAnim();

        UpdateParticles();
    }

    void UpdateParticles(){
        var emission = dirtParticles.emission;
        emission.rateOverTime = Mathf.Lerp(0, 10, worldMovement.magnitude);
        trail.transform.localPosition = new Vector3(0, _y, 0);
        trail.transform.position = new Vector3(trail.transform.position.x, _y, trail.transform.position.z);
    }

    void UpdateRotationAnim(){
        rotAngleAnim += speedAnimMul * currentForce.magnitude;
        duckMesh.transform.localEulerAngles = new Vector3(rotAngleAnim, 0, 90);
    }

    public void DisableGoose(){
        m_state = State.afk;
        mainFogTrail.transform.SetParent(null);
        trail.emitting = false;
        rb.isKinematic = true;
        dirtParticles.Stop();
        animator.SetTrigger("IdleMode");
        currentForce = Vector3.zero;
        dashForce = Vector3.zero;
        rotAngleAnim = -90;
        duckMesh.transform.localEulerAngles = new Vector3(rotAngleAnim, 0, 90);
    }
    
    public void Die(){
        DisableGoose();
        puffCollisionVFX.Play();
        puffCollisionVFX.transform.SetParent(null);
        gameObject.SetActive(false);
    }

    public Vector3 GetInputDir(){
        return worldMovement;
    }

    void OnGUI()
    {
        return;
        GUIStyle guiStyle = new GUIStyle();
        guiStyle.normal.textColor = Color.red;
        guiStyle.fontSize = 40;
        float yOffset = 50;
        float lvlOffset = 50;
        GUI.Label(new Rect(10, yOffset + lvlOffset * 1, 300, 200), "worldMovement: " + worldMovement, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 2, 300, 200), "currentForce: " + currentForce, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 3, 300, 200), "current magnitude: " + currentForce.magnitude, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 4, 300, 200), "max allowed magnitude: " + maxSpeed, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 5, 300, 200), "device acc raw: " + deviceAccelerationRaw, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 6, 300, 200), "device dash: " + deviceJerk, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 7, 300, 200), "dash vector: " + jerkVector, guiStyle);
        GUI.Label(new Rect(10, yOffset + lvlOffset * 8, 300, 200), "dashForce: " + dashForce, guiStyle);
    }

    void OnCollisionEnter(Collision collision)
    {   
        if (currentForce.magnitude < minFoceToHitWall) return;

        if (collision.collider.CompareTag(regularWallTag)){
            puffCollisionVFX.Play();
            currentForce = currentForce / 3f; 
            StopMoving(Vector2.zero);
        }       
    }
}
