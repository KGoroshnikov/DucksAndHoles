using System.Collections.Generic;
using UnityEngine;

public class MoveObjects : MonoBehaviour
{
    public class obj{
        public Transform m_obj;
        public Quaternion startRot;
        public Vector3 startPos;
        public Quaternion endRot;
        public Vector3 endPos;
        public float timeToMove;
        public float t;
        public Funcs.CallbackFunc callbackFunc;
    }
    private List<obj> objs = new List<obj>();

    void FixedUpdate()
    {
        List<obj> objsToRemove = new List<obj>(); 
        for(int i = 0; i < objs.Count; i++){
            objs[i].t += Time.deltaTime / objs[i].timeToMove;
            objs[i].m_obj.position = Vector3.Lerp(objs[i].startPos, objs[i].endPos, Funcs.SmoothLerp(objs[i].t));
            objs[i].m_obj.rotation = Quaternion.Lerp(objs[i].startRot, objs[i].endRot, Funcs.SmoothLerp(objs[i].t));
            if (objs[i].t >= 1){
                objsToRemove.Add(objs[i]);
                if (objs[i].callbackFunc != null)
                    objs[i].callbackFunc();
            }
        }
        for(int i = 0; i < objsToRemove.Count; i++){
            objs.Remove(objsToRemove[i]);
        }
    }

    public void AddObjToMove(Transform _obj, float _timeToMove, Vector3 _endpos, Quaternion _endrot, Funcs.CallbackFunc _callback){
        obj newObj = new obj();
        newObj.m_obj = _obj;
        newObj.startPos = _obj.position;
        newObj.startRot = _obj.rotation;
        newObj.endPos = _endpos;
        newObj.endRot = _endrot;
        newObj.timeToMove = _timeToMove;
        newObj.callbackFunc = _callback;
        objs.Add(newObj);
    }
}
