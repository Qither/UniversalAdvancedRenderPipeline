using System;
using URPDiffusionProfile.Runtime.Core;
using UnityEditor;
using UnityEngine;

namespace URPDiffusionProfile.EditorTools
{
    internal static class DiffusionProfileMaterialUI
    {
        private static readonly string kNotAssigned = "The diffusion profile on this material is not assigned.\nThe material will be rendered with an error color.";

        internal static bool IsSupported(MaterialEditor materialEditor)
        {
            foreach (var target in materialEditor.targets)
            {
                if (target is not Material material)
                {
                    continue;
                }

                if (!material.HasProperty("_DiffusionProfileAsset") || !material.HasProperty("_DiffusionProfileHash"))
                {
                    return false;
                }
            }

            return true;
        }

        internal static void OnGUI(MaterialEditor materialEditor, MaterialProperty diffusionProfileAsset, MaterialProperty diffusionProfileHash, string displayName = "Diffusion Profile")
        {
            MaterialEditor.BeginProperty(diffusionProfileAsset);
            MaterialEditor.BeginProperty(diffusionProfileHash);

            var guid = ConvertVector4ToGuid(diffusionProfileAsset.vectorValue);
            var profile = string.IsNullOrEmpty(guid)
                ? null
                : AssetDatabase.LoadAssetAtPath<URPDiffusionProfileAsset>(AssetDatabase.GUIDToAssetPath(guid));

            EditorGUI.BeginChangeCheck();
            profile = (URPDiffusionProfileAsset)EditorGUILayout.ObjectField(displayName, profile, typeof(URPDiffusionProfileAsset), false);
            if (EditorGUI.EndChangeCheck())
            {
                var encodedGuid = Vector4.zero;
                var hash = 0f;
                if (profile != null)
                {
                    var path = AssetDatabase.GetAssetPath(profile);
                    encodedGuid = ConvertGuidToVector4(AssetDatabase.AssetPathToGUID(path));
                    hash = BitConverter.Int32BitsToSingle(unchecked((int)profile.ProfileHash));
                }

                diffusionProfileAsset.vectorValue = encodedGuid;
                diffusionProfileHash.floatValue = hash;
            }

            MaterialEditor.EndProperty();
            MaterialEditor.EndProperty();

            if (profile == null)
            {
                EditorGUILayout.HelpBox(kNotAssigned, MessageType.Error);
            }
        }

        private static Vector4 ConvertGuidToVector4(string guid)
        {
            if (string.IsNullOrEmpty(guid) || guid.Length != 32)
            {
                return Vector4.zero;
            }

            return new Vector4(
                UInt32ToFloat(Convert.ToUInt32(guid.Substring(0, 8), 16)),
                UInt32ToFloat(Convert.ToUInt32(guid.Substring(8, 8), 16)),
                UInt32ToFloat(Convert.ToUInt32(guid.Substring(16, 8), 16)),
                UInt32ToFloat(Convert.ToUInt32(guid.Substring(24, 8), 16)));
        }

        private static string ConvertVector4ToGuid(Vector4 value)
        {
            return string.Concat(
                FloatToUInt32(value.x).ToString("x8"),
                FloatToUInt32(value.y).ToString("x8"),
                FloatToUInt32(value.z).ToString("x8"),
                FloatToUInt32(value.w).ToString("x8"));
        }

        private static float UInt32ToFloat(uint value)
        {
            return BitConverter.Int32BitsToSingle(unchecked((int)value));
        }

        private static uint FloatToUInt32(float value)
        {
            return unchecked((uint)BitConverter.SingleToInt32Bits(value));
        }
    }
}
