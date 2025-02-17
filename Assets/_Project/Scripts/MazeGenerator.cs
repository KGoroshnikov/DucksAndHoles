using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class MazeGenerator : MonoBehaviour
{
    private ARPlane arPlane;

    [Header("Maze Settings")]
    [SerializeField] private int minPathLength;
    [SerializeField] private float cellSize;
    [SerializeField] private GameObject wallPrefab;
    [SerializeField] private Vector2 wallHeight;
    [SerializeField] private int maxMazeCellsX = 10;
    [SerializeField] private int maxMazeCellsY = 10;

    private Vector3 mazeStartPoint;

    [Header("Rooms")]
    [SerializeField] private List<RoomInfo> customRooms = new List<RoomInfo>();

    private MazeCell[,] grid;
    private int gridWidth;
    private int gridHeight;

    private Vector2Int startCell;
    private Vector2Int finishCell;

    private List<Vector2Int> mainPath = new List<Vector2Int>();
    private Vector2Int autoStartCellIndex;

    private int generationAttempts = 0;
    private int maxGenerationAttempts = 10;

    [SerializeField] private FogOfWarManager fogOfWarManager;
    private Transform goose;

    [SerializeField] private GameObject text;
    [SerializeField] private GameObject hole;
    [SerializeField] private GameObject slime;

    public struct RoomDoorInfo {
        public Vector2Int insideCell;
        public Vector2Int outsideCell;
        public Vector3 worldInside;
        public Vector3 worldOutside;
    }
    [System.Serializable]
    public class RoomInfo
    {
        public GameObject roomPrefab;
        [Range(0f, 1f)]
        public float pathFraction = 0.5f;
        public int roomWidth = 2;
        public int roomHeight = 2;
        public int maxRoomPathTiles;
    }

    class MazeCell
    {
        public bool visited = false;
        public bool wallTop = true;
        public bool wallBottom = true;
        public bool wallLeft = true;
        public bool wallRight = true;
        public bool isRoom = false;
    }

    public void GenerateMazeLevel(ARPlane _arplane, Transform _goose)
    {
        arPlane = _arplane;
        mazeStartPoint = _goose.position;
        goose = _goose;

        if (!CheckARPlaneSize())
        {
            Debug.LogError("ARPlane too smoll");
            return;
        }

        Vector2 planeSize = arPlane.size;
        int availableCellsX = Mathf.FloorToInt(planeSize.x / cellSize);
        int availableCellsY = Mathf.FloorToInt(planeSize.y / cellSize);

        gridWidth = Mathf.Min(availableCellsX, maxMazeCellsX);
        gridHeight = Mathf.Min(availableCellsY, maxMazeCellsY);

        if (gridWidth * gridHeight < minPathLength)
        {
            Debug.LogError("ARPlane too smoll for min length");
            return;
        }

        Vector3 arPlaneBottomLeft = arPlane.transform.position - new Vector3(arPlane.size.x, 0, arPlane.size.y) / 2f;
        float desiredOriginX = mazeStartPoint.x - (gridWidth / 2f) * cellSize;
        float desiredOriginZ = mazeStartPoint.z - (gridHeight / 2f) * cellSize;
        float planeLeft = arPlaneBottomLeft.x;
        float planeRight = arPlaneBottomLeft.x + arPlane.size.x;
        float planeBottom = arPlaneBottomLeft.z;
        float planeTop = arPlaneBottomLeft.z + arPlane.size.y;
        float minOriginX = planeLeft;
        float maxOriginX = planeRight - gridWidth * cellSize;
        float minOriginZ = planeBottom;
        float maxOriginZ = planeTop - gridHeight * cellSize;
        float chosenOriginX = Mathf.Clamp(desiredOriginX, minOriginX, maxOriginX);
        float chosenOriginZ = Mathf.Clamp(desiredOriginZ, minOriginZ, maxOriginZ);
        int autoStartX = Mathf.RoundToInt((mazeStartPoint.x - chosenOriginX) / cellSize);
        int autoStartY = Mathf.RoundToInt((mazeStartPoint.z - chosenOriginZ) / cellSize);
        autoStartCellIndex = new Vector2Int(Mathf.Clamp(autoStartX, 0, gridWidth - 1), Mathf.Clamp(autoStartY, 0, gridHeight - 1));
        Debug.Log(autoStartCellIndex + " wh: " + gridWidth + " " + gridHeight);


        generationAttempts = 0;
        bool validMaze = false;
        while (!validMaze && generationAttempts < maxGenerationAttempts)
        {
            generationAttempts++;
            InitGrid();
            GenerateMazeDFS();

            startCell = autoStartCellIndex;
            finishCell = GetFurthestCellFrom(startCell);
            mainPath = FindMainPathBFS(startCell, finishCell);

            if (mainPath != null && mainPath.Count >= minPathLength) 
                validMaze = true;
            else
                Debug.Log("Try " + generationAttempts + ": Length " + (mainPath != null ? mainPath.Count.ToString() : "null") + " Regeneration...");
        }

        if (!validMaze)
        {
            Debug.LogError("I cant generate a maze: " + maxGenerationAttempts + " tries.");
            return;
        }

        foreach (RoomInfo room in customRooms)
            InsertRoom(room);

        AdjustAdjacentWallsToRooms();

        BuildMazeWalls();
        Debug.Log("Success! Length: " + mainPath.Count);

        //ShowCellID();

        InitFog();
        SpawnHoles();
        SpawnSlimes(3);
    }

    void SpawnSlimes(int amount){
        for(int i = 0; i < amount; i++){
            for(int att = 0; att < 10; att++){
                Vector2Int cell = new Vector2Int(Random.Range(0, gridWidth), Random.Range(0, gridHeight));
                if (mainPath.Contains(cell)) continue;
                Instantiate(slime, GridToWorldPosition(cell), Quaternion.identity);
                break;
            }
        }
    }

    void SpawnHoles(){
        Instantiate(hole, GridToWorldPosition(finishCell) + new Vector3(0, 0.005f, 0), Quaternion.Euler(90, 0, 0));
    }

    void InitFog(){
        Vector3 leftBottom = GridToWorldPosition(new Vector2(0, 0));
        Vector3 rTop = GridToWorldPosition(new Vector2(gridWidth - 1, gridHeight - 1));
        fogOfWarManager.SetupFog(goose, (leftBottom + rTop)/2, new Vector2(gridWidth, gridHeight));
    }

    void InitGrid()
    {
        grid = new MazeCell[gridWidth, gridHeight];
        for (int x = 0; x < gridWidth; x++)
        {
            for (int y = 0; y < gridHeight; y++)
            {
                grid[x, y] = new MazeCell();
            }
        }
    }

    void ShowCellID(){

        for (int x = 0; x < gridWidth; x++)
        {
            for (int y = 0; y < gridHeight; y++)
            {
                GameObject obj = Instantiate(text, GridToWorldPosition(new Vector2Int(x, y)) + new Vector3(0, .15f, 0), Quaternion.identity);
                obj.GetComponent<TMP_Text>().text = new Vector2Int(x, y) + "";
                if (mainPath.Contains(new Vector2Int(x, y)))
                    obj.GetComponent<TMP_Text>().color = Color.blue;
                if (startCell == new Vector2Int(x, y))
                    obj.GetComponent<TMP_Text>().color = Color.green;
                if (finishCell == new Vector2Int(x, y))
                    obj.GetComponent<TMP_Text>().color = Color.red;
            }
        }
    }

    void GenerateMazeDFS()
    {
        Stack<Vector2Int> stack = new Stack<Vector2Int>();
        Vector2Int current = new Vector2Int(Random.Range(0, gridWidth), Random.Range(0, gridHeight));
        grid[current.x, current.y].visited = true;
        stack.Push(current);

        while (stack.Count > 0)
        {
            current = stack.Peek();
            List<Vector2Int> neighbors = GetUnvisitedNeighbors(current);
            if (neighbors.Count > 0)
            {
                Vector2Int chosen = neighbors[Random.Range(0, neighbors.Count)];
                RemoveWallBetween(current, chosen);
                grid[chosen.x, chosen.y].visited = true;
                stack.Push(chosen);
            }
            else stack.Pop();
        }
    }

    List<Vector2Int> GetUnvisitedNeighbors(Vector2Int cell)
    {
        List<Vector2Int> neighbors = new List<Vector2Int>();
        if (cell.y < gridHeight - 1 && !grid[cell.x, cell.y + 1].visited)
            neighbors.Add(new Vector2Int(cell.x, cell.y + 1));
        if (cell.y > 0 && !grid[cell.x, cell.y - 1].visited)
            neighbors.Add(new Vector2Int(cell.x, cell.y - 1));
        if (cell.x < gridWidth - 1 && !grid[cell.x + 1, cell.y].visited)
            neighbors.Add(new Vector2Int(cell.x + 1, cell.y));
        if (cell.x > 0 && !grid[cell.x - 1, cell.y].visited)
            neighbors.Add(new Vector2Int(cell.x - 1, cell.y));
        return neighbors;
    }

    void RemoveWallBetween(Vector2Int a, Vector2Int b)
    {
        if (a.x == b.x)
        {
            if (a.y < b.y)
            {
                grid[a.x, a.y].wallTop = false;
                grid[b.x, b.y].wallBottom = false;
            }
            else
            {
                grid[a.x, a.y].wallBottom = false;
                grid[b.x, b.y].wallTop = false;
            }
        }
        else if (a.y == b.y)
        {
            if (a.x < b.x)
            {
                grid[a.x, a.y].wallRight = false;
                grid[b.x, b.y].wallLeft = false;
            }
            else
            {
                grid[a.x, a.y].wallLeft = false;
                grid[b.x, b.y].wallRight = false;
            }
        }
    }

    List<Vector2Int> FindMainPathBFS(Vector2Int start, Vector2Int finish)
    {
        Queue<Vector2Int> queue = new Queue<Vector2Int>();
        Dictionary<Vector2Int, Vector2Int> cameFrom = new Dictionary<Vector2Int, Vector2Int>();
        bool[,] visited = new bool[gridWidth, gridHeight];

        queue.Enqueue(start);
        visited[start.x, start.y] = true;
        bool pathFound = false;

        while (queue.Count > 0)
        {
            Vector2Int current = queue.Dequeue();
            if (current == finish)
            {
                pathFound = true;
                break;
            }
            foreach (Vector2Int neighbor in GetNeighborsForBFS(current))
            {
                if (!visited[neighbor.x, neighbor.y])
                {
                    visited[neighbor.x, neighbor.y] = true;
                    queue.Enqueue(neighbor);
                    cameFrom[neighbor] = current;
                }
            }
        }

        if (!pathFound)
            return null;

        List<Vector2Int> path = new List<Vector2Int>();
        Vector2Int currentCell = finish;
        while (currentCell != start)
        {
            path.Add(currentCell);
            currentCell = cameFrom[currentCell];
        }
        path.Add(start);
        path.Reverse();
        return path;
    }

    List<Vector2Int> GetNeighborsForBFS(Vector2Int cell)
    {
        List<Vector2Int> neighbors = new List<Vector2Int>();
        if (!grid[cell.x, cell.y].wallTop && cell.y < gridHeight - 1)
            neighbors.Add(new Vector2Int(cell.x, cell.y + 1));
        if (!grid[cell.x, cell.y].wallBottom && cell.y > 0)
            neighbors.Add(new Vector2Int(cell.x, cell.y - 1));
        if (!grid[cell.x, cell.y].wallRight && cell.x < gridWidth - 1)
            neighbors.Add(new Vector2Int(cell.x + 1, cell.y));
        if (!grid[cell.x, cell.y].wallLeft && cell.x > 0)
            neighbors.Add(new Vector2Int(cell.x - 1, cell.y));
        return neighbors;
    }

    Vector2Int GetFurthestCellFrom(Vector2Int start)
    {
        Queue<Vector2Int> queue = new Queue<Vector2Int>();
        int[,] distances = new int[gridWidth, gridHeight];
        bool[,] visited = new bool[gridWidth, gridHeight];
        Debug.Log(gridWidth + " wh " + gridHeight);
        Debug.Log("start: " + start);

        queue.Enqueue(start);
        visited[start.x, start.y] = true;
        distances[start.x, start.y] = 0;

        while (queue.Count > 0)
        {
            Vector2Int current = queue.Dequeue();
            foreach (Vector2Int neighbor in GetNeighborsForBFS(current))
            {
                if (!visited[neighbor.x, neighbor.y])
                {
                    visited[neighbor.x, neighbor.y] = true;
                    distances[neighbor.x, neighbor.y] = distances[current.x, current.y] + 1;
                    queue.Enqueue(neighbor);
                }
            }
        }

        Vector2Int furthest = start;
        int maxDistance = 0;
        for (int x = 0; x < gridWidth; x++)
        {
            for (int y = 0; y < gridHeight; y++)
            {
                if (visited[x, y] && distances[x, y] > maxDistance)
                {
                    maxDistance = distances[x, y];
                    furthest = new Vector2Int(x, y);
                }
            }
        }
        return furthest;
    }
    void InsertRoom(RoomInfo room)
    {
        if (mainPath == null || mainPath.Count == 0)
            return;

        int targetIndex = Mathf.Clamp(Mathf.RoundToInt(room.pathFraction * (mainPath.Count - 1)), 0, mainPath.Count - 1);
        Vector2Int targetCell = mainPath[targetIndex];

        int roomWidthCells = room.roomWidth;
        int roomHeightCells = room.roomHeight;
        int roomStartX = targetCell.x - roomWidthCells / 2;
        int roomStartY = targetCell.y - roomHeightCells / 2;

        if (roomStartX < 0) roomStartX = 0;
        if (roomStartY < 0) roomStartY = 0;
        if (roomStartX + roomWidthCells > gridWidth) roomStartX = gridWidth - roomWidthCells;
        if (roomStartY + roomHeightCells > gridHeight) roomStartY = gridHeight - roomHeightCells;

        int shiftRange = 3;
        int bestScore = int.MaxValue;
        int bestStartX = roomStartX;
        int bestStartY = roomStartY;
        List<int> bestIdsInsideRoom = null;

        for (int dx = -shiftRange; dx <= shiftRange; dx++)
        {
            for (int dy = -shiftRange; dy <= shiftRange; dy++)
            {
                int candidateX = roomStartX + dx;
                int candidateY = roomStartY + dy;

                candidateX = Mathf.Clamp(candidateX, 0, gridWidth - roomWidthCells);
                candidateY = Mathf.Clamp(candidateY, 0, gridHeight - roomHeightCells);

                List<int> candidateIds = new List<int>();
                for (int i = 0; i < mainPath.Count; i++)
                {
                    Vector2Int cell = mainPath[i];
                    if (cell.x >= candidateX && cell.x < candidateX + roomWidthCells &&
                        cell.y >= candidateY && cell.y < candidateY + roomHeightCells)
                    {
                        candidateIds.Add(i);
                    }
                }
                int score = 0;

                if (candidateIds.Contains(0)) score += 1000;
                if (candidateIds.Contains(mainPath.Count - 1)) score += 1000;

                if (candidateIds.Count > room.maxRoomPathTiles)
                    score += (candidateIds.Count - room.maxRoomPathTiles) * 100;

                if (candidateIds.Count == 0)
                    score += 500;

                if (score < bestScore)
                {
                    bestScore = score;
                    bestStartX = candidateX;
                    bestStartY = candidateY;
                    bestIdsInsideRoom = candidateIds;
                }
            }
        }
        roomStartX = bestStartX;
        roomStartY = bestStartY;
        if (bestIdsInsideRoom == null || bestIdsInsideRoom.Count == 0)
        {
            bestIdsInsideRoom = new List<int> { targetIndex };
            grid[targetCell.x, targetCell.y].isRoom = true;
        }

        for (int x = roomStartX; x < roomStartX + roomWidthCells; x++)
        {
            for (int y = roomStartY; y < roomStartY + roomHeightCells; y++)
            {
                grid[x, y].isRoom = true;
                grid[x, y].wallTop = false;
                grid[x, y].wallBottom = false;
                grid[x, y].wallLeft = false;
                grid[x, y].wallRight = false;
            }
        }

        RoomDoorInfo entranceDoor;
        entranceDoor.insideCell = mainPath[bestIdsInsideRoom[0]];
        entranceDoor.outsideCell = bestIdsInsideRoom[0] > 0 ? mainPath[bestIdsInsideRoom[0] - 1] : entranceDoor.insideCell;
        entranceDoor.worldInside = GridToWorldPosition(entranceDoor.insideCell);
        entranceDoor.worldOutside = GridToWorldPosition(entranceDoor.outsideCell);
        Debug.Log("Entrance: inside " + entranceDoor.insideCell + ", outside " + entranceDoor.outsideCell);

        RoomDoorInfo exitDoor;
        exitDoor.insideCell = mainPath[bestIdsInsideRoom[bestIdsInsideRoom.Count - 1]];
        exitDoor.outsideCell = (bestIdsInsideRoom[bestIdsInsideRoom.Count - 1] < mainPath.Count - 1) ?
                                mainPath[bestIdsInsideRoom[bestIdsInsideRoom.Count - 1] + 1] : exitDoor.insideCell;
        exitDoor.worldInside = GridToWorldPosition(exitDoor.insideCell);
        exitDoor.worldOutside = GridToWorldPosition(exitDoor.outsideCell);
        Debug.Log("Exit: inside " + exitDoor.insideCell + ", outside " + exitDoor.outsideCell);

        Vector3 roomCenter = GridToWorldPosition(new Vector2Int(roomStartX + roomWidthCells / 2, roomStartY + roomHeightCells / 2));
        GameObject roomObj = Instantiate(room.roomPrefab, roomCenter, Quaternion.identity, transform);

        List<RoomDoorInfo> roomDoorInfos = new List<RoomDoorInfo>();
        roomDoorInfos.Add(entranceDoor);
        roomDoorInfos.Add(exitDoor);
        roomObj.GetComponent<Room>().SetupRoom(roomDoorInfos);
    }

    void AdjustAdjacentWallsToRooms()
    {
        for (int x = 0; x < gridWidth; x++)
        {
            for (int y = 0; y < gridHeight; y++)
            {
                if (grid[x, y].isRoom)
                    continue;

                if (x > 0 && grid[x - 1, y].isRoom)
                    grid[x, y].wallLeft = false;
                if (x < gridWidth - 1 && grid[x + 1, y].isRoom)
                    grid[x, y].wallRight = false;
                if (y > 0 && grid[x, y - 1].isRoom)
                    grid[x, y].wallBottom = false;
                if (y < gridHeight - 1 && grid[x, y + 1].isRoom)
                    grid[x, y].wallTop = false;
            }
        }
    }

    void BuildMazeWalls()
    {
        GameObject wallParent = new GameObject("MazeWalls");
        wallParent.transform.parent = transform;
        float yOffset = Funcs.yOffset;
        for (int x = 0; x < gridWidth; x++)
        {
            for (int y = 0; y < gridHeight; y++)
            {
                if (grid[x, y].isRoom)
                    continue;

                Vector3 cellPos = GridToWorldPosition(new Vector2Int(x, y));

                if (grid[x, y].wallRight)
                {
                    Vector3 pos = cellPos + new Vector3(cellSize / 2f, yOffset, 0);
                    GameObject wall = Instantiate(wallPrefab, pos, Quaternion.Euler(0, 90, 0), wallParent.transform);
                    SetupWall(wall);
                }
                if (grid[x, y].wallTop)
                {
                    Vector3 pos = cellPos + new Vector3(0, yOffset, cellSize / 2f);
                    GameObject wall = Instantiate(wallPrefab, pos, Quaternion.identity, wallParent.transform);
                    SetupWall(wall);
                }
            }
        }
        for (int y = 0; y < gridHeight; y++)
        {
            int x = 0;
            if (!grid[x, y].isRoom && grid[x, y].wallLeft)
            {
                Vector3 cellPos = GridToWorldPosition(new Vector2Int(x, y));
                Vector3 pos = cellPos + new Vector3(-cellSize / 2f, yOffset, 0);
                GameObject wall = Instantiate(wallPrefab, pos, Quaternion.Euler(0, 90, 0), wallParent.transform);
                SetupWall(wall);
            }
        }
        for (int x = 0; x < gridWidth; x++)
        {
            int y = 0;
            if (!grid[x, y].isRoom && grid[x, y].wallBottom)
            {
                Vector3 cellPos = GridToWorldPosition(new Vector2Int(x, y));
                Vector3 pos = cellPos + new Vector3(0, yOffset, -cellSize / 2f);
                GameObject wall = Instantiate(wallPrefab, pos, Quaternion.identity, wallParent.transform);
                SetupWall(wall);
            }
        }
    }
    void SetupWall(GameObject wall){
        wall.transform.localScale = new Vector3(wall.transform.localScale.x, Random.Range(wallHeight.x, wallHeight.y), wall.transform.localScale.z);
    }

    public Vector3 GridToWorldPosition(Vector2 gridPos)
    {
        Vector3 mazeOrigin = mazeStartPoint - new Vector3(autoStartCellIndex.x * cellSize, 0, autoStartCellIndex.y * cellSize);
        return mazeOrigin + new Vector3(gridPos.x * cellSize, 0, gridPos.y * cellSize);
    }

    bool CheckARPlaneSize()
    {
        if (arPlane == null)
            return false;
        if (arPlane.size.x < 4 * cellSize || arPlane.size.y < 4 * cellSize)
            return false;

        return true;
    }
}
