using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace UARP.Editor
{
    internal static class UARPMaterialMigration
    {
        private static readonly Dictionary<string, string> ShaderMap = new()
        {
            { "URP+/SimpleLit", "UARP/SimpleLit" },
            { "URP+/Lit", "UARP/Lit" },
            { "URP+/LitTessellation", "UARP/LitTessellation" },
            { "URP+/ComplexLit", "UARP/ComplexLit" },
            { "URP+/ComplexLitTessellation", "UARP/ComplexLitTessellation" },
            { "URP+/Fabric", "UARP/Fabric" },
            { "URP+/Hair", "UARP/Hair" },
            { "URP+/Eye", "UARP/Eye" },
            { "URP+/LayeredLit", "UARP/LayeredLit" },
            { "URP+/LayeredLitTessellation", "UARP/LayeredLitTessellation" },
            { "BadDog/URP/SSSLit", "UARP/LitSSS" }
        };

        [MenuItem("Tools/UARP/Migrate Selected Materials")]
        private static void MigrateSelectedMaterials()
        {
            var materials = new List<Material>();
            foreach (var obj in Selection.objects)
            {
                if (obj is Material material)
                {
                    materials.Add(material);
                }
            }

            MigrateMaterials(materials);
        }

        [MenuItem("Tools/UARP/Migrate All Project Materials")]
        private static void MigrateAllMaterials()
        {
            var materials = new List<Material>();
            foreach (var guid in AssetDatabase.FindAssets("t:Material"))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (material != null)
                {
                    materials.Add(material);
                }
            }

            MigrateMaterials(materials);
        }

        private static void MigrateMaterials(List<Material> materials)
        {
            var migratedCount = 0;

            foreach (var material in materials)
            {
                if (material.shader == null)
                {
                    continue;
                }

                if (!ShaderMap.TryGetValue(material.shader.name, out var newShaderName))
                {
                    continue;
                }

                var newShader = Shader.Find(newShaderName);
                if (newShader == null)
                {
                    Debug.LogWarning($"UARP migration skipped '{material.name}': shader '{newShaderName}' was not found.", material);
                    continue;
                }

                Undo.RecordObject(material, "Migrate Material To UARP");
                material.shader = newShader;
                EditorUtility.SetDirty(material);
                migratedCount++;
            }

            if (migratedCount > 0)
            {
                AssetDatabase.SaveAssets();
            }

            Debug.Log($"UARP material migration finished. Migrated {migratedCount} material(s).");
        }
    }
}
