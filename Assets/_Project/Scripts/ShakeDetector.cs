using UnityEngine;
using UnityEngine.Events;

public class ShakeDetector : MonoBehaviour
{
    [SerializeField] private UnityEvent OnCollidedDetected;

    void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.CompareTag("Wall")) OnCollidedDetected.Invoke();
    }
}