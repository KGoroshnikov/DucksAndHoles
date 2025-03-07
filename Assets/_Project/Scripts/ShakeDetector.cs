using UnityEngine;
using UnityEngine.Events;

public class ShakeDetector : MonoBehaviour
{
    [SerializeField] private UnityEvent OnCollidedDetected;
    [SerializeField] private float cooldownTime = 0.1f;
    private bool canDetect = true;

    void OnCollisionEnter(Collision collision)
    {
        if (!canDetect) return;
        if (collision.collider.CompareTag("Wall")){
            OnCollidedDetected.Invoke();
            canDetect = false;
            Invoke("Reset", cooldownTime);
        }
    }

    void Reset()
    {
        canDetect = true;
    }
}