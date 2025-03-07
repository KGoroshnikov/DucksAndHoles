using UnityEngine;

public class LvlHole : MonoBehaviour
{
    [SerializeField] private int m_id;

    public int GetID(){
        return m_id;
    }
    public void SetID(int id){
        m_id = id;
    }
}
