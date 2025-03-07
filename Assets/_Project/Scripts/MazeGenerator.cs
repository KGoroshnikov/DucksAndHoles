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
    [SerializeField] private int slimeAmount;
    [SerializeField] private int wrongHoles;
    [SerializeField] private int bubblesAmount;

    [Header("Special Settings")]
    [SerializeField] private float groundTextureOffset;
    [SerializeField] private float fogOffset;
    [SerializeField] private StartCellType startCellType;
    [SerializeField] private bool isLvlPath;
    public enum StartCellType{
        center, zero
    }

    private Vector3 mazeStartPoint;

    [Header("Rooms")]
    [SerializeField] private List<RoomInfo> customRooms = new List<RoomInfo>();

    [Header("VFX")]
    [SerializeField] private ParticleSystem grassVFX;
    [SerializeField] private int grassAmountPerArea;
    [SerializeField] private ParticleSystem glowsVFX;
    [SerializeField] private int glowsAmountPerArea;

    private List<RoomDoorInfo> roomsDoors = new List<RoomDoorInfo>();
    private MazeCell[,] grid;
    private int gridWidth;
    private int gridHeight;

    private Vector2Int startCell;
    private Vector2Int finishCell;

    private List<Vector2Int> mainPath = new List<Vector2Int>();
    private Vector2Int autoStartCellIndex;

    private int generationAttempts = 0;
    private int maxGenerationAttempts = 10;
    private int cellOffset;

    [Header("Other")]
    [SerializeField] private Transform GrassGround;
    [SerializeField] private Material GrassMat;
    [SerializeField] private float GroundMulSize;
    [SerializeField] private FogOfWarManager fogOfWarManager;
    private Transform goose;
    [SerializeField] private HealthManager playerHealth;
    [SerializeField] private ChooseGameArea chooseGameArea;
    [SerializeField] private GameManager gameManager;

    [SerializeField] private GameObject text;
    [SerializeField] private GameObject hole;
    [SerializeField] private GameObject slime;
    [SerializeField] private GameObject wrongHolePref;
    [SerializeField] private GameObject bubblePref;

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
        public bool customWals;
        [Range(0f, 1f)]
        public float pathFraction = 0.5f;
        public int roomWidth = 2;
        public int roomHeight = 2;
        public int maxRoomPathTiles;
    }

    public class MazeCell
    {
        public bool visited = false;
        public bool wallTop = true;
        public bool wallBottom = true;
        public bool wallLeft = true;
        public bool wallRight = true;

        public bool isRoom = false;
        public bool noWalls = false;

        public bool canSpawnHere = true;
    }
    
    private List<GameObject> spawnedObjects = new List<GameObject>();
    private LvlScriptableObject lvlData;

    public bool GenerateMazeLevel(ARPlane _arplane, Transform _goose)
    {
        arPlane = _arplane;
        mazeStartPoint = _goose.position;
        goose = _goose;

        if (!CheckARPlaneSize())
        {
            Debug.LogError("ARPlane too smoll");
            return false;
        }

        Vector2 planeSize = arPlane.size;
        int availableCellsX = Mathf.FloorToInt(planeSize.x / cellSize);
        int availableCellsY = Mathf.FloorToInt(planeSize.y / cellSize);

        gridWidth = Mathf.Min(availableCellsX, maxMazeCellsX);
        gridHeight = Mathf.Min(availableCellsY, maxMazeCellsY);

        if (gridWidth * gridHeight < minPathLength)
        {
            Debug.LogError("ARPlane too smoll for min length");
            return false;
        }

        Vector3 arPlaneBottomLeft = arPlane.transform.position - new Vector3(arPlane.size.x, 0, arPlane.size.y) / 2f;
        float desiredOriginX = 0, desiredOriginZ = 0;
        if (startCellType == StartCellType.center){
            desiredOriginX = mazeStartPoint.x - (gridWidth / 2f) * cellSize;
            desiredOriginZ = mazeStartPoint.z - (gridHeight / 2f) * cellSize;
        }
        else if (startCellType == StartCellType.zero){
            desiredOriginX = mazeStartPoint.x;
            desiredOriginZ = mazeStartPoint.z;
        }
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

        Vector2Int cellIndexOffset = new Vector2Int(0, 0);
        cellOffset = 0;
        generationAttempts = 0;
        bool validMaze = false;
        while (!validMaze && generationAttempts < maxGenerationAttempts)
        {
            generationAttempts++;
            InitGrid();
            GenerateMazeDFS();

            startCell = autoStartCellIndex + cellIndexOffset;
            finishCell = GetFurthestCellFrom(startCell);
            mainPath = FindMainPathBFS(startCell, finishCell);

            if (mainPath != null && mainPath.Count >= minPathLength) 
                validMaze = true;
            else{
                cellIndexOffset = SpiralOffset(cellIndexOffset, autoStartCellIndex, new Vector2Int(gridWidth, gridHeight));
                Debug.Log("Try " + generationAttempts + ": Length " + (mainPath != null ? mainPath.Count.ToString() : "null") + " Regeneration...");
            }
        }

        if (!validMaze)
        {
            Debug.LogError("I cant generate a maze: " + maxGenerationAttempts + " tries.");
            return false;
        }

        grid[startCell.x, startCell.y].canSpawnHere = false;
        grid[finishCell.x, finishCell.y].canSpawnHere = false;

        foreach (RoomInfo room in customRooms)
            InsertRoom(room);

        AdjustAdjacentWallsToRooms();

        BuildMazeWalls();
        Debug.Log("Success! Length: " + mainPath.Count);

        //ShowCellID();

        InitFog();
        SpawnHoles();
        SpawnWrongHoles();
        SpawnSlimes(slimeAmount);
        SpawnBubbles(bubblesAmount);

        InitGroundTex();

        SetupVFX(GrassGround, grassVFX, grassAmountPerArea);
        SetupVFX(GrassGround, glowsVFX, glowsAmountPerArea);

        return true;
    }

    void InitGroundTex(){
        GrassGround.gameObject.SetActive(true);
        Vector3 lBottom = GridToWorldPosition(new Vector2(0, 0));
        Vector3 rTop = GridToWorldPosition(new Vector2(gridWidth - 1, gridHeight - 1));
        Vector3 center = (lBottom + rTop) / 2;
        GrassGround.position = center;
        GrassGround.localScale = new Vector3(gridWidth * GroundMulSize + groundTextureOffset, 1, gridHeight * GroundMulSize + groundTextureOffset);
        /*return;
        Vector3 topRight = GridToWorldPosition(new Vector2Int(gridWidth-1, gridHeight-1));
        Vector3 bottomLeft = GridToWorldPosition(new Vector2Int(0, 0));
        topRight += new Vector3(groundTextureOffset, 0, groundTextureOffset);
        bottomLeft -= new Vector3(groundTextureOffset, 0, groundTextureOffset);
        
        List<Vector2> points = new List<Vector2>();
        points.Add(new Vector2(bottomLeft.x, bottomLeft.z));
        points.Add(new Vector2(topRight.x, bottomLeft.z));
        points.Add(new Vector2(topRight.x, topRight.z));
        points.Add(new Vector2(bottomLeft.x, topRight.z));

        chooseGameArea.SetGameGround(points);*/
    }

    public void SetupLvlData(LvlScriptableObject lvl){
        lvlData = lvl;
        startCellType = lvl.startCellType;
        isLvlPath = lvl.isLvlPath;

        minPathLength = lvlData.minPathLength;
        slimeAmount = lvlData.slimeAmount;
        maxMazeCellsX = lvlData.maxMazeCellsX;
        maxMazeCellsY = lvlData.maxMazeCellsY;
        customRooms = lvlData.customRooms;

        wrongHoles = lvl.wrongHoles;
        bubblesAmount = lvl.bubblesAmount;
    }

    public void DestroyLevel(){
        if (goose != null) goose.SetParent(null);
        for(int i = 0; i < spawnedObjects.Count; i++){
            Destroy(spawnedObjects[i]);
        }
    }

    Vector2Int SpiralOffset(Vector2Int cellIndexOffset, Vector2Int startCellIndex, Vector2Int gridSize)
    {
        Vector2Int candidate;
        if (cellOffset == 0)
        {
            cellOffset = 1;
            candidate = new Vector2Int(cellOffset, 0);
        }
        else if (cellIndexOffset.x != 0)
        {
            if (cellIndexOffset.x == cellOffset) candidate = new Vector2Int(0, -cellOffset);
            else candidate = new Vector2Int(0, cellOffset);
        }
        else
        {
            if (cellIndexOffset.y == -cellOffset) candidate = new Vector2Int(-cellOffset, 0);
            else
            {
                cellOffset++;
                candidate = new Vector2Int(cellOffset, 0);
            }
        }

        Vector2Int newStart = startCellIndex + candidate;
        bool inBounds = (newStart.x >= 0 && newStart.x < gridSize.x && newStart.y >= 0 && newStart.y < gridSize.y);
        
        Debug.Log("Candidate: " + candidate + " inBounds: " + inBounds); 
        if (!inBounds)
        {
            if (cellOffset >= 10){
                Debug.LogError("REGENERATE THE LVL");
                return candidate;
            }

            Vector2Int nextCandidate = SpiralOffset(candidate, startCellIndex, gridSize);
            Debug.Log("nextCandidate: " + nextCandidate + " candidate: " + candidate);
            if (nextCandidate == candidate)
                return candidate;
            else
                return nextCandidate;
        }
        
        return candidate;
    }

    void SetupVFX(Transform obj, ParticleSystem particles, int amount){
        var shape = particles.shape;
        var mainModule = particles.main;
        mainModule.maxParticles = amount;
        shape.scale = new Vector3(obj.localScale.x * 10, obj.localScale.z * 10, 1);
        particles.transform.position = obj.position + new Vector3(0, 0.005f, 0);
        particles.transform.rotation = obj.rotation;
        particles.Clear();
        particles.Play();
    }

    void SpawnSlimes(int amount){
        if (isLvlPath) return;
        for(int i = 0; i < amount; i++){
            for(int att = 0; att < 10; att++){
                Vector2Int cell = new Vector2Int(Random.Range(0, gridWidth), Random.Range(0, gridHeight));
                if (mainPath.Contains(cell)) continue;
                GameObject mob = Instantiate(slime, GridToWorldPosition(cell), Quaternion.identity);
                spawnedObjects.Add(mob);

                mob.GetComponent<Slime>().Init(grid, cell, this, playerHealth);
                break;
            }
        }
    }

    public HealthManager GetHealthManager(){
        return playerHealth;
    }

    void SpawnHoles(){
        if (isLvlPath) return;
        GameObject newHole = Instantiate(hole, GridToWorldPosition(finishCell) + new Vector3(0, 0.005f, 0), Quaternion.Euler(90, 0, 0));
        spawnedObjects.Add(newHole);
    }

    void SpawnWrongHoles(){
        List<Vector2Int> possiblePositions = new List<Vector2Int>();
        for(int i = 0; i < gridWidth; i++){
            for(int j = 0; j < gridHeight; j++){
                if (grid[i, j].isRoom || !grid[i, j].canSpawnHere) continue;

                int amountWalls = 0;
                if (grid[i, j].wallBottom) amountWalls++;
                if (grid[i, j].wallTop) amountWalls++;
                if (grid[i, j].wallLeft) amountWalls++;
                if (grid[i, j].wallRight) amountWalls++;
                
                if (amountWalls == 3){
                    possiblePositions.Add(new Vector2Int(i, j));
                }
            }
        }
        int spawnAmountWrongHoles = Mathf.Min(wrongHoles, possiblePositions.Count);
        for(int i = 0; i < spawnAmountWrongHoles; i++){
            int spawnPos = Random.Range(0, possiblePositions.Count);
            grid[possiblePositions[spawnPos].x, possiblePositions[spawnPos].y].canSpawnHere = false;
            GameObject newHole = Instantiate(wrongHolePref, GridToWorldPosition(possiblePositions[spawnPos]) + new Vector3(0, Funcs.yOffset, 0), Quaternion.Euler(90, 0, 0));
            spawnedObjects.Add(newHole);
            possiblePositions.RemoveAt(spawnPos);
        }
    }

    void SpawnBubbles(int amount){
        if (amount == 0) return;
        List<Vector2Int> possibleTiles = new List<Vector2Int>();
        for(int x = 0; x < gridWidth; x++){
            for(int y = 0; y < gridHeight; y++)
            {
                if (new Vector2Int(x, y) == startCell || new Vector2Int(x, y) == finishCell || !grid[x, y].canSpawnHere) continue;
                possibleTiles.Add(new Vector2Int(x, y));
            }
        }
        amount = Mathf.Min(amount, possibleTiles.Count);
        for(int i = 0; i < amount; i++){
            Vector2Int cell = possibleTiles[Random.Range(0, possibleTiles.Count)];
            grid[cell.x, cell.y].canSpawnHere = false;
            possibleTiles.Remove(cell);
            GameObject bubble = Instantiate(bubblePref, GridToWorldPosition(cell), Quaternion.identity);
            spawnedObjects.Add(bubble);
        }
    }

    void InitFog(){
        if (isLvlPath){
            fogOfWarManager.HideFog();
            return;
        }
        Vector3 topRight = GridToWorldPosition(new Vector2Int(gridWidth-1, gridHeight-1));
        Vector3 bottomLeft = GridToWorldPosition(new Vector2Int(0, 0));
        topRight += new Vector3(fogOffset, 0, fogOffset);
        bottomLeft -= new Vector3(fogOffset, 0, fogOffset);
        
        List<Vector2> points = new List<Vector2>();
        points.Add(new Vector2(bottomLeft.x, bottomLeft.z));
        points.Add(new Vector2(topRight.x, bottomLeft.z));
        points.Add(new Vector2(topRight.x, topRight.z));
        points.Add(new Vector2(bottomLeft.x, topRight.z));

        fogOfWarManager.SetupFog(goose, (bottomLeft + topRight)/2, new Vector2(gridWidth, gridHeight), points);
    }

    void InitGrid()
    {
        roomsDoors.Clear();
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
                spawnedObjects.Add(obj);
                obj.GetComponent<TMP_Text>().text = new Vector2Int(x, y) + "";
                string walls = "";
                if (grid[x, y].wallLeft) walls += "L";
                if (grid[x, y].wallBottom) walls += "B";
                if (grid[x, y].wallRight) walls += "R";
                if (grid[x, y].wallTop) walls += "T";
                obj.transform.Find("walls").GetComponent<TMP_Text>().text = walls;
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
                
                score += Mathf.Abs(dx) + Mathf.Abs(dy);

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
        Debug.Log("Best room score: " + bestScore);
        roomStartX = bestStartX;
        roomStartY = bestStartY;
        if (bestIdsInsideRoom == null || bestIdsInsideRoom.Count == 0)
        {
            bestIdsInsideRoom = new List<int> { targetIndex };
            grid[targetCell.x, targetCell.y].isRoom = true;
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

        List<Vector2Int> roomCells = new List<Vector2Int>();
        for (int x = roomStartX; x < roomStartX + roomWidthCells; x++)
        {
            for (int y = roomStartY; y < roomStartY + roomHeightCells; y++)
            {
                roomCells.Add(new Vector2Int(x, y));
                grid[x, y].isRoom = true;
                grid[x, y].noWalls = room.customWals;
                if (!room.customWals && y + 1 >= roomStartY + roomHeightCells && new Vector2Int(x, y + 1) != entranceDoor.outsideCell && new Vector2Int(x, y + 1) != exitDoor.outsideCell) 
                    grid[x, y].wallTop = true;
                else grid[x, y].wallTop = false;
                if (!room.customWals && y - 1 < roomStartY && new Vector2Int(x, y - 1) != entranceDoor.outsideCell && new Vector2Int(x, y - 1) != exitDoor.outsideCell) 
                    grid[x, y].wallBottom = true;
                else grid[x, y].wallBottom = false;

                if (!room.customWals && x + 1 >= roomStartX + roomWidthCells && new Vector2Int(x + 1, y) != entranceDoor.outsideCell && new Vector2Int(x + 1, y) != exitDoor.outsideCell) 
                    grid[x, y].wallRight = true;
                else grid[x, y].wallRight = false;
                if (!room.customWals && x - 1 < roomStartX && new Vector2Int(x - 1, y) != entranceDoor.outsideCell && new Vector2Int(x - 1, y) != exitDoor.outsideCell) 
                    grid[x, y].wallLeft = true;
                else grid[x, y].wallLeft = false;

            }
        }

        Vector3 roomCenter = GridToWorldPosition(new Vector2Int(roomStartX + roomWidthCells / 2, roomStartY + roomHeightCells / 2));
        GameObject roomObj = Instantiate(room.roomPrefab, roomCenter, Quaternion.identity, transform);
        spawnedObjects.Add(roomObj);

        List<RoomDoorInfo> roomDoorInfos = new List<RoomDoorInfo>();
        roomDoorInfos.Add(entranceDoor);
        roomDoorInfos.Add(exitDoor);
        roomsDoors.AddRange(roomDoorInfos);
        roomObj.GetComponent<Room>().SetupRoom(roomDoorInfos, this, roomCells);
    }

    public void UpdateTile(Vector2Int tile, bool canSpawn){
        grid[tile.x, tile.y].canSpawnHere = canSpawn;
    }

    void AdjustAdjacentWallsToRooms()
    {
        for (int x = 0; x < gridWidth; x++)
        {
            for (int y = 0; y < gridHeight; y++)
            {
                if (grid[x, y].isRoom)
                    continue;
                
                // check walls
                if (x > 0 && grid[x - 1, y].isRoom)
                    grid[x, y].wallLeft = !grid[x - 1, y].noWalls;
                if (x < gridWidth - 1 && grid[x + 1, y].isRoom)
                    grid[x, y].wallRight = !grid[x + 1, y].noWalls;
                if (y > 0 && grid[x, y - 1].isRoom)
                    grid[x, y].wallBottom = !grid[x, y - 1].noWalls;
                if (y < gridHeight - 1 && grid[x, y + 1].isRoom)
                    grid[x, y].wallTop = !grid[x, y + 1].noWalls;

                // check doors
                if (CheckDoorBetween(new Vector2Int(x, y), new Vector2Int(x-1, y)))
                    grid[x, y].wallLeft = false;
                if (CheckDoorBetween(new Vector2Int(x, y), new Vector2Int(x+1, y)))
                    grid[x, y].wallRight = false;
                if (CheckDoorBetween(new Vector2Int(x, y), new Vector2Int(x, y-1)))
                    grid[x, y].wallBottom = false;
                if (CheckDoorBetween(new Vector2Int(x, y), new Vector2Int(x, y+1)))
                    grid[x, y].wallTop = false;
            }
        }
    }

    bool CheckDoorBetween(Vector2Int firstCell, Vector2Int secondCell){
        bool ok = false;
        for(int i = 0; i < roomsDoors.Count; i++){
            if ( (roomsDoors[i].insideCell == firstCell && roomsDoors[i].outsideCell == secondCell) ||
                (roomsDoors[i].insideCell == secondCell && roomsDoors[i].outsideCell == firstCell) )
                ok = true;
        }
        return ok;
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
            if (grid[x, y].wallLeft)
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
            if (grid[x, y].wallBottom)
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
        spawnedObjects.Add(wall);
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

    public List<Vector3> GetPosForLvlPath(){
        //float distToFirst = Vector3.Distance(goose.position, GridToWorldPosition(new Vector2Int(0, 0)));
        //float distToLast = Vector3.Distance(goose.position, GridToWorldPosition(new Vector2Int(gridWidth - 1, gridHeight - 1)));
        //return (distToFirst <= distToLast) ? GridToWorldPosition(new Vector2Int(0, 0)) : GridToWorldPosition(new Vector2Int(gridWidth - 1, gridHeight - 1));
        List<Vector3> firstAndLastPoses = new List<Vector3>();
        firstAndLastPoses.Add(GridToWorldPosition(new Vector2Int(0, 0)));
        firstAndLastPoses.Add(GridToWorldPosition(new Vector2Int(gridWidth - 1, gridHeight - 1)));
        return firstAndLastPoses;
    }
    public Transform getGoose(){
        return goose;
    }

    public List<Vector2Int> GetTilesBeforeRoom(Vector2Int roomEntrance)
    {
        List<Vector2Int> allowedTiles = new List<Vector2Int>();
        Queue<Vector2Int> queue = new Queue<Vector2Int>();
        queue.Enqueue(startCell);
        allowedTiles.Add(startCell);

        while (queue.Count > 0)
        {
            Vector2Int current = queue.Dequeue();
            if (current == roomEntrance) continue;

            foreach (Vector2Int neighbor in GetNeighborsForBFS(current))
            {
                if (!allowedTiles.Contains(neighbor))
                {
                    allowedTiles.Add(neighbor);
                    queue.Enqueue(neighbor);
                }
            }
        }

        return allowedTiles;
    }

    public GameManager GetGameManager(){
        return gameManager;
    }
}
