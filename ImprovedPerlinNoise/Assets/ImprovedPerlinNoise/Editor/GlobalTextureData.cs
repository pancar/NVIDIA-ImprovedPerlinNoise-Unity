#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName = "GlobalTextureData", menuName = "Rendering/Global Texture Data")]
public class GlobalTextureData : ScriptableObject
{
    public Texture permTexture;
    public Texture gradTexture;

    public static GlobalTextureData Instance;

    private void OnEnable()
    {
        Instance = this;
        ApplyGlobals();
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        ApplyGlobals();
    }

    [InitializeOnLoadMethod]
    static void EditorRegister()
    {
        // Editör idle loop’una bağla
        EditorApplication.update += () =>
        {
            if (Instance == null)
            {
                Instance = AssetDatabase.LoadAssetAtPath<GlobalTextureData>(
                    "Assets/Resources/GlobalTextureData.asset");
            }
            ApplyGlobals();
        };
    }
#endif

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    static void RuntimeRegister()
    {
        if (Instance == null)
            Instance = Resources.Load<GlobalTextureData>("GlobalTextureData");

        ApplyGlobals();

        RenderPipelineManager.beginFrameRendering += (ctx, cams) => { ApplyGlobals(); };
    }

    static void ApplyGlobals()
    {
        if (Instance == null) return;

        if (Instance.permTexture != null)
            Shader.SetGlobalTexture("_PermutationTex", Instance.permTexture);

        if (Instance.gradTexture != null)
            Shader.SetGlobalTexture("_GradientTex", Instance.gradTexture);
    }
}