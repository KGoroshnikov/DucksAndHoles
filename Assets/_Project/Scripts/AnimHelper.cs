using UnityEngine;
using UnityEngine.Events;

public class AnimHelper : MonoBehaviour
{
    [SerializeField] private UnityEvent event1;
    [SerializeField] private UnityEvent event2;

    public void StartEvent1(){
        event1.Invoke();
    }
    public void StartEvent2(){
        event2.Invoke();
    }
}
