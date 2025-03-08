using System.Collections.Generic;
using UnityEngine;

public class Funcs : MonoBehaviour
{
    public const float yOffset = 0.0025f;
    public delegate void CallbackFunc();

    public static float SmoothLerp(float t){
        t = Mathf.Clamp(t, 0, 1);
        float smoothedT = t * t * (3f - 2f * t);
        return smoothedT;
    }

    public static Quaternion GyroToUnity(Quaternion quat)
    {
        return new Quaternion(quat.x, quat.z, quat.y, -quat.w);
    }

    public static List<Vector2> SortPointsCounterClockwiseXZ(List<Vector2> points)
    {
        Vector2 center = Vector2.zero;
        foreach (Vector2 point in points)
        {
            center += point;
        }
        center /= points.Count;

        points.Sort((a, b) =>
        {
            float angleA = Mathf.Atan2(a.y - center.y, a.x - center.x);
            float angleB = Mathf.Atan2(b.y - center.y, b.x - center.x);
            return angleA.CompareTo(angleB);
        });

        return points;
    }
}
