using UnityEngine;

public class SlimeTappable : MonoBehaviour, ITappable
{
    [SerializeField] private SlimeHoleRoom slimeHoleRoom;
    public void Tapped()
    {
        slimeHoleRoom.SlimeTapped();
    }

}
