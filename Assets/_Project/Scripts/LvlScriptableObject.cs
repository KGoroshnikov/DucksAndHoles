using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Data", menuName = "ScriptableObjects/LvlScriptableObject", order = 1)]
public class LvlScriptableObject : ScriptableObject
{
    public int minPathLength;
    public int maxMazeCellsX = 10;
    public int maxMazeCellsY = 10;
    public int wrongHoles = 0;
    public int bubblesAmount = 0;
    public List<MazeGenerator.RoomInfo> customRooms = new List<MazeGenerator.RoomInfo>();

    public int slimeAmount;

    public MazeGenerator.StartCellType startCellType = MazeGenerator.StartCellType.center;
    public bool isLvlPath;
}