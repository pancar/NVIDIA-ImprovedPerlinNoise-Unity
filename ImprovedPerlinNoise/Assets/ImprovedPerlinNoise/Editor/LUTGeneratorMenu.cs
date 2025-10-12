using UnityEngine;
using UnityEditor;
using System.IO;

public static class LUTGeneratorMenu
{
    [MenuItem("Tools/ImprovedPerlinNoise/Generate Global Texture Data + LUTs")]
    public static void GenerateAll()
    {
        string resourcesFolder = "Assets/Resources";
        string lutFolder = Path.Combine(resourcesFolder, "LUTs");

        EnsureFolderExists(resourcesFolder);
        EnsureFolderExists(lutFolder);

        string assetPath = Path.Combine(resourcesFolder, "GlobalTextureData.asset");
        GlobalTextureData globalData = AssetDatabase.LoadAssetAtPath<GlobalTextureData>(assetPath);
        if (globalData == null)
        {
            globalData = ScriptableObject.CreateInstance<GlobalTextureData>();
            AssetDatabase.CreateAsset(globalData, assetPath);
            Debug.Log("GlobalTextureData asset created at " + assetPath);
        }
        else
        {
            Debug.Log("GlobalTextureData asset already exists.");
        }

        Texture2D gradientTex = LUTGenerator.GenerateGradientTexture(LUTData.Gradient);
        LUTTextureToAsset.Save(gradientTex, lutFolder, "GradientTex");
        globalData.gradTexture = gradientTex;

        Texture2D permTex = LUTGenerator.GeneratePermutationTexture(LUTData.Permutation);
        LUTTextureToAsset.Save(permTex, lutFolder, "PermutationTex");
        globalData.permTexture = permTex;

        EditorUtility.SetDirty(globalData);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("GlobalTextureData + LUT textures created and assigned!");
    }

    static void EnsureFolderExists(string path)
    {
        if (!AssetDatabase.IsValidFolder(path))
        {
            string parent = Path.GetDirectoryName(path);
            string newFolder = Path.GetFileName(path);
            if (!AssetDatabase.IsValidFolder(parent))
                EnsureFolderExists(parent);
            AssetDatabase.CreateFolder(parent, newFolder);
            Debug.Log($"Folder created: {path}");
        }
    }
}
