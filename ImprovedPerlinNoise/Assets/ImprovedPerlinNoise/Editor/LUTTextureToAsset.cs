using System.IO;
using UnityEditor;
using UnityEngine;

public static class LUTTextureToAsset
{
    public static void Save(Texture2D texture, string path, string name)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
            AssetDatabase.Refresh();
        }

        string assetPath = path + "/" + name + ".asset";
        AssetDatabase.CreateAsset(texture, assetPath);
        AssetDatabase.SaveAssets();

        Debug.Log("Gradient texture saved to " + assetPath);
    }
}