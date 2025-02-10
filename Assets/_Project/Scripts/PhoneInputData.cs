using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class PhoneInputData : MonoBehaviour
{
    [SerializeField] private UDPReceiver UDPReceiver;

    public delegate void StartTouchEvent(Vector2 pos);
    public event StartTouchEvent OnStartTouch;
    public delegate void EndTouchEvent(Vector2 pos);
    public event EndTouchEvent OnEndTouch;

    public InputActionReference tap;

    private MyInput inputActions;

    void Awake(){
        inputActions = new MyInput();
    }
    void Start(){
        Input.gyro.enabled = true;
        inputActions.MyActions.Tap.started += ctx => TouchStarted(ctx);
        inputActions.MyActions.Tap.canceled += ctx => TouchEnded(ctx);
    }
    void OnEnable(){
        inputActions.Enable();
    }
    void OnDisable(){
        inputActions.Disable();
    }

    public Vector2 GetTapPos(){
        return inputActions.MyActions.TapPos.ReadValue<Vector2>();
    }

    void TouchStarted(InputAction.CallbackContext context){
        if (OnStartTouch != null)
            OnStartTouch(inputActions.MyActions.TapPos.ReadValue<Vector2>());
    }
    void TouchEnded(InputAction.CallbackContext context){
        if (OnEndTouch != null)
            OnEndTouch(inputActions.MyActions.TapPos.ReadValue<Vector2>());
    }

    public Quaternion GetAttitude(){
        #if UNITY_EDITOR
            return UDPReceiver.attitude;
        #else
            return Input.gyro.attitude;
        #endif
    }
    public Vector3 GetRotationRate(){
        #if UNITY_EDITOR
            return UDPReceiver.rotationRate;
        #else
            return Input.gyro.rotationRate;
        #endif
    }
    public Vector3 GetUserAcceleration(){
        #if UNITY_EDITOR
            return UDPReceiver.userAcceleration;
        #else
            return Input.gyro.userAcceleration;
        #endif
    }
}
