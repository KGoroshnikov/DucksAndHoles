using UnityEngine;

public class MovableObject : MonoBehaviour
{
    public enum state{
        idle, noUse
    }
    [SerializeField] private float dragSpeed;
    [SerializeField] private state m_state;
    [SerializeField] private Rigidbody rb;
    [SerializeField] private Collider collider;
    [SerializeField] private float maxVelocity = 10;

    void FixedUpdate()
    {
        if (rb.linearVelocity.magnitude > maxVelocity)
            rb.linearVelocity = Vector3.ClampMagnitude(rb.linearVelocity, maxVelocity);
    }

    public state GetState(){
        return m_state;
    }

    public float GetDragSpeed(){
        return dragSpeed;
    }

    public void SetState(state newState){
        m_state = newState;
    }

    public Collider GetCollider(){
        return collider;
    }

    public Rigidbody GetRigidbody(){
        return rb;
    }
}
