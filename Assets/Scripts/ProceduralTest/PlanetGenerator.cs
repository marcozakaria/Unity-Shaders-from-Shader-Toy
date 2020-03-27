using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanetGenerator : MonoBehaviour
{
    [Header("Base Settings")]
    public float radius;
    public int IsoSphereSubDivision;
    public Material planetMaterial;
    public bool smoothNormals;
    public bool rotate;
    public float turnSpeed;
    //public List<ColorSettings>

    [Header("Ocean")]
    public bool drawShore;
    public float minShoreWidth;
    public float maxShoreWidth;

    [Header("Continents")]
    public int maxAmountOfContents;
    public float ContinetsMinSize;
    public float ContinetsMaxSize;
    public float minLandExtrusionHeight;
    public float maxLandExtrusionHeight;

    [Header("Mountains")]
    public float maxAmountOfMountains;
    public float mountainBaseSize;
    public float minMountainHeight;
    public float maxMountainHeight;

    [Header("Bumpiness")]
    public float minBumpFactor;
    public float maxBumpFactor;


    private GameObject planetGameObject;
    private MeshRenderer meshRenderer;
    private MeshFilter meshFilter;

    private Mesh planetMesh;
    private List<MeshTriangle> meshTraiangles;
    private List<Vector3> vertices;


    public void GeneratePlanet()
    {
        if (!planetGameObject)
        {
            planetGameObject = this.gameObject;
        }

        if (!meshRenderer)
        {
            meshRenderer = planetGameObject.GetComponent<MeshRenderer>();
            meshRenderer.material = planetMaterial;
        }

        if (!meshFilter)
        {
            meshFilter = planetGameObject.GetComponent<MeshFilter>();
        }

        planetMesh = new Mesh();
        GenerateIcoSphere();

        SetMesh();
    }

    void GenerateIcoSphere()
    {
        planetGameObject.transform.localPosition = Vector3.zero;
        meshTraiangles.Clear();
        vertices.Clear();

        float t = (1.0f + Mathf.Sqrt(5.0f)) / 2.0f;

        vertices.Add(new Vector3(-1, t, 0).normalized);
        vertices.Add(new Vector3(1, t, 0).normalized);
        vertices.Add(new Vector3(-1, -t, 0).normalized);
        vertices.Add(new Vector3(1, -t, 0).normalized);
        vertices.Add(new Vector3(0, -1, t).normalized);
        vertices.Add(new Vector3(0, 1, t).normalized);
        vertices.Add(new Vector3(0, -1, -t).normalized);
        vertices.Add(new Vector3(0, 1, -t).normalized);
        vertices.Add(new Vector3(t, 0, -1).normalized);
        vertices.Add(new Vector3(t, 0, 1).normalized);
        vertices.Add(new Vector3(-t, 0, -1).normalized);
        vertices.Add(new Vector3(-t, 0, 1).normalized);

        meshTraiangles.Add(new MeshTriangle(0, 11, 5));
        meshTraiangles.Add(new MeshTriangle(0, 5, 1));
        meshTraiangles.Add(new MeshTriangle(0, 1, 7));
        meshTraiangles.Add(new MeshTriangle(0, 7, 10));
        meshTraiangles.Add(new MeshTriangle(0, 10, 11));
        meshTraiangles.Add(new MeshTriangle(1, 5, 9));
        meshTraiangles.Add(new MeshTriangle(5, 11, 4));
        meshTraiangles.Add(new MeshTriangle(11, 10, 2));
        meshTraiangles.Add(new MeshTriangle(10, 7, 6));
        meshTraiangles.Add(new MeshTriangle(7, 1, 8));
        meshTraiangles.Add(new MeshTriangle(3, 9, 4));
        meshTraiangles.Add(new MeshTriangle(3, 4, 2));
        meshTraiangles.Add(new MeshTriangle(3, 2, 6));
        meshTraiangles.Add(new MeshTriangle(3, 6, 8));
        meshTraiangles.Add(new MeshTriangle(3, 8, 9));
        meshTraiangles.Add(new MeshTriangle(4, 9, 5));
        meshTraiangles.Add(new MeshTriangle(2, 4, 11));
        meshTraiangles.Add(new MeshTriangle(6, 2, 10));
        meshTraiangles.Add(new MeshTriangle(8, 6, 7));
        meshTraiangles.Add(new MeshTriangle(9, 8, 1));

        SubDivideVertices();
    }

    void SubDivideVertices()
    {
        Dictionary<int, int> middlePointVertices = new Dictionary<int, int>();

        for (int i = 0; i < IsoSphereSubDivision; i++)
        {
            List<MeshTriangle> updatedMeshTriangle = new List<MeshTriangle>();
            foreach (MeshTriangle triangle in meshTraiangles)
            {
                int a = triangle.VertexIndices[0];
                int b = triangle.VertexIndices[1];
                int c = triangle.VertexIndices[2];

                int ab = MiddlePointIndex(middlePointVertices, a, b);
                int bc = MiddlePointIndex(middlePointVertices, b, c);
                int ca = MiddlePointIndex(middlePointVertices, c, a);

                updatedMeshTriangle.Add(new MeshTriangle(a, ab, ca));
                updatedMeshTriangle.Add(new MeshTriangle(b, bc, ab));
                updatedMeshTriangle.Add(new MeshTriangle(c, ca, bc));
                updatedMeshTriangle.Add(new MeshTriangle(ab, bc, ca));
            }

            meshTraiangles = updatedMeshTriangle;
        }
    }

    int MiddlePointIndex(Dictionary<int, int> middlePointVertices, int a, int b)
    {
        return 0;
    }

    void SetMesh()
    {

    }
}
