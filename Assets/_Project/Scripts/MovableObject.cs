using UnityEngine;

public class MovableObject : MonoBehaviour
{
    public enum state{
        idle, dragging, noUse
    }
    [SerializeField] private float dragSpeed;
    [SerializeField] private state m_state;
    [SerializeField] private Rigidbody rb;
    [SerializeField] private Collider collider;
    [SerializeField] private float maxVelocity = 10;

    [SerializeField] private AudioSource dragSound;

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

    public void StartDrag(){
        m_state = state.dragging;
        if (dragSound != null) dragSound.Play();
    }
    public void EndDrag(){
        m_state = state.idle;
        if (dragSound != null) dragSound.Stop();
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
