using UnityEngine;

public class Funcs : MonoBehaviour
{
    public delegate void CallbackFunc();

    public static float SmoothLerp(float t){
        t = Mathf.Clamp(t, 0, 1);
        float smoothedT = t * t * (3f - 2f * t);
        return smoothedT;
    }
}
