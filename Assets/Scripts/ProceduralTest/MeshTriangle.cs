using System.Collections.Generic;
using UnityEngine;

public class MeshTriangle : MonoBehaviour
{
    public List<int> VertexIndices;
    public List<Vector2> UVs;
    public List<MeshTriangle> Neighbours;
    public Color color;

    public MeshTriangle(int _VertexIndexA, int _VertexIndexB,int _VertexIndexC)
    {
        VertexIndices = new List<int>() { _VertexIndexA, _VertexIndexB, _VertexIndexC };
        UVs = new List<Vector2>() { Vector2.zero, Vector2.zero, Vector2.zero };
        Neighbours = new List<MeshTriangle>();
    }

    public bool IsNeighbouring(MeshTriangle _other)
    {
        int sharedVertices = 0;
        foreach (int index in VertexIndices)
        {
            if (_other.VertexIndices.Contains(index))
            {
                sharedVertices++;
            }
        }

        return sharedVertices > 1;
    }

    public void UpdateNeighbour(MeshTriangle _initialNeighbour, MeshTriangle newNeighbour)
    {
        for (int i = 0; i < Neighbours.Count; i++)
        {
            if (_initialNeighbour == Neighbours[i])
            {
                Neighbours[i] = newNeighbour;
                return;
            }
        }
    }
}
