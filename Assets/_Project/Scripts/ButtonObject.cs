using UnityEngine;
using UnityEngine.Events;

public class ButtonObject : MonoBehaviour
{
    [SerializeField] private Animator animator;

    [SerializeField] private UnityEvent onPressed;
    [SerializeField] private UnityEvent onReleased;

    [SerializeField] private AudioSource buttonAudio;

    private bool pressed;

    void Press(){
        if (pressed) return;
        pressed = true;
        animator.SetTrigger("Pressed");
        onPressed.Invoke();
        buttonAudio.Play();
    }
    void Release(){
        if (!pressed) return;
        pressed = false;
        animator.SetTrigger("Released");
        onReleased.Invoke();
        buttonAudio.Play();
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
