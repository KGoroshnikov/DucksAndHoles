using UnityEngine;
using UnityEngine.Events;

public class ButtonObject : MonoBehaviour
{
    [SerializeField] private Animator animator;

    [SerializeField] private UnityEvent onPressed;
    [SerializeField] private UnityEvent onReleased;

    private bool pressed;

    void Press(){
        if (pressed) return;
        pressed = true;
        animator.SetTrigger("Pressed");
        onPressed.Invoke();
    }
    void Release(){
        if (!pressed) return;
        pressed = false;
        animator.SetTrigger("Released");
        onReleased.Invoke();
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player") || other.CompareTag("Movable")){
            Press();
        }
    }
    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player") || other.CompareTag("Movable")){
            Release();
        }
    }
}
