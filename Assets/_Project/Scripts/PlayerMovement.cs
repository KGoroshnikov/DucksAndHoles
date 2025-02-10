using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private float maxSpeed = 5f;
    [SerializeField] private float smoothTime = 0.2f;
    [SerializeField] private float deadZone = 2f;
    [SerializeField] private float maxPhoneAngle = 35;
    [SerializeField] private state m_state;

    [SerializeField] private float rotationSpeed = 0.125f;

    private Vector3 currentVelocity = Vector3.zero;
    private Vector3 smoothedInput = Vector3.zero;
    private Quaternion neutralGyro;
    public enum state{
        idle, running
    }

    [Header("Init")]
    [SerializeField] private PhoneInputData phoneInputData;
    [SerializeField] private Animator animator;

    void OnEnable(){
        phoneInputData.OnStartTouch += StartMoving;
        phoneInputData.OnEndTouch += StopMoving;
    }
     void OnDisable(){
        phoneInputData.OnStartTouch -= StartMoving;
        phoneInputData.OnEndTouch -= StopMoving;
    }

    void StartMoving(Vector2 touchPos){
        if (m_state != state.idle) return;
        m_state = state.running;
        animator.ResetTrigger("IdleMode");
        animator.SetTrigger("BallMode");
        neutralGyro = phoneInputData.GetAttitude();
    }

    void StopMoving(Vector2 touchPos){
        m_state = state.idle;
        animator.ResetTrigger("BallMode");
        animator.SetTrigger("IdleMode");
        currentVelocity = Vector3.zero;
        smoothedInput = Vector3.zero;
    }

    void Update()
    {
        if (m_state != state.running) return;
        Quaternion currentGyro = phoneInputData.GetAttitude();
        
        Quaternion delta = Quaternion.Inverse(neutralGyro) * currentGyro;

        Vector3 deltaEuler = delta.eulerAngles;

        Debug.Log("delta: " + delta + " deltaEuler: " + deltaEuler);

        deltaEuler.x = (deltaEuler.x > 180f) ? deltaEuler.x - 360f : deltaEuler.x;
        deltaEuler.y = (deltaEuler.y > 180f) ? deltaEuler.y - 360f : deltaEuler.y;
        deltaEuler.z = (deltaEuler.z > 180f) ? deltaEuler.z - 360f : deltaEuler.z;

        Vector2 tilt = new Vector2(deltaEuler.x, deltaEuler.y);

        if (tilt.magnitude < deadZone)
        {
            tilt = Vector2.zero;
        }
        else
        {
            float adjustedMagnitude = (tilt.magnitude - deadZone) / (maxPhoneAngle - deadZone);
            adjustedMagnitude = Mathf.Clamp01(adjustedMagnitude);
            tilt = tilt.normalized * (adjustedMagnitude * adjustedMagnitude);
        }

        Vector3 inputDirection = new Vector3(tilt.y, 0, -tilt.x);

        Transform camTransform = Camera.main.transform;
        Vector3 camForward = camTransform.forward;
        camForward.y = 0;
        camForward.Normalize();
        Vector3 camRight = camTransform.right;
        camRight.y = 0;
        camRight.Normalize();

        Vector3 relativeInputDirection = inputDirection.z * camForward + inputDirection.x * camRight;
        smoothedInput = Vector3.Lerp(smoothedInput, relativeInputDirection, Time.deltaTime / smoothTime);
        Vector3 targetVelocity = smoothedInput * maxSpeed;
        currentVelocity = Vector3.Lerp(currentVelocity, targetVelocity, Time.deltaTime / smoothTime);

        transform.Translate(currentVelocity * Time.deltaTime, Space.World);

        if (currentVelocity.magnitude > 0.1f)
        {
            transform.forward = Vector3.Lerp(transform.forward, currentVelocity, rotationSpeed * Time.deltaTime);
        }
    }
}
