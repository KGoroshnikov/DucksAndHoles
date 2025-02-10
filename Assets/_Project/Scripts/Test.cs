using UnityEngine;

public class Test : MonoBehaviour
{
    [SerializeField] private PhoneInputData phoneInputData;

     private Quaternion _origin = Quaternion.identity;

     
     void LateUpdate()
     {
         transform.rotation = GyroToUnity(phoneInputData.GetAttitude());
         transform.Rotate(90,0,0);
     }
     
    Quaternion GyroToUnity(Quaternion quat)
    {
        return new Quaternion(quat.x, quat.z, quat.y, -quat.w);
    }

}
