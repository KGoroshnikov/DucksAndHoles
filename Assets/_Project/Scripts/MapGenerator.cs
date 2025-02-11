using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class MapGenerator : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private GameObject wallPrefab;
    [SerializeField] private int wallCount = 10;
    [SerializeField] private float minRequiredArea = 1.0f;

    [SerializeField] private ParticleSystem grassVFX;
    [SerializeField] private int grassAmountPerArea;
    [SerializeField] private ParticleSystem glowsVFX;
    [SerializeField] private int glowsAmountPerArea;

    [SerializeField] private GameObject theHole;
    [SerializeField] private Transform transformHole;

    public static float CalculatePolygonArea(List<Vector2> polygon)
    {
        float area = 0f;
        int j = polygon.Count - 1;
        for (int i = 0; i < polygon.Count; i++)
        {
            area += (polygon[j].x + polygon[i].x) * (polygon[j].y - polygon[i].y);
            j = i;
        }
        return Mathf.Abs(area * 0.5f);
    }

    private bool IsPointInPolygon(Vector2 point, List<Vector2> polygon)
    {
        bool isInside = false;
        int j = polygon.Count - 1;
        for (int i = 0; i < polygon.Count; i++)
        {
            if ((polygon[i].y > point.y) != (polygon[j].y > point.y) &&
                (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x))
            {
                isInside = !isInside;
            }
            j = i;
        }
        return isInside;
    }
    public void GenerateMap(ARPlane targetPlane)
    {
        List<Vector2> boundary = new List<Vector2>(targetPlane.boundary);

        if (boundary.Count < 3)
        {
            Debug.LogError("Not a plane");
            return;
        }
        float area = CalculatePolygonArea(boundary);
        Debug.Log("Area: " + area);

        if (area < minRequiredArea)
        {
            Debug.Log("Plane is too smoll");
            return;
        }

        float minX = float.MaxValue, minY = float.MaxValue;
        float maxX = float.MinValue, maxY = float.MinValue;
        foreach (Vector2 vertex in boundary)
        {
            if (vertex.x < minX) minX = vertex.x;
            if (vertex.y < minY) minY = vertex.y;
            if (vertex.x > maxX) maxX = vertex.x;
            if (vertex.y > maxY) maxY = vertex.y;
        }

        int spawnedWalls = 0;
        int attempts = 0;
        int maxAttempts = wallCount * 10;
        while (spawnedWalls < wallCount && attempts < maxAttempts)
        {
            attempts++;
            float randomX = Random.Range(minX, maxX);
            float randomY = Random.Range(minY, maxY);
            Vector2 randomPoint = new Vector2(randomX, randomY);

            if (IsPointInPolygon(randomPoint, boundary))
            {
                Vector3 worldPoint = targetPlane.transform.TransformPoint(new Vector3(randomPoint.x, 0, randomPoint.y));
                worldPoint.y += 0.05f;

                Instantiate(wallPrefab, worldPoint, Quaternion.identity);
                spawnedWalls++;
            }
        }

        SetupVFX(targetPlane, grassVFX, grassAmountPerArea);
        SetupVFX(targetPlane, glowsVFX, glowsAmountPerArea);

        Instantiate(theHole, transformHole.position, transformHole.rotation);
    }

    void SetupVFX(ARPlane currentPlane, ParticleSystem particles, int ppa){
        MeshFilter meshFilter = currentPlane.GetComponent<MeshFilter>();
        Mesh planeMesh = meshFilter.mesh;
        var shape = particles.shape;
        var mainModule = particles.main;
        shape.shapeType = ParticleSystemShapeType.Mesh;
        shape.mesh = planeMesh;
        List<Vector2> boundary = new List<Vector2>(currentPlane.boundary);
        float area = MapGenerator.CalculatePolygonArea(boundary);
        mainModule.maxParticles = (int)(area * ppa);
        particles.transform.position = currentPlane.transform.position;
        particles.transform.rotation = currentPlane.transform.rotation;
        particles.Play();
    }
}
