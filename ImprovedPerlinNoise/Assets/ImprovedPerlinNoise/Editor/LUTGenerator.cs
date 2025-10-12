using UnityEngine;

public static class LUTGenerator
{
    public static Texture2D GenerateGradientTexture(float[] gradient)
    {
        int vectorCount = gradient.Length / 3;
        Texture2D tex = new Texture2D(vectorCount, 1, TextureFormat.RGBAFloat, false, true);
        tex.wrapMode = TextureWrapMode.Repeat;
        tex.filterMode = FilterMode.Point;

        for (int i = 0; i < vectorCount; i++)
        {
            float x = (gradient[i * 3 + 0] + 1f) * 0.5f;
            float y = (gradient[i * 3 + 1] + 1f) * 0.5f;
            float z = (gradient[i * 3 + 2] + 1f) * 0.5f;

            tex.SetPixel(i, 0, new Color(x, y, z, 1f));
        }

        tex.Apply();

        return tex;
    }

    public static Texture2D GeneratePermutationTexture(int[] permutation)
    {
        Texture2D tex = new Texture2D(256, 1, TextureFormat.RFloat, false, true);
        tex.wrapMode = TextureWrapMode.Repeat;
        tex.filterMode = FilterMode.Point;

        for (int i = 0; i < 256; i++)
        {
            float value = permutation[i] / 255.0f;
            tex.SetPixel(i, 0, new Color(value, 0, 0, 1f));
        }

        tex.Apply();

        return tex;
    }
}